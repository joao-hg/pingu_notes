import '../entities/knowledge_os_entities.dart';
import '../entities/study_goal.dart';

abstract class KnowledgeRepository {
  Future<List<StudyGoal>> getStudyGoals();
  Future<void> addStudyGoal(StudyGoal goal);
  Future<void> updateStudyGoal(StudyGoal goal);
  Future<void> deleteStudyGoal(int id);
  
  Future<void> addStudyStep(StudyStep step);
  Future<void> updateStudyStep(StudyStep step);
  Future<void> deleteStudyStep(int id);

  Future<List<KnowledgeConnection>> getConnections();
  Future<List<KnowledgeConnection>> getNoteConnections(int noteId);
  Future<void> addConnection(KnowledgeConnection connection);
  Future<void> deleteConnection(int id);

  Future<List<NoteQuestion>> getNoteQuestions(int noteId);
  Future<void> addNoteQuestion(NoteQuestion question);
  Future<void> updateNoteQuestion(NoteQuestion question);
  Future<void> deleteNoteQuestion(int id);

  Future<List<Achievement>> getAchievements();
  Future<void> unlockAchievement(String key);

  Future<List<Attachment>> getNoteAttachments(int noteId);
  Future<void> addAttachment(Attachment attachment);
  Future<void> deleteAttachment(int id);
}
