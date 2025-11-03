import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/home_screen.dart';
import '../../screens/statistics_screen.dart';
import '../../screens/achievements_screen.dart';
import '../../screens/settings_screen.dart';
import '../navigation/global_navigator.dart';

/// App router configuration with TabBar navigation
class AppRouter {
  static const String home = '/';
  static const String statistics = '/statistics';
  static const String achievements = '/achievements';
  static const String settings = '/settings';
  
  static final GoRouter router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: statistics,
            name: 'statistics',
            builder: (context, state) => const StatisticsScreen(),
          ),
          GoRoute(
            path: achievements,
            name: 'achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Main navigation shell with TabBar
class MainNavigationShell extends StatelessWidget {
  final Widget child;
  
  const MainNavigationShell({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
  
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case AppRouter.home:
        return 0;
      case AppRouter.statistics:
        return 1;
      case AppRouter.achievements:
        return 2;
      case AppRouter.settings:
        return 3;
      default:
        return 0;
    }
  }
  
  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.statistics);
        break;
      case 2:
        context.go(AppRouter.achievements);
        break;
      case 3:
        context.go(AppRouter.settings);
        break;
    }
  }
}

