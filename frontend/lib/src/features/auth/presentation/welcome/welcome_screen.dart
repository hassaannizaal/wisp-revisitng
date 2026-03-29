import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/aura_background.dart';
import '../../../../../core/widgets/luxury_glass_card.dart';
import '../../../../../core/widgets/luxury_stagger.dart';
import '../../../../../core/widgets/luxury_button.dart';
import '../../../../../core/widgets/wisp_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _main, _aura;
  late Animation<double> _logoAnim, _headAnim, _subAnim, _actionAnim;

  @override
  void initState() {
    super.initState();
    _main = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _aura =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    const c = Curves.fastOutSlowIn;
    _logoAnim = CurvedAnimation(
        parent: _main, curve: const Interval(0.0, 0.4, curve: c));
    _headAnim = CurvedAnimation(
        parent: _main, curve: const Interval(0.2, 0.6, curve: c));
    _subAnim = CurvedAnimation(
        parent: _main, curve: const Interval(0.35, 0.75, curve: c));
    _actionAnim = CurvedAnimation(
        parent: _main, curve: const Interval(0.5, 0.9, curve: c));
    _main.forward();
  }

  @override
  void dispose() {
    _main.dispose();
    _aura.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E081A),
      body: Stack(children: [
        AuraBackground(animation: _aura),
        SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(children: [
            const Spacer(flex: 2),
            LuxuryStagger(
                animation: _logoAnim,
                child: const WispLogo(
                  fontSize: 48, 
                  color: Colors.white,
                  heroTag: 'wisp_branding_hero',
                )),
            const Spacer(),
            LuxuryStagger(
                animation: _headAnim,
                child: Text('Pause. Breathe. Begin.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 42,
                        height: 1.1,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1.5))),
            const SizedBox(height: 24),
            LuxuryStagger(
                animation: _subAnim,
                child: Text('A sanctuary for your thoughts and your healing',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: Colors.white54,
                        fontWeight: FontWeight.w300,
                        height: 1.5))),
            const Spacer(flex: 4),
            LuxuryStagger(
                animation: _actionAnim,
                child: LuxuryGlassCard(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  LuxuryButton(
                      text: 'Get Started',
                      onPressed: () => context.go('/signup')),
                  const SizedBox(height: 16),
                  TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text('LOG IN',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3))),
                ]))),
          ]),
        )),
      ]),
    );
  }
}
