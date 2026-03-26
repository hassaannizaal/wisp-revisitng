import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'src/features/auth/presentation/splash/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: WispApp(),
    ),
  );
}

class WispApp extends StatelessWidget {
  const WispApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisp Wellness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
