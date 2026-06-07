import '../entities/project.dart';
import '../repositories/note_repository.dart';

class AddProject {
  final NoteRepository repository;
  AddProject(this.repository);
  Future<void> call(Project project) async =>
      await repository.addProject(project);
}
