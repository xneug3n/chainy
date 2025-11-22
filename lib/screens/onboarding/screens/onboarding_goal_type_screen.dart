import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';
import '../../../features/habits/domain/models/habit.dart';

/// Goal type selection screen - Step in onboarding
/// 
/// Displays tappable goal type cards allowing users to select whether they want
/// to track their habit as binary (done/not done) or quantitative (with numbers).
class OnboardingGoalTypeScreen extends StatefulWidget {
  final ValueChanged<GoalType> onGoalTypeSelected;

  const OnboardingGoalTypeScreen({
    super.key,
    required this.onGoalTypeSelected,
  });

  @override
  State<OnboardingGoalTypeScreen> createState() =>
      _OnboardingGoalTypeScreenState();
}

class _OnboardingGoalTypeScreenState extends State<OnboardingGoalTypeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  GoalType? _selectedGoalType;

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onGoalTypeSelected(GoalType goalType) {
    setState(() {
      _selectedGoalType = goalType;
    });
    widget.onGoalTypeSelected(goalType);
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
                'How do you want to track it?',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: ChainyColors.getPrimaryText(brightness),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Choose whether you want to track completion or measure progress with numbers.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ChainyColors.getSecondaryText(brightness),
                ),
              ),
              const SizedBox(height: 48),

              // Goal type selection cards
              _GoalTypeOptionCard(
                goalType: GoalType.binary,
                title: 'Binary',
                subtitle: 'Done or not done',
                icon: Icons.check_circle_outline,
                isSelected: _selectedGoalType == GoalType.binary,
                onTap: () => _onGoalTypeSelected(GoalType.binary),
              ),
              const SizedBox(height: 12),
              _GoalTypeOptionCard(
                goalType: GoalType.quantitative,
                title: 'Quantitative',
                subtitle: 'Track numbers and progress',
                icon: Icons.trending_up,
                isSelected: _selectedGoalType == GoalType.quantitative,
                onTap: () => _onGoalTypeSelected(GoalType.quantitative),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual goal type option card widget
class _GoalTypeOptionCard extends StatelessWidget {
  final GoalType goalType;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalTypeOptionCard({
    required this.goalType,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? ChainyColors.getAccentBlue(brightness).withValues(alpha: 0.15)
              : ChainyColors.getCard(brightness),
          border: Border.all(
            color: isSelected
                ? ChainyColors.getAccentBlue(brightness)
                : ChainyColors.getBorder(brightness),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          // Enhanced iOS-style shadows for dark mode
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ChainyColors.getAccentBlue(brightness)
                        .withValues(alpha: brightness == Brightness.dark ? 0.3 : 0.2),
                    blurRadius: brightness == Brightness.dark ? 12 : 8,
                    spreadRadius: 0,
                  ),
                  // Additional subtle outer glow for dark mode
                  if (brightness == Brightness.dark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: -1,
                    ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? ChainyColors.getAccentBlue(brightness).withValues(alpha: 0.2)
                    : ChainyColors.getGray(brightness),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? ChainyColors.getAccentBlue(brightness)
                    : ChainyColors.getSecondaryText(brightness),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ChainyColors.getPrimaryText(brightness),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: ChainyColors.getSecondaryText(brightness),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 24,
                color: ChainyColors.getAccentBlue(brightness),
              ),
          ],
        ),
      ),
    );
  }
}

