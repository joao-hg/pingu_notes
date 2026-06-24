import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/note_provider.dart';

class TodayPanel extends StatelessWidget {
  const TodayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final stats = provider.todayStats;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withAlpha(28),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.today_outlined,
                        color: AppColors.primaryGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Hoje',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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
                      color: AppColors.primaryGreen,
                    ),
                    _TodayStatItem(
                      label: 'Revisadas',
                      value: stats['revisedToday']!,
                      icon: Icons.visibility_outlined,
                      color: AppColors.categoryStudy,
                    ),
                    _TodayStatItem(
                      label: 'Esquecidas',
                      value: stats['forgotten']!,
                      icon: Icons.psychology_outlined,
                      color: AppColors.warning,
                    ),
                    _TodayStatItem(
                      label: 'Favoritas',
                      value: stats['favorites']!,
                      icon: Icons.star_border_rounded,
                      color: AppColors.danger,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
  final Color color;

  const _TodayStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 28 : 16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(isDark ? 60 : 40)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: color.withAlpha(200),
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white54 : AppColors.mutedInk,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: count > 0
                  ? AppColors.primaryGreen.withAlpha(isDark ? 50 : 28)
                  : (isDark ? AppColors.darkBorder : AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: count > 0
                    ? AppColors.primaryGreen
                    : AppColors.mutedInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
