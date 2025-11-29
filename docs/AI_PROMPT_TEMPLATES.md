# 📝 AI Prompt Templates Library

> **Ready-to-use prompt templates for common Android development tasks. Copy, customize, and use!**

## 📚 How to Use This Library

1. **Find your task** in the table of contents
2. **Copy the template** that matches your need
3. **Customize** the bracketed `[placeholders]` with your specific information
4. **Paste** into your AI assistant (ChatGPT, Claude, GitHub Copilot, etc.)
5. **Iterate** based on the response

---

## 📑 Table of Contents

### Getting Started
- [Understanding the Template](#understanding-the-template)
- [First Time Setup](#first-time-setup)
- [Customizing Basic Elements](#customizing-basic-elements)

### UI Development
- [Creating a New Screen](#creating-a-new-screen)
- [Building Custom Layouts](#building-custom-layouts)
- [Adding Navigation](#adding-navigation)
- [Implementing Lists (RecyclerView)](#implementing-lists-recyclerview)
- [Creating Custom Views](#creating-custom-views)

### Data Management
- [Setting Up Room Database](#setting-up-room-database)
- [Implementing Repository Pattern](#implementing-repository-pattern)
- [Working with SharedPreferences](#working-with-sharedpreferences)
- [API Integration with Retrofit](#api-integration-with-retrofit)

### Features
- [Adding Camera Functionality](#adding-camera-functionality)
- [Implementing Notifications](#implementing-notifications)
- [Background Tasks with WorkManager](#background-tasks-with-workmanager)
- [Location Services](#location-services)

### Architecture
- [Setting Up MVVM](#setting-up-mvvm)
- [Dependency Injection with Hilt](#dependency-injection-with-hilt)
- [Navigation Component](#navigation-component)

### Testing
- [Writing Unit Tests](#writing-unit-tests)
- [Writing UI Tests](#writing-ui-tests)
- [Testing ViewModels](#testing-viewmodels)

### Debugging & Optimization
- [Debugging Errors](#debugging-errors)
- [Performance Optimization](#performance-optimization)
- [Fixing Memory Leaks](#fixing-memory-leaks)

---

## Getting Started

### Understanding the Template

```
I just cloned the min-android-app-template. I'm [beginner/intermediate/experienced] 
with [brief background].

Please explain:
1. The project structure and key directories
2. What each main file does (MainActivity, build.gradle.kts, etc.)
3. How the build system works
4. Where I should start making changes
5. Best practices for keeping the template organized

Make explanations [simple/technical] based on my level.
```

### First Time Setup

```
I want to set up the min-android-app-template for my new app called "[App Name]".

Changes needed:
- App name: "[Your App Name]"
- Package name: "com.[company].[appname]"
- Minimum SDK: [current is 24, change if needed]
- Primary color: [color name or hex]
- App icon: [describe or say "keep default for now"]

Please provide:
1. Step-by-step instructions for each change
2. Which files to modify
3. Exact code changes
4. How to verify the changes work

Additional context: [Any specific requirements]
```

### Customizing Basic Elements

```
I want to customize the main screen of my app.

Current state: Default "Hello World" template

Desired changes:
- [Change 1: e.g., "Add a title at the top saying 'Welcome'"]
- [Change 2: e.g., "Add a button in the center"]
- [Change 3: e.g., "Change background color to light blue"]

Please provide:
1. XML layout code for activity_main.xml
2. Any necessary Kotlin code changes
3. Explanation of each change
4. How to preview the changes

My experience level: [beginner/intermediate/experienced]
```

---

## UI Development

### Creating a New Screen

```
I need to add a new screen to my app.

Screen purpose: [What this screen does]

Screen should contain:
- [UI element 1: e.g., "Title text"]
- [UI element 2: e.g., "Form with 3 input fields"]
- [UI element 3: e.g., "Submit button"]

Navigation:
- How to reach this screen: [e.g., "Button click from main screen"]
- What happens after: [e.g., "Return to main screen with data"]

Using: min-android-app-template

Please provide:
1. New Activity/Fragment file structure
2. Layout XML code
3. Activity/Fragment Kotlin code
4. How to set up navigation
5. How to pass data to/from this screen

My level: [beginner/intermediate/experienced]
```

### Building Custom Layouts

```
I need to create a layout for [describe screen purpose].

Layout requirements:
- [Requirement 1: e.g., "Header at top, fixed height"]
- [Requirement 2: e.g., "Scrollable content in middle"]
- [Requirement 3: e.g., "Button fixed at bottom"]

Visual style:
- Material Design: [Yes/No]
- Responsive: [Phone only / Tablet support too]
- Orientation: [Portrait only / Both orientations]

Please provide:
1. Complete XML layout
2. Explanation of layout structure
3. Constraint or other layout manager recommendations
4. How to make it responsive
5. Best practices for this layout type

Reference image/sketch: [Describe or say "I'll describe verbally"]
Description: [Detailed visual description]
```

### Adding Navigation

```
I need to implement navigation in my app.

App structure:
- Screens: [List all screens: e.g., "Home, Profile, Settings, Details"]
- Navigation type: [Bottom nav / Drawer / Tab / Simple back-forward]

Navigation flow:
[Describe how users move between screens]

Requirements:
- Back stack behavior: [How back button should work]
- Data passing: [What data needs to pass between screens]
- Deep linking: [Yes/No, if yes describe]

Using: min-android-app-template

Please provide:
1. Recommended navigation approach
2. Setup and configuration
3. Implementation for each screen
4. Data passing mechanism
5. Back stack management

My experience: [Your level]
```

### Implementing Lists (RecyclerView)

```
I need to display a list of [items].

Data structure:
Item contains:
- [Field 1: e.g., "title (String)"]
- [Field 2: e.g., "date (Date)"]
- [Field 3: e.g., "status (enum)"]

List requirements:
- Layout: [Linear/Grid/Staggered]
- Interactions: [Click/Long click/Swipe actions]
- Empty state: [What to show when no items]
- Loading state: [Show while loading]

Item appearance:
[Describe how each list item should look]

Please provide:
1. Data class definition
2. RecyclerView adapter implementation
3. ViewHolder implementation
4. Layout XML for list item
5. Integration with Activity/Fragment
6. Click handling
7. Best practices for list performance

Using: min-android-app-template with ViewBinding
```

### Creating Custom Views

```
I need to create a custom view: [name/description]

View purpose: [What it does]

Visual behavior:
- Appearance: [Describe how it looks]
- Interactive elements: [What users can interact with]
- Animations: [Any animations needed]
- States: [Different visual states: normal, pressed, disabled, etc.]

Technical requirements:
- Extends: [View/ViewGroup/specific view]
- Custom attributes: [List attributes users can set in XML]
- Performance: [Any specific concerns]

Please provide:
1. Complete custom view implementation
2. attrs.xml for custom attributes
3. Usage example in layout XML
4. Usage example in code
5. Performance considerations
6. Accessibility implementation

Using: min-android-app-template, SDK 24+

### Icons & Assets

```
I need icons and launcher assets for my app. Use the project's icon guidelines and provide:
1. Vector-first SVG for UI icons sized at 24x24 (viewBox 0 0 24 24) and Android VectorDrawable XML
2. Adaptive launcher icon foreground SVG (transparent) and suggested background color with multiple PNG exports for mipmap densities
3. File paths and recommended filenames (drawable/vector or mipmap/*) and one-line alt text for accessibility

Please follow the `icon-generation.prompt.md` custom prompt in `.github/prompts/` for constraints and examples.
```
```

---

## Data Management

### Setting Up Room Database

```
I need to set up a Room database for my app.

Entities needed:
[Entity 1]:
- [field name]: [type] [annotations: e.g., primary key]
- [field name]: [type]

[Entity 2]:
- [field name]: [type]
- [field name]: [type]

Relationships:
[Describe any relationships between entities]

Queries needed:
- [Query 1: e.g., "Get all items sorted by date"]
- [Query 2: e.g., "Get item by ID"]
- [Query 3: e.g., "Delete items older than X"]

Using: min-android-app-template

Please provide:
1. Room dependency setup (if not already in template)
2. Entity class definitions
3. DAO interfaces with queries
4. Database class
5. Repository pattern implementation
6. How to access from ViewModel
7. Migration strategy for future changes

My experience with databases: [Your level]
```

### Implementing Repository Pattern

```
I need to implement a repository for [data type].

Data sources:
- Local: [Room/SharedPreferences/File]
- Remote: [REST API/GraphQL/Firebase]

Requirements:
- Offline-first: [Yes/No]
- Caching strategy: [Describe]
- Error handling: [Requirements]
- Loading states: [How to expose]

Use cases:
- [Use case 1: e.g., "Fetch all items"]
- [Use case 2: e.g., "Save new item"]
- [Use case 3: e.g., "Sync with server"]

Please provide:
1. Repository interface
2. Repository implementation
3. Data source interfaces/implementations
4. Error handling with sealed Result class
5. How to use from ViewModel with Flow
6. Testing strategy

Architecture: MVVM with min-android-app-template
```

### Working with SharedPreferences

```
I need to store simple key-value data using SharedPreferences.

Data to store:
- [Key 1]: [Type] - [Purpose]
- [Key 2]: [Type] - [Purpose]
- [Key 3]: [Type] - [Purpose]

Requirements:
- Type-safe access
- Default values: [Specify for each]
- Observe changes: [Yes/No]
- Encryption needed: [Yes/No]

Please provide:
1. Preferences wrapper class (or recommend DataStore)
2. Type-safe key definitions
3. Read/write methods
4. How to inject with Hilt (if applicable)
5. How to observe changes
6. Migration from SharedPreferences to DataStore (if recommended)

Using: min-android-app-template
```

### API Integration with Retrofit

```
I need to integrate with a REST API.

API details:
- Base URL: [URL or say "private"]
- Authentication: [None/API key/OAuth/JWT]
- Endpoints needed:
  - [Endpoint 1]: [Method] [Path] - [Purpose]
  - [Endpoint 2]: [Method] [Path] - [Purpose]

Request/Response models:
[Describe or paste JSON examples]

Requirements:
- Error handling
- Timeout configuration
- Logging for debugging
- Offline support: [Yes/No]

Please provide:
1. Retrofit dependency setup
2. API interface definition
3. Request/Response data classes
4. Retrofit instance configuration
5. Error handling approach
6. Repository integration
7. Testing strategy

Using: min-android-app-template
```

---

## Features

### Adding Camera Functionality

```
I need to add camera functionality to my app.

Use case: [What users do with camera]

Requirements:
- Capture: [Photo/Video/Both]
- Source: [Camera only/Gallery option too]
- Processing: [Any processing needed: resize, filter, etc.]
- Storage: [Where to save]
- Permissions: [Handle runtime permissions]

Please provide:
1. Necessary permissions in manifest
2. Runtime permission handling code
3. Camera intent implementation
4. Image/video processing code
5. Saving and retrieving media
6. Best practices for camera on Android

Target: min-android-app-template, SDK 24+
```

### Implementing Notifications

```
I need to implement notifications for [purpose].

Notification types:
- [Type 1]: [When triggered] - [Content]
- [Type 2]: [When triggered] - [Content]

Requirements:
- Channels: [Organize by channels]
- Actions: [Notification actions: e.g., reply, dismiss]
- Style: [Text/Big text/Image/Custom]
- Priority: [High/Medium/Low]
- Launch behavior: [What happens on tap]

Please provide:
1. Notification channel setup
2. Creating and displaying notifications
3. Notification action handling
4. Scheduled notifications (if needed)
5. Permission handling (Android 13+)
6. Best practices for notifications

Using: min-android-app-template
```

### Background Tasks with WorkManager

```
I need to run background tasks for [purpose].

Tasks:
- [Task 1]: [Description] - Frequency: [one-time/periodic]
- [Task 2]: [Description] - Frequency: [one-time/periodic]

Constraints:
- Network: [Required/Not required]
- Battery: [Not charging/Charging/Any]
- Storage: [Requirements]
- Device state: [Idle/Any]

Requirements:
- Handle failures and retries
- Report progress: [Yes/No]
- Task chaining: [Yes/No]

Please provide:
1. WorkManager dependency setup
2. Worker implementations
3. Work request configuration
4. Enqueueing work
5. Monitoring work status
6. Testing workers

Using: min-android-app-template
```

### Location Services

```
I need to access device location for [purpose].

Requirements:
- Accuracy: [High/Medium/Low]
- Frequency: [One-time/Continuous/Periodic]
- Background updates: [Yes/No]
- Geofencing: [Yes/No]

Usage:
[Describe what you do with location data]

Please provide:
1. Permissions setup (manifest + runtime)
2. Location client setup
3. Requesting location updates
4. Handling location data
5. Battery optimization considerations
6. Best practices for location in Android

Using: min-android-app-template, SDK 24+
```

---

## Architecture

### Setting Up MVVM

```
I want to implement MVVM architecture in my app.

Current state: [Basic template/Existing code to refactor]

Features to implement with MVVM:
- [Feature 1]
- [Feature 2]

Data sources:
- [Room database/API/Both]

Please provide:
1. Project structure for MVVM
2. ViewModel implementation example
3. Repository implementation
4. LiveData/Flow usage in ViewModel
5. Activity/Fragment observing ViewModel
6. Dependency injection approach
7. Testing strategy for each layer

Using: min-android-app-template with [Kotlin/Java]
My experience: [Your level with architecture patterns]
```

### Dependency Injection with Hilt

```
I want to set up Hilt for dependency injection.

Current dependencies to inject:
- [Dependency 1: e.g., "Repository"]
- [Dependency 2: e.g., "Retrofit instance"]
- [Dependency 3: e.g., "Database"]

Scope requirements:
[Describe which components need which scope]

Please provide:
1. Hilt setup in build.gradle.kts
2. Application class with Hilt
3. Module definitions for dependencies
4. How to inject into ViewModel
5. How to inject into Activity/Fragment
6. Testing with Hilt

Using: min-android-app-template
My DI experience: [Your level]
```

### Navigation Component

```
I want to implement Jetpack Navigation Component.

App navigation structure:
- [Screen 1] -> [Screen 2] -> [Screen 3]
- [Bottom nav / Drawer / Tabs] with [List screens]

Navigation requirements:
- Pass arguments: [What data between screens]
- Deep links: [Required URLs]
- Animations: [Transition animations]

Please provide:
1. Navigation component setup
2. Navigation graph XML
3. NavHost setup in Activity
4. Navigation actions in code
5. Passing arguments safely
6. Deep link handling
7. Integration with BottomNavigationView (if applicable)

Using: min-android-app-template
```

---

## Testing

### Writing Unit Tests

```
I need to write unit tests for this class:

[Paste class code or describe]

Test requirements:
- Test framework: [JUnit 4/JUnit 5]
- Mocking: [MockK/Mockito]
- Coverage goal: [percentage]

Scenarios to test:
- [Scenario 1]
- [Scenario 2]
- Edge cases: [List edge cases]

Please provide:
1. Complete test class
2. Test fixtures/setup
3. Individual test cases
4. Mock setup for dependencies
5. Assertions and verification
6. How to run tests

Using: min-android-app-template
```

### Writing UI Tests

```
I need to write UI tests for [screen/feature].

Test scenarios:
- [Scenario 1: e.g., "User enters text and clicks submit"]
- [Scenario 2: e.g., "Validation error is shown"]
- [Scenario 3: e.g., "Navigation to next screen"]

Using: [Espresso/Compose Testing]

Requirements:
- Page Object pattern: [Yes/No]
- Test data setup: [How to set up test data]
- Async handling: [API calls/animations to wait for]

Please provide:
1. Test class structure
2. Page Object implementations (if applicable)
3. Individual test cases
4. Idling resource setup (if needed)
5. How to run on emulator/device

Using: min-android-app-template
```

### Testing ViewModels

```
I need to write tests for this ViewModel:

[Paste ViewModel code or describe]

Dependencies:
- [Repository/Use cases that ViewModel uses]

Test scenarios:
- [Scenario 1]
- [Scenario 2]
- Error cases: [List error scenarios]

Please provide:
1. ViewModel test class
2. Test rule setup for coroutines
3. Mock repository setup
4. Tests for each function
5. Testing LiveData/StateFlow
6. Error case handling tests

Using: min-android-app-template with Kotlin coroutines
```

---

## Debugging & Optimization

### Debugging Errors

```
I'm getting an error and need help debugging.

Error message:
[Paste complete error message/stack trace]

Context:
- What I was trying to do: [Your action]
- When it occurs: [Consistently/Sometimes/First time]
- What I recently changed: [Recent code changes]

Relevant code:
[Paste the code around the error line]

Environment:
- Android version: [version]
- Device: [Emulator/Physical device]
- App version: [your version]

Please help:
1. Identify the root cause
2. Explain why this error occurred
3. Provide a fix
4. Suggest how to prevent similar errors
5. Recommend debugging approach

Using: min-android-app-template
```

### Performance Optimization

```
My app has performance issues.

Issue: [Specific performance problem: slow, laggy, freezes, etc.]

Occurs: [When/where in the app]

Profiling data (if available):
[Paste relevant metrics]

Current implementation:
[Describe or paste relevant code]

Requirements:
- Target performance: [Specific goal]
- Cannot change: [Constraints]

Please provide:
1. Analysis of likely bottlenecks
2. Profiling strategy
3. Optimization recommendations
4. Refactored code
5. Measurement approach to verify improvement

Using: min-android-app-template, SDK 24+
```

### Fixing Memory Leaks

```
I suspect a memory leak in my app.

Symptoms:
- [Symptom 1: e.g., "Memory grows over time"]
- [Symptom 2: e.g., "OutOfMemory crashes"]

Suspected component:
[Which Activity/Fragment/feature]

LeakCanary trace (if available):
[Paste leak trace]

Relevant code:
[Paste suspected code]

Please help:
1. Analyze the leak
2. Identify the cause
3. Provide fix
4. Explain prevention strategies
5. Recommend verification approach

Using: min-android-app-template
```

---

## General Purpose Templates

### Feature Implementation

```
I want to implement [feature name] in my Android app.

Feature description:
[Detailed description of what the feature does]

User interaction:
[How users interact with this feature]

Technical requirements:
- [Requirement 1]
- [Requirement 2]

Constraints:
- SDK: 24+
- Must work offline: [Yes/No]
- Performance requirements: [Any specific needs]

Please provide:
1. Recommended approach
2. Architecture/design
3. Step-by-step implementation
4. Best practices
5. Testing strategy

Using: min-android-app-template
My level: [beginner/intermediate/experienced]
```

### Code Review Request

```
Please review this code for:
- [Focus area 1: e.g., "Performance"]
- [Focus area 2: e.g., "Security"]
- [Focus area 3: e.g., "Best practices"]

Code:
[Paste your code]

Context:
[What this code does]

Specific concerns:
[Any specific areas you're unsure about]

Please provide:
1. Issues found with severity
2. Specific suggestions for improvement
3. Best practices recommendations
4. Refactored code (if needed)

Target: Android SDK 24+, Kotlin
```

### Learning Request

```
I want to learn about [Android concept/pattern/API].

My background: [Your experience]
My goal: [What you want to achieve]

Please explain:
1. What it is and when to use it
2. How it works (internals if relevant)
3. Simple example
4. Complex example
5. Best practices
6. Common mistakes to avoid

Teaching style: [Simple/Technical/With analogies]
Code examples: [Yes, with detailed comments]

Context: Using min-android-app-template
```

---

## 💡 Tips for Using Templates

### 1. Be Specific
Replace ALL bracketed placeholders with your actual information. The more specific, the better the AI response.

### 2. Include Context
Always mention:
- Your experience level
- What you're working with (min-android-app-template)
- Any constraints (SDK version, existing code, etc.)

### 3. Ask for Explanations
Add "Please explain..." to any template to get learning along with code.

### 4. Request Examples
Add "Show me a complete example..." for more comprehensive responses.

### 5. Iterate
If the first response isn't quite right, refine your prompt:
- "That's close, but can you also add [X]?"
- "Make it simpler for a beginner"
- "Show me a more advanced version"

### 6. Combine Templates
Mix and match parts from different templates for complex scenarios.

---

## 🎯 Quick Start Combos

### Complete Beginner Starting Out
1. [Understanding the Template](#understanding-the-template)
2. [First Time Setup](#first-time-setup)
3. [Customizing Basic Elements](#customizing-basic-elements)
4. [Creating a New Screen](#creating-a-new-screen)

### Building a Data-Driven App
1. [Setting Up Room Database](#setting-up-room-database)
2. [Implementing Repository Pattern](#implementing-repository-pattern)
3. [Setting Up MVVM](#setting-up-mvvm)
4. [Implementing Lists](#implementing-lists-recyclerview)

### Integrating with Backend
1. [API Integration with Retrofit](#api-integration-with-retrofit)
2. [Implementing Repository Pattern](#implementing-repository-pattern)
3. [Background Tasks with WorkManager](#background-tasks-with-workmanager)
4. [Writing Unit Tests](#writing-unit-tests)

---

## 📚 Additional Resources

- **[Main AI Prompting Guide](../AI_PROMPTING_GUIDE.md)** - Comprehensive guide
- **[Beginner's Guide](./AI_BEGINNER_GUIDE.md)** - For complete beginners
- **[Intermediate Guide](./AI_INTERMEDIATE_GUIDE.md)** - For developers new to Android
- **[Advanced Guide](./AI_ADVANCED_GUIDE.md)** - For experienced Android developers

---

## 🤝 Contributing Templates

Found a prompt that works great? Consider contributing it back!

Share prompts that are:
- ✅ Reusable across different projects
- ✅ Well-structured and clear
- ✅ Tested and effective
- ✅ Properly documented

---

**Happy prompting! 🚀** Copy a template, customize it, and start building!
