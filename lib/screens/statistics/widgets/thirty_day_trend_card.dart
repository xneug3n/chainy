import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/ui/chainy_card.dart';
import '../../../core/theme/chainy_colors.dart';
import '../models/statistics_models.dart';

/// Extension for ThirtyDayStats to add chart data method
extension ThirtyDayStatsExtension on ThirtyDayStats {
  /// Get chart line data for fl_chart with theme colors
  LineChartData getChartData(Brightness brightness) {
    final chartColor = ChainyColors.getAccentBlue(brightness);
    
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 29,
      minY: minValue,
      maxY: maxValue,
      lineBarsData: [
        LineChartBarData(
          spots: dataPoints,
          isCurved: true,
          color: chartColor,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: chartColor.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}

/// Card widget displaying 30-day trend visualization with line chart
class ThirtyDayTrendCard extends StatelessWidget {
  final ThirtyDayStats stats;

  const ThirtyDayTrendCard({
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
            '30-Day Trend',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(stats.getChartData(brightness)),
          ),
        ],
      ),
    );
  }
}

