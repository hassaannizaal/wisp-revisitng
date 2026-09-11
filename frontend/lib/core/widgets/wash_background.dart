import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Two soft radial washes — accent top-left, ember bottom-right. Purely
/// decorative: it is painted behind [child] and never affects layout.
class WashBackground extends StatelessWidget {
  const WashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.9, -0.9),
                radius: 0.9,
                colors: [c.accent.withValues(alpha: 0.09), c.accent.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.9, 0.95),
                radius: 0.9,
                colors: [c.ember.withValues(alpha: 0.07), c.ember.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
