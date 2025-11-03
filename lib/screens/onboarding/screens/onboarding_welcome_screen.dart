import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Welcome/Name input screen - First step of onboarding
/// TODO: Implement in task 9.2
class OnboardingWelcomeScreen extends StatelessWidget {
  final ValueChanged<String> onNameEntered;

  const OnboardingWelcomeScreen({
    super.key,
    required this.onNameEntered,
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
            'Welcome to Chainy',
            style: theme.textTheme.displayLarge?.copyWith(
              color: ChainyColors.getPrimaryText(brightness),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s get started by setting up your first habit.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: ChainyColors.getSecondaryText(brightness),
            ),
          ),
          // TODO: Add name input field in task 9.2
        ],
      ),
    );
  }
}

