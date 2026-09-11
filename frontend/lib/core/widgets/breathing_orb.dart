import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';

/// The character orb: a radial accent gradient that breathes on
/// [Motion.cycle], with an expanding ring fading out behind it.
///
/// Honours reduce-motion via [Motion.respecting] — the orb then holds still.
class BreathingOrb extends StatefulWidget {
  const BreathingOrb({super.key, this.size = 104, this.ringSize, this.animate = true});

  final double size;

  /// Diameter of the ring behind the orb; defaults to `size + 28`.
  final double? ringSize;
  final bool animate;

  @override
  State<BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<BreathingOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: Motion.cycle);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final duration = Motion.respecting(context, Motion.cycle);
    if (widget.animate && duration > Duration.zero) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    final ringSize = widget.ringSize ?? widget.size + 28;

    return SizedBox(
      width: ringSize * 1.5,
      height: ringSize * 1.5,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_controller.value);
          // Scale 1.0 → 1.075 → 1.0 over one cycle.
          final breath = 1.0 + 0.075 * (1 - (2 * t - 1).abs());
          // Ring expands 0.92 → 1.5 while fading to zero on the same period.
          final ringScale = 0.92 + 0.58 * _controller.value;
          final ringOpacity = (1 - _controller.value) * 0.55;

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: ringSize,
                  height: ringSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.accent.withValues(alpha: ringOpacity), width: 1.5),
                  ),
                ),
              ),
              Transform.scale(scale: breath, child: child),
            ],
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: Radii.liveR,
            gradient: RadialGradient(
              center: const Alignment(-0.24, -0.32),
              radius: 0.85,
              colors: [c.accentInk, c.accent, c.accentDim],
              stops: const [0.0, 0.42, 1.0],
            ),
            boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.35), blurRadius: 40, spreadRadius: 2)],
          ),
        ),
      ),
    );
  }
}
