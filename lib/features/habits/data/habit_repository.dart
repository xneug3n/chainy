import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/habit.dart';
import 'models/habit_dto.dart';

part 'habit_repository.g.dart';

/// Repository for managing habit data persistence
@riverpod
class HabitRepository extends _$HabitRepository {
  static const String _boxName = 'habits';
  Box<HabitDto>? _box;

  @override
  Future<List<Habit>> build() async {
    await _ensureBoxInitialized();
    return _getAllHabits();
  }

  /// Ensure the Hive box is initialized
  Future<void> _ensureBoxInitialized() async {
    if (_box != null) return;
    
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<HabitDto>(_boxName);
    } else {
      _box = await Hive.openBox<HabitDto>(_boxName);
    }
  }

  /// Get all habits
  List<Habit> _getAllHabits() {
    if (_box == null) {
      throw StateError('Hive box not initialized. Call _ensureBoxInitialized() first.');
    }
    return _box!.values.map((dto) => dto.toDomain()).toList();
  }

  /// Get all habits as async
  Future<List<Habit>> getAllHabits() async {
    await _ensureBoxInitialized();
    return _getAllHabits();
  }

  /// Get a specific habit by ID
  Future<Habit?> getHabitById(String id) async {
    await _ensureBoxInitialized();
    final dto = _box!.get(id);
    return dto?.toDomain();
  }

  /// Save a habit (create or update)
  Future<void> saveHabit(Habit habit) async {
    await _ensureBoxInitialized();
    final dto = HabitDto.fromDomain(habit);
    await _box!.put(habit.id, dto);
    ref.invalidateSelf();
  }

  /// Delete a habit
  Future<void> deleteHabit(String id) async {
    await _ensureBoxInitialized();
    await _box!.delete(id);
    ref.invalidateSelf();
  }

  /// Get habits by recurrence type
  Future<List<Habit>> getHabitsByRecurrenceType(RecurrenceType type) async {
    await _ensureBoxInitialized();
    final allHabits = _getAllHabits();
    return allHabits.where((habit) => habit.recurrenceType == type).toList();
  }

  /// Get habits created after a specific date
  Future<List<Habit>> getHabitsCreatedAfter(DateTime date) async {
    await _ensureBoxInitialized();
    final allHabits = _getAllHabits();
    return allHabits.where((habit) => habit.createdAt.isAfter(date)).toList();
  }

  /// Search habits by name
  Future<List<Habit>> searchHabits(String query) async {
    await _ensureBoxInitialized();
    final allHabits = _getAllHabits();
    return allHabits
        .where((habit) => habit.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get habits count
  Future<int> getHabitsCount() async {
    await _ensureBoxInitialized();
    return _box!.length;
  }

  /// Clear all habits (for testing)
  Future<void> clearAllHabits() async {
    await _ensureBoxInitialized();
    await _box!.clear();
    ref.invalidateSelf();
  }
}
