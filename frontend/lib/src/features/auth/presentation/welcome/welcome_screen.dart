import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login/login_screen.dart';
import '../signup/signup_screen.dart';
import '../../../../../core/widgets/wisp_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _auraController;

  // Staggered Animations
  late Animation<double> _logoAnimation;
  late Animation<double> _headlineAnimation;
  late Animation<double> _subheadlineAnimation;
  late Animation<double> _actionAreaAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    const curve = Curves.fastOutSlowIn;

    _logoAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.45, curve: curve),
    );

    _headlineAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.65, curve: curve),
    );

    _subheadlineAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.35, 0.8, curve: curve),
    );

    _actionAreaAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.55, 1.0, curve: curve),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _auraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E081A), // Luxury Deep Rich Purple
      body: Stack(
        children: [
          // 1. Aura Background (Shared Environment)
          _AuraBackground(animation: _auraController),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                
                // Item 1: Wisp Logo
                _StaggeredTransition(
                  animation: _logoAnimation,
                  child: const Center(
                    child: WispLogo(
                      fontSize: 48, // Prominent branding
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Item 2: Headline
                _StaggeredTransition(
                  animation: _headlineAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Text(
                          'Your Space to Breathe',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 40,
                            fontWeight: FontWeight.w300, // Elegant thin weight
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Item 3: Subheadline
                        _StaggeredTransition(
                          animation: _subheadlineAnimation,
                          child: Text(
                            'A specialized mental wellness journey designed uniquely for you.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.5),
                              height: 1.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 4),

                // Item 4: Luxury Action Area (Glassmorphism)
                _StaggeredTransition(
                  animation: _actionAreaAnimation,
                  child: _LuxuryGlassActionArea(
                    onGetStarted: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    onLogin: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuraBackground extends StatelessWidget {
  final Animation<double> animation;
  const _AuraBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Shared Orbs with Login Screen (Continuous Room feel)
            Positioned(
              top: -100 + (animation.value * 60),
              left: -150 + (animation.value * 100),
              child: _AuraOrb(
                size: 600,
                color: const Color(0xFF6B5B95).withValues(alpha: 0.15),
              ),
            ),
            Positioned(
              bottom: 100 + (animation.value * 80),
              right: -200 + (animation.value * 120),
              child: _AuraOrb(
                size: 700,
                color: const Color(0xFFE9B384).withValues(alpha: 0.1),
              ),
            ),
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

class _StaggeredTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _StaggeredTransition({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _LuxuryGlassActionArea extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  const _LuxuryGlassActionArea({required this.onGetStarted, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.5),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        padding: const EdgeInsets.all(1.5), // The Border Width
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Luxury Translucent Button
                  Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.25), // Higher density
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.05),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: onLogin,
                    child: Text(
                      'LOG IN',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
