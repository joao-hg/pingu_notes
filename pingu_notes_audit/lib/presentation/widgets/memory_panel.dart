import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../pages/note_edit_page.dart';

class MemoryPanel extends StatelessWidget {
  const MemoryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final forgotten = provider.forgottenNotes;
        final stats = provider.dashboardStats;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🧠 Memória & Inteligência',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (forgotten.isNotEmpty) ...[
                const Text(
                  'Notas esquecidas precisando de atenção:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forgotten.length,
                    itemBuilder: (context, index) {
                      final note = forgotten[index];
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            provider.markAsViewed(note);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditPage(note: note),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 0,
                            color: Colors.red.withAlpha(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.red,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    note.title.isEmpty
                                        ? 'Sem título'
                                        : note.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DateTime.now().difference(note.lastViewedAt).inDays} dias sem ver',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                const Card(
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '✅ Sua memória está em dia! Nenhuma nota esquecida.',
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text(
                '🏷️ Assuntos Recorrentes:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: provider.topTags
                    .map(
                      (tag) => Chip(
                        label: Text(
                          '#$tag',
                          style: const TextStyle(fontSize: 10),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  _BrainMetaItem(
                    label: 'Projetos Ativos',
                    value: stats['activeProjects'].toString(),
                    icon: Icons.rocket_launch,
                  ),
                  const SizedBox(width: 8),
                  _BrainMetaItem(
                    label: 'Produtividade',
                    value: stats['totalTasks'] > 0
                        ? '${((stats['completedTasks'] / stats['totalTasks']) * 100).toInt()}%'
                        : '0%',
                    icon: Icons.auto_graph,
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

class _BrainMetaItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BrainMetaItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
