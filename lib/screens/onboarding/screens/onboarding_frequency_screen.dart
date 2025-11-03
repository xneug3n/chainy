import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';
import '../../../features/habits/domain/models/habit.dart';

/// Frequency selection screen - Fourth step of onboarding
/// 
/// Displays tappable frequency cards allowing users to select how often
/// they want to track their habit (Daily, Multiple times per day, Weekly, etc.).
class OnboardingFrequencyScreen extends StatefulWidget {
  final ValueChanged<String> onFrequencySelected;

  const OnboardingFrequencyScreen({
    super.key,
    required this.onFrequencySelected,
  });

  @override
  State<OnboardingFrequencyScreen> createState() =>
      _OnboardingFrequencyScreenState();
}

class _OnboardingFrequencyScreenState extends State<OnboardingFrequencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _selectedFrequency;

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

  void _onFrequencySelected(String frequency) {
    setState(() {
      _selectedFrequency = frequency;
    });
    widget.onFrequencySelected(frequency);
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
                'How often?',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: ChainyColors.getPrimaryText(brightness),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Select how frequently you want to track this habit.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ChainyColors.getSecondaryText(brightness),
                ),
              ),
              const SizedBox(height: 48),

              // Frequency selection cards
              _FrequencyOptionCard(
                frequency: RecurrenceType.daily.name,
                title: 'Daily',
                subtitle: 'Every day',
                icon: Icons.calendar_today,
                isSelected: _selectedFrequency == RecurrenceType.daily.name,
                onTap: () => _onFrequencySelected(RecurrenceType.daily.name),
              ),
              const SizedBox(height: 12),
              _FrequencyOptionCard(
                frequency: RecurrenceType.multiplePerDay.name,
                title: 'Multiple times per day',
                subtitle: 'Several times daily',
                icon: Icons.repeat,
                isSelected: _selectedFrequency == RecurrenceType.multiplePerDay.name,
                onTap: () => _onFrequencySelected(RecurrenceType.multiplePerDay.name),
              ),
              const SizedBox(height: 12),
              _FrequencyOptionCard(
                frequency: RecurrenceType.weekly.name,
                title: 'Weekly',
                subtitle: '3× per week',
                icon: Icons.calendar_view_week,
                isSelected: _selectedFrequency == RecurrenceType.weekly.name,
                onTap: () => _onFrequencySelected(RecurrenceType.weekly.name),
              ),
              const SizedBox(height: 12),
              _FrequencyOptionCard(
                frequency: RecurrenceType.custom.name,
                title: 'Custom',
                subtitle: 'Advanced pattern',
                icon: Icons.settings,
                isSelected: _selectedFrequency == RecurrenceType.custom.name,
                onTap: () => _onFrequencySelected(RecurrenceType.custom.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual frequency option card widget
class _FrequencyOptionCard extends StatelessWidget {
  final String frequency;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyOptionCard({
    required this.frequency,
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ChainyColors.getAccentBlue(brightness)
                        .withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
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

