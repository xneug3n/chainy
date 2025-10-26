import 'package:flutter/material.dart';
import '../theme/chainy_colors.dart';

/// iOS-styled button component with primary and secondary variants
class ChainyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ChainyButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  
  const ChainyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ChainyButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    Widget button;
    
    switch (variant) {
      case ChainyButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: ChainyColors.getAccentBlue(brightness),
            foregroundColor: ChainyColors.getPrimaryText(brightness),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: isFullWidth ? const Size(double.infinity, 44) : null,
          ),
          child: _buildButtonContent(),
        );
        break;
      case ChainyButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: ChainyColors.getAccentBlue(brightness),
            side: BorderSide(color: ChainyColors.getAccentBlue(brightness)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: isFullWidth ? const Size(double.infinity, 44) : null,
          ),
          child: _buildButtonContent(),
        );
        break;
      case ChainyButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: ChainyColors.getAccentBlue(brightness),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: isFullWidth ? const Size(double.infinity, 44) : null,
          ),
          child: _buildButtonContent(),
        );
        break;
    }
    
    return button;
  }
  
  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }
}

enum ChainyButtonVariant {
  primary,
  secondary,
  text,
}

