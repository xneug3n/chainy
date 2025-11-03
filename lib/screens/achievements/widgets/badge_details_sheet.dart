import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';
import '../models/achievement_interface.dart';

/// Modal bottom sheet displaying detailed badge information
class BadgeDetailsSheet extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;

  const BadgeDetailsSheet({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final categoryColor = _getCategoryColor(achievement.category, brightness);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: ChainyColors.getCard(brightness),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ChainyColors.getSecondaryText(brightness),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Badge icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked
                      ? categoryColor
                      : ChainyColors.getGray(brightness),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  achievement.icon,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              // Badge title
              Text(
                achievement.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ChainyColors.getPrimaryText(brightness),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Badge description
              Text(
                achievement.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ChainyColors.getSecondaryText(brightness),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Progress indicator (for locked badges)
              if (!isUnlocked && progress > 0.0) ...[
                Text(
                  'Progress: ${(progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ChainyColors.getSecondaryText(brightness),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: ChainyColors.getGray(brightness),
                  valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                ),
                const SizedBox(height: 24),
              ],
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? categoryColor.withValues(alpha: 0.1)
                      : ChainyColors.getGray(brightness).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUnlocked ? 'Unlocked' : 'Locked',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isUnlocked
                        ? categoryColor
                        : ChainyColors.getSecondaryText(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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
}

