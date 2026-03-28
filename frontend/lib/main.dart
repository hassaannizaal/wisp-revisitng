import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'src/features/auth/presentation/splash/splash_screen.dart';

void main() async {
  // 1. Ensure Flutter bindings are ready before interacting with native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase with our securely generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Run the app
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
      title: 'WISP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
