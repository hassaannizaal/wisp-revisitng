import 'package:flutter/material.dart';

import '../../../../../core/theme/app_metrics.dart';
import '../../../../../core/widgets/breathing_orb.dart';
import '../../../../../core/widgets/wordmark.dart';

/// Shown only while the session is being restored. The router moves on the
/// moment Firebase reports whether a user is signed in (see app_router.dart);
/// a signed-in user never sees the welcome screen.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BreathingOrb(size: 72, ringSize: 96),
            SizedBox(height: Space.lg),
            Wordmark(),
          ],
        ),
      ),
    );
  }
}
