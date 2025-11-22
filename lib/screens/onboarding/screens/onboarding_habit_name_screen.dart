import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Habit Name input screen - Second step of onboarding
/// 
/// Displays the question "What habit do you want to build?" with a large
/// text input field and motivational microcopy encouraging clear naming.
class OnboardingHabitNameScreen extends StatefulWidget {
  final ValueChanged<String> onHabitNameEntered;
  final String? userName;

  const OnboardingHabitNameScreen({
    super.key,
    required this.onHabitNameEntered,
    this.userName,
  });

  @override
  State<OnboardingHabitNameScreen> createState() =>
      _OnboardingHabitNameScreenState();
}

class _OnboardingHabitNameScreenState extends State<OnboardingHabitNameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _habitNameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    _habitNameController.addListener(() {
      widget.onHabitNameEntered(_habitNameController.text);
      setState(() {
        // Trigger rebuild to update UI when habit name changes
      });
    });
  }

  @override
  void dispose() {
    _habitNameController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final hasUserName = widget.userName != null && widget.userName!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Greeting if user name is available
            if (hasUserName)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: ChainyColors.getPrimaryText(brightness),
                    fontWeight: FontWeight.w400,
                  ) ?? const TextStyle(),
                  child: Text(
                    'Hi, ${widget.userName!.trim()}!',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            
            // Question title
            Text(
              'What habit do you want to build?',
              style: theme.textTheme.displayLarge?.copyWith(
                color: ChainyColors.getPrimaryText(brightness),
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Motivational microcopy
            Text(
              'Choose a clear, specific name for your habit.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ChainyColors.getSecondaryText(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Large habit name input field - transparent background, visible text
            TextField(
              controller: _habitNameController,
              focusNode: _focusNode,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              maxLength: 50,
              style: TextStyle(
                color: ChainyColors.getPrimaryText(brightness), // White - primary text color
                fontSize: 28,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Drink water, Exercise, Read',
                hintStyle: TextStyle(
                  color: ChainyColors.getSecondaryText(brightness),
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: ChainyColors.getBackground(brightness), // Same as background - invisible field
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterText: '', // Hide character counter
              ),
              cursorColor: ChainyColors.getAccentBlue(brightness),
              onSubmitted: (_) {
                _focusNode.unfocus();
              },
            ),
          ],
        ),
      ),
    );
  }
}

