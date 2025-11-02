import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/presentation/controllers/check_in_controller.dart';

/// Compact progress widget for quantitative habits
/// Displays numeric progress with a linear progress bar
class QuantitativeProgressWidget extends ConsumerStatefulWidget {
  final Habit habit;
  final int currentValue;

  const QuantitativeProgressWidget({
    super.key,
    required this.habit,
    required this.currentValue,
  });

  @override
  ConsumerState<QuantitativeProgressWidget> createState() =>
      _QuantitativeProgressWidgetState();
}

class _QuantitativeProgressWidgetState
    extends ConsumerState<QuantitativeProgressWidget> {
  /// Check if this is a multiplePerDay habit
  bool get _isMultiplePerDay =>
      widget.habit.recurrenceType == RecurrenceType.multiplePerDay;

  /// Get target session count for multiplePerDay habits
  int get _targetSessionCount {
    if (!_isMultiplePerDay) return 1;
    return widget.habit.recurrenceConfig.maybeWhen(
      multiplePerDay: (targetCount) => targetCount,
      orElse: () => 1,
    );
  }

  /// Get total target value (for multiplePerDay: targetValue * targetCount)
  int get _totalTargetValue {
    if (_isMultiplePerDay) {
      return widget.habit.targetValue * _targetSessionCount;
    } else {
      return widget.habit.targetValue;
    }
  }

  /// Calculate progress percentage (can exceed 100%)
  double get _progressPercentage {
    final totalTarget = _totalTargetValue;
    if (totalTarget <= 0) return 0.0;
    return (widget.currentValue / totalTarget).clamp(0.0, 1.0);
  }

  /// Check if goal is exceeded
  bool get _isExceeded => widget.currentValue > _totalTargetValue;

  /// Get display text for progress
  String get _progressText {
    final unit = widget.habit.unit ?? '';
    final unitSuffix = unit.isNotEmpty ? ' $unit' : '';
    final totalTarget = _totalTargetValue;
    return '${widget.currentValue} / $totalTarget$unitSuffix';
  }

  /// Get accessibility label
  String get _accessibilityLabel {
    final unit = widget.habit.unit ?? '';
    final unitSuffix = unit.isNotEmpty ? ' $unit' : '';
    final totalTarget = _totalTargetValue;
    final percentage = (_progressPercentage * 100).round();
    return '${widget.currentValue} von $totalTarget$unitSuffix, $percentage Prozent fertig';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine if target value is set
    final hasTarget = widget.habit.targetValue > 0;

    return Semantics(
      label: _accessibilityLabel,
      value: '${widget.currentValue} / $_totalTargetValue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress text and controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Progress text
              Flexible(
                child: Text(
                  hasTarget
                      ? _progressText
                      : '${widget.currentValue}${widget.habit.unit != null ? ' ${widget.habit.unit}' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Increment/decrement buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decrement button
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: widget.currentValue > 0
                        ? () => _handleDecrement(context)
                        : null,
                    color: theme.colorScheme.primary,
                  ),
                  // Increment button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => _handleIncrement(context),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar (only if target is set)
          if (hasTarget)
            Semantics(
              label: 'Fortschrittsbalken',
              value: '$_progressPercentage%',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progressPercentage,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isExceeded
                        ? Colors.orange
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            )
          else
            Text(
              'Kein Zielwert gesetzt',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  void _handleIncrement(BuildContext context) {
    HapticFeedback.lightImpact();
    final today = DateTime.now();
    final checkInController = ref.read(checkInControllerProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    int newValue;
    if (_isMultiplePerDay) {
      // For multiplePerDay: add one complete session (targetValue units)
      newValue = widget.currentValue + widget.habit.targetValue;
    } else {
      // For regular quantitative: add 1 unit
      newValue = widget.currentValue + 1;
    }
    
    checkInController.saveCheckIn(
      habitId: widget.habit.id,
      date: today,
      value: newValue,
    ).catchError((error) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Fehler: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _handleDecrement(BuildContext context) {
    HapticFeedback.lightImpact();
    final today = DateTime.now();
    final checkInController = ref.read(checkInControllerProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    int newValue;
    if (_isMultiplePerDay) {
      // For multiplePerDay: remove one complete session (targetValue units)
      newValue = (widget.currentValue - widget.habit.targetValue).clamp(0, widget.currentValue);
    } else {
      // For regular quantitative: remove 1 unit
      newValue = widget.currentValue > 0 ? widget.currentValue - 1 : 0;
    }
    
    if (newValue == 0) {
      // Delete check-in if value becomes 0
      checkInController.deleteCheckIn(widget.habit.id, today).catchError((error) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Fehler: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      checkInController.saveCheckIn(
        habitId: widget.habit.id,
        date: today,
        value: newValue,
      ).catchError((error) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Fehler: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
}

