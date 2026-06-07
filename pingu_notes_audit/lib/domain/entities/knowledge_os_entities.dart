import 'package:equatable/equatable.dart';

class KnowledgeConnection extends Equatable {
  final int? id;
  final int sourceId;
  final int targetId;
  final String type; // 'related', 'prerequisite', 'dependency'
  final double weight;

  const KnowledgeConnection({
    this.id,
    required this.sourceId,
    required this.targetId,
    this.type = 'related',
    this.weight = 1.0,
  });

  @override
  List<Object?> get props => [id, sourceId, targetId, type, weight];
}

class NoteQuestion extends Equatable {
  final int? id;
  final int noteId;
  final String question;
  final String? answer;
  final int difficulty; // 1-5

  const NoteQuestion({
    this.id,
    required this.noteId,
    required this.question,
    this.answer,
    this.difficulty = 1,
  });

  @override
  List<Object?> get props => [id, noteId, question, answer, difficulty];
}

class Achievement extends Equatable {
  final int? id;
  final String key;
  final String title;
  final String? description;
  final DateTime? unlockedAt;

  const Achievement({
    this.id,
    required this.key,
    required this.title,
    this.description,
    this.unlockedAt,
  });

  @override
  List<Object?> get props => [id, key, title, description, unlockedAt];
}

class Attachment extends Equatable {
  final int? id;
  final int noteId;
  final String type; // 'audio', 'image', 'document'
  final String path;
  final String? metadata;
  final DateTime createdAt;

  const Attachment({
    this.id,
    required this.noteId,
    required this.type,
    required this.path,
    this.metadata,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, noteId, type, path, metadata, createdAt];
}
