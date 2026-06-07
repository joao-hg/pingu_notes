import '../entities/note.dart';
import '../repositories/note_repository.dart';

class ReviewNote {
  final NoteRepository repository;

  ReviewNote(this.repository);

  Future<void> call(Note note) async {
    final now = DateTime.now();
    final newReviewCount = note.reviewCount + 1;
    
    DateTime nextReview;
    switch (newReviewCount) {
      case 1:
        nextReview = now.add(const Duration(days: 1));
        break;
      case 2:
        nextReview = now.add(const Duration(days: 3));
        break;
      case 3:
        nextReview = now.add(const Duration(days: 7));
        break;
      case 4:
        nextReview = now.add(const Duration(days: 15));
        break;
      default:
        nextReview = now.add(const Duration(days: 30));
    }

    int masteryLevel;
    if (newReviewCount == 0) {
      masteryLevel = 0;
    } else if (newReviewCount >= 1 && newReviewCount <= 3) {
      masteryLevel = 1; // Learning
    } else {
      masteryLevel = 2; // Mastered (4+)
    }

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
