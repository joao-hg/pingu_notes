import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';

class DashboardPanel extends StatelessWidget {
  const DashboardPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final stats = provider.dashboardStats;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 Dashboard Pessoal',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _StatCard(
                    label: 'Notas',
                    value: stats['totalNotes'].toString(),
                    icon: Icons.notes,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    label: 'Tarefas',
                    value: '${stats['completedTasks']}/${stats['totalTasks']}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  _StatCard(
                    label: 'Dominadas',
                    value: stats['totalMastered'].toString(),
                    icon: Icons.auto_awesome_rounded,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    label: 'Em aprendizado',
                    value: stats['totalLearning'].toString(),
                    icon: Icons.psychology_outlined,
                    color: Colors.amber,
                  ),
                  _StatCard(
                    label: 'Taxa de Aprend.',
                    value: '${(stats['learningRate'] * 100).toStringAsFixed(1)}%',
                    icon: Icons.trending_up_rounded,
                    color: Colors.teal,
                  ),
                  _StatCard(
                    label: 'Pendentes',
                    value: stats['dueReviewCount'].toString(),
                    icon: Icons.history_edu_rounded,
                    color: Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _ActiveGoalsSection(),
              const SizedBox(height: 16),
              const _KnowledgeGapsSection(),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveGoalsSection extends StatelessWidget {
  const _ActiveGoalsSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final goals = provider.studyGoals.where((g) => g.status == 'active').take(2).toList();
        if (goals.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎯 Objetivos Ativos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...goals.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(g.title, style: const TextStyle(fontSize: 11)),
                      Text('${(g.progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: g.progress, minHeight: 4, borderRadius: BorderRadius.circular(2)),
                ],
              ),
            )),
          ],
        );
      },
    );
  }
}

class _KnowledgeGapsSection extends StatefulWidget {
  const _KnowledgeGapsSection();

  @override
  State<_KnowledgeGapsSection> createState() => _KnowledgeGapsSectionState();
}

class _KnowledgeGapsSectionState extends State<_KnowledgeGapsSection> {
  late Future<List<String>> _gapsFuture;

  @override
  void initState() {
    super.initState();
    _gapsFuture = context.read<NoteProvider>().getKnowledgeGaps();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _gapsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠️ Lacunas Detectadas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: snapshot.data!.map((gap) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withAlpha(50)),
                ),
                child: Text(gap, style: const TextStyle(fontSize: 10, color: Colors.orange)),
              )).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: color.withAlpha(200)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
