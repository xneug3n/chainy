import 'package:flutter/material.dart';
import '../../../core/ui/chainy_card.dart';
import '../../../core/theme/chainy_colors.dart';
import '../models/statistics_models.dart';

/// Card widget displaying weekly progress comparison (this week vs. last week)
class WeekComparisonCard extends StatelessWidget {
  final WeekComparisonStats stats;

  const WeekComparisonCard({
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
            'Weekly Progress',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeekColumn(
                context,
                'Last Week',
                stats.lastWeekCompletion,
                brightness,
              ),
              _buildWeekColumn(
                context,
                'This Week',
                stats.thisWeekCompletion,
                brightness,
              ),
            ],
          ),
          if (stats.improvementPercentage > 0) ...[
            const SizedBox(height: 16),
            Text(
              '${stats.improvementPercentage.toStringAsFixed(0)}% improvement! 🎉',
              style: TextStyle(
                color: ChainyColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekColumn(
    BuildContext context,
    String label,
    double percentage,
    Brightness brightness,
  ) {
    final theme = Theme.of(context);
    final clampedPercentage = percentage.clamp(0.0, 100.0);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: clampedPercentage / 100,
            backgroundColor: ChainyColors.getGray(brightness),
            valueColor: AlwaysStoppedAnimation<Color>(
              ChainyColors.getAccentBlue(brightness),
            ),
            strokeWidth: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${clampedPercentage.toStringAsFixed(0)}%',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

