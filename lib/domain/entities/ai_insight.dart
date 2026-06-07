import 'package:equatable/equatable.dart';

class AiInsight extends Equatable {
  final int? id;
  final int? noteId;
  final String type;
  final String value;
  final double confidence;
  final DateTime createdAt;

  const AiInsight({
    this.id,
    this.noteId,
    required this.type,
    required this.value,
    required this.confidence,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, noteId, type, value, confidence, createdAt];
}
