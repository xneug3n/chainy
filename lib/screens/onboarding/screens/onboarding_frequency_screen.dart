import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Frequency selection screen - Fourth step of onboarding
/// TODO: Implement in task 9.5
class OnboardingFrequencyScreen extends StatelessWidget {
  final ValueChanged<String> onFrequencySelected;

  const OnboardingFrequencyScreen({
    super.key,
    required this.onFrequencySelected,
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
            'How often?',
            style: theme.textTheme.displayLarge?.copyWith(
              color: ChainyColors.getPrimaryText(brightness),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select how frequently you want to track this habit.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ChainyColors.getSecondaryText(brightness),
            ),
          ),
          // TODO: Add frequency selection cards in task 9.5
        ],
      ),
    );
  }
}

