import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/evolution_panel.dart';
import '../widgets/memory_panel.dart';
import '../widgets/pingu_brand.dart';
import 'note_edit_page.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memória & Evolução')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const EvolutionPanel(),
            const Divider(),
            const MemoryPanel(),
            const Divider(),
            Consumer<NoteProvider>(
              builder: (context, provider, child) {
                final due = provider.dueReviews;
                final forgotten = provider.forgottenNotes;
                
                if (due.isEmpty && forgotten.isEmpty) {
                  return const PinguEmptyState(
                    message:
                        'Sua memória está em dia. Nenhuma revisão pendente agora.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (due.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '📚 Pendentes de Revisão:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: due.length,
                        itemBuilder: (context, index) {
                          return NoteCard(
                            note: due[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditPage(note: due[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (forgotten.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '⚠️ Você pode ter esquecido:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: forgotten.length,
                        itemBuilder: (context, index) {
                          return NoteCard(
                            note: forgotten[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditPage(note: forgotten[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
