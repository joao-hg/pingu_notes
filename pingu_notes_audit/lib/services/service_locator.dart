import 'package:get_it/get_it.dart';
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
  // Services
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerSingleton(notificationService);
  sl.registerLazySingleton<IntelligenceService>(
    () => LocalIntelligenceService(),
  );

  // Use cases
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

  // Repository
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<KnowledgeRepository>(
    () => KnowledgeRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<NoteLocalDataSource>(
    () => NoteLocalDataSourceImpl(),
  );
}
