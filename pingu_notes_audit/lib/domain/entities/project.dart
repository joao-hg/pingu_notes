import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final int? id;
  final String name;
  final String description;
  final int color; // Store color as ARGB int
  final DateTime createdAt;
  final bool isActive;

  const Project({
    this.id,
    required this.name,
    this.description = '',
    this.color = 0xFF2196F3, // Default blue
    required this.createdAt,
    this.isActive = true,
  });

  Project copyWith({
    int? id,
    String? name,
    String? description,
    int? color,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    color,
    createdAt,
    isActive,
  ];
}
