import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() async {
  // 1. Ensure Flutter bindings are ready before interacting with native code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase with our securely generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2.5 Load environment variables
  await dotenv.load(fileName: ".env");

  // 3. Run the app
  runApp(
    const ProviderScope(
      child: WispApp(),
    ),
  );
}

class WispApp extends ConsumerWidget {
  const WispApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'WISP Wellness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
