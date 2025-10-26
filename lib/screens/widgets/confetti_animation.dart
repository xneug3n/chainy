import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Confetti animation widget for celebrating streak increments
class ConfettiAnimation extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final Color? confettiColor;

  const ConfettiAnimation({
    super.key,
    required this.child,
    required this.isActive,
    this.duration = const Duration(milliseconds: 1500),
    this.confettiColor,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _confettiControllers;
  late List<Animation<double>> _confettiAnimations;
  final int _confettiCount = 20;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _confettiControllers = List.generate(
      _confettiCount,
      (index) => AnimationController(
        duration: Duration(
          milliseconds: 800 + _random.nextInt(700),
        ),
        vsync: this,
      ),
    );

    _confettiAnimations = _confettiControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startConfetti();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _confettiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startConfetti() {
    _controller.forward();
    for (final controller in _confettiControllers) {
      controller.reset();
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          ...List.generate(_confettiCount, (index) {
            return AnimatedBuilder(
              animation: _confettiAnimations[index],
              builder: (context, child) {
                return Positioned(
                  left: _random.nextDouble() * MediaQuery.of(context).size.width,
                  top: _random.nextDouble() * MediaQuery.of(context).size.height,
                  child: Transform.rotate(
                    angle: _confettiAnimations[index].value * 2 * math.pi,
                    child: Opacity(
                      opacity: 1.0 - _confettiAnimations[index].value,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.confettiColor ?? 
                              Colors.primaries[_random.nextInt(Colors.primaries.length)],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
      ],
    );
  }
}

/// Streak celebration widget that shows confetti when streak increments
class StreakCelebration extends StatefulWidget {
  final Widget child;
  final int currentStreak;
  final int? previousStreak;

  const StreakCelebration({
    super.key,
    required this.child,
    required this.currentStreak,
    this.previousStreak,
  });

  @override
  State<StreakCelebration> createState() => _StreakCelebrationState();
}

class _StreakCelebrationState extends State<StreakCelebration> {
  bool _showConfetti = false;

  @override
  void didUpdateWidget(StreakCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Show confetti if streak increased
    if (widget.previousStreak != null && 
        widget.currentStreak > widget.previousStreak!) {
      setState(() {
        _showConfetti = true;
      });
      
      // Hide confetti after animation
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _showConfetti = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiAnimation(
      isActive: _showConfetti,
      child: widget.child,
    );
  }
}
