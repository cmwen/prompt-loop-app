#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Generate Android Release Keystore
# =============================================================================
# This script generates a new Android release keystore for signing your app.
# It creates the keystore and optionally uploads it to GitHub Secrets.
#
# Usage: ./scripts/signing/generate-keystore.sh
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
echo "║            🔐 Generate Android Release Keystore                   ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check for keytool
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}❌ Error: keytool is not installed.${NC}"
    echo "Please install Java JDK to get keytool."
    exit 1
fi

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default values
DEFAULT_KEYSTORE_NAME="release-keystore.jks"
DEFAULT_KEY_ALIAS="release"
DEFAULT_VALIDITY=10000

# Prompt for keystore location
echo -e "${GREEN}📁 Where would you like to save the keystore?${NC}"
echo "   1) android/app/ directory (recommended for local development)"
echo "   2) Custom location"
read -p "   Choice [1]: " LOCATION_CHOICE
LOCATION_CHOICE="${LOCATION_CHOICE:-1}"

if [[ "$LOCATION_CHOICE" == "1" ]]; then
    KEYSTORE_DIR="$PROJECT_ROOT/android/app"
    KEYSTORE_PATH="$KEYSTORE_DIR/$DEFAULT_KEYSTORE_NAME"
else
    read -p "   Enter full path for keystore: " KEYSTORE_PATH
    KEYSTORE_DIR=$(dirname "$KEYSTORE_PATH")
fi

# Check if keystore already exists
if [[ -f "$KEYSTORE_PATH" ]]; then
    echo -e "${YELLOW}⚠️  Keystore already exists at: $KEYSTORE_PATH${NC}"
    read -p "   Overwrite? [y/N]: " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Cancelled. Keeping existing keystore.${NC}"
        exit 0
    fi
    rm -f "$KEYSTORE_PATH"
fi

# Create directory if needed
mkdir -p "$KEYSTORE_DIR"

# Prompt for key alias
echo ""
echo -e "${GREEN}🏷️  Enter key alias:${NC}"
read -p "   Key alias [$DEFAULT_KEY_ALIAS]: " KEY_ALIAS
KEY_ALIAS="${KEY_ALIAS:-$DEFAULT_KEY_ALIAS}"

# Prompt for passwords
echo ""
echo -e "${GREEN}🔑 Enter keystore password (min 6 characters):${NC}"
while true; do
    read -s -p "   Password: " KEYSTORE_PASSWORD
    echo ""
    if [[ ${#KEYSTORE_PASSWORD} -lt 6 ]]; then
        echo -e "${RED}   Password must be at least 6 characters${NC}"
        continue
    fi
    read -s -p "   Confirm password: " KEYSTORE_PASSWORD_CONFIRM
    echo ""
    if [[ "$KEYSTORE_PASSWORD" != "$KEYSTORE_PASSWORD_CONFIRM" ]]; then
        echo -e "${RED}   Passwords do not match${NC}"
        continue
    fi
    break
done

echo ""
echo -e "${GREEN}🔑 Enter key password (press Enter to use same as keystore):${NC}"
read -s -p "   Key password: " KEY_PASSWORD
echo ""
KEY_PASSWORD="${KEY_PASSWORD:-$KEYSTORE_PASSWORD}"

# Certificate information
echo ""
echo -e "${GREEN}📋 Enter certificate information:${NC}"
read -p "   Your name or app name: " CN
read -p "   Organization (company name): " O
read -p "   City: " L
read -p "   State/Province: " ST
read -p "   Country code (e.g., US): " C

CN="${CN:-Android App}"
O="${O:-Development}"
L="${L:-City}"
ST="${ST:-State}"
C="${C:-US}"

DNAME="CN=$CN, OU=Mobile, O=$O, L=$L, ST=$ST, C=$C"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}📋 Summary:${NC}"
echo "   Keystore: $KEYSTORE_PATH"
echo "   Key alias: $KEY_ALIAS"
echo "   Certificate: $DNAME"
echo "   Validity: $DEFAULT_VALIDITY days (~27 years)"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
echo ""

read -p "Generate keystore? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled.${NC}"
    exit 0
fi

# Generate the keystore
echo ""
echo -e "${BLUE}🔄 Generating keystore...${NC}"

keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -storepass "$KEYSTORE_PASSWORD" \
    -alias "$KEY_ALIAS" \
    -keypass "$KEY_PASSWORD" \
    -keyalg RSA \
    -keysize 2048 \
    -validity $DEFAULT_VALIDITY \
    -dname "$DNAME"

echo ""
echo -e "${GREEN}✅ Keystore generated successfully!${NC}"

# Create key.properties if in android/app
if [[ "$KEYSTORE_DIR" == "$PROJECT_ROOT/android/app" ]]; then
    KEY_PROPERTIES="$PROJECT_ROOT/android/key.properties"
    
    echo ""
    echo -e "${BLUE}📝 Creating key.properties...${NC}"
    cat > "$KEY_PROPERTIES" << EOF
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$DEFAULT_KEYSTORE_NAME
EOF
    echo -e "${GREEN}✅ key.properties created at: $KEY_PROPERTIES${NC}"
fi

# Offer to upload to GitHub Secrets
echo ""
echo -e "${YELLOW}Would you like to upload these credentials to GitHub Secrets?${NC}"
echo "This allows GitHub Actions to sign your releases automatically."
read -p "Upload to GitHub? [y/N]: " UPLOAD

if [[ "$UPLOAD" =~ ^[Yy]$ ]]; then
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI (gh) not installed. Install from: https://cli.github.com/${NC}"
    elif ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not authenticated. Run: gh auth login${NC}"
    else
        REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "")
        
        if [[ -z "$REPO" ]]; then
            echo -e "${YELLOW}Could not detect repository.${NC}"
            read -p "Enter repository (owner/repo): " REPO
        fi
        
        echo ""
        echo -e "${BLUE}🔄 Uploading to GitHub Secrets for ${REPO}...${NC}"
        
        # Base64 encode the keystore (cross-platform: works on both Linux and macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            KEYSTORE_BASE64=$(base64 -i "$KEYSTORE_PATH" | tr -d '\n')
        else
            KEYSTORE_BASE64=$(base64 -w 0 "$KEYSTORE_PATH")
        fi
        
        echo -n "  ANDROID_KEYSTORE_BASE64... "
        echo "$KEYSTORE_BASE64" | gh secret set ANDROID_KEYSTORE_BASE64 --repo "$REPO" && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo -n "  ANDROID_KEYSTORE_PASSWORD... "
        echo "$KEYSTORE_PASSWORD" | gh secret set ANDROID_KEYSTORE_PASSWORD --repo "$REPO" && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo -n "  ANDROID_KEY_ALIAS... "
        echo "$KEY_ALIAS" | gh secret set ANDROID_KEY_ALIAS --repo "$REPO" && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo -n "  ANDROID_KEY_PASSWORD... "
        echo "$KEY_PASSWORD" | gh secret set ANDROID_KEY_PASSWORD --repo "$REPO" && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
        
        echo ""
        echo -e "${GREEN}✅ Secrets uploaded to GitHub!${NC}"
    fi
fi

echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║                    🎉 Keystore Ready! 🎉                          ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}⚠️  IMPORTANT: Back up your keystore securely!${NC}"
echo ""
echo "If you lose your keystore, you won't be able to update your app"
echo "on the Play Store with the same signing key."
echo ""
echo -e "${BLUE}Recommended backup locations:${NC}"
echo "  - Secure cloud storage (encrypted)"
echo "  - Password manager"
echo "  - Multiple secure physical locations"
echo ""

# Add to .gitignore if not already there
GITIGNORE="$PROJECT_ROOT/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
    if ! grep -q "release-keystore.jks" "$GITIGNORE"; then
        echo "" >> "$GITIGNORE"
        echo "# Android signing" >> "$GITIGNORE"
        echo "*.jks" >> "$GITIGNORE"
        echo "*.keystore" >> "$GITIGNORE"
        echo "key.properties" >> "$GITIGNORE"
        echo -e "${GREEN}✅ Added keystore files to .gitignore${NC}"
    fi
fi

echo -e "${GREEN}You're ready to build signed releases!${NC}"
