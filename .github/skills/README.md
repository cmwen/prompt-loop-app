# GitHub Copilot Agent Skills

This directory contains [Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) - specialized, reusable instructions that guide GitHub Copilot agents to perform specific tasks according to project best practices.

## What Are Agent Skills?

Agent Skills are folders containing structured instructions, workflows, and examples that Copilot agents can use to handle specialized tasks. Each skill has:

- **SKILL.md**: Main skill file with YAML frontmatter and detailed instructions
- **Frontmatter**: Metadata including name, description, and when to use the skill
- **Body**: Detailed workflows, commands, examples, and troubleshooting guidance

Skills are automatically discovered by Copilot in VS Code, GitHub CLI, and Copilot agents.

## Available Skills

### 🎨 icon-generation
**Path**: `.github/skills/icon-generation/`

Generate app icons (SVG/PNG) and launcher icons for Android Flutter apps.

**Use when**:
- Creating UI icons or launcher icons
- Setting up flutter_launcher_icons
- Generating platform-ready icon assets
- Creating consistent, accessible icons

**Key capabilities**:
- Provides sizing guidance for Android mipmap densities
- Includes prompt templates for AI image generation
- Documents flutter_launcher_icons setup
- Best practices for icon design

---

### 🐛 android-debug
**Path**: `.github/skills/android-debug/`

Debug Android Flutter apps including runtime errors, build issues, and performance problems.

**Use when**:
- App crashes or runtime errors on Android
- Device/emulator connection issues
- Performance problems (lag, memory, battery)
- Platform channel issues
- APK/App Bundle generation problems

**Key capabilities**:
- Complete debugging workflow from identification to resolution
- ADB commands and Flutter DevTools usage
- Platform-specific troubleshooting (Gradle, manifests, resources)
- Performance profiling guidance
- Quick troubleshooting checklist

---

### 🔧 ci-debug
**Path**: `.github/skills/ci-debug/`

Debug GitHub Actions workflow failures and CI-specific issues.

**Use when**:
- GitHub Actions workflows fail
- CI build errors that don't occur locally
- Test failures only in CI environment
- Artifact or secret issues
- Timeout or cache problems

**Key capabilities**:
- Workflow-specific debugging for build.yml, release.yml, pre-release.yml
- Common CI failure patterns and solutions
- Cache and artifact troubleshooting
- Auto-format commit step debugging
- Local CI simulation commands

---

### 🏗️ build-fix
**Path**: `.github/skills/build-fix/`

Diagnose and fix Flutter build failures including dependency conflicts and Gradle errors.

**Use when**:
- Flutter build fails (apk, appbundle)
- Gradle sync or build errors
- Dependency resolution failures
- Compilation errors (Dart or native)
- Version conflicts

**Key capabilities**:
- Systematic diagnostic workflow by build stage
- Common failure patterns with solutions
- Gradle, Java/JVM, R8/ProGuard issues
- Project-specific configuration guidance
- Performance optimization tips
- Troubleshooting checklist and quick reference

---

## How to Use Skills

### In VS Code
Skills are automatically loaded when you use GitHub Copilot. The agent will suggest using relevant skills based on your context.

### In Copilot Chat
Reference skills directly:
```
@workspace Use the android-debug skill to help me fix this crash
```

### In GitHub CLI
Skills work with `gh copilot` commands when available.

## Skill Structure

Each skill follows this structure:

```
.github/skills/
└── skill-name/
    └── SKILL.md          # Main skill file
```

### SKILL.md Format

```markdown
---
name: skill-name
description: What the skill does and when to use it
---

# Skill Title

Detailed instructions, workflows, examples, and resources.
```

## Creating New Skills

To add a new skill:

1. **Create directory**: `.github/skills/your-skill-name/`
2. **Create SKILL.md** with:
   - YAML frontmatter (name, description)
   - Clear "When to Use" section
   - Structured workflow or instructions
   - Examples and code snippets
   - Troubleshooting guidance
   - Links to relevant resources

3. **Follow best practices**:
   - Use lowercase-with-hyphens for skill names
   - Be specific about when to use the skill
   - Include practical examples
   - Add commands and code snippets
   - Provide troubleshooting steps
   - Keep instructions actionable

4. **Update this README**: Add your skill to the list above

## Skill Guidelines

**Good skills**:
- Focus on specific, repeatable tasks
- Include clear workflows and decision trees
- Provide concrete examples and commands
- Document edge cases and gotchas
- Reference project-specific configuration

**Avoid**:
- Vague or overly broad guidance
- Duplicating information available in docs
- Skills that are too similar to existing ones
- Complex dependencies between skills

## Related Resources

- **Custom Agents**: `.github/agents/` - Role-based agent personas
- **Custom Prompts**: `.github/prompts/` - General guidance (legacy)
- **Documentation**: `docs/` - Project documentation
- **Workflows**: `.github/workflows/` - CI/CD automation

## Additional Information

### Skills vs Prompts vs Agents

- **Skills**: Task-specific, reusable workflows (this directory)
- **Prompts**: General guidance and constraints (`.github/prompts/`)
- **Agents**: Role-based personas with tools (`.github/agents/`)

### Official Documentation

- [About Agent Skills - GitHub Docs](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- [VS Code Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Writing Great Agents - GitHub Blog](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)

## Contributing

When contributing skills:

1. Test the skill with Copilot
2. Ensure it doesn't duplicate existing skills
3. Follow the structure and format
4. Update this README
5. Consider if it should be a skill vs documentation

For questions or suggestions, open an issue or PR.
