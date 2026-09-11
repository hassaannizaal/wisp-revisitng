import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_typography.dart';
import 'app_buttons.dart';

/// Destination for modules that are designed but not built yet. Cards and
/// links to unbuilt modules route here rather than being hidden (CLAUDE.md).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.message = 'This part is still being built.'});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return Scaffold(
      appBar: AppBar(
        leading: TapTargetIconButton(
          icon: Icons.chevron_left,
          size: 28,
          tooltip: 'Back',
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: Space.screen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_outlined, size: 32, color: c.textTertiary),
              const SizedBox(height: Space.base),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppType.bodyMedium.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
