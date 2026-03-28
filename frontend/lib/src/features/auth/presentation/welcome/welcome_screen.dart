import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
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
  late AnimationController _bgAnimationController;

  // Staggered Animations
  late Animation<double> _logoAnimation;
  late Animation<double> _headlineAnimation;
  late Animation<double> _subheadlineAnimation;
  late Animation<double> _actionAreaAnimation;

  // Slide Animations
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _headlineSlide;
  late Animation<Offset> _subheadlineSlide;
  late Animation<Offset> _actionAreaSlide;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Intervals for staggered effect
    const curve = Curves.easeOutQuart;

    _logoAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: curve),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_logoAnimation);

    _headlineAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.7, curve: curve),
    );
    _headlineSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_headlineAnimation);

    _subheadlineAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.9, curve: curve),
    );
    _subheadlineSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_subheadlineAnimation);

    _actionAreaAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: curve),
    );
    _actionAreaSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_actionAreaAnimation);

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background (Continuous Depth)
          _WelcomeBackground(animation: _bgAnimationController),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Item 1: Logo
                FadeTransition(
                  opacity: _logoAnimation,
                  child: SlideTransition(
                    position: _logoSlide,
                    child: const Center(
                      child: WispLogo(
                        fontSize: 42,
                        color: AppColors.splashTextDark,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Item 2: Headline
                FadeTransition(
                  opacity: _headlineAnimation,
                  child: SlideTransition(
                    position: _headlineSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Your Space to Breathe',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppColors.splashTextDark,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Item 3: Subheadline
                FadeTransition(
                  opacity: _subheadlineAnimation,
                  child: SlideTransition(
                    position: _subheadlineSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        'A specialized mental wellness journey designed uniquely for you.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          color: AppColors.splashTextDark.withValues(alpha: 0.6),
                          height: 1.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Item 4: Action Area (Glassmorphism)
                FadeTransition(
                  opacity: _actionAreaAnimation,
                  child: SlideTransition(
                    position: _actionAreaSlide,
                    child: _GlassActionArea(
                      onGetStarted: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      ),
                      onLogin: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBackground extends StatelessWidget {
  final Animation<double> animation;
  const _WelcomeBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.splashPhase3,
                AppColors.splashPhase2,
                AppColors.splashPhase3,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Subtle breathing orb
              Positioned(
                top: 100 + (animation.value * 50),
                right: -50 + (animation.value * 30),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.splashPhase2.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlassActionArea extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  const _GlassActionArea({required this.onGetStarted, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: onGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.splashPhase0,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Secondary Button
                TextButton(
                  onPressed: onLogin,
                  child: Text(
                    'Already have an account? Log In',
                    style: GoogleFonts.outfit(
                      color: AppColors.splashTextDark.withValues(alpha: 0.8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
