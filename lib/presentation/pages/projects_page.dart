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
    _showProjectDialog(context);
  }

  void _showEditProject(BuildContext context, Project project) {
    _showProjectDialog(context, project: project);
  }

  void _showProjectDialog(BuildContext context, {Project? project}) {
    final nameController = TextEditingController(text: project?.name ?? '');
    int selectedColor = project?.color ?? Theme.of(context).colorScheme.primary.toARGB32();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(project == null ? 'Novo Projeto' : 'Editar Projeto'),
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
                  final provider = context.read<NoteProvider>();
                  if (project == null) {
                    provider.addProject(
                      Project(
                        name: nameController.text,
                        color: selectedColor,
                        createdAt: DateTime.now(),
                      ),
                    );
                  } else {
                    provider.updateProject(
                      project.copyWith(
                        name: nameController.text,
                        color: selectedColor,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(project == null ? 'Criar' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProject(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Projeto?'),
        content: Text('Isso removerá o projeto "${project.name}". As notas não serão excluídas, mas ficarão sem projeto.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<NoteProvider>().deleteProject(project.id!);
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _showEditProject(context, project),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      onPressed: () => _confirmDeleteProject(context, project),
                    ),
                  ],
                ),
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
