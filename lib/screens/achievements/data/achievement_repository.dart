import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/app_logger.dart';

part 'achievement_repository.g.dart';

/// Repository for managing unlocked achievement persistence
@riverpod
class AchievementRepository extends _$AchievementRepository {
  static const String _boxName = 'achievements';
  static const String _unlockedKey = 'unlocked_achievements';
  Box? _box;

  @override
  Future<Set<String>> build() async {
    await _ensureBoxInitialized();
    return _getUnlockedAchievements();
  }

  /// Ensure the Hive box is initialized
  Future<void> _ensureBoxInitialized() async {
    AppLogger.debug('_ensureBoxInitialized called', tag: 'AchievementRepository');
    
    if (_box != null) {
      AppLogger.debug('Box already initialized', tag: 'AchievementRepository');
      return;
    }
    
    if (Hive.isBoxOpen(_boxName)) {
      AppLogger.debug('Box is already open, getting reference', tag: 'AchievementRepository');
      _box = Hive.box(_boxName);
      AppLogger.info('Box reference obtained from open box', tag: 'AchievementRepository');
    } else {
      AppLogger.debug('Box is not open, opening box', data: {'boxName': _boxName}, tag: 'AchievementRepository');
      try {
        _box = await Hive.openBox(_boxName);
        AppLogger.info('Box opened successfully', 
          data: {'boxName': _boxName, 'boxLength': _box?.length}, 
          tag: 'AchievementRepository');
      } catch (error, stack) {
        AppLogger.error(
          'Failed to open Hive box',
          error: error,
          stackTrace: stack,
          tag: 'AchievementRepository',
          context: {'boxName': _boxName},
        );
        rethrow;
      }
    }
  }

  /// Get all unlocked achievement IDs
  Set<String> _getUnlockedAchievements() {
    AppLogger.functionEntry('AchievementRepository._getUnlockedAchievements', tag: 'AchievementRepository');
    
    if (_box == null) {
      final error = StateError('Hive box not initialized. Call _ensureBoxInitialized() first.');
      AppLogger.error('Box not initialized', error: error, tag: 'AchievementRepository');
      throw error;
    }
    
    final unlockedList = _box!.get(_unlockedKey, defaultValue: <String>[]) as List<dynamic>?;
    final unlockedSet = unlockedList?.map((e) => e.toString()).toSet() ?? <String>{};
    
    AppLogger.info('Retrieved unlocked achievements', 
      data: {'count': unlockedSet.length}, 
      tag: 'AchievementRepository');
    
    return unlockedSet;
  }

  /// Get all unlocked achievement IDs as async
  Future<Set<String>> getUnlockedAchievements() async {
    await _ensureBoxInitialized();
    return _getUnlockedAchievements();
  }

  /// Check if an achievement is unlocked
  Future<bool> isUnlocked(String achievementId) async {
    await _ensureBoxInitialized();
    final unlocked = _getUnlockedAchievements();
    return unlocked.contains(achievementId);
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(String achievementId) async {
    final startTime = DateTime.now();
    AppLogger.functionEntry(
      'AchievementRepository.unlockAchievement',
      params: {'achievementId': achievementId},
      tag: 'AchievementRepository',
    );

    try {
      await _ensureBoxInitialized();
      
      if (_box == null) {
        final error = StateError('Hive box is null after initialization');
        AppLogger.error(
          'Box is null after initialization',
          error: error,
          tag: 'AchievementRepository',
          context: {'boxName': _boxName},
        );
        throw error;
      }
      
      final unlocked = _getUnlockedAchievements();
      if (unlocked.contains(achievementId)) {
        AppLogger.debug('Achievement already unlocked', 
          data: {'achievementId': achievementId},
          tag: 'AchievementRepository');
        return;
      }
      
      unlocked.add(achievementId);
      await _box!.put(_unlockedKey, unlocked.toList());
      
      AppLogger.info('Achievement unlocked successfully', 
        data: {'achievementId': achievementId}, 
        tag: 'AchievementRepository');
      
      ref.invalidateSelf();
      
      final duration = DateTime.now().difference(startTime);
      AppLogger.functionExit('AchievementRepository.unlockAchievement', 
        result: {'achievementId': achievementId, 'success': true}, 
        tag: 'AchievementRepository',
        duration: duration);
    } catch (error, stack) {
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.error(
        'Failed to unlock achievement',
        error: error,
        stackTrace: stack,
        tag: 'AchievementRepository',
        context: {
          'achievementId': achievementId,
          'duration': '${duration.inMilliseconds}ms',
        },
      );
      
      rethrow;
    }
  }

  /// Clear all unlocked achievements (for testing)
  Future<void> clearAll() async {
    AppLogger.functionEntry('AchievementRepository.clearAll', tag: 'AchievementRepository');
    
    await _ensureBoxInitialized();
    await _box!.put(_unlockedKey, <String>[]);
    ref.invalidateSelf();
    
    AppLogger.info('All achievements cleared', tag: 'AchievementRepository');
    AppLogger.functionExit('AchievementRepository.clearAll', tag: 'AchievementRepository');
  }
}

