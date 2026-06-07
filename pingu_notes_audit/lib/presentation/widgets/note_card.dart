import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import 'pingu_brand.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final provider = context.watch<NoteProvider>();
    final severity = provider.getForgottenSeverity(note);
    final review = _reviewStateFromSeverity(severity);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: PinguPaper(
        padding: EdgeInsets.zero,
        color: note.isFavorite
            ? AppColors.warmYellow.withAlpha(48)
            : Theme.of(context).cardTheme.color,
        border: BorderSide(
          color:
              review?.color.withAlpha(170) ??
              (note.isFavorite
                  ? AppColors.warmYellow
                  : Theme.of(context).colorScheme.outlineVariant.withAlpha(90)),
          width: review != null || note.isFavorite ? 1.4 : 1,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.isTask) ...[
                  ScaleTransitionCheckbox(note: note),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (review != null) ...[
                        _ReviewBadge(review: review),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MasteryIndicator(level: note.masteryLevel),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note.title.isEmpty ? 'Sem título' : note.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    decoration: note.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                          ),
                          if (note.isTask) ...[
                            const SizedBox(width: 8),
                            _PriorityBadge(priority: note.priority),
                          ],
                        ],
                      ),
                      if (note.content.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          note.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(190),
                                decoration: note.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                      ],
                      if (note.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: note.tags
                              .map((tag) => _TagPill(tag: tag))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            size: 15,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _footerText(dateFormat),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _FavoriteButton(note: note),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _footerText(DateFormat dateFormat) {
    String text = 'Criada em ${dateFormat.format(note.createdAt)}';
    if (note.reviewCount > 0) {
      text += ' · ${note.reviewCount} revisões';
    }
    return text;
  }

  _ReviewState? _reviewStateFromSeverity(String severity) {
    return switch (severity) {
      'red' => const _ReviewState(
        'Atenção necessária',
        Icons.priority_high_rounded,
        AppColors.danger,
      ),
      'orange' => const _ReviewState(
        'Assunto esquecido',
        Icons.warning_amber_rounded,
        AppColors.softOrange,
      ),
      'yellow' => const _ReviewState(
        'Revisão recomendada',
        Icons.psychology_outlined,
        AppColors.warmYellow,
      ),
      _ => null,
    };
  }
}

class _MasteryIndicator extends StatelessWidget {
  final int level;

  const _MasteryIndicator({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      2 => AppColors.success,
      1 => AppColors.warmYellow,
      _ => AppColors.danger,
    };

    final tooltip = switch (level) {
      2 => 'Dominada',
      1 => 'Em aprendizado',
      _ => 'Nunca revisada',
    };

    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(80),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
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
      scale: _pressed ? .86 : 1,
      duration: const Duration(milliseconds: 120),
      child: Checkbox(
        value: widget.note.isCompleted,
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
      scale: _pressed ? 1.22 : 1,
      duration: const Duration(milliseconds: 160),
      child: IconButton(
        icon: Icon(
          widget.note.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: widget.note.isFavorite
              ? AppColors.danger
              : Theme.of(context).colorScheme.primary,
        ),
        onPressed: () async {
          setState(() => _pressed = true);
          await context.read<NoteProvider>().toggleFavorite(widget.note);
          if (mounted) setState(() => _pressed = false);
        },
      ),
    );
  }
}

class _ReviewBadge extends StatelessWidget {
  final _ReviewState review;

  const _ReviewBadge({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: review.color.withAlpha(40),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(review.icon, size: 14, color: review.color),
          const SizedBox(width: 5),
          Text(
            review.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: review.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (priority) {
      'high' => (AppColors.danger, 'Alta'),
      'low' => (AppColors.success, 'Baixa'),
      _ => (AppColors.softOrange, 'Média'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(110), width: .8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String tag;

  const _TagPill({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Text(
      '#$tag',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ReviewState {
  final String label;
  final IconData icon;
  final Color color;

  const _ReviewState(this.label, this.icon, this.color);
}
