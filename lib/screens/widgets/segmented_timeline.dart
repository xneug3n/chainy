import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/habits/domain/models/habit.dart';

/// Segmented timeline widget for habit progress tracking
class SegmentedTimeline extends StatefulWidget {
  final Habit habit;
  final int currentValue;
  final Function(int)? onSegmentTap;
  
  const SegmentedTimeline({
    super.key,
    required this.habit,
    required this.currentValue,
    this.onSegmentTap,
  });

  @override
  State<SegmentedTimeline> createState() => _SegmentedTimelineState();
}

class _SegmentedTimelineState extends State<SegmentedTimeline>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        widget.habit.targetValue,
        (index) => _buildSegment(index),
      ),
    );
  }

  Widget _buildSegment(int index) {
    final isActive = index < widget.currentValue;
    final isCompleted = index < widget.currentValue;
    
    return GestureDetector(
      onTap: () => _updateSegment(index),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isCompleted ? _scaleAnimation.value : 1.0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _getSegmentColor(isActive),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _getBorderColor(isActive),
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
            ),
          );
        },
      ),
    );
  }

  Color _getSegmentColor(bool isActive) {
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

  Color _getBorderColor(bool isActive) {
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

  void _updateSegment(int index) {
    HapticFeedback.lightImpact();
    
    if (index < widget.currentValue) {
      // Segment is already active, deactivate it
      _animationController.reverse();
      widget.onSegmentTap?.call(index);
    } else {
      // Activate segment
      _animationController.forward();
      widget.onSegmentTap?.call(index + 1);
    }
  }
}
