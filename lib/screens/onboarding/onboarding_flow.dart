import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/chainy_colors.dart';
import '../../core/ui/chainy_button.dart';
import '../../core/utils/app_logger.dart';
import '../../core/config/preferences_repository.dart';
import '../../core/routes/app_router.dart';
import '../../features/habits/presentation/controllers/habit_controller.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/domain/models/recurrence_config.dart';
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
    AppLogger.functionEntry('_completeOnboarding', tag: 'OnboardingFlow');
    
    try {
      // Parse frequency string to RecurrenceType enum
      final recurrenceType = _parseFrequency(_selectedFrequency);
      AppLogger.debug('Parsed frequency', 
        data: {'frequency': _selectedFrequency, 'recurrenceType': recurrenceType.name}, 
        tag: 'OnboardingFlow');
      
      // Create RecurrenceConfig based on RecurrenceType
      final recurrenceConfig = _createRecurrenceConfig(recurrenceType);
      AppLogger.debug('Created RecurrenceConfig', 
        data: {'recurrenceType': recurrenceType.name}, 
        tag: 'OnboardingFlow');
      
      // Create habit using habit controller
      AppLogger.info('Creating habit with collected data', 
        data: {
          'habitName': _habitName,
          'icon': _selectedIcon,
          'color': _selectedColor.toString(),
          'recurrenceType': recurrenceType.name,
        }, 
        tag: 'OnboardingFlow');
      
      final habitController = ref.read(habitControllerProvider.notifier);
      await habitController.createHabit(
        name: _habitName,
        icon: _selectedIcon,
        color: _selectedColor,
        goalType: GoalType.binary, // Default to binary for onboarding
        recurrenceType: recurrenceType,
        recurrenceConfig: recurrenceConfig,
      );
      
      AppLogger.info('Habit created successfully', tag: 'OnboardingFlow');
      
      // Save user name
      final preferencesRepo = ref.read(preferencesRepositoryProvider.notifier);
      await preferencesRepo.saveUserName(_userName);
      AppLogger.info('User name saved', data: {'userName': _userName}, tag: 'OnboardingFlow');
      
      // Mark onboarding as completed
      await preferencesRepo.setOnboardingCompleted(true);
      AppLogger.info('Onboarding marked as completed', tag: 'OnboardingFlow');
      
      // Navigate to main app
      if (mounted) {
        AppLogger.debug('Navigating to home screen', tag: 'OnboardingFlow');
        context.go(AppRouter.home);
        AppLogger.info('Navigation to home screen completed', tag: 'OnboardingFlow');
      }
      
      AppLogger.functionExit('_completeOnboarding', tag: 'OnboardingFlow');
    } catch (error, stack) {
      AppLogger.error(
        'Failed to complete onboarding',
        error: error,
        stackTrace: stack,
        tag: 'OnboardingFlow',
      );
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete onboarding: ${error.toString()}'),
            backgroundColor: ChainyColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      rethrow;
    }
  }
  
  /// Parse frequency string to RecurrenceType enum
  RecurrenceType _parseFrequency(String frequency) {
    // The frequency screen returns RecurrenceType enum names (daily, multiplePerDay, weekly, custom)
    switch (frequency) {
      case 'daily':
        return RecurrenceType.daily;
      case 'multiplePerDay':
        return RecurrenceType.multiplePerDay;
      case 'weekly':
        return RecurrenceType.weekly;
      case 'custom':
        return RecurrenceType.custom;
      default:
        AppLogger.warning('Unknown frequency, defaulting to daily', 
          data: {'frequency': frequency}, 
          tag: 'OnboardingFlow');
        return RecurrenceType.daily;
    }
  }
  
  /// Create RecurrenceConfig based on RecurrenceType
  RecurrenceConfig _createRecurrenceConfig(RecurrenceType recurrenceType) {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return const RecurrenceConfig.daily();
      case RecurrenceType.multiplePerDay:
        return const RecurrenceConfig.multiplePerDay(targetCount: 2);
      case RecurrenceType.weekly:
        // Default to Mon/Wed/Fri for weekly habits
        return const RecurrenceConfig.weekly(
          daysOfWeek: [Weekday.monday, Weekday.wednesday, Weekday.friday],
        );
      case RecurrenceType.custom:
        return const RecurrenceConfig.custom(interval: 1);
    }
  }
}

