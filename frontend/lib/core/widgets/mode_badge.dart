import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_typography.dart';

/// The single most important component: the privacy promise, made visible.
///
/// Two states only. Independent: accent, `Private · only you`. Organization:
/// caution, `Visible · <named watcher>` — amber always names who (rule 3).
/// `Radii.live` is deliberate: the badge is one of the few things that earns
/// the fully-round radius (rule 4).
class ModeBadge extends StatelessWidget {
  const ModeBadge({super.key, required this.organizationName}) : forcePrivate = false;

  /// For surfaces an admin can never see (journal text): always reads
  /// Private, even in organization mode. Never shows amber.
  const ModeBadge.private({super.key}) : organizationName = null, forcePrivate = true;

  /// Null in independent mode.
  final String? organizationName;
  final bool forcePrivate;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    final visible = !forcePrivate && organizationName != null;
    final color = visible ? c.caution : c.accent;
    final label = visible ? 'Visible · $organizationName' : 'Private · only you';

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: Radii.liveR,
          border: Border.all(color: color.withValues(alpha: 0.6)),
          color: (visible ? c.cautionDim : c.accentDim).withValues(alpha: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, borderRadius: Radii.liveR),
            ),
            const SizedBox(width: Space.sm),
            Text(label, style: AppType.label.copyWith(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
