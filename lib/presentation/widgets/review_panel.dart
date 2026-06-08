import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/note_provider.dart';
import '../pages/note_edit_page.dart';
import '../pages/study_page.dart';
import 'pingu_brand.dart';

class ReviewPanel extends StatelessWidget {
  const ReviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final dueReviews = provider.dueReviews;
        final forgotten = provider.forgottenNotes;

        if (dueReviews.isEmpty && forgotten.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dueReviews.isNotEmpty) ...[
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '📚 Estudo Espaçado',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StudyNowButton(count: dueReviews.length),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (forgotten.isNotEmpty) ...[
                Text(
                  '⚠️ Você pode ter esquecido',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forgotten.length,
                    itemBuilder: (context, index) {
                      final note = forgotten[index];
                      final severity = provider.getForgottenSeverity(note);
                      final baseline = note.lastReviewedAt ?? note.createdAt;
                      final days = DateTime.now().difference(baseline).inDays;

                      Color color;
                      String prefix;
                      switch (severity) {
                        case 'red':
                          color = AppColors.danger;
                          prefix = '🔴';
                          break;
                        case 'orange':
                          color = AppColors.softOrange;
                          prefix = '🟠';
                          break;
                        default:
                          color = AppColors.warmYellow;
                          prefix = '🟡';
                      }

                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteEditPage(note: note),
                              ),
                            );
                          },
                          child: PinguPaper(
                            padding: const EdgeInsets.all(12.0),
                            color: color.withAlpha(20),
                            border: BorderSide(color: color.withAlpha(100)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$prefix ${note.title.isEmpty ? 'Sem título' : note.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sem revisão há $days dias',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: color.withAlpha(200),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StudyNowButton extends StatelessWidget {
  final int count;

  const _StudyNowButton({required this.count});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // We'll implement StudyPage next or just open the first due note
        _startStudySession(context);
      },
      icon: const Icon(Icons.school_outlined, size: 18),
      label: Text('Estudar Agora ($count)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deepOceanBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _startStudySession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudyPage()),
    );
  }
}
