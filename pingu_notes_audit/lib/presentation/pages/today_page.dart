import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/pingu_brand.dart';
import 'note_edit_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hoje')),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          final hasContent =
              provider.tasksDueToday.isNotEmpty ||
              provider.remindersToday.isNotEmpty ||
              provider.importantNotes.isNotEmpty ||
              provider.pendingReviewNotes.isNotEmpty;

          if (!hasContent) {
            return const PinguEmptyState(
              message: 'Nada para hoje. Suas ideias continuam bem guardadas.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TodaySection(
                title: 'Tarefas para hoje',
                icon: Icons.check_circle_outline,
                notes: provider.tasksDueToday,
              ),
              _TodaySection(
                title: 'Lembretes de hoje',
                icon: Icons.alarm_outlined,
                notes: provider.remindersToday,
              ),
              _TodaySection(
                title: 'Notas importantes',
                icon: Icons.star_outline_rounded,
                notes: provider.importantNotes.take(8).toList(),
              ),
              _TodaySection(
                title: 'Revisões pendentes',
                icon: Icons.psychology_outlined,
                notes: provider.pendingReviewNotes,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TodaySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Note> notes;

  const _TodaySection({
    required this.title,
    required this.icon,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          ...notes.map(
            (note) => NoteCard(
              note: note,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteEditPage(note: note)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
