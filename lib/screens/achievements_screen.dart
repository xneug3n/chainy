import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/chainy_colors.dart';

/// Achievements screen showing user accomplishments
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Connect to AchievementProvider when implemented (task 7.3)
    // For now, using empty list as placeholder
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
        // TODO: Replace with actual BadgeCard when AchievementProvider is implemented
        return _buildPlaceholderBadge(context);
      },
    );
  }

  /// Build placeholder badge card (to be replaced with BadgeCard in task 7.2)
  Widget _buildPlaceholderBadge(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Container(
      decoration: BoxDecoration(
        color: ChainyColors.getCard(brightness),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ChainyColors.getBorder(brightness),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ChainyColors.getGray(brightness),
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                color: ChainyColors.getSecondaryText(brightness),
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Badge',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: ChainyColors.getSecondaryText(brightness),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
