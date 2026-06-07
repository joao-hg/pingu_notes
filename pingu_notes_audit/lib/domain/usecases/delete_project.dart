import '../repositories/note_repository.dart';

class DeleteProject {
  final NoteRepository repository;
  DeleteProject(this.repository);
  Future<void> call(int id) async => await repository.deleteProject(id);
}
