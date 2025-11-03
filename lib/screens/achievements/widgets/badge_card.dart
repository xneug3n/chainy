import 'package:flutter/material.dart';
import '../../../core/ui/chainy_card.dart';
import '../../../core/theme/chainy_colors.dart';
import '../models/achievement_interface.dart';
import 'badge_details_sheet.dart';

/// Badge card widget displaying individual achievement badges
/// Supports locked/unlocked states with progress indicators
class BadgeCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;

  const BadgeCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.progress = 0.0,
  }) : assert(progress >= 0.0 && progress <= 1.0, 'Progress must be between 0.0 and 1.0');

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final categoryColor = _getCategoryColor(achievement.category, brightness);

    return GestureDetector(
      onTap: () => _showBadgeDetails(context),
      child: ChainyCard(
        padding: const EdgeInsets.all(8),
        isElevated: isUnlocked,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBadgeIcon(categoryColor, brightness),
            const SizedBox(height: 8),
            _buildBadgeTitle(brightness),
          ],
        ),
      ),
    );
  }

  /// Build the circular badge icon with progress indicator
  Widget _buildBadgeIcon(Color categoryColor, Brightness brightness) {
    final iconSize = 60.0;
    final iconContainerSize = iconSize;

    return SizedBox(
      width: iconContainerSize,
      height: iconContainerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Badge background circle
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? categoryColor
                  : ChainyColors.getGray(brightness),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              achievement.icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          // Progress indicator overlay (only for locked badges with progress)
          if (!isUnlocked && progress > 0.0)
            SizedBox(
              width: iconSize + 4,
              height: iconSize + 4,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  categoryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build the badge title text
  Widget _buildBadgeTitle(Brightness brightness) {
    return Text(
      achievement.title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.w400,
        color: isUnlocked
            ? ChainyColors.getPrimaryText(brightness)
            : ChainyColors.getSecondaryText(brightness),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Get category color based on achievement category
  Color _getCategoryColor(AchievementCategory category, Brightness brightness) {
    switch (category) {
      case AchievementCategory.firstSteps:
        return ChainyColors.success;
      case AchievementCategory.streakMilestones:
        return ChainyColors.getOrange(brightness);
      case AchievementCategory.habitManagement:
        return ChainyColors.getAccentBlue(brightness);
      case AchievementCategory.checkInMilestones:
        return const Color(0xFFAF52DE); // Purple
      case AchievementCategory.perfection:
        return ChainyColors.error;
      case AchievementCategory.consistency:
        return const Color(0xFF5AC8FA); // Teal
    }
  }

  /// Show badge details in a modal bottom sheet
  void _showBadgeDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BadgeDetailsSheet(
        achievement: achievement,
        isUnlocked: isUnlocked,
        progress: progress,
      ),
    );
  }
}

