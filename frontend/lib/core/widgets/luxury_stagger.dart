import 'package:flutter/material.dart';

class LuxuryStagger extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const LuxuryStagger({super.key, required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
