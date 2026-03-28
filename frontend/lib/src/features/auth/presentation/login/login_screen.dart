import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom_auth_text_field.dart';
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
  late AnimationController _bgAnimationController;

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
      duration: const Duration(milliseconds: 2000),
    );

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    const curve = Curves.easeOutQuart;

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
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Background (Atmospheric Continuity)
          _LoginBackground(animation: _bgAnimationController),

          // 2. Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Item 1: Wisp Logo
                    _StaggeredItem(
                      animation: _logoAnimation,
                      child: const WispLogo(fontSize: 32, color: AppColors.splashTextDark),
                    ),
                    const SizedBox(height: 48),

                    // Item 2: Headline
                    _StaggeredItem(
                      animation: _headlineAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.splashTextDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log in to continue your wellness journey.',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: AppColors.splashTextDark.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Item 3: Glassmorphic Form Card
                    _StaggeredItem(
                      animation: _cardAnimation,
                      child: _GlassmorphicCard(
                        child: Column(
                          children: [
                            CustomAuthTextField(
                              controller: _emailController,
                              hintText: 'Email Address',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            CustomAuthTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.splashPhase0.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Item 4: Login Button
                    _StaggeredItem(
                      animation: _primaryButtonAnimation,
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryElevatedButton(
                              text: 'Log In',
                              onPressed: () async {
                                final success = await ref.read(loginControllerProvider.notifier).login(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                if (!context.mounted) return;
                                if (success) {
                                  // Navigate to Home or handle success
                                } else if (state.hasError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.error.toString())),
                                  );
                                }
                              },
                            ),
                    ),
                    const SizedBox(height: 40),

                    // Item 5: Social Login Section
                    _StaggeredItem(
                      animation: _socialAnimation,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.splashTextDark.withOpacity(0.1))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.splashTextDark.withOpacity(0.4),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppColors.splashTextDark.withOpacity(0.1))),
                            ],
                          ),
                          const SizedBox(height: 32),
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
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.outfit(
                                  color: AppColors.splashTextDark.withOpacity(0.6),
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
                                    color: AppColors.splashPhase0,
                                    fontWeight: FontWeight.bold,
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

class _LoginBackground extends StatelessWidget {
  final Animation<double> animation;
  const _LoginBackground({required this.animation});

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
              Positioned(
                top: 200 - (animation.value * 40),
                left: -100 + (animation.value * 50),
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.splashPhase2.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
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

class _StaggeredItem extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _StaggeredItem({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _GlassmorphicCard extends StatelessWidget {
  final Widget child;
  const _GlassmorphicCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white24,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
