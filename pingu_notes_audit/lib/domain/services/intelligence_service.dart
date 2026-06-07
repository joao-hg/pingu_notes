import '../entities/note.dart';

abstract class IntelligenceService {
  String summarize(Note note);
  List<String> suggestTags(Note note);
  bool looksLikeTask(Note note);
  List<List<Note>> groupRelatedNotes(List<Note> notes);

  // Knowledge OS V1 - Module 1: Pingu Studies
  Future<List<String>> getStudySuggestions(Note note, List<Note> contextNotes);
  Future<List<String>> getResearchSuggestions(Note note);
  Future<List<String>> getLearningRoadmap(Note note);

  // Knowledge OS V1 - Module 2: Questions
  Future<List<Map<String, String>>> generateQuestions(Note note);

  // Knowledge OS V1 - Module 3: Related Notes
  Future<List<Note>> findRelatedNotes(Note note, List<Note> allNotes);

  // Knowledge OS V1 - Module 4: Pingu Voice
  Future<String> transcribeAudio(String audioPath);
  Future<Map<String, dynamic>> extractIntelligentData(String text);

  // Knowledge OS V1 - Module 5: Converter
  Future<String> translate(String text, String targetLanguage);
  Future<String> convertStyle(String text, String style);

  // Knowledge OS V1 - Module 6: Chat
  Future<String> chatWithNotes(String query, List<Note> notes);

  // Knowledge OS V1 - Module 7: Knowledge Gaps
  Future<List<String>> detectKnowledgeGaps(List<Note> notes);

  // Knowledge OS V1 - Module 11: Intelligent Capture
  Future<Map<String, dynamic>> analyzeImage(String imagePath);
  Future<Map<String, dynamic>> analyzeDocument(String docPath);
}
