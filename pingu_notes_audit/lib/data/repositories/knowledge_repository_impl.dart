import '../../domain/entities/knowledge_os_entities.dart';
import '../../domain/entities/study_goal.dart';
import '../../domain/repositories/knowledge_repository.dart';
import '../datasource/note_local_datasource.dart';
import '../models/knowledge_os_models.dart';

class KnowledgeRepositoryImpl implements KnowledgeRepository {
  final NoteLocalDataSource localDataSource;

  KnowledgeRepositoryImpl({required this.localDataSource});

  @override
  Future<List<StudyGoal>> getStudyGoals() async {
    return await localDataSource.getStudyGoals();
  }

  @override
  Future<void> addStudyGoal(StudyGoal goal) async {
    await localDataSource.addStudyGoal(StudyGoalModel(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      progress: goal.progress,
      status: goal.status,
      createdAt: goal.createdAt,
    ));
  }

  @override
  Future<void> updateStudyGoal(StudyGoal goal) async {
    await localDataSource.updateStudyGoal(StudyGoalModel(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      progress: goal.progress,
      status: goal.status,
      createdAt: goal.createdAt,
    ));
  }

  @override
  Future<void> deleteStudyGoal(int id) async {
    await localDataSource.deleteStudyGoal(id);
  }

  @override
  Future<void> addStudyStep(StudyStep step) async {
    await localDataSource.addStudyStep(StudyStepModel(
      id: step.id,
      goalId: step.goalId,
      title: step.title,
      isCompleted: step.isCompleted,
      position: step.position,
    ));
  }

  @override
  Future<void> updateStudyStep(StudyStep step) async {
    await localDataSource.updateStudyStep(StudyStepModel(
      id: step.id,
      goalId: step.goalId,
      title: step.title,
      isCompleted: step.isCompleted,
      position: step.position,
    ));
  }

  @override
  Future<void> deleteStudyStep(int id) async {
    await localDataSource.deleteStudyStep(id);
  }

  @override
  Future<List<KnowledgeConnection>> getConnections() async {
    return await localDataSource.getConnections();
  }

  @override
  Future<List<KnowledgeConnection>> getNoteConnections(int noteId) async {
    return await localDataSource.getNoteConnections(noteId);
  }

  @override
  Future<void> addConnection(KnowledgeConnection connection) async {
    await localDataSource.addConnection(KnowledgeConnectionModel(
      id: connection.id,
      sourceId: connection.sourceId,
      targetId: connection.targetId,
      type: connection.type,
      weight: connection.weight,
    ));
  }

  @override
  Future<void> deleteConnection(int id) async {
    await localDataSource.deleteConnection(id);
  }

  @override
  Future<List<NoteQuestion>> getNoteQuestions(int noteId) async {
    return await localDataSource.getNoteQuestions(noteId);
  }

  @override
  Future<void> addNoteQuestion(NoteQuestion question) async {
    await localDataSource.addNoteQuestion(NoteQuestionModel(
      id: question.id,
      noteId: question.noteId,
      question: question.question,
      answer: question.answer,
      difficulty: question.difficulty,
    ));
  }

  @override
  Future<void> updateNoteQuestion(NoteQuestion question) async {
    await localDataSource.updateNoteQuestion(NoteQuestionModel(
      id: question.id,
      noteId: question.noteId,
      question: question.question,
      answer: question.answer,
      difficulty: question.difficulty,
    ));
  }

  @override
  Future<void> deleteNoteQuestion(int id) async {
    await localDataSource.deleteNoteQuestion(id);
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    return await localDataSource.getAchievements();
  }

  @override
  Future<void> unlockAchievement(String key) async {
    await localDataSource.unlockAchievement(key);
  }

  @override
  Future<List<Attachment>> getNoteAttachments(int noteId) async {
    return await localDataSource.getNoteAttachments(noteId);
  }

  @override
  Future<void> addAttachment(Attachment attachment) async {
    await localDataSource.addAttachment(AttachmentModel(
      id: attachment.id,
      noteId: attachment.noteId,
      type: attachment.type,
      path: attachment.path,
      metadata: attachment.metadata,
      createdAt: attachment.createdAt,
    ));
  }

  @override
  Future<void> deleteAttachment(int id) async {
    await localDataSource.deleteAttachment(id);
  }
}
