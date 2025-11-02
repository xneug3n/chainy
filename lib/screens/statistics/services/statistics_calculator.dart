import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/app_logger.dart';
import '../../../features/habits/data/habit_repository.dart';
import '../../../features/habits/data/check_in_repository.dart';
import '../../../features/habits/domain/models/habit.dart';
import '../../../features/habits/domain/models/check_in.dart';
import '../../../features/habits/domain/services/streak_service.dart';
import '../models/statistics_models.dart';

/// Service for calculating aggregate statistics across all habits
class StatisticsCalculator {
  final HabitRepository habitRepository;
  final CheckInRepository checkInRepository;
  final StreakService streakService;

  StatisticsCalculator({
    required this.habitRepository,
    required this.checkInRepository,
    required this.streakService,
  });

  /// Calculate aggregate streak statistics across all habits
  Future<StreakStats> calculateStreakStats() async {
    AppLogger.functionEntry('StatisticsCalculator.calculateStreakStats', tag: 'StatisticsCalculator');
    
    try {
      final habits = await habitRepository.getAllHabits();
      
      if (habits.isEmpty) {
        AppLogger.debug('No habits found, returning empty streak stats', tag: 'StatisticsCalculator');
        return const StreakStats(
          currentStreak: 0,
          bestStreak: 0,
          encouragementMessage: 'Create your first habit to start tracking streaks!',
        );
      }

      int aggregateCurrentStreak = 0;
      int aggregateBestStreak = 0;

      for (final habit in habits) {
        final currentStreak = await streakService.getCurrentStreak(habit.id);
        final longestStreak = await streakService.getLongestStreak(habit.id);

        // For aggregate, we take the average or max - using max for motivation
        aggregateCurrentStreak = aggregateCurrentStreak > currentStreak 
            ? aggregateCurrentStreak 
            : currentStreak;
        aggregateBestStreak = aggregateBestStreak > longestStreak 
            ? aggregateBestStreak 
            : longestStreak;
      }

      final encouragementMessage = _getEncouragementMessage(aggregateCurrentStreak);

      AppLogger.info('Streak stats calculated', 
        data: {
          'currentStreak': aggregateCurrentStreak,
          'bestStreak': aggregateBestStreak,
          'habitsCount': habits.length,
        },
        tag: 'StatisticsCalculator',
      );

      AppLogger.functionExit('StatisticsCalculator.calculateStreakStats', 
        result: {'currentStreak': aggregateCurrentStreak, 'bestStreak': aggregateBestStreak},
        tag: 'StatisticsCalculator');

      return StreakStats(
        currentStreak: aggregateCurrentStreak,
        bestStreak: aggregateBestStreak,
        encouragementMessage: encouragementMessage,
      );
    } catch (error, stack) {
      AppLogger.error(
        'Failed to calculate streak stats',
        error: error,
        stackTrace: stack,
        tag: 'StatisticsCalculator',
      );
      rethrow;
    }
  }

  /// Calculate week comparison statistics
  Future<WeekComparisonStats> calculateWeekComparison() async {
    AppLogger.functionEntry('StatisticsCalculator.calculateWeekComparison', tag: 'StatisticsCalculator');
    
    try {
      final now = DateTime.now();
      final thisWeekStart = _getWeekStart(now);
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
      final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

      final habits = await habitRepository.getAllHabits();
      
      if (habits.isEmpty) {
        AppLogger.debug('No habits found, returning empty week comparison', tag: 'StatisticsCalculator');
        return const WeekComparisonStats(
          lastWeekCompletion: 0,
          thisWeekCompletion: 0,
          improvementPercentage: 0,
        );
      }

      double thisWeekTotal = 0;
      double lastWeekTotal = 0;
      int thisWeekExpected = 0;
      int lastWeekExpected = 0;

      for (final habit in habits) {
        // Count expected completions for this week
        final thisWeekDays = _getDaysInWeekRange(thisWeekStart, now);
        thisWeekExpected += thisWeekDays.length;

        // Count expected completions for last week
        final lastWeekDays = _getDaysInWeekRange(lastWeekStart, lastWeekEnd);
        lastWeekExpected += lastWeekDays.length;

        // Count actual completions
        for (final day in thisWeekDays) {
          final checkIn = await checkInRepository.getCheckInForHabitOnDate(habit.id, day);
          if (checkIn != null && _isGoalMet(habit, checkIn)) {
            thisWeekTotal++;
          }
        }

        for (final day in lastWeekDays) {
          final checkIn = await checkInRepository.getCheckInForHabitOnDate(habit.id, day);
          if (checkIn != null && _isGoalMet(habit, checkIn)) {
            lastWeekTotal++;
          }
        }
      }

      final thisWeekCompletion = thisWeekExpected > 0 
          ? (thisWeekTotal / thisWeekExpected) * 100 
          : 0.0;
      final lastWeekCompletion = lastWeekExpected > 0 
          ? (lastWeekTotal / lastWeekExpected) * 100 
          : 0.0;

      final improvementPercentage = lastWeekCompletion > 0
          ? ((thisWeekCompletion - lastWeekCompletion) / lastWeekCompletion) * 100
          : (thisWeekCompletion > 0 ? 100.0 : 0.0);

      AppLogger.info('Week comparison calculated',
        data: {
          'thisWeekCompletion': thisWeekCompletion,
          'lastWeekCompletion': lastWeekCompletion,
          'improvementPercentage': improvementPercentage,
        },
        tag: 'StatisticsCalculator',
      );

      AppLogger.functionExit('StatisticsCalculator.calculateWeekComparison', tag: 'StatisticsCalculator');

      return WeekComparisonStats(
        lastWeekCompletion: lastWeekCompletion,
        thisWeekCompletion: thisWeekCompletion,
        improvementPercentage: improvementPercentage,
      );
    } catch (error, stack) {
      AppLogger.error(
        'Failed to calculate week comparison',
        error: error,
        stackTrace: stack,
        tag: 'StatisticsCalculator',
      );
      rethrow;
    }
  }

  /// Calculate 30-day trend statistics
  Future<ThirtyDayStats> calculateThirtyDayTrend() async {
    AppLogger.functionEntry('StatisticsCalculator.calculateThirtyDayTrend', tag: 'StatisticsCalculator');
    
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final habits = await habitRepository.getAllHabits();
      
      if (habits.isEmpty) {
        AppLogger.debug('No habits found, returning empty trend', tag: 'StatisticsCalculator');
        return const ThirtyDayStats(
          dataPoints: [],
          minValue: 0,
          maxValue: 100,
        );
      }

      // Aggregate daily completion percentages
      final Map<DateTime, int> dailyCompletions = {};
      final Map<DateTime, int> dailyExpected = {};

      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = DateTime(date.year, date.month, date.day);
        dailyCompletions[dateKey] = 0;
        dailyExpected[dateKey] = habits.length; // Each habit expected once per day
      }

      // Count actual completions
      for (final habit in habits) {
        final checkIns = await checkInRepository.getCheckInsByDateRange(
          habit.id,
          thirtyDaysAgo,
          now,
        );

        for (final checkIn in checkIns) {
          final dateKey = DateTime(
            checkIn.date.year,
            checkIn.date.month,
            checkIn.date.day,
          );
          
          if (dailyCompletions.containsKey(dateKey) && _isGoalMet(habit, checkIn)) {
            dailyCompletions[dateKey] = (dailyCompletions[dateKey] ?? 0) + 1;
          }
        }
      }

      // Convert to FlSpot data points (most recent = index 0)
      final dataPoints = <FlSpot>[];
      double minValue = 100;
      double maxValue = 0;

      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: 29 - i)); // Reverse order (oldest first)
        final dateKey = DateTime(date.year, date.month, date.day);
        final completions = dailyCompletions[dateKey] ?? 0;
        final expected = dailyExpected[dateKey] ?? habits.length;
        final percentage = expected > 0 ? (completions / expected) * 100 : 0.0;

        dataPoints.add(FlSpot(i.toDouble(), percentage));

        if (percentage < minValue) minValue = percentage;
        if (percentage > maxValue) maxValue = percentage;
      }

      // Ensure min/max have some range for chart visualization
      if (minValue == maxValue) {
        if (maxValue == 0) {
          maxValue = 100;
        } else {
          minValue = (minValue - 10).clamp(0, 100);
          maxValue = (maxValue + 10).clamp(0, 100);
        }
      }

      AppLogger.info('30-day trend calculated',
        data: {
          'dataPointsCount': dataPoints.length,
          'minValue': minValue,
          'maxValue': maxValue,
        },
        tag: 'StatisticsCalculator',
      );

      AppLogger.functionExit('StatisticsCalculator.calculateThirtyDayTrend', tag: 'StatisticsCalculator');

      return ThirtyDayStats(
        dataPoints: dataPoints,
        minValue: minValue,
        maxValue: maxValue,
      );
    } catch (error, stack) {
      AppLogger.error(
        'Failed to calculate 30-day trend',
        error: error,
        stackTrace: stack,
        tag: 'StatisticsCalculator',
      );
      rethrow;
    }
  }

  /// Calculate month heatmap statistics
  Future<MonthHeatmapStats> calculateMonthHeatmap() async {
    AppLogger.functionEntry('StatisticsCalculator.calculateMonthHeatmap', tag: 'StatisticsCalculator');
    
    try {
      final now = DateTime.now();
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      final habits = await habitRepository.getAllHabits();
      
      if (habits.isEmpty) {
        AppLogger.debug('No habits found, returning empty heatmap', tag: 'StatisticsCalculator');
        return const MonthHeatmapStats(heatmapData: []);
      }

      final heatmapData = <HeatmapDataPoint>[];

      // Generate data for each day in the current month
      for (int day = 1; day <= monthEnd.day; day++) {
        final date = DateTime(now.year, now.month, day);
        
        // Skip future dates
        if (date.isAfter(now)) break;

        int completions = 0;
        int expected = habits.length;

        // Count completions for this day across all habits
        for (final habit in habits) {
          final checkIn = await checkInRepository.getCheckInForHabitOnDate(habit.id, date);
          if (checkIn != null && _isGoalMet(habit, checkIn)) {
            completions++;
          }
        }

        final percentage = expected > 0 ? (completions / expected) * 100 : 0;
        final value = percentage.round().clamp(0, 100);

        heatmapData.add(HeatmapDataPoint(
          date: date,
          value: value,
        ));
      }

      AppLogger.info('Month heatmap calculated',
        data: {
          'dataPointsCount': heatmapData.length,
          'month': now.month,
          'year': now.year,
        },
        tag: 'StatisticsCalculator',
      );

      AppLogger.functionExit('StatisticsCalculator.calculateMonthHeatmap', tag: 'StatisticsCalculator');

      return MonthHeatmapStats(heatmapData: heatmapData);
    } catch (error, stack) {
      AppLogger.error(
        'Failed to calculate month heatmap',
        error: error,
        stackTrace: stack,
        tag: 'StatisticsCalculator',
      );
      rethrow;
    }
  }

  /// Check if a check-in meets the habit's goal
  bool _isGoalMet(Habit habit, CheckIn checkIn) {
    switch (habit.goalType) {
      case GoalType.binary:
        return checkIn.value >= 1;
      case GoalType.quantitative:
        return checkIn.value >= habit.targetValue;
    }
  }

  /// Get the start of the week (Monday)
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    final daysFromMonday = weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }

  /// Get all days in a week range
  List<DateTime> _getDaysInWeekRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = start;
    while (!current.isAfter(end)) {
      days.add(DateTime(current.year, current.month, current.day));
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  /// Get encouragement message based on streak
  String _getEncouragementMessage(int streak) {
    if (streak == 0) {
      return 'Start your streak today!';
    } else if (streak < 7) {
      return 'Keep going! You\'re building momentum.';
    } else if (streak < 30) {
      return 'Great job! You\'re forming a strong habit.';
    } else if (streak < 100) {
      return 'Amazing! You\'re on fire! 🔥';
    } else {
      return 'Incredible! You\'re a champion! 🏆';
    }
  }
}

