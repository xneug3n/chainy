import 'package:flutter/material.dart';
import '../../domain/models/habit.dart';
import '../../../../core/theme/chainy_colors.dart';

/// Widget for selecting goal type (binary or quantitative)
class GoalTypeSelectorWidget extends StatelessWidget {
  final GoalType goalType;
  final ValueChanged<GoalType> onGoalTypeChanged;

  const GoalTypeSelectorWidget({
    super.key,
    required this.goalType,
    required this.onGoalTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ChainyColors.getPrimaryText(brightness),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _GoalTypeOption(
                type: GoalType.binary,
                title: 'Binary',
                subtitle: 'Done or not done',
                icon: Icons.check_circle_outline,
                isSelected: goalType == GoalType.binary,
                onTap: () => onGoalTypeChanged(GoalType.binary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GoalTypeOption(
                type: GoalType.quantitative,
                title: 'Quantitative',
                subtitle: 'Track numbers',
                icon: Icons.trending_up,
                isSelected: goalType == GoalType.quantitative,
                onTap: () => onGoalTypeChanged(GoalType.quantitative),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoalTypeOption extends StatelessWidget {
  final GoalType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalTypeOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? ChainyColors.getAccentBlue(brightness).withOpacity(0.1)
              : ChainyColors.getCard(brightness),
          border: Border.all(
            color: isSelected 
                ? ChainyColors.getAccentBlue(brightness)
                : ChainyColors.getBorder(brightness),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                  ? ChainyColors.getAccentBlue(brightness)
                  : ChainyColors.getSecondaryText(brightness),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ChainyColors.getPrimaryText(brightness),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: ChainyColors.getSecondaryText(brightness),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
