import 'package:flutter/material.dart';
import '../../../core/theme/chainy_colors.dart';

/// Welcome/Name input screen - First step of onboarding
/// 
/// Displays a friendly welcome message with a large typography name input field.
/// When the user enters their name, it transitions to a clean headline format.
class OnboardingWelcomeScreen extends StatefulWidget {
  final ValueChanged<String> onNameEntered;

  const OnboardingWelcomeScreen({
    super.key,
    required this.onNameEntered,
  });

  @override
  State<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
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

    _nameController.addListener(() {
      widget.onNameEntered(_nameController.text);
      setState(() {
        // Trigger rebuild to update UI when name changes
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final hasName = _nameController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Welcome to Chainy',
              style: theme.textTheme.displayLarge?.copyWith(
                color: ChainyColors.getPrimaryText(brightness),
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),

            // Name input or headline display
            if (hasName)
              // Show name as headline after entry
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: ChainyColors.getPrimaryText(brightness),
                  fontWeight: FontWeight.w400,
                ) ?? const TextStyle(),
                child: Text(
                  'Hi, ${_nameController.text.trim()}!',
                ),
              )
            else
              // Show friendly message and input field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let\'s get started by setting up your first habit.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: ChainyColors.getSecondaryText(brightness),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Large name input field
                  TextField(
                    controller: _nameController,
                    focusNode: _focusNode,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                      color: ChainyColors.getPrimaryText(brightness),
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Your name',
                      hintStyle: TextStyle(
                        color: ChainyColors.getSecondaryText(brightness),
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) {
                      _focusNode.unfocus();
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

