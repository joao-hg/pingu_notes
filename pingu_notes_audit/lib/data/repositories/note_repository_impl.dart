import '../../domain/entities/note.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasource/note_local_datasource.dart';
import '../models/note_model.dart';
import '../models/project_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;

  NoteRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Note>> getNotes() async {
    return await localDataSource.getNotes();
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    return await localDataSource.searchNotes(query);
  }

  @override
  Future<Note> addNote(Note note) async {
    return await localDataSource.addNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> updateNote(Note note) async {
    await localDataSource.updateNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(int id) async {
    await localDataSource.deleteNote(id);
  }

  // Projects
  @override
  Future<List<Project>> getProjects() async {
    return await localDataSource.getProjects();
  }

  @override
  Future<void> addProject(Project project) async {
    await localDataSource.addProject(ProjectModel.fromEntity(project));
  }

  @override
  Future<void> updateProject(Project project) async {
    await localDataSource.updateProject(ProjectModel.fromEntity(project));
  }

  @override
  Future<void> deleteProject(int id) async {
    await localDataSource.deleteProject(id);
  }
}
