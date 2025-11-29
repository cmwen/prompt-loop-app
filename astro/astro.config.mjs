import { defineConfig } from 'astro/config';

// ============================================================================
// GITHUB PAGES CONFIGURATION
// ============================================================================
// Update these values for your GitHub Pages deployment:
//
// For user/org site (username.github.io):
//   site: 'https://username.github.io'
//   base: undefined (or remove the base property)
//
// For project site (username.github.io/repo-name):
//   site: 'https://username.github.io'
//   base: '/repo-name'
//
// AI PROMPT: To update for your repo, replace:
//   - 'cmwen' with your GitHub username
//   - 'min-android-app-template' with your repository name
// ============================================================================

const GITHUB_USERNAME = 'cmwen';
const REPO_NAME = 'min-android-app-template';

export default defineConfig({
  site: `https://${GITHUB_USERNAME}.github.io`,
  base: `/${REPO_NAME}`,
});
