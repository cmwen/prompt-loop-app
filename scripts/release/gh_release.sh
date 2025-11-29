#!/usr/bin/env bash
set -euo pipefail

# Helper script to validate release preconditions and trigger the release workflow
# Requirements: gh (GitHub CLI) authenticated, node/npm (if website exists), git

BRANCH=main
WORKFLOW_FILE=release.yml
SKIP_CHECKS=false

usage() {
  cat <<EOF
Usage: $0 [--branch BRANCH] [--workflow FILE] [--skip-checks]

Checks that GitHub Actions for the branch are green, that docs build locally,
and that a CHANGELOG.md exists (soft-check). Then it dispatches the
${WORKFLOW_FILE} workflow on the chosen branch via the GitHub CLI.

Examples:
  $0
  $0 --branch develop
  $0 --skip-checks
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      BRANCH="$2"; shift 2 ;;
    --workflow)
      WORKFLOW_FILE="$2"; shift 2 ;;
    --skip-checks)
      SKIP_CHECKS=true; shift 1 ;;
    -h|--help)
      usage;;
    *)
      echo "Unknown argument: $1" >&2; usage;;
  esac
done

echo "Releasing from branch: $BRANCH"

command -v gh >/dev/null 2>&1 || { echo "gh (GitHub CLI) is required. Please install and authenticate (gh auth login)." >&2; exit 2; }
command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 2; }

if [ "$SKIP_CHECKS" = false ]; then
  # Make sure local view of remote is up-to-date
  echo "Fetching latest refs from origin..."
  git fetch origin "$BRANCH" --quiet || true

  # Find the commit sha at the tip of the branch on origin
  SHA=$(git rev-parse --verify origin/$BRANCH)
  echo "Latest commit on origin/$BRANCH: $SHA"

  echo "Checking CI status for commit $SHA ..."
  # Use check-runs for the commit — all checks must be 'success'
  conclusions=$(gh api -X GET "/repos/$(gh repo view --json name,owner -q '.owner.login + "/" + .name')/commits/$SHA/check-runs" --jq '.check_runs[].conclusion' 2>/dev/null || true)

  if [ -z "$conclusions" ]; then
    echo "Warning: could not find check-run conclusions for commit $SHA. There may be no runs yet or you have limited permissions." >&2
  else
    bad=$(printf "%s\n" "$conclusions" | grep -vE "^success$" || true)
    if [ -n "$bad" ]; then
      echo "One or more check runs are not 'success' for $SHA:" >&2
      printf "%s\n" "$conclusions"
      echo "Aborting release. Fix failing CI runs first." >&2
      exit 3
    fi
  fi

  # Also ensure at least one workflow run for this branch is complete and successful for the main workflow
  echo "Looking up last workflow run for workflow file: $WORKFLOW_FILE on branch: $BRANCH"
  latest_conclusion=$(gh run list --branch "$BRANCH" --workflow "$WORKFLOW_FILE" --limit 1 --json conclusion -q '.[0].conclusion' 2>/dev/null || true)
  if [ -z "$latest_conclusion" ]; then
    echo "No completed workflow run found for $WORKFLOW_FILE on branch $BRANCH. You might still trigger, but consider confirming your CI state." >&2
  else
    if [ "$latest_conclusion" != "success" ]; then
      echo "Latest workflow run conclusion for $WORKFLOW_FILE was: $latest_conclusion" >&2
      echo "Aborting release until workflows are green." >&2
      exit 4
    fi
  fi

  # Quick docs check
  if [ -d website ]; then
    echo "Running a quick website build to validate docs..."
    if command -v npm >/dev/null 2>&1; then
      (cd website && npm ci --silent) || { echo "npm ci failed in website/ — ensure your docs are up to date." >&2; exit 5; }
      (cd website && npm run build --silent) || { echo "Website build failed — fix docs before releasing." >&2; exit 6; }
      echo "Website build passed.";
    else
      echo "npm not installed — skipping website build check (you can use --skip-checks)." >&2
    fi
  else
    echo "No website/ directory found — skipping docs build check.";
  fi

  # Changelog check (soft)
  if [ ! -f CHANGELOG.md ]; then
    echo "Warning: CHANGELOG.md not found in repo root. It's recommended to have release notes in CHANGELOG.md or a RELEASE_NOTES file." >&2
    read -p "Continue release despite missing CHANGELOG.md? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "Aborting release. Update or add CHANGELOG.md then retry." >&2
      exit 7
    fi
  else
    echo "Found CHANGELOG.md — good.";
  fi
fi

# Confirm and dispatch
printf "\nReady to trigger workflow '%s' on branch '%s'.\n" "$WORKFLOW_FILE" "$BRANCH"
read -p "Trigger release workflow now? [y/N] " proceed
if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
  echo "Cancelled by user."; exit 0
fi

echo "Triggering workflow: $WORKFLOW_FILE on ref: $BRANCH"
gh workflow run "$WORKFLOW_FILE" --ref "$BRANCH"

echo "Workflow dispatched. You can watch runs with: gh run list --branch $BRANCH" 

exit 0
