import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/habit.dart';
import 'models/habit_dto.dart';

part 'habit_repository.g.dart';

/// Repository for managing habit data persistence
@riverpod
class HabitRepository extends _$HabitRepository {
  static const String _boxName = 'habits';
  late Box<HabitDto> _box;

  @override
  Future<List<Habit>> build() async {
    _box = await Hive.openBox<HabitDto>(_boxName);
    return _getAllHabits();
  }

  /// Get all habits
  List<Habit> _getAllHabits() {
    return _box.values.map((dto) => dto.toDomain()).toList();
  }

  /// Get all habits as async
  Future<List<Habit>> getAllHabits() async {
    return _getAllHabits();
  }

  /// Get a specific habit by ID
  Future<Habit?> getHabitById(String id) async {
    final dto = _box.get(id);
    return dto?.toDomain();
  }

  /// Save a habit (create or update)
  Future<void> saveHabit(Habit habit) async {
    final dto = HabitDto.fromDomain(habit);
    await _box.put(habit.id, dto);
    ref.invalidateSelf();
  }

  /// Delete a habit
  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
    ref.invalidateSelf();
  }

  /// Get habits by recurrence type
  Future<List<Habit>> getHabitsByRecurrenceType(RecurrenceType type) async {
    final allHabits = _getAllHabits();
    return allHabits.where((habit) => habit.recurrenceType == type).toList();
  }

  /// Get habits created after a specific date
  Future<List<Habit>> getHabitsCreatedAfter(DateTime date) async {
    final allHabits = _getAllHabits();
    return allHabits.where((habit) => habit.createdAt.isAfter(date)).toList();
  }

  /// Search habits by name
  Future<List<Habit>> searchHabits(String query) async {
    final allHabits = _getAllHabits();
    return allHabits
        .where((habit) => habit.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get habits count
  Future<int> getHabitsCount() async {
    return _box.length;
  }

  /// Clear all habits (for testing)
  Future<void> clearAllHabits() async {
    await _box.clear();
    ref.invalidateSelf();
  }
}
