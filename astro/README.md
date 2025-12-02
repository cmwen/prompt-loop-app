# Prompt Loop Website (Astro)

This folder contains an Astro-based documentation site for Prompt Loop, deployed to GitHub Pages.

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

The site is configured in `astro.config.mjs`:

```js
const GITHUB_USERNAME = 'cmwen';
const REPO_NAME = 'prompt-loop-app';
```

Site deployed to: `https://cmwen.github.io/prompt-loop-app/`

## Features

- Small Startlight-inspired theme (dark, readable, fast)
- Minimal pages: Home, About, Install, Releases
- Auto-deploy to GitHub Pages via `.github/workflows/deploy-website.yml`
- Published when a GitHub Release is created (or via manual workflow dispatch)

## Flutter App Commands

For app build instructions, from the repo root:

```bash
# Get dependencies
flutter pub get

# Run in development
flutter run

# Build for release
flutter build apk         # Android
flutter build appbundle   # Play Store
```

## Releases

Download prebuilt artifacts from GitHub Releases:
https://github.com/cmwen/prompt-loop-app/releases/latest

