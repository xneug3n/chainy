import 'package:flutter/material.dart';
import '../../../core/ui/chainy_card.dart';
import '../../../core/theme/chainy_colors.dart';
import '../models/statistics_models.dart';

/// Card widget displaying current streak with fire icon and encouragement message
class StreakHighlightCard extends StatelessWidget {
  final StreakStats stats;

  const StreakHighlightCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return ChainyCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current Streak',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: ChainyColors.getOrange(brightness),
                size: 40,
              ),
              const SizedBox(width: 8),
              Text(
                stats.currentStreak.toString(),
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(width: 8),
              Text(
                'days',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stats.encouragementMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

