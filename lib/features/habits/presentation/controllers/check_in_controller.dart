import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/check_in_repository.dart';
import '../../domain/models/check_in.dart';
import '../../domain/services/progress_service.dart';
import '../../domain/services/streak_service.dart';
import '../../../../screens/statistics/controllers/statistics_provider.dart';

part 'check_in_controller.g.dart';

/// Controller for managing check-in operations
@riverpod
class CheckInController extends _$CheckInController {
  @override
  Future<void> build() async {
    // Controller doesn't hold state, just provides methods
    return;
  }

  /// Add or update a check-in for a habit
  Future<void> saveCheckIn({
    required String habitId,
    required DateTime date,
    required int value,
    String? note,
  }) async {
    final startTime = DateTime.now();
    AppLogger.functionEntry(
      'CheckInController.saveCheckIn',
      params: {
        'habitId': habitId,
        'date': date.toIso8601String(),
        'value': value,
        'hasNote': note != null,
      },
      tag: 'CheckInController',
    );

    try {
      // Check if check-in already exists for this date
      final repository = ref.read(checkInRepositoryProvider.notifier);
      final existingCheckIn = await repository.getCheckInForHabitOnDate(habitId, date);
      
      final now = DateTime.now();
      final checkInId = existingCheckIn?.id ?? 
        '${habitId}_${date.year}_${date.month}_${date.day}';

      final checkIn = CheckIn(
        id: checkInId,
        habitId: habitId,
        date: date,
        value: value,
        note: note ?? existingCheckIn?.note,
        createdAt: existingCheckIn?.createdAt ?? now,
        updatedAt: now,
        isBackfilled: existingCheckIn?.isBackfilled ?? false,
      );

      if (existingCheckIn != null) {
        AppLogger.debug('Updating existing check-in', 
          data: {'checkInId': checkInId},
          tag: 'CheckInController');
        await repository.updateCheckIn(checkIn);
      } else {
        AppLogger.debug('Creating new check-in', 
          data: {'checkInId': checkInId},
          tag: 'CheckInController');
        await repository.addCheckIn(checkIn);
      }

      // Invalidate all dependent providers to trigger UI updates
      AppLogger.debug('Invalidating dependent providers', tag: 'CheckInController');
      
      // Invalidate progress service (used by habit_row for current value)
      ref.invalidate(progressServiceProvider);
      
      // Invalidate streak service (used by habit_row for streak)
      ref.invalidate(streakServiceProvider);
      
      // Invalidate statistics provider (used by statistics screen)
      ref.invalidate(statisticsProviderProvider);
      
      // Also invalidate the check-in repository to ensure fresh data
      ref.invalidate(checkInRepositoryProvider);

      final duration = DateTime.now().difference(startTime);
      AppLogger.functionExit('CheckInController.saveCheckIn', 
        result: {'checkInId': checkInId, 'success': true}, 
        tag: 'CheckInController',
        duration: duration);
      AppLogger.info('✅ Check-in saved successfully', 
        data: {'checkInId': checkInId, 'duration': '${duration.inMilliseconds}ms'}, 
        tag: 'CheckInController');
    } catch (error, stack) {
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.error(
        'Failed to save check-in',
        error: error,
        stackTrace: stack,
        tag: 'CheckInController',
        context: {
          'habitId': habitId,
          'date': date.toIso8601String(),
          'value': value,
          'duration': '${duration.inMilliseconds}ms',
        },
      );
      
      AppLogger.functionExit('CheckInController.saveCheckIn', 
        tag: 'CheckInController',
        duration: duration);
      rethrow;
    }
  }

  /// Delete a check-in for a habit on a specific date
  Future<void> deleteCheckIn(String habitId, DateTime date) async {
    AppLogger.functionEntry(
      'CheckInController.deleteCheckIn',
      params: {
        'habitId': habitId,
        'date': date.toIso8601String(),
      },
      tag: 'CheckInController',
    );

    try {
      final repository = ref.read(checkInRepositoryProvider.notifier);
      final checkIn = await repository.getCheckInForHabitOnDate(habitId, date);
      
      if (checkIn != null) {
        await repository.deleteCheckIn(checkIn.id);
        
        // Invalidate all dependent providers
        ref.invalidate(progressServiceProvider);
        ref.invalidate(streakServiceProvider);
        ref.invalidate(statisticsProviderProvider);
        ref.invalidate(checkInRepositoryProvider);
        
        AppLogger.info('Check-in deleted successfully', 
          data: {'checkInId': checkIn.id},
          tag: 'CheckInController');
      } else {
        AppLogger.debug('No check-in found to delete', tag: 'CheckInController');
      }
    } catch (error, stack) {
      AppLogger.error(
        'Failed to delete check-in',
        error: error,
        stackTrace: stack,
        tag: 'CheckInController',
      );
      rethrow;
    }
  }

  /// Toggle binary habit completion (if value is 1, set to 0; if 0 or missing, set to 1)
  Future<void> toggleBinaryCheckIn({
    required String habitId,
    required DateTime date,
  }) async {
    AppLogger.functionEntry(
      'CheckInController.toggleBinaryCheckIn',
      params: {
        'habitId': habitId,
        'date': date.toIso8601String(),
      },
      tag: 'CheckInController',
    );

    try {
      final repository = ref.read(checkInRepositoryProvider.notifier);
      final existingCheckIn = await repository.getCheckInForHabitOnDate(habitId, date);
      
      if (existingCheckIn != null && existingCheckIn.value >= 1) {
        // Already completed, delete it
        await deleteCheckIn(habitId, date);
      } else {
        // Not completed or doesn't exist, create/update with value 1
        await saveCheckIn(habitId: habitId, date: date, value: 1);
      }
      
      AppLogger.functionExit('CheckInController.toggleBinaryCheckIn', tag: 'CheckInController');
    } catch (error, stack) {
      AppLogger.error(
        'Failed to toggle binary check-in',
        error: error,
        stackTrace: stack,
        tag: 'CheckInController',
      );
      rethrow;
    }
  }
}

/// Provider for current progress value (reactive)
@riverpod
Future<int> currentProgressValue(CurrentProgressValueRef ref, String habitId) async {
  // Watch the service provider to trigger rebuilds when invalidated
  ref.watch(progressServiceProvider);
  final service = ref.read(progressServiceProvider.notifier);
  return await service.getCurrentValue(habitId);
}

/// Provider for current streak (reactive)
@riverpod
Future<int> currentStreak(CurrentStreakRef ref, String habitId) async {
  // Watch the service provider to trigger rebuilds when invalidated
  ref.watch(streakServiceProvider);
  final service = ref.read(streakServiceProvider.notifier);
  return await service.getCurrentStreak(habitId);
}

/// Provider for week completion status (reactive)
@riverpod
Future<List<bool>> weekCompletionStatus(
  WeekCompletionStatusRef ref,
  String habitId,
) async {
  // Watch the service provider to trigger rebuilds when invalidated
  ref.watch(progressServiceProvider);
  final today = DateTime.now();
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final service = ref.read(progressServiceProvider.notifier);
  return await service.getWeekCompletionStatus(habitId, weekStart);
}

/// Provider for today's completion status (reactive)
@riverpod
Future<bool> isCompletedToday(IsCompletedTodayRef ref, String habitId) async {
  // Watch the service provider to trigger rebuilds when invalidated
  ref.watch(progressServiceProvider);
  final service = ref.read(progressServiceProvider.notifier);
  return await service.isCompletedToday(habitId);
}

