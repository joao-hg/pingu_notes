import '../../domain/entities/knowledge_os_entities.dart';
import '../../domain/entities/study_goal.dart';

class StudyGoalModel extends StudyGoal {
  const StudyGoalModel({
    super.id,
    required super.title,
    super.description,
    super.progress,
    super.status,
    required super.createdAt,
    super.steps,
  });

  factory StudyGoalModel.fromMap(Map<String, dynamic> map, {List<StudyStep> steps = const []}) {
    return StudyGoalModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      progress: map['progress'] ?? 0.0,
      status: map['status'] ?? 'active',
      createdAt: DateTime.parse(map['created_at']),
      steps: steps,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progress': progress,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class StudyStepModel extends StudyStep {
  const StudyStepModel({
    super.id,
    required super.goalId,
    required super.title,
    super.isCompleted,
    required super.position,
  });

  factory StudyStepModel.fromMap(Map<String, dynamic> map) {
    return StudyStepModel(
      id: map['id'],
      goalId: map['goal_id'],
      title: map['title'],
      isCompleted: map['is_completed'] == 1,
      position: map['position'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'position': position,
    };
  }
}

class KnowledgeConnectionModel extends KnowledgeConnection {
  const KnowledgeConnectionModel({
    super.id,
    required super.sourceId,
    required super.targetId,
    super.type,
    super.weight,
  });

  factory KnowledgeConnectionModel.fromMap(Map<String, dynamic> map) {
    return KnowledgeConnectionModel(
      id: map['id'],
      sourceId: map['source_id'],
      targetId: map['target_id'],
      type: map['type'] ?? 'related',
      weight: map['weight'] ?? 1.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source_id': sourceId,
      'target_id': targetId,
      'type': type,
      'weight': weight,
    };
  }
}

class NoteQuestionModel extends NoteQuestion {
  const NoteQuestionModel({
    super.id,
    required super.noteId,
    required super.question,
    super.answer,
    super.difficulty,
  });

  factory NoteQuestionModel.fromMap(Map<String, dynamic> map) {
    return NoteQuestionModel(
      id: map['id'],
      noteId: map['note_id'],
      question: map['question'],
      answer: map['answer'],
      difficulty: map['difficulty'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'question': question,
      'answer': answer,
      'difficulty': difficulty,
    };
  }
}

class AchievementModel extends Achievement {
  const AchievementModel({
    super.id,
    required super.key,
    required super.title,
    super.description,
    super.unlockedAt,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    return AchievementModel(
      id: map['id'],
      key: map['key'],
      title: map['title'],
      description: map['description'],
      unlockedAt: map['unlocked_at'] != null ? DateTime.parse(map['unlocked_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'description': description,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }
}

class AttachmentModel extends Attachment {
  const AttachmentModel({
    super.id,
    required super.noteId,
    required super.type,
    required super.path,
    super.metadata,
    required super.createdAt,
  });

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      id: map['id'],
      noteId: map['note_id'],
      type: map['type'],
      path: map['path'],
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'type': type,
      'path': path,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
