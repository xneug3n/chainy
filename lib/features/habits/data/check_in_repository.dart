import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/check_in.dart';
import 'models/check_in_dto.dart';

part 'check_in_repository.g.dart';

/// Repository for managing check-in data persistence
@riverpod
class CheckInRepository extends _$CheckInRepository {
  static const String _boxName = 'check_ins';
  late Box<CheckInDto> _box;

  @override
  Future<List<CheckIn>> build() async {
    _box = await Hive.openBox<CheckInDto>(_boxName);
    return _getAllCheckIns();
  }

  /// Get all check-ins
  List<CheckIn> _getAllCheckIns() {
    return _box.values.map((dto) => dto.toDomain()).toList();
  }

  /// Get all check-ins as async
  Future<List<CheckIn>> getAllCheckIns() async {
    return _getAllCheckIns();
  }

  /// Get a specific check-in by ID
  Future<CheckIn?> getCheckInById(String id) async {
    final dto = _box.get(id);
    return dto?.toDomain();
  }

  /// Get check-ins for a specific habit
  Future<List<CheckIn>> getCheckInsForHabit(String habitId) async {
    final allCheckIns = _getAllCheckIns();
    return allCheckIns
        .where((checkIn) => checkIn.habitId == habitId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get check-ins by date range for a specific habit
  Future<List<CheckIn>> getCheckInsByDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final habitCheckIns = await getCheckInsForHabit(habitId);
    return habitCheckIns
        .where((checkIn) =>
            checkIn.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            checkIn.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  /// Save a check-in (create or update)
  Future<void> addCheckIn(CheckIn checkIn) async {
    final dto = CheckInDto.fromDomain(checkIn);
    await _box.put(checkIn.id, dto);
    ref.invalidateSelf();
  }

  /// Update a check-in
  Future<void> updateCheckIn(CheckIn checkIn) async {
    final dto = CheckInDto.fromDomain(checkIn);
    await _box.put(checkIn.id, dto);
    ref.invalidateSelf();
  }

  /// Delete a check-in
  Future<void> deleteCheckIn(String id) async {
    await _box.delete(id);
    ref.invalidateSelf();
  }

  /// Get check-ins for a specific date
  Future<List<CheckIn>> getCheckInsForDate(DateTime date) async {
    final allCheckIns = _getAllCheckIns();
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return allCheckIns
        .where((checkIn) {
          final checkInDate = DateTime(
            checkIn.date.year,
            checkIn.date.month,
            checkIn.date.day,
          );
          return checkInDate.isAtSameMomentAs(targetDate);
        })
        .toList();
  }

  /// Get check-ins for a specific habit on a specific date
  Future<CheckIn?> getCheckInForHabitOnDate(String habitId, DateTime date) async {
    final habitCheckIns = await getCheckInsForHabit(habitId);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    for (final checkIn in habitCheckIns) {
      final checkInDate = DateTime(
        checkIn.date.year,
        checkIn.date.month,
        checkIn.date.day,
      );
      if (checkInDate.isAtSameMomentAs(targetDate)) {
        return checkIn;
      }
    }
    return null;
  }

  /// Get check-ins count
  Future<int> getCheckInsCount() async {
    return _box.length;
  }

  /// Get check-ins count for a specific habit
  Future<int> getCheckInsCountForHabit(String habitId) async {
    final habitCheckIns = await getCheckInsForHabit(habitId);
    return habitCheckIns.length;
  }

  /// Clear all check-ins (for testing)
  Future<void> clearAllCheckIns() async {
    await _box.clear();
    ref.invalidateSelf();
  }
}
