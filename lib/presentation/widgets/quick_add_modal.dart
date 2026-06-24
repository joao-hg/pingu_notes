import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
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
  final FocusNode _contentFocus = FocusNode();
  bool _isFavorite = false;
  DateTime? _reminderAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocus.dispose();
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
              date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Note _buildNote() {
    final now = DateTime.now();
    return Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: now,
      updatedAt: now,
      lastViewedAt: now,
      reminderAt: _reminderAt,
      isFavorite: _isFavorite,
    );
  }

  Future<void> _save({bool openEditor = false}) async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    try {
      debugPrint('[EXPANDIR] Salvando nota...');
      final savedNote =
          await context.read<NoteProvider>().addNote(_buildNote());
      debugPrint('[EXPANDIR] Nota criada — ID=${savedNote.id}');
      if (!mounted) return;

      if (openEditor) {
        debugPrint('[EXPANDIR] ID retornado: ${savedNote.id}');
        debugPrint('[EXPANDIR] Navegando para editor');
        // Return the saved note as the modal result — caller handles navigation
        Navigator.pop(context, savedNote);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('[EXPANDIR] ERRO: $e');
      if (mounted) setState(() => _isSaving = false);
    }
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Nova Nota',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (_isSaving)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  TextButton(
                    onPressed: () => _save(openEditor: true),
                    child: Text(
                      'Expandir',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.mutedInk),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _save(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Salvar',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Título (opcional)',
                hintStyle: TextStyle(color: AppColors.mutedInk),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _contentFocus.requestFocus(),
            ),

            // Content
            TextField(
              controller: _contentController,
              focusNode: _contentFocus,
              decoration: const InputDecoration(
                hintText: 'O que você não pode esquecer?',
                border: InputBorder.none,
              ),
              maxLines: null,
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),

            // Action chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: Icon(
                      _isFavorite ? Icons.star : Icons.star_border,
                      size: 16,
                    ),
                    label: Text(_isFavorite ? 'Favorito' : 'Favoritar'),
                    onPressed: () =>
                        setState(() => _isFavorite = !_isFavorite),
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
                        _contentController.text =
                            '${_contentController.text}\n$text'.trim();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
