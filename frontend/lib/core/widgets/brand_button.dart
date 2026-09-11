import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_buttons.dart';

/// Sign-in with a third-party identity provider. The only place in the app
/// where off-palette brand colours are permitted (see the design rules).
enum BrandProvider { google, apple }

class BrandButton extends StatelessWidget {
  const BrandButton({super.key, required this.provider, required this.onPressed});

  final BrandProvider provider;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      label: switch (provider) {
        BrandProvider.google => 'Continue with Google',
        BrandProvider.apple => 'Continue with Apple',
      },
      icon: switch (provider) {
        BrandProvider.google => const _GoogleGlyph(),
        BrandProvider.apple => Icon(Icons.apple, size: 22, color: context.wisp.textPrimary),
      },
      onPressed: onPressed,
    );
  }
}

/// The four-colour "G", drawn so no image asset is needed.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 20, height: 20, child: CustomPaint(painter: _GooglePainter()));
  }
}

class _GooglePainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arcRect = rect.deflate(stroke / 2);

    const deg = 3.141592653589793 / 180;
    canvas.drawArc(arcRect, -10 * deg, -100 * deg, false, paint..color = _red);
    canvas.drawArc(arcRect, -110 * deg, -100 * deg, false, paint..color = _yellow);
    canvas.drawArc(arcRect, -210 * deg, -95 * deg, false, paint..color = _green);
    canvas.drawArc(arcRect, 15 * deg, 30 * deg, false, paint..color = _blue);
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width - stroke / 2, size.height / 2),
      paint..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
