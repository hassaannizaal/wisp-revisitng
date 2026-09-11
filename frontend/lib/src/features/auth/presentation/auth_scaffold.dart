import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';

/// Shared frame for the sign-in and sign-up screens: a 44px back chevron,
/// then a single scrolling column with `Space.lg` side padding.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.onBack, required this.children});

  final VoidCallback onBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.lg),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TapTargetIconButton(icon: Icons.chevron_left, tooltip: 'Back', onPressed: onBack, size: 28),
                ),
                const SizedBox(height: Space.lg),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "New here? Create an account" — 44px tall, link portion in accentInk.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({super.key, required this.prompt, required this.link, required this.onPressed});

  final String prompt;
  final String link;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(prompt, style: AppType.bodyMedium.copyWith(color: c.textSecondary)),
          TextButton(
            onPressed: onPressed,
            child: Text(
              link,
              style: AppType.bodyMedium.copyWith(color: c.accentInk, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
