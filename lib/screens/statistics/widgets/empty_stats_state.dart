import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Empty state widget for statistics screen when user has no data
class EmptyStatsState extends StatelessWidget {
  const EmptyStatsState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 80,
            color: ChainyColors.getSecondaryText(brightness),
          ),
          const SizedBox(height: 16),
          Text(
            'Your statistics will appear here',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start tracking your habits to see your progress and trends over time.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}








