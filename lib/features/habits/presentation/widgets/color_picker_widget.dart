import 'package:flutter/material.dart';
import '../../../../core/theme/chainy_colors.dart';

/// Widget for selecting habit colors
class ColorPickerWidget extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  
  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });
  
  // Predefined color palette
  static final List<Color> _colors = [
    ChainyColors.lightAccentBlue,
    ChainyColors.success,
    ChainyColors.warning,
    ChainyColors.error,
    ChainyColors.lightOrange,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.yellow,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.deepPurple,
  ];
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(
            color: ChainyColors.getPrimaryText(brightness),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        
        // Selected color preview
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ChainyColors.getBorder(brightness),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selectedColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.check,
              color: _getContrastColor(selectedColor),
              size: 24,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Color grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _colors.length,
          itemBuilder: (context, index) {
            final color = _colors[index];
            final isSelected = color.value == selectedColor.value;
            
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? ChainyColors.getPrimaryText(brightness)
                        : ChainyColors.getBorder(brightness),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check,
                          color: _getContrastColor(color),
                          size: 20,
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// Get contrasting color (white or black) based on background color brightness
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
