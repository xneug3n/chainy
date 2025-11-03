import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/chainy_theme.dart';
import 'core/routes/app_router.dart';
import 'core/di/hive_setup.dart';
import 'features/habits/domain/services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveSetup.initialize();
  
  runApp(
    const ProviderScope(
      child: ChainyApp(),
    ),
  );
}

/// Initialize ReminderService after app starts
/// This is called from ChainyApp to ensure ProviderScope is available
class ReminderServiceInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const ReminderServiceInitializer({super.key, required this.child});

  @override
  ConsumerState<ReminderServiceInitializer> createState() =>
      _ReminderServiceInitializerState();
}

class _ReminderServiceInitializerState
    extends ConsumerState<ReminderServiceInitializer> with WidgetsBindingObserver {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeReminderService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Log app lifecycle changes for notification handling
    // flutter_local_notifications handles all states (foreground, background, terminated)
    // automatically, but we log for debugging
    debugPrint('App lifecycle changed: $state');
  }

  Future<void> _initializeReminderService() async {
    if (_initialized) return;
    
    try {
      // Access the provider to trigger initialization
      await ref.read(reminderServiceProvider.future);
      _initialized = true;
    } catch (e) {
      // Log error but don't block app startup
      debugPrint('Failed to initialize ReminderService: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ChainyApp extends StatelessWidget {
  const ChainyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ReminderServiceInitializer(
      child: MaterialApp.router(
        title: 'Chainy',
        theme: ChainyTheme.lightTheme(),
        darkTheme: ChainyTheme.darkTheme(),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
