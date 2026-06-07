import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/note_provider.dart';
import 'pingu_brand.dart';

class EvolutionPanel extends StatelessWidget {
  const EvolutionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final stats = provider.knowledgeStats;
        final today = provider.todayStats;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📈 Sua Evolução',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _EvolutionCard(
                      label: 'Criadas Hoje',
                      value: today['createdToday'].toString(),
                      icon: Icons.add_chart_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _EvolutionCard(
                      label: 'Revisadas Hoje',
                      value: today['revisedToday'].toString(),
                      icon: Icons.fact_check_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _MasteryProgressCard(
                mastered: stats['totalMastered'],
                learning: stats['totalLearning'],
                total: stats['totalNotes'],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EvolutionCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _EvolutionCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PinguPaper(
      padding: const EdgeInsets.all(12),
      color: color.withAlpha(20),
      border: BorderSide(color: color.withAlpha(80)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryProgressCard extends StatelessWidget {
  final int mastered;
  final int learning;
  final int total;

  const _MasteryProgressCard({
    required this.mastered,
    required this.learning,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return PinguPaper(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Domínio de Conhecimento',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (mastered > 0)
                    Expanded(
                      flex: mastered,
                      child: Container(color: AppColors.success),
                    ),
                  if (learning > 0)
                    Expanded(
                      flex: learning,
                      child: Container(color: AppColors.warmYellow),
                    ),
                  if (total - mastered - learning > 0)
                    Expanded(
                      flex: total - mastered - learning,
                      child: Container(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  if (total == 0)
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendItem(
                label: 'Dominado',
                color: AppColors.success,
                count: mastered,
              ),
              _LegendItem(
                label: 'Aprendendo',
                color: AppColors.warmYellow,
                count: learning,
              ),
              _LegendItem(
                label: 'Nunca',
                color: Theme.of(context).colorScheme.outlineVariant,
                count: total - mastered - learning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final int count;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
