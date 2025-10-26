import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for initializing Hive in tests
class HiveTestHelper {
  static bool _isInitialized = false;

  /// Initialize Hive for testing
  static Future<void> initializeHive() async {
    if (_isInitialized) return;

    // Initialize Hive with a test directory
    await Hive.initFlutter('test_hive');
    
    // Register adapters for test data
    // Note: In a real app, these would be registered in main.dart
    // For tests, we need to register them manually
    
    _isInitialized = true;
  }

  /// Clean up Hive after tests
  static Future<void> cleanupHive() async {
    if (!_isInitialized) return;

    // Close all boxes
    await Hive.close();
    _isInitialized = false;
  }

  /// Setup for individual test
  static Future<void> setUp() async {
    await initializeHive();
  }

  /// Teardown for individual test
  static Future<void> tearDown() async {
    // Clean up any open boxes but keep Hive initialized for other tests
    // Note: In newer versions of Hive, we need to track boxes differently
    // For now, we'll just close the specific boxes we know about
    try {
      if (Hive.isBoxOpen('habits')) {
        await Hive.box('habits').close();
      }
      if (Hive.isBoxOpen('check_ins')) {
        await Hive.box('check_ins').close();
      }
    } catch (e) {
      // Ignore errors if boxes don't exist
    }
  }
}
