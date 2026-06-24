# Changelog

All notable changes to Pingu Notes are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- `.editorconfig` for consistent formatting across editors
- `CODE_OF_CONDUCT.md` following Contributor Covenant 2.1
- `CONTRIBUTING.md` with architecture guidelines and PR process
- Improved `analysis_options.yaml` with additional lint rules

### Changed
- `pubspec.yaml` description updated to reflect the project's purpose
- `analysis_options.yaml` now enables `prefer_single_quotes`, `prefer_const_constructors`, and `avoid_redundant_argument_values`
- Removed redundant default arguments across multiple files (analyzer-validated)
- `.gitignore` now excludes `.claude/`, `.openclaude/`, Gradle cache, and iOS/macOS ephemeral directories

### Fixed
- Removed stale inline developer comment (`// ← ADICIONADO`) from `main.dart`
- `DarwinInitializationSettings` call now omits redundant default boolean arguments
- `_SectionLabel` instantiations in `settings_page.dart` promoted to `const`
- `Icon` in `review_panel.dart` promoted to `const`
- `InputDecoration` in `quick_add_modal.dart` promoted to `const`

---

## [1.0.0] — 2026-06-08

### Added

**Core Note Management**
- Full CRUD for notes with SQLite persistence (offline-first)
- Rich note model: title, content, tags (CSV), category (`inbox` / `organized`), priority, project association
- Auto-save on edit with debounce; manual save on close
- Swipe-to-favorite on home page
- Full-text search (LIKE on title, content, tags) with real-time filtering
- Sort by: Intelligent (due reviews first), Newest, Oldest, Alphabetical

**Projects**
- Create / edit / delete projects with custom color picker
- Notes can be associated with projects; cascade-clear on project deletion
- Project list with note count badge

**Spaced Repetition (Pingu Studies)**
- `ReviewNote` use case: intervals of 1 / 3 / 7 / 15 / 30 days
- Mastery levels: `0` = never reviewed · `1` = learning · `2` = mastered
- Dashboard panel shows due reviews count and overdue notes
- Automatic review scheduling via `flutter_local_notifications`

**Goals & Learning Objectives**
- `StudyGoal` with nested `StudyStep` list
- Manual progress tracking with percentage bar
- Full CRUD for goals and steps

**Knowledge OS**
- Pergunte ao Pingu (Ask Pingu): offline keyword search over notes; responds to stats, tag, and favorite queries
- Pingu Studies suggestions: 20+ technology domain map with related topic suggestions
- Knowledge gap detection: 8-domain heuristic analysis
- Auto-generated review questions per note (1–3 heuristic questions)
- Knowledge connections graph (table `knowledge_connections`; no UI yet)
- Conversor: `convertStyle()` functional for Summary, Flashcard, Academic, Beginner styles

**Achievements System**
- 7 default achievements seeded via `INSERT OR IGNORE` on every DB open
- Automatic unlock triggers in `addNote`, `reviewNote`, `addProject`
- Idempotent unlock: only fires once per achievement (`AND unlocked_at IS NULL`)

**Notifications**
- 3 notification channels: `review`, `reminder`, `memory`
- Timezone-aware scheduling via `flutter_timezone`
- Deep-link from notification to note (via `onDidReceiveNotificationResponse`)

**UI / UX**
- Dark mode / Light mode / System theme toggle
- Design system: Deep Ocean Blue primary, warm yellow FAB, Poppins + Playfair Display typography
- Custom `PinguMascot` drawn via `CustomPainter`
- Animated splash screen with scale + fade
- Bottom navigation with 5 sections: Home, Memory, Today, Projects, Settings
- Markdown / plain text toggle in note editor with `FormatToolbar`
- Inbox, Timeline, Today, Memory, Goals, Evolution, Study pages
- `AskPinguPage` with chat-style UI (ready for real AI integration)
- `AudioRecorderWidget` scaffold (seam for Whisper integration)

**Infrastructure**
- Clean Architecture (Domain → Data ← Presentation)
- GetIt dependency injection with mandatory registration order
- SQLite v8 with WAL mode, foreign keys, and performance indexes
- `sqflite_common_ffi` for desktop (Linux, Windows, macOS) support
- `LocalIntelligenceService` as offline-first AI seam
- Stress test covering 50-note sequential insert and 25,000-character emoji content

### Architecture Decisions

- Single `ChangeNotifier` (`NoteProvider`) for simplified offline-first data flow
- `IntelligenceService` abstract interface as the sole extension point for future AI backends (Whisper, Gemma, Llama, RAG)
- `Color.toARGB32()` used throughout (`.value` deprecated in Flutter 3.44+ / Dart ^3.12.1)
- `FutureBuilder` futures stored in `initState()` to prevent rebuild loops
- Tags stored as CSV in `notes.tags TEXT` — known limitation for tags containing commas

---

[Unreleased]: https://github.com/joao-hg/pingu_notes/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/joao-hg/pingu_notes/releases/tag/v1.0.0
