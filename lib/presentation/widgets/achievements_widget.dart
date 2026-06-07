import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/knowledge_os_entities.dart';
import '../providers/note_provider.dart';

class AchievementsWidget extends StatelessWidget {
  const AchievementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        final achievements = provider.achievements;
        if (achievements.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '🏆 Conquistas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final a = achievements[index];
                  final isUnlocked = a.unlockedAt != null;
                  return _AchievementBadge(achievement: a, isUnlocked: isUnlocked);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementBadge({required this.achievement, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.warmYellow.withAlpha(50) : Colors.grey.withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked ? AppColors.warmYellow : Colors.grey.withAlpha(100),
                width: 2,
              ),
            ),
            child: Icon(
              _getIcon(achievement.key),
              color: isUnlocked ? AppColors.warmYellow : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              color: isUnlocked ? null : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'streak_7': return Icons.local_fire_department;
      case 'notes_50': return Icons.auto_stories;
      case 'reviews_100': return Icons.psychology;
      case 'first_project': return Icons.emoji_events;
      default: return Icons.star;
    }
  }
}
