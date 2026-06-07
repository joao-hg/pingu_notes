import '../entities/note.dart';
import '../entities/project.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<List<Note>> searchNotes(String query);
  Future<Note> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(int id);

  // Projects
  Future<List<Project>> getProjects();
  Future<void> addProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(int id);
}
