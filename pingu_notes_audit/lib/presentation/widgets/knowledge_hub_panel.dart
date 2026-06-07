import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/knowledge_os_entities.dart';
import '../providers/note_provider.dart';
import 'audio_recorder_widget.dart';

class KnowledgeHubPanel extends StatefulWidget {
  final Note note;

  const KnowledgeHubPanel({super.key, required this.note});

  @override
  State<KnowledgeHubPanel> createState() => _KnowledgeHubPanelState();
}

class _KnowledgeHubPanelState extends State<KnowledgeHubPanel> {
  List<NoteQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    if (widget.note.id == null) return;
    final questions = await context.read<NoteProvider>().getNoteQuestions(widget.note.id!);
    if (mounted) setState(() => _questions = questions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.warmYellow, size: 18),
              const SizedBox(width: 8),
              Text(
                'Hub de Conhecimento',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        // Actions
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ActionButton(
                icon: Icons.psychology_outlined,
                label: 'Gerar Questões',
                onTap: () async {
                  await context.read<NoteProvider>().generateQuestionsForNote(widget.note);
                  _loadData();
                },
              ),
              _ActionButton(
                icon: Icons.map_outlined,
                label: 'Criar Roteiro',
                onTap: () => context.read<NoteProvider>().generateStudyRoadmap(widget.note),
              ),
              _ActionButton(
                icon: Icons.translate,
                label: 'Traduzir (EN)',
                onTap: () => context.read<NoteProvider>().convertNoteStyle(widget.note, 'English'),
              ),
              _ActionButton(
                icon: Icons.summarize_outlined,
                label: 'Resumir',
                onTap: () => context.read<NoteProvider>().convertNoteStyle(widget.note, 'Summary'),
              ),
              const SizedBox(width: 8),
              AudioRecorderWidget(note: widget.note),
            ],
          ),
        ),
        if (_questions.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('❓ Perguntas de Revisão', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._questions.map((q) => _QuestionItem(question: q)),
        ],

        const SizedBox(height: 16),
        const Text('🔗 Sugestões de Estudo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        FutureBuilder<List<String>>(
          future: context.read<NoteProvider>().intelligenceService.getStudySuggestions(widget.note, []),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('Nenhuma sugestão no momento.', style: TextStyle(fontSize: 10));
            return Wrap(
              spacing: 8,
              children: snapshot.data!.map((s) => Chip(
                label: Text(s, style: const TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact,
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 10)),
        onPressed: onTap,
      ),
    );
  }
}

class _QuestionItem extends StatelessWidget {
  final NoteQuestion question;

  const _QuestionItem({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          if (question.answer != null) ...[
            const SizedBox(height: 4),
            Text('A: ${question.answer}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
