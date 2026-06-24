import 'package:flutter_test/flutter_test.dart';
import 'package:pingu_notes/data/datasource/note_local_datasource.dart';
import 'package:pingu_notes/data/models/note_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:path/path.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late NoteLocalDataSourceImpl dataSource;
  final dbPath = join(Directory.systemTemp.path, 'release_audit_real.db');

  Future<Database> createRealDatabase(String path) async {
    return await openDatabase(
      path,
      version: 11,
      onConfigure: (db) async {
        await db.execute('PRAGMA journal_mode=WAL');
      },
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
            is_favorite INTEGER DEFAULT 0,
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
            ai_analysis TEXT,
            content_type TEXT DEFAULT 'plain'
          )
        ''');
      },
    );
  }

  test('Release Integrity: Massive Content and Sequential Creation', () async {
    if (await File(dbPath).exists()) await File(dbPath).delete();
    final db = await createRealDatabase(dbPath);
    dataSource = NoteLocalDataSourceImpl(database: db);

    // 1. Massive Content
    final massiveText = '🐧' * 25000; 
    final note = NoteModel(
      title: 'Massive Note',
      content: massiveText,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastViewedAt: DateTime.now(),
    );

    final saved = await dataSource.addNote(note);
    expect(saved.id, isNotNull);
    
    final retrieved = await dataSource.getNotes();
    // 🐧 is 2 code units in UTF-16
    expect(retrieved.first.content.length, 50000);

    // 2. Sequential Stress (Realistic)
    for(int i=0; i<50; i++) {
      await dataSource.addNote(NoteModel(
        title: 'Note $i',
        content: 'Integrity Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastViewedAt: DateTime.now(),
      ));
    }
    
    final all = await dataSource.getNotes();
    expect(all.length, 51);

    await db.close();
    if (await File(dbPath).exists()) await File(dbPath).delete();
  }, timeout: const Timeout(Duration(minutes: 1)));
}
