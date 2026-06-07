import 'package:equatable/equatable.dart';

class StudyGoal extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final double progress; // 0.0 to 1.0
  final String status; // 'active', 'completed', 'paused'
  final DateTime createdAt;
  final List<StudyStep> steps;

  const StudyGoal({
    this.id,
    required this.title,
    this.description,
    this.progress = 0.0,
    this.status = 'active',
    required this.createdAt,
    this.steps = const [],
  });

  StudyGoal copyWith({
    int? id,
    String? title,
    String? description,
    double? progress,
    String? status,
    DateTime? createdAt,
    List<StudyStep>? steps,
  }) {
    return StudyGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      steps: steps ?? this.steps,
    );
  }

  @override
  List<Object?> get props => [id, title, description, progress, status, createdAt, steps];
}

class StudyStep extends Equatable {
  final int? id;
  final int goalId;
  final String title;
  final bool isCompleted;
  final int position;

  const StudyStep({
    this.id,
    required this.goalId,
    required this.title,
    this.isCompleted = false,
    required this.position,
  });

  StudyStep copyWith({
    int? id,
    int? goalId,
    String? title,
    bool? isCompleted,
    int? position,
  }) {
    return StudyStep(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [id, goalId, title, isCompleted, position];
}
