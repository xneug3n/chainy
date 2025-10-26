import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurrence_config.freezed.dart';
part 'recurrence_config.g.dart';

/// Configuration for habit recurrence patterns
@freezed
class RecurrenceConfig with _$RecurrenceConfig {
  const factory RecurrenceConfig.daily({
    @Default(1) int interval,
  }) = DailyRecurrence;

  const factory RecurrenceConfig.multiplePerDay({
    required int targetCount,
  }) = MultiplePerDayRecurrence;

  const factory RecurrenceConfig.weekly({
    required List<Weekday> daysOfWeek,
    @Default(1) int interval,
  }) = WeeklyRecurrence;

  const factory RecurrenceConfig.custom({
    required int interval,
    List<Weekday>? byDay,
    int? count,
    DateTime? until,
  }) = CustomRecurrence;

  factory RecurrenceConfig.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceConfigFromJson(json);
}

/// Weekday enumeration for recurrence patterns
enum Weekday {
  @JsonValue('monday')
  monday,
  @JsonValue('tuesday')
  tuesday,
  @JsonValue('wednesday')
  wednesday,
  @JsonValue('thursday')
  thursday,
  @JsonValue('friday')
  friday,
  @JsonValue('saturday')
  saturday,
  @JsonValue('sunday')
  sunday,
}

/// Extension methods for RecurrenceConfig
extension RecurrenceConfigExtension on RecurrenceConfig {
  /// Check if a specific date matches this recurrence pattern
  bool matchesDate(DateTime date) {
    return when(
      daily: (interval) => _matchesDailyInterval(date, interval),
      multiplePerDay: (targetCount) => true, // Multiple per day is always valid
      weekly: (daysOfWeek, interval) => _matchesWeeklyPattern(date, daysOfWeek, interval),
      custom: (interval, byDay, count, until) => _matchesCustomPattern(date, interval, byDay, count, until),
    );
  }

  bool _matchesDailyInterval(DateTime date, int interval) {
    // For daily habits, every day matches
    return true;
  }

  bool _matchesWeeklyPattern(DateTime date, List<Weekday> daysOfWeek, int interval) {
    final weekday = _getWeekdayFromDateTime(date);
    return daysOfWeek.contains(weekday);
  }

  bool _matchesCustomPattern(DateTime date, int interval, List<Weekday>? byDay, int? count, DateTime? until) {
    if (until != null && date.isAfter(until)) return false;
    
    if (byDay != null) {
      final weekday = _getWeekdayFromDateTime(date);
      return byDay.contains(weekday);
    }
    
    return true;
  }

  Weekday _getWeekdayFromDateTime(DateTime date) {
    switch (date.weekday) {
      case 1: return Weekday.monday;
      case 2: return Weekday.tuesday;
      case 3: return Weekday.wednesday;
      case 4: return Weekday.thursday;
      case 5: return Weekday.friday;
      case 6: return Weekday.saturday;
      case 7: return Weekday.sunday;
      default: return Weekday.monday;
    }
  }
}
