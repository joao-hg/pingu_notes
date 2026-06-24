import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/note_icon.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = noteIconColor(note);
    final icon = noteIconData(note);
    final dateStr = _formatDate(note.updatedAt);
    final provider = context.read<NoteProvider>();
    final severity = provider.getNoteSeverity(note);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: note.isFavorite
            ? (isDark
                ? AppColors.warning.withAlpha(18)
                : AppColors.warning.withAlpha(12))
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: note.isFavorite
              ? AppColors.warning.withAlpha(80)
              : (isDark ? AppColors.darkBorder : AppColors.cardBorder),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (note.isFavorite ? AppColors.warning : iconColor)
                      .withAlpha(28),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  note.isFavorite ? Icons.star_rounded : icon,
                  color: note.isFavorite ? AppColors.warning : iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title.isEmpty ? 'Sem título' : note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              decoration: note.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (severity == 'red' || severity == 'orange')
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.circle,
                              size: 8,
                              color: severity == 'red'
                                  ? AppColors.danger
                                  : AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                    if (note.content.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        _previewContent(note.content),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white54
                              : AppColors.mutedInk,
                          decoration: note.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: note.tags
                            .take(3)
                            .map((tag) => _TagChip(tag: tag))
                            .toList(),
                      ),
                    ],
                    if (note.isTask) ...[
                      const SizedBox(height: 6),
                      _TaskControls(note: note),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Date + actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : AppColors.mutedInk,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _FavoriteButton(note: note),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _previewContent(String raw) {
    var s = raw;
    s = s.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m[1]!);
    s = s.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m[1]!);
    s = s.replaceAllMapped(RegExp(r'_(.+?)_'), (m) => m[1]!);
    s = s.replaceAll(RegExp(r'```[\s\S]*?```'), '[código]');
    s = s.replaceAllMapped(RegExp(r'`(.+?)`'), (m) => m[1]!);
    s = s.replaceAll(RegExp(r'^- \[x\] ', multiLine: true), '☑ ');
    s = s.replaceAll(RegExp(r'^- \[ \] ', multiLine: true), '☐ ');
    s = s.replaceAll(RegExp(r'^- ', multiLine: true), '• ');
    s = s.replaceAll(RegExp(r'^> ?', multiLine: true), '');
    s = s.replaceAll(RegExp(r'^#{1,6} ', multiLine: true), '');
    s = s.replaceAll(RegExp(r'^\-{3,}$', multiLine: true), '──────');
    return s.trim();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    return DateFormat('dd MMM', 'pt_BR').format(date);
  }
}

class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (textColor, bgColor) = _resolveColors(tag, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  (Color, Color) _resolveColors(String tag, bool isDark) {
    final lower = tag.toLowerCase();
    if (['study', 'estudos', 'estudo', 'revisão'].contains(lower)) {
      return (AppColors.categoryStudy, AppColors.categoryStudy.withAlpha(isDark ? 40 : 22));
    }
    if (['work', 'trabalho', 'projeto', 'project'].contains(lower)) {
      return (AppColors.categoryProject, AppColors.categoryProject.withAlpha(isDark ? 40 : 22));
    }
    if (['personal', 'pessoal'].contains(lower)) {
      return (AppColors.softOrange, AppColors.softOrange.withAlpha(isDark ? 40 : 22));
    }
    if (['audio', 'voz', 'recording'].contains(lower)) {
      return (AppColors.categoryAudio, AppColors.categoryAudio.withAlpha(isDark ? 40 : 22));
    }
    if (['ai', 'ia', 'gpt', 'resumo'].contains(lower)) {
      return (AppColors.categoryAI, AppColors.categoryAI.withAlpha(isDark ? 40 : 22));
    }
    return (
      AppColors.primaryGreen,
      AppColors.primaryGreen.withAlpha(isDark ? 40 : 22),
    );
  }
}

class _TaskControls extends StatelessWidget {
  final Note note;

  const _TaskControls({required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ScaleTransitionCheckbox(note: note),
        if (note.priority != 'medium') ...[
          const SizedBox(width: 6),
          _PriorityDot(priority: note.priority),
        ],
      ],
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final String priority;

  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (priority) {
      'high' => (AppColors.danger, 'Alta'),
      'low' => (AppColors.success, 'Baixa'),
      _ => (AppColors.warning, 'Média'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80), width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final Note note;

  const _FavoriteButton({required this.note});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 1.22 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTap: () async {
          setState(() => _pressed = true);
          await context.read<NoteProvider>().toggleFavorite(widget.note);
          if (mounted) setState(() => _pressed = false);
        },
        child: Icon(
          widget.note.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          size: 18,
          color: widget.note.isFavorite
              ? AppColors.danger
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white38
                  : AppColors.mutedInk.withAlpha(120)),
        ),
      ),
    );
  }
}

class ScaleTransitionCheckbox extends StatefulWidget {
  final Note note;

  const ScaleTransitionCheckbox({super.key, required this.note});

  @override
  State<ScaleTransitionCheckbox> createState() =>
      _ScaleTransitionCheckboxState();
}

class _ScaleTransitionCheckboxState extends State<ScaleTransitionCheckbox> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.86 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Transform.scale(
        scale: 0.85,
        child: Checkbox(
          value: widget.note.isCompleted,
          activeColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (value) async {
            setState(() => _pressed = true);
            await context.read<NoteProvider>().updateNote(
              widget.note.copyWith(
                isCompleted: value ?? false,
                updatedAt: DateTime.now(),
              ),
            );
            if (mounted) setState(() => _pressed = false);
          },
        ),
      ),
    );
  }
}
