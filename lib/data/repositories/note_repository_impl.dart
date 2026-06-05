import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasource/note_local_datasource.dart';
import '../models/note_model.dart';

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
  Future<void> addNote(Note note) async {
    await localDataSource.addNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> updateNote(Note note) async {
    await localDataSource.updateNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(int id) async {
    await localDataSource.deleteNote(id);
  }
}
