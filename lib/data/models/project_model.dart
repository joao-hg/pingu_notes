import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    super.id,
    required super.name,
    super.description,
    super.color,
    required super.createdAt,
    super.isActive,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      color: map['color'] ?? 0xFF2196F3,
      createdAt: DateTime.parse(map['created_at']),
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      color: project.color,
      createdAt: project.createdAt,
      isActive: project.isActive,
    );
  }
}
