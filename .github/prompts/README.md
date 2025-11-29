# Copilot Custom Prompts

This directory contains custom prompt files that guide GitHub Copilot and other LLMs to follow project-specific best practices and constraints.

## How to Use Custom Prompts

Custom prompts are automatically loaded by VS Code when you have the Copilot extension installed. They help guide Copilot's responses to be more aligned with your project's requirements.

For more information, see: https://code.visualstudio.com/docs/copilot/customization/prompt-files

## Available Prompts

### icon-generation.md

**Purpose**: Helps designers and developers create consistent, platform-ready icons (SVG, PNG, Flutter assets) and launcher assets. Includes prompt templates, sizing guidance, filename conventions, and examples for use with Copilot, Copilot Chat, and image-generation models.

**When to Use**:
- When creating UI or launcher icons
- When producing export-ready PNG/SVG files for Flutter assets
- Generating app icons for multiple platforms (Android, iOS, Web)

## Contributing Custom Prompts

When adding new custom prompts:

1. Create a descriptive filename ending in `.md`
2. Include clear context about the project
3. Provide specific rules and constraints
4. Add validation checklists where applicable
5. Include troubleshooting guidance
6. Link to relevant documentation

## Project Configuration Reference

This is a Flutter project. Current configuration:
- **Flutter**: 3.10.1+
- **Dart**: 3.10.1+
- **Platforms**: Android, iOS, Web, Linux, macOS, Windows

For the latest dependency versions, check `pubspec.yaml`.
