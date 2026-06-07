import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastViewedAt;
  final DateTime? reminderAt;
  final DateTime? deadline;
  final bool isFavorite;
  final bool isTask;
  final bool isCompleted;
  final String priority; // 'high', 'medium', 'low'
  final int? projectId;
  final String category; // 'inbox', 'organized'
  final String? aiSummary;
  final List<String> tags;
  final int reviewCount;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final int masteryLevel; // 0: Never, 1-3: Learning, 4+: Mastered
  final String? audioPath;
  final String? transcription;
  final Map<String, dynamic>? aiAnalysis;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.lastViewedAt,
    this.reminderAt,
    this.deadline,
    this.isFavorite = false,
    this.isTask = false,
    this.isCompleted = false,
    this.priority = 'medium',
    this.projectId,
    this.category = 'inbox',
    this.aiSummary,
    this.tags = const [],
    this.reviewCount = 0,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.masteryLevel = 0,
    this.audioPath,
    this.transcription,
    this.aiAnalysis,
  });

  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastViewedAt,
    DateTime? reminderAt,
    DateTime? deadline,
    bool? isFavorite,
    bool? isTask,
    bool? isCompleted,
    String? priority,
    int? projectId,
    String? category,
    String? aiSummary,
    List<String>? tags,
    int? reviewCount,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    int? masteryLevel,
    String? audioPath,
    String? transcription,
    Map<String, dynamic>? aiAnalysis,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      reminderAt: reminderAt ?? this.reminderAt,
      deadline: deadline ?? this.deadline,
      isFavorite: isFavorite ?? this.isFavorite,
      isTask: isTask ?? this.isTask,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      aiSummary: aiSummary ?? this.aiSummary,
      tags: tags ?? this.tags,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      audioPath: audioPath ?? this.audioPath,
      transcription: transcription ?? this.transcription,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    createdAt,
    updatedAt,
    lastViewedAt,
    reminderAt,
    deadline,
    isFavorite,
    isTask,
    isCompleted,
    priority,
    projectId,
    category,
    aiSummary,
    tags,
    reviewCount,
    lastReviewedAt,
    nextReviewAt,
    masteryLevel,
    audioPath,
    transcription,
    aiAnalysis,
  ];
}
