import 'package:flutter/material.dart';
import '../theme/chainy_colors.dart';

/// iOS-styled switch component matching iOS toggle style
class ChainySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;
  
  const ChainySwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    Widget switchWidget = Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeThumbColor: ChainyColors.getAccentBlue(brightness),
      inactiveThumbColor: ChainyColors.getSecondaryText(brightness),
      inactiveTrackColor: ChainyColors.getBorder(brightness),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    
    if (label != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              label!,
              style: TextStyle(
                color: ChainyColors.getPrimaryText(brightness),
                fontSize: 16,
              ),
            ),
          ),
          switchWidget,
        ],
      );
    }
    
    return switchWidget;
  }
}
