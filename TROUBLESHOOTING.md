# Troubleshooting Guide

This guide helps you solve common issues when using this template.

---

## Table of Contents

- [Installation Issues](#installation-issues)
- [Build Errors](#build-errors)
- [Runtime Errors](#runtime-errors)
- [IDE Issues](#ide-issues)
- [CI/CD Issues](#cicd-issues)
- [Common Error Messages](#common-error-messages)

---

## Installation Issues

### ❌ "flutter: command not found"

**Cause:** Flutter is not in your PATH.

**Fix:**
```bash
# macOS/Linux - add to ~/.zshrc or ~/.bashrc
export PATH="$PATH:$HOME/development/flutter/bin"
source ~/.zshrc

# Windows - add to System Environment Variables
# Path: C:\development\flutter\bin
```

### ❌ "java: command not found" or wrong Java version

**Cause:** Java 17 is not installed or not set as default.

**Fix:**
```bash
# Check current version
java -version

# macOS - set Java 17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Linux - set Java 17
sudo update-alternatives --config java
# Select Java 17

# Windows - set JAVA_HOME environment variable
# JAVA_HOME: C:\Program Files\Java\jdk-17
```

### ❌ "Android SDK not found"

**Cause:** Android SDK location not configured.

**Fix:**
```bash
# Find your SDK location
# macOS: ~/Library/Android/sdk
# Windows: %LOCALAPPDATA%\Android\Sdk
# Linux: ~/Android/Sdk

# Configure Flutter
flutter config --android-sdk /path/to/your/sdk
```

### ❌ "Android license status unknown"

**Cause:** Android licenses not accepted.

**Fix:**
```bash
flutter doctor --android-licenses
# Press 'y' to accept all licenses
```

---

## Build Errors

### ❌ "Unresolved reference" after renaming app

**Cause:** Dart import statements reference old package name.

**Fix:**
```bash
# Clean and regenerate
flutter clean
flutter pub get

# Auto-fix imports
dart fix --apply

# If still broken, manually search for old package name:
grep -r "min_flutter_template" lib/ test/
```

### ❌ Gradle build fails with memory error

**Cause:** Not enough memory allocated for Gradle.

**Fix:**
```bash
# Increase Gradle memory in android/gradle.properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G
```

### ❌ "Could not resolve all files for configuration"

**Cause:** Gradle dependency resolution failure.

**Fix:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### ❌ "Namespace not specified" error

**Cause:** Android Gradle Plugin 8.0+ requires namespace in build.gradle.kts.

**Fix:**
The template already includes namespace. If you see this error:
```kotlin
// android/app/build.gradle.kts
android {
    namespace = "com.yourcompany.yourapp"  // Ensure this exists
    ...
}
```

### ❌ Build takes forever (>10 minutes)

**Cause:** First build downloads dependencies; subsequent builds should be cached.

**Fix:**
1. First build is slow - this is normal
2. Don't run `flutter clean` unnecessarily
3. Check internet connection
4. Try:
```bash
flutter pub cache clean
flutter pub get
```

---

## Runtime Errors

### ❌ App crashes on launch

**Possible causes and fixes:**

1. **Missing permissions:**
   ```xml
   <!-- android/app/src/main/AndroidManifest.xml -->
   <uses-permission android:name="android.permission.INTERNET" />
   ```

2. **Minimum SDK too high:**
   Check device Android version vs minSdkVersion in build.gradle.kts

3. **Debug crash:**
   ```bash
   flutter run --verbose
   # Look for the actual error message
   ```

### ❌ "setState() called after dispose()"

**Cause:** Async operation completes after widget is unmounted.

**Fix:**
```dart
@override
void dispose() {
  // Cancel any pending operations
  super.dispose();
}

// Check if mounted before setState
if (mounted) {
  setState(() { ... });
}
```

### ❌ Network requests fail on Android

**Cause:** Cleartext traffic blocked by default on Android 9+.

**Fix:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="true"
    ...>
```

Or better, use HTTPS for all requests.

---

## IDE Issues

### ❌ VS Code doesn't recognize Flutter

**Fix:**
1. Install Flutter and Dart extensions
2. Restart VS Code
3. Run `Flutter: Run Flutter Doctor` from command palette

### ❌ Red squiggles everywhere (imports not found)

**Fix:**
```bash
flutter pub get
# Then restart VS Code or Dart analyzer

# VS Code: Cmd/Ctrl + Shift + P → "Dart: Restart Analysis Server"
```

### ❌ Emulator doesn't start

**Fix:**
```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_id>

# Or create new one in Android Studio:
# Tools → Device Manager → Create Device
```

### ❌ Hot reload not working

**Fix:**
1. Ensure app is running in debug mode
2. Try hot restart instead: press `R` in terminal
3. Full restart: press `Shift+R` in terminal
4. Last resort: Stop and restart the app

---

## CI/CD Issues

### ❌ GitHub Actions workflow fails

**Check these common causes:**

1. **Secrets not configured:**
   - Go to repo Settings → Secrets → Actions
   - Add required secrets (see release.yml)

2. **Flutter version mismatch:**
   ```yaml
   # .github/workflows/build.yml
   - uses: subosito/flutter-action@v2
     with:
       flutter-version: '3.38.3'  # Check this matches your local version
   ```

3. **Permissions issue:**
   ```yaml
   permissions:
     contents: write  # Required for releases
   ```

### ❌ Keystore issues in release workflow

**Check:**
1. Base64 encoding is correct:
   ```bash
   base64 -i your-keystore.jks -o keystore-base64.txt
   # Copy entire content to ANDROID_KEYSTORE_BASE64 secret
   ```

2. All four secrets are set:
   - ANDROID_KEYSTORE_BASE64
   - ANDROID_KEYSTORE_PASSWORD
   - ANDROID_KEY_ALIAS
   - ANDROID_KEY_PASSWORD

### ❌ Codecov upload fails

**Cause:** CODECOV_TOKEN not set (optional).

**Fix:** Either:
1. Add CODECOV_TOKEN secret from codecov.io
2. Or ignore - coverage upload is set to `fail_ci_if_error: false`

---

## Common Error Messages

### "The Dart SDK version does not satisfy the constraint"

**Cause:** Your Flutter/Dart version is too old or too new.

**Fix:**
```bash
# Update Flutter to latest stable
flutter upgrade

# Or use specific version
flutter downgrade 3.38.3
```

### "Waiting for another flutter command to release the startup lock"

**Cause:** Another Flutter process is running.

**Fix:**
```bash
# Kill all Flutter processes
killall -9 dart flutter

# Remove lock file
rm -rf ~/flutter/bin/cache/lockfile
```

### "FAILURE: Build failed with an exception"

**Cause:** Generic Gradle build failure.

**Fix:**
```bash
# Get more details
cd android
./gradlew build --stacktrace

# Clean everything
cd ..
flutter clean
flutter pub get
```

### "Your project requires a newer version of the Kotlin Gradle plugin"

**Cause:** Kotlin version mismatch.

**Fix:**
Check `android/settings.gradle.kts` has correct Kotlin version:
```kotlin
plugins {
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}
```

---

## Still Stuck?

### 1. Search for the error
Copy the exact error message and search:
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter GitHub Issues](https://github.com/flutter/flutter/issues)

### 2. Ask AI for help
```
I'm getting this error in my Flutter app:

[PASTE ENTIRE ERROR MESSAGE]

Here's my relevant code:
[PASTE CODE]

I'm using Flutter 3.x.x and this template. How do I fix this?
```

### 3. Check Flutter doctor
```bash
flutter doctor -v
```
This often reveals the root cause.

### 4. Clean everything
The nuclear option:
```bash
flutter clean
rm -rf pubspec.lock
rm -rf .dart_tool
rm -rf build
rm -rf android/.gradle
rm -rf android/app/build
flutter pub get
```

---

## Getting More Help

- **Flutter Documentation:** https://docs.flutter.dev
- **Flutter Discord:** https://discord.gg/flutter
- **Stack Overflow:** https://stackoverflow.com/questions/tagged/flutter
- **GitHub Issues:** For template-specific issues
