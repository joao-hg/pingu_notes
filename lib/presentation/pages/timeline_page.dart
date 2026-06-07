import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../widgets/pingu_brand.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📅 Evolução do Conhecimento')),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          final notes = provider.notes;
          if (notes.isEmpty) {
            return const PinguEmptyState(message: 'Sua jornada de conhecimento começa com a primeira nota.');
          }

          final grouped = _groupNotesByMonth(notes);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.keys.length,
            itemBuilder: (context, index) {
              final month = grouped.keys.elementAt(index);
              final monthNotes = grouped[month]!;
              return _TimelineMonth(month: month, notes: monthNotes);
            },
          );
        },
      ),
    );
  }

  Map<String, List<Note>> _groupNotesByMonth(List<Note> notes) {
    final Map<String, List<Note>> grouped = {};
    for (var note in notes) {
      final month = DateFormat('MMMM yyyy', 'pt_BR').format(note.createdAt);
      grouped.putIfAbsent(month, () => []).add(note);
    }
    return grouped;
  }
}

class _TimelineMonth extends StatelessWidget {
  final String month;
  final List<Note> notes;

  const _TimelineMonth({required this.month, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            month.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
        ),
        ...notes.map((note) => _TimelineItem(note: note)),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Note note;

  const _TimelineItem({required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(width: 2, height: 20, color: Colors.grey.withAlpha(50)),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 20, color: Colors.grey.withAlpha(50)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(50)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title.isEmpty ? 'Sem título' : note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (note.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      note.tags.map((t) => '#$t').join(' '),
                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
