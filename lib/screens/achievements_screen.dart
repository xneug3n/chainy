import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/chainy_colors.dart';
import 'achievements/widgets/badge_card.dart';
import 'achievements/controllers/achievement_provider.dart';

/// Achievements screen showing user accomplishments
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: achievementsAsync.when(
        data: (achievements) {
          if (achievements.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildGridView(context, achievements);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: ChainyColors.error),
              const SizedBox(height: 16),
              Text(
                'Error loading achievements',
                style: TextStyle(color: ChainyColors.getPrimaryText(Theme.of(context).brightness)),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(achievementProviderProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
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
  Widget _buildGridView(BuildContext context, List<AchievementWithStatus> achievements) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievementWithStatus = achievements[index];
        return BadgeCard(
          achievement: achievementWithStatus.achievement,
          isUnlocked: achievementWithStatus.isUnlocked,
          progress: achievementWithStatus.progress,
        );
      },
    );
  }
}
