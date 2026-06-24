import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../widgets/format_toolbar.dart';
import '../widgets/knowledge_hub_panel.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage({super.key, this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  // Persisted note — null until first auto-save
  Note? _savedNote;

  // Metadata state
  bool _isFavorite = false;
  bool _isTask = false;
  bool _isCompleted = false;
  String _priority = 'medium';
  int? _projectId;
  DateTime? _reminderAt;
  DateTime? _deadline;
  String _category = 'inbox';
  String _contentType = 'plain';

  // Auto-save indicators
  Timer? _saveTimer;
  bool _isDirty = false;
  bool _isSaving = false;
  DateTime? _lastSaved;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _savedNote = n;
    _titleController = TextEditingController(text: n?.title ?? '');
    _contentController = TextEditingController(text: n?.content ?? '');
    _tagsController = TextEditingController(text: n?.tags.join(', ') ?? '');
    _isFavorite = n?.isFavorite ?? false;
    _isTask = n?.isTask ?? false;
    _isCompleted = n?.isCompleted ?? false;
    _priority = n?.priority ?? 'medium';
    _projectId = n?.projectId;
    _reminderAt = n?.reminderAt;
    _deadline = n?.deadline;
    _category = n?.category ?? 'inbox';
    _contentType = n?.contentType ?? 'plain';

    _titleController.addListener(_onChanged);
    _contentController.addListener(_onChanged);
    _tagsController.addListener(_onChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (n == null) {
        _titleFocus.requestFocus();
      } else {
        _contentFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _titleController.removeListener(_onChanged);
    _contentController.removeListener(_onChanged);
    _tagsController.removeListener(_onChanged);
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  // ── auto-save ──────────────────────────────────────────────────────────────

  void _onChanged() {
    if (!_isDirty) setState(() => _isDirty = true);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1500), _autoSave);
  }

  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;
    if (!mounted) return;

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final provider = context.read<NoteProvider>();

    try {
      if (_savedNote == null) {
        debugPrint('[AutoSave] Criando nova nota...');
        final saved = await provider.addNote(_buildNote(now));
        debugPrint('[AutoSave] Nota criada — ID=${saved.id}');
        if (mounted) {
          setState(() {
            _savedNote = saved;
            _isSaving = false;
            _lastSaved = now;
            _isDirty = false;
          });
        }
      } else {
        final note = _buildNote(now);
        // Quiet update: does NOT call notifyListeners(), so no global rebuilds
        await provider.updateNoteQuiet(note);
        debugPrint('[AutoSave] Nota atualizada silenciosamente — ID=${note.id}');
        if (mounted) {
          setState(() {
            _savedNote = note;
            _isSaving = false;
            _lastSaved = now;
            _isDirty = false;
          });
        }
      }
    } catch (e) {
      debugPrint('[AutoSave] ERRO: $e');
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Note _buildNote(DateTime now) {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Note(
      id: _savedNote?.id,
      title: title,
      content: content,
      contentType: _contentType,
      createdAt: _savedNote?.createdAt ?? now,
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
      reviewCount: _savedNote?.reviewCount ?? 0,
      lastReviewedAt: _savedNote?.lastReviewedAt,
      nextReviewAt: _savedNote?.nextReviewAt,
      masteryLevel: _savedNote?.masteryLevel ?? 0,
      audioPath: _savedNote?.audioPath,
      transcription: _savedNote?.transcription,
    );
  }

  // ── back / pop ─────────────────────────────────────────────────────────────

  void _handlePop() {
    _saveTimer?.cancel();
    final empty = _titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty;

    if (empty) {
      if (_savedNote?.id != null) {
        context.read<NoteProvider>().deleteNote(_savedNote!.id!);
      }
      Navigator.pop(context);
      return;
    }
    _performSaveAndPop();
  }

  Future<void> _performSaveAndPop() async {
    if (_isDirty) {
      setState(() => _isSaving = true);
      try {
        final note = _buildNote(DateTime.now());
        if (_savedNote == null) {
          await context.read<NoteProvider>().addNote(note);
        } else {
          // Full update on close: refreshes the note list for HomePage
          await context.read<NoteProvider>().updateNote(note);
        }
        debugPrint('[Editor] Nota salva ao fechar — ID=${note.id}');
      } catch (e) {
        debugPrint('[Editor] ERRO ao salvar ao fechar: $e');
      }
    }
    if (mounted) Navigator.pop(context);
  }

  // ── delete ─────────────────────────────────────────────────────────────────

  void _deleteNote() {
    if (_savedNote?.id == null) {
      Navigator.pop(context);
      return;
    }
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deletar nota?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Deletar'),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true && mounted) {
        context.read<NoteProvider>().deleteNote(_savedNote!.id!);
        Navigator.pop(context);
      }
    });
  }

  // ── metadata sheet ─────────────────────────────────────────────────────────

  void _showMetadataSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) {
          void update(VoidCallback fn) {
            setState(fn);
            setSheet(() {});
            _onChanged();
          }

          return _buildMetadataContent(sheetCtx, update);
        },
      ),
    );
  }

  Widget _buildMetadataContent(
      BuildContext sheetCtx, void Function(VoidCallback) update) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(sheetCtx).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.mutedInk.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Detalhes',
                    style: GoogleFonts.poppins(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),

                // ── Tags ──────────────────────────────────────
                _sheetLabel('Tags'),
                TextField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    hintText: 'tag1, tag2, tag3',
                    prefixIcon: Icon(Icons.tag, size: 18),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // ── Category ──────────────────────────────────
                _sheetLabel('Fluxo'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'inbox',
                        icon: Icon(Icons.inbox_outlined),
                        label: Text('Inbox')),
                    ButtonSegment(
                        value: 'organized',
                        icon: Icon(Icons.auto_stories_outlined),
                        label: Text('Organizada')),
                  ],
                  selected: {_category},
                  onSelectionChanged: (s) =>
                      update(() => _category = s.first),
                ),
                const SizedBox(height: 16),

                // ── Task toggle ───────────────────────────────
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tarefa'),
                  secondary: const Icon(Icons.check_circle_outline_rounded),
                  value: _isTask,
                  onChanged: (v) => update(() => _isTask = v),
                ),

                if (_isTask) ...[
                  _sheetLabel('Prioridade'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _priorityChip('high', '🔴 Alta', update),
                      const SizedBox(width: 8),
                      _priorityChip('medium', '🟡 Média', update),
                      const SizedBox(width: 8),
                      _priorityChip('low', '🟢 Baixa', update),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: Text(_deadline == null
                        ? 'Definir prazo'
                        : 'Prazo: ${DateFormat('dd/MM HH:mm').format(_deadline!)}'),
                    onTap: () async {
                      final dt = await _pickDateTime(sheetCtx, _deadline);
                      if (dt != null) update(() => _deadline = dt);
                    },
                    trailing: _deadline != null
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => update(() => _deadline = null))
                        : null,
                  ),
                ],

                // ── Project ───────────────────────────────────
                Consumer<NoteProvider>(
                  builder: (_, provider, _) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.rocket_launch_outlined),
                    title: const Text('Projeto'),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: DropdownButton<int?>(
                        value: _projectId,
                        hint: const Text('Nenhum'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(child: Text('Nenhum')),
                          ...provider.projects.map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Row(children: [
                                CircleAvatar(
                                    backgroundColor: Color(p.color), radius: 5),
                                const SizedBox(width: 6),
                                Flexible(
                                    child: Text(p.name,
                                        overflow: TextOverflow.ellipsis)),
                              ]),
                            ),
                          ),
                        ],
                        onChanged: (v) => update(() => _projectId = v),
                      ),
                    ),
                  ),
                ),

                // ── Reminder ──────────────────────────────────
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alarm_outlined),
                  title: Text(_reminderAt == null
                      ? 'Lembrete'
                      : 'Lembrete: ${DateFormat('dd/MM HH:mm').format(_reminderAt!)}'),
                  onTap: () async {
                    final dt = await _pickDateTime(sheetCtx, _reminderAt);
                    if (dt != null) update(() => _reminderAt = dt);
                  },
                  trailing: _reminderAt != null
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => update(() => _reminderAt = null))
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedInk),
        ),
      );

  Widget _priorityChip(
      String value, String label, void Function(VoidCallback) update) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _priority == value,
      onSelected: (_) => update(() => _priority = value),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext ctx, DateTime? initial) async {
    final date = await showDatePicker(
      context: ctx,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null || !ctx.mounted) return null;
    final time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handlePop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _contentFocus.requestFocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTitleField(isDark),
                      _buildContentField(isDark),
                      if (_savedNote != null) ...[
                        const SizedBox(height: 24),
                        _StudiesSection(note: _savedNote!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            FormatToolbar(
              controller: _contentController,
              onOpenMetadata: _showMetadataSheet,
              onFormatUsed: () {
                if (_contentType == 'plain') {
                  setState(() => _contentType = 'markdown');
                }
                _onChanged();
              },
            ),
            SizedBox(height: bottom),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: _handlePop,
      ),
      titleSpacing: 0,
      title: AnimatedBuilder(
        animation: _titleController,
        builder: (_, _) {
          final t = _titleController.text.trim();
          final label = t.isEmpty
              ? (widget.note == null ? 'Nova nota' : 'Sem título')
              : (t.length > 28 ? '${t.substring(0, 28)}…' : t);
          return Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600));
        },
      ),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_lastSaved != null && !_isDirty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.check_circle_rounded,
                size: 16,
                color: AppColors.primaryGreen.withAlpha(180)),
          ),
        IconButton(
          icon: Icon(
            _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isFavorite ? AppColors.danger : null,
            size: 22,
          ),
          onPressed: () {
            setState(() => _isFavorite = !_isFavorite);
            _onChanged();
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, size: 22),
          onSelected: (v) {
            if (v == 'delete') _deleteNote();
            if (v == 'details') _showMetadataSheet();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(children: [
                Icon(Icons.tune_rounded, size: 18),
                SizedBox(width: 10),
                Text('Detalhes'),
              ]),
            ),
            if (_savedNote != null)
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.danger),
                  SizedBox(width: 10),
                  Text('Deletar',
                      style: TextStyle(color: AppColors.danger)),
                ]),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleField(bool isDark) {
    return TextField(
      controller: _titleController,
      focusNode: _titleFocus,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _contentFocus.requestFocus(),
      decoration: InputDecoration(
        hintText: 'Título',
        hintStyle: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: (isDark ? Colors.white : AppColors.ink).withAlpha(40),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 6),
      ),
      style: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.ink,
      ),
      maxLines: null,
    );
  }

  Widget _buildContentField(bool isDark) {
    return TextField(
      controller: _contentController,
      focusNode: _contentFocus,
      decoration: InputDecoration(
        hintText: 'Comece a escrever…',
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: (isDark ? Colors.white : AppColors.ink).withAlpha(40),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: GoogleFonts.poppins(
        fontSize: 15,
        height: 1.6,
        color: isDark ? Colors.white.withAlpha(220) : AppColors.ink,
      ),
      maxLines: null,
      minLines: 12,
      keyboardType: TextInputType.multiline,
    );
  }
}

// ── Pingu Studies collapsible ──────────────────────────────────────────────

class _StudiesSection extends StatefulWidget {
  final Note note;

  const _StudiesSection({required this.note});

  @override
  State<_StudiesSection> createState() => _StudiesSectionState();
}

class _StudiesSectionState extends State<_StudiesSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 16, color: AppColors.categoryStudy),
                const SizedBox(width: 8),
                const Text(
                  'Pingu Studies',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.categoryStudy),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.mutedInk,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          _MasteryCard(note: widget.note),
          const SizedBox(height: 12),
          KnowledgeHubPanel(note: widget.note),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MasteryCard extends StatelessWidget {
  final Note note;

  const _MasteryCard({required this.note});

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
          Icon(Icons.auto_awesome_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text('${note.reviewCount} revisões',
                    style:
                        TextStyle(color: color.withAlpha(200), fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NoteProvider>().reviewNote(note);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nota revisada!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Revisar'),
          ),
        ],
      ),
    );
  }
}
