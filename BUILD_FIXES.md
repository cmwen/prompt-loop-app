# Build Fixes Summary (Jan 2026)

## Issues Fixed

### 1. Java Version Incompatibility
**Problem**: Build was using Java 25.0.1 instead of Java 17, causing cryptic error "25.0.1"
**Solution**: 
- CI already configured to use Java 17 (via `actions/setup-java@v5`)
- Local development must use Java 17: `brew install openjdk@17`
- Set `JAVA_HOME=/path/to/openjdk@17`

### 2. Android Gradle Plugin (AGP) Too New
**Problem**: AGP 8.11.1 and Kotlin 2.3.20 were causing compatibility issues
**Solution**: Downgraded to stable versions:
- AGP: 8.11.1 → 8.9.1
- Kotlin: 2.3.20 → 2.1.0
- These versions work with Java 17 and Flutter 3.38.5

### 3. Build Tools Corruption
**Problem**: Build tools 35.0.0 were corrupted
**Solution**: Use build tools 34.0.0 instead

### 4. WSL/Windows CMake Issues (Local Only)
**Problem**: CMake and Ninja from Windows Android SDK have .exe extensions that don't work in WSL
**Solution** (for WSL users):
```bash
cd "$ANDROID_HOME/cmake/3.22.1/bin"
echo '#!/bin/bash
exec cmake.exe "$@"' > cmake && chmod +x cmake

echo '#!/bin/bash
exec ninja.exe "$@"' > ninja && chmod +x ninja
```

**Note**: CI doesn't need this as GitHub Actions runners use native Linux Android SDK.

## Files Changed
- `android/settings.gradle.kts`: Updated AGP and Kotlin versions
- `android/app/build.gradle.kts`: Changed buildToolsVersion to 34.0.0

## Testing
✅ CI should now pass with Java 17
✅ Local builds work with Java 17 + wrappers (WSL)
✅ PR #12 updated with these fixes

## Future Prevention
- Keep AGP and Kotlin versions in sync with Flutter stable recommendations
- Always test locally with same Java version as CI (Java 17)
- Document Java requirements in TROUBLESHOOTING.md
