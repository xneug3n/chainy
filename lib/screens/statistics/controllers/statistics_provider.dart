import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/app_logger.dart';
import '../../../features/habits/data/habit_repository.dart';
import '../../../features/habits/data/check_in_repository.dart';
import '../../../features/habits/domain/services/streak_service.dart';
import '../models/statistics_models.dart';
import '../services/statistics_calculator.dart';

part 'statistics_provider.g.dart';

/// Provider for aggregate statistics across all habits
@riverpod
class StatisticsProvider extends _$StatisticsProvider {
  @override
  Future<AggregateStatistics> build() async {
    AppLogger.functionEntry('StatisticsProvider.build', tag: 'StatisticsProvider');
    
    try {
      // Create calculator instance with dependencies from Riverpod
      final calculator = StatisticsCalculator(
        habitRepository: ref.read(habitRepositoryProvider.notifier),
        checkInRepository: ref.read(checkInRepositoryProvider.notifier),
        streakService: ref.read(streakServiceProvider.notifier),
      );

      // Calculate all statistics in parallel for better performance
      final results = await Future.wait([
        calculator.calculateStreakStats(),
        calculator.calculateWeekComparison(),
        calculator.calculateThirtyDayTrend(),
        calculator.calculateMonthHeatmap(),
      ]);

      final statistics = AggregateStatistics(
        streakStats: results[0] as StreakStats,
        weekComparisonStats: results[1] as WeekComparisonStats,
        thirtyDayStats: results[2] as ThirtyDayStats,
        monthHeatmapStats: results[3] as MonthHeatmapStats,
      );

      AppLogger.info('Statistics calculated successfully', 
        data: {'isEmpty': statistics.isEmpty},
        tag: 'StatisticsProvider',
      );

      AppLogger.functionExit('StatisticsProvider.build', tag: 'StatisticsProvider');

      return statistics;
    } catch (error, stack) {
      AppLogger.error(
        'Failed to build statistics',
        error: error,
        stackTrace: stack,
        tag: 'StatisticsProvider',
      );
      rethrow;
    }
  }

  /// Refresh statistics
  Future<void> refresh() async {
    AppLogger.debug('Refreshing statistics', tag: 'StatisticsProvider');
    ref.invalidateSelf();
    await future;
  }
}

