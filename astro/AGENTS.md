# Agents guide — astro/

This file explains how AI agents and automated tools should work with the `astro/` Astro project for the `min-android-app-template` repository.

Keep these instructions concise and actionable — follow them when making edits, testing locally, or changing CI/deployment behavior.

## Project overview

- Location: `astro/` (this directory contains an Astro site with a Startlight-inspired theme)
- Build output: `astro/dist/` (static files produced by `npm run build`)
- Hosted: GitHub Pages via `.github/workflows/deploy-website.yml` (build & deploy when a GitHub Release is published)

## GitHub Pages URL Configuration

The site URL is configured in `astro/astro.config.mjs`. To customize for your deployment:

1. Edit `GITHUB_USERNAME` and `REPO_NAME` constants at the top of the file
2. The site will be deployed to: `https://<GITHUB_USERNAME>.github.io/<REPO_NAME>/`

Example:
```js
const GITHUB_USERNAME = 'your-username';
const REPO_NAME = 'your-repo-name';
```

## Local environment & expectations

- Node: use Node 18+ (see `package.json` engines field). The site uses Astro v5.15 — prefer `npm ci` to get supported versions.
- Commands:
  - `npm ci` — install exact dependencies for CI
  - `npm install` — install locally for development
  - `npm run dev` — start the dev server
  - `npm run build` — create a static site in `astro/dist/`
  - `npm run preview` — preview the built output locally

## Common tasks for agents

- Add or edit content
  - Modify or create files under `astro/src/pages/` for content pages.
  - For reusable sections or patterns, add components under `astro/src/components/` and use layouts in `astro/src/layouts/`.
  - Keep copy short and link back to repository files as appropriate.

- Styling and assets
  - Minor theme tweaks should go in `astro/src/styles.css`.
  - Add media assets to `astro/public/` if needed (create the folder). Don't commit very large files; prefer optimized images.

  - Project prompts & design helpers
    - The repository contains Copilot custom prompts under `.github/prompts/` (e.g. `icon-generation.prompt.md`) — use these for consistent, copy-ready prompts when generating icons, SVGs, VectorDrawable XML, or launcher assets.

- Structural changes
  - Adding new top-level routes: create `astro/src/pages/yourpage.astro`.
  - Add additional layouts in `astro/src/layouts/` and import them in pages.

- CI & deploy changes
  - The CI pipeline lives at `.github/workflows/deploy-website.yml` and builds `astro/dist/` to deploy to GitHub Pages — it runs when a GitHub Release is published (or via manual dispatch).
  - If a change requires a different Pages branch, the workflow must be updated and peer-reviewed.

## Authoring rules and conventions

- Keep pages accessible and lightweight — static HTML, minimal client JS.
- Use clear headings and short paragraphs (two to four sentences per paragraph).
- For any external links, use rel="noopener" and target="_blank".
- Follow the Startlight style: dark, elegant, compact cards and concise text.

## Testing & validation

- Build success: `npm run build` must finish with zero errors and generate files in `astro/dist/`.
- Manual preview: `npm run preview` should serve the `dist/` output for quick QA.

## When to open a PR vs. push to main

- Small content updates (typos, wording) may be pushed directly to main, only when you own the repo or have explicit permission.
- Feature changes, CI edits, or layout refactors must be made via pull request with description and a short testing checklist.

## Metadata & configuration

- Update `astro.config.mjs` if the site URL or other config changes are required. It currently contains the `site` and `base` values for GitHub Pages.

```js
// astro/astro.config.mjs
const GITHUB_USERNAME = 'cmwen';
const REPO_NAME = 'min-android-app-template';

export default defineConfig({
  site: `https://${GITHUB_USERNAME}.github.io`,
  base: `/${REPO_NAME}`,
});
```

If you change these values, ensure CI and README are consistent and update links where necessary.

## Review & release notes for maintainers

- Keep PRs small and scoped; always run `npm ci` and `npm run build` locally before asking for review.
- Document any breaking changes in the `astro/README.md` and in the top-level `README.md` if they affect the project or CI.
