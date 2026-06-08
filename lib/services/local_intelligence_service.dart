import 'dart:async';
import '../domain/entities/note.dart';
import '../domain/services/intelligence_service.dart';

class LocalIntelligenceService implements IntelligenceService {
  static const _taskSignals = [
    'fazer', 'comprar', 'ligar', 'enviar', 'resolver', 'pagar', 'marcar', 'revisar',
  ];

  // Domain → related topics knowledge base
  static const _domainSuggestions = {
    'flutter': ['Clean Architecture', 'Riverpod', 'Testes de Widget', 'CI/CD com Flutter'],
    'dart': ['Null Safety', 'Async/Await', 'Streams', 'Generics em Dart'],
    'provider': ['Riverpod', 'Bloc/Cubit', 'GetX'],
    'sqlite': ['Floor (ORM)', 'Drift/Moor', 'Indexação SQL', 'Transações'],
    'python': ['FastAPI', 'Pandas', 'NumPy', 'Testes com pytest'],
    'javascript': ['TypeScript', 'React', 'Node.js', 'Testes com Jest'],
    'typescript': ['Generics', 'Decorators', 'Utility Types', 'Strict Mode'],
    'sql': ['Indexação', 'Joins avançados', 'Normalização', 'Window Functions'],
    'api': ['REST vs GraphQL', 'Autenticação JWT', 'Rate Limiting', 'OpenAPI/Swagger'],
    'git': ['Git Flow', 'Conventional Commits', 'Rebase interativo', 'CI/CD'],
    'docker': ['Kubernetes', 'Docker Compose', 'Multi-stage builds'],
    'react': ['TypeScript', 'Next.js', 'Testing Library', 'Zustand', 'TanStack Query'],
    'java': ['Spring Boot', 'JPA/Hibernate', 'JUnit 5', 'Project Reactor'],
    'kotlin': ['Coroutines', 'Jetpack Compose', 'Hilt', 'Flow'],
    'swift': ['SwiftUI', 'Combine', 'Core Data', 'Swift Concurrency'],
    'linux': ['Bash Scripting', 'Systemd', 'Redes TCP/IP', 'Containers'],
    'machine learning': ['Redes Neurais', 'PyTorch', 'Scikit-learn', 'MLOps'],
    'segurança': ['OWASP Top 10', 'Criptografia', 'Autenticação 2FA', 'SAST/DAST'],
    'design': ['Design System', 'Acessibilidade (a11y)', 'Atomic Design', 'Figma'],
    'agile': ['Scrum', 'Kanban', 'OKRs', 'Shape Up'],
    'banco': ['Índices', 'Query Optimization', 'Replication', 'Sharding'],
    'aws': ['Lambda', 'S3', 'ECS/EKS', 'CloudFormation'],
    'clean architecture': ['SOLID', 'DDD', 'Hexagonal Architecture', 'Use Cases'],
    'solid': ['Dependency Injection', 'Design Patterns', 'Clean Code'],
  };

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

  // --- Knowledge OS: Pingu Studies ---

  @override
  Future<List<String>> getStudySuggestions(Note note, List<Note> contextNotes) async {
    final text = '${note.title} ${note.content}'.toLowerCase();
    final suggestions = <String>{};

    for (final entry in _domainSuggestions.entries) {
      if (text.contains(entry.key)) {
        for (final s in entry.value) {
          if (!text.contains(s.toLowerCase())) suggestions.add(s);
          if (suggestions.length >= 8) break;
        }
      }
    }

    // Fallback: suggestions from tags
    for (final tag in note.tags.take(2)) {
      final tagLower = tag.toLowerCase();
      if (!_domainSuggestions.containsKey(tagLower)) {
        suggestions.add('Casos de uso avançados de $tag');
        suggestions.add('Melhores práticas em $tag');
      }
    }

    // Generic fallback when nothing matches
    if (suggestions.isEmpty && note.content.isNotEmpty) {
      suggestions.add('Conecte esta nota com outras que você tem sobre o mesmo assunto');
      suggestions.add('Crie uma questão de revisão para fixar o conteúdo');
    }

    return suggestions.take(5).toList();
  }

  @override
  Future<List<String>> getResearchSuggestions(Note note) async {
    final title = note.title.isEmpty ? note.content.split(' ').take(3).join(' ') : note.title;
    return [
      'Comparativo: $title vs alternativas',
      'Melhores práticas de $title',
      'Casos de uso reais de $title',
    ];
  }

  @override
  Future<List<String>> getLearningRoadmap(Note note) async {
    final text = '${note.title} ${note.content}'.toLowerCase();
    if (text.contains('flutter') || text.contains('dart')) {
      return ['Dart Basics', 'Widget Tree', 'State Management', 'Persistência', 'Clean Architecture', 'Testes'];
    }
    if (text.contains('python')) {
      return ['Sintaxe Básica', 'POO', 'Bibliotecas Padrão', 'Frameworks Web', 'Testes', 'Deploy'];
    }
    if (text.contains('javascript') || text.contains('typescript')) {
      return ['JS Moderno (ES6+)', 'TypeScript', 'Framework Frontend', 'Node.js', 'Testes', 'CI/CD'];
    }
    final title = note.title.isEmpty ? 'este assunto' : note.title;
    return ['Fundamentos de $title', 'Intermediário', 'Avançado', 'Projetos Práticos', 'Especialista'];
  }

  // --- Knowledge OS: Questions ---

  @override
  Future<List<Map<String, String>>> generateQuestions(Note note) async {
    if (note.content.isEmpty) return [];

    final questions = <Map<String, String>>[];
    final sentences = note.content
        .split(RegExp(r'[.!?\n]'))
        .map((s) => s.trim())
        .where((s) => s.length > 25)
        .toList();

    if (sentences.isNotEmpty) {
      questions.add({
        'question': 'Explique com suas próprias palavras: "${sentences[0].length > 80 ? '${sentences[0].substring(0, 77)}...' : sentences[0]}"',
        'answer': 'Consulte a nota para elaborar a resposta.',
      });
    }

    if (sentences.length > 1) {
      questions.add({
        'question': 'Qual a ideia principal desta nota sobre "${note.title.isEmpty ? 'este assunto' : note.title}"?',
        'answer': summarize(note),
      });
    }

    if (note.tags.isNotEmpty) {
      questions.add({
        'question': 'Como esta nota se relaciona com o tópico #${note.tags[0]}?',
        'answer': 'Use as conexões entre suas notas para elaborar.',
      });
    }

    return questions;
  }

  // --- Knowledge OS: Related Notes ---

  @override
  Future<List<Note>> findRelatedNotes(Note note, List<Note> allNotes) async {
    return allNotes.where((n) {
      if (n.id == note.id) return false;
      final sharedTags = n.tags.any((t) => note.tags.contains(t));
      if (sharedTags) return true;
      // Fallback: keyword overlap in title
      if (note.title.isNotEmpty && n.title.isNotEmpty) {
        final noteWords = note.title.toLowerCase().split(' ').where((w) => w.length >= 4).toSet();
        final nWords = n.title.toLowerCase().split(' ').where((w) => w.length >= 4).toSet();
        return noteWords.intersection(nWords).isNotEmpty;
      }
      return false;
    }).toList();
  }

  // --- Knowledge OS: Pingu Voice ---

  @override
  Future<String> transcribeAudio(String audioPath) async {
    return '';
  }

  @override
  Future<Map<String, dynamic>> extractIntelligentData(String text) async {
    final lower = text.toLowerCase();
    final data = <String, dynamic>{};
    if (lower.contains('lembrar') || lower.contains('estudar') || lower.contains('fazer')) {
      data['task'] = text;
      if (lower.contains('amanhã')) {
        data['date'] = DateTime.now().add(const Duration(days: 1)).toIso8601String();
      }
    }
    return data;
  }

  // --- Knowledge OS: Conversor ---

  @override
  Future<String> translate(String text, String targetLanguage) async {
    return '⚠️ Tradução para $targetLanguage indisponível no modo offline.\n\nOriginal:\n\n$text';
  }

  @override
  Future<String> convertStyle(String text, String style) async {
    final s = style.toLowerCase();
    if (s.contains('summary') || s.contains('resumo')) {
      if (text.length <= 200) return text;
      return '${text.substring(0, 197).trim()}...';
    }
    if (s.contains('flashcard')) {
      final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.length >= 2) {
        return 'PERGUNTA: ${lines[0]}\n\nRESPOSTA: ${lines.sublist(1).join(' ')}';
      }
      return 'PERGUNTA: O que você sabe sobre este assunto?\n\nRESPOSTA: $text';
    }
    if (s.contains('academic') || s.contains('acadêmico')) {
      return 'Este trabalho aborda o seguinte tema: ${text.replaceAll('\n', ' ').trim()}';
    }
    if (s.contains('beginner') || s.contains('iniciante')) {
      return 'De forma simples: ${text.replaceAll('\n', ' ').trim()}';
    }
    return '[$style]:\n\n$text';
  }

  // --- Knowledge OS: Pergunte ao Pingu ---

  @override
  Future<String> chatWithNotes(String query, List<Note> notes) async {
    if (notes.isEmpty) {
      return 'Você ainda não tem notas. Comece capturando suas ideias e voltarei a responder com base no que você sabe!';
    }

    final q = query.toLowerCase().trim();

    // Quantas notas / estatísticas
    if (q.contains('quantas') || q.contains('total') || q.contains('estatística') || q.contains('estatistica')) {
      final mastered = notes.where((n) => n.masteryLevel == 2).length;
      final learning = notes.where((n) => n.masteryLevel == 1).length;
      final tasks = notes.where((n) => n.isTask).length;
      final favorites = notes.where((n) => n.isFavorite).length;
      return 'Suas notas em números:\n\n'
          '📝 ${notes.length} notas no total\n'
          '✅ $mastered dominadas\n'
          '📖 $learning em aprendizado\n'
          '☑️ $tasks tarefas\n'
          '⭐ $favorites favoritas';
    }

    // Assuntos mais estudados / top tags
    if (q.contains('mais estudo') || q.contains('assunto') || q.contains('tópico') || q.contains('topico') || q.contains('tag')) {
      final tags = <String, int>{};
      for (final note in notes) {
        for (final tag in note.tags) {
          tags[tag] = (tags[tag] ?? 0) + 1;
        }
      }
      if (tags.isEmpty) {
        return 'Suas notas ainda não têm tags. Adicione tags para identificar seus assuntos de estudo.';
      }
      final sorted = tags.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.take(5).map((e) => '  #${e.key} — ${e.value} nota(s)').join('\n');
      return 'Seus assuntos mais frequentes:\n\n$top\n\nTotal: ${notes.length} notas.';
    }

    // Notas favoritas
    if (q.contains('favorit')) {
      final favs = notes.where((n) => n.isFavorite).toList();
      if (favs.isEmpty) return 'Você não tem notas favoritas ainda. Marque suas notas mais importantes com ⭐';
      final list = favs.take(5).map((n) => '  📌 ${n.title.isEmpty ? "Sem título" : n.title}').join('\n');
      return 'Suas notas favoritas (${favs.length}):\n\n$list${favs.length > 5 ? '\n  ... e mais ${favs.length - 5}.' : ''}';
    }

    // Notas esquecidas
    if (q.contains('esquec') || q.contains('revisão pendente') || q.contains('revisao pendente')) {
      final now = DateTime.now();
      final forgotten = notes.where((n) {
        final baseline = n.lastReviewedAt ?? n.createdAt;
        return now.difference(baseline).inDays >= 7;
      }).toList();
      if (forgotten.isEmpty) return 'Parabéns! Nenhuma nota esquecida. Sua memória está em dia! 🧠';
      final forgottenList = forgotten.take(3).map((n) {
        final days = now.difference(n.lastReviewedAt ?? n.createdAt).inDays;
        return '  ⚠️ ${n.title.isEmpty ? "Sem título" : n.title} ($days dias)';
      }).join('\n');
      return 'Você tem ${forgotten.length} nota(s) que não revisa há mais de 7 dias.\n\nAlgumas delas:\n$forgottenList';
    }

    // Busca por keyword
    final stopWords = {'que', 'sobre', 'com', 'uma', 'para', 'você', 'sei', 'tem', 'das', 'dos', 'minha', 'minhas', 'sua', 'suas', 'qual', 'quais', 'como', 'onde', 'quando', 'por'};
    final words = q
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^a-záàâãéêíóôõúç0-9]'), ''))
        .where((w) => w.length >= 3 && !stopWords.contains(w))
        .toList();

    if (words.isEmpty) {
      return 'Me pergunte sobre algum assunto das suas notas.\n\nExemplos:\n• "O que sei sobre Flutter?"\n• "Quais assuntos mais estudo?"\n• "Mostre minhas favoritas"';
    }

    final scored = <Note, int>{};
    for (final note in notes) {
      final text = '${note.title} ${note.content} ${note.tags.join(' ')}'.toLowerCase();
      var score = 0;
      for (final w in words) {
        if (text.contains(w)) score++;
        if (note.title.toLowerCase().contains(w)) score += 2; // título vale mais
        if (note.tags.any((t) => t.toLowerCase().contains(w))) score++;
      }
      if (score > 0) scored[note] = score;
    }

    if (scored.isEmpty) {
      return 'Não encontrei notas sobre "${query.trim()}".\n\nQue tal criar uma nota sobre esse assunto?';
    }

    final relevant = scored.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = relevant.take(3).map((e) => e.key).toList();

    final buffer = StringBuffer();
    buffer.writeln('Encontrei ${relevant.length} nota(s) sobre "${query.trim()}":\n');
    for (final note in top) {
      final title = note.title.isEmpty ? 'Sem título' : note.title;
      buffer.writeln('📌 $title');
      if (note.content.isNotEmpty) {
        final preview = note.content.length > 110
            ? '${note.content.substring(0, 107).trim()}...'
            : note.content;
        buffer.writeln('   $preview');
      }
      if (note.tags.isNotEmpty) {
        buffer.writeln('   ${note.tags.map((t) => "#$t").join(' ')}');
      }
      buffer.writeln();
    }
    if (relevant.length > 3) {
      buffer.write('... e mais ${relevant.length - 3} nota(s) relacionada(s).');
    }
    return buffer.toString().trim();
  }

  // --- Knowledge OS: Knowledge Gaps ---

  @override
  Future<List<String>> detectKnowledgeGaps(List<Note> notes) async {
    if (notes.isEmpty) return [];
    final allText = notes.map((n) => '${n.title} ${n.content} ${n.tags.join(' ')}').join(' ').toLowerCase();
    final gaps = <String>[];

    final gapRules = {
      'flutter': ['testes', 'test', 'ci/cd', 'acessibilidade'],
      'python': ['testes', 'pytest', 'type hints', 'async'],
      'sql': ['índice', 'index', 'explain', 'transação'],
      'javascript': ['typescript', 'testes', 'async', 'modulos'],
      'react': ['testes', 'testing library', 'typescript', 'performance'],
      'clean architecture': ['testes unitários', 'dependency injection', 'solid'],
      'docker': ['kubernetes', 'ci/cd', 'segurança'],
    };

    for (final entry in gapRules.entries) {
      if (allText.contains(entry.key)) {
        for (final gap in entry.value) {
          if (!allText.contains(gap)) {
            gaps.add('${entry.key.replaceFirst(entry.key[0], entry.key[0].toUpperCase())}: $gap');
            if (gaps.length >= 5) return gaps;
          }
        }
      }
    }
    return gaps;
  }

  // --- Placeholders for future model integration ---

  @override
  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    return {'summary': 'Análise de imagem indisponível no modo offline.', 'tags': []};
  }

  @override
  Future<Map<String, dynamic>> analyzeDocument(String docPath) async {
    return {'summary': 'Análise de documento indisponível no modo offline.', 'tags': []};
  }
}
