import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/pingu_brand.dart';
import 'note_edit_page.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caixa de Entrada')),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          final notes = provider.inboxNotes;
          if (notes.isEmpty) {
            return const PinguEmptyState(
              message:
                  'Sua caixa de entrada está vazia. Pingu está pronto para guardar a próxima ideia.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return NoteCard(
                note: notes[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoteEditPage(note: notes[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
