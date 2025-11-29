# Minimal Android App Template

A production-ready Android Flutter template with **AI-powered development workflow**, optimized build system, and comprehensive documentation. Start building your Android app in minutes, not hours.

## ✨ What Makes This Template Special

- 🤖 **AI-First Development**: 6 custom GitHub Copilot agents (product owner, UX designer, architect, developer, researcher, doc writer)
- ⚡ **Optimized Build System**: Java 17, parallel builds, multi-level caching - builds 60% faster
- 🚀 **Production CI/CD**: GitHub Actions workflows with caching, testing, and signed releases
- 📱 **Android Focused**: Clean, minimal Android-only configuration
- 🎨 **Material Design 3**: Beautiful, accessible UI out of the box
- 📚 **Extensive Documentation**: Step-by-step guides for first-time users
- 🧪 **Testing Framework**: Unit, widget, and integration testing ready
- 🔧 **VS Code Optimized**: Agents configured with terminal, debugger, and VS Code API access

## 🚀 Quick Start (5 Minutes)

### Prerequisites

- ✅ Flutter SDK 3.10.1+
- ✅ Dart 3.10.1+
- ✅ Java 17+ (for Android)
- ✅ VS Code + GitHub Copilot (recommended)

Verify: `flutter doctor -v && java -version`

> 📖 **New to development?** See [PREREQUISITES.md](PREREQUISITES.md) for detailed installation instructions.

### Option 1: Automated Setup (Recommended)

```bash
# Clone this template
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name

# Run the quick start script
./scripts/setup/quick-start.sh
```

The script will guide you through naming your app and make all necessary changes automatically!

### Option 2: Manual Setup

```bash
# Clone this template
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name

# Get dependencies
flutter pub get

# Verify everything works
flutter test && flutter analyze
```

Then customize using AI:
```
@flutter-developer Please rename this app from "min_flutter_template" 
to "my_awesome_app" with package "com.mycompany.my_awesome_app"
```

### Option 3: GitHub Codespaces (No Installation!)

1. Click **"Use this template"** → **"Create a new repository"**
2. In your new repo, click **Code** → **Codespaces** → **"Create codespace on main"**
3. Everything is pre-configured - start coding immediately!

**See [GETTING_STARTED.md](GETTING_STARTED.md) for complete setup guide.**

### Generate App Icon

```
@icon-generation.prompt.md Create an app icon for my [describe app] 
with primary color #3B82F6 in minimal style
```

### Build and Run

```bash
flutter run -d android     # Android (connected device/emulator)
flutter build apk          # Release APK
```

**Full customization guide: [APP_CUSTOMIZATION.md](APP_CUSTOMIZATION.md)**

## 🤖 AI-Powered Development

### Meet Your AI Team

This template includes 6 specialized AI agents for VS Code:

| Agent | Purpose | Example Usage |
|-------|---------|---------------|
| **@product-owner** | Define features & requirements | `@product-owner Create user stories for a note-taking app` |
| **@experience-designer** | Design UX & user flows | `@experience-designer Design the login and onboarding flow` |
| **@architect** | Plan technical architecture | `@architect How should I structure authentication?` |
| **@researcher** | Find packages & best practices | `@researcher Best packages for local database in Flutter` |
| **@flutter-developer** | Implement features & fix bugs | `@flutter-developer Implement login screen with validation` |
| **@doc-writer** | Write documentation | `@doc-writer Document the authentication API` |

### Example Workflow

```bash
# 1. Define your app concept
@product-owner I want to build a recipe app with categories, 
search, and favorites. Create user stories and MVP scope.

# 2. Design the experience
@experience-designer Based on the requirements, design the 
information architecture and main user flows.

# 3. Research dependencies
@researcher What packages do I need for local storage, 
images, and JSON parsing?

# 4. Plan architecture
@architect Design the app architecture with Riverpod state management 
and repository pattern for recipes.

# 5. Implement features
@flutter-developer Implement the recipe list screen with 
category filtering and search.

# 6. Write documentation
@doc-writer Document the recipe repository API and usage examples.
```

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
├── lib/main.dart         # App entry point
├── test/                 # Tests
├── android/              # Android configuration
├── astro/                # GitHub Pages website
├── docs/                 # AI prompting guides
└── pubspec.yaml          # Dependencies
```

## 📚 Documentation

### Getting Started
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Complete setup guide for first-time users ⭐
- **[APP_CUSTOMIZATION.md](APP_CUSTOMIZATION.md)** - Comprehensive customization checklist & AI prompts ⭐
- **[PREREQUISITES.md](PREREQUISITES.md)** - Installation requirements for all platforms

### Development
- [AI_PROMPTING_GUIDE.md](AI_PROMPTING_GUIDE.md) - AI agent best practices
- [AGENTS.md](AGENTS.md) - AI agent configuration reference
- [BUILD_OPTIMIZATION.md](BUILD_OPTIMIZATION.md) - Build performance details
- [TESTING.md](TESTING.md) - Testing guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

### Help
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions

### Prompts
- `.github/prompts/icon-generation.prompt.md` - Icon generation guide

## 💡 Pro Tips

1. **Start with @product-owner** - Define clear requirements before coding
2. **Use @experience-designer** - Plan UX before implementing screens
3. **Let @researcher find packages** - Don't waste time searching pub.dev
4. **@flutter-developer has terminal access** - Can run tests, format, build
5. **Save documentation to docs/** - AI agents reference prior decisions
6. **Use pre-release workflow** - Test builds before production releases

## 🎓 Learning Path

### For Beginners
1. Read [GETTING_STARTED.md](GETTING_STARTED.md)
2. Follow the customization checklist
3. Ask `@flutter-developer` questions as you learn
4. Start with simple features

### For Intermediate Developers
1. Review [BUILD_OPTIMIZATION.md](BUILD_OPTIMIZATION.md) 
2. Set up CI/CD workflows
3. Use AI agents to accelerate development
4. Implement advanced features with @architect guidance

### For Teams
1. Review [AGENTS.md](AGENTS.md) for agent roles
2. Set up shared documentation in docs/
3. Use @product-owner for requirement alignment
4. Leverage @doc-writer for team documentation

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language](https://dart.dev/)
- [Flutter Packages](https://pub.dev/)

## License

MIT License - see [LICENSE](LICENSE)
