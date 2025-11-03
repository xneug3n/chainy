import 'package:flutter/foundation.dart';

/// Centralized logging utility for the app
class AppLogger {
  static const String _prefix = '[Chainy]';
  static String get _separator => List.generate(80, (_) => '─').join();
  
  /// Global flag to temporarily disable all logging
  static bool enabled = false;

  /// Log debug information
  static void debug(String message, {Object? data, String? tag}) {
    if (kDebugMode && enabled) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix $tagStr $timestamp | DEBUG: $message');
      if (data != null) {
        debugPrint('$_prefix $tagStr Data: $data');
      }
    }
  }

  /// Log information
  static void info(String message, {Object? data, String? tag}) {
    if (kDebugMode && enabled) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix $tagStr $timestamp | INFO: $message');
      if (data != null) {
        debugPrint('$_prefix $tagStr Data: $data');
      }
    }
  }

  /// Log warnings
  static void warning(String message, {Object? data, String? tag, StackTrace? stackTrace}) {
    if (kDebugMode && enabled) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix $tagStr $timestamp | ⚠️ WARNING: $message');
      if (data != null) {
        debugPrint('$_prefix $tagStr Data: $data');
      }
      if (stackTrace != null) {
        debugPrint('$_prefix $tagStr StackTrace: $stackTrace');
      }
    }
  }

  /// Log errors with full context
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
    Map<String, dynamic>? context,
  }) {
    if (kDebugMode && enabled) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('');
      debugPrint(_separator);
      debugPrint('$_prefix $tagStr $timestamp | ❌ ERROR: $message');
      if (error != null) {
        debugPrint('$_prefix $tagStr Error Type: ${error.runtimeType}');
        debugPrint('$_prefix $tagStr Error: $error');
      }
      if (context != null && context.isNotEmpty) {
        debugPrint('$_prefix $tagStr Context:');
        context.forEach((key, value) {
          debugPrint('$_prefix $tagStr   $key: $value');
        });
      }
      if (stackTrace != null) {
        debugPrint('$_prefix $tagStr StackTrace:');
        debugPrint(stackTrace.toString());
      }
      debugPrint(_separator);
      debugPrint('');
    }
  }

  /// Log function entry
  static void functionEntry(String functionName, {Map<String, dynamic>? params, String? tag}) {
    if (kDebugMode && enabled) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix $tagStr $timestamp | → ENTRY: $functionName');
      if (params != null && params.isNotEmpty) {
        debugPrint('$_prefix $tagStr Parameters:');
        params.forEach((key, value) {
          debugPrint('$_prefix $tagStr   $key: $value');
        });
      }
    }
  }

  /// Log function exit
  static void functionExit(String functionName, {Object? result, String? tag, Duration? duration}) {
    if (kDebugMode && enabled) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag]' : '';
      final durationStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
      debugPrint('$_prefix $tagStr $timestamp | ← EXIT: $functionName$durationStr');
      if (result != null) {
        debugPrint('$_prefix $tagStr Result: $result');
      }
    }
  }

  /// Log section separator
  static void separator(String label, {String? tag}) {
    if (kDebugMode && enabled) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('');
      debugPrint('$_prefix $tagStr $_separator');
      debugPrint('$_prefix $tagStr $label');
      debugPrint('$_prefix $tagStr $_separator');
      debugPrint('');
    }
  }
}

