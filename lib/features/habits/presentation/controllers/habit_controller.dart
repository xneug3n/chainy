import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/habit_repository.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/recurrence_config.dart';

part 'habit_controller.g.dart';

/// Controller for managing habit operations
@riverpod
class HabitController extends _$HabitController {
  @override
  Future<List<Habit>> build() async {
    // Read directly from repository to avoid circular dependency
    // The repository will be invalidated separately, and we'll invalidate this controller manually
    final repository = ref.read(habitRepositoryProvider.notifier);
    return repository.getAllHabits();
  }

  /// Create a new habit
  Future<void> createHabit({
    required String name,
    required String icon,
    required Color color,
    required GoalType goalType,
    int targetValue = 1,
    String? unit,
    required RecurrenceType recurrenceType,
    required RecurrenceConfig recurrenceConfig,
    String? note,
  }) async {
    final startTime = DateTime.now();
    AppLogger.functionEntry(
      'HabitController.createHabit',
      params: {
        'name': name,
        'icon': icon,
        'color': color.toString(),
        'goalType': goalType.toString(),
        'targetValue': targetValue,
        'unit': unit,
        'recurrenceType': recurrenceType.toString(),
        'hasNote': note != null,
      },
      tag: 'HabitController',
    );

    try {
      // Create habit domain object
      AppLogger.debug('Creating Habit domain object', tag: 'HabitController');
      final habitId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      
      final habit = Habit(
        id: habitId,
        name: name,
        icon: icon,
        color: color,
        goalType: goalType,
        targetValue: targetValue,
        unit: unit,
        recurrenceType: recurrenceType,
        recurrenceConfig: recurrenceConfig,
        note: note,
        createdAt: now,
        updatedAt: now,
      );
      
      AppLogger.info(
        'Habit domain object created',
        data: {
          'habitId': habit.id,
          'name': habit.name,
          'createdAt': habit.createdAt.toIso8601String(),
        },
        tag: 'HabitController',
      );

      // Read repository
      AppLogger.debug('Reading habitRepositoryProvider', tag: 'HabitController');
      final repository = ref.read(habitRepositoryProvider.notifier);
      AppLogger.debug('Repository obtained successfully', tag: 'HabitController');

      // Save habit
      AppLogger.debug('Calling repository.saveHabit', data: {'habitId': habit.id}, tag: 'HabitController');
      await repository.saveHabit(habit);
      AppLogger.info('Repository.saveHabit completed successfully', tag: 'HabitController');

      // Invalidate controller to refresh UI
      // filteredHabitsProvider will automatically update since it watches habitControllerProvider
      AppLogger.debug('Invalidating HabitController (self)', tag: 'HabitController');
      ref.invalidateSelf();
      AppLogger.info('HabitController invalidated, filteredHabitsProvider will auto-update', tag: 'HabitController');

      final duration = DateTime.now().difference(startTime);
      AppLogger.functionExit('HabitController.createHabit', 
        result: {'habitId': habit.id, 'success': true}, 
        tag: 'HabitController',
        duration: duration);
      AppLogger.info('✅ Habit created successfully', 
        data: {'habitId': habit.id, 'duration': '${duration.inMilliseconds}ms'}, 
        tag: 'HabitController');
    } catch (error, stack) {
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.error(
        'Failed to create habit',
        error: error,
        stackTrace: stack,
        tag: 'HabitController',
        context: {
          'name': name,
          'goalType': goalType.toString(),
          'recurrenceType': recurrenceType.toString(),
          'duration': '${duration.inMilliseconds}ms',
        },
      );
      
      AppLogger.functionExit('HabitController.createHabit', 
        tag: 'HabitController',
        duration: duration);
      rethrow;
    }
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit habit) async {
    final startTime = DateTime.now();
    AppLogger.functionEntry(
      'HabitController.updateHabit',
      params: {
        'habitId': habit.id,
        'name': habit.name,
      },
      tag: 'HabitController',
    );

    try {
      AppLogger.debug('Creating updated habit with new updatedAt timestamp', tag: 'HabitController');
      final updatedHabit = habit.copyWith(updatedAt: DateTime.now());
      
      AppLogger.debug('Reading habitRepositoryProvider', tag: 'HabitController');
      final repository = ref.read(habitRepositoryProvider.notifier);
      
      AppLogger.debug('Calling repository.saveHabit', data: {'habitId': updatedHabit.id}, tag: 'HabitController');
      await repository.saveHabit(updatedHabit);
      AppLogger.info('Repository.saveHabit completed successfully', tag: 'HabitController');

      // Invalidate controller to refresh UI
      // filteredHabitsProvider will automatically update since it watches habitControllerProvider
      AppLogger.debug('Invalidating HabitController (self)', tag: 'HabitController');
      ref.invalidateSelf();
      AppLogger.info('HabitController invalidated, filteredHabitsProvider will auto-update', tag: 'HabitController');

      final duration = DateTime.now().difference(startTime);
      AppLogger.functionExit('HabitController.updateHabit', 
        result: {'habitId': habit.id, 'success': true}, 
        tag: 'HabitController',
        duration: duration);
      AppLogger.info('✅ Habit updated successfully', 
        data: {'habitId': habit.id, 'duration': '${duration.inMilliseconds}ms'}, 
        tag: 'HabitController');
    } catch (error, stack) {
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.error(
        'Failed to update habit',
        error: error,
        stackTrace: stack,
        tag: 'HabitController',
        context: {
          'habitId': habit.id,
          'duration': '${duration.inMilliseconds}ms',
        },
      );
      
      AppLogger.functionExit('HabitController.updateHabit', 
        tag: 'HabitController',
        duration: duration);
      rethrow;
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String id) async {
    final repository = ref.read(habitRepositoryProvider.notifier);
    await repository.deleteHabit(id);
    // Refresh controller state from repository to ensure UI updates
    // filteredHabitsProvider will automatically update since it watches habitControllerProvider
    ref.invalidateSelf();
  }

  /// Clear all habits (useful for migration or reset)
  Future<void> clearAllHabits() async {
    AppLogger.functionEntry('HabitController.clearAllHabits', tag: 'HabitController');
    
    try {
      final repository = ref.read(habitRepositoryProvider.notifier);
      await repository.clearAllHabits();
      
      // Refresh controller state
      // filteredHabitsProvider will automatically update since it watches habitControllerProvider
      ref.invalidateSelf();
      
      AppLogger.info('All habits cleared successfully', tag: 'HabitController');
      AppLogger.functionExit('HabitController.clearAllHabits', tag: 'HabitController');
    } catch (error, stack) {
      AppLogger.error(
        'Failed to clear all habits',
        error: error,
        stackTrace: stack,
        tag: 'HabitController',
      );
      rethrow;
    }
  }

  /// Get a specific habit by ID
  Future<Habit?> getHabitById(String id) async {
    final repository = ref.read(habitRepositoryProvider.notifier);
    return repository.getHabitById(id);
  }

  /// Search habits by name
  Future<List<Habit>> searchHabits(String query) async {
    final repository = ref.read(habitRepositoryProvider.notifier);
    return repository.searchHabits(query);
  }

  /// Get habits by recurrence type
  Future<List<Habit>> getHabitsByRecurrenceType(RecurrenceType type) async {
    final repository = ref.read(habitRepositoryProvider.notifier);
    return repository.getHabitsByRecurrenceType(type);
  }
}

/// Provider for getting a specific habit by ID
@riverpod
Future<Habit?> habitById(HabitByIdRef ref, String id) async {
  final repository = ref.read(habitRepositoryProvider.notifier);
  return repository.getHabitById(id);
}

/// Provider for searching habits
@riverpod
Future<List<Habit>> searchHabits(SearchHabitsRef ref, String query) async {
  final repository = ref.read(habitRepositoryProvider.notifier);
  return repository.searchHabits(query);
}

/// Provider for habits by recurrence type
@riverpod
Future<List<Habit>> habitsByRecurrenceType(
  HabitsByRecurrenceTypeRef ref,
  RecurrenceType type,
) async {
  final repository = ref.read(habitRepositoryProvider.notifier);
  return repository.getHabitsByRecurrenceType(type);
}
