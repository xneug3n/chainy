import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/app_logger.dart';
import '../models/achievement_interface.dart';
import '../services/achievement_service.dart';
import '../data/achievement_repository.dart';

part 'achievement_provider.g.dart';

/// Achievement data class containing achievement with its status
class AchievementWithStatus {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;

  const AchievementWithStatus({
    required this.achievement,
    required this.isUnlocked,
    required this.progress,
  });
}

/// Provider for managing achievements and their unlock status
@riverpod
class AchievementProvider extends _$AchievementProvider {
  @override
  Future<List<AchievementWithStatus>> build() async {
    AppLogger.functionEntry('AchievementProvider.build', tag: 'AchievementProvider');
    
    try {
      final service = ref.read(achievementServiceProvider.notifier);
      final repository = ref.read(achievementRepositoryProvider.notifier);
      
      // Get all predefined achievements from service
      final allAchievements = service.getAllAchievements();
      
      // Get unlocked achievements from repository
      final unlockedAchievements = await repository.getUnlockedAchievements();
      
      // Build list with status for each achievement
      final List<AchievementWithStatus> achievementsWithStatus = [];
      
      for (final achievement in allAchievements) {
        final isUnlocked = unlockedAchievements.contains(achievement.id);
        final progress = await service.getProgress(achievement.id);
        
        // Check if achievement should be unlocked but isn't yet
        if (!isUnlocked && progress >= 1.0) {
          AppLogger.info('Achievement unlocked automatically', 
            data: {'achievementId': achievement.id},
            tag: 'AchievementProvider');
          await repository.unlockAchievement(achievement.id);
          achievementsWithStatus.add(AchievementWithStatus(
            achievement: achievement,
            isUnlocked: true,
            progress: 1.0,
          ));
        } else {
          achievementsWithStatus.add(AchievementWithStatus(
            achievement: achievement,
            isUnlocked: isUnlocked,
            progress: progress,
          ));
        }
      }
      
      AppLogger.info('Achievements loaded', 
        data: {
          'total': achievementsWithStatus.length,
          'unlocked': achievementsWithStatus.where((a) => a.isUnlocked).length,
        },
        tag: 'AchievementProvider');
      
      AppLogger.functionExit('AchievementProvider.build', tag: 'AchievementProvider');
      
      return achievementsWithStatus;
    } catch (error, stack) {
      AppLogger.error(
        'Failed to load achievements',
        error: error,
        stackTrace: stack,
        tag: 'AchievementProvider',
      );
      rethrow;
    }
  }

  /// Get all achievements (for backward compatibility)
  List<Achievement> get allAchievements {
    final currentState = state;
    if (!currentState.hasValue) {
      return [];
    }
    return currentState.value!.map((a) => a.achievement).toList();
  }

  /// Check if an achievement is unlocked
  bool isUnlocked(String achievementId) {
    final currentState = state;
    if (!currentState.hasValue) {
      return false;
    }
    final achievement = currentState.value!.firstWhere(
      (a) => a.achievement.id == achievementId,
      orElse: () => throw StateError('Achievement not found: $achievementId'),
    );
    return achievement.isUnlocked;
  }

  /// Get progress for an achievement (0.0 to 1.0)
  double getProgress(String achievementId) {
    final currentState = state;
    if (!currentState.hasValue) {
      return 0.0;
    }
    try {
      final achievement = currentState.value!.firstWhere(
        (a) => a.achievement.id == achievementId,
      );
      return achievement.progress;
    } catch (e) {
      return 0.0;
    }
  }

  /// Refresh achievements (recalculate progress and check for new unlocks)
  Future<void> refresh() async {
    AppLogger.debug('Refreshing achievements', tag: 'AchievementProvider');
    ref.invalidateSelf();
  }
}

