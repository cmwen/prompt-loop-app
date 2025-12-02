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
// ============================================================================

const GITHUB_USERNAME = 'cmwen';
const REPO_NAME = 'prompt-loop-app';

export default defineConfig({
  site: `https://${GITHUB_USERNAME}.github.io`,
  base: `/${REPO_NAME}`,
});
