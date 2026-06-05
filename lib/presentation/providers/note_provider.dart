import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/update_note.dart';

class NoteProvider with ChangeNotifier {
  final GetNotes getNotesUseCase;
  final SearchNotes searchNotesUseCase;
  final AddNote addNoteUseCase;
  final UpdateNote updateNoteUseCase;
  final DeleteNote deleteNoteUseCase;

  NoteProvider({
    required this.getNotesUseCase,
    required this.searchNotesUseCase,
    required this.addNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  });

  List<Note> _notes = [];
  List<Note> get notes => _notes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    _notes = await getNotesUseCase();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchNotes(String query) async {
    if (query.isEmpty) {
      await loadNotes();
      return;
    }
    _isLoading = true;
    notifyListeners();
    _notes = await searchNotesUseCase(query);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await addNoteUseCase(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await updateNoteUseCase(note);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await deleteNoteUseCase(id);
    await loadNotes();
  }

  Future<void> toggleFavorite(Note note) async {
    final updatedNote = note.copyWith(
      isFavorite: !note.isFavorite,
      updatedAt: DateTime.now(),
    );
    await updateNote(updatedNote);
  }
}
