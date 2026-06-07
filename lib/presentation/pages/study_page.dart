import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'note_edit_page.dart';

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Modo Estudo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          final notes = provider.dueReviews;

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 80,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tudo revisado!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Pingu está orgulhoso do seu progresso.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar ao Dashboard'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Você tem ${notes.length} notas para revisar hoje.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _StudyItem(note: note);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudyItem extends StatelessWidget {
  final Note note;

  const _StudyItem({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          NoteCard(
            note: note,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditPage(note: note),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<NoteProvider>().reviewNote(note);
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Marcar como Revisado'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
