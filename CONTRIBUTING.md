# Contributing to rtdog

Thank you for your interest in contributing to rtdog! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- macOS 14.0+ (for development)
- Xcode 15.0+
- Git

### Setup
1. Clone the repository
2. Open `rtdog.xcodeproj` in Xcode
3. Build and run the project

## 📋 Development Workflow

### Branch Strategy
We use **Git Flow** branching model:

- `main` - Production-ready releases
- `develop` - Integration branch for features
- `feature/*` - Feature development branches
- `release/*` - Release preparation branches
- `hotfix/*` - Critical bug fixes for production

### Making Changes

1. **Create a feature branch**:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Write clean, readable Swift code
   - Follow existing code style and patterns
   - Add comments for complex logic
   - Update tests if applicable

3. **Test your changes**:
   - Build and test on macOS
   - Verify all existing functionality works
   - Test edge cases

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push and create PR**:
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Message Format
We follow **Conventional Commits**:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
- `feat: add notification sound preferences`
- `fix: resolve calendar month navigation issue`
- `docs: update installation instructions`

## 🏗️ Code Style

### Swift Style Guide
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for consistent formatting
- Prefer explicit types when it improves readability
- Use meaningful variable and function names

### File Organization
```
rtdog/
├── Models/          # Data models
├── Views/           # SwiftUI views
├── ViewModels/      # View models and business logic
├── Services/        # External services (notifications, etc.)
└── Assets.xcassets/ # Images and colors
```

## 🧪 Testing

### Manual Testing Checklist
- [ ] App launches successfully
- [ ] Calendar displays current month correctly
- [ ] Day selection works for past, present, and future dates
- [ ] Notifications trigger at scheduled times
- [ ] Settings save and persist between app launches
- [ ] Month navigation works correctly
- [ ] Recent days interface functions properly
- [ ] App icon displays correctly in Dock and Applications

### Before Submitting
- [ ] Code builds without warnings
- [ ] All features work as expected
- [ ] No crashes or memory leaks
- [ ] Code follows style guidelines
- [ ] Documentation updated if needed

## 📦 Release Process

### Version Numbering
We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes or major features
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes, backwards compatible

### Release Checklist
1. Update version in `VERSION` file
2. Update `CHANGELOG.md` with new changes
3. Update version in Xcode project settings
4. Test release build thoroughly
5. Create release branch
6. Tag release in Git
7. Build and distribute

## 🚨 Reporting Issues

When reporting bugs, please include:
- macOS version
- rtdog version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable

## 💡 Feature Requests

We welcome feature suggestions! Please:
- Check existing issues first
- Describe the problem you're trying to solve
- Explain your proposed solution
- Consider backwards compatibility

## 📞 Getting Help

- Create an issue for bugs or questions
- Check the README for basic setup
- Review existing issues and discussions

## 🙏 Recognition

Contributors will be acknowledged in:
- CHANGELOG.md for significant contributions
- Release notes
- Project documentation

Thank you for contributing to rtdog! 🎉 
