import '../entities/project.dart';
import '../repositories/note_repository.dart';

class UpdateProject {
  final NoteRepository repository;
  UpdateProject(this.repository);
  Future<void> call(Project project) async =>
      await repository.updateProject(project);
}
