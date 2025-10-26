import 'package:hive_flutter/hive_flutter.dart';
import '../../features/habits/data/models/habit_dto.dart';

/// Initialize Hive database with all required adapters
class HiveSetup {
  static bool _initialized = false;

  /// Initialize Hive with all adapters
  static Future<void> initialize() async {
    if (_initialized) return;
    
    await Hive.initFlutter();
    
    // Register adapters - using the generated adapter from habit_dto.dart
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitDtoAdapter());
    }
    
    _initialized = true;
  }

  /// Initialize Hive for testing (without Flutter dependencies)
  static Future<void> initializeForTesting() async {
    if (_initialized) return;
    
    // Register adapters - using the generated adapter from habit_dto.dart
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitDtoAdapter());
    }
    
    _initialized = true;
  }

  /// Check if Hive is initialized
  static bool get isInitialized => _initialized;

  /// Close all Hive boxes (for testing)
  static Future<void> closeAll() async {
    await Hive.close();
    _initialized = false;
  }
}
