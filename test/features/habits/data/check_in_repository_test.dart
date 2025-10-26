import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chainy/features/habits/domain/models/check_in.dart';
import 'package:chainy/features/habits/data/check_in_repository.dart';
import 'package:chainy/features/habits/data/models/check_in_dto.dart';

void main() {
  group('CheckInRepository', () {
    late CheckInRepository repository;
    late Box<CheckInDto> box;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      Hive.registerAdapter(CheckInDtoAdapter());
      box = await Hive.openBox<CheckInDto>('test_check_ins');
      repository = CheckInRepository();
    });

    tearDown(() async {
      await box.clear();
      await box.close();
    });

    test('should add a check-in', () async {
      final now = DateTime.now();
      final checkIn = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addCheckIn(checkIn);
      
      final savedCheckIn = await repository.getCheckInById('test-id');
      expect(savedCheckIn, isNotNull);
      expect(savedCheckIn!.id, 'test-id');
      expect(savedCheckIn.habitId, 'habit-id');
      expect(savedCheckIn.value, 1);
    });

    test('should get check-ins for a specific habit', () async {
      final now = DateTime.now();
      final checkIn1 = CheckIn(
        id: 'test-id-1',
        habitId: 'habit-id-1',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      final checkIn2 = CheckIn(
        id: 'test-id-2',
        habitId: 'habit-id-1',
        date: now.subtract(const Duration(days: 1)),
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      final checkIn3 = CheckIn(
        id: 'test-id-3',
        habitId: 'habit-id-2',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addCheckIn(checkIn1);
      await repository.addCheckIn(checkIn2);
      await repository.addCheckIn(checkIn3);

      final habitCheckIns = await repository.getCheckInsForHabit('habit-id-1');
      
      expect(habitCheckIns.length, 2);
      expect(habitCheckIns[0].id, 'test-id-1'); // Most recent first
      expect(habitCheckIns[1].id, 'test-id-2');
    });

    test('should get check-ins by date range', () async {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 5));
      final endDate = now.subtract(const Duration(days: 1));

      final checkIn1 = CheckIn(
        id: 'test-id-1',
        habitId: 'habit-id',
        date: now.subtract(const Duration(days: 3)),
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      final checkIn2 = CheckIn(
        id: 'test-id-2',
        habitId: 'habit-id',
        date: now.subtract(const Duration(days: 6)), // Outside range
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      final checkIn3 = CheckIn(
        id: 'test-id-3',
        habitId: 'habit-id',
        date: now, // Outside range
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addCheckIn(checkIn1);
      await repository.addCheckIn(checkIn2);
      await repository.addCheckIn(checkIn3);

      final rangeCheckIns = await repository.getCheckInsByDateRange(
        'habit-id',
        startDate,
        endDate,
      );
      
      expect(rangeCheckIns.length, 1);
      expect(rangeCheckIns[0].id, 'test-id-1');
    });

    test('should get check-in for specific date', () async {
      final now = DateTime.now();
      final targetDate = now.subtract(const Duration(days: 1));

      final checkIn = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: targetDate,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addCheckIn(checkIn);
      
      final foundCheckIn = await repository.getCheckInForHabitOnDate('habit-id', targetDate);
      expect(foundCheckIn, isNotNull);
      expect(foundCheckIn!.id, 'test-id');
    });

    test('should return null for non-existent check-in', () async {
      final now = DateTime.now();
      final foundCheckIn = await repository.getCheckInForHabitOnDate('habit-id', now);
      expect(foundCheckIn, isNull);
    });

    test('should update a check-in', () async {
      final now = DateTime.now();
      final checkIn = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addCheckIn(checkIn);
      
      final updatedCheckIn = checkIn.copyWith(value: 2, updatedAt: now.add(const Duration(hours: 1)));
      await repository.updateCheckIn(updatedCheckIn);
      
      final savedCheckIn = await repository.getCheckInById('test-id');
      expect(savedCheckIn!.value, 2);
    });

    test('should delete a check-in', () async {
      final now = DateTime.now();
      final checkIn = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addCheckIn(checkIn);
      await repository.deleteCheckIn('test-id');
      
      final deletedCheckIn = await repository.getCheckInById('test-id');
      expect(deletedCheckIn, isNull);
    });

    test('should get check-ins count', () async {
      final now = DateTime.now();
      final checkIn1 = CheckIn(
        id: 'test-id-1',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      final checkIn2 = CheckIn(
        id: 'test-id-2',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addCheckIn(checkIn1);
      await repository.addCheckIn(checkIn2);
      
      final count = await repository.getCheckInsCount();
      expect(count, 2);
    });

    test('should get check-ins count for specific habit', () async {
      final now = DateTime.now();
      final checkIn1 = CheckIn(
        id: 'test-id-1',
        habitId: 'habit-id-1',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      final checkIn2 = CheckIn(
        id: 'test-id-2',
        habitId: 'habit-id-1',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      final checkIn3 = CheckIn(
        id: 'test-id-3',
        habitId: 'habit-id-2',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addCheckIn(checkIn1);
      await repository.addCheckIn(checkIn2);
      await repository.addCheckIn(checkIn3);
      
      final count1 = await repository.getCheckInsCountForHabit('habit-id-1');
      final count2 = await repository.getCheckInsCountForHabit('habit-id-2');
      
      expect(count1, 2);
      expect(count2, 1);
    });

    test('should clear all check-ins', () async {
      final now = DateTime.now();
      final checkIn = CheckIn(
        id: 'test-id',
        habitId: 'habit-id',
        date: now,
        value: 1,
        createdAt: now,
        updatedAt: now,
      );

      await repository.addCheckIn(checkIn);
      await repository.clearAllCheckIns();
      
      final count = await repository.getCheckInsCount();
      expect(count, 0);
    });
  });
}
