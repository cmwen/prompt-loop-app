# Prerequisites

This document outlines all the tools you need to install before using this template.

## Quick Checklist

- [ ] Java 17+ (OpenJDK or Oracle JDK)
- [ ] Flutter SDK 3.10.1+
- [ ] Android Studio (for Android SDK and emulator)
- [ ] Git
- [ ] VS Code with GitHub Copilot (recommended)

---

## Detailed Installation Guide

### 1. Java 17+

**Why?** Required for Android builds (Gradle and Android SDK tools).

#### macOS

```bash
# Using Homebrew (recommended)
brew install openjdk@17

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$PATH"
```

#### Windows

1. Download from [Adoptium](https://adoptium.net/temurin/releases/?version=17)
2. Run the installer
3. Check "Set JAVA_HOME variable" during installation

#### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

#### Verify Installation

```bash
java -version
# Expected output: openjdk version "17.x.x" or similar
```

---

### 2. Flutter SDK 3.10.1+

**Why?** The framework used to build the Android app.

#### macOS

```bash
# Using Homebrew
brew install flutter

# Or manual installation
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

#### Windows

1. Download from [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. Extract to `C:\development\flutter`
3. Add to PATH: `C:\development\flutter\bin`

#### Linux

```bash
# Using snap (recommended)
sudo snap install flutter --classic

# Or manual installation
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/development/flutter/bin"
```

#### Verify Installation

```bash
flutter --version
# Expected: Flutter 3.x.x

flutter doctor
# Should show all green checkmarks for Android
```

---

### 3. Android Studio

**Why?** Provides Android SDK, platform tools, and emulator.

1. Download from [developer.android.com/studio](https://developer.android.com/studio)
2. Install and run Android Studio
3. Complete the setup wizard (downloads Android SDK)
4. Install at least one Android SDK Platform (API 33+ recommended)
5. (Optional) Create an Android Virtual Device (AVD) for testing

#### Verify Android SDK

```bash
flutter doctor
# Should show: [✓] Android toolchain
```

---

### 4. Git

**Why?** Version control and cloning the template.

#### macOS

```bash
# Usually pre-installed, or:
xcode-select --install
```

#### Windows

Download from [git-scm.com](https://git-scm.com/download/win)

#### Linux

```bash
sudo apt install git
```

#### Verify Installation

```bash
git --version
# Expected: git version 2.x.x
```

---

### 5. VS Code (Recommended)

**Why?** Best experience with GitHub Copilot AI agents.

1. Download from [code.visualstudio.com](https://code.visualstudio.com)
2. Install these extensions:
   - Flutter
   - Dart
   - GitHub Copilot
   - GitHub Copilot Chat

---

## Troubleshooting

### Java version mismatch

If you have multiple Java versions:

```bash
# macOS - List all Java versions
/usr/libexec/java_home -V

# Set specific version
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

### Flutter not found

Add Flutter to your PATH permanently:

```bash
# macOS/Linux - add to ~/.zshrc or ~/.bashrc
export PATH="$PATH:$HOME/development/flutter/bin"

# Reload shell
source ~/.zshrc
```

### Android SDK not found

```bash
# Check SDK location
flutter config --android-sdk /path/to/android/sdk

# Common locations:
# macOS: ~/Library/Android/sdk
# Windows: %LOCALAPPDATA%\Android\Sdk
# Linux: ~/Android/Sdk
```

### flutter doctor shows issues

```bash
# Accept Android licenses
flutter doctor --android-licenses

# Run full diagnostics
flutter doctor -v
```

---

## Minimum System Requirements

| Platform | RAM | Disk Space | Notes |
|----------|-----|------------|-------|
| macOS | 8GB+ | 10GB+ | macOS 10.14+ |
| Windows | 8GB+ | 10GB+ | Windows 10+ |
| Linux | 8GB+ | 10GB+ | 64-bit |

---

## Alternative: GitHub Codespaces

**No installation required!** Use GitHub Codespaces for a fully configured cloud environment:

1. Fork this repository
2. Click **Code** → **Codespaces** → **Create codespace on main**
3. Wait 2-3 minutes for setup
4. Start coding!

Note: Codespaces provides a browser-based VS Code with all tools pre-installed.

---

## Verification Commands

Run these commands to verify your setup is complete:

```bash
# Check all tools
java -version          # Should show 17.x.x
flutter --version      # Should show 3.10.1+
git --version          # Any recent version
flutter doctor         # All checks should pass

# Test the template
cd your-app-folder
flutter pub get        # Should complete without errors
flutter analyze        # Should pass
flutter test           # Should pass (1 test)
```

---

## Next Steps

Once all prerequisites are installed:

1. Clone or use this template
2. Run `./scripts/setup/quick-start.sh` to customize your app
3. Follow [GETTING_STARTED.md](GETTING_STARTED.md) for detailed setup
