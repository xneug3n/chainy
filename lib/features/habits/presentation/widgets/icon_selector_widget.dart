import 'package:flutter/material.dart';
import '../../../../core/theme/chainy_colors.dart';

/// Widget for selecting habit icons/emojis
class IconSelectorWidget extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onIconSelected;
  
  const IconSelectorWidget({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });
  
  // Predefined list of common habit icons
  static const List<String> _icons = [
    '💪', '🏃', '🚰', '📚', '🧘', '🍎', '💤', '🎯',
    '⭐', '🔥', '💎', '🌱', '🎨', '🎵', '📝', '🏆',
    '💡', '🌈', '🎪', '🚀', '🎭', '🎨', '🎪', '🎯',
    '💫', '🌟', '✨', '🎊', '🎉', '🎈', '🎁', '🎂',
  ];
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon',
          style: TextStyle(
            color: ChainyColors.getPrimaryText(brightness),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        
        // Selected icon preview
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: ChainyColors.getCard(brightness),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ChainyColors.getBorder(brightness),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              selectedIcon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Icon grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _icons.length,
          itemBuilder: (context, index) {
            final icon = _icons[index];
            final isSelected = icon == selectedIcon;
            
            return GestureDetector(
              onTap: () => onIconSelected(icon),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? ChainyColors.lightAccentBlue.withOpacity(0.2)
                      : ChainyColors.getCard(brightness),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? ChainyColors.lightAccentBlue
                        : ChainyColors.getBorder(brightness),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
