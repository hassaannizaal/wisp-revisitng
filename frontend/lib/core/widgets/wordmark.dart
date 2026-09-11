import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_typography.dart';

/// The product wordmark: a 9px accent dot, then "WISP LIFE" tracked out.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: c.accent, borderRadius: Radii.liveR),
        ),
        const SizedBox(width: Space.sm),
        Text('WISP LIFE', style: AppType.monoLabel.copyWith(color: c.textSecondary, letterSpacing: 2.2)),
      ],
    );
  }
}
