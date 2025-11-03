import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

/// Particle data for confetti burst animation
class Particle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double size;
  final Color color;
  final double lifetime;
  
  double currentX;
  double currentY;
  double age = 0.0;
  
  Particle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.color,
    required this.lifetime,
  }) : currentX = startX, currentY = startY;
  
  void update(double deltaTime) {
    age += deltaTime;
    if (age > lifetime) return;
    
    // Apply gravity (500 px/s²)
    const gravity = 500.0;
    final t = age / 1000.0; // Convert to seconds
    
    currentX = startX + velocityX * t;
    currentY = startY + velocityY * t + 0.5 * gravity * t * t;
  }
  
  double get opacity {
    if (age > lifetime) return 0.0;
    final progress = age / lifetime;
    // Ease out fade
    return 1.0 - (progress * progress);
  }
  
  bool get isAlive => age <= lifetime;
}

/// Widget that wraps a child and adds a spark trail burst animation.
/// When the user long-presses, a trail draws around the card perimeter.
/// Upon completion, a directional confetti burst is triggered.
class LongPressFillAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;
  final Duration fillDuration;
  final Color? fillColor;
  final bool enabled;

  const LongPressFillAnimation({
    super.key,
    required this.child,
    this.onComplete,
    this.fillDuration = const Duration(milliseconds: 550),
    this.fillColor,
    this.enabled = true,
  });

  static ValueNotifier<bool>? isLongPressingNotifier(BuildContext context) {
    final state = context.findAncestorStateOfType<_LongPressFillAnimationState>();
    return state?._isPressingNotifier;
  }

  @override
  State<LongPressFillAnimation> createState() =>
      _LongPressFillAnimationState();
}

class _LongPressFillAnimationState extends State<LongPressFillAnimation>
    with TickerProviderStateMixin {
  // Animation controllers for multi-stage animation
  late AnimationController _holdController;     // 0-550ms hold progress
  late AnimationController _burstController;    // 550-880ms burst
  late AnimationController _settleController;   // 880-1180ms settle
  
  // Animations
  late Animation<double> _trailProgress;
  late Animation<double> _cardScale;
  late Animation<double> _settleScale;
  
  final ValueNotifier<bool> _isPressingNotifier = ValueNotifier<bool>(false);
  bool get _isPressing => _isPressingNotifier.value;
  Timer? _longPressTimer;
  Timer? _hapticTimer;
  PointerDownEvent? _pointerDownEvent;
  
  // Particle system
  final List<Particle> _particles = [];
  Timer? _particleTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Hold animation controller (0-550ms)
    _holdController = AnimationController(
      duration: widget.fillDuration,
      vsync: this,
    );

    // Burst animation controller (330ms)
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 330),
      vsync: this,
    );
    
    // Settle animation controller (300ms)
    _settleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Trail progress (linear)
    _trailProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _holdController,
      curve: Curves.linear,
    ));

    // Card scale during hold
    _cardScale = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _holdController,
      curve: Curves.easeOut,
    ));
    
    
    // Settle scale (yeah pulse)
    _settleScale = Tween<double>(
      begin: 1.03,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _settleController,
      curve: const Cubic(0.2, 0.7, 0, 1), // cubic-bezier(0.2,0.7,0,1)
    ));

    _holdController.addListener(_onHoldProgress);
    _burstController.addListener(_updateParticles);
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _hapticTimer?.cancel();
    _particleTimer?.cancel();
    _isPressingNotifier.dispose();
    _holdController.dispose();
    _burstController.dispose();
    _settleController.dispose();
    super.dispose();
  }

  void _onHoldProgress() {
    if (_holdController.value >= 1.0 && _isPressing) {
      // Hold complete - trigger burst animation and callback
      _handleHoldComplete();
    }
  }
  
  void _updateParticles() {
    if (_particles.isEmpty) return;
    
    const deltaTime = 16.0; // ~60fps
    for (final particle in _particles) {
      particle.update(deltaTime);
    }
    
    // Remove dead particles
    _particles.removeWhere((particle) => !particle.isAlive);
  }

  void _handleHoldComplete() {
    if (!_isPressing) return;

    _isPressingNotifier.value = false;

    // Haptic feedback when complete (550ms timing)
    HapticFeedback.mediumImpact();

    // Create confetti particles
    _createConfettiParticles();
    
    // Start burst animation
    _burstController.forward().then((_) {
      // Start settle animation
      _settleController.forward().then((_) {
        // Reset all animations
        _resetAnimations();
      });
    });

    // Trigger completion callback
    widget.onComplete?.call();
  }
  
  void _createConfettiParticles() {
    _particles.clear();
    
    final size = context.size;
    if (size == null) return;
    
    // Emission from center-top of card, -90° (upward)
    final centerX = size.width / 2;
    final centerY = size.height * 0.2; // Slightly below top
    
    final brightness = Theme.of(context).brightness;
    final confettiColors = [
      brightness == Brightness.light 
        ? const Color(0xFF5D5FEF) // confetti1 light
        : const Color(0xFF8B8DFF), // confetti1 dark
      brightness == Brightness.light 
        ? const Color(0xFF10B981) // confetti2 light  
        : const Color(0xFF34D399), // confetti2 dark
      brightness == Brightness.light 
        ? const Color(0xFFF43F5E) // confetti3 light
        : const Color(0xFFFB7185), // confetti3 dark
    ];
    
    // Create 36 particles
    for (int i = 0; i < 36; i++) {
      // Spread within 65° cone (-90° ± 32.5°)
      final baseAngle = -90.0; // Upward
      final spreadAngle = ((_random.nextDouble() - 0.5) * 65.0) * (math.pi / 180.0);
      final angle = (baseAngle * math.pi / 180.0) + spreadAngle;
      
      // Speed between 220-360 px/s
      final speed = 220.0 + _random.nextDouble() * 140.0;
      final velocityX = math.cos(angle) * speed;
      final velocityY = math.sin(angle) * speed;
      
      // Lifetime between 380-720ms
      final lifetime = 380.0 + _random.nextDouble() * 340.0;
      
      // Size between 2-3.5px
      final particleSize = 2.0 + _random.nextDouble() * 1.5;
      
      // Random color
      final color = confettiColors[_random.nextInt(confettiColors.length)];
      
      _particles.add(Particle(
        startX: centerX,
        startY: centerY,
        velocityX: velocityX,
        velocityY: velocityY,
        size: particleSize,
        color: color,
        lifetime: lifetime,
      ));
    }
    
    // Start particle update timer
    _particleTimer?.cancel();
    _particleTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_particles.isNotEmpty) {
        _updateParticles();
        if (mounted) setState(() {});
      } else {
        _particleTimer?.cancel();
      }
    });
  }
  
  void _resetAnimations() {
    _holdController.reset();
    _burstController.reset();
    _settleController.reset();
    _particles.clear();
    _particleTimer?.cancel();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled || _isPressing) return;

    _pointerDownEvent = event;
    _startLongPress(event);
  }

  void _onPointerMove(PointerMoveEvent event) {
    // Cancel long press if pointer moves too far or exits widget bounds
    if (_pointerDownEvent != null &&
        (event.position - _pointerDownEvent!.position).distance > 10) {
      _cancelLongPress();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _cancelLongPress();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _cancelLongPress();
  }

  void _startLongPress(PointerDownEvent event) {
    if (!widget.enabled || _isPressing) return;

    _isPressingNotifier.value = true;

    // Initial haptic feedback at 90ms
    _hapticTimer = Timer(const Duration(milliseconds: 90), () {
      HapticFeedback.lightImpact();
    });

    // Start hold animation
    _holdController.forward();
  }

  void _cancelLongPress() {
    _longPressTimer?.cancel();
    _hapticTimer?.cancel();
    _longPressTimer = null;
    _hapticTimer = null;

    if (!_isPressing) {
      _pointerDownEvent = null;
      return;
    }

    _isPressingNotifier.value = false;
    _pointerDownEvent = null;

    HapticFeedback.lightImpact();

    // Reverse trail animation if not complete (cancel at 40-60% shrinks backward)
    if (_holdController.value < 1.0) {
      // Create reverse animation for trail shrinking
      final reverseController = AnimationController(
        duration: const Duration(milliseconds: 140),
        vsync: this,
      );
      
      final startValue = _holdController.value;
      final reverseAnimation = Tween<double>(
        begin: startValue,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: reverseController,
        curve: Curves.easeOut,
      ));
      
      reverseAnimation.addListener(() {
        _holdController.value = reverseAnimation.value;
      });
      
      reverseController.forward().then((_) {
        _resetAnimations();
        reverseController.dispose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    // Get theme-aware trail color
    final trailColor = widget.fillColor ?? 
      (brightness == Brightness.light 
        ? const Color(0xFFF59E0B) // trail light
        : const Color(0xFFFBBF24)); // trail dark

    return RepaintBoundary(
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Original child with scale animation
            AnimatedBuilder(
              animation: Listenable.merge([_cardScale, _settleScale]),
              builder: (context, child) {
                final scale = _settleController.isAnimating 
                  ? _settleScale.value 
                  : _cardScale.value;
                return Transform.scale(
                  scale: scale,
                  child: AbsorbPointer(
                    absorbing: _isPressing,
                    child: widget.child,
                  ),
                );
              },
            ),
            
            // Trail animation overlay
            ValueListenableBuilder<bool>(
              valueListenable: _isPressingNotifier,
              builder: (context, isPressing, child) {
                if (!isPressing && _holdController.value == 0.0) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _trailProgress,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: SparkTrailPainter(
                            progress: _trailProgress.value,
                            trailColor: trailColor,
                            borderRadius: 12.0,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            
            // Confetti particles
            if (_particles.isNotEmpty)
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: ConfettiPainter(
                      particles: _particles,
                      borderColor: const Color(0xFF0B1220), // Contrast border
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the spark trail around card perimeter
class SparkTrailPainter extends CustomPainter {
  final double progress;
  final Color trailColor;
  final double borderRadius;
  
  SparkTrailPainter({
    required this.progress,
    required this.trailColor,
    required this.borderRadius,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;
    
    // Create rounded rectangle path
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);
    
    // Get path metrics
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;
    
    final pathMetric = pathMetrics.first;
    final totalLength = pathMetric.length;
    final currentLength = totalLength * progress;
    
    // Extract the current trail path
    final trailPath = pathMetric.extractPath(0, currentLength);
    
    // Paint the trail with glow effect
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = trailColor.withValues(alpha: progress)
      ..strokeCap = StrokeCap.round;
    
    // Draw glow effect
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..color = trailColor.withValues(alpha: progress * 0.3)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    canvas.drawPath(trailPath, glowPaint);
    canvas.drawPath(trailPath, paint);
  }
  
  @override
  bool shouldRepaint(SparkTrailPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.trailColor != trailColor;
  }
}

/// Custom painter for confetti particles
class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  final Color borderColor;
  
  ConfettiPainter({
    required this.particles,
    required this.borderColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (!particle.isAlive) continue;
      
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;
      
      // Draw particle with border for contrast
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      final center = Offset(particle.currentX, particle.currentY);
      final radius = particle.size / 2;
      
      canvas.drawCircle(center, radius, paint);
      canvas.drawCircle(center, radius, borderPaint);
    }
  }
  
  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return particles != oldDelegate.particles;
  }
}

