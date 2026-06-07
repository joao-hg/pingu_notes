import 'dart:async';
import '../domain/entities/note.dart';
import '../domain/services/intelligence_service.dart';

class LocalIntelligenceService implements IntelligenceService {
  static const _taskSignals = [
    'fazer', 'comprar', 'ligar', 'enviar', 'resolver', 'pagar', 'marcar', 'revisar',
  ];

  @override
  String summarize(Note note) {
    final text = '${note.title} ${note.content}'.trim();
    if (text.length <= 160) return text;
    return '${text.substring(0, 157).trim()}...';
  }

  @override
  List<String> suggestTags(Note note) {
    final words = '${note.title} ${note.content}'
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9áàâãéêíóôõúç\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length >= 5)
        .toList();

    final frequency = <String, int>{};
    for (final word in words) {
      frequency[word] = (frequency[word] ?? 0) + 1;
    }

    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((entry) => entry.key).take(5).toList();
  }

  @override
  bool looksLikeTask(Note note) {
    final text = '${note.title} ${note.content}'.toLowerCase();
    return _taskSignals.any(text.contains);
  }

  @override
  List<List<Note>> groupRelatedNotes(List<Note> notes) {
    final groups = <String, List<Note>>{};
    for (final note in notes) {
      final key = note.tags.isNotEmpty ? note.tags.first : note.category;
      groups.putIfAbsent(key, () => []).add(note);
    }
    return groups.values.where((group) => group.isNotEmpty).toList();
  }

  // --- Knowledge OS V1 Logic ---

  @override
  Future<List<String>> getStudySuggestions(Note note, List<Note> contextNotes) async {
    // Heuristic: based on common tech stacks or related concepts
    final text = '${note.title} ${note.content}'.toLowerCase();
    final suggestions = <String>[];
    
    if (text.contains('flutter')) {
      if (!text.contains('clean architecture')) suggestions.add('Clean Architecture');
      if (!text.contains('riverpod')) suggestions.add('Riverpod');
      if (!text.contains('unit testing')) suggestions.add('Unit Testing');
    }
    if (text.contains('provider')) suggestions.add('Riverpod');
    if (text.contains('sqlite')) suggestions.add('Floor or Drift (Moor)');
    
    return suggestions.take(5).toList();
  }

  @override
  Future<List<String>> getResearchSuggestions(Note note) async {
    final title = note.title.toLowerCase();
    if (title.isEmpty) return ['Pesquise sobre o assunto desta nota'];
    return [
      'Comparativo: $title vs alternativas',
      'Melhores práticas de $title',
      'Casos de uso avançados para $title',
    ];
  }

  @override
  Future<List<String>> getLearningRoadmap(Note note) async {
    final text = '${note.title} ${note.content}'.toLowerCase();
    if (text.contains('flutter')) {
      return ['Dart Basics', 'Widget Tree', 'State Management', 'Persistence', 'Clean Arch'];
    }
    return ['Básico', 'Intermediário', 'Avançado', 'Especialista'];
  }

  @override
  Future<List<Map<String, String>>> generateQuestions(Note note) async {
    if (note.content.isEmpty) return [];
    
    final questions = <Map<String, String>>[];
    final sentences = note.content.split(RegExp(r'[.!?]')).where((s) => s.trim().length > 20).toList();
    
    if (sentences.isNotEmpty) {
      questions.add({
        'question': 'Sobre o que trata a afirmação: "${sentences[0].trim()}..."?',
        'answer': 'Consulte a nota para mais detalhes.',
      });
    }

    if (note.tags.isNotEmpty) {
      questions.add({
        'question': 'Como esta nota se relaciona com #${note.tags[0]}?',
        'answer': 'A nota está categorizada com esta tag para facilitar a conexão de ideias.',
      });
    }

    return questions;
  }

  @override
  Future<List<Note>> findRelatedNotes(Note note, List<Note> allNotes) async {
    return allNotes.where((n) {
      if (n.id == note.id) return false;
      // Intersection of tags
      return n.tags.any((t) => note.tags.contains(t));
    }).toList();
  }

  @override
  Future<String> transcribeAudio(String audioPath) async {
    // Transcription not available in offline mode
    return '';
  }

  @override
  Future<Map<String, dynamic>> extractIntelligentData(String text) async {
    final lower = text.toLowerCase();
    final data = <String, dynamic>{};
    
    if (lower.contains('lembrar') || lower.contains('estudar')) {
      data['task'] = text;
      if (lower.contains('amanhã')) {
        data['date'] = DateTime.now().add(const Duration(days: 1)).toIso8601String();
      }
    }
    return data;
  }

  @override
  Future<String> translate(String text, String targetLanguage) async {
    return "Nota: Tradução local para $targetLanguage indisponível (Modo Offline). Original:\n\n$text";
  }

  @override
  Future<String> convertStyle(String text, String style) async {
    if (style.toLowerCase().contains('summary') || style.toLowerCase().contains('resumo')) {
      if (text.length <= 160) return text;
      return "${text.substring(0, 157).trim()}...";
    }
    if (style.toLowerCase().contains('flashcard')) {
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.length >= 2) {
        return "PERGUNTA: ${lines[0]}\nRESPOSTA: ${lines.sublist(1).join(' ')}";
      }
    }
    return "[$style]: $text";
  }

  @override
  Future<String> chatWithNotes(String query, List<Note> notes) async {
    // Chat functionality not available in offline mode
    return 'Funcionalidade de chat não disponível no modo offline.';
  }

  @override
  Future<List<String>> detectKnowledgeGaps(List<Note> notes) async {
    final allText = notes.map((n) => '${n.title} ${n.content}').join(' ').toLowerCase();
    final gaps = <String>[];
    if (allText.contains('flutter') && !allText.contains('testes')) gaps.add('Testes Unitários em Flutter');
    if (allText.contains('flutter') && !allText.contains('clean architecture')) gaps.add('Clean Architecture');
    return gaps;
  }

  @override
  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    return {'summary': 'Imagem analisada', 'tags': ['ocr', 'image']};
  }

  @override
  Future<Map<String, dynamic>> analyzeDocument(String docPath) async {
    return {'summary': 'Documento analisado', 'tags': ['doc', 'pdf']};
  }
}
