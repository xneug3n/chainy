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
  late AnimationController _popController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  int? _lastTappedIndex;

  @override
  void initState() {
    super.initState();
    
    // Pop animation controller
    _popController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _popController.dispose();
    _glowController.dispose();
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
    final isLastTapped = _lastTappedIndex == index;
    
    return GestureDetector(
      onTap: () => _updateSegment(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: isLastTapped ? _scaleAnimation.value : 1.0,
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
                boxShadow: isLastTapped && _glowAnimation.value > 0
                    ? [
                        BoxShadow(
                          color: _getSegmentColor(isActive).withOpacity(0.6),
                          blurRadius: 8 * _glowAnimation.value,
                          spreadRadius: 2 * _glowAnimation.value,
                        ),
                      ]
                    : null,
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
    
    setState(() {
      _lastTappedIndex = index;
    });
    
    if (index < widget.currentValue) {
      // Segment is already active, deactivate it
      _popController.reverse();
      _glowController.reverse();
      widget.onSegmentTap?.call(index);
    } else {
      // Activate segment
      _popController.forward().then((_) {
        _popController.reverse();
      });
      _glowController.forward().then((_) {
        _glowController.reverse();
      });
      widget.onSegmentTap?.call(index + 1);
    }
    
    // Reset last tapped index after animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _lastTappedIndex = null;
        });
      }
    });
  }
}
