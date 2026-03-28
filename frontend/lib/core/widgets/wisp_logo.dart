import 'package:flutter/material.dart';

class WispLogo extends StatelessWidget {
  final double fontSize;
  final Color color;
  final bool showText;

  const WispLogo({
    super.key, 
    this.fontSize = 42, 
    this.color = Colors.white,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The Abstract "Wisp" Orb
        Container(
          width: fontSize * 1.5,
          height: fontSize * 1.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.3),
                color.withOpacity(0.0),
              ],
              stops: const [0.2, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 5,
              )
            ]
          ),
        ),
        if (showText) ...[
          SizedBox(height: fontSize * 0.4),
          // Premium Minimalist Typography
          Text(
            'WISP',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w300, 
              letterSpacing: 14.0, // Wide tracking for that premium calm feel
              color: color,
            ),
          ),
        ]
      ],
    );
  }
}
