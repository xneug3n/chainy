import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/reminder.dart';
import '../../../../core/ui/chainy_button.dart';
import '../../../../core/theme/chainy_colors.dart';
import 'dart:math' as math;

/// Widget for managing up to 3 reminders per habit
class ReminderFormWidget extends StatefulWidget {
  final String habitId;
  final List<Reminder> existingReminders;
  final ValueChanged<List<Reminder>> onRemindersChanged;

  const ReminderFormWidget({
    super.key,
    required this.habitId,
    required this.existingReminders,
    required this.onRemindersChanged,
  });

  @override
  State<ReminderFormWidget> createState() => _ReminderFormWidgetState();
}

class _ReminderFormWidgetState extends State<ReminderFormWidget> {
  late List<Reminder> _reminders;

  @override
  void initState() {
    super.initState();
    _reminders = List.from(widget.existingReminders);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminders',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ChainyColors.getPrimaryText(brightness),
          ),
        ),
        const SizedBox(height: 12),
        ..._buildReminderWidgets(),
        if (_reminders.length < 3) ...[
          const SizedBox(height: 8),
          ChainyButton(
            text: 'Add Reminder',
            variant: ChainyButtonVariant.secondary,
            icon: Icons.add,
            onPressed: _addReminder,
            isFullWidth: true,
          ),
        ] else ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ChainyColors.getCard(brightness),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ChainyColors.getBorder(brightness),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: ChainyColors.getSecondaryText(brightness),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maximum of 3 reminders per habit',
                    style: TextStyle(
                      fontSize: 12,
                      color: ChainyColors.getSecondaryText(brightness),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildReminderWidgets() {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    if (_reminders.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ChainyColors.getCard(brightness),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ChainyColors.getBorder(brightness),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 20,
                color: ChainyColors.getSecondaryText(brightness),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No reminders set',
                  style: TextStyle(
                    fontSize: 14,
                    color: ChainyColors.getSecondaryText(brightness),
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return _reminders.asMap().entries.map((entry) {
      final index = entry.key;
      final reminder = entry.value;
      return _ReminderCard(
        reminder: reminder,
        index: index + 1,
        onEdit: () => _editReminder(reminder),
        onDelete: () => _deleteReminder(reminder),
      );
    }).toList();
  }

  Future<void> _addReminder() async {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ChainyColors.getAccentBlue(brightness),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null && mounted) {
      final newReminder = Reminder(
        id: _generateReminderId(),
        habitId: widget.habitId,
        time: time,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Default to every day
      );

      setState(() {
        _reminders.add(newReminder);
      });

      HapticFeedback.lightImpact();
      widget.onRemindersChanged(_reminders);
    }
  }

  Future<void> _editReminder(Reminder reminder) async {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    final time = await showTimePicker(
      context: context,
      initialTime: reminder.time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ChainyColors.getAccentBlue(brightness),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null && mounted) {
      final updatedReminder = reminder.copyWith(time: time);

      setState(() {
        final index = _reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          _reminders[index] = updatedReminder;
        }
      });

      HapticFeedback.lightImpact();
      widget.onRemindersChanged(_reminders);
    }
  }

  void _deleteReminder(Reminder reminder) {
    setState(() {
      _reminders.removeWhere((r) => r.id == reminder.id);
    });

    HapticFeedback.mediumImpact();
    widget.onRemindersChanged(_reminders);
  }

  String _generateReminderId() {
    return 'reminder_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }
}

/// Card widget for displaying a single reminder
class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final timeStr = _formatTime(reminder.time);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ChainyColors.getCard(brightness),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ChainyColors.getBorder(brightness),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ChainyColors.getAccentBlue(brightness).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.access_time,
              size: 18,
              color: ChainyColors.getAccentBlue(brightness),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder $index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ChainyColors.getSecondaryText(brightness),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ChainyColors.getPrimaryText(brightness),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: ChainyColors.getAccentBlue(brightness),
            ),
            onPressed: onEdit,
            tooltip: 'Edit reminder',
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: ChainyColors.error,
            ),
            onPressed: onDelete,
            tooltip: 'Delete reminder',
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

