import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/navigation/global_navigator.dart';
import '../../data/habit_repository.dart';
import '../../presentation/widgets/snooze_dialog.dart';

part 'reminder_service.g.dart';

/// Service for managing habit reminder notifications
@riverpod
class ReminderService extends _$ReminderService {
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  bool _initialized = false;

  @override
  Future<bool> build() async {
    if (_initialized) return true;
    
    AppLogger.functionEntry('ReminderService.build', tag: 'ReminderService');
    
    try {
      await initialize();
      AppLogger.functionExit('ReminderService.build', tag: 'ReminderService');
      return _initialized;
    } catch (error, stack) {
      AppLogger.error(
        'Failed to initialize ReminderService',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
      );
      return false;
    }
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) {
      AppLogger.debug('ReminderService already initialized', tag: 'ReminderService');
      return;
    }

    AppLogger.functionEntry('ReminderService.initialize', tag: 'ReminderService');

    try {
      // Initialize timezone database
      tz.initializeTimeZones();
      AppLogger.debug('Timezone database initialized', tag: 'ReminderService');

      // Create notification plugin instance
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      
      // Request permissions
      final permissionsGranted = await _requestPermissions();
      if (permissionsGranted == false) {
        AppLogger.warning(
          'Notification permissions not granted',
          tag: 'ReminderService',
        );
        // Continue anyway - permissions might be requested later
      }

      // Initialize Android settings
      const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Initialize iOS settings
      const darwinInitializationSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      // Initialize notification settings
      const initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings,
      );

      // Initialize the plugin
      final initialized = await _flutterLocalNotificationsPlugin!.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized != true) {
        throw Exception('Failed to initialize FlutterLocalNotificationsPlugin');
      }

      // Create notification channel for Android
      await _createNotificationChannel();
      
      // Create notification action buttons for Android
      await _createNotificationActions();

      _initialized = true;
      AppLogger.info('ReminderService initialized successfully', tag: 'ReminderService');
    } catch (error, stack) {
      AppLogger.error(
        'Error initializing ReminderService',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
      );
      rethrow;
    } finally {
      AppLogger.functionExit('ReminderService.initialize', tag: 'ReminderService');
    }
  }

  /// Request notification permissions (public method for UI)
  /// Ensures service is initialized before requesting permissions
  Future<bool> requestPermissions() async {
    AppLogger.functionEntry('ReminderService.requestPermissions', tag: 'ReminderService');
    
    // Ensure service is initialized
    if (!_initialized) {
      AppLogger.debug('ReminderService not initialized, initializing now', tag: 'ReminderService');
      try {
        await initialize();
      } catch (error, stack) {
        AppLogger.error(
          'Error initializing ReminderService before permission request',
          error: error,
          stackTrace: stack,
          tag: 'ReminderService',
        );
        return false;
      }
    }
    
    return await _requestPermissions();
  }

  /// Request notification permissions (internal method)
  Future<bool> _requestPermissions() async {
    AppLogger.functionEntry('ReminderService._requestPermissions', tag: 'ReminderService');
    
    if (_flutterLocalNotificationsPlugin == null) {
      AppLogger.warning('Notification plugin not initialized', tag: 'ReminderService');
      return false;
    }

    try {
      // Android 13+ requires runtime permission
      final androidResult = await _flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // iOS requires permission request
      final iosResult = await _flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      final granted = androidResult ?? iosResult ?? false;
      AppLogger.info(
        'Notification permissions requested',
        data: {'granted': granted},
        tag: 'ReminderService',
      );
      
      return granted;
    } catch (error, stack) {
      AppLogger.error(
        'Error requesting notification permissions',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
      );
      return false;
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    AppLogger.functionEntry('ReminderService._createNotificationChannel', tag: 'ReminderService');
    
    if (_flutterLocalNotificationsPlugin == null) {
      AppLogger.warning('Notification plugin not initialized', tag: 'ReminderService');
      return;
    }

    try {
      final androidImplementation = _flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        // Use default importance to respect Do-Not-Disturb settings
        // Users can still customize this in system settings
        const androidChannel = AndroidNotificationChannel(
          'habit_reminders',
          'Habit Reminders',
          description: 'Notifications for habit reminders',
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: true,
        );

        await androidImplementation.createNotificationChannel(androidChannel);
        AppLogger.info('Notification channel created', tag: 'ReminderService');
      }
    } catch (error, stack) {
      AppLogger.error(
        'Error creating notification channel',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
      );
    } finally {
      AppLogger.functionExit('ReminderService._createNotificationChannel', tag: 'ReminderService');
    }
  }

  /// Create notification action buttons for Android
  Future<void> _createNotificationActions() async {
    AppLogger.functionEntry('ReminderService._createNotificationActions', tag: 'ReminderService');
    
    if (_flutterLocalNotificationsPlugin == null) {
      AppLogger.warning('Notification plugin not initialized', tag: 'ReminderService');
      return;
    }

    try {
      final androidImplementation = _flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        // Create notification channel group for organization
        await androidImplementation.createNotificationChannelGroup(
          const AndroidNotificationChannelGroup(
            'habit_reminders_group',
            'Habit Reminders',
          ),
        );

        AppLogger.info('Notification channel group created', tag: 'ReminderService');
      }
    } catch (error, stack) {
      AppLogger.error(
        'Error creating notification actions',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
      );
    } finally {
      AppLogger.functionExit('ReminderService._createNotificationActions', tag: 'ReminderService');
    }
  }

  /// Schedule a reminder notification
  Future<void> scheduleReminder({
    required String habitId,
    required String reminderId,
    required TimeOfDay time,
    required List<int> daysOfWeek,
  }) async {
    AppLogger.functionEntry(
      'ReminderService.scheduleReminder',
      params: {
        'habitId': habitId,
        'reminderId': reminderId,
        'time': '${time.hour}:${time.minute}',
        'daysOfWeek': daysOfWeek,
      },
      tag: 'ReminderService',
    );

    if (!_initialized) {
      AppLogger.warning(
        'ReminderService not initialized, cannot schedule reminder',
        tag: 'ReminderService',
      );
      return;
    }

    if (_flutterLocalNotificationsPlugin == null) {
      AppLogger.warning(
        'Notification plugin not initialized',
        tag: 'ReminderService',
      );
      return;
    }

    try {
      final habitRepo = ref.read(habitRepositoryProvider.notifier);
      final habit = await habitRepo.getHabitById(habitId);
      if (habit == null) {
        AppLogger.warning(
          'Habit not found',
          data: {'habitId': habitId},
          tag: 'ReminderService',
        );
        return;
      }

      // Create unique notification ID
      final notificationId = _generateNotificationId(habitId, reminderId);

      // Android notification actions for quick snooze
      const snooze15Action = AndroidNotificationAction(
        'snooze_15',
        'Snooze 15 min',
        titleColor: Color(0xFF2196F3),
        showsUserInterface: false,
      );

      const snooze1HourAction = AndroidNotificationAction(
        'snooze_1hour',
        'Snooze 1 hour',
        titleColor: Color(0xFF2196F3),
        showsUserInterface: false,
      );

      // Android notification details with actions
      final androidDetails = AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Notifications for habit reminders',
        importance: Importance.defaultImportance, // Respects Do-Not-Disturb
        priority: Priority.defaultPriority,
        color: const Color(0xFF2196F3),
        playSound: true,
        enableVibration: true,
        actions: [snooze15Action, snooze1HourAction],
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule for each day of week
      for (final dayOfWeek in daysOfWeek) {
        final scheduledDate = _nextInstanceOfTime(time, dayOfWeek);
        if (scheduledDate == null) continue;

        await _flutterLocalNotificationsPlugin!.zonedSchedule(
          notificationId + dayOfWeek, // Unique ID per day
          habit.name,
          'Time to ${habit.name}!',
          scheduledDate,
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: jsonEncode({
            'habitId': habitId,
            'reminderId': reminderId,
            'dayOfWeek': dayOfWeek,
          }),
        );
      }

      AppLogger.info(
        'Reminder scheduled successfully',
        data: {
          'habitId': habitId,
          'reminderId': reminderId,
          'daysScheduled': daysOfWeek.length,
        },
        tag: 'ReminderService',
      );
    } catch (error, stack) {
      AppLogger.error(
        'Error scheduling reminder',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
        context: {'habitId': habitId, 'reminderId': reminderId},
      );
    } finally {
      AppLogger.functionExit('ReminderService.scheduleReminder', tag: 'ReminderService');
    }
  }

  /// Cancel a reminder notification
  Future<void> cancelReminder({
    required String habitId,
    required String reminderId,
    List<int>? daysOfWeek,
  }) async {
    AppLogger.functionEntry(
      'ReminderService.cancelReminder',
      params: {
        'habitId': habitId,
        'reminderId': reminderId,
        'daysOfWeek': daysOfWeek,
      },
      tag: 'ReminderService',
    );

    if (!_initialized) {
      AppLogger.warning(
        'ReminderService not initialized, cannot cancel reminder',
        tag: 'ReminderService',
      );
      return;
    }

    if (_flutterLocalNotificationsPlugin == null) {
      AppLogger.warning(
        'Notification plugin not initialized',
        tag: 'ReminderService',
      );
      return;
    }

    try {
      final baseNotificationId = _generateNotificationId(habitId, reminderId);
      
      if (daysOfWeek != null) {
        // Cancel specific days
        for (final dayOfWeek in daysOfWeek) {
          await _flutterLocalNotificationsPlugin!.cancel(baseNotificationId + dayOfWeek);
        }
      } else {
        // Cancel all days (1-7)
        for (int day = 1; day <= 7; day++) {
          await _flutterLocalNotificationsPlugin!.cancel(baseNotificationId + day);
        }
      }

      AppLogger.info(
        'Reminder cancelled successfully',
        data: {
          'habitId': habitId,
          'reminderId': reminderId,
          'daysCancelled': daysOfWeek?.length ?? 7,
        },
        tag: 'ReminderService',
      );
    } catch (error, stack) {
      AppLogger.error(
        'Error cancelling reminder',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
        context: {'habitId': habitId, 'reminderId': reminderId},
      );
    } finally {
      AppLogger.functionExit('ReminderService.cancelReminder', tag: 'ReminderService');
    }
  }

  /// Cancel all reminders for a habit
  Future<void> cancelAllRemindersForHabit(String habitId) async {
    AppLogger.functionEntry(
      'ReminderService.cancelAllRemindersForHabit',
      params: {'habitId': habitId},
      tag: 'ReminderService',
    );

    if (!_initialized || _flutterLocalNotificationsPlugin == null) {
      AppLogger.warning(
        'ReminderService not initialized, cannot cancel all reminders',
        tag: 'ReminderService',
      );
      return;
    }

    try {
      // Get all pending notifications
      final pendingNotifications =
          await _flutterLocalNotificationsPlugin!.pendingNotificationRequests();

      // Cancel all notifications for this habit
      for (final notification in pendingNotifications) {
        if (notification.payload != null) {
          try {
            final payload = jsonDecode(notification.payload!);
            if (payload['habitId'] == habitId) {
              await _flutterLocalNotificationsPlugin!.cancel(notification.id);
            }
          } catch (e) {
            // Skip invalid payloads
            continue;
          }
        }
      }

      AppLogger.info(
        'All reminders cancelled for habit',
        data: {'habitId': habitId},
        tag: 'ReminderService',
      );
    } catch (error, stack) {
      AppLogger.error(
        'Error cancelling all reminders for habit',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
        context: {'habitId': habitId},
      );
    } finally {
      AppLogger.functionExit(
        'ReminderService.cancelAllRemindersForHabit',
        tag: 'ReminderService',
      );
    }
  }

  /// Snooze a reminder notification
  Future<void> snoozeReminder({
    required String habitId,
    required String reminderId,
    required Duration duration,
  }) async {
    AppLogger.functionEntry(
      'ReminderService.snoozeReminder',
      params: {
        'habitId': habitId,
        'reminderId': reminderId,
        'duration': duration.inMinutes,
      },
      tag: 'ReminderService',
    );

    if (!_initialized) {
      AppLogger.warning(
        'ReminderService not initialized, cannot snooze reminder',
        tag: 'ReminderService',
      );
      return;
    }

    if (_flutterLocalNotificationsPlugin == null) {
      AppLogger.warning(
        'Notification plugin not initialized',
        tag: 'ReminderService',
      );
      return;
    }

    try {
      final habitRepo = ref.read(habitRepositoryProvider.notifier);
      final habit = await habitRepo.getHabitById(habitId);
      if (habit == null) {
        AppLogger.warning(
          'Habit not found',
          data: {'habitId': habitId},
          tag: 'ReminderService',
        );
        return;
      }

      // Create unique notification ID for snoozed reminder
      final snoozeNotificationId = _generateNotificationId(habitId, reminderId) + 1000;

      // Android notification actions for snoozed reminders
      const snooze15Action = AndroidNotificationAction(
        'snooze_15',
        'Snooze 15 min',
        titleColor: Color(0xFF2196F3),
        showsUserInterface: false,
      );

      const snooze1HourAction = AndroidNotificationAction(
        'snooze_1hour',
        'Snooze 1 hour',
        titleColor: Color(0xFF2196F3),
        showsUserInterface: false,
      );

      final androidDetails = AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Notifications for habit reminders',
        importance: Importance.defaultImportance, // Respects Do-Not-Disturb
        priority: Priority.defaultPriority,
        color: const Color(0xFF2196F3),
        playSound: true,
        enableVibration: true,
        actions: [snooze15Action, snooze1HourAction],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule snoozed notification
      final snoozeTime = tz.TZDateTime.now(tz.local).add(duration);
      await _flutterLocalNotificationsPlugin!.zonedSchedule(
        snoozeNotificationId,
        habit.name,
        'Time to ${habit.name}! (Snoozed)',
        snoozeTime,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({
          'habitId': habitId,
          'reminderId': reminderId,
          'snoozed': true,
        }),
      );

      AppLogger.info(
        'Reminder snoozed successfully',
        data: {
          'habitId': habitId,
          'reminderId': reminderId,
          'snoozeDuration': duration.inMinutes,
        },
        tag: 'ReminderService',
      );
    } catch (error, stack) {
      AppLogger.error(
        'Error snoozing reminder',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
        context: {'habitId': habitId, 'reminderId': reminderId},
      );
    } finally {
      AppLogger.functionExit('ReminderService.snoozeReminder', tag: 'ReminderService');
    }
  }

  /// Handle notification tap or action
  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.functionEntry(
      'ReminderService._onNotificationTapped',
      params: {
        'id': response.id,
        'actionId': response.actionId,
        'payload': response.payload,
      },
      tag: 'ReminderService',
    );

    // Handle Android notification action buttons
    if (response.actionId != null && response.actionId!.isNotEmpty) {
      _handleNotificationAction(response);
      return;
    }

    // Handle notification tap (when payload exists)
    if (response.payload == null) {
      AppLogger.debug('Notification tapped without payload', tag: 'ReminderService');
      return;
    }

    try {
      final payloadData = jsonDecode(response.payload!);
      final habitId = payloadData['habitId'] as String?;
      final reminderId = payloadData['reminderId'] as String?;
      final snoozed = payloadData['snoozed'] as bool? ?? false;

      if (habitId == null || reminderId == null) {
        AppLogger.warning(
          'Notification payload missing habitId or reminderId',
          data: {'payload': payloadData},
          tag: 'ReminderService',
        );
        return;
      }

      AppLogger.info(
        'Notification tapped',
        data: {
          'habitId': habitId,
          'reminderId': reminderId,
          'snoozed': snoozed,
        },
        tag: 'ReminderService',
      );

      // Navigate to home screen and show snooze dialog
      _handleNotificationTap(habitId, reminderId);
    } catch (error, stack) {
      AppLogger.error(
        'Error parsing notification payload',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
        context: {'payload': response.payload},
      );
    } finally {
      AppLogger.functionExit('ReminderService._onNotificationTapped', tag: 'ReminderService');
    }
  }

  /// Handle notification tap - navigate and show snooze dialog
  void _handleNotificationTap(String habitId, String reminderId) {
    AppLogger.functionEntry(
      'ReminderService._handleNotificationTap',
      params: {
        'habitId': habitId,
        'reminderId': reminderId,
      },
      tag: 'ReminderService',
    );

    // Get the navigator context
    final navigatorContext = globalNavigatorKey.currentContext;
    if (navigatorContext == null) {
      AppLogger.warning(
        'Global navigator context not available',
        tag: 'ReminderService',
      );
      return;
    }

    // Navigate to home screen if not already there
    final router = GoRouter.of(navigatorContext);
    if (router.routerDelegate.currentConfiguration.uri.path != '/') {
      router.go('/');
    }

    // Get habit name for the dialog
    ref.read(habitRepositoryProvider.notifier).getHabitById(habitId).then((habit) {
      if (habit == null) {
        AppLogger.warning(
          'Habit not found for notification',
          data: {'habitId': habitId},
          tag: 'ReminderService',
        );
        return;
      }

      // Show snooze dialog after navigation
      // Use Future.microtask to ensure context is available
      Future.microtask(() {
        final context = globalNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          SnoozeDialog.show(
            context: context,
            habitId: habitId,
            reminderId: reminderId,
            habitName: habit.name,
          );
        }
      });
    }).catchError((error, stack) {
      AppLogger.error(
        'Error showing snooze dialog',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
      );
    });
  }

  /// Handle notification action button press (Android)
  void _handleNotificationAction(NotificationResponse response) {
    AppLogger.functionEntry(
      'ReminderService._handleNotificationAction',
      params: {
        'actionId': response.actionId,
        'payload': response.payload,
      },
      tag: 'ReminderService',
    );

    if (response.payload == null) {
      AppLogger.warning(
        'Notification action triggered without payload',
        tag: 'ReminderService',
      );
      return;
    }

    try {
      final payloadData = jsonDecode(response.payload!);
      final habitId = payloadData['habitId'] as String?;
      final reminderId = payloadData['reminderId'] as String?;

      if (habitId == null || reminderId == null) {
        AppLogger.warning(
          'Notification action payload missing habitId or reminderId',
          data: {'payload': payloadData},
          tag: 'ReminderService',
        );
        return;
      }

      // Determine snooze duration based on action
      Duration? snoozeDuration;
      if (response.actionId == 'snooze_15') {
        snoozeDuration = const Duration(minutes: 15);
      } else if (response.actionId == 'snooze_1hour') {
        snoozeDuration = const Duration(hours: 1);
      }

      if (snoozeDuration == null) {
        AppLogger.warning(
          'Unknown notification action',
          data: {'actionId': response.actionId},
          tag: 'ReminderService',
        );
        return;
      }

      // Execute snooze
      snoozeReminder(
        habitId: habitId,
        reminderId: reminderId,
        duration: snoozeDuration,
      ).catchError((error, stack) {
        AppLogger.error(
          'Error executing snooze from notification action',
          error: error,
          stackTrace: stack,
          tag: 'ReminderService',
        );
      });

      AppLogger.info(
        'Notification action executed',
        data: {
          'actionId': response.actionId,
          'habitId': habitId,
          'reminderId': reminderId,
          'duration': snoozeDuration.inMinutes,
        },
        tag: 'ReminderService',
      );
    } catch (error, stack) {
      AppLogger.error(
        'Error handling notification action',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
        context: {'actionId': response.actionId, 'payload': response.payload},
      );
    } finally {
      AppLogger.functionExit('ReminderService._handleNotificationAction', tag: 'ReminderService');
    }
  }

  /// Generate a unique notification ID from habit and reminder IDs
  int _generateNotificationId(String habitId, String reminderId) {
    // Use hash codes to create a unique integer ID
    // Combine habit and reminder IDs, then take modulo to fit in int range
    final combined = habitId.hashCode ^ reminderId.hashCode;
    // Ensure positive ID (notification IDs must be positive)
    return combined.abs() % 1000000;
  }

  /// Calculate the next instance of a time for a specific day of week
  /// Returns null if dayOfWeek is invalid (must be 1-7)
  tz.TZDateTime? _nextInstanceOfTime(TimeOfDay time, int dayOfWeek) {
    if (dayOfWeek < 1 || dayOfWeek > 7) {
      AppLogger.warning(
        'Invalid day of week',
        data: {'dayOfWeek': dayOfWeek},
        tag: 'ReminderService',
      );
      return null;
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Find the next occurrence of this day of week
    int daysUntilTarget = (dayOfWeek - scheduledDate.weekday) % 7;
    if (daysUntilTarget == 0 && scheduledDate.isBefore(now)) {
      // If it's today but the time has passed, schedule for next week
      daysUntilTarget = 7;
    }

    final targetDate = scheduledDate.add(Duration(days: daysUntilTarget));

    // If the target day is today but time has passed, move to next week
    if (targetDate.isBefore(now)) {
      return targetDate.add(const Duration(days: 7));
    }

    return targetDate;
  }

  /// Check if the service is initialized
  bool get isInitialized => _initialized;

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    if (!_initialized || _flutterLocalNotificationsPlugin == null) {
      return 0;
    }

    try {
      final pending =
          await _flutterLocalNotificationsPlugin!.pendingNotificationRequests();
      return pending.length;
    } catch (error, stack) {
      AppLogger.error(
        'Error getting pending notifications count',
        error: error,
        stackTrace: stack,
        tag: 'ReminderService',
      );
      return 0;
    }
  }
}

