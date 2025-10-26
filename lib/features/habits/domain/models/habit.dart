import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'recurrence_config.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

/// Domain model for a habit with all required fields
@freezed
class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String name,
    required String icon,
    @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson) required Color color,
    required GoalType goalType,
    @Default(1) int targetValue,
    String? unit,
    required RecurrenceType recurrenceType,
    required RecurrenceConfig recurrenceConfig,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}

/// Helper functions for Color serialization
Color _colorFromJson(int value) => Color(value);
int _colorToJson(Color color) => color.value;


/// Goal type for habits
enum GoalType {
  @JsonValue('binary')
  binary,
  @JsonValue('quantitative')
  quantitative,
}

/// Recurrence type for habits
enum RecurrenceType {
  @JsonValue('daily')
  daily,
  @JsonValue('multiplePerDay')
  multiplePerDay,
  @JsonValue('weekly')
  weekly,
  @JsonValue('custom')
  custom,
}
