import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Habit Name input screen - Second step of onboarding
/// TODO: Implement in task 9.3
class OnboardingHabitNameScreen extends StatelessWidget {
  final ValueChanged<String> onHabitNameEntered;

  const OnboardingHabitNameScreen({
    super.key,
    required this.onHabitNameEntered,
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
            'What habit do you want to build?',
            style: theme.textTheme.displayLarge?.copyWith(
              color: ChainyColors.getPrimaryText(brightness),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose a clear, specific name for your habit.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ChainyColors.getSecondaryText(brightness),
            ),
          ),
          // TODO: Add habit name input field in task 9.3
        ],
      ),
    );
  }
}

