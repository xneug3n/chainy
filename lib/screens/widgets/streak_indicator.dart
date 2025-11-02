import 'package:flutter/material.dart';

/// Streak indicator widget showing current habit streak
/// Only visible when habit is completed today, glows orange when completed
class StreakIndicator extends StatelessWidget {
  final int streak;
  final bool isCompletedToday;
  
  const StreakIndicator({
    super.key,
    required this.streak,
    this.isCompletedToday = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if habit is completed today
    if (!isCompletedToday || streak == 0) {
      return const SizedBox.shrink();
    }
    
    // Orange color for completed habits
    final flameColor = Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: flameColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: flameColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: flameColor,
          ),
          const SizedBox(width: 4),
          Text(
            streak.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: flameColor,
            ),
          ),
        ],
      ),
    );
  }
}
