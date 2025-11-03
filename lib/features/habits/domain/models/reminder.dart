import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

/// Domain model for a habit reminder
/// Represents a notification reminder with time and days of week
@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String habitId,
    @JsonKey(fromJson: _timeFromJson, toJson: _timeToJson) required TimeOfDay time,
    @Default([1, 2, 3, 4, 5, 6, 7]) List<int> daysOfWeek, // 1-7 for Monday-Sunday
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);
}

/// Helper functions for TimeOfDay serialization
TimeOfDay _timeFromJson(Map<String, dynamic> json) {
  return TimeOfDay(
    hour: json['hour'] as int,
    minute: json['minute'] as int,
  );
}

Map<String, dynamic> _timeToJson(TimeOfDay time) {
  return {
    'hour': time.hour,
    'minute': time.minute,
  };
}

