import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chainy/core/di/hive_setup.dart';
import 'package:chainy/features/habits/domain/services/reminder_service.dart';
import 'package:chainy/features/habits/data/habit_repository.dart';

void main() {
  group('ReminderService', () {
    late HabitRepository habitRepository;

    setUpAll(() async {
      await Hive.initFlutter();
    });

    setUp(() async {
      await HiveSetup.closeAll();
      await HiveSetup.initialize();
      
      habitRepository = HabitRepository();
      await habitRepository.build();
    });

    tearDown(() async {
      await habitRepository.clearAllHabits();
    });

    tearDownAll(() async {
      await HiveSetup.closeAll();
    });

    // Note: ReminderService initialization requires platform channels (notifications)
    // which are not available in unit tests. These tests verify the service structure
    // and error handling. Full integration testing should be done with integration tests.

    test('should handle scheduling reminder for non-existent habit', () async {
      // Arrange
      final reminderService = ReminderService();
      final habitId = 'non-existent-habit';
      final reminderId = 'reminder-1';
      final time = const TimeOfDay(hour: 9, minute: 30);
      final daysOfWeek = [1, 2, 3, 4, 5];

      // Act & Assert
      // Should not throw, but log a warning
      await expectLater(
        reminderService.scheduleReminder(
          habitId: habitId,
          reminderId: reminderId,
          time: time,
          daysOfWeek: daysOfWeek,
        ),
        completes,
      );
    });

    // Note: Private methods like _generateNotificationId and _nextInstanceOfTime
    // are tested indirectly through public methods like scheduleReminder

    test('should handle canceling reminder for non-existent habit', () async {
      // Arrange
      final reminderService = ReminderService();
      final habitId = 'non-existent-habit';
      final reminderId = 'reminder-1';

      // Act & Assert
      // Should not throw
      await expectLater(
        reminderService.cancelReminder(
          habitId: habitId,
          reminderId: reminderId,
        ),
        completes,
      );
    });

    test('should handle canceling all reminders for habit', () async {
      // Arrange
      final reminderService = ReminderService();
      final habitId = 'test-habit';

      // Act & Assert
      // Should not throw
      await expectLater(
        reminderService.cancelAllRemindersForHabit(habitId),
        completes,
      );
    });

    test('should handle snoozing reminder for non-existent habit', () async {
      // Arrange
      final reminderService = ReminderService();
      final habitId = 'non-existent-habit';
      final reminderId = 'reminder-1';
      final duration = const Duration(minutes: 15);

      // Act & Assert
      // Should not throw, but log a warning
      await expectLater(
        reminderService.snoozeReminder(
          habitId: habitId,
          reminderId: reminderId,
          duration: duration,
        ),
        completes,
      );
    });
  });
}

