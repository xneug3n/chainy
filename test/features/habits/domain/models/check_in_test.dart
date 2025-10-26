import 'package:flutter_test/flutter_test.dart';
import 'package:chainy/features/habits/domain/models/check_in.dart';

void main() {
  group('CheckIn', () {
    test('should create a CheckIn with all required fields', () {
      final now = DateTime.now();
      final checkIn = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        note: 'Test note',
        createdAt: now,
        updatedAt: now,
        isBackfilled: false,
      );

      expect(checkIn.id, 'test-id');
      expect(checkIn.habitId, 'habit-id');
      expect(checkIn.date, now);
      expect(checkIn.value, 1);
      expect(checkIn.note, 'Test note');
      expect(checkIn.createdAt, now);
      expect(checkIn.updatedAt, now);
      expect(checkIn.isBackfilled, false);
    });

    test('should create a CheckIn with default values', () {
      final now = DateTime.now();
      final checkIn = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      expect(checkIn.note, null);
      expect(checkIn.isBackfilled, false);
    });

    test('should serialize to JSON correctly', () {
      final now = DateTime.now();
      final checkIn = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        note: 'Test note',
        createdAt: now,
        updatedAt: now,
        isBackfilled: true,
      );

      final json = checkIn.toJson();
      
      expect(json['id'], 'test-id');
      expect(json['habitId'], 'habit-id');
      expect(json['date'], now.toIso8601String());
      expect(json['value'], 1);
      expect(json['note'], 'Test note');
      expect(json['createdAt'], now.toIso8601String());
      expect(json['updatedAt'], now.toIso8601String());
      expect(json['isBackfilled'], true);
    });

    test('should deserialize from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'habitId': 'habit-id',
        'date': now.toIso8601String(),
        'value': 1,
        'note': 'Test note',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isBackfilled': true,
      };

      final checkIn = CheckIn.fromJson(json);
      
      expect(checkIn.id, 'test-id');
      expect(checkIn.habitId, 'habit-id');
      expect(checkIn.date, now);
      expect(checkIn.value, 1);
      expect(checkIn.note, 'Test note');
      expect(checkIn.createdAt, now);
      expect(checkIn.updatedAt, now);
      expect(checkIn.isBackfilled, true);
    });

    test('should handle null note in JSON', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'habitId': 'habit-id',
        'date': now.toIso8601String(),
        'value': 1,
        'note': null,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isBackfilled': false,
      };

      final checkIn = CheckIn.fromJson(json);
      
      expect(checkIn.note, null);
      expect(checkIn.isBackfilled, false);
    });

    test('should be immutable', () {
      final now = DateTime.now();
      final checkIn = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      // Attempting to modify should not work due to immutability
      expect(() => checkIn.copyWith(value: 2), returnsNormally);
      
      final updatedCheckIn = checkIn.copyWith(value: 2);
      expect(updatedCheckIn.value, 2);
      expect(checkIn.value, 1); // Original unchanged
    });

    test('should support equality comparison', () {
      final now = DateTime.now();
      final checkIn1 = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      final checkIn2 = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      final checkIn3 = CheckIn(
        id: 'different-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      expect(checkIn1, equals(checkIn2));
      expect(checkIn1, isNot(equals(checkIn3)));
    });
  });
}
