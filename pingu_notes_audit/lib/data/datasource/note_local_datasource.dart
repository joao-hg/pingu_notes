import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';
import '../models/project_model.dart';
import '../models/knowledge_os_models.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<List<NoteModel>> searchNotes(String query);
  Future<NoteModel> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(int id);

  // Projects
  Future<List<ProjectModel>> getProjects();
  Future<void> addProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(int id);

  // Knowledge OS V1
  Future<List<StudyGoalModel>> getStudyGoals();
  Future<void> addStudyGoal(StudyGoalModel goal);
  Future<void> updateStudyGoal(StudyGoalModel goal);
  Future<void> deleteStudyGoal(int id);
  
  Future<void> addStudyStep(StudyStepModel step);
  Future<void> updateStudyStep(StudyStepModel step);
  Future<void> deleteStudyStep(int id);

  Future<List<KnowledgeConnectionModel>> getConnections();
  Future<List<KnowledgeConnectionModel>> getNoteConnections(int noteId);
  Future<void> addConnection(KnowledgeConnectionModel connection);
  Future<void> deleteConnection(int id);

  Future<List<NoteQuestionModel>> getNoteQuestions(int noteId);
  Future<void> addNoteQuestion(NoteQuestionModel question);
  Future<void> updateNoteQuestion(NoteQuestionModel question);
  Future<void> deleteNoteQuestion(int id);

  Future<List<AchievementModel>> getAchievements();
  Future<void> unlockAchievement(String key);

  Future<List<AttachmentModel>> getNoteAttachments(int noteId);
  Future<void> addAttachment(AttachmentModel attachment);
  Future<void> deleteAttachment(int id);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pingu_notes.db');
    return await openDatabase(
      path,
      version: 7,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            created_at TEXT,
            updated_at TEXT,
            last_viewed_at TEXT,
            reminder_at TEXT,
            deadline TEXT,
            is_favorite INTEGER,
            is_task INTEGER,
            is_completed INTEGER,
            priority TEXT,
            project_id INTEGER,
            category TEXT,
            ai_summary TEXT,
            tags TEXT,
            review_count INTEGER DEFAULT 0,
            last_reviewed_at TEXT,
            next_review_at TEXT,
            mastery_level INTEGER DEFAULT 0,
            audio_path TEXT,
            transcription TEXT,
            ai_analysis TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE projects(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            description TEXT,
            color INTEGER,
            created_at TEXT,
            is_active INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE ai_insights(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            note_id INTEGER,
            type TEXT NOT NULL,
            value TEXT NOT NULL,
            confidence REAL NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE study_goals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            progress REAL DEFAULT 0,
            status TEXT DEFAULT 'active',
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE study_steps(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goal_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            is_completed INTEGER DEFAULT 0,
            position INTEGER NOT NULL,
            FOREIGN KEY (goal_id) REFERENCES study_goals (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE knowledge_connections(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_id INTEGER NOT NULL,
            target_id INTEGER NOT NULL,
            type TEXT DEFAULT 'related',
            weight REAL DEFAULT 1.0,
            FOREIGN KEY (source_id) REFERENCES notes (id) ON DELETE CASCADE,
            FOREIGN KEY (target_id) REFERENCES notes (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE note_questions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            note_id INTEGER NOT NULL,
            question TEXT NOT NULL,
            answer TEXT,
            difficulty INTEGER DEFAULT 1,
            FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE achievements(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT UNIQUE NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            unlocked_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE attachments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            note_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            path TEXT NOT NULL,
            metadata TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE notes ADD COLUMN last_viewed_at TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE notes ADD COLUMN reminder_at TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE notes ADD COLUMN deadline TEXT');
          await db.execute(
            'ALTER TABLE notes ADD COLUMN is_task INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE notes ADD COLUMN is_completed INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE notes ADD COLUMN priority TEXT DEFAULT "medium"',
          );
          await db.execute('ALTER TABLE notes ADD COLUMN project_id INTEGER');
          await db.execute(
            'ALTER TABLE notes ADD COLUMN category TEXT DEFAULT "inbox"',
          );
          await db.execute('ALTER TABLE notes ADD COLUMN ai_summary TEXT');

          await db.execute('''
            CREATE TABLE projects(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              description TEXT,
              color INTEGER,
              created_at TEXT,
              is_active INTEGER
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ai_insights(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              note_id INTEGER,
              type TEXT NOT NULL,
              value TEXT NOT NULL,
              confidence REAL NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 6) {
          await db.execute(
            'ALTER TABLE notes ADD COLUMN review_count INTEGER DEFAULT 0',
          );
          await db.execute('ALTER TABLE notes ADD COLUMN last_reviewed_at TEXT');
          await db.execute('ALTER TABLE notes ADD COLUMN next_review_at TEXT');
          await db.execute(
            'ALTER TABLE notes ADD COLUMN mastery_level INTEGER DEFAULT 0',
          );
        }
        if (oldVersion < 7) {
          await db.execute('ALTER TABLE notes ADD COLUMN audio_path TEXT');
          await db.execute('ALTER TABLE notes ADD COLUMN transcription TEXT');
          await db.execute('ALTER TABLE notes ADD COLUMN ai_analysis TEXT');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS study_goals(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT,
              progress REAL DEFAULT 0,
              status TEXT DEFAULT 'active',
              created_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS study_steps(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              goal_id INTEGER NOT NULL,
              title TEXT NOT NULL,
              is_completed INTEGER DEFAULT 0,
              position INTEGER NOT NULL,
              FOREIGN KEY (goal_id) REFERENCES study_goals (id) ON DELETE CASCADE
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS knowledge_connections(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              source_id INTEGER NOT NULL,
              target_id INTEGER NOT NULL,
              type TEXT DEFAULT 'related',
              weight REAL DEFAULT 1.0,
              FOREIGN KEY (source_id) REFERENCES notes (id) ON DELETE CASCADE,
              FOREIGN KEY (target_id) REFERENCES notes (id) ON DELETE CASCADE
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS note_questions(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              note_id INTEGER NOT NULL,
              question TEXT NOT NULL,
              answer TEXT,
              difficulty INTEGER DEFAULT 1,
              FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS achievements(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              key TEXT UNIQUE NOT NULL,
              title TEXT NOT NULL,
              description TEXT,
              unlocked_at TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS attachments(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              note_id INTEGER NOT NULL,
              type TEXT NOT NULL,
              path TEXT NOT NULL,
              metadata TEXT,
              created_at TEXT NOT NULL,
              FOREIGN KEY (note_id) REFERENCES notes (id) ON DELETE CASCADE
            )
          ''');
        }
      },
    );
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'is_favorite DESC, updated_at DESC',
    );
    return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'is_favorite DESC, updated_at DESC',
    );
    return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
  }

  @override
  Future<NoteModel> addNote(NoteModel note) async {
    final db = await database;
    final id = await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return NoteModel.fromEntity(note.copyWith(id: id));
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    final db = await database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Projects
  @override
  Future<List<ProjectModel>> getProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ProjectModel.fromMap(maps[i]));
  }

  @override
  Future<void> addProject(ProjectModel project) async {
    final db = await database;
    await db.insert(
      'projects',
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    final db = await database;
    await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  @override
  Future<void> deleteProject(int id) async {
    final db = await database;
    // Set notes associated with this project to null project_id
    await db.update(
      'notes',
      {'project_id': null},
      where: 'project_id = ?',
      whereArgs: [id],
    );
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // Knowledge OS V1 Implementation

  @override
  Future<List<StudyGoalModel>> getStudyGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('study_goals', orderBy: 'created_at DESC');
    
    final List<StudyGoalModel> goals = [];
    for (var map in maps) {
      final stepsMaps = await db.query('study_steps', where: 'goal_id = ?', whereArgs: [map['id']], orderBy: 'position ASC');
      final steps = stepsMaps.map((s) => StudyStepModel.fromMap(s)).toList();
      goals.add(StudyGoalModel.fromMap(map, steps: steps));
    }
    return goals;
  }

  @override
  Future<void> addStudyGoal(StudyGoalModel goal) async {
    final db = await database;
    await db.insert('study_goals', goal.toMap());
  }

  @override
  Future<void> updateStudyGoal(StudyGoalModel goal) async {
    final db = await database;
    await db.update('study_goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  @override
  Future<void> deleteStudyGoal(int id) async {
    final db = await database;
    await db.delete('study_goals', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> addStudyStep(StudyStepModel step) async {
    final db = await database;
    await db.insert('study_steps', step.toMap());
  }

  @override
  Future<void> updateStudyStep(StudyStepModel step) async {
    final db = await database;
    await db.update('study_steps', step.toMap(), where: 'id = ?', whereArgs: [step.id]);
  }

  @override
  Future<void> deleteStudyStep(int id) async {
    final db = await database;
    await db.delete('study_steps', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<KnowledgeConnectionModel>> getConnections() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('knowledge_connections');
    return maps.map((m) => KnowledgeConnectionModel.fromMap(m)).toList();
  }

  @override
  Future<List<KnowledgeConnectionModel>> getNoteConnections(int noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'knowledge_connections',
      where: 'source_id = ? OR target_id = ?',
      whereArgs: [noteId, noteId],
    );
    return maps.map((m) => KnowledgeConnectionModel.fromMap(m)).toList();
  }

  @override
  Future<void> addConnection(KnowledgeConnectionModel connection) async {
    final db = await database;
    await db.insert('knowledge_connections', connection.toMap());
  }

  @override
  Future<void> deleteConnection(int id) async {
    final db = await database;
    await db.delete('knowledge_connections', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<NoteQuestionModel>> getNoteQuestions(int noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('note_questions', where: 'note_id = ?', whereArgs: [noteId]);
    return maps.map((m) => NoteQuestionModel.fromMap(m)).toList();
  }

  @override
  Future<void> addNoteQuestion(NoteQuestionModel question) async {
    final db = await database;
    await db.insert('note_questions', question.toMap());
  }

  @override
  Future<void> updateNoteQuestion(NoteQuestionModel question) async {
    final db = await database;
    await db.update('note_questions', question.toMap(), where: 'id = ?', whereArgs: [question.id]);
  }

  @override
  Future<void> deleteNoteQuestion(int id) async {
    final db = await database;
    await db.delete('note_questions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('achievements');
    return maps.map((m) => AchievementModel.fromMap(m)).toList();
  }

  @override
  Future<void> unlockAchievement(String key) async {
    final db = await database;
    await db.update(
      'achievements',
      {'unlocked_at': DateTime.now().toIso8601String()},
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  @override
  Future<List<AttachmentModel>> getNoteAttachments(int noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('attachments', where: 'note_id = ?', whereArgs: [noteId]);
    return maps.map((m) => AttachmentModel.fromMap(m)).toList();
  }

  @override
  Future<void> addAttachment(AttachmentModel attachment) async {
    final db = await database;
    await db.insert('attachments', attachment.toMap());
  }

  @override
  Future<void> deleteAttachment(int id) async {
    final db = await database;
    await db.delete('attachments', where: 'id = ?', whereArgs: [id]);
  }
}
