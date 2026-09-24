import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/breathing_orb.dart';
import '../../../../core/widgets/wash_background.dart';
import '../../../../core/widgets/wordmark.dart';

/// Spec: docs/screens/01-welcome.md
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;

    return Scaffold(
      body: WashBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: Space.base),
                      child: Align(alignment: Alignment.centerLeft, child: Wordmark()),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const BreathingOrb(size: 104, ringSize: 132),
                              const SizedBox(height: Space.xl),
                              Text(
                                'A quiet place to put things down',
                                textAlign: TextAlign.center,
                                style: AppType.displayLarge.copyWith(color: c.textPrimary),
                              ),
                              const SizedBox(height: Space.base),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 300),
                                child: Text(
                                  'Check in daily, write when you need to, and talk it through whenever the hour gets long.',
                                  textAlign: TextAlign.center,
                                  style: AppType.bodyLarge.copyWith(color: c.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    PrimaryButton(label: 'Create an account', onPressed: () => context.go(AppRoutes.signUp)),
                    const SizedBox(height: Space.md),
                    SecondaryButton(label: 'I already have one', onPressed: () => context.go(AppRoutes.signIn)),
                    const SizedBox(height: Space.base),
                    Text(
                      'Nothing you write is shared unless you choose to share it.',
                      textAlign: TextAlign.center,
                      style: AppType.caption.copyWith(color: c.textTertiary),
                    ),
                    const SizedBox(height: Space.base),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
