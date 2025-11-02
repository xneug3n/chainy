import 'package:fl_chart/fl_chart.dart';

/// Statistics data model for streak highlights
class StreakStats {
  final int currentStreak;
  final int bestStreak;
  final String encouragementMessage;

  const StreakStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.encouragementMessage,
  });

  /// Check if statistics are empty
  bool get isEmpty => currentStreak == 0 && bestStreak == 0;
}

/// Statistics data model for week comparison
class WeekComparisonStats {
  final double lastWeekCompletion;
  final double thisWeekCompletion;
  final double improvementPercentage;

  const WeekComparisonStats({
    required this.lastWeekCompletion,
    required this.thisWeekCompletion,
    required this.improvementPercentage,
  });

  /// Check if statistics are empty
  bool get isEmpty => lastWeekCompletion == 0 && thisWeekCompletion == 0;
}

/// Statistics data model for 30-day trend
class ThirtyDayStats {
  final List<FlSpot> dataPoints;
  final double minValue;
  final double maxValue;

  const ThirtyDayStats({
    required this.dataPoints,
    required this.minValue,
    required this.maxValue,
  });

  /// Check if statistics are empty
  bool get isEmpty => dataPoints.isEmpty;
}

/// Heatmap data point for a specific date
class HeatmapDataPoint {
  final DateTime date;
  final int value; // 0-100 representing completion percentage

  const HeatmapDataPoint({
    required this.date,
    required this.value,
  });
}

/// Statistics data model for month heatmap
class MonthHeatmapStats {
  final List<HeatmapDataPoint> heatmapData;

  const MonthHeatmapStats({
    required this.heatmapData,
  });

  /// Check if statistics are empty
  bool get isEmpty => heatmapData.isEmpty;
}

/// Aggregate statistics data containing all dashboard metrics
class AggregateStatistics {
  final StreakStats streakStats;
  final WeekComparisonStats weekComparisonStats;
  final ThirtyDayStats thirtyDayStats;
  final MonthHeatmapStats monthHeatmapStats;

  const AggregateStatistics({
    required this.streakStats,
    required this.weekComparisonStats,
    required this.thirtyDayStats,
    required this.monthHeatmapStats,
  });

  /// Check if all statistics are empty
  bool get isEmpty =>
      streakStats.isEmpty &&
      weekComparisonStats.isEmpty &&
      thirtyDayStats.isEmpty &&
      monthHeatmapStats.isEmpty;
}

