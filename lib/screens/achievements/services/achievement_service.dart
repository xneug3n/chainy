import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/app_logger.dart';
import '../../../features/habits/data/habit_repository.dart';
import '../../../features/habits/data/check_in_repository.dart';
import '../../../features/habits/domain/services/streak_service.dart';
import '../../../features/habits/domain/services/progress_service.dart';
import '../models/achievement_interface.dart';

part 'achievement_service.g.dart';

/// Service for calculating achievement progress and determining unlock status
@riverpod
class AchievementService extends _$AchievementService {
  @override
  Future<void> build() async {
    // Service doesn't maintain state, just provides methods
  }

  /// Calculate progress for a specific achievement (0.0 to 1.0)
  Future<double> getProgress(String achievementId) async {
    AppLogger.functionEntry(
      'AchievementService.getProgress',
      params: {'achievementId': achievementId},
      tag: 'AchievementService',
    );

    try {
      final achievement = getAchievementById(achievementId);
      if (achievement == null) {
        AppLogger.warning('Achievement not found', 
          data: {'achievementId': achievementId},
          tag: 'AchievementService');
        return 0.0;
      }

      double progress = 0.0;

      switch (achievement.category) {
        case AchievementCategory.firstSteps:
          progress = await _calculateFirstStepsProgress(achievement);
          break;
        case AchievementCategory.streakMilestones:
          progress = await _calculateStreakMilestoneProgress(achievement);
          break;
        case AchievementCategory.habitManagement:
          progress = await _calculateHabitManagementProgress(achievement);
          break;
        case AchievementCategory.checkInMilestones:
          progress = await _calculateCheckInMilestoneProgress(achievement);
          break;
        case AchievementCategory.perfection:
          progress = await _calculatePerfectionProgress(achievement);
          break;
        case AchievementCategory.consistency:
          progress = await _calculateConsistencyProgress(achievement);
          break;
      }

      // Clamp progress between 0.0 and 1.0
      progress = progress.clamp(0.0, 1.0);

      AppLogger.info('Progress calculated',
        data: {'achievementId': achievementId, 'progress': progress},
        tag: 'AchievementService');

      return progress;
    } catch (error, stack) {
      AppLogger.error(
        'Failed to calculate progress',
        error: error,
        stackTrace: stack,
        tag: 'AchievementService',
        context: {'achievementId': achievementId},
      );
      return 0.0;
    }
  }

  /// Check if an achievement should be unlocked based on current progress
  Future<bool> shouldUnlock(String achievementId) async {
    final progress = await getProgress(achievementId);
    return progress >= 1.0;
  }

  /// Calculate progress for First Steps achievements
  Future<double> _calculateFirstStepsProgress(Achievement achievement) async {
    final habitRepo = ref.read(habitRepositoryProvider.notifier);
    final habits = await habitRepo.getAllHabits();
    
    // Examples: "Create your first habit", "Complete 5 habits"
    if (achievement.id == 'first_habit') {
      return habits.isEmpty ? 0.0 : 1.0;
    }
    if (achievement.id == 'five_habits') {
      return (habits.length / 5).clamp(0.0, 1.0);
    }
    
    return 0.0;
  }

  /// Calculate progress for Streak Milestones achievements
  Future<double> _calculateStreakMilestoneProgress(Achievement achievement) async {
    final streakService = ref.read(streakServiceProvider.notifier);
    final habitRepo = ref.read(habitRepositoryProvider.notifier);
    final habits = await habitRepo.getAllHabits();

    if (habits.isEmpty) return 0.0;

    int maxStreak = 0;
    for (final habit in habits) {
      final streak = await streakService.getCurrentStreak(habit.id);
      if (streak > maxStreak) {
        maxStreak = streak;
      }
    }

    // Examples: "3 day streak", "7 day streak", "30 day streak"
    return (maxStreak / achievement.targetValue).clamp(0.0, 1.0);
  }

  /// Calculate progress for Habit Management achievements
  Future<double> _calculateHabitManagementProgress(Achievement achievement) async {
    final habitRepo = ref.read(habitRepositoryProvider.notifier);
    final habits = await habitRepo.getAllHabits();

    // Examples: "Create 10 habits", "Manage 5 active habits"
    if (achievement.id.contains('create')) {
      return (habits.length / achievement.targetValue).clamp(0.0, 1.0);
    }

    return 0.0;
  }

  /// Calculate progress for Check-in Milestones achievements
  Future<double> _calculateCheckInMilestoneProgress(Achievement achievement) async {
    final checkInRepo = ref.read(checkInRepositoryProvider.notifier);
    final allCheckIns = await checkInRepo.getAllCheckIns();

    // Examples: "10 check-ins", "100 check-ins", "1000 check-ins"
    final totalCheckIns = allCheckIns.length;
    return (totalCheckIns / achievement.targetValue).clamp(0.0, 1.0);
  }

  /// Calculate progress for Perfection achievements
  Future<double> _calculatePerfectionProgress(Achievement achievement) async {
    final habitRepo = ref.read(habitRepositoryProvider.notifier);
    final progressService = ref.read(progressServiceProvider.notifier);
    final habits = await habitRepo.getAllHabits();

    if (habits.isEmpty) return 0.0;

    // Examples: "Perfect week", "Perfect month"
    int perfectDays = 0;
    final now = DateTime.now();

    if (achievement.id.contains('week')) {
      // Calculate perfect week (7 days)
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        bool allCompleted = true;
        for (final habit in habits) {
          final completed = await progressService.isCompletedOnDate(habit.id, date);
          if (!completed) {
            allCompleted = false;
            break;
          }
        }
        if (allCompleted) perfectDays++;
      }
      return (perfectDays / 7).clamp(0.0, 1.0);
    } else if (achievement.id.contains('month')) {
      // Calculate perfect month (30 days)
      final monthStart = DateTime(now.year, now.month, 1);
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final daysToCheck = now.day < daysInMonth ? now.day : daysInMonth;
      
      for (int i = 0; i < daysToCheck; i++) {
        final date = monthStart.add(Duration(days: i));
        bool allCompleted = true;
        for (final habit in habits) {
          final completed = await progressService.isCompletedOnDate(habit.id, date);
          if (!completed) {
            allCompleted = false;
            break;
          }
        }
        if (allCompleted) perfectDays++;
      }
      return (perfectDays / daysToCheck).clamp(0.0, 1.0);
    }

    return 0.0;
  }

  /// Calculate progress for Consistency achievements
  Future<double> _calculateConsistencyProgress(Achievement achievement) async {
    final habitRepo = ref.read(habitRepositoryProvider.notifier);
    final progressService = ref.read(progressServiceProvider.notifier);
    final habits = await habitRepo.getAllHabits();

    if (habits.isEmpty) return 0.0;

    // Examples: "7 days in a row", "30 days in a row"
    final now = DateTime.now();
    final targetDays = achievement.targetValue;
    int consecutiveDays = 0;

    for (int i = 0; i < targetDays; i++) {
      final date = now.subtract(Duration(days: i));
      bool allCompleted = true;
      for (final habit in habits) {
        final completed = await progressService.isCompletedOnDate(habit.id, date);
        if (!completed) {
          allCompleted = false;
          break;
        }
      }
      if (allCompleted) {
        consecutiveDays++;
      } else {
        break; // Streak broken
      }
    }

    return (consecutiveDays / targetDays).clamp(0.0, 1.0);
  }

  /// Get achievement by ID from predefined list
  Achievement? getAchievementById(String id) {
    final allAchievements = getAllAchievements();
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all predefined achievements
  List<Achievement> getAllAchievements() {
    return [
      // First Steps
      const Achievement(
        id: 'first_habit',
        title: 'First Step',
        description: 'Create your first habit',
        icon: Icons.add_circle_outline,
        category: AchievementCategory.firstSteps,
        targetValue: 1,
      ),
      const Achievement(
        id: 'five_habits',
        title: 'Getting Started',
        description: 'Create 5 habits',
        icon: Icons.list_alt,
        category: AchievementCategory.firstSteps,
        targetValue: 5,
      ),
      
      // Streak Milestones
      const Achievement(
        id: 'streak_3',
        title: 'On Fire',
        description: 'Maintain a 3-day streak',
        icon: Icons.local_fire_department,
        category: AchievementCategory.streakMilestones,
        targetValue: 3,
      ),
      const Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: Icons.local_fire_department,
        category: AchievementCategory.streakMilestones,
        targetValue: 7,
      ),
      const Achievement(
        id: 'streak_30',
        title: 'Month Master',
        description: 'Maintain a 30-day streak',
        icon: Icons.local_fire_department,
        category: AchievementCategory.streakMilestones,
        targetValue: 30,
      ),
      
      // Habit Management
      const Achievement(
        id: 'create_10',
        title: 'Habit Collector',
        description: 'Create 10 habits',
        icon: Icons.collections,
        category: AchievementCategory.habitManagement,
        targetValue: 10,
      ),
      
      // Check-in Milestones
      const Achievement(
        id: 'checkins_10',
        title: 'Getting There',
        description: 'Complete 10 check-ins',
        icon: Icons.check_circle_outline,
        category: AchievementCategory.checkInMilestones,
        targetValue: 10,
      ),
      const Achievement(
        id: 'checkins_100',
        title: 'Century Club',
        description: 'Complete 100 check-ins',
        icon: Icons.check_circle,
        category: AchievementCategory.checkInMilestones,
        targetValue: 100,
      ),
      
      // Perfection
      const Achievement(
        id: 'perfect_week',
        title: 'Perfect Week',
        description: 'Complete all habits every day for a week',
        icon: Icons.star,
        category: AchievementCategory.perfection,
        targetValue: 7,
      ),
      const Achievement(
        id: 'perfect_month',
        title: 'Perfect Month',
        description: 'Complete all habits every day for a month',
        icon: Icons.star_border,
        category: AchievementCategory.perfection,
        targetValue: 30,
      ),
      
      // Consistency
      const Achievement(
        id: 'consistency_7',
        title: 'Steady',
        description: 'Complete all habits 7 days in a row',
        icon: Icons.trending_up,
        category: AchievementCategory.consistency,
        targetValue: 7,
      ),
      const Achievement(
        id: 'consistency_30',
        title: 'Unstoppable',
        description: 'Complete all habits 30 days in a row',
        icon: Icons.trending_flat,
        category: AchievementCategory.consistency,
        targetValue: 30,
      ),
    ];
  }
}

