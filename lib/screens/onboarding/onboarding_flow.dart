import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/chainy_colors.dart';
import '../../core/ui/chainy_button.dart';
import 'widgets/onboarding_progress_indicator.dart';
import 'screens/onboarding_welcome_screen.dart';
import 'screens/onboarding_habit_name_screen.dart';
import 'screens/onboarding_icon_color_screen.dart';
import 'screens/onboarding_frequency_screen.dart';
import 'screens/onboarding_notification_screen.dart';

/// Onboarding flow widget with PageView and progress indicator
/// Guides users through 5 sequential steps to set up their first habit
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 5;

  // User input data collected during onboarding
  String _userName = '';
  String _habitName = '';
  String _selectedIcon = '';
  Color _selectedColor = ChainyColors.darkAccentBlue;
  String _selectedFrequency = '';
  bool _notificationsEnabled = false;

  // Getters for accessing collected data (used in completion)
  String get userName => _userName;
  String get habitName => _habitName;
  String get selectedIcon => _selectedIcon;
  Color get selectedColor => _selectedColor;
  String get selectedFrequency => _selectedFrequency;
  bool get notificationsEnabled => _notificationsEnabled;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      backgroundColor: ChainyColors.getBackground(brightness),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: OnboardingProgressIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
              ),
            ),

            // Main content - PageView with 5 screens
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  OnboardingWelcomeScreen(
                    onNameEntered: (name) {
                      setState(() {
                        _userName = name;
                      });
                    },
                  ),
                  OnboardingHabitNameScreen(
                    onHabitNameEntered: (name) {
                      setState(() {
                        _habitName = name;
                      });
                    },
                  ),
                  OnboardingIconColorScreen(
                    onSelectionComplete: (icon, color) {
                      setState(() {
                        _selectedIcon = icon;
                        _selectedColor = color;
                      });
                    },
                  ),
                  OnboardingFrequencyScreen(
                    onFrequencySelected: (frequency) {
                      setState(() {
                        _selectedFrequency = frequency;
                      });
                    },
                  ),
                  OnboardingNotificationScreen(
                    onPermissionResult: (granted) {
                      setState(() {
                        _notificationsEnabled = granted;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Bottom navigation button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ChainyButton(
                text: _currentStep < _totalSteps - 1 ? 'Next' : 'Get Started',
                onPressed: _canProceed() ? _handleNavigation : null,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Checks if the current step can proceed
  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _userName.trim().isNotEmpty;
      case 1:
        return _habitName.trim().isNotEmpty;
      case 2:
        return _selectedIcon.isNotEmpty;
      case 3:
        return _selectedFrequency.isNotEmpty;
      case 4:
        return true; // Notification permission is optional
      default:
        return false;
    }
  }

  /// Handles navigation between screens or completion
  void _handleNavigation() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Completes onboarding and creates the first habit
  Future<void> _completeOnboarding() async {
    // TODO: Implement in task 9.7
    // - Create habit with collected data
    // - Save user name
    // - Mark onboarding as completed
    // - Navigate to main app
  }
}

