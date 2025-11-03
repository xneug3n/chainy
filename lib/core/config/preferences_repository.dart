import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/app_logger.dart';

part 'preferences_repository.g.dart';

/// Repository for managing app preferences (user name, onboarding status, etc.)
@riverpod
class PreferencesRepository extends _$PreferencesRepository {
  static const String _boxName = 'preferences';
  static const String _userNameKey = 'user_name';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  Box? _box;

  @override
  Future<void> build() async {
    await _ensureBoxInitialized();
  }

  /// Ensure the Hive box is initialized
  Future<void> _ensureBoxInitialized() async {
    AppLogger.debug('_ensureBoxInitialized called', tag: 'PreferencesRepository');
    
    if (_box != null) {
      AppLogger.debug('Box already initialized', tag: 'PreferencesRepository');
      return;
    }
    
    if (Hive.isBoxOpen(_boxName)) {
      AppLogger.debug('Box is already open, getting reference', tag: 'PreferencesRepository');
      _box = Hive.box(_boxName);
      AppLogger.info('Box reference obtained from open box', tag: 'PreferencesRepository');
    } else {
      AppLogger.debug('Box is not open, opening box', data: {'boxName': _boxName}, tag: 'PreferencesRepository');
      try {
        _box = await Hive.openBox(_boxName);
        AppLogger.info('Box opened successfully', 
          data: {'boxName': _boxName, 'boxLength': _box?.length}, 
          tag: 'PreferencesRepository');
      } catch (error, stack) {
        AppLogger.error(
          'Failed to open Hive box',
          error: error,
          stackTrace: stack,
          tag: 'PreferencesRepository',
          context: {'boxName': _boxName},
        );
        rethrow;
      }
    }
  }

  /// Get user name
  String? getUserName() {
    if (_box == null) {
      AppLogger.warning('Box is null when getting user name', tag: 'PreferencesRepository');
      return null;
    }
    return _box!.get(_userNameKey) as String?;
  }

  /// Save user name
  Future<void> saveUserName(String name) async {
    await _ensureBoxInitialized();
    if (_box == null) {
      AppLogger.error('Box is null when saving user name', tag: 'PreferencesRepository');
      throw StateError('Preferences box is not initialized');
    }
    
    AppLogger.info('Saving user name', data: {'name': name}, tag: 'PreferencesRepository');
    await _box!.put(_userNameKey, name);
    AppLogger.info('User name saved successfully', tag: 'PreferencesRepository');
  }

  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    if (_box == null) {
      AppLogger.debug('Box is null when checking onboarding status, returning false', tag: 'PreferencesRepository');
      return false;
    }
    return _box!.get(_onboardingCompletedKey, defaultValue: false) as bool;
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    await _ensureBoxInitialized();
    if (_box == null) {
      AppLogger.error('Box is null when setting onboarding status', tag: 'PreferencesRepository');
      throw StateError('Preferences box is not initialized');
    }
    
    AppLogger.info('Setting onboarding completed', data: {'completed': completed}, tag: 'PreferencesRepository');
    await _box!.put(_onboardingCompletedKey, completed);
    AppLogger.info('Onboarding status saved successfully', tag: 'PreferencesRepository');
  }
}

