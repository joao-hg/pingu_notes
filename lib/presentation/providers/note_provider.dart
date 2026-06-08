import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/update_note.dart';
import '../../domain/usecases/get_projects.dart';
import '../../domain/usecases/add_project.dart';
import '../../domain/usecases/update_project.dart';
import '../../domain/usecases/delete_project.dart';
import '../../domain/usecases/review_note.dart';
import '../../domain/repositories/knowledge_repository.dart';
import '../../domain/services/intelligence_service.dart';
import '../../domain/entities/study_goal.dart';
import '../../domain/entities/knowledge_os_entities.dart';
import '../../services/notification_service.dart';

class NoteProvider with ChangeNotifier {
  final GetNotes getNotesUseCase;
  final SearchNotes searchNotesUseCase;
  final AddNote addNoteUseCase;
  final UpdateNote updateNoteUseCase;
  final DeleteNote deleteNoteUseCase;
  final GetProjects getProjectsUseCase;
  final AddProject addProjectUseCase;
  final UpdateProject updateProjectUseCase;
  final DeleteProject deleteProjectUseCase;
  final ReviewNote reviewNoteUseCase;
  final KnowledgeRepository knowledgeRepository;
  final IntelligenceService intelligenceService;
  final NotificationService notificationService;

  NoteProvider({
    required this.getNotesUseCase,
    required this.searchNotesUseCase,
    required this.addNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.getProjectsUseCase,
    required this.addProjectUseCase,
    required this.updateProjectUseCase,
    required this.deleteProjectUseCase,
    required this.reviewNoteUseCase,
    required this.knowledgeRepository,
    required this.intelligenceService,
    required this.notificationService,
  });

  List<Note> _notes = [];
  List<Project> _projects = [];
  List<StudyGoal> _studyGoals = [];
  List<KnowledgeConnection> _connections = [];
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;
  bool _showOnlyFavorites = false;
  String _currentQuery = '';

  List<Note> get notes {
    List<Note> filtered = List.from(_notes);

    // Intelligent Sorting: Forgotten > Favorites > Recent
    filtered.sort((a, b) {
      final aDays = DateTime.now().difference(a.lastViewedAt).inDays;
      final bDays = DateTime.now().difference(b.lastViewedAt).inDays;

      final aIsForgotten = aDays >= 7;
      final bIsForgotten = bDays >= 7;

      if (aIsForgotten && !bIsForgotten) return -1;
      if (!aIsForgotten && bIsForgotten) return 1;
      if (aIsForgotten && bIsForgotten) {
        return bDays.compareTo(aDays);
      }

      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;

      return b.updatedAt.compareTo(a.updatedAt);
    });

    if (_showOnlyFavorites) {
      filtered = filtered.where((n) => n.isFavorite).toList();
    }
    return filtered;
  }

  List<Project> get projects => _projects;
  List<StudyGoal> get studyGoals => _studyGoals;
  List<KnowledgeConnection> get connections => _connections;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showOnlyFavorites => _showOnlyFavorites;

  List<Note> get inboxNotes =>
      _notes.where((n) => n.category == 'inbox').toList();

  List<Note> get tasksDueToday =>
      _notes.where((n) {
        return n.isTask &&
            !n.isCompleted &&
            _isSameDay(n.deadline, DateTime.now());
      }).toList()..sort(
        (a, b) =>
            _priorityRank(a.priority).compareTo(_priorityRank(b.priority)),
      );

  List<Note> get remindersToday =>
      _notes.where((n) {
        return _isSameDay(n.reminderAt, DateTime.now());
      }).toList()..sort((a, b) {
        final aReminder = a.reminderAt ?? a.updatedAt;
        final bReminder = b.reminderAt ?? b.updatedAt;
        return aReminder.compareTo(bReminder);
      });

  List<Note> get importantNotes => _notes.where((n) {
    return n.isFavorite || (n.isTask && n.priority == 'high' && !n.isCompleted);
  }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Note> get dueReviews {
    final now = DateTime.now();
    return _notes.where((n) {
      if (n.nextReviewAt == null) return now.difference(n.createdAt).inDays >= 1;
      return n.nextReviewAt!.isBefore(now);
    }).toList()..sort((a, b) {
      if (a.nextReviewAt == null && b.nextReviewAt == null) return 0;
      if (a.nextReviewAt == null) return -1;
      if (b.nextReviewAt == null) return 1;
      return a.nextReviewAt!.compareTo(b.nextReviewAt!);
    });
  }

  List<Note> get masteredNotes =>
      _notes.where((n) => n.masteryLevel == 2).toList();

  List<Note> get learningNotes =>
      _notes.where((n) => n.masteryLevel == 1).toList();

  List<Note> get neverReviewedNotes =>
      _notes.where((n) => n.masteryLevel == 0).toList();

  List<Note> get pendingReviewNotes => dueReviews;

  List<Note> get todayNotes {
    final now = DateTime.now();
    return _notes.where((n) {
      return _isSameDay(n.deadline, now) ||
          _isSameDay(n.reminderAt, now) ||
          n.isFavorite ||
          (n.nextReviewAt != null && n.nextReviewAt!.isBefore(now));
    }).toList();
  }

  List<String> get allTags {
    final tags = <String, int>{};
    for (var note in _notes) {
      for (var tag in note.tags) {
        tags[tag] = (tags[tag] ?? 0) + 1;
      }
    }
    return tags.keys.toList()..sort();
  }

  List<String> get topTags {
    final tags = <String, int>{};
    for (var note in _notes) {
      for (var tag in note.tags) {
        tags[tag] = (tags[tag] ?? 0) + 1;
      }
    }
    var sorted = tags.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).take(5).toList();
  }

  Map<String, dynamic> get dashboardStats {
    final now = DateTime.now();
    int totalNotes = _notes.length;
    int totalTasks = _notes.where((n) => n.isTask).length;
    int completedTasks = _notes.where((n) => n.isTask && n.isCompleted).length;
    int activeProjects = _projects.where((p) => p.isActive).length;
    int pendingReminders = _notes
        .where((n) => n.reminderAt != null && n.reminderAt!.isAfter(now))
        .length;

    // Knowledge stats
    int totalMastered = _notes.where((n) => n.masteryLevel == 2).length;
    int totalLearning = _notes.where((n) => n.masteryLevel == 1).length;
    int totalNever = _notes.where((n) => n.masteryLevel == 0).length;
    int dueReviewCount = dueReviews.length;
    int forgottenCount = forgottenNotes.length;
    
    double learningRate = totalNotes == 0 ? 0 : (totalMastered / totalNotes);

    return {
      'totalNotes': totalNotes,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'activeProjects': activeProjects,
      'pendingReminders': pendingReminders,
      'totalMastered': totalMastered,
      'totalLearning': totalLearning,
      'totalNever': totalNever,
      'dueReviewCount': dueReviewCount,
      'forgottenCount': forgottenCount,
      'learningRate': learningRate,
    };
  }

  Map<String, dynamic> get knowledgeStats => dashboardStats;

  Map<String, int> get stats {
    return {
      'total': _notes.length,
      'favorites': _notes.where((n) => n.isFavorite).length,
      'needingReview': dueReviews.length,
      'forgotten': forgottenNotes.length,
      'mastered': masteredNotes.length,
    };
  }

  Map<String, int> get todayStats {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int createdToday = _notes.where((n) {
      final c = n.createdAt;
      return DateTime(c.year, c.month, c.day).isAtSameMomentAs(today);
    }).length;

    int revisedToday = _notes.where((n) {
      if (n.lastReviewedAt == null) return false;
      final v = n.lastReviewedAt!;
      return DateTime(v.year, v.month, v.day).isAtSameMomentAs(today);
    }).length;

    int forgotten = forgottenNotes.length;
    int favorites = _notes.where((n) => n.isFavorite).length;

    return {
      'createdToday': createdToday,
      'revisedToday': revisedToday,
      'forgotten': forgotten,
      'favorites': favorites,
    };
  }

  List<Note> get recentNotes {
    final recent = List<Note>.from(_notes);
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(5).toList();
  }

  List<Note> get recentlyUpdatedNotes {
    final recent = List<Note>.from(_notes);
    recent.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return recent.take(5).toList();
  }

  List<Note> get forgottenNotes {
    final now = DateTime.now();
    return _notes.where((n) {
      final baseline = n.lastReviewedAt ?? n.createdAt;
      final days = now.difference(baseline).inDays;
      return days >= 7;
    }).toList()..sort((a, b) {
      final aBaseline = a.lastReviewedAt ?? a.createdAt;
      final bBaseline = b.lastReviewedAt ?? b.createdAt;
      return bBaseline.compareTo(aBaseline);
    });
  }

  String getForgottenSeverity(Note note) {
    final now = DateTime.now();
    final baseline = note.lastReviewedAt ?? note.createdAt;
    final days = now.difference(baseline).inDays;
    
    if (days >= 30) return 'red';
    if (days >= 15) return 'orange';
    if (days >= 7) return 'yellow';
    return 'none';
  }

  Future<void> reviewNote(Note note) async {
    try {
      await reviewNoteUseCase(note);
      await searchNotes(_currentQuery);
      await _checkReviewAchievements();
    } catch (e) {
      _error = e.toString();
      debugPrint('[NoteProvider.reviewNote] $e');
      notifyListeners();
    }
  }

  // --- Knowledge OS V1 Methods ---

  Future<void> addStudyGoal(StudyGoal goal) async {
    await knowledgeRepository.addStudyGoal(goal);
    _studyGoals = await knowledgeRepository.getStudyGoals();
    notifyListeners();
  }

  Future<void> updateStudyGoal(StudyGoal goal) async {
    await knowledgeRepository.updateStudyGoal(goal);
    _studyGoals = await knowledgeRepository.getStudyGoals();
    notifyListeners();
  }

  Future<void> deleteStudyGoal(int id) async {
    await knowledgeRepository.deleteStudyGoal(id);
    _studyGoals = await knowledgeRepository.getStudyGoals();
    notifyListeners();
  }

  Future<void> generateStudyRoadmap(Note note) async {
    final roadmap = await intelligenceService.getLearningRoadmap(note);
    final goal = StudyGoal(
      title: 'Aprender: ${note.title}',
      description: 'Roteiro: ${roadmap.join(" -> ")}',
      createdAt: DateTime.now(),
    );
    await addStudyGoal(goal);
  }

  Future<void> generateQuestionsForNote(Note note) async {
    final questions = await intelligenceService.generateQuestions(note);
    for (var q in questions) {
      await knowledgeRepository.addNoteQuestion(NoteQuestion(
        noteId: note.id!,
        question: q['question']!,
        answer: q['answer'],
      ));
    }
  }

  Future<List<NoteQuestion>> getNoteQuestions(int noteId) async {
    return await knowledgeRepository.getNoteQuestions(noteId);
  }

  Future<void> transcribeNoteAudio(Note note, String audioPath) async {
    if (audioPath.isEmpty) return;
    final transcription = await intelligenceService.transcribeAudio(audioPath);
    final intelligentData = await intelligenceService.extractIntelligentData(transcription);
    
    final updatedNote = note.copyWith(
      audioPath: audioPath,
      transcription: transcription,
      content: '${note.content}\n\n[Transcrição]:\n$transcription',
    );
    await updateNote(updatedNote);

    if (intelligentData.containsKey('task')) {
      // Logic to auto-create task or reminder could go here
    }
  }

  Future<void> convertNoteStyle(Note note, String style) async {
    final converted = await intelligenceService.convertStyle(note.content, style);
    final updatedNote = note.copyWith(
      content: converted,
      aiAnalysis: {
        ...(note.aiAnalysis ?? {}),
        'lastStyleConversion': style,
        'originalContent': note.content,
      },
    );
    await updateNote(updatedNote);
  }

  Future<String> chatWithNotes(String query) async {
    return await intelligenceService.chatWithNotes(query, _notes);
  }

  Future<List<String>> getKnowledgeGaps() async {
    return await intelligenceService.detectKnowledgeGaps(_notes);
  }

  Future<void> unlockAchievement(String key) async {
    await knowledgeRepository.unlockAchievement(key);
    _achievements = await knowledgeRepository.getAchievements();
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notes = await getNotesUseCase();
      _projects = await getProjectsUseCase();
      _studyGoals = await knowledgeRepository.getStudyGoals();
      _connections = await knowledgeRepository.getConnections();
      _achievements = await knowledgeRepository.getAchievements();
    } catch (e) {
      _error = e.toString();
      debugPrint('[NoteProvider] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNotes() async {
    try {
      _notes = await getNotesUseCase();
    } catch (e) {
      _error = e.toString();
      debugPrint('[NoteProvider.loadNotes] $e');
    }
    notifyListeners();
  }

  Future<void> searchNotes(String query) async {
    _currentQuery = query;
    if (query.isEmpty) {
      await loadNotes();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _notes = await searchNotesUseCase(query);
    } catch (e) {
      _error = e.toString();
      debugPrint('[NoteProvider.searchNotes] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleShowOnlyFavorites() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  Future<void> markAsViewed(Note note) async {
    final updatedNote = note.copyWith(lastViewedAt: DateTime.now());
    await updateNote(updatedNote);
  }

  Future<void> addNote(Note note) async {
    try {
      final savedNote = await addNoteUseCase(note);
      _scheduleNoteNotifications(savedNote);
      await searchNotes(_currentQuery);
      await _checkNoteCountAchievements();
    } catch (e) {
      _error = e.toString();
      debugPrint('[NoteProvider.addNote] $e');
      notifyListeners();
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await updateNoteUseCase(note);
      if (note.id != null) {
        await notificationService.cancelNoteNotifications(note.id!);
        _scheduleNoteNotifications(note);
      }
      await searchNotes(_currentQuery);
    } catch (e) {
      _error = e.toString();
      debugPrint('[NoteProvider.updateNote] $e');
      notifyListeners();
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await deleteNoteUseCase(id);
      await notificationService.cancelNoteNotifications(id);
      await searchNotes(_currentQuery);
    } catch (e) {
      _error = e.toString();
      debugPrint('[NoteProvider.deleteNote] $e');
      notifyListeners();
    }
  }

  void _scheduleNoteNotifications(Note note) {
    if (note.id == null) return;

    if (note.reminderAt != null) {
      notificationService.scheduleNotification(
        id: notificationService.notificationId(
          note.id!,
          PinguNotificationType.reminder,
        ),
        title: '⏰ Lembrete: ${note.title.isEmpty ? "Nota" : note.title}',
        body: note.content.length > 50
            ? '${note.content.substring(0, 47)}...'
            : note.content,
        scheduledDate: note.reminderAt!,
        type: PinguNotificationType.reminder,
      );
    }

    notificationService.scheduleNotification(
      id: notificationService.notificationId(
        note.id!,
        PinguNotificationType.review,
      ),
      title: '📌 Revisar nota',
      body: note.title.isEmpty
          ? 'Pingu separou uma nota para revisão.'
          : note.title,
      scheduledDate: note.lastViewedAt.add(const Duration(days: 3)),
      type: PinguNotificationType.review,
    );

    notificationService.scheduleNotification(
      id: notificationService.notificationId(
        note.id!,
        PinguNotificationType.memory,
      ),
      title: '🧠 Não Me Deixe Esquecer',
      body: note.title.isEmpty
          ? 'Essa ideia merece voltar para sua atenção.'
          : note.title,
      scheduledDate: note.lastViewedAt.add(const Duration(days: 7)),
      type: PinguNotificationType.memory,
    );
  }

  Future<void> _checkNoteCountAchievements() async {
    final count = _notes.length;
    if (count >= 1) await unlockAchievement('first_note');
    if (count >= 10) await unlockAchievement('notes_10');
    if (count >= 50) await unlockAchievement('notes_50');
  }

  Future<void> _checkReviewAchievements() async {
    final total = _notes.fold<int>(0, (sum, n) => sum + n.reviewCount);
    if (total >= 10) await unlockAchievement('reviews_10');
    if (total >= 100) await unlockAchievement('reviews_100');
  }

  // Projects CRUD
  Future<void> addProject(Project project) async {
    await addProjectUseCase(project);
    _projects = await getProjectsUseCase();
    notifyListeners();
    if (_projects.length == 1) await unlockAchievement('first_project');
  }

  Future<void> updateProject(Project project) async {
    await updateProjectUseCase(project);
    _projects = await getProjectsUseCase();
    notifyListeners();
  }

  Future<void> deleteProject(int id) async {
    await deleteProjectUseCase(id);
    _projects = await getProjectsUseCase();
    await loadNotes(); // Reload notes because project association changed
  }

  Future<void> toggleFavorite(Note note) async {
    final updatedNote = note.copyWith(
      isFavorite: !note.isFavorite,
      updatedAt: DateTime.now(),
    );
    await updateNote(updatedNote);
  }

  bool _isSameDay(DateTime? value, DateTime day) {
    if (value == null) return false;
    return value.year == day.year &&
        value.month == day.month &&
        value.day == day.day;
  }

  int _priorityRank(String priority) {
    return switch (priority) {
      'high' => 0,
      'medium' => 1,
      'low' => 2,
      _ => 1,
    };
  }
}
