import '../entities/project.dart';
import '../repositories/note_repository.dart';

class GetProjects {
  final NoteRepository repository;
  GetProjects(this.repository);
  Future<List<Project>> call() async => await repository.getProjects();
}
