import '../entities/note.dart';
import '../repositories/note_repository.dart';

class ReviewNote {
  final NoteRepository repository;

  ReviewNote(this.repository);

  Future<void> call(Note note) async {
    final now = DateTime.now();
    final newReviewCount = note.reviewCount + 1;

    final nextReview = switch (newReviewCount) {
      1 => now.add(const Duration(days: 1)),
      2 => now.add(const Duration(days: 3)),
      3 => now.add(const Duration(days: 7)),
      4 => now.add(const Duration(days: 15)),
      _ => now.add(const Duration(days: 30)),
    };

    // 1–3 reviews: learning; 4+: mastered
    final masteryLevel = newReviewCount <= 3 ? 1 : 2;

    final updatedNote = note.copyWith(
      reviewCount: newReviewCount,
      lastReviewedAt: now,
      nextReviewAt: nextReview,
      masteryLevel: masteryLevel,
      updatedAt: now,
    );

    await repository.updateNote(updatedNote);
  }
}
