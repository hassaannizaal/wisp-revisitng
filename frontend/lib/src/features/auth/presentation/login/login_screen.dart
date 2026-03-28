import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/primary_elevated_button.dart';
import '../../../../../core/widgets/social_login_button.dart';
import '../../../../../core/widgets/wisp_logo.dart';
import 'login_controller.dart';
import '../signup/signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _mainController;
  late AnimationController _auraController;

  // Staggered Animations
  late Animation<double> _logoAnimation;
  late Animation<double> _headlineAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _primaryButtonAnimation;
  late Animation<double> _socialAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    const curve = Curves.fastOutSlowIn;

    _logoAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: curve),
    );

    _headlineAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.15, 0.55, curve: curve),
    );

    _cardAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.7, curve: curve),
    );

    _primaryButtonAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.45, 0.85, curve: curve),
    );

    _socialAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: curve),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mainController.dispose();
    _auraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0E081A), // Luxury Deep Rich Purple
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Aura Background (Luxury Depth)
          _AuraBackground(animation: _auraController),

          // 2. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Item 1: Wisp Logo
                    _LuxuryStaggered(
                      animation: _logoAnimation,
                      child: const WispLogo(fontSize: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 56),

                    // Item 2: Headline
                    _LuxuryStaggered(
                      animation: _headlineAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Log in to continue your wellness journey.',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Item 3: Luxury Glass Card
                    _LuxuryStaggered(
                      animation: _cardAnimation,
                      child: _LuxuryGlassCard(
                        child: Column(
                          children: [
                            _LuxuryTextField(
                              controller: _emailController,
                              label: 'EMAIL ADDRESS',
                              hintText: 'Enter your email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 32), // Extra breathing room
                            _LuxuryTextField(
                              controller: _passwordController,
                              label: 'PASSWORD',
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w300,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Item 4: Action Button
                    _LuxuryStaggered(
                      animation: _primaryButtonAnimation,
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : PrimaryElevatedButton(
                              text: 'Log In',
                              onPressed: () async {
                                final success = await ref.read(loginControllerProvider.notifier).login(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                if (!context.mounted) return;
                                if (success) {
                                  // Home navigation handled by provider or router
                                } else if (state.hasError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(state.error.toString()),
                                      backgroundColor: AppColors.error.withValues(alpha: 0.8),
                                    ),
                                  );
                                }
                              },
                            ),
                    ),
                    const SizedBox(height: 48),

                    // Item 5: Social & Signup
                    _LuxuryStaggered(
                      animation: _socialAnimation,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
                            ],
                          ),
                          const SizedBox(height: 40),
                          SocialLoginButton(
                            text: 'Continue with Google',
                            onPressed: () {},
                            iconData: Icons.g_mobiledata_rounded,
                          ),
                          const SizedBox(height: 16),
                          SocialLoginButton(
                            text: 'Continue with Apple',
                            onPressed: () {},
                            iconData: Icons.apple,
                          ),
                          const SizedBox(height: 48),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

class _LuxuryGlassCard extends StatelessWidget {
  final Widget child;
  const _LuxuryGlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 5,
            offset: const Offset(0, 20),
          ),
        ],
        // The Shimmering Edge-light Gradient Border
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.5), // The Border Width
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.5), // Slightly smaller to match outer radius
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(28.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }


}

class _LuxuryTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;

  const _LuxuryTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<_LuxuryTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.3),
              fontWeight: FontWeight.w300,
            ),
            prefixIcon: Icon(widget.prefixIcon, color: Colors.white.withValues(alpha: 0.5), size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
        ),
      ],
    );
  }
}

class _LuxuryStaggered extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _LuxuryStaggered({required this.animation, required this.child});

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
