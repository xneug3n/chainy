import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Icon and Color selection screen - Third step of onboarding
/// 
/// Displays inline icon and color selection grids allowing users to personalize
/// their habit with visual customization options.
class OnboardingIconColorScreen extends StatefulWidget {
  final ValueChanged2<String, Color> onSelectionComplete;

  const OnboardingIconColorScreen({
    super.key,
    required this.onSelectionComplete,
  });

  @override
  State<OnboardingIconColorScreen> createState() =>
      _OnboardingIconColorScreenState();
}

class _OnboardingIconColorScreenState extends State<OnboardingIconColorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Predefined list of common habit icons
  static const List<String> _icons = [
    '💪', '🏃', '🚰', '📚', '🧘', '🍎', '💤', '🎯',
    '⭐', '🔥', '💎', '🌱', '🎨', '🎵', '📝', '🏆',
    '💡', '🌈', '🎪', '🚀', '🎭', '🎬', '🎮', '🎸',
    '💫', '🌟', '✨', '🎊', '🎉', '🎈', '🎁', '🎂',
  ];

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

  String _selectedIcon = '';
  Color _selectedColor = ChainyColors.lightAccentBlue;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Initialize with first icon and first color
    _selectedIcon = _icons.first;
    _selectedColor = _colors.first;
    widget.onSelectionComplete(_selectedIcon, _selectedColor);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onIconSelected(String icon) {
    setState(() {
      _selectedIcon = icon;
    });
    widget.onSelectionComplete(_selectedIcon, _selectedColor);
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
    widget.onSelectionComplete(_selectedIcon, _selectedColor);
  }

  /// Get contrasting color (white or black) based on background color brightness
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Choose an icon and color',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: ChainyColors.getPrimaryText(brightness),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Personalize your habit with an icon and color that represents it.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ChainyColors.getSecondaryText(brightness),
                ),
              ),
              const SizedBox(height: 48),

              // Icon selection section
              Text(
                'Icon',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ChainyColors.getPrimaryText(brightness),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Icon grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  final isSelected = icon == _selectedIcon;

                  return GestureDetector(
                    onTap: () => _onIconSelected(icon),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ChainyColors.lightAccentBlue.withValues(alpha: 0.2)
                            : ChainyColors.getCard(brightness),
                        borderRadius: BorderRadius.circular(12),
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
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Color selection section
              Text(
                'Color',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ChainyColors.getPrimaryText(brightness),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Selected color preview
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ChainyColors.getBorder(brightness),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: _getContrastColor(_selectedColor),
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                  final isSelected = color == _selectedColor;

                  return GestureDetector(
                    onTap: () => _onColorSelected(color),
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
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper typedef for callback with two parameters
typedef ValueChanged2<T1, T2> = void Function(T1 value1, T2 value2);

