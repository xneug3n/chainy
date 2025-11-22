import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Icon selection screen - Third step of onboarding
/// 
/// Displays icon selection grid allowing users to personalize their habit.
class OnboardingIconColorScreen extends StatefulWidget {
  final ValueChanged<String> onSelectionComplete;

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

  String _selectedIcon = '';

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

    // Initialize with first icon
    _selectedIcon = _icons.first;
    
    // Defer callback until after first frame to avoid triggering parent setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onSelectionComplete(_selectedIcon);
      }
    });
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
    widget.onSelectionComplete(_selectedIcon);
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
                'Choose an icon',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: ChainyColors.getPrimaryText(brightness),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Personalize your habit with an icon that represents it.',
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final itemSize = (availableWidth - (12 * 7)) / 8;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _icons.map((icon) {
                      final isSelected = icon == _selectedIcon;
                      return SizedBox(
                        width: itemSize,
                        height: itemSize,
                        child: GestureDetector(
                          onTap: () => _onIconSelected(icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ChainyColors.getAccentBlue(brightness).withValues(alpha: 0.2)
                                  : ChainyColors.getCard(brightness),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? ChainyColors.getAccentBlue(brightness)
                                    : ChainyColors.getBorder(brightness),
                                width: isSelected ? 2 : 1,
                              ),
                              // iOS-style subtle shadow for selected state in dark mode
                              boxShadow: isSelected && brightness == Brightness.dark
                                  ? [
                                      BoxShadow(
                                        color: ChainyColors.getAccentBlue(brightness)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

