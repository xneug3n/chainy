import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/presentation/controllers/check_in_controller.dart';
import 'quantitative_progress_widget.dart';
import 'week_strip_indicator.dart';
import 'streak_indicator.dart';
import 'confetti_animation.dart';
import 'long_press_fill_animation.dart';

/// Row widget for displaying a single habit
class HabitRow extends ConsumerStatefulWidget {
  final Habit habit;
  
  const HabitRow({
    super.key,
    required this.habit,
  });

  @override
  ConsumerState<HabitRow> createState() => _HabitRowState();
}

class _HabitRowState extends ConsumerState<HabitRow> {
  int? _previousStreak;

  @override
  Widget build(BuildContext context) {
    return StreakCelebration(
      currentStreak: _getCurrentStreak(),
      previousStreak: _previousStreak,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: LongPressFillAnimation(
          fillColor: widget.habit.color,
          fillDuration: const Duration(milliseconds: 550),
          onComplete: () => _handleLongPressComplete(context),
          enabled: true,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.habit.color.withValues(alpha: 0.1),
              child: Text(
                widget.habit.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(
              widget.habit.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                ref.watch(currentProgressValueProvider(widget.habit.id)).when(
                  data: (currentValue) {
                    // Conditional rendering based on goal type
                    if (widget.habit.goalType == GoalType.quantitative) {
                      return QuantitativeProgressWidget(
                        habit: widget.habit,
                        currentValue: currentValue,
                      );
                    } else {
                      // Binary habit: no visual indicator (completed via long press)
                      return const SizedBox.shrink();
                    }
                  },
                  loading: () {
                    if (widget.habit.goalType == GoalType.quantitative) {
                      return QuantitativeProgressWidget(
                        habit: widget.habit,
                        currentValue: 0,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                  error: (_, __) {
                    if (widget.habit.goalType == GoalType.quantitative) {
                      return QuantitativeProgressWidget(
                        habit: widget.habit,
                        currentValue: 0,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 4),
                WeekStripIndicator(habitId: widget.habit.id),
              ],
            ),
            trailing: ref.watch(isCompletedTodayProvider(widget.habit.id)).when(
              data: (isCompleted) {
                return ref.watch(currentStreakProvider(widget.habit.id)).when(
                  data: (streak) => StreakIndicator(
                    streak: streak,
                    isCompletedToday: isCompleted,
                  ),
                  loading: () => StreakIndicator(
                    streak: 0,
                    isCompletedToday: isCompleted,
                  ),
                  error: (_, __) => StreakIndicator(
                    streak: 0,
                    isCompletedToday: isCompleted,
                  ),
                );
              },
              loading: () => const StreakIndicator(streak: 0, isCompletedToday: false),
              error: (_, __) => const StreakIndicator(streak: 0, isCompletedToday: false),
            ),
            onTap: () => _showHabitDetails(context),
          ),
        ),
      ),
    );
  }

  int _getCurrentStreak() {
    // This would normally get the current streak from the service
    // For now, return a placeholder value
    return 0;
  }

  void _showHabitDetails(BuildContext context) {
    // TODO: Navigate to habit details screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit details coming soon!')),
    );
  }

  void _triggerCompletionAnimation() {
    // Animation logic removed - field was unused
    // This method is kept for potential future use
  }

  void _handleLongPressComplete(BuildContext context) {
    // Trigger completion animation
    _triggerCompletionAnimation();
    
    final today = DateTime.now();
    final checkInController = ref.read(checkInControllerProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    if (widget.habit.goalType == GoalType.binary) {
      // Toggle binary completion
      checkInController.toggleBinaryCheckIn(
        habitId: widget.habit.id,
        date: today,
      ).catchError((error) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      // Increment quantitative habit
      ref.read(currentProgressValueProvider(widget.habit.id)).whenData((currentValue) {
        int newValue;
        // For multiplePerDay habits: add one complete session (targetValue units)
        // For regular quantitative: add 1 unit
        if (widget.habit.recurrenceType == RecurrenceType.multiplePerDay) {
          newValue = currentValue + widget.habit.targetValue;
        } else {
          newValue = currentValue + 1;
        }
        // Note: Allow exceeding target value for quantitative habits
        checkInController.saveCheckIn(
          habitId: widget.habit.id,
          date: today,
          value: newValue,
        ).catchError((error) {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Error: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      });
    }
  }

}
