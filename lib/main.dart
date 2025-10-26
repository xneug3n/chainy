import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/chainy_theme.dart';
import 'core/routes/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ChainyApp(),
    ),
  );
}

class ChainyApp extends StatelessWidget {
  const ChainyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chainy',
      theme: ChainyTheme.lightTheme(),
      darkTheme: ChainyTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
