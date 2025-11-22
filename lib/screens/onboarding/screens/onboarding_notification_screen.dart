import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/chainy_colors.dart';
import '../../../core/ui/chainy_button.dart';
import '../../../features/habits/domain/services/reminder_service.dart';

/// Notification permission screen - Fifth step of onboarding
/// 
/// Displays a motivational explanation about how notifications help maintain
/// streaks and builds consistency. Includes a primary CTA button that triggers
/// the system notification permission dialog.
class OnboardingNotificationScreen extends ConsumerStatefulWidget {
  final ValueChanged<bool> onPermissionResult;

  const OnboardingNotificationScreen({
    super.key,
    required this.onPermissionResult,
  });

  @override
  ConsumerState<OnboardingNotificationScreen> createState() =>
      _OnboardingNotificationScreenState();
}

class _OnboardingNotificationScreenState
    extends ConsumerState<OnboardingNotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isRequesting = false;
  bool _permissionGranted = false;

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

  Future<void> _requestPermissions() async {
    if (_isRequesting || _permissionGranted) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      final reminderService = ref.read(reminderServiceProvider.notifier);
      final granted = await reminderService.requestPermissions();

      setState(() {
        _permissionGranted = granted;
        _isRequesting = false;
      });

      widget.onPermissionResult(granted);
    } catch (error) {
      setState(() {
        _isRequesting = false;
      });

      if (mounted) {
        final theme = Theme.of(context);
        final brightness = theme.brightness;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to request notification permissions. You can enable them later in settings.',
              style: TextStyle(
                color: ChainyColors.getPrimaryText(brightness),
              ),
            ),
            backgroundColor: ChainyColors.getCard(brightness),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      widget.onPermissionResult(false);
    }
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
                'Stay on track',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: ChainyColors.getPrimaryText(brightness),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 16),

              // Motivational description
              Text(
                'Reminders help you maintain your streak and build consistency. We\'ll send you gentle notifications to keep you motivated.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ChainyColors.getSecondaryText(brightness),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Permission request button
              if (!_permissionGranted)
                ChainyButton(
                  text: 'Enable Notifications',
                  onPressed: _isRequesting ? null : _requestPermissions,
                  isFullWidth: true,
                  isLoading: _isRequesting,
                  icon: Icons.notifications_outlined,
                )
              else
                // Success state with iOS dark mode styling
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ChainyColors.success.withValues(
                      alpha: brightness == Brightness.dark ? 0.2 : 0.15,
                    ),
                    border: Border.all(
                      color: ChainyColors.success,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    // Subtle shadow for depth in dark mode
                    boxShadow: brightness == Brightness.dark
                        ? [
                            BoxShadow(
                              color: ChainyColors.success.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: ChainyColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifications enabled! You\'re all set.',
                          style: TextStyle(
                            color: ChainyColors.success,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

