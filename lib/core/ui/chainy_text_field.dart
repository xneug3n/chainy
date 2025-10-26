import 'package:flutter/material.dart';
import '../theme/chainy_colors.dart';

/// iOS-styled text field with proper styling and validation
class ChainyTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  
  const ChainyTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: ChainyColors.getPrimaryText(brightness),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly,
          focusNode: focusNode,
          style: TextStyle(
            color: ChainyColors.getPrimaryText(brightness),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: ChainyColors.getSecondaryText(brightness),
              fontSize: 16,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: ChainyColors.getCard(brightness),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ChainyColors.getBorder(brightness),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ChainyColors.getBorder(brightness),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: ChainyColors.getAccentBlue(brightness),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ChainyColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ChainyColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              color: ChainyColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

