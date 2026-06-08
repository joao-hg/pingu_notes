# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Product Vision

Pingu Notes is **not** a traditional note-taking app. Its goal is to transform text, audio, images and ideas into organized, studyable, reusable knowledge.

Core flow: **Capture → Organize → Relate → Review → Learn → Expand Knowledge**

The app is **offline-first**. When a feature is unavailable offline, tell the user clearly — never use silent mocks.

## Priority Order

When working in this codebase, always follow this order. Never add features on top of an unstable base:

1. Fix bugs / crashes
2. Fix layout overflows
3. Guarantee data persistence
4. Guarantee performance
5. Only then: new features

## Commands

```bash
# Must pass with 0 issues before finishing any change
flutter analyze

flutter run                          # run on connected device / emulator
flutter build apk --release
flutter test
flutter test test/path/to/file.dart  # single test file
flutter pub run flutter_launcher_icons  # after changing assets/icon/icon.png
```

## Architecture

Strict Clean Architecture. Dependencies only point inward (domain has no Flutter/sqflite imports).

```
domain/          ← pure Dart
  entities/      ← Note, Project, StudyGoal, KnowledgeConnection, NoteQuestion, Achievement, Attachment
  repositories/  ← abstract interfaces (NoteRepository, KnowledgeRepository)
  usecases/      ← one callable class per use case
  services/      ← IntelligenceService (abstract — the AI seam)

data/
  datasource/    ← NoteLocalDataSourceImpl (SQLite via sqflite)
  models/        ← NoteModel, ProjectModel, KnowledgeOsModels (extend domain entities)
  repositories/  ← NoteRepositoryImpl, KnowledgeRepositoryImpl

services/        ← concrete impls (outside clean-arch layers)
  service_locator.dart              ← GetIt DI
  local_intelligence_service.dart   ← offline IntelligenceService (heuristics only)
  notification_service.dart         ← flutter_local_notifications singleton

presentation/
  providers/     ← NoteProvider (single ChangeNotifier for all state)
  pages/         ← full screens
  widgets/       ← reusable widgets
```

## Dependency Injection

`service_locator.dart` uses GetIt. Registration order is mandatory:
1. `NoteLocalDataSourceImpl`
2. `NoteRepositoryImpl`, `KnowledgeRepositoryImpl` (depend on DataSource)
3. All use cases (depend on Repositories)
4. `LocalIntelligenceService`, `NotificationService` (last — `NotificationService` requires `await init()`)

`NotificationService` uses `registerSingleton`; everything else uses `registerLazySingleton`.

## State Management

`NoteProvider` is the single `ChangeNotifier` for the entire app:
- Fields: `_notes`, `_projects`, `_studyGoals`, `_connections`, `_achievements`, `_isLoading`, `_error`
- Computed getters (`dueReviews`, `forgottenNotes`, `dashboardStats`, etc.) are synchronous calculations on `_notes` — not DB calls
- `loadInitialData()` is wrapped in try/catch/finally — `_isLoading = false` always runs in finally
- After any write (add/update/delete), always calls `searchNotes(_currentQuery)` to refresh state
- `searchNotes(query)` replaces `_notes` with search results; `loadNotes()` resets to all notes

## Database

SQLite at `pingu_notes.db`, currently **version 8**. Schema in `NoteLocalDataSourceImpl._initDatabase()`. Full version history in `ARCHITECTURE.md`.

Migration rules:
- Add `if (oldVersion < N)` block in `onUpgrade`
- Use `CREATE TABLE IF NOT EXISTS` for new tables in migrations
- SQLite ALTER TABLE only supports `ADD COLUMN`

**Tables:** `notes`, `projects`, `study_goals`, `study_steps`, `knowledge_connections`, `note_questions`, `achievements`, `attachments`, `ai_insights` (table exists but unused in UI)

`tags` stored as CSV in `notes`. Tags with commas break parsing. Achievement rows are seeded via `INSERT OR IGNORE` on every DB open (`_seedAchievements`); 7 default rows with keys: `first_note`, `first_project`, `notes_10`, `notes_50`, `reviews_10`, `reviews_100`, `streak_7`.

## IntelligenceService — The AI Seam

`IntelligenceService` (abstract in `domain/services/`) is the single extension point for all AI capabilities. `LocalIntelligenceService` implements it offline using keyword heuristics — no real ML.

To add a real AI backend (Whisper, Gemma, Qwen, Llama, RAG), implement `IntelligenceService` and swap the registration in `service_locator.dart`. Nothing else changes.

Methods currently returning stubs: `transcribeAudio()`, `chatWithNotes()`, `translate()`. The UI is already wired — `AskPinguPage` and `AudioRecorderWidget` are ready.

Do not add heavy model dependencies (`tflite`, `flutter_pytorch`, etc.) without explicit instruction.

## Roadmap (architecture to prepare, not implement yet)

| Feature | Status | Notes |
|---|---|---|
| Pingu Studies V2 | Partial | `getStudySuggestions`, `getLearningRoadmap` exist in `IntelligenceService`; expand with real note graph |
| Pergunte ao Pingu | Stub | `chatWithNotes()` in `LocalIntelligenceService`; UI complete in `AskPinguPage` |
| Pingu Voice | Disabled | `AudioRecorderWidget` shows SnackBar; `transcribeAudio()` is the seam; prepare for Whisper |
| Conversor de Linguagem | Stub | `translate()` and `convertStyle()` in service; UI entry points exist |
| RAG Local | Future | Will need embedding storage (new table) + vector similarity; keep domain layer clean for this |
| Pingu Tutor | Future | Superset of "Pergunte ao Pingu"; same `chatWithNotes()` seam |

Target languages for Conversor: Portuguese → English, Spanish, French, German, Italian.  
Target styles: Summary, Academic, Technical, Beginner, Flashcards.

## Key Patterns & Constraints

**Color API:** Use `.toARGB32()` to convert `Color` to `int`. `.value` is deprecated in Flutter 3.44+ / Dart ^3.12.1.

**FutureBuilder rebuild loop:** Never call an async method directly in `build()`. Store the `Future` in `initState()` and pass that variable to `FutureBuilder`. See `_KnowledgeGapsSectionState` and `_KnowledgeHubPanelState` for the correct pattern.

**Locale:** `Intl.defaultLocale = 'pt_BR'` and `initializeDateFormatting('pt_BR', null)` must run before `di.init()` and `runApp()`. Already correct in `main()`.

**Layout:** Pages with keyboards must account for `MediaQuery.of(context).viewInsets.bottom`. `HomePage.body` is wrapped in `SafeArea`.

**Mastery levels:** `0` = never reviewed, `1` = learning, `2` = mastered. Ignore the entity comment that says "4+: Mastered" — the provider logic is the source of truth.

**Spaced repetition:** `ReviewNote` use case sets `nextReviewAt` based on `reviewCount`. Notes without `nextReviewAt` appear in `dueReviews` if at least 1 day old (by `createdAt`).

**Notification IDs:** `noteId * 10 + type.index + 1`. Safe for current scale.

**Audio:** `AudioRecorderWidget` intentionally shows a SnackBar instead of recording. `transcribeNoteAudio()` guards `if (audioPath.isEmpty) return`.

## Rules

- Do not remove existing features.
- Do not change the visual identity (colors, mascot, typography) without explicit request.
- Do not create silent mocks — if something doesn't work offline, say so to the user.
- Always run `flutter analyze` and get 0 issues before finishing any change.
- Validate that a feature actually works before expanding it.

## pingu_notes_audit/

Snapshot of a prior state. Ignore entirely — all active development is in the root `lib/`.
