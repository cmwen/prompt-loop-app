# Prompt Loop

AI-powered skill development through deliberate practice loops. Build expertise faster with intelligent feedback and structured learning paths.

## ✨ Features

- 🤖 **AI-Powered Practice**: Intelligent feedback loops for skill development
- 🎯 **Deliberate Practice**: Structured exercises designed for rapid improvement
- 📈 **Progress Tracking**: Monitor your growth across multiple skill domains
- 🔄 **Adaptive Learning**: Personalized practice sessions based on your performance
- 🎨 **Material Design 3**: Beautiful, accessible UI
- 📱 **Android Focused**: Optimized for mobile learning
- ⚡ **Optimized Build System**: Java 17, parallel builds, multi-level caching
- 🚀 **Production CI/CD**: GitHub Actions workflows with testing and signed releases

## 🚀 Quick Start

### Prerequisites

- ✅ Flutter SDK 3.10.1+
- ✅ Dart 3.10.1+
- ✅ Java 17+ (for Android)
- ✅ VS Code + GitHub Copilot (recommended)

Verify: `flutter doctor -v && java -version`

> 📖 **New to development?** See [PREREQUISITES.md](PREREQUISITES.md) for detailed installation instructions.

### Clone and Run

```bash
# Clone the repository
git clone https://github.com/cmwen/prompt-loop-app.git
cd prompt-loop-app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### GitHub Codespaces (No Installation!)

1. Click **Code** → **Codespaces** → **"Create codespace on main"**
2. Everything is pre-configured - start coding immediately!

**See [GETTING_STARTED.md](GETTING_STARTED.md) for complete setup guide.**

### Build for Release

```bash
flutter build apk          # Release APK
flutter build appbundle    # Android App Bundle
```

## 🤖 AI-Powered Development

Prompt Loop uses 6 specialized AI agents for development:

| Agent | Purpose | Example Usage |
|-------|---------|---------------|
| **@product-owner** | Define features & requirements | `@product-owner Create user stories for a new practice mode` |
| **@experience-designer** | Design UX & user flows | `@experience-designer Design the practice session flow` |
| **@architect** | Plan technical architecture | `@architect How should I structure the feedback system?` |
| **@researcher** | Find packages & best practices | `@researcher Best packages for spaced repetition in Flutter` |
| **@flutter-developer** | Implement features & fix bugs | `@flutter-developer Implement the progress tracking screen` |
| **@doc-writer** | Write documentation | `@doc-writer Document the practice loop API` |

**All agents have access to VS Code terminal, debugger, and test runner!**

## ⚡ Build Performance

This template includes **comprehensive build optimizations**:

- **Java 17 baseline** for modern Android development
- **Parallel builds** with 4 workers (local) / 2 workers (CI)
- **Multi-level caching**: Gradle, Flutter SDK, pub packages
- **R8 code shrinking**: 40-60% smaller release APKs
- **Concurrency control**: Cancels duplicate CI runs
- **CI-optimized Gradle properties**: Separate config for CI vs local

### Expected Build Times

| Environment | Build Type | Time |
|------------|-----------|------|
| Local (cached) | Debug APK | 30-60s |
| Local | Release APK | 1-2 min |
| CI (cached) | Full workflow | 3-5 min |

**See [BUILD_OPTIMIZATION.md](BUILD_OPTIMIZATION.md) for details.**

## 🔄 CI/CD Workflows

### Automated Workflows

- **build.yml**: Auto-formats code, runs tests, lints, and builds on every push (30min timeout)
- **release.yml**: Signed releases on version tags (45min timeout)
- **pre-release.yml**: Manual beta/alpha releases (workflow_dispatch)
- **deploy-website.yml**: Deploys GitHub Pages website

> **Note**: The build workflow automatically formats code using `dart format` and applies lint fixes with `dart fix --apply`. Any formatting changes are committed automatically, so you don't need to worry about code style.

### Setup Signed Releases

```bash
# 1. Generate keystore
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release

# 2. Add GitHub Secrets
- ANDROID_KEYSTORE_BASE64: `base64 -i release.jks | pbcopy`
- ANDROID_KEYSTORE_PASSWORD
- ANDROID_KEY_ALIAS: release
- ANDROID_KEY_PASSWORD

# 3. Tag and push
git tag v1.0.0 && git push --tags
```

## Project Structure

```
├── lib/                  # Dart source code
│   ├── main.dart         # App entry point
│   ├── models/           # Data models
│   ├── screens/          # UI screens
│   └── services/         # Business logic
├── test/                 # Tests
├── android/              # Android configuration
├── astro/                # GitHub Pages website
├── docs/                 # Documentation
└── pubspec.yaml          # Dependencies
```

## 📚 Documentation

### Getting Started
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Complete setup guide ⭐
- **[PREREQUISITES.md](PREREQUISITES.md)** - Installation requirements

### Development
- [AI_PROMPTING_GUIDE.md](AI_PROMPTING_GUIDE.md) - AI agent best practices
- [AGENTS.md](AGENTS.md) - AI agent configuration reference
- [BUILD_OPTIMIZATION.md](BUILD_OPTIMIZATION.md) - Build performance details
- [TESTING.md](TESTING.md) - Testing guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

### Help
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions

## 🔗 Links

- **Repository**: [github.com/cmwen/prompt-loop-app](https://github.com/cmwen/prompt-loop-app)
- **Releases**: [Latest Release](https://github.com/cmwen/prompt-loop-app/releases/latest)
- **Issues**: [Report a Bug](https://github.com/cmwen/prompt-loop-app/issues)

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language](https://dart.dev/)
- [Flutter Packages](https://pub.dev/)

## License

MIT License - see [LICENSE](LICENSE)
