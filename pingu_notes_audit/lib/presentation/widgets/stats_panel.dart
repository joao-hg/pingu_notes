import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';

class StatsPanel extends StatelessWidget {
  const StatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 Resumo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatItem(
                    label: 'Total',
                    value: stats['total']!,
                    icon: Icons.notes,
                    color: Colors.blue,
                  ),
                  _StatItem(
                    label: 'Favoritas',
                    value: stats['favorites']!,
                    icon: Icons.favorite,
                    color: Colors.red,
                  ),
                  _StatItem(
                    label: 'Revisão',
                    value: stats['needingReview']!,
                    icon: Icons.info_outline,
                    color: Colors.amber,
                  ),
                  _StatItem(
                    label: 'Esquecidas',
                    value: stats['forgotten']!,
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withAlpha(50)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: color.withAlpha(180)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
