import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/app_logger.dart';
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
    AppLogger.debug('_ensureBoxInitialized called', tag: 'HabitRepository');
    
    if (_box != null) {
      AppLogger.debug('Box already initialized', tag: 'HabitRepository');
      return;
    }
    
    AppLogger.debug('Box not initialized, checking if box is open', 
      data: {'boxName': _boxName, 'isBoxOpen': Hive.isBoxOpen(_boxName)}, 
      tag: 'HabitRepository');
    
    if (Hive.isBoxOpen(_boxName)) {
      AppLogger.debug('Box is already open, getting reference', tag: 'HabitRepository');
      _box = Hive.box<HabitDto>(_boxName);
      AppLogger.info('Box reference obtained from open box', tag: 'HabitRepository');
    } else {
      AppLogger.debug('Box is not open, opening box', data: {'boxName': _boxName}, tag: 'HabitRepository');
      try {
        _box = await Hive.openBox<HabitDto>(_boxName);
        AppLogger.info('Box opened successfully', 
          data: {'boxName': _boxName, 'boxLength': _box?.length}, 
          tag: 'HabitRepository');
      } catch (error, stack) {
        AppLogger.error(
          'Failed to open Hive box',
          error: error,
          stackTrace: stack,
          tag: 'HabitRepository',
          context: {'boxName': _boxName},
        );
        rethrow;
      }
    }
    
    AppLogger.debug('Box initialization complete', 
      data: {'boxName': _boxName, 'boxIsNull': _box == null}, 
      tag: 'HabitRepository');
  }

  /// Get all habits
  List<Habit> _getAllHabits() {
    AppLogger.functionEntry('HabitRepository._getAllHabits', tag: 'HabitRepository');
    
    if (_box == null) {
      final error = StateError('Hive box not initialized. Call _ensureBoxInitialized() first.');
      AppLogger.error('Box not initialized', error: error, tag: 'HabitRepository');
      throw error;
    }
    
    AppLogger.debug('Starting to convert DTOs to domain models', 
      data: {'boxLength': _box!.length}, 
      tag: 'HabitRepository');
    
    final habits = <Habit>[];
    int index = 0;
    
    for (final dto in _box!.values) {
      try {
        AppLogger.debug('Converting DTO to domain', 
          data: {'index': index, 'total': _box!.length, 'habitId': dto.id, 'name': dto.name}, 
          tag: 'HabitRepository');
        
        final habit = dto.toDomain();
        habits.add(habit);
        
        AppLogger.debug('Successfully converted DTO', 
          data: {'habitId': habit.id, 'name': habit.name}, 
          tag: 'HabitRepository');
      } catch (e, stack) {
        AppLogger.error('Failed to convert DTO to domain model, skipping habit', 
          error: e, 
          stackTrace: stack, 
          tag: 'HabitRepository',
          context: {
            'index': index,
            'total': _box!.length,
            'habitId': dto.id,
            'name': dto.name,
            'createdAt': dto.createdAt,
            'updatedAt': dto.updatedAt,
            'recurrenceConfig': dto.recurrenceConfig.toString(),
          });
        // Skip invalid habits instead of crashing
        continue;
      }
      index++;
    }
    
    AppLogger.info('Finished converting DTOs to domain models', 
      data: {'totalDTOs': _box!.length, 'successfulConversions': habits.length}, 
      tag: 'HabitRepository');
    
    AppLogger.functionExit('HabitRepository._getAllHabits', 
      result: {'habitsCount': habits.length}, 
      tag: 'HabitRepository');
    
    return habits;
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
    final startTime = DateTime.now();
    AppLogger.functionEntry(
      'HabitRepository.saveHabit',
      params: {
        'habitId': habit.id,
        'name': habit.name,
        'goalType': habit.goalType.toString(),
      },
      tag: 'HabitRepository',
    );

    try {
      // Ensure box is initialized
      AppLogger.debug('Ensuring box is initialized', tag: 'HabitRepository');
      await _ensureBoxInitialized();
      
      if (_box == null) {
        final error = StateError('Hive box is null after initialization');
        AppLogger.error(
          'Box is null after initialization',
          error: error,
          tag: 'HabitRepository',
          context: {'boxName': _boxName},
        );
        throw error;
      }
      
      AppLogger.debug('Box is initialized and available', 
        data: {'boxLength': _box!.length}, 
        tag: 'HabitRepository');

      // Convert domain model to DTO
      AppLogger.debug('Converting Habit domain model to DTO', tag: 'HabitRepository');
      HabitDto dto;
      try {
        dto = HabitDto.fromDomain(habit);
        AppLogger.debug('DTO conversion successful', 
          data: {'dtoId': dto.id, 'dtoName': dto.name}, 
          tag: 'HabitRepository');
      } catch (error, stack) {
        AppLogger.error(
          'Failed to convert Habit to DTO',
          error: error,
          stackTrace: stack,
          tag: 'HabitRepository',
          context: {'habitId': habit.id, 'habitName': habit.name},
        );
        rethrow;
      }

      // Save to Hive
      AppLogger.debug('Saving DTO to Hive box', 
        data: {'habitId': habit.id, 'boxName': _boxName}, 
        tag: 'HabitRepository');
      try {
        await _box!.put(habit.id, dto);
        AppLogger.info('Habit saved to Hive successfully', 
          data: {'habitId': habit.id, 'newBoxLength': _box!.length}, 
          tag: 'HabitRepository');
      } catch (error, stack) {
        AppLogger.error(
          'Failed to save habit to Hive box',
          error: error,
          stackTrace: stack,
          tag: 'HabitRepository',
          context: {
            'habitId': habit.id,
            'boxName': _boxName,
            'boxLength': _box!.length,
          },
        );
        rethrow;
      }

      // Verify save
      final verifyDto = _box!.get(habit.id);
      if (verifyDto == null) {
        AppLogger.error(
          'Habit save verification failed: DTO not found in box after save',
          tag: 'HabitRepository',
          context: {
            'habitId': habit.id,
            'boxName': _boxName,
            'boxLength': _box!.length,
          },
        );
        throw StateError('Habit was not found in box after save operation');
      }
      AppLogger.debug('Habit save verified: DTO found in box', 
        data: {'habitId': habit.id}, 
        tag: 'HabitRepository');

      // Invalidate repository provider
      AppLogger.debug('Invalidating HabitRepository provider', tag: 'HabitRepository');
      ref.invalidateSelf();
      AppLogger.info('HabitRepository invalidated', tag: 'HabitRepository');

      final duration = DateTime.now().difference(startTime);
      AppLogger.functionExit('HabitRepository.saveHabit', 
        result: {'habitId': habit.id, 'success': true}, 
        tag: 'HabitRepository',
        duration: duration);
      AppLogger.info('✅ Habit saved to repository successfully', 
        data: {'habitId': habit.id, 'duration': '${duration.inMilliseconds}ms'}, 
        tag: 'HabitRepository');
    } catch (error, stack) {
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.error(
        'Failed to save habit to repository',
        error: error,
        stackTrace: stack,
        tag: 'HabitRepository',
        context: {
          'habitId': habit.id,
          'habitName': habit.name,
          'boxName': _boxName,
          'boxIsNull': _box == null,
          'boxLength': _box?.length,
          'duration': '${duration.inMilliseconds}ms',
        },
      );
      
      AppLogger.functionExit('HabitRepository.saveHabit', 
        tag: 'HabitRepository',
        duration: duration);
      rethrow;
    }
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

  /// Clear all habits (for testing or migration)
  Future<void> clearAllHabits() async {
    AppLogger.functionEntry('HabitRepository.clearAllHabits', tag: 'HabitRepository');
    
    await _ensureBoxInitialized();
    
    final boxLength = _box!.length;
    AppLogger.info('Clearing all habits', data: {'habitsCount': boxLength}, tag: 'HabitRepository');
    
    await _box!.clear();
    ref.invalidateSelf();
    
    AppLogger.info('All habits cleared successfully', 
      data: {'previousCount': boxLength, 'newLength': _box!.length}, 
      tag: 'HabitRepository');
    
    AppLogger.functionExit('HabitRepository.clearAllHabits', tag: 'HabitRepository');
  }
}
