import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/note_provider.dart';
import '../pages/note_edit_page.dart';
import '../pages/study_page.dart';

class ReviewPanel extends StatelessWidget {
  const ReviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final dueReviews = provider.dueReviews;
        final forgotten = provider.forgottenNotes;

        if (dueReviews.isEmpty && forgotten.isEmpty) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dueReviews.isNotEmpty) ...[
                // Study banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withAlpha(isDark ? 35 : 18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryGreen.withAlpha(isDark ? 80 : 50),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        size: 20,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estudo Espaçado',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            Text(
                              '${dueReviews.length} ${dueReviews.length == 1 ? 'nota pronta' : 'notas prontas'} para revisão',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.primaryGreen.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StudyNowButton(count: dueReviews.length),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (forgotten.isNotEmpty) ...[
                Text(
                  'Você pode ter esquecido',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 88,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: forgotten.length,
                    itemBuilder: (context, index) {
                      final note = forgotten[index];
                      final severity = provider.getNoteSeverity(note);
                      final baseline =
                          note.lastReviewedAt ?? note.createdAt;
                      final days =
                          DateTime.now().difference(baseline).inDays;

                      final color = switch (severity) {
                        'red' => AppColors.danger,
                        'orange' => AppColors.warning,
                        _ => AppColors.categoryStudy,
                      };

                      return Container(
                        width: 176,
                        margin: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditPage(note: note),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withAlpha(isDark ? 28 : 14),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color.withAlpha(isDark ? 70 : 50),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  note.title.isEmpty ? 'Sem título' : note.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Sem revisão há $days dias',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StudyPage()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Estudar',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
