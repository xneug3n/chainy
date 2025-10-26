import 'package:flutter_test/flutter_test.dart';
import 'package:chainy/features/habits/domain/models/recurrence_config.dart';

void main() {
  group('RecurrenceConfig', () {
    group('Daily', () {
      test('should create daily recurrence', () {
        // Act
        const config = RecurrenceConfig.daily();

        // Assert
        expect(config, isA<DailyRecurrence>());
      });

      test('should create daily recurrence with custom interval', () {
        // Act
        const config = RecurrenceConfig.daily(interval: 2);

        // Assert
        expect(config, isA<DailyRecurrence>());
      });

      test('should match any date for daily recurrence', () {
        // Arrange
        const config = RecurrenceConfig.daily();
        final testDate = DateTime(2024, 1, 15); // Monday

        // Act & Assert
        expect(config.matchesDate(testDate), isTrue);
      });
    });

    group('MultiplePerDay', () {
      test('should create multiple per day recurrence', () {
        // Act
        const config = RecurrenceConfig.multiplePerDay(targetCount: 3);

        // Assert
        expect(config, isA<MultiplePerDayRecurrence>());
      });

      test('should match any date for multiple per day', () {
        // Arrange
        const config = RecurrenceConfig.multiplePerDay(targetCount: 5);
        final testDate = DateTime(2024, 1, 15);

        // Act & Assert
        expect(config.matchesDate(testDate), isTrue);
      });
    });

    group('Weekly', () {
      test('should create weekly recurrence with specific days', () {
        // Act
        const config = RecurrenceConfig.weekly(
          daysOfWeek: [Weekday.monday, Weekday.wednesday, Weekday.friday],
        );

        // Assert
        expect(config, isA<WeeklyRecurrence>());
      });

      test('should create weekly recurrence with custom interval', () {
        // Act
        const config = RecurrenceConfig.weekly(
          daysOfWeek: [Weekday.sunday],
          interval: 2,
        );

        // Assert
        expect(config, isA<WeeklyRecurrence>());
      });

      test('should match correct weekdays', () {
        // Arrange
        const config = RecurrenceConfig.weekly(
          daysOfWeek: [Weekday.monday, Weekday.wednesday, Weekday.friday],
        );

        // Act & Assert
        expect(config.matchesDate(DateTime(2024, 1, 15)), isTrue); // Monday
        expect(config.matchesDate(DateTime(2024, 1, 16)), isFalse); // Tuesday
        expect(config.matchesDate(DateTime(2024, 1, 17)), isTrue); // Wednesday
        expect(config.matchesDate(DateTime(2024, 1, 18)), isFalse); // Thursday
        expect(config.matchesDate(DateTime(2024, 1, 19)), isTrue); // Friday
      });
    });

    group('Custom', () {
      test('should create custom recurrence with interval', () {
        // Act
        const config = RecurrenceConfig.custom(
          interval: 2,
          byDay: [Weekday.monday, Weekday.friday],
        );

        // Assert
        expect(config, isA<CustomRecurrence>());
      });

      test('should create custom recurrence with count', () {
        // Arrange
        final until = DateTime(2024, 12, 31);
        
        // Act
        final config = RecurrenceConfig.custom(
          interval: 1,
          byDay: [Weekday.sunday],
          count: 10,
          until: until,
        );

        // Assert
        expect(config, isA<CustomRecurrence>());
      });

      test('should match dates within until date', () {
        // Arrange
        final until = DateTime(2024, 6, 30);
        final config = RecurrenceConfig.custom(
          interval: 1,
          byDay: [Weekday.monday],
          until: until,
        );

        // Act & Assert
        expect(config.matchesDate(DateTime(2024, 1, 15)), isTrue); // Monday before until
        expect(config.matchesDate(DateTime(2024, 7, 1)), isFalse); // After until
      });

      test('should match specific days of week', () {
        // Arrange
        const config = RecurrenceConfig.custom(
          interval: 1,
          byDay: [Weekday.tuesday, Weekday.thursday],
        );

        // Act & Assert
        expect(config.matchesDate(DateTime(2024, 1, 16)), isTrue); // Tuesday
        expect(config.matchesDate(DateTime(2024, 1, 17)), isFalse); // Wednesday
        expect(config.matchesDate(DateTime(2024, 1, 18)), isTrue); // Thursday
      });
    });

    group('Serialization', () {
      test('should serialize and deserialize daily recurrence', () {
        // Arrange
        const config = RecurrenceConfig.daily(interval: 2);

        // Act
        final json = config.toJson();
        final deserialized = RecurrenceConfig.fromJson(json);

        // Assert
        expect(deserialized, isA<DailyRecurrence>());
      });

      test('should serialize and deserialize weekly recurrence', () {
        // Arrange
        const config = RecurrenceConfig.weekly(
          daysOfWeek: [Weekday.monday, Weekday.friday],
          interval: 1,
        );

        // Act
        final json = config.toJson();
        final deserialized = RecurrenceConfig.fromJson(json);

        // Assert
        expect(deserialized, isA<WeeklyRecurrence>());
      });

      test('should serialize and deserialize custom recurrence', () {
        // Arrange
        final until = DateTime(2024, 12, 31);
        final config = RecurrenceConfig.custom(
          interval: 2,
          byDay: [Weekday.sunday],
          count: 5,
          until: until,
        );

        // Act
        final json = config.toJson();
        final deserialized = RecurrenceConfig.fromJson(json);

        // Assert
        expect(deserialized, isA<CustomRecurrence>());
      });
    });
  });

  group('Weekday', () {
    test('should have correct JSON values', () {
      expect(Weekday.monday.name, equals('monday'));
      expect(Weekday.tuesday.name, equals('tuesday'));
      expect(Weekday.wednesday.name, equals('wednesday'));
      expect(Weekday.thursday.name, equals('thursday'));
      expect(Weekday.friday.name, equals('friday'));
      expect(Weekday.saturday.name, equals('saturday'));
      expect(Weekday.sunday.name, equals('sunday'));
    });
  });
}
