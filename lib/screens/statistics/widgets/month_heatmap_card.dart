import 'package:flutter/material.dart';
import '../../../core/ui/chainy_card.dart';
import '../../../core/theme/chainy_colors.dart';
import '../models/statistics_models.dart';

/// Card widget displaying monthly overview with a simple heatmap visualization
/// Note: This is a simplified implementation. A full heatmap calendar library
/// would be integrated in a later iteration.
class MonthHeatmapCard extends StatelessWidget {
  final MonthHeatmapStats stats;

  const MonthHeatmapCard({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Overview',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildSimpleHeatmap(context, brightness),
          const SizedBox(height: 8),
          _buildLegend(context, brightness),
        ],
      ),
    );
  }

  Widget _buildSimpleHeatmap(BuildContext context, Brightness brightness) {
    // Group data by week
    final weeks = <List<HeatmapDataPoint>>[];
    List<HeatmapDataPoint> currentWeek = [];

    for (final point in stats.heatmapData) {
      if (currentWeek.isEmpty) {
        currentWeek.add(point);
      } else {
        final daysDiff = point.date.difference(currentWeek.first.date).inDays;
        if (daysDiff < 7 && currentWeek.length < 7) {
          currentWeek.add(point);
        } else {
          weeks.add(List.from(currentWeek));
          currentWeek = [point];
        }
      }
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...weeks.map(
          (week) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: week.map((point) {
                final opacity = (point.value / 100).clamp(0.1, 1.0);
                return Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: ChainyColors.success.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, Brightness brightness) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final opacity = (index + 1) / 5;
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: ChainyColors.success.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          'More',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

