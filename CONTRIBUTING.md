# Contributing to Min Flutter Template

Thank you for considering contributing to this Flutter app template!

## How to Use This Template

This is a **template repository**. To use it:

1. Click "Use this template" on GitHub
2. Create a new repository from this template
3. Clone your new repository
4. Start building your Flutter app!

## Improving the Template

If you'd like to improve this template itself, here's how:

### Reporting Issues

- Check if the issue already exists
- Provide clear reproduction steps
- Include your environment details (OS, Flutter version, Dart version, etc.)
- Share relevant error messages or logs

### Suggesting Enhancements

- Open an issue describing the enhancement
- Explain why it would be useful
- Consider backward compatibility
- Keep the template minimal and general-purpose

### Pull Requests

1. **Fork** the repository
2. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**:
   - Follow existing code style
   - Update documentation if needed
   - Keep changes minimal and focused
4. **Test your changes**:
   ```bash
   flutter clean
   flutter pub get
   flutter analyze
   flutter test
   ```
5. **Commit your changes**:
   ```bash
   git commit -m "Brief description of changes"
   ```
6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request** with a clear description

### Code Style Guidelines

- Use Dart for all application code
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use Flutter best practices and widget composition
- Keep dependencies up to date but stable
- Maintain null safety throughout
- Use const constructors when possible

### What to Contribute

**Good contributions:**
- Bug fixes
- Security updates
- Documentation improvements
- CI/CD workflow enhancements
- Dependency updates
- Better default configurations

**What to avoid:**
- Adding app-specific features
- Including opinionated state management libraries
- Complex architectural patterns
- UI/UX customizations
- Domain-specific code

### Keeping It Minimal

This template should remain:
- **Minimal**: Only essential files and dependencies
- **General**: Not specific to any app domain
- **Modern**: Using current best practices
- **Documented**: Clear and helpful documentation
- **AI-Friendly**: Easy to customize with AI assistants

### Testing Guidelines

Before submitting a PR:

- [ ] Build succeeds: `flutter build apk`
- [ ] Tests pass: `flutter test`
- [ ] Code analysis passes: `flutter analyze`
- [ ] GitHub Actions workflows pass
- [ ] Documentation is updated
- [ ] Changes are backward compatible

> **Note**: Code formatting is automatically applied by CI. You don't need to run `dart format` manually, but you can run it locally if preferred.

### Commit Message Format

Use clear, descriptive commit messages:

```
Brief summary (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.
Explain what changed and why, not how.

- Bullet points are okay
- Use present tense: "Add feature" not "Added feature"
```

### Version Updates

When updating versions:

1. Check compatibility
2. Update version in appropriate file
3. Test the build
4. Update documentation
5. Note breaking changes

### Documentation Updates

Keep these files in sync:
- `README.md` - User-facing documentation
- `AGENTS.md` - Agent/automation documentation
- `TESTING.md` - Testing procedures
- `CONTRIBUTING.md` - This file

## Questions?

Feel free to open an issue for discussion before starting major work.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
