# Opinionated Defaults

This template includes sensible defaults for common Android app requirements. This document explains what's included and how to customize it for your needs.

## Table of Contents

- [Permissions](#permissions)
- [Network Security Configuration](#network-security-configuration)
- [Storage](#storage)
- [Customization Guide](#customization-guide)

---

## Permissions

**File location:** `android/app/src/main/AndroidManifest.xml`

### Included Permissions

#### Required (Enabled by Default)

| Permission | Purpose |
|------------|---------|
| `INTERNET` | Make network requests (API calls, fetch web content) |
| `ACCESS_NETWORK_STATE` | Check if device has network connectivity |

#### Optional (Commented Out)

These permissions are included but commented out. Uncomment them as needed:

| Permission | Purpose | Notes |
|------------|---------|-------|
| `CAMERA` | Photo/video capture | Requires runtime permission |
| `ACCESS_FINE_LOCATION` | GPS-level location | Requires runtime permission |
| `ACCESS_COARSE_LOCATION` | Approximate location | Requires runtime permission |
| `READ_EXTERNAL_STORAGE` | Read files from storage | Limited to API 32 (Android 12L) |
| `WRITE_EXTERNAL_STORAGE` | Write files to storage | Limited to API 29 (Android 10) |
| `RECORD_AUDIO` | Microphone access | Requires runtime permission |

### How to Enable Optional Permissions

1. Open `android/app/src/main/AndroidManifest.xml`
2. Find the commented permission you need
3. Remove the `<!-- -->` comment markers

Example - enabling camera:

```xml
<!-- Before -->
<!-- <uses-permission android:name="android.permission.CAMERA"/> -->

<!-- After -->
<uses-permission android:name="android.permission.CAMERA"/>
```

### How to Remove Unused Permissions

If you don't need network access, you can remove or comment out the INTERNET permission:

```xml
<!-- <uses-permission android:name="android.permission.INTERNET"/> -->
```

### Runtime Permissions

Android 6.0+ requires runtime permission requests for dangerous permissions. Use the `permission_handler` package:

```yaml
dependencies:
  permission_handler: ^11.3.0
```

```dart
import 'package:permission_handler/permission_handler.dart';

// Request camera permission
if (await Permission.camera.request().isGranted) {
  // Use camera
}
```

---

## Network Security Configuration

### Location

`android/app/src/main/res/xml/network_security_config.xml`

### What It Does

The network security configuration controls how your app handles network connections:

- **Cleartext Traffic**: HTTP (non-encrypted) traffic is **disabled by default**
- **Development Exceptions**: Allows HTTP for localhost and emulator addresses
- **Certificate Trust**: Only trusts system Certificate Authorities

### Default Configuration

```xml
<network-security-config>
    <!-- Block cleartext (HTTP) by default -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </base-config>

    <!-- Allow cleartext for local development -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

### Common Customizations

#### Allow HTTP for a Specific Domain (Not Recommended)

```xml
<domain-config cleartextTrafficPermitted="true">
    <domain includeSubdomains="true">api.example.com</domain>
</domain-config>
```

#### Enable Certificate Pinning

```xml
<domain-config>
    <domain includeSubdomains="true">api.example.com</domain>
    <pin-set expiration="2025-12-31">
        <pin digest="SHA-256">base64EncodedSHA256PinHere=</pin>
        <!-- Backup pin -->
        <pin digest="SHA-256">backupPinHere=</pin>
    </pin-set>
</domain-config>
```

#### Trust Custom CA (for Development)

```xml
<debug-overrides>
    <trust-anchors>
        <certificates src="user"/>
    </trust-anchors>
</debug-overrides>
```

### AndroidManifest Reference

The configuration is referenced in `AndroidManifest.xml`:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

---

## Storage

### Included Dependencies

```yaml
# pubspec.yaml
dependencies:
  shared_preferences: ^2.3.0  # Key-value storage
  path_provider: ^2.1.0       # File system paths
```

### StorageService

A simple wrapper around SharedPreferences is provided at `lib/services/storage_service.dart`.

#### Basic Usage

```dart
import 'package:min_flutter_template/services/storage_service.dart';

// Initialize once at app startup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = StorageService();
  await storage.init();
  
  runApp(MyApp());
}

// Store values
await storage.setString('username', 'john');
await storage.setBool('onboarded', true);
await storage.setInt('launchCount', 1);

// Retrieve values
final username = storage.getString('username');
final onboarded = storage.getBool('onboarded') ?? false;
final count = storage.getInt('launchCount') ?? 0;

// Remove values
await storage.remove('username');
await storage.clear(); // Remove all
```

#### When to Use SharedPreferences

✅ **Good for:**
- User preferences (theme, language)
- Simple flags (onboarding completed, feature seen)
- Small cached values (auth tokens, user ID)
- App settings

❌ **Not good for:**
- Large data sets
- Complex objects
- Relational data
- Sensitive data (use flutter_secure_storage instead)

### File System Access

Use `path_provider` to get platform-specific directories:

```dart
import 'package:path_provider/path_provider.dart';

// Get directories
final appDir = await getApplicationDocumentsDirectory();
final tempDir = await getTemporaryDirectory();
final cacheDir = await getApplicationCacheDirectory();

// Save a file
final file = File('${appDir.path}/data.json');
await file.writeAsString(jsonEncode(data));

// Read a file
final content = await file.readAsString();
```

### Alternative Storage Options

For more advanced storage needs:

| Package | Use Case | Add to pubspec.yaml |
|---------|----------|---------------------|
| `hive` | Fast NoSQL database | `hive: ^2.2.3` |
| `isar` | High-performance database | `isar: ^3.1.0` |
| `sqflite` | SQLite database | `sqflite: ^2.3.2` |
| `flutter_secure_storage` | Encrypted storage | `flutter_secure_storage: ^9.0.0` |
| `drift` | Type-safe SQL | `drift: ^2.15.0` |

---

## Customization Guide

### Minimal App (No Network)

If your app doesn't need network access:

1. Remove INTERNET permission from `AndroidManifest.xml`
2. Remove `networkSecurityConfig` attribute from `<application>`
3. Delete `res/xml/network_security_config.xml`

### Offline-First App

For apps that work offline:

1. Keep network permissions for sync
2. Add Hive or Isar for local database
3. Implement sync logic when online

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^6.0.1
```

### Secure Storage App

For apps handling sensitive data:

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorage = FlutterSecureStorage();

// Store securely (encrypted)
await secureStorage.write(key: 'apiKey', value: 'secret123');

// Retrieve
final apiKey = await secureStorage.read(key: 'apiKey');
```

### Location-Based App

1. Uncomment location permissions in `AndroidManifest.xml`
2. Add location package

```yaml
dependencies:
  geolocator: ^11.0.0
  geocoding: ^3.0.0
```

### Camera App

1. Uncomment camera permission in `AndroidManifest.xml`
2. Add camera packages

```yaml
dependencies:
  camera: ^0.10.5
  image_picker: ^1.0.7
```

---

## Summary

| Feature | Location | Default State |
|---------|----------|---------------|
| Internet permission | `AndroidManifest.xml` | Enabled |
| Network state permission | `AndroidManifest.xml` | Enabled |
| Camera permission | `AndroidManifest.xml` | Commented |
| Location permissions | `AndroidManifest.xml` | Commented |
| Storage permissions | `AndroidManifest.xml` | Commented |
| Audio permission | `AndroidManifest.xml` | Commented |
| Network security config | `res/xml/network_security_config.xml` | HTTPS only (HTTP for localhost) |
| Key-value storage | `pubspec.yaml` | shared_preferences |
| File paths | `pubspec.yaml` | path_provider |
| StorageService | `lib/services/storage_service.dart` | Ready to use |
| NetworkService | `lib/services/network_service.dart` | Template/placeholder |

For more information, see:
- [Android Permissions Guide](https://developer.android.com/guide/topics/permissions/overview)
- [Network Security Configuration](https://developer.android.com/training/articles/security-config)
- [shared_preferences documentation](https://pub.dev/packages/shared_preferences)
- [path_provider documentation](https://pub.dev/packages/path_provider)
