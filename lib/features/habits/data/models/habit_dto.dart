import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/recurrence_config.dart';
import '../../domain/models/reminder.dart';
import '../../../../core/utils/app_logger.dart';

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
    @HiveField(10) @Default(0) int currentStreak,
    @HiveField(13) @Default([]) List<Map<String, dynamic>> reminders,
    @HiveField(11) required String createdAt,
    @HiveField(12) required String updatedAt,
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
      currentStreak: habit.currentStreak,
      reminders: habit.reminders.map((r) => r.toJson()).toList(),
      createdAt: habit.createdAt.toIso8601String(),
      updatedAt: habit.updatedAt.toIso8601String(),
    );
  }
}

/// Extension to convert DTO to domain model
extension HabitDtoExtension on HabitDto {
  Habit toDomain() {
    AppLogger.functionEntry('HabitDto.toDomain', 
      params: {'habitId': id, 'name': name}, 
      tag: 'HabitDto');
    
    try {
      // Safely deserialize RecurrenceConfig with fallback
      RecurrenceConfig config;
      try {
        AppLogger.debug('Deserializing RecurrenceConfig', 
          data: {'recurrenceConfig': recurrenceConfig}, 
          tag: 'HabitDto');
        
        if (recurrenceConfig.isEmpty || !recurrenceConfig.containsKey('runtimeType')) {
          AppLogger.warning('Invalid or empty RecurrenceConfig, using default', 
            data: {'recurrenceType': recurrenceType, 'recurrenceConfig': recurrenceConfig}, 
            tag: 'HabitDto');
          
          // No valid config found, create default based on recurrence type
          final type = RecurrenceType.values.firstWhere(
            (e) => e.name == recurrenceType,
            orElse: () => RecurrenceType.daily,
          );
          config = _createDefaultRecurrenceConfig(type);
        } else {
          config = RecurrenceConfig.fromJson(recurrenceConfig);
          AppLogger.debug('RecurrenceConfig deserialized successfully', tag: 'HabitDto');
        }
      } catch (e, stack) {
        AppLogger.error('Failed to deserialize RecurrenceConfig, using default', 
          error: e, 
          stackTrace: stack, 
          tag: 'HabitDto',
          context: {
            'habitId': id,
            'recurrenceType': recurrenceType,
            'recurrenceConfig': recurrenceConfig.toString(),
          });
        
        // Fallback to default config if deserialization fails
        final type = RecurrenceType.values.firstWhere(
          (e) => e.name == recurrenceType,
          orElse: () => RecurrenceType.daily,
        );
        config = _createDefaultRecurrenceConfig(type);
      }

      // Safely parse dates with fallback
      DateTime createdAtDate;
      try {
        AppLogger.debug('Parsing createdAt', data: {'createdAt': createdAt}, tag: 'HabitDto');
        createdAtDate = DateTime.parse(createdAt);
      } catch (e, stack) {
        AppLogger.error('Failed to parse createdAt, using current date', 
          error: e, 
          stackTrace: stack, 
          tag: 'HabitDto',
          context: {'habitId': id, 'createdAt': createdAt});
        createdAtDate = DateTime.now();
      }

      DateTime updatedAtDate;
      try {
        AppLogger.debug('Parsing updatedAt', data: {'updatedAt': updatedAt}, tag: 'HabitDto');
        updatedAtDate = DateTime.parse(updatedAt);
      } catch (e, stack) {
        AppLogger.error('Failed to parse updatedAt, using createdAt or current date', 
          error: e, 
          stackTrace: stack, 
          tag: 'HabitDto',
          context: {'habitId': id, 'updatedAt': updatedAt});
        updatedAtDate = createdAtDate;
      }

      // Safely deserialize reminders with fallback
      List<Reminder> remindersList;
      try {
        remindersList = reminders
            .map((json) => Reminder.fromJson(json))
            .toList();
      } catch (e, stack) {
        AppLogger.error(
          'Failed to deserialize reminders, using empty list',
          error: e,
          stackTrace: stack,
          tag: 'HabitDto',
          context: {'habitId': id, 'reminders': reminders.toString()},
        );
        remindersList = [];
      }

      final habit = Habit(
        id: id,
        name: name,
        icon: icon,
        color: Color(colorValue),
        goalType: GoalType.values.firstWhere((e) => e.name == goalType),
        targetValue: targetValue,
        unit: unit,
        recurrenceType: RecurrenceType.values.firstWhere((e) => e.name == recurrenceType),
        recurrenceConfig: config,
        note: note,
        currentStreak: currentStreak,
        reminders: remindersList,
        createdAt: createdAtDate,
        updatedAt: updatedAtDate,
      );
      
      AppLogger.functionExit('HabitDto.toDomain', 
        result: {'habitId': habit.id, 'name': habit.name}, 
        tag: 'HabitDto');
      
      return habit;
    } catch (e, stack) {
      AppLogger.error('Failed to convert HabitDto to domain model', 
        error: e, 
        stackTrace: stack, 
        tag: 'HabitDto',
        context: {
          'habitId': id,
          'name': name,
          'createdAt': createdAt,
          'updatedAt': updatedAt,
          'recurrenceConfig': recurrenceConfig.toString(),
        });
      rethrow;
    }
  }

  /// Create a default RecurrenceConfig based on the recurrence type
  RecurrenceConfig _createDefaultRecurrenceConfig(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return const RecurrenceConfig.daily();
      case RecurrenceType.multiplePerDay:
        return const RecurrenceConfig.multiplePerDay(targetCount: 2);
      case RecurrenceType.weekly:
        return const RecurrenceConfig.weekly(
          daysOfWeek: [Weekday.monday],
        );
      case RecurrenceType.custom:
        return const RecurrenceConfig.custom(interval: 1);
    }
  }
}
