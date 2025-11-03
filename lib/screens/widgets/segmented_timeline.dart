import 'package:flutter/material.dart';
import '../../features/habits/domain/models/habit.dart';

/// Segmented timeline widget for habit progress tracking (display-only)
class SegmentedTimeline extends StatelessWidget {
  final Habit habit;
  final int currentValue;
  
  const SegmentedTimeline({
    super.key,
    required this.habit,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        habit.targetValue,
        (index) => _buildSegment(context, index),
      ),
    );
  }

  Widget _buildSegment(BuildContext context, int index) {
    final isActive = index < currentValue;
    final isCompleted = index < currentValue;
    
    // Segments are now display-only (no interaction)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: _getSegmentColor(context, isActive),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getBorderColor(context, isActive),
          width: 1,
        ),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            )
          : null,
    );
  }

  Color _getSegmentColor(BuildContext context, bool isActive) {
    if (isActive) {
      return Theme.of(context).brightness == Brightness.light
          ? Colors.green
          : Colors.green[700]!;
    } else {
      return Theme.of(context).brightness == Brightness.light
          ? Colors.grey[300]!
          : Colors.grey[600]!;
    }
  }

  Color _getBorderColor(BuildContext context, bool isActive) {
    if (isActive) {
      return Theme.of(context).brightness == Brightness.light
          ? Colors.green
          : Colors.green[700]!;
    } else {
      return Theme.of(context).brightness == Brightness.light
          ? Colors.grey[300]!
          : Colors.grey[600]!;
    }
  }
}
