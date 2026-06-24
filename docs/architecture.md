# Architecture — Pingu Notes

> For the quick summary, see [ARCHITECTURE.md](../ARCHITECTURE.md) at the repo root.
> This document goes deeper into design decisions and extension points.

---

## Layer Diagram

```
┌──────────────────────────────────────────────────────┐
│                   Presentation                        │
│  (Flutter widgets, pages, NoteProvider ChangeNotifier)│
└────────────────────────┬─────────────────────────────┘
                         │ reads/calls
┌────────────────────────▼─────────────────────────────┐
│                     Domain                            │
│  (Entities, Repository interfaces, Use cases,         │
│   IntelligenceService interface)                      │
│  ← Pure Dart — no Flutter, no sqflite →               │
└──────┬──────────────────────────────────┬────────────┘
       │ implements                       │ implements
┌──────▼──────────────┐    ┌─────────────▼────────────┐
│       Data          │    │         Services           │
│  (NoteLocalDataSource│   │  (LocalIntelligenceService,│
│   SQLite, models,   │    │   NotificationService,     │
│   repositories impl)│    │   service_locator / GetIt) │
└─────────────────────┘    └──────────────────────────-┘
```

---

## Key Design Decisions

### 1. Single ChangeNotifier

`NoteProvider` is the only `ChangeNotifier` in the app. This keeps the data flow simple for an offline-first app where all data lives in SQLite. There is no reactive stream layer — `notifyListeners()` triggers synchronous rebuilds, which is appropriate because all computed state is derived from in-memory `List<Note>`.

**Trade-off:** Scaling to concurrent operations or very large datasets would require moving to `Riverpod` or bloc.

### 2. IntelligenceService as the AI Seam

`IntelligenceService` (abstract, in `domain/services/`) is the single point where AI capabilities are introduced. `LocalIntelligenceService` provides offline heuristics so the app is fully functional without any model integration.

**To add a real model:** implement `IntelligenceService`, swap the registration in `service_locator.dart`. Nothing else changes.

Planned backends: Whisper (audio transcription), Gemma / Llama (chat/tutor), RAG via embedding table.

### 3. SQLite with WAL Mode

`PRAGMA journal_mode=WAL` is set in `onConfigure` (before any other operation). WAL allows concurrent reads during writes, which matters for spaced-repetition scheduled writes happening while the user navigates.

`PRAGMA foreign_keys=ON` enforces referential integrity at the DB level (cascade deletes, orphan prevention).

### 4. Spaced Repetition Algorithm

`ReviewNote` use case implements a simplified SM-2-inspired algorithm:

| Review Count | Interval |
|---|---|
| 1 | +1 day |
| 2 | +3 days |
| 3 | +7 days |
| 4 | +15 days |
| 5+ | +30 days |

Mastery levels:
- `0` — Never reviewed
- `1` — Learning (reviewCount 1–3)
- `2` — Mastered (reviewCount ≥ 4)

### 5. Notification ID Scheme

```dart
id = noteId * 10 + type.index + 1
```

This packs (noteId, type) into a single integer without collision for any noteId < 100,000 and 3 notification types. Safe for current scale; would need revisiting above ~200M rows.

---

## Database Schema (v8)

```sql
-- Core
CREATE TABLE notes (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  title           TEXT,
  content         TEXT,
  created_at      TEXT,   -- ISO-8601
  updated_at      TEXT,
  last_viewed_at  TEXT,
  reminder_at     TEXT,
  deadline        TEXT,
  is_favorite     INTEGER DEFAULT 0,
  is_task         INTEGER DEFAULT 0,
  is_completed    INTEGER DEFAULT 0,
  priority        TEXT DEFAULT 'medium',
  project_id      INTEGER REFERENCES projects(id),
  category        TEXT DEFAULT 'inbox',
  ai_summary      TEXT,
  tags            TEXT,   -- CSV, e.g. "flutter,dart,mobile"
  review_count    INTEGER DEFAULT 0,
  last_reviewed_at TEXT,
  next_review_at  TEXT,
  mastery_level   INTEGER DEFAULT 0,
  audio_path      TEXT,
  transcription   TEXT,
  ai_analysis     TEXT,   -- JSON blob
  content_type    TEXT DEFAULT 'plain'
);

CREATE TABLE projects (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT,
  description TEXT,
  color       INTEGER,    -- ARGB32 int
  created_at  TEXT,
  updated_at  TEXT
);

-- Knowledge OS
CREATE TABLE study_goals (...);
CREATE TABLE study_steps (...);
CREATE TABLE knowledge_connections (...);
CREATE TABLE note_questions (...);
CREATE TABLE achievements (...);
CREATE TABLE attachments (...);
CREATE TABLE ai_insights (...);  -- reserved, not yet used in UI
```

**Performance indexes (v8):**
- `notes(updated_at)`, `notes(is_favorite)`, `notes(project_id)`, `notes(category)`, `notes(next_review_at)`

---

## Extending the App

### Adding a New Use Case

```dart
// 1. domain/usecases/my_use_case.dart
class MyUseCase {
  final NoteRepository repository;
  MyUseCase(this.repository);
  Future<void> call(/* params */) => repository.doSomething();
}

// 2. services/service_locator.dart
sl.registerLazySingleton(() => MyUseCase(sl()));

// 3. presentation/providers/note_provider.dart
// Add field + method
```

### Adding a New AI Method

```dart
// 1. domain/services/intelligence_service.dart
Future<String> myNewMethod(String input);

// 2. services/local_intelligence_service.dart
@override
Future<String> myNewMethod(String input) async =>
    'This feature requires an AI backend.';

// 3. Wire up in NoteProvider or widget
```

### Adding a Database Column

```dart
// In NoteLocalDataSourceImpl._initDatabase():
if (oldVersion < 9) {
  await db.execute('ALTER TABLE notes ADD COLUMN my_field TEXT');
}
```

SQLite `ALTER TABLE` only supports `ADD COLUMN`. For renaming or dropping columns, create a new table, migrate data, and drop the old table.
