import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chainy/features/habits/data/models/habit_dto.dart';
import 'package:chainy/features/habits/domain/models/habit.dart';
import 'package:chainy/features/habits/domain/models/recurrence_config.dart';

void main() {
  group('HabitDto', () {
    test('should convert from domain model to DTO', () {
      // Arrange
      final now = DateTime.now();
      final recurrenceConfig = const RecurrenceConfig.daily();
      
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

      // Act
      final dto = HabitDto.fromDomain(habit);

      // Assert
      expect(dto.id, equals(habit.id));
      expect(dto.name, equals(habit.name));
      expect(dto.icon, equals(habit.icon));
      expect(dto.colorValue, equals(habit.color.value));
      expect(dto.goalType, equals(habit.goalType.name));
      expect(dto.targetValue, equals(habit.targetValue));
      expect(dto.unit, equals(habit.unit));
      expect(dto.recurrenceType, equals(habit.recurrenceType.name));
      expect(dto.note, equals(habit.note));
      expect(dto.createdAt, equals(habit.createdAt.toIso8601String()));
      expect(dto.updatedAt, equals(habit.updatedAt.toIso8601String()));
    });

    test('should convert from DTO to domain model', () {
      // Arrange
      final now = DateTime.now();
      final dto = HabitDto(
        id: 'test-id',
        name: 'Test Habit',
        icon: '🏃‍♂️',
        colorValue: Colors.blue.value,
        goalType: 'binary',
        targetValue: 1,
        unit: null,
        recurrenceType: 'daily',
        recurrenceConfig: const RecurrenceConfig.daily().toJson(),
        note: 'Test note',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      // Act
      final habit = dto.toDomain();

      // Assert
      expect(habit.id, equals(dto.id));
      expect(habit.name, equals(dto.name));
      expect(habit.icon, equals(dto.icon));
      expect(habit.color.value, equals(dto.colorValue));
      expect(habit.goalType.name, equals(dto.goalType));
      expect(habit.targetValue, equals(dto.targetValue));
      expect(habit.unit, equals(dto.unit));
      expect(habit.recurrenceType.name, equals(dto.recurrenceType));
      expect(habit.note, equals(dto.note));
      expect(habit.createdAt, equals(DateTime.parse(dto.createdAt)));
      expect(habit.updatedAt, equals(DateTime.parse(dto.updatedAt)));
    });

    test('should serialize and deserialize correctly', () {
      // Arrange
      final now = DateTime.now();
      final dto = HabitDto(
        id: 'test-id',
        name: 'Test Habit',
        icon: '🏃‍♂️',
        colorValue: Colors.blue.value,
        goalType: 'binary',
        targetValue: 1,
        unit: null,
        recurrenceType: 'daily',
        recurrenceConfig: const RecurrenceConfig.daily().toJson(),
        note: 'Test note',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      // Act
      final json = dto.toJson();
      final deserializedDto = HabitDto.fromJson(json);

      // Assert
      expect(deserializedDto.id, equals(dto.id));
      expect(deserializedDto.name, equals(dto.name));
      expect(deserializedDto.icon, equals(dto.icon));
      expect(deserializedDto.colorValue, equals(dto.colorValue));
      expect(deserializedDto.goalType, equals(dto.goalType));
      expect(deserializedDto.targetValue, equals(dto.targetValue));
      expect(deserializedDto.unit, equals(dto.unit));
      expect(deserializedDto.recurrenceType, equals(dto.recurrenceType));
      expect(deserializedDto.note, equals(dto.note));
      expect(deserializedDto.createdAt, equals(dto.createdAt));
      expect(deserializedDto.updatedAt, equals(dto.updatedAt));
    });

    test('should handle quantitative habit with unit', () {
      // Arrange
      final now = DateTime.now();
      final habit = Habit(
        id: 'quantitative-id',
        name: 'Water Intake',
        icon: '💧',
        color: Colors.cyan,
        goalType: GoalType.quantitative,
        targetValue: 8,
        unit: 'glasses',
        recurrenceType: RecurrenceType.multiplePerDay,
        recurrenceConfig: const RecurrenceConfig.multiplePerDay(targetCount: 8),
        note: 'Drink 8 glasses of water daily',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final dto = HabitDto.fromDomain(habit);
      final convertedBack = dto.toDomain();

      // Assert
      expect(convertedBack.goalType, equals(GoalType.quantitative));
      expect(convertedBack.targetValue, equals(8));
      expect(convertedBack.unit, equals('glasses'));
      expect(convertedBack.recurrenceType, equals(RecurrenceType.multiplePerDay));
    });
  });
}
