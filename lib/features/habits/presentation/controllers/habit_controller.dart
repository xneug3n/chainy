import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/habit_repository.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/recurrence_config.dart';

part 'habit_controller.g.dart';

/// Controller for managing habit operations
@riverpod
class HabitController extends _$HabitController {
  @override
  Future<List<Habit>> build() async {
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
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: icon,
      color: color,
      goalType: goalType,
      targetValue: targetValue,
      unit: unit,
      recurrenceType: recurrenceType,
      recurrenceConfig: recurrenceConfig,
      note: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repository = ref.read(habitRepositoryProvider.notifier);
    await repository.saveHabit(habit);
    ref.invalidateSelf();
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit habit) async {
    final updatedHabit = habit.copyWith(updatedAt: DateTime.now());
    final repository = ref.read(habitRepositoryProvider.notifier);
    await repository.saveHabit(updatedHabit);
    ref.invalidateSelf();
  }

  /// Delete a habit
  Future<void> deleteHabit(String id) async {
    final repository = ref.read(habitRepositoryProvider.notifier);
    await repository.deleteHabit(id);
    ref.invalidateSelf();
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
