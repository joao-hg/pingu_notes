import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../data/datasource/note_local_datasource.dart';
import '../data/repositories/note_repository_impl.dart';
import '../data/repositories/knowledge_repository_impl.dart';
import '../domain/repositories/note_repository.dart';
import '../domain/repositories/knowledge_repository.dart';
import '../domain/usecases/add_note.dart';
import '../domain/usecases/delete_note.dart';
import '../domain/usecases/get_notes.dart';
import '../domain/usecases/search_notes.dart';
import '../domain/usecases/update_note.dart';
import '../domain/usecases/get_projects.dart';
import '../domain/usecases/add_project.dart';
import '../domain/usecases/update_project.dart';
import '../domain/usecases/delete_project.dart';
import '../domain/usecases/review_note.dart';
import '../domain/services/intelligence_service.dart';
import 'local_intelligence_service.dart';
import 'notification_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 0. Initialize Database Factory for Desktop
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 1. Data sources
  sl.registerLazySingleton<NoteLocalDataSource>(
    () => NoteLocalDataSourceImpl(),
  );

  // 2. Repositories
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<KnowledgeRepository>(
    () => KnowledgeRepositoryImpl(localDataSource: sl()),
  );

  // 3. Use cases
  sl.registerLazySingleton(() => GetNotes(sl()));
  sl.registerLazySingleton(() => SearchNotes(sl()));
  sl.registerLazySingleton(() => AddNote(sl()));
  sl.registerLazySingleton(() => UpdateNote(sl()));
  sl.registerLazySingleton(() => DeleteNote(sl()));
  sl.registerLazySingleton(() => GetProjects(sl()));
  sl.registerLazySingleton(() => AddProject(sl()));
  sl.registerLazySingleton(() => UpdateProject(sl()));
  sl.registerLazySingleton(() => DeleteProject(sl()));
  sl.registerLazySingleton(() => ReviewNote(sl()));

  // 4. Services
  sl.registerLazySingleton<IntelligenceService>(
    () => LocalIntelligenceService(),
  );
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerSingleton(notificationService);
}
