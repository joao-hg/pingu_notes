import 'dart:convert';
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    required super.lastViewedAt,
    super.reminderAt,
    super.deadline,
    super.isFavorite,
    super.isTask,
    super.isCompleted,
    super.priority,
    super.projectId,
    super.category,
    super.aiSummary,
    super.tags,
    super.reviewCount,
    super.lastReviewedAt,
    super.nextReviewAt,
    super.masteryLevel,
    super.audioPath,
    super.transcription,
    super.aiAnalysis,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      lastViewedAt: map['last_viewed_at'] != null
          ? DateTime.parse(map['last_viewed_at'])
          : DateTime.parse(map['updated_at']),
      reminderAt: map['reminder_at'] != null
          ? DateTime.parse(map['reminder_at'])
          : null,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
      isFavorite: map['is_favorite'] == 1,
      isTask: map['is_task'] == 1,
      isCompleted: map['is_completed'] == 1,
      priority: map['priority'] ?? 'medium',
      projectId: map['project_id'],
      category: map['category'] ?? 'inbox',
      aiSummary: map['ai_summary'],
      tags: (map['tags'] as String?)?.isEmpty ?? true
          ? []
          : (map['tags'] as String).split(','),
      reviewCount: map['review_count'] ?? 0,
      lastReviewedAt: map['last_reviewed_at'] != null
          ? DateTime.parse(map['last_reviewed_at'])
          : null,
      nextReviewAt: map['next_review_at'] != null
          ? DateTime.parse(map['next_review_at'])
          : null,
      masteryLevel: map['mastery_level'] ?? 0,
      audioPath: map['audio_path'],
      transcription: map['transcription'],
      aiAnalysis: map['ai_analysis'] != null
          ? jsonDecode(map['ai_analysis']) as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_viewed_at': lastViewedAt.toIso8601String(),
      'reminder_at': reminderAt?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      'is_task': isTask ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
      'priority': priority,
      'project_id': projectId,
      'category': category,
      'ai_summary': aiSummary,
      'tags': tags.join(','),
      'review_count': reviewCount,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'next_review_at': nextReviewAt?.toIso8601String(),
      'mastery_level': masteryLevel,
      'audio_path': audioPath,
      'transcription': transcription,
      'ai_analysis': aiAnalysis != null ? jsonEncode(aiAnalysis) : null,
    };
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      lastViewedAt: note.lastViewedAt,
      reminderAt: note.reminderAt,
      deadline: note.deadline,
      isFavorite: note.isFavorite,
      isTask: note.isTask,
      isCompleted: note.isCompleted,
      priority: note.priority,
      projectId: note.projectId,
      category: note.category,
      aiSummary: note.aiSummary,
      tags: note.tags,
      reviewCount: note.reviewCount,
      lastReviewedAt: note.lastReviewedAt,
      nextReviewAt: note.nextReviewAt,
      masteryLevel: note.masteryLevel,
      audioPath: note.audioPath,
      transcription: note.transcription,
      aiAnalysis: note.aiAnalysis,
    );
  }
}
