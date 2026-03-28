import 'dart:ui';
import 'package:flutter/material.dart';

class AuraBackground extends StatelessWidget {
  final Animation<double> animation;

  const AuraBackground({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Aura 1: Deep Lavender
            Positioned(
              top: 100 - (animation.value * 60),
              left: -150 + (animation.value * 100),
              child: _AuraOrb(
                size: 600,
                color: const Color(0xFF6B5B95).withValues(alpha: 0.15),
              ),
            ),
            // Aura 2: Soft Peach
            Positioned(
              bottom: 200 + (animation.value * 80),
              right: -200 + (animation.value * 120),
              child: _AuraOrb(
                size: 700,
                color: const Color(0xFFE9B384).withValues(alpha: 0.1),
              ),
            ),
            // Aura 3: Muted Violet
            Positioned(
              top: 400 + (animation.value * 50),
              right: 100 - (animation.value * 40),
              child: _AuraOrb(
                size: 500,
                color: const Color(0xFF9E8CB2).withValues(alpha: 0.08),
              ),
            ),
            // Blur Layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AuraOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _AuraOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
