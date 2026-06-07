import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import 'audio_recorder_widget.dart';

class QuickAddModal extends StatefulWidget {
  const QuickAddModal({super.key});

  @override
  State<QuickAddModal> createState() => _QuickAddModalState();
}

class _QuickAddModalState extends State<QuickAddModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isFavorite = false;
  DateTime? _reminderAt;

  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _reminderAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _save() {
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
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      lastViewedAt: now,
      reminderAt: _reminderAt,
      isFavorite: _isFavorite,
      tags: tags,
    );

    context.read<NoteProvider>().addNote(note);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Nova Nota Inteligente',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _save,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Título (opcional)',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _contentController,
            focusNode: _contentFocusNode,
            decoration: const InputDecoration(
              hintText: 'O que você não pode esquecer?',
              border: InputBorder.none,
            ),
            maxLines: 5,
            minLines: 1,
          ),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              hintText: 'Tags (separadas por vírgula)',
              prefixIcon: Icon(Icons.tag, size: 18),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 14),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  avatar: Icon(
                    _isFavorite ? Icons.star : Icons.star_border,
                    size: 16,
                  ),
                  label: Text(_isFavorite ? 'Favorito' : 'Marcar Favorito'),
                  onPressed: () => setState(() => _isFavorite = !_isFavorite),
                  backgroundColor: _isFavorite
                      ? Colors.amber.withAlpha(50)
                      : null,
                ),
                const SizedBox(width: 8),
                InputChip(
                  avatar: const Icon(Icons.alarm, size: 16),
                  label: Text(
                    _reminderAt == null
                        ? 'Lembrete'
                        : DateFormat('dd/MM HH:mm').format(_reminderAt!),
                  ),
                  onPressed: _pickReminder,
                  onDeleted: _reminderAt != null
                      ? () => setState(() => _reminderAt = null)
                      : null,
                ),
                const SizedBox(width: 8),
                AudioRecorderWidget(
                  onTranscription: (text) {
                    setState(() {
                      _contentController.text = '${_contentController.text}\n$text'.trim();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
