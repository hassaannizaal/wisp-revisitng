import 'dart:ui';
import 'package:flutter/material.dart';

class LuxuryGlassCard extends StatelessWidget {
  final Widget child;
  const LuxuryGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4), // Darker shadow
            blurRadius: 40,
            spreadRadius: 5,
            offset: const Offset(0, 20),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12), // Darkened to stop the white flash
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.5), 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.5), 
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45), 
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              // Match the deep purple background to force a dark render
              color: const Color(0xFF0E081A).withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(28.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
