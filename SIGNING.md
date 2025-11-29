# Android App Signing Guide

This guide explains how to sign your Android app for release.

## Overview

Android requires all apps to be digitally signed with a certificate (keystore) before they can be installed. The same keystore must be used for all updates to your app. **If you lose your keystore, you cannot update your app on the Play Store.**

This template provides three ways to handle signing:

1. **Auto-Generate** - The pipeline generates a keystore automatically
2. **Local Generation** - Use the provided script to create a keystore locally
3. **Manual Setup** - Traditional keystore generation and secret configuration

## Quick Start (Auto-Generate)

The easiest way to get started is to let the pipeline handle keystore generation:

1. **Trigger a release** by pushing a tag or using workflow dispatch
2. **Download the `signing-credentials` artifact** from the workflow run
3. **Run the persistence script** to save the credentials:
   ```bash
   ./scripts/signing/persist-credentials.sh ./signing-credentials.json
   ```
4. **Delete the credentials file** after persistence

That's it! Future releases will automatically use the persisted keystore.

## Local Generation (Interactive)

If you prefer to generate the keystore locally:

```bash
./scripts/signing/generate-keystore.sh
```

This interactive script will:
- Prompt for keystore details (passwords, certificate info)
- Generate a secure keystore
- Create the `key.properties` file for local builds
- Optionally upload to GitHub Secrets

## Manual Setup (Advanced)

### Step 1: Generate a Keystore

```bash
keytool -genkey -v \
  -keystore release-keystore.jks \
  -storepass YOUR_STORE_PASSWORD \
  -alias release \
  -keypass YOUR_KEY_PASSWORD \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -dname "CN=Your App, OU=Mobile, O=Your Company, L=City, ST=State, C=US"
```

### Step 2: Create key.properties (for local builds)

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=release
storeFile=release-keystore.jks
```

### Step 3: Add GitHub Secrets (for CI/CD)

1. Base64 encode the keystore:
   ```bash
   # macOS
   base64 -i release-keystore.jks | pbcopy
   
   # Linux
   base64 -w 0 release-keystore.jks
   ```

2. Go to your repository: **Settings → Secrets and variables → Actions**

3. Add these secrets:
   - `ANDROID_KEYSTORE_BASE64` - The base64-encoded keystore
   - `ANDROID_KEYSTORE_PASSWORD` - Your keystore password
   - `ANDROID_KEY_ALIAS` - `release` (or your chosen alias)
   - `ANDROID_KEY_PASSWORD` - Your key password

## Persisting Auto-Generated Credentials

If you used auto-generation and need to persist the credentials:

### Using the Script (Recommended)

```bash
# Download and extract the signing-credentials artifact
unzip signing-credentials-*.zip

# Run the persistence script
./scripts/signing/persist-credentials.sh ./signing-credentials.json

# Clean up
rm -rf signing-credentials* signing-credentials.json
```

### Manual Persistence

1. Download the `signing-credentials` artifact from the workflow run
2. Extract the ZIP file
3. Open `signing-credentials.json`
4. Go to **Settings → Secrets and variables → Actions**
5. Add each value as a repository secret:
   - `ANDROID_KEYSTORE_BASE64`
   - `ANDROID_KEYSTORE_PASSWORD`
   - `ANDROID_KEY_ALIAS`
   - `ANDROID_KEY_PASSWORD`

## How It Works

### The Signing Action

The template includes a composite GitHub Action (`.github/actions/setup-signing`) that:

1. **Checks for secrets** - If `ANDROID_KEYSTORE_BASE64` is provided, uses it
2. **Auto-generates if missing** - Creates a new keystore with secure random password
3. **Creates key.properties** - Configures Gradle to use the keystore
4. **Outputs credentials** - For auto-generated keystores, outputs the credentials for persistence

### Workflow Integration

Both `release.yml` and `pre-release.yml` use this action:

```yaml
- name: Setup Android Signing
  id: signing
  uses: ./.github/actions/setup-signing
  with:
    keystore_base64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
    keystore_password: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
    key_alias: ${{ secrets.ANDROID_KEY_ALIAS }}
    key_password: ${{ secrets.ANDROID_KEY_PASSWORD }}
```

If secrets aren't provided, the action generates a keystore and the workflow uploads the credentials as an artifact.

## Security Best Practices

### Do

- ✅ Back up your keystore in multiple secure locations
- ✅ Use strong, unique passwords
- ✅ Store secrets only in GitHub Secrets or secure vaults
- ✅ Delete credential files after persisting them
- ✅ Use the `.gitignore` entries provided (already configured)

### Don't

- ❌ Commit keystore files to version control
- ❌ Share keystore passwords via insecure channels
- ❌ Use the same keystore for multiple apps (unless they need to be signed together)
- ❌ Store credentials in plain text files

## Backup Recommendations

The keystore is **critical** for app updates. If lost, you cannot update your app. Back it up:

1. **Encrypted cloud storage** (Google Drive, Dropbox with encryption)
2. **Password manager** (1Password, Bitwarden - store keystore as attachment)
3. **Hardware backup** (encrypted USB drive in secure location)
4. **GitHub Secrets** (automatically backed up as part of your repository)

## Troubleshooting

### "No secrets found" but I added them

- Ensure secret names match exactly: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, etc.
- Check that secrets are repository secrets, not environment secrets (unless using environments)

### Build succeeds but APK isn't signed

- Verify `key.properties` is being created correctly
- Check that `storeFile` path is correct in key.properties
- Look at build logs for signing-related messages

### "Keystore was tampered with" error

- Password might be incorrect
- Keystore file might be corrupted
- Try re-encoding the keystore to base64

### Auto-generated keystore not working on subsequent runs

- You need to persist the credentials to GitHub Secrets
- Download the `signing-credentials` artifact and run the persistence script
- Or manually copy values to GitHub Secrets

## Related Files

- `.github/actions/setup-signing/action.yml` - Composite action for signing setup
- `.github/workflows/release.yml` - Release workflow
- `.github/workflows/pre-release.yml` - Pre-release workflow
- `scripts/signing/generate-keystore.sh` - Local keystore generation script
- `scripts/signing/persist-credentials.sh` - Credentials persistence script
- `android/app/build.gradle.kts` - Gradle signing configuration
