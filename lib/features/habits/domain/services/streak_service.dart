import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/habit.dart';
import '../models/check_in.dart';
import '../../data/habit_repository.dart';
import '../../data/check_in_repository.dart';

part 'streak_service.g.dart';

/// Service for calculating and managing streak data
@riverpod
class StreakService extends _$StreakService {
  @override
  Future<Map<String, int>> build() async {
    return {};
  }

  /// Get current streak for a specific habit
  Future<int> getCurrentStreak(String habitId) async {
    final habit = await ref.read(habitRepositoryProvider.notifier).getHabitById(habitId);
    if (habit == null) return 0;

    final checkIns = await ref.read(checkInRepositoryProvider.notifier).getCheckInsForHabit(habitId);
    if (checkIns.isEmpty) return 0;

    // Sort check-ins by date (most recent first)
    checkIns.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? lastDate;

    for (var checkIn in checkIns) {
      final date = DateTime(checkIn.date.year, checkIn.date.month, checkIn.date.day);
      
      // Check if goal was met
      bool goalMet = _isGoalMet(habit, checkIn);
      
      if (!goalMet) break;
      
      // Check for streak continuity
      if (lastDate == null) {
        streak = 1;
        lastDate = date;
        continue;
      }
      
      // Calculate days difference
      final difference = lastDate.difference(date).inDays;
      
      // Check if streak is continuous
      if (difference == 1) {
        streak++;
        lastDate = date;
      } else {
        break;
      }
    }
    
    return streak;
  }

  /// Get longest streak for a specific habit
  Future<int> getLongestStreak(String habitId) async {
    final habit = await ref.read(habitRepositoryProvider.notifier).getHabitById(habitId);
    if (habit == null) return 0;

    final checkIns = await ref.read(checkInRepositoryProvider.notifier).getCheckInsForHabit(habitId);
    if (checkIns.isEmpty) return 0;

    // Sort check-ins by date (oldest first)
    checkIns.sort((a, b) => a.date.compareTo(b.date));

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (var checkIn in checkIns) {
      final date = DateTime(checkIn.date.year, checkIn.date.month, checkIn.date.day);
      
      // Check if goal was met
      bool goalMet = _isGoalMet(habit, checkIn);
      
      if (!goalMet) {
        currentStreak = 0;
        lastDate = null;
        continue;
      }
      
      if (lastDate == null) {
        currentStreak = 1;
        lastDate = date;
      } else {
        final difference = date.difference(lastDate).inDays;
        
        if (difference == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
        lastDate = date;
      }
      
      maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
    }
    
    return maxStreak;
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

  /// Get streak data for a specific date range
  Future<Map<DateTime, int>> getStreakDataForDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final habit = await ref.read(habitRepositoryProvider.notifier).getHabitById(habitId);
    if (habit == null) return {};

    final checkIns = await ref.read(checkInRepositoryProvider.notifier)
        .getCheckInsByDateRange(habitId, startDate, endDate);
    
    final Map<DateTime, int> streakData = {};
    
    // Sort check-ins by date (oldest first)
    checkIns.sort((a, b) => a.date.compareTo(b.date));
    
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (var checkIn in checkIns) {
      final date = DateTime(checkIn.date.year, checkIn.date.month, checkIn.date.day);
      
      // Check if goal was met
      bool goalMet = _isGoalMet(habit, checkIn);
      
      if (!goalMet) {
        currentStreak = 0;
        lastDate = null;
      } else {
        if (lastDate == null) {
          currentStreak = 1;
        } else {
          final difference = date.difference(lastDate).inDays;
          if (difference == 1) {
            currentStreak++;
          } else {
            currentStreak = 1;
          }
        }
        lastDate = date;
      }
      
      streakData[date] = currentStreak;
    }
    
    return streakData;
  }

  /// Check if a streak is active (no missed days)
  Future<bool> isStreakActive(String habitId) async {
    final currentStreak = await getCurrentStreak(habitId);
    if (currentStreak == 0) return false;
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    final todayCheckIn = await ref.read(checkInRepositoryProvider.notifier)
        .getCheckInForHabitOnDate(habitId, today);
    final yesterdayCheckIn = await ref.read(checkInRepositoryProvider.notifier)
        .getCheckInForHabitOnDate(habitId, yesterday);
    
    // Streak is active if there's a check-in today or yesterday
    return todayCheckIn != null || yesterdayCheckIn != null;
  }

  /// Get streak statistics for a habit
  Future<Map<String, dynamic>> getStreakStatistics(String habitId) async {
    final currentStreak = await getCurrentStreak(habitId);
    final longestStreak = await getLongestStreak(habitId);
    final isActive = await isStreakActive(habitId);
    
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'isActive': isActive,
    };
  }
}
