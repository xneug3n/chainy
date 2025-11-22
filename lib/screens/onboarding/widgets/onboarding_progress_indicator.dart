import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Progress indicator for onboarding flow
/// Displays segmented progress bars at the top of the onboarding screen
class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  }) : assert(currentStep >= 0 && currentStep < totalSteps,
            'currentStep must be between 0 and totalSteps - 1');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.symmetric(
              horizontal: index == 0 || index == totalSteps - 1 ? 0 : 2,
            ),
            decoration: BoxDecoration(
              color: index <= currentStep
                  ? ChainyColors.getAccentBlue(brightness)
                  : ChainyColors.getGray(brightness),
              borderRadius: BorderRadius.circular(2),
              // Subtle glow for active segments in dark mode
              boxShadow: index <= currentStep && brightness == Brightness.dark
                  ? [
                      BoxShadow(
                        color: ChainyColors.getAccentBlue(brightness)
                            .withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

