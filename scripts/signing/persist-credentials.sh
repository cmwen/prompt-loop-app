#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Persist Signing Credentials to GitHub Secrets
# =============================================================================
# This script uploads signing credentials from a downloaded artifact to GitHub
# repository secrets, ensuring consistent app signing across releases.
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated: gh auth login
#   - Downloaded signing-credentials artifact from workflow run
#
# Usage: 
#   ./scripts/signing/persist-credentials.sh [path-to-credentials-json]
#
# Example:
#   ./scripts/signing/persist-credentials.sh ./signing-credentials/signing-credentials.json
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║         🔐 Persist Signing Credentials to GitHub Secrets         ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check for gh CLI
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed.${NC}"
    echo ""
    echo "Please install it from: https://cli.github.com/"
    echo "Then authenticate with: gh auth login"
    exit 1
fi

# Check if gh is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI is not authenticated.${NC}"
    echo ""
    echo "Please run: gh auth login"
    exit 1
fi

# Get credentials file path
CREDENTIALS_FILE="${1:-}"

if [[ -z "$CREDENTIALS_FILE" ]]; then
    echo -e "${YELLOW}Looking for signing-credentials.json in common locations...${NC}"
    
    # Check common locations
    POSSIBLE_PATHS=(
        "./signing-credentials/signing-credentials.json"
        "./signing-credentials.json"
        "$HOME/Downloads/signing-credentials/signing-credentials.json"
        "$HOME/Downloads/signing-credentials.json"
    )
    
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            CREDENTIALS_FILE="$path"
            echo -e "${GREEN}Found credentials at: $CREDENTIALS_FILE${NC}"
            break
        fi
    done
fi

if [[ -z "$CREDENTIALS_FILE" || ! -f "$CREDENTIALS_FILE" ]]; then
    echo -e "${RED}❌ Error: Could not find signing-credentials.json${NC}"
    echo ""
    echo "Usage: $0 <path-to-signing-credentials.json>"
    echo ""
    echo "To get the credentials file:"
    echo "  1. Go to your GitHub repository"
    echo "  2. Navigate to Actions → Your workflow run"
    echo "  3. Download the 'signing-credentials' artifact"
    echo "  4. Extract the ZIP file"
    echo "  5. Run this script with the path to signing-credentials.json"
    exit 1
fi

echo -e "${BLUE}📄 Reading credentials from: $CREDENTIALS_FILE${NC}"

# Check if jq is available, otherwise use grep/sed
if command -v jq &> /dev/null; then
    KEYSTORE_BASE64=$(jq -r '.keystore_base64' "$CREDENTIALS_FILE")
    KEYSTORE_PASSWORD=$(jq -r '.keystore_password' "$CREDENTIALS_FILE")
    KEY_ALIAS=$(jq -r '.key_alias' "$CREDENTIALS_FILE")
    KEY_PASSWORD=$(jq -r '.key_password' "$CREDENTIALS_FILE")
else
    echo -e "${YELLOW}Note: jq not found, using fallback parsing${NC}"
    # Fallback to grep/sed for JSON parsing
    KEYSTORE_BASE64=$(grep -o '"keystore_base64"[[:space:]]*:[[:space:]]*"[^"]*"' "$CREDENTIALS_FILE" | sed 's/.*: *"\([^"]*\)"/\1/')
    KEYSTORE_PASSWORD=$(grep -o '"keystore_password"[[:space:]]*:[[:space:]]*"[^"]*"' "$CREDENTIALS_FILE" | sed 's/.*: *"\([^"]*\)"/\1/')
    KEY_ALIAS=$(grep -o '"key_alias"[[:space:]]*:[[:space:]]*"[^"]*"' "$CREDENTIALS_FILE" | sed 's/.*: *"\([^"]*\)"/\1/')
    KEY_PASSWORD=$(grep -o '"key_password"[[:space:]]*:[[:space:]]*"[^"]*"' "$CREDENTIALS_FILE" | sed 's/.*: *"\([^"]*\)"/\1/')
fi

# Validate we got all values
if [[ -z "$KEYSTORE_BASE64" || -z "$KEYSTORE_PASSWORD" || -z "$KEY_ALIAS" || -z "$KEY_PASSWORD" ]]; then
    echo -e "${RED}❌ Error: Could not parse all required values from credentials file${NC}"
    echo "Please ensure the file contains: keystore_base64, keystore_password, key_alias, key_password"
    exit 1
fi

echo -e "${GREEN}✓ Credentials parsed successfully${NC}"
echo ""

# Get repository info
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "")

if [[ -z "$REPO" ]]; then
    echo -e "${YELLOW}Could not detect repository. Please enter the repository (owner/repo):${NC}"
    read -p "Repository: " REPO
fi

echo -e "${BLUE}📦 Target repository: ${REPO}${NC}"
echo ""

# Confirm with user
echo -e "${YELLOW}This will create/update the following secrets in ${REPO}:${NC}"
echo "  - ANDROID_KEYSTORE_BASE64"
echo "  - ANDROID_KEYSTORE_PASSWORD"
echo "  - ANDROID_KEY_ALIAS"
echo "  - ANDROID_KEY_PASSWORD"
echo ""
read -p "Continue? [y/N]: " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled by user.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🔄 Uploading secrets...${NC}"

# Upload each secret
echo -n "  ANDROID_KEYSTORE_BASE64... "
if echo "$KEYSTORE_BASE64" | gh secret set ANDROID_KEYSTORE_BASE64 --repo "$REPO" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}Failed to set ANDROID_KEYSTORE_BASE64${NC}"
    exit 1
fi

echo -n "  ANDROID_KEYSTORE_PASSWORD... "
if echo "$KEYSTORE_PASSWORD" | gh secret set ANDROID_KEYSTORE_PASSWORD --repo "$REPO" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}Failed to set ANDROID_KEYSTORE_PASSWORD${NC}"
    exit 1
fi

echo -n "  ANDROID_KEY_ALIAS... "
if echo "$KEY_ALIAS" | gh secret set ANDROID_KEY_ALIAS --repo "$REPO" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}Failed to set ANDROID_KEY_ALIAS${NC}"
    exit 1
fi

echo -n "  ANDROID_KEY_PASSWORD... "
if echo "$KEY_PASSWORD" | gh secret set ANDROID_KEY_PASSWORD --repo "$REPO" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo -e "${RED}Failed to set ANDROID_KEY_PASSWORD${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║                    🎉 Secrets Saved! 🎉                           ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}Your signing credentials have been saved to GitHub Secrets.${NC}"
echo ""
echo "Future releases will automatically use these credentials to sign your app."
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Please securely backup or delete the credentials file:${NC}"
echo "   rm -f $CREDENTIALS_FILE"
echo ""
echo -e "${GREEN}You can now trigger a new release and it will use the persisted keystore!${NC}"
