import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/study_goal.dart';
import '../providers/note_provider.dart';
import '../widgets/pingu_brand.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Objetivos de Aprendizado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(context),
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          final goals = provider.studyGoals;
          if (goals.isEmpty) {
            return const PinguEmptyState(
              message: 'Você ainda não definiu objetivos de estudo.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _GoalCard(goal: goal);
            },
          );
        },
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Objetivo'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Ex: Aprender Flutter Clean Arch'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<NoteProvider>().addStudyGoal(StudyGoal(
                  title: titleController.text,
                  createdAt: DateTime.now(),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final StudyGoal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: PinguPaper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                  onPressed: () => context.read<NoteProvider>().deleteStudyGoal(goal.id!),
                ),
              ],
            ),
            if (goal.description != null) ...[
              const SizedBox(height: 4),
              Text(
                goal.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(goal.progress * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
