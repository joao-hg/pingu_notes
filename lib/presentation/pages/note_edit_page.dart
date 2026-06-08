import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../widgets/knowledge_hub_panel.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage({super.key, this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  bool _isFavorite = false;
  bool _isTask = false;
  bool _isCompleted = false;
  String _priority = 'medium';
  int? _projectId;
  DateTime? _reminderAt;
  DateTime? _deadline;
  String _category = 'inbox';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _tagsController = TextEditingController(
      text: widget.note?.tags.join(', ') ?? '',
    );
    _isFavorite = widget.note?.isFavorite ?? false;
    _isTask = widget.note?.isTask ?? false;
    _isCompleted = widget.note?.isCompleted ?? false;
    _priority = widget.note?.priority ?? 'medium';
    _projectId = widget.note?.projectId;
    _reminderAt = widget.note?.reminderAt;
    _deadline = widget.note?.deadline;
    _category = widget.note?.category ?? 'inbox';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isReminder) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isReminder ? _reminderAt : _deadline) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          (isReminder ? _reminderAt : _deadline) ?? DateTime.now(),
        ),
      );
      if (time != null) {
        setState(() {
          if (isReminder) {
            _reminderAt = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          } else {
            _deadline = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          }
        });
      }
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (content.isEmpty && title.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id,
      title: title,
      content: content,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      lastViewedAt: now,
      reminderAt: _reminderAt,
      deadline: _deadline,
      isFavorite: _isFavorite,
      isTask: _isTask,
      isCompleted: _isCompleted,
      priority: _priority,
      projectId: _projectId,
      category: _projectId != null || _isTask ? 'organized' : _category,
      tags: tags,
      reviewCount: widget.note?.reviewCount ?? 0,
      lastReviewedAt: widget.note?.lastReviewedAt,
      nextReviewAt: widget.note?.nextReviewAt,
      masteryLevel: widget.note?.masteryLevel ?? 0,
    );

    if (widget.note == null) {
      context.read<NoteProvider>().addNote(note);
    } else {
      context.read<NoteProvider>().updateNote(note);
    }

    Navigator.pop(context);
  }

  void _deleteNote() {
    if (widget.note?.id != null) {
      context.read<NoteProvider>().deleteNote(widget.note!.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
            ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveNote),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.note != null) ...[
                _MasterySection(note: widget.note!),
                const SizedBox(height: 16),
                KnowledgeHubPanel(note: widget.note!),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Título',
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Comece a escrever...',
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fluxo',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'inbox',
                    icon: Icon(Icons.inbox_outlined),
                    label: Text('Inbox'),
                  ),
                  ButtonSegment(
                    value: 'organized',
                    icon: Icon(Icons.auto_stories_outlined),
                    label: Text('Organizada'),
                  ),
                ],
                selected: {_category},
                onSelectionChanged: (selection) {
                  setState(() => _category = selection.first);
                },
              ),
              const SizedBox(height: 12),

              // Task Section
              SwitchListTile(
                title: const Text('Transformar em Tarefa'),
                secondary: const Icon(Icons.check_circle_outline),
                value: _isTask,
                onChanged: (val) => setState(() => _isTask = val),
              ),
              if (_isTask) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text('Prioridade:'),
                            const SizedBox(width: 16),
                            _buildPriorityChip('high', '🔴 Alta'),
                            _buildPriorityChip('medium', '🟡 Média'),
                            _buildPriorityChip('low', '🟢 Baixa'),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: Text(
                          _deadline == null
                              ? 'Definir Prazo'
                              : 'Prazo: ${DateFormat('dd/MM HH:mm').format(_deadline!)}',
                        ),
                        onTap: () => _pickDateTime(false),
                        trailing: _deadline != null
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _deadline = null),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ],

              // Project Section
              Consumer<NoteProvider>(
                builder: (context, provider, child) {
                  return ListTile(
                    leading: const Icon(Icons.rocket_launch_outlined),
                    title: const Text('Projeto'),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: DropdownButton<int?>(
                      value: _projectId,
                      hint: const Text('Nenhum'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Nenhum'),
                        ),
                        ...provider.projects.map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(p.color),
                                  radius: 6,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    p.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _projectId = val),
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(
                  _reminderAt == null
                      ? 'Lembrete'
                      : 'Lembrete: ${DateFormat('dd/MM HH:mm').format(_reminderAt!)}',
                ),
                onTap: () => _pickDateTime(true),
                trailing: _reminderAt != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _reminderAt = null),
                      )
                    : null,
              ),

              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  hintText: 'Tags (separadas por vírgula)',
                  prefixIcon: Icon(Icons.tag),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String value, String label) {
    bool isSelected = _priority == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 10)),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => _priority = value);
        },
      ),
    );
  }
}

class _MasterySection extends StatelessWidget {
  final Note note;

  const _MasterySection({required this.note});

  @override
  Widget build(BuildContext context) {
    final color = switch (note.masteryLevel) {
      2 => Colors.green,
      1 => Colors.amber,
      _ => Colors.red,
    };

    final label = switch (note.masteryLevel) {
      2 => 'Dominada',
      1 => 'Em aprendizado',
      _ => 'Nunca revisada',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${note.reviewCount} revisões completadas',
                  style: TextStyle(color: color.withAlpha(200), fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NoteProvider>().reviewNote(note);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nota revisada com sucesso!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Revisar Agora'),
          ),
        ],
      ),
    );
  }
}