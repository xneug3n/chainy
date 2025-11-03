import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/reminder_service.dart';
import '../../../../core/utils/app_logger.dart';

/// Dialog for snoozing a reminder notification
/// Shows options for +15 minutes and +1 hour
class SnoozeDialog extends ConsumerWidget {
  final String habitId;
  final String reminderId;
  final String habitName;

  const SnoozeDialog({
    super.key,
    required this.habitId,
    required this.reminderId,
    required this.habitName,
  });

  /// Show the snooze dialog
  static Future<void> show({
    required BuildContext context,
    required String habitId,
    required String reminderId,
    required String habitName,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SnoozeDialog(
        habitId: habitId,
        reminderId: reminderId,
        habitName: habitName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Snooze reminder'),
      content: Text('Snooze reminder for "$habitName"'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _handleSnooze(
            context: context,
            ref: ref,
            duration: const Duration(minutes: 15),
          ),
          child: const Text('+15 min'),
        ),
        TextButton(
          onPressed: () => _handleSnooze(
            context: context,
            ref: ref,
            duration: const Duration(hours: 1),
          ),
          child: const Text('+1 hour'),
        ),
      ],
    );
  }

  Future<void> _handleSnooze({
    required BuildContext context,
    required WidgetRef ref,
    required Duration duration,
  }) async {
    AppLogger.functionEntry(
      'SnoozeDialog._handleSnooze',
      params: {
        'habitId': habitId,
        'reminderId': reminderId,
        'duration': duration.inMinutes,
      },
      tag: 'SnoozeDialog',
    );

    try {
      final reminderService = ref.read(reminderServiceProvider.notifier);
      await reminderService.snoozeReminder(
        habitId: habitId,
        reminderId: reminderId,
        duration: duration,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder snoozed for ${_formatDuration(duration)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      AppLogger.info(
        'Reminder snoozed successfully',
        data: {
          'habitId': habitId,
          'reminderId': reminderId,
          'duration': duration.inMinutes,
        },
        tag: 'SnoozeDialog',
      );
    } catch (error, stack) {
      AppLogger.error(
        'Error snoozing reminder',
        error: error,
        stackTrace: stack,
        tag: 'SnoozeDialog',
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to snooze reminder: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours >= 1) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
}

