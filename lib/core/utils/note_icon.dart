import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../domain/entities/note.dart';

Color noteIconColor(Note note) {
  if (note.isTask) return AppColors.categoryTask;
  final tags = note.tags.map((t) => t.toLowerCase()).toList();
  if (tags.any((t) => ['audio', 'voz', 'gravação', 'recording'].contains(t))) {
    return AppColors.categoryAudio;
  }
  if (tags.any(
    (t) => ['study', 'estudos', 'estudo', 'aprendizado', 'revisão'].contains(t),
  )) {
    return AppColors.categoryStudy;
  }
  if (tags.any(
    (t) => ['ai', 'ia', 'gpt', 'resumo', 'summary', 'artificial'].contains(t),
  )) {
    return AppColors.categoryAI;
  }
  if (note.projectId != null) return AppColors.categoryProject;
  return AppColors.categoryNote;
}

IconData noteIconData(Note note) {
  if (note.isTask) return Icons.check_circle_outline_rounded;
  final tags = note.tags.map((t) => t.toLowerCase()).toList();
  if (tags.any((t) => ['audio', 'voz', 'gravação', 'recording'].contains(t))) {
    return Icons.graphic_eq_rounded;
  }
  if (tags.any(
    (t) => ['study', 'estudos', 'estudo', 'aprendizado', 'revisão'].contains(t),
  )) {
    return Icons.school_rounded;
  }
  if (tags.any(
    (t) => ['ai', 'ia', 'gpt', 'resumo', 'summary', 'artificial'].contains(t),
  )) {
    return Icons.auto_awesome_rounded;
  }
  if (note.projectId != null) return Icons.folder_rounded;
  return Icons.description_rounded;
}
