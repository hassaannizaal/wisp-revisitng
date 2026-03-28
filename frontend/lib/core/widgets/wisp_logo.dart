import 'package:flutter/material.dart';

class WispLogo extends StatefulWidget {
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
  State<WispLogo> createState() => _WispLogoState();
}

class _WispLogoState extends State<WispLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Breathing interval (4s)
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine, // Smooth, natural breathing curve
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Fixed-size wrapper to accommodate the prominent breathing effect
        SizedBox(
          width: widget.fontSize * 1.5 * 1.4, // Increased space for larger pulse
          height: widget.fontSize * 1.5 * 1.4,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              // Prominent pulsating scale (0.85 to 1.3)
              final scale = 0.85 + (_pulseAnimation.value * 0.45);
              // Intense oscillating blur for glow effect (20 to 65)
              final blur = 20.0 + (_pulseAnimation.value * 45.0);
              
              return Center(
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.fontSize * 1.5,
                    height: widget.fontSize * 1.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.color.withValues(alpha: 0.9),
                          widget.color.withValues(alpha: 0.3),
                          widget.color.withValues(alpha: 0.0),
                        ],
                        stops: const [0.2, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.5), // More visible glow
                          blurRadius: blur,
                          spreadRadius: 2,
                        )
                      ]
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showText) ...[
          SizedBox(height: widget.fontSize * 0.4),
          // Premium Minimalist Typography
          Text(
            'WISP',
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w300, 
              letterSpacing: 14.0, // Wide tracking for that premium calm feel
              color: widget.color,
            ),
          ),
        ]
      ],
    );
  }
}
