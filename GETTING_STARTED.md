# Getting Started Guide

Welcome! This guide will help you customize this Android Flutter template for your new app from scratch.

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ Flutter SDK 3.10.1+ ([Install Guide](https://docs.flutter.dev/get-started/install))
- ✅ Dart 3.10.1+
- ✅ Java 17+ (for Android builds)
- ✅ Android Studio (for Android development)
- ✅ Git
- ✅ VS Code with GitHub Copilot (recommended for AI assistance)

Verify your setup:
```bash
flutter doctor -v
java -version  # Should show version 17+
```

## 🚀 Quick Start Checklist

Follow these steps in order to customize the template for your app:

### Step 1: Clone and Setup

```bash
# Clone this template
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name

# Get dependencies
flutter pub get

# Verify everything works
flutter test
flutter analyze
```

### Step 2: Rename Your App

**Important**: You need to update the app name in multiple locations. Use AI agents or search/replace:

#### Files to Update:

1. **`pubspec.yaml`** (Line 1):
   ```yaml
   name: your_app_name  # Change from min_flutter_template
   description: "Your app description"
   ```

2. **`lib/main.dart`** (Import statement):
   ```dart
   import 'package:your_app_name/main.dart';  // Update import
   ```

3. **`test/widget_test.dart`** (Import):
   ```dart
   import 'package:your_app_name/main.dart';
   ```

4. **`android/app/build.gradle.kts`** (Lines 36-37, 50):
   ```kotlin
   namespace = "com.yourcompany.yourapp"
   applicationId = "com.yourcompany.yourapp"
   ```

5. **`android/app/src/main/AndroidManifest.xml`** (Line 2):
   ```xml
   android:label="Your App Name"
   ```

#### Using AI to Rename

Ask your AI agent:
```
Please rename this Flutter app from "min_flutter_template" to "my_awesome_app" 
and update the package name from "com.cmwen.min_flutter_template" to "com.mycompany.my_awesome_app". 
Update all necessary files including pubspec.yaml, build.gradle.kts, AndroidManifest.xml, 
and Dart imports.
```

### Step 3: Create App Icon

You have three options:

#### Option A: AI-Generated Icon (Recommended)

1. Use the provided prompt:
   ```
   @icon-generation.prompt.md
   
   Create an app launcher icon for [describe your app]. 
   Style: [flat/gradient/minimal], 
   Primary color: #[hex], 
   Symbol: [describe icon concept]
   ```

2. Save the generated 1024×1024 PNG to `assets/icon/app_icon.png`

#### Option B: Automated with flutter_launcher_icons

1. Add to `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.1
   
   flutter_launcher_icons:
     android: true
     image_path: "assets/icon/app_icon.png"
   ```

2. Run:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

#### Option C: Manual Icon Placement

Place your icons manually in these directories:
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png` (48, 72, 96, 144, 192 px)

See [icon-generation.prompt.md](.github/prompts/icon-generation.prompt.md) for detailed sizing requirements.

### Step 4: Customize App Theme

Edit `lib/main.dart`:

```dart
MaterialApp(
  title: 'Your App Name',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,  // Change to your brand color
    ),
    useMaterial3: true,
  ),
  home: const MyHomePage(title: 'Your App Home'),
)
```

### Step 5: Set Up GitHub Repository

1. **Create new repository** on GitHub

2. **Update remote**:
   ```bash
   git remote set-url origin https://github.com/yourusername/your-repo-name.git
   ```

3. **Configure signing** (choose one option):

   #### Option A: Auto-Generate (Recommended for Beginners)
   
   Just run the release workflow! It will automatically generate a keystore.
   After the first release:
   1. Download the `signing-credentials` artifact from the workflow run
   2. Run the persistence script:
      ```bash
      ./scripts/signing/persist-credentials.sh ./signing-credentials.json
      ```
   3. Delete the downloaded credentials file
   
   #### Option B: Generate Locally (Interactive)
   
   Use the provided script for a guided setup:
   ```bash
   ./scripts/signing/generate-keystore.sh
   ```
   This will create a keystore and optionally upload it to GitHub Secrets.
   
   #### Option C: Manual Setup (Advanced)
   
   Generate keystore manually:
   ```bash
   keytool -genkey -v -keystore release-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias release
   ```
   
   Add GitHub Secrets:
   - `ANDROID_KEYSTORE_BASE64`: `base64 -w 0 release-keystore.jks`
   - `ANDROID_KEYSTORE_PASSWORD`: Your keystore password
   - `ANDROID_KEY_ALIAS`: `release`
   - `ANDROID_KEY_PASSWORD`: Your key password

4. **Push to GitHub**:
   ```bash
   git add .
   git commit -m "Initial setup with custom app name"
   git push -u origin main
   ```

### Step 6: Test Your Setup

```bash
# Run on Android
flutter run -d android     # Android (connected device/emulator)

# Build release
flutter build apk --release

# Run tests
flutter test
flutter analyze
```

## 🤖 Using AI Agents for Development

This template includes custom GitHub Copilot agents to accelerate development:

### Available Agents

1. **@product-owner** - Define features and requirements
   ```
   @product-owner I need a login screen with email/password authentication
   ```

2. **@experience-designer** - Design user flows and interfaces
   ```
   @experience-designer Design a user flow for the login and registration process
   ```

3. **@architect** - Plan technical architecture
   ```
   @architect What's the best way to implement authentication with JWT tokens?
   ```

4. **@researcher** - Research dependencies and best practices
   ```
   @researcher Find the best Flutter packages for local storage and authentication
   ```

5. **@flutter-developer** - Implement features
   ```
   @flutter-developer Implement the login screen with form validation
   ```

6. **@doc-writer** - Create documentation
   ```
   @doc-writer Document the authentication flow and API endpoints
   ```

### Example Workflow

1. **Define requirements**:
   ```
   @product-owner I want to build a note-taking app with categories, 
   search, and local storage. Create user stories with acceptance criteria.
   ```

2. **Design UX**:
   ```
   @experience-designer Based on the product requirements, design the 
   information architecture and main user flows for the note-taking app.
   ```

3. **Research dependencies**:
   ```
   @researcher What are the best packages for local database, 
   state management, and markdown rendering in Flutter?
   ```

4. **Plan architecture**:
   ```
   @architect Design the app architecture including data models, 
   repositories, and state management for the note-taking app.
   ```

5. **Implement features**:
   ```
   @flutter-developer Implement the note list screen with 
   category filtering and search functionality.
   ```

6. **Document**:
   ```
   @doc-writer Create API documentation for the note repository 
   and usage examples.
   ```

## 📚 Key Documentation

After setup, familiarize yourself with:

- [BUILD_OPTIMIZATION.md](BUILD_OPTIMIZATION.md) - Build performance tips
- [AGENTS.md](AGENTS.md) - AI agent configuration details
- [AI_PROMPTING_GUIDE.md](AI_PROMPTING_GUIDE.md) - AI prompting best practices
- [TESTING.md](TESTING.md) - Testing guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contributing guidelines

## 🎯 Next Steps

Once setup is complete:

1. **Plan your features** with @product-owner
2. **Design your UI** with @experience-designer
3. **Set up state management** (Provider, Riverpod, Bloc)
4. **Implement your first feature** with @flutter-developer
5. **Write tests** for your features
6. **Deploy** your first release

## 🐛 Troubleshooting

### Build Issues

**Java version mismatch**:
```bash
# Check Java version
java -version

# Set JAVA_HOME (macOS/Linux)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

**Flutter not found**:
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**Gradle build fails**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Icon Issues

**Icons not updating**:
```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
```

### Import Errors After Renaming

```bash
# Regenerate code
flutter clean
flutter pub get
dart fix --apply
```

## 💡 Pro Tips

1. **Use VS Code snippets** - Type `stless` for StatelessWidget, `stful` for StatefulWidget
2. **Hot reload** - Press `r` in terminal or use VS Code's hot reload button
3. **Extract widgets** - Select code → Right-click → Refactor → Extract Widget
4. **Generate constructors** - Put cursor on class → Quick Fix → Generate constructor
5. **Use AI agents frequently** - They understand the project structure and best practices

## 🆘 Getting Help

- **Flutter Docs**: https://docs.flutter.dev
- **Pub.dev Packages**: https://pub.dev
- **Community**: https://flutter.dev/community
- **Stack Overflow**: Tag [flutter]

## ✅ Setup Complete!

Once you've completed all steps, you should have:
- ✅ App renamed with custom package name
- ✅ Custom app icon
- ✅ GitHub repository configured
- ✅ CI/CD workflows ready
- ✅ AI agents configured for development
- ✅ First build successful

**You're ready to build your app!** 🎉

Start with: `@product-owner What features should I implement first for [your app concept]?`
