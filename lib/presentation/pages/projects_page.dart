import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../domain/entities/project.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/pingu_brand.dart';
import 'note_edit_page.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  void _showAddProject(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = Theme.of(context).colorScheme.primary.toARGB32();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Novo Projeto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Nome do Projeto'),
              ),
              const SizedBox(height: 16),
              const Text('Cor do Projeto'),
              BlockPicker(
                pickerColor: Color(selectedColor),
                onColorChanged: (color) =>
                    setState(() => selectedColor = color.toARGB32()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<NoteProvider>().addProject(
                    Project(
                      name: nameController.text,
                      color: selectedColor,
                      createdAt: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projetos')),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          if (provider.projects.isEmpty) {
            return const PinguEmptyState(
              message:
                  'Nenhum projeto ainda. Agrupe ideias, tarefas e lembretes quando fizer sentido.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              final projectNotes = provider.notes
                  .where((n) => n.projectId == project.id)
                  .toList();

              return ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Color(project.color),
                  radius: 10,
                ),
                title: Text(
                  project.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${projectNotes.length} notas'),
                children: projectNotes
                    .map(
                      (note) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: NoteCard(
                          note: note,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditPage(note: note),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProject(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
