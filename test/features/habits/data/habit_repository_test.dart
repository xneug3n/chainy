import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chainy/features/habits/data/habit_repository.dart';
import 'package:chainy/features/habits/data/models/habit_dto.dart';
import 'package:chainy/features/habits/domain/models/habit.dart';
import 'package:chainy/features/habits/domain/models/recurrence_config.dart';
import 'package:chainy/core/di/hive_setup.dart';

void main() {
  group('HabitRepository', () {
    late HabitRepository repository;

    setUpAll(() async {
      await Hive.initFlutter();
      Hive.registerAdapter(HabitDtoAdapter());
    });

    setUp(() async {
      await HiveSetup.closeAll();
      await HiveSetup.initialize();
      repository = HabitRepository();
      await repository.build();
    });

    tearDown(() async {
      await repository.clearAllHabits();
    });

    tearDownAll(() async {
      await HiveSetup.closeAll();
    });

    test('should create and retrieve a habit', () async {
      // Arrange
      final now = DateTime.now();
      final recurrenceConfig = const RecurrenceConfig.daily();
      
      final habit = Habit(
        id: 'test-habit-1',
        name: 'Morning Run',
        icon: '🏃‍♂️',
        color: Colors.blue,
        goalType: GoalType.binary,
        targetValue: 1,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: recurrenceConfig,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      await repository.saveHabit(habit);
      final retrievedHabit = await repository.getHabitById('test-habit-1');

      // Assert
      expect(retrievedHabit, isNotNull);
      expect(retrievedHabit!.id, equals(habit.id));
      expect(retrievedHabit.name, equals(habit.name));
      expect(retrievedHabit.icon, equals(habit.icon));
      expect(retrievedHabit.color, equals(habit.color));
      expect(retrievedHabit.goalType, equals(habit.goalType));
    });

    test('should get all habits', () async {
      // Arrange
      final now = DateTime.now();
      final habits = [
        Habit(
          id: 'habit-1',
          name: 'Habit 1',
          icon: '📚',
          color: Colors.green,
          goalType: GoalType.binary,
          targetValue: 1,
          recurrenceType: RecurrenceType.daily,
          recurrenceConfig: const RecurrenceConfig.daily(),
          createdAt: now,
          updatedAt: now,
        ),
        Habit(
          id: 'habit-2',
          name: 'Habit 2',
          icon: '💧',
          color: Colors.cyan,
          goalType: GoalType.quantitative,
          targetValue: 8,
          unit: 'glasses',
          recurrenceType: RecurrenceType.multiplePerDay,
          recurrenceConfig: const RecurrenceConfig.multiplePerDay(targetCount: 8),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act
      for (final habit in habits) {
        await repository.saveHabit(habit);
      }
      final allHabits = await repository.getAllHabits();

      // Assert
      expect(allHabits.length, equals(2));
      expect(allHabits.any((h) => h.id == 'habit-1'), isTrue);
      expect(allHabits.any((h) => h.id == 'habit-2'), isTrue);
    });

    test('should update an existing habit', () async {
      // Arrange
      final now = DateTime.now();
      final originalHabit = Habit(
        id: 'update-test',
        name: 'Original Name',
        icon: '📚',
        color: Colors.green,
        goalType: GoalType.binary,
        targetValue: 1,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: const RecurrenceConfig.daily(),
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveHabit(originalHabit);

      // Act
      final updatedHabit = originalHabit.copyWith(
        name: 'Updated Name',
        note: 'Added note',
        updatedAt: DateTime.now(),
      );
      await repository.saveHabit(updatedHabit);
      final retrievedHabit = await repository.getHabitById('update-test');

      // Assert
      expect(retrievedHabit, isNotNull);
      expect(retrievedHabit!.name, equals('Updated Name'));
      expect(retrievedHabit.note, equals('Added note'));
    });

    test('should delete a habit', () async {
      // Arrange
      final now = DateTime.now();
      final habit = Habit(
        id: 'delete-test',
        name: 'To Delete',
        icon: '🗑️',
        color: Colors.red,
        goalType: GoalType.binary,
        targetValue: 1,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: const RecurrenceConfig.daily(),
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveHabit(habit);

      // Act
      await repository.deleteHabit('delete-test');
      final deletedHabit = await repository.getHabitById('delete-test');

      // Assert
      expect(deletedHabit, isNull);
    });

    test('should search habits by name', () async {
      // Arrange
      final now = DateTime.now();
      final habits = [
        Habit(
          id: 'search-1',
          name: 'Morning Exercise',
          icon: '🏃‍♂️',
          color: Colors.blue,
          goalType: GoalType.binary,
          targetValue: 1,
          recurrenceType: RecurrenceType.daily,
          recurrenceConfig: const RecurrenceConfig.daily(),
          createdAt: now,
          updatedAt: now,
        ),
        Habit(
          id: 'search-2',
          name: 'Evening Reading',
          icon: '📚',
          color: Colors.green,
          goalType: GoalType.binary,
          targetValue: 1,
          recurrenceType: RecurrenceType.daily,
          recurrenceConfig: const RecurrenceConfig.daily(),
          createdAt: now,
          updatedAt: now,
        ),
        Habit(
          id: 'search-3',
          name: 'Water Intake',
          icon: '💧',
          color: Colors.cyan,
          goalType: GoalType.quantitative,
          targetValue: 8,
          unit: 'glasses',
          recurrenceType: RecurrenceType.multiplePerDay,
          recurrenceConfig: const RecurrenceConfig.multiplePerDay(targetCount: 8),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      for (final habit in habits) {
        await repository.saveHabit(habit);
      }

      // Act
      final morningResults = await repository.searchHabits('morning');
      final readingResults = await repository.searchHabits('reading');
      final waterResults = await repository.searchHabits('water');

      // Assert
      expect(morningResults.length, equals(1));
      expect(morningResults.first.name, equals('Morning Exercise'));
      
      expect(readingResults.length, equals(1));
      expect(readingResults.first.name, equals('Evening Reading'));
      
      expect(waterResults.length, equals(1));
      expect(waterResults.first.name, equals('Water Intake'));
    });

    test('should get habits by recurrence type', () async {
      // Arrange
      final now = DateTime.now();
      final habits = [
        Habit(
          id: 'daily-1',
          name: 'Daily Habit',
          icon: '📅',
          color: Colors.blue,
          goalType: GoalType.binary,
          targetValue: 1,
          recurrenceType: RecurrenceType.daily,
          recurrenceConfig: const RecurrenceConfig.daily(),
          createdAt: now,
          updatedAt: now,
        ),
        Habit(
          id: 'weekly-1',
          name: 'Weekly Habit',
          icon: '📆',
          color: Colors.green,
          goalType: GoalType.binary,
          targetValue: 1,
          recurrenceType: RecurrenceType.weekly,
          recurrenceConfig: const RecurrenceConfig.weekly(
            daysOfWeek: [Weekday.monday, Weekday.friday],
          ),
          createdAt: now,
          updatedAt: now,
        ),
        Habit(
          id: 'daily-2',
          name: 'Another Daily',
          icon: '🔄',
          color: Colors.orange,
          goalType: GoalType.binary,
          targetValue: 1,
          recurrenceType: RecurrenceType.daily,
          recurrenceConfig: const RecurrenceConfig.daily(),
          createdAt: now,
          updatedAt: now,
        ),
      ];

      for (final habit in habits) {
        await repository.saveHabit(habit);
      }

      // Act
      final dailyHabits = await repository.getHabitsByRecurrenceType(RecurrenceType.daily);
      final weeklyHabits = await repository.getHabitsByRecurrenceType(RecurrenceType.weekly);

      // Assert
      expect(dailyHabits.length, equals(2));
      expect(dailyHabits.every((h) => h.recurrenceType == RecurrenceType.daily), isTrue);
      
      expect(weeklyHabits.length, equals(1));
      expect(weeklyHabits.first.recurrenceType, equals(RecurrenceType.weekly));
    });

    test('should get habits count', () async {
      // Arrange
      final now = DateTime.now();
      final habits = List.generate(5, (index) => Habit(
        id: 'count-test-$index',
        name: 'Habit $index',
        icon: '📝',
        color: Colors.blue,
        goalType: GoalType.binary,
        targetValue: 1,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: const RecurrenceConfig.daily(),
        createdAt: now,
        updatedAt: now,
      ));

      // Act
      for (final habit in habits) {
        await repository.saveHabit(habit);
      }
      final count = await repository.getHabitsCount();

      // Assert
      expect(count, equals(5));
    });

    test('should clear all habits', () async {
      // Arrange
      final now = DateTime.now();
      final habits = List.generate(3, (index) => Habit(
        id: 'clear-test-$index',
        name: 'Habit $index',
        icon: '📝',
        color: Colors.blue,
        goalType: GoalType.binary,
        targetValue: 1,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: const RecurrenceConfig.daily(),
        createdAt: now,
        updatedAt: now,
      ));

      for (final habit in habits) {
        await repository.saveHabit(habit);
      }

      // Act
      await repository.clearAllHabits();
      final allHabits = await repository.getAllHabits();
      final count = await repository.getHabitsCount();

      // Assert
      expect(allHabits.length, equals(0));
      expect(count, equals(0));
    });
  });
}
