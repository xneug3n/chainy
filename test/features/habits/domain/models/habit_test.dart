import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chainy/features/habits/domain/models/habit.dart';
import 'package:chainy/features/habits/domain/models/recurrence_config.dart';

void main() {
  group('Habit', () {
    test('should create a habit with all required fields', () {
      // Arrange
      final now = DateTime.now();
      final recurrenceConfig = const RecurrenceConfig.daily();
      
      // Act
      final habit = Habit(
        id: 'test-id',
        name: 'Test Habit',
        icon: '🏃‍♂️',
        color: Colors.blue,
        goalType: GoalType.binary,
        targetValue: 1,
        unit: null,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: recurrenceConfig,
        note: 'Test note',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(habit.id, equals('test-id'));
      expect(habit.name, equals('Test Habit'));
      expect(habit.icon, equals('🏃‍♂️'));
      expect(habit.color, equals(Colors.blue));
      expect(habit.goalType, equals(GoalType.binary));
      expect(habit.targetValue, equals(1));
      expect(habit.unit, isNull);
      expect(habit.recurrenceType, equals(RecurrenceType.daily));
      expect(habit.recurrenceConfig, equals(recurrenceConfig));
      expect(habit.note, equals('Test note'));
      expect(habit.createdAt, equals(now));
      expect(habit.updatedAt, equals(now));
    });

    test('should create a quantitative habit with target value and unit', () {
      // Arrange
      final now = DateTime.now();
      final recurrenceConfig = const RecurrenceConfig.multiplePerDay(targetCount: 3);
      
      // Act
      final habit = Habit(
        id: 'test-id-2',
        name: 'Water Intake',
        icon: '💧',
        color: Colors.cyan,
        goalType: GoalType.quantitative,
        targetValue: 8,
        unit: 'glasses',
        recurrenceType: RecurrenceType.multiplePerDay,
        recurrenceConfig: recurrenceConfig,
        note: 'Drink 8 glasses of water daily',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(habit.goalType, equals(GoalType.quantitative));
      expect(habit.targetValue, equals(8));
      expect(habit.unit, equals('glasses'));
      expect(habit.recurrenceType, equals(RecurrenceType.multiplePerDay));
    });

    test('should serialize and deserialize correctly', () {
      // Arrange
      final now = DateTime.now();
      final recurrenceConfig = const RecurrenceConfig.daily();
      
      final habit = Habit(
        id: 'test-id-3',
        name: 'Gym Workout',
        icon: '💪',
        color: Colors.red,
        goalType: GoalType.binary,
        targetValue: 1,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: recurrenceConfig,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final json = habit.toJson();
      final deserializedHabit = Habit.fromJson(json);

      // Assert
      expect(deserializedHabit.id, equals(habit.id));
      expect(deserializedHabit.name, equals(habit.name));
      expect(deserializedHabit.icon, equals(habit.icon));
      expect(deserializedHabit.color.value, equals(habit.color.value));
      expect(deserializedHabit.goalType, equals(habit.goalType));
      expect(deserializedHabit.targetValue, equals(habit.targetValue));
      expect(deserializedHabit.unit, equals(habit.unit));
      expect(deserializedHabit.recurrenceType, equals(habit.recurrenceType));
      expect(deserializedHabit.note, equals(habit.note));
      expect(deserializedHabit.createdAt, equals(habit.createdAt));
      expect(deserializedHabit.updatedAt, equals(habit.updatedAt));
    });

    test('should create a copy with updated fields', () {
      // Arrange
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 1));
      final recurrenceConfig = const RecurrenceConfig.daily();
      
      final habit = Habit(
        id: 'test-id-4',
        name: 'Original Name',
        icon: '📚',
        color: Colors.green,
        goalType: GoalType.binary,
        targetValue: 1,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: recurrenceConfig,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updatedHabit = habit.copyWith(
        name: 'Updated Name',
        note: 'Added note',
        updatedAt: later,
      );

      // Assert
      expect(updatedHabit.id, equals(habit.id));
      expect(updatedHabit.name, equals('Updated Name'));
      expect(updatedHabit.note, equals('Added note'));
      expect(updatedHabit.updatedAt, equals(later));
      expect(updatedHabit.icon, equals(habit.icon));
      expect(updatedHabit.color, equals(habit.color));
    });
  });

  group('GoalType', () {
    test('should have correct JSON values', () {
      expect(GoalType.binary.name, equals('binary'));
      expect(GoalType.quantitative.name, equals('quantitative'));
    });
  });

  group('RecurrenceType', () {
    test('should have correct JSON values', () {
      expect(RecurrenceType.daily.name, equals('daily'));
      expect(RecurrenceType.multiplePerDay.name, equals('multiplePerDay'));
      expect(RecurrenceType.weekly.name, equals('weekly'));
      expect(RecurrenceType.custom.name, equals('custom'));
    });
  });
}
