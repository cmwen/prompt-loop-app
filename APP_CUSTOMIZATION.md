# App Customization Guide

This guide provides a comprehensive checklist and AI prompts for customizing this Android Flutter template for your specific app.

## Complete Customization Checklist

### Phase 1: Identity and Branding

- [ ] **App Name**
  - [ ] `pubspec.yaml` - name field
  - [ ] `lib/main.dart` - MaterialApp title
  - [ ] `android/app/src/main/AndroidManifest.xml` - android:label

- [ ] **Package/Bundle Identifier**
  - [ ] `android/app/build.gradle.kts` - namespace and applicationId
   
- [ ] **Description**
  - [ ] `pubspec.yaml` - description field
  - [ ] `README.md` - project description

### Phase 2: Visual Identity

- [ ] **App Icon**
  - [ ] Create 1024x1024 master icon
  - [ ] Generate platform-specific icons
  - [ ] Android: `android/app/src/main/res/mipmap-*`

- [ ] **Color Theme**
  - [ ] `lib/main.dart` - MaterialApp theme
  - [ ] Primary color (seedColor)
  - [ ] Consider dark mode theme

- [ ] **Splash Screen** (Optional)
  - [ ] Use flutter_native_splash package
  - [ ] Configure in `pubspec.yaml`

### Phase 3: Configuration

- [ ] **Repository Setup**
  - [ ] GitHub repository URL
  - [ ] Update git remote
  - [ ] README.md - repository links

- [ ] **GitHub Secrets** (for CI/CD)
  - [ ] `ANDROID_KEYSTORE_BASE64`
  - [ ] `ANDROID_KEYSTORE_PASSWORD`
  - [ ] `ANDROID_KEY_ALIAS`
  - [ ] `ANDROID_KEY_PASSWORD`
  - [ ] `CODECOV_TOKEN` (optional)

- [ ] **Version Management**
  - [ ] `pubspec.yaml` - version: 1.0.0+1
  - [ ] Plan version numbering strategy

### Phase 4: Feature Planning

- [ ] **Define Core Features**
  - [ ] User stories with @product-owner
  - [ ] Feature prioritization
  - [ ] MVP scope

- [ ] **Design User Experience**
  - [ ] User flows with @experience-designer
  - [ ] Screen designs
  - [ ] Navigation structure

- [ ] **Technical Architecture**
  - [ ] Choose state management (Provider, Riverpod, Bloc, GetX)
  - [ ] Plan data persistence (shared_preferences, sqflite, hive, isar)
  - [ ] API integration architecture
  - [ ] Authentication strategy

## AI Prompts for Customization

### Step 1: Rename App

Ask your AI agent:
```
@flutter-developer Please rename this Flutter app:
- Current name: "min_flutter_template"
- New name: "my_awesome_app"
- Current package: "com.cmwen.min_flutter_template"
- New package: "com.mycompany.my_awesome_app"

Update all necessary files including:
- pubspec.yaml
- lib/main.dart (imports and title)
- test/widget_test.dart (imports)
- android/app/build.gradle.kts (namespace and applicationId)
- android/app/src/main/AndroidManifest.xml (label)

After updating, run flutter pub get and verify everything compiles.
```

### Step 2: Generate App Icon

```
@icon-generation.prompt.md

Create an app launcher icon for my [TYPE OF APP] app.

Requirements:
- App concept: [DESCRIBE YOUR APP]
- Style: [flat/gradient/minimal/modern]
- Primary color: #[HEX CODE]
- Secondary color: #[HEX CODE]
- Symbol/concept: [DESCRIBE ICON CONCEPT]
- Background: [transparent/solid color]

Please provide:
1. A 1024x1024 PNG master icon
2. Instructions for using flutter_launcher_icons package
3. Alt text for accessibility

Save the master icon to assets/icon/app_icon.png and help me set up 
flutter_launcher_icons in pubspec.yaml.
```

### Step 3: Customize Theme

```
@flutter-developer Please customize the app theme in lib/main.dart:

Brand colors:
- Primary: #[HEX] ([COLOR NAME])
- Secondary: #[HEX] ([COLOR NAME])
- Background: #[HEX]
- Surface: #[HEX]
- Error: #[HEX]

Requirements:
- Use Material Design 3
- Support dark mode
- Ensure WCAG AA contrast ratios
- Use ColorScheme.fromSeed for consistency
```

### Step 4: Define Product Requirements

```
@product-owner I want to build a [TYPE OF APP] with the following capabilities:

Core features:
1. [FEATURE 1]
2. [FEATURE 2]
3. [FEATURE 3]

Target users:
- [USER PERSONA 1]
- [USER PERSONA 2]

Please create:
1. Detailed user stories with acceptance criteria
2. Feature prioritization (MVP vs future)
3. Non-functional requirements
4. Success metrics and KPIs

Save requirements to docs/REQUIREMENTS.md
```

### Step 5: Design User Experience

```
@experience-designer Based on the product requirements in docs/REQUIREMENTS.md, 
please design:

1. Information architecture (screen hierarchy)
2. Navigation structure (tab bar, drawer, or stack-based)
3. User flows for key features
4. Wireframes for main screens
5. Accessibility considerations

Constraints:
- Platform: Android
- Target devices: Mobile phones and tablets
- Material Design 3 components

Save design to docs/UX_DESIGN.md
```

### Step 6: Research Dependencies

```
@researcher I need to find the best Flutter packages for:

1. State Management - [brief description of needs]
2. Local Database - [data structure and requirements]
3. HTTP Client - [API integration needs]

For each category, please:
- Recommend top 3 packages with pros/cons
- Check latest version and maintenance status
- Verify compatibility with Flutter 3.10+
- Consider package size and performance
- Check license compatibility

Save findings to docs/DEPENDENCIES_RESEARCH.md
```

### Step 7: Plan Architecture

```
@architect Based on the requirements and dependencies research, please design:

Project structure:
- Folder organization (screens, widgets, models, services, providers)
- State management pattern
- Data layer architecture
- API integration approach
- Navigation structure

Provide:
1. Directory structure with purpose of each folder
2. Data flow diagram
3. Key architectural patterns to follow
4. Code organization guidelines

Save to docs/ARCHITECTURE.md
```

### Step 8: Implement First Feature

```
@flutter-developer Implement [FEATURE NAME] feature:

Requirements:
- [REQUIREMENT 1]
- [REQUIREMENT 2]
- [REQUIREMENT 3]

Technical approach:
- Follow architecture in docs/ARCHITECTURE.md
- Create necessary models in lib/models/
- Implement UI in lib/screens/[feature_name]/
- Use widgets from lib/widgets/ for reusable components
- Implement business logic in lib/services/
- Add state management with [chosen solution]

After implementation:
1. Write unit tests for business logic
2. Write widget tests for UI components
3. Run flutter analyze
4. Run flutter test
5. Document any public APIs
6. Code formatting is handled automatically by CI
```

### Step 9: Create Release Build

```
@flutter-developer Please help me create the first release build:

1. Verify all customizations are complete
2. Update version in pubspec.yaml to 1.0.0+1
3. Build release artifacts:
   - Android: APK and AAB
4. Test release build on device
5. Create git tag v1.0.0
6. Push tag to trigger release workflow

Provide step-by-step commands.
```

## Verification Checklist

After customization, verify:

### Build Verification
```bash
# Clean start
flutter clean
flutter pub get

# Check for issues
flutter analyze

# Run tests
flutter test

# Build Android
flutter build apk --release
```

### Visual Verification
- [ ] App icon shows correctly
- [ ] App name displays correctly everywhere
- [ ] Theme colors match brand
- [ ] Splash screen works (if implemented)
- [ ] Dark mode works correctly (if implemented)

### Functional Verification
- [ ] App launches without errors
- [ ] Navigation works correctly
- [ ] Core features work as expected
- [ ] No placeholder content from template
- [ ] All imports reference correct package name

### Documentation Verification
- [ ] README.md updated with app-specific info
- [ ] docs/ folder contains requirements, architecture, design docs
- [ ] GitHub repository configured
- [ ] CI/CD workflows tested

## Recommended Dependencies

### Essential Packages
```yaml
dependencies:
  # State Management
  provider: ^6.1.1              # Simple, official
  # OR riverpod: ^2.4.9         # More powerful
  # OR flutter_bloc: ^8.1.3     # BLoC pattern
  
  # HTTP Client
  dio: ^5.4.0                   # Feature-rich HTTP client
  
  # Local Storage
  shared_preferences: ^2.2.2    # Simple key-value
  # OR hive: ^2.2.3             # Fast NoSQL
  # OR isar: ^3.1.0             # Advanced database
  
  # Navigation
  go_router: ^13.0.0            # Declarative routing
  
  # JSON Serialization
  json_annotation: ^4.8.1
  
  # Forms and Validation
  flutter_form_builder: ^9.1.1
  
  # UI Components
  flutter_svg: ^2.0.9           # SVG support
  cached_network_image: ^3.3.0  # Image caching
  
  # Utilities
  intl: ^0.19.0                 # Internationalization
  url_launcher: ^6.2.2          # Open URLs
  
dev_dependencies:
  # Code Generation
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  
  # Icons
  flutter_launcher_icons: ^0.13.1
  
  # Testing
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

## Learning Resources

- **Flutter Documentation**: https://docs.flutter.dev
- **Dart Language**: https://dart.dev
- **Material Design 3**: https://m3.material.io
- **Flutter Packages**: https://pub.dev
- **Flutter Community**: https://flutter.dev/community

## Best Practices

1. **Keep it simple** - Start with MVP features
2. **Test early** - Write tests as you implement features
3. **Use AI agents** - Let them handle boilerplate and research
4. **Document decisions** - Save to docs/ folder for future reference
5. **Follow conventions** - Use Flutter/Dart style guides
6. **Version control** - Commit frequently with clear messages
7. **Build often** - Test on real devices regularly
8. **Accessibility first** - Design for all users from the start

## Ready to Build!

Once you have completed these customizations, you will have:
- Fully branded app with custom name and icon
- Clear product requirements and user stories
- Designed user experience and flows
- Well-planned architecture
- Configured CI/CD pipeline
- Ready-to-use development environment

**Start building your features with the AI agents!**
