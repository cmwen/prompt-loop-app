# Documentation Website (Astro)

This folder contains an Astro-based documentation site for the repository, deployed to GitHub Pages.

**Note**: This site uses Astro v5.15 and requires Node 18+ to run locally.

## Quick Start

```bash
cd astro
npm install
npm run dev      # Local development
npm run build    # Generate dist/
npm run preview  # Preview build
```

## Configuration

Update `astro.config.mjs` for your GitHub Pages deployment:

```js
const GITHUB_USERNAME = 'your-username';
const REPO_NAME = 'your-repo-name';
```

Your site will be deployed to: `https://your-username.github.io/your-repo-name/`

## Features

- Small Startlight-inspired theme (dark, readable, fast)
- Minimal pages: Home, About, Install, Releases
- Auto-deploy to GitHub Pages via `.github/workflows/deploy-website.yml`
- Published when a GitHub Release is created (or via manual workflow dispatch)

## Flutter Project Commands

For app build instructions, from the repo root:

```bash
# Get dependencies
flutter pub get

# Run in development
flutter run

# Build for release
flutter build apk         # Android
flutter build appbundle   # Play Store
flutter build ios         # iOS
flutter build web         # Web
```

## Releases

Download prebuilt artifacts from GitHub Releases:
https://github.com/cmwen/min-android-app-template/releases/latest

