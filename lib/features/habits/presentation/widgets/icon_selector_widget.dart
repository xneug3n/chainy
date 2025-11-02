import 'package:flutter/material.dart';
import '../../../../core/theme/chainy_colors.dart';

/// Widget for displaying selected icon in a box (clickable to open selector)
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
  
  void _showIconSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _IconSelectorDialog(
        selectedIcon: selectedIcon,
        icons: _icons,
        onIconSelected: (icon) {
          onIconSelected(icon);
          Navigator.of(context).pop();
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return GestureDetector(
      onTap: () => _showIconSelectorDialog(context),
      child: Container(
        width: 56,
        height: 56,
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
    );
  }
}

/// Dialog for selecting an icon
class _IconSelectorDialog extends StatelessWidget {
  final String selectedIcon;
  final List<String> icons;
  final ValueChanged<String> onIconSelected;
  
  const _IconSelectorDialog({
    required this.selectedIcon,
    required this.icons,
    required this.onIconSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Icon auswählen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ChainyColors.getPrimaryText(brightness),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: ChainyColors.getSecondaryText(brightness),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Icon grid
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final icon = icons[index];
                  final isSelected = icon == selectedIcon;
                  
                  return GestureDetector(
                    onTap: () => onIconSelected(icon),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? ChainyColors.lightAccentBlue.withValues(alpha: 0.2)
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
            ),
          ],
        ),
      ),
    );
  }
}
