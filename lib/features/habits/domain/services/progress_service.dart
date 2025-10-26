import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/habit.dart';
import '../models/check_in.dart';
import '../../data/habit_repository.dart';
import '../../data/check_in_repository.dart';

part 'progress_service.g.dart';

/// Service for calculating and managing habit progress data
@riverpod
class ProgressService extends _$ProgressService {
  @override
  Future<Map<String, int>> build() async {
    return {};
  }

  /// Get current progress value for a habit today
  Future<int> getCurrentValue(String habitId) async {
    final today = DateTime.now();
    final todayCheckIn = await ref.read(checkInRepositoryProvider.notifier)
        .getCheckInForHabitOnDate(habitId, today);
    
    return todayCheckIn?.value ?? 0;
  }

  /// Get progress value for a specific date
  Future<int> getValueForDate(String habitId, DateTime date) async {
    final checkIn = await ref.read(checkInRepositoryProvider.notifier)
        .getCheckInForHabitOnDate(habitId, date);
    
    return checkIn?.value ?? 0;
  }

  /// Get progress values for a date range
  Future<Map<DateTime, int>> getValuesForDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final checkIns = await ref.read(checkInRepositoryProvider.notifier)
        .getCheckInsByDateRange(habitId, startDate, endDate);
    
    final Map<DateTime, int> values = {};
    
    for (final checkIn in checkIns) {
      final date = DateTime(checkIn.date.year, checkIn.date.month, checkIn.date.day);
      values[date] = checkIn.value;
    }
    
    return values;
  }

  /// Check if a habit was completed on a specific date
  Future<bool> isCompletedOnDate(String habitId, DateTime date) async {
    final habit = await ref.read(habitRepositoryProvider.notifier).getHabitById(habitId);
    if (habit == null) return false;

    final checkIn = await ref.read(checkInRepositoryProvider.notifier)
        .getCheckInForHabitOnDate(habitId, date);
    
    if (checkIn == null) return false;
    
    return _isGoalMet(habit, checkIn);
  }

  /// Get completion status for a week (Monday to Sunday)
  Future<List<bool>> getWeekCompletionStatus(String habitId, DateTime weekStart) async {
    final List<bool> weekStatus = [];
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final isCompleted = await isCompletedOnDate(habitId, date);
      weekStatus.add(isCompleted);
    }
    
    return weekStatus;
  }

  /// Check if a habit was completed today
  Future<bool> isCompletedToday(String habitId) async {
    final today = DateTime.now();
    return await isCompletedOnDate(habitId, today);
  }

  /// Get completion percentage for a date range
  Future<double> getCompletionPercentage(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final habit = await ref.read(habitRepositoryProvider.notifier).getHabitById(habitId);
    if (habit == null) return 0.0;

    final checkIns = await ref.read(checkInRepositoryProvider.notifier)
        .getCheckInsByDateRange(habitId, startDate, endDate);
    
    if (checkIns.isEmpty) return 0.0;
    
    int completedDays = 0;
    final totalDays = endDate.difference(startDate).inDays + 1;
    
    for (final checkIn in checkIns) {
      if (_isGoalMet(habit, checkIn)) {
        completedDays++;
      }
    }
    
    return completedDays / totalDays;
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

  /// Get progress statistics for a habit
  Future<Map<String, dynamic>> getProgressStatistics(String habitId) async {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(today.year, today.month, 1);
    
    final currentValue = await getCurrentValue(habitId);
    final completedToday = await isCompletedToday(habitId);
    final weekCompletion = await getWeekCompletionStatus(habitId, weekStart);
    final monthCompletion = await getCompletionPercentage(habitId, monthStart, today);
    
    return {
      'currentValue': currentValue,
      'isCompletedToday': completedToday,
      'weekCompletion': weekCompletion,
      'monthCompletionPercentage': monthCompletion,
    };
  }
}
