import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Notification permission screen - Fifth step of onboarding
/// TODO: Implement in task 9.6
class OnboardingNotificationScreen extends StatelessWidget {
  final ValueChanged<bool> onPermissionResult;

  const OnboardingNotificationScreen({
    super.key,
    required this.onPermissionResult,
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
            'Enable notifications',
            style: theme.textTheme.displayLarge?.copyWith(
              color: ChainyColors.getPrimaryText(brightness),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Reminders help you maintain your streak and build consistency.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ChainyColors.getSecondaryText(brightness),
            ),
          ),
          // TODO: Add notification permission request in task 9.6
        ],
      ),
    );
  }
}

