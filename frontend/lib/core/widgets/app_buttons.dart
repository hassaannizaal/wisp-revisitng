import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';

/// Standard control height from the specs.
const double kControlHeight = 54;

/// Primary action, 54px, full width. Shows a spinner while [loading] without
/// changing size, so the layout never shifts while a request is in flight.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  /// Overrides the accent fill — the account-mode CTA uses `caution`.
  final Color? color;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    final foreground = foregroundColor ?? (color == null ? null : c.ground);

    return SizedBox(
      height: kControlHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          disabledBackgroundColor: loading ? (color ?? c.accent) : null,
          disabledForegroundColor: loading ? foreground ?? c.ground : null,
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: foreground ?? c.ground),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: Space.sm)],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Secondary action, 54px outlined.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kControlHeight,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: Space.md)],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// A 44px-tall text button: the minimum tap target from the design rules.
class QuietButton extends StatelessWidget {
  const QuietButton({super.key, required this.label, required this.onPressed, this.color});

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: color ?? context.wisp.textSecondary),
        child: Text(label),
      ),
    );
  }
}

/// A 44×44 icon button. The glyph can be small; the target cannot.
class TapTargetIconButton extends StatelessWidget {
  const TapTargetIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.size = 22,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: size, color: color ?? context.wisp.textSecondary),
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      padding: EdgeInsets.zero,
    );
  }
}
