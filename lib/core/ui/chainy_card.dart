import 'package:flutter/material.dart';
import '../theme/chainy_colors.dart';

/// iOS-styled card component with proper shadows and corner radius
class ChainyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isElevated;
  
  const ChainyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isElevated = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: ChainyColors.getCard(brightness),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isElevated ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
    
    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }
    
    return card;
  }
}
