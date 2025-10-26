import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/recurrence_config.dart';

part 'habit_dto.freezed.dart';
part 'habit_dto.g.dart';

/// Data Transfer Object for Habit persistence
@freezed
@HiveType(typeId: 0)
class HabitDto with _$HabitDto {
  const factory HabitDto({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String icon,
    @HiveField(3) required int colorValue,
    @HiveField(4) required String goalType,
    @HiveField(5) @Default(1) int targetValue,
    @HiveField(6) String? unit,
    @HiveField(7) required String recurrenceType,
    @HiveField(8) required Map<String, dynamic> recurrenceConfig,
    @HiveField(9) String? note,
    @HiveField(10) required String createdAt,
    @HiveField(11) required String updatedAt,
  }) = _HabitDto;

  factory HabitDto.fromJson(Map<String, dynamic> json) => _$HabitDtoFromJson(json);

  /// Convert from domain model
  factory HabitDto.fromDomain(Habit habit) {
    return HabitDto(
      id: habit.id,
      name: habit.name,
      icon: habit.icon,
      colorValue: habit.color.value,
      goalType: habit.goalType.name,
      targetValue: habit.targetValue,
      unit: habit.unit,
      recurrenceType: habit.recurrenceType.name,
      recurrenceConfig: habit.recurrenceConfig.toJson(),
      note: habit.note,
      createdAt: habit.createdAt.toIso8601String(),
      updatedAt: habit.updatedAt.toIso8601String(),
    );
  }
}

/// Extension to convert DTO to domain model
extension HabitDtoExtension on HabitDto {
  Habit toDomain() {
    return Habit(
      id: id,
      name: name,
      icon: icon,
      color: Color(colorValue),
      goalType: GoalType.values.firstWhere((e) => e.name == goalType),
      targetValue: targetValue,
      unit: unit,
      recurrenceType: RecurrenceType.values.firstWhere((e) => e.name == recurrenceType),
      recurrenceConfig: RecurrenceConfig.fromJson(recurrenceConfig),
      note: note,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
