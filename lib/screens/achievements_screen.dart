import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/chainy_colors.dart';
import 'achievements/widgets/badge_card.dart';
import 'achievements/models/achievement_interface.dart';

/// Achievements screen showing user accomplishments
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Connect to AchievementProvider when implemented (task 7.3)
    // For now, using empty list as placeholder
    // Once provider is available, replace with:
    // final achievements = ref.watch(achievementProviderProvider);
    // return achievements.when(...)
    const achievementCount = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: achievementCount == 0
          ? _buildEmptyState(context)
          : _buildGridView(context, ref, achievementCount),
    );
  }

  /// Build empty state when no achievements exist
  Widget _buildEmptyState(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: ChainyColors.getSecondaryText(brightness),
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: ChainyColors.getPrimaryText(brightness),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete habits to unlock achievements',
            style: TextStyle(
              fontSize: 15,
              color: ChainyColors.getSecondaryText(brightness),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build grid view with achievement badges
  Widget _buildGridView(BuildContext context, WidgetRef ref, int itemCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // TODO: Replace with actual Achievement data from AchievementProvider (task 7.3)
        // Example usage:
        // final achievement = achievements[index];
        // return BadgeCard(
        //   achievement: achievement,
        //   isUnlocked: ref.read(achievementProviderProvider.notifier).isUnlocked(achievement.id),
        //   progress: ref.read(achievementProviderProvider.notifier).getProgress(achievement.id),
        // );
        return _buildPlaceholderBadge(context);
      },
    );
  }

  /// Build placeholder badge card (kept for backward compatibility)
  /// This will be replaced when AchievementProvider provides real data
  Widget _buildPlaceholderBadge(BuildContext context) {
    // Create a placeholder achievement for demonstration
    // This will be removed when real data is available
    const placeholderAchievement = Achievement(
      id: 'placeholder',
      title: 'Badge',
      description: 'Placeholder badge',
      icon: Icons.emoji_events_outlined,
      category: AchievementCategory.firstSteps,
      targetValue: 1,
    );
    
    return BadgeCard(
      achievement: placeholderAchievement,
      isUnlocked: false,
      progress: 0.0,
    );
  }
}
