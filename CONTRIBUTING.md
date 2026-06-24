# Contributing to Pingu Notes

Thank you for your interest in contributing to Pingu Notes! This document provides guidelines and information to help you get started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Architecture Overview](#architecture-overview)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)

---

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.24.0` (Dart `^3.12.1`)
- Android Studio or VS Code with Flutter/Dart extensions
- A connected Android device or emulator (primary target)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/joao-hg/pingu_notes.git
cd pingu_notes

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run

# Run the test suite
flutter test

# Run static analysis (must pass with 0 issues before any PR)
flutter analyze
```

---

## Architecture Overview

Pingu Notes follows **Clean Architecture** with strict layer separation:

```
domain/       ← Pure Dart. No Flutter, no sqflite. Entities, repositories (interfaces), use cases.
data/         ← SQLite via sqflite. Implements domain interfaces.
services/     ← GetIt DI, LocalIntelligenceService, NotificationService.
presentation/ ← Flutter widgets, Provider state management.
```

**The golden rule:** dependencies only point inward. `domain/` has no external dependencies.

For a deeper dive, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## How to Contribute

### Reporting Bugs

1. Check if the issue already exists in [GitHub Issues](https://github.com/joao-hg/pingu_notes/issues).
2. Open a new issue using the **Bug Report** template.
3. Include: device/OS version, Flutter version, steps to reproduce, expected vs. actual behavior.

### Suggesting Features

1. Open a **Feature Request** issue describing the problem it solves.
2. Reference the relevant section in [ROADMAP.md](ROADMAP.md) if applicable.
3. Features that require heavy external model dependencies (tflite, pytorch, etc.) need explicit maintainer approval before implementation.

### Implementing a Feature

1. Fork the repository and create a branch from `main`:
   ```bash
   git checkout -b feat/your-feature-name
   ```
2. Implement the feature following the [Coding Standards](#coding-standards) below.
3. Add or update tests in `test/`.
4. Run `flutter analyze` and ensure **0 issues**.
5. Open a Pull Request.

---

## Pull Request Process

1. **One concern per PR** — keep PRs focused and reviewable.
2. Update `CHANGELOG.md` under the `[Unreleased]` section.
3. Ensure `flutter analyze` returns 0 issues.
4. Ensure existing tests pass: `flutter test`.
5. Describe your changes clearly in the PR description, including screenshots or recordings for UI changes.
6. PRs are squash-merged into `main`.

---

## Coding Standards

### General

- Follow the [Dart style guide](https://dart.dev/effective-dart/style).
- Use `prefer_single_quotes` for strings.
- Prefer `const` constructors wherever possible.
- No dead code, no commented-out code blocks.
- `debugPrint` is acceptable in error handlers; avoid it in hot paths.

### Clean Architecture Rules

- **Domain layer** must not import from `flutter`, `sqflite`, or any package outside `equatable` and `dart:core`.
- **Use cases** are single-callable classes with a `call()` method. One file per use case.
- **Widgets** must not contain business logic. Delegate to `NoteProvider`.
- **NoteProvider** computed getters must be synchronous calculations over `_notes` — no async DB calls.

### AI Seam

To add a new AI capability:
1. Add an abstract method to `IntelligenceService` in `domain/services/`.
2. Add a stub implementation in `LocalIntelligenceService` that returns a meaningful offline response — never a silent empty result.
3. Wire up the new method in the relevant provider or widget.

---

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <short summary>

Types: feat | fix | refactor | docs | test | chore | perf
Scope: domain | data | presentation | services | provider | deps

Examples:
feat(provider): add toggleFavorite to NoteProvider
fix(datasource): handle null next_review_at in migration v8
docs: update ARCHITECTURE with spaced repetition intervals
test(datasource): add stress test for massive note content
```

---

## Questions?

Open a [GitHub Discussion](https://github.com/joao-hg/pingu_notes/discussions) or reach out at **jvhenriquegonzaga@gmail.com**.
