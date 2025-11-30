# App Icon Setup Guide

## Icon Design

The Prompt Loop app icon features:
- **Concept**: Continuous learning loop with AI nodes
- **Style**: Minimal, modern, flat design
- **Colors**: 
  - Primary: #0EA5E9 (Sky Blue)
  - Secondary: #0369A1 (Darker Blue)
  - Accent: #E0F2FE (Light Blue for nodes)
  - Foreground: White (#FFFFFF)

## Files Included

- `app_icon.svg` - Vector source file (1024x1024)

## Generating PNG Icons

### Option 1: Using Online Converter (Recommended)

1. Go to https://cloudconvert.com/svg-to-png or similar
2. Upload `app_icon.svg`
3. Set output size to 1024x1024
4. Download as `app_icon.png`

For the foreground (adaptive icon):
- Create a version with transparent background
- Save as `app_icon_foreground.png`

### Option 2: Using ImageMagick (Command Line)

```bash
# Install ImageMagick (if not installed)
brew install imagemagick

# Convert SVG to PNG
magick convert -background none -resize 1024x1024 app_icon.svg app_icon.png
magick convert -background none -resize 1024x1024 app_icon.svg app_icon_foreground.png
```

### Option 3: Using Figma/Design Tools

1. Open `app_icon.svg` in Figma or Adobe Illustrator
2. Export as PNG at 1024x1024
3. Save both regular and foreground versions

## Generating All Android Icon Sizes

Once you have `app_icon.png` in this directory:

```bash
# Run the flutter_launcher_icons package
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required Android mipmap sizes:
- mdpi: 48×48 px
- hdpi: 72×72 px
- xhdpi: 96×96 px
- xxhdpi: 144×144 px
- xxxhdpi: 192×192 px

## Manual Icon Generation (Alternative)

If automated generation doesn't work, manually create these sizes:

```bash
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-hdpi/ic_launcher.png (72x72)
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
└── mipmap-xxxhdpi/ic_launcher.png (192x192)
```

## Design Specifications

### Visual Elements

1. **Loop Path**: Continuous white stroke (56px width) forming a circular learning loop
2. **Center Dot**: White circle (40px radius) representing the learner
3. **Progress Nodes**: Three light blue circles (28px radius) marking progress points
4. **Arrow**: White triangular arrow indicating forward movement
5. **Background**: Gradient from #0EA5E9 to #0369A1 with 228px corner radius

### Accessibility

- High contrast white-on-blue design
- Simple, recognizable shape at small sizes
- No text (universal understanding)
- Distinct from common app icons

## Color Palette Reference

```
Primary Background: #0EA5E9 (RGB: 14, 165, 233)
Gradient End: #0369A1 (RGB: 3, 105, 161)
Foreground: #FFFFFF (RGB: 255, 255, 255)
Node Accent: #E0F2FE (RGB: 224, 242, 254)
```

## Testing

After generating icons:

1. Build the app: `flutter build apk`
2. Install on device: `flutter install`
3. Check icon appearance in launcher
4. Test on both light and dark home screen backgrounds
5. Verify icon is recognizable at small sizes

## Troubleshooting

**Issue**: Icons not updating after running flutter_launcher_icons
**Solution**: 
```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
flutter build apk
```

**Issue**: Adaptive icon background color not applied
**Solution**: Check `android/app/src/main/res/values/colors.xml` or manually set in `AndroidManifest.xml`
