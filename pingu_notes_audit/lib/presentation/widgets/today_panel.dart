import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/note_provider.dart';
import 'pingu_brand.dart';

class TodayPanel extends StatelessWidget {
  const TodayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final stats = provider.todayStats;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: PinguPaper(
            color: AppColors.deepOceanBlue,
            border: BorderSide(color: AppColors.iceBlue.withAlpha(70)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.today_outlined, color: AppColors.warmYellow),
                    const SizedBox(width: 8),
                    Text(
                      'Hoje',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.softWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _TodayStatItem(
                      label: 'Criadas',
                      value: stats['createdToday']!,
                      icon: Icons.add_circle_outline,
                    ),
                    _TodayStatItem(
                      label: 'Revisadas',
                      value: stats['revisedToday']!,
                      icon: Icons.visibility_outlined,
                    ),
                    _TodayStatItem(
                      label: 'Esquecidas',
                      value: stats['forgotten']!,
                      icon: Icons.psychology_outlined,
                    ),
                    _TodayStatItem(
                      label: 'Favoritas',
                      value: stats['favorites']!,
                      icon: Icons.star_border_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _TodayLine(
                  icon: Icons.check_circle_outline,
                  label: 'Tarefas para hoje',
                  count: provider.tasksDueToday.length,
                ),
                _TodayLine(
                  icon: Icons.alarm_outlined,
                  label: 'Lembretes de hoje',
                  count: provider.remindersToday.length,
                ),
                _TodayLine(
                  icon: Icons.star_outline_rounded,
                  label: 'Notas importantes',
                  count: provider.importantNotes.length,
                ),
                _TodayLine(
                  icon: Icons.auto_stories_outlined,
                  label: 'Revisões pendentes',
                  count: provider.pendingReviewNotes.length,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TodayStatItem extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _TodayStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.softWhite.withAlpha(18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.iceBlue.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.warmYellow),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.softWhite),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.iceBlue),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _TodayLine({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.iceBlue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.softWhite),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: count > 0
                  ? AppColors.warmYellow
                  : AppColors.softWhite.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: count > 0 ? AppColors.deepOceanBlue : AppColors.iceBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
