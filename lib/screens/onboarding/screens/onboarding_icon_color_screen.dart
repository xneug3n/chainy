import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Icon and Color selection screen - Third step of onboarding
/// TODO: Implement in task 9.4
class OnboardingIconColorScreen extends StatelessWidget {
  final ValueChanged2<String, Color> onSelectionComplete;

  const OnboardingIconColorScreen({
    super.key,
    required this.onSelectionComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose an icon and color',
            style: theme.textTheme.displayLarge?.copyWith(
              color: ChainyColors.getPrimaryText(brightness),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Personalize your habit with an icon and color that represents it.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ChainyColors.getSecondaryText(brightness),
            ),
          ),
          // TODO: Add icon and color selection in task 9.4
        ],
      ),
    );
  }
}

/// Helper typedef for callback with two parameters
typedef ValueChanged2<T1, T2> = void Function(T1 value1, T2 value2);

