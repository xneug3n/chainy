import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/domain/services/progress_service.dart';
import '../../features/habits/domain/services/streak_service.dart';
import 'segmented_timeline.dart';
import 'week_strip_indicator.dart';
import 'streak_indicator.dart';

/// Row widget for displaying a single habit
class HabitRow extends ConsumerWidget {
  final Habit habit;
  
  const HabitRow({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(habit.id),
        background: _SwipeRightBackground(),
        secondaryBackground: _SwipeLeftBackground(),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            _handleSwipeRight(context);
          } else {
            _handleSwipeLeft(context);
          }
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: habit.color.withOpacity(0.1),
            child: Text(
              habit.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          title: Text(
            habit.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              FutureBuilder<int>(
                future: ref.read(progressServiceProvider.notifier).getCurrentValue(habit.id),
                builder: (context, snapshot) {
                  final currentValue = snapshot.data ?? 0;
                  return SegmentedTimeline(
                    habit: habit,
                    currentValue: currentValue,
                    onSegmentTap: (newValue) => _handleSegmentTap(context, ref, newValue),
                  );
                },
              ),
              const SizedBox(height: 4),
              WeekStripIndicator(habitId: habit.id),
            ],
          ),
          trailing: FutureBuilder<int>(
            future: ref.read(streakServiceProvider.notifier).getCurrentStreak(habit.id),
            builder: (context, snapshot) {
              final streak = snapshot.data ?? 0;
              return StreakIndicator(streak: streak);
            },
          ),
          onTap: () => _showHabitDetails(context),
        ),
      ),
    );
  }

  void _handleSwipeRight(BuildContext context) {
    // Complete/increment habit
    HapticFeedback.lightImpact();
    // TODO: Implement habit completion logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Completed ${habit.name}!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo logic
          },
        ),
      ),
    );
  }

  void _handleSwipeLeft(BuildContext context) {
    // Show notes or undo
    HapticFeedback.lightImpact();
    // TODO: Show notes dialog or undo options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notes/Undo functionality coming soon!')),
    );
  }

  void _showHabitDetails(BuildContext context) {
    // TODO: Navigate to habit details screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Habit details coming soon!')),
    );
  }

  void _handleSegmentTap(BuildContext context, WidgetRef ref, int newValue) {
    // TODO: Implement segment tap logic to update check-ins
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated ${habit.name} to $newValue'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo logic
          },
        ),
      ),
    );
  }

}

/// Background widget for right swipe (complete/increment)
class _SwipeRightBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Background widget for left swipe (notes/undo)
class _SwipeLeftBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(
            Icons.note,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
