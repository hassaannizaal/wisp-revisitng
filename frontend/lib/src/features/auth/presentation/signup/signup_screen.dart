import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/widgets/aura_background.dart';
import '../../../../../core/widgets/luxury_glass_card.dart';
import '../../../../../core/widgets/luxury_text_field.dart';
import '../../../../../core/widgets/wisp_logo.dart';
import 'signup_controller.dart';
import '../login/login_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});
  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController(), _emailController = TextEditingController(), _passwordController = TextEditingController();
  late AnimationController _mainController, _auraController;
  late Animation<double> _logoAnim, _headAnim, _formAnim;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _auraController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    const c = Curves.fastOutSlowIn;
    _logoAnim = CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: c));
    _headAnim = CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 0.7, curve: c));
    _formAnim = CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 1.0, curve: c));
    _mainController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mainController.dispose();
    _auraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupControllerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0E081A),
      body: Stack(
        children: [
          AuraBackground(animation: _auraController),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  _Stagger(animation: _logoAnim, child: const WispLogo(fontSize: 32, color: Colors.white)),
                  const SizedBox(height: 56),
                  _Stagger(animation: _headAnim, child: Column(children: [
                    Text('Create Account', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
                    const SizedBox(height: 12),
                    Text('Join Wisp to start your journey.', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w300, color: Colors.white54, letterSpacing: 0.5)),
                  ])),
                  const SizedBox(height: 48),
                  _Stagger(animation: _formAnim, child: LuxuryGlassCard(child: Column(children: [
                    LuxuryTextField(controller: _nameController, label: 'FULL NAME', hintText: 'Enter your name', prefixIcon: Icons.person_outline),
                    const SizedBox(height: 24),
                    LuxuryTextField(controller: _emailController, label: 'EMAIL ADDRESS', hintText: 'Enter your email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 24),
                    LuxuryTextField(controller: _passwordController, label: 'PASSWORD', hintText: 'Create a password', prefixIcon: Icons.lock_outline, isPassword: true),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity, height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)]),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final ok = await ref.read(signupControllerProvider.notifier).signup(_emailController.text, _passwordController.text);
                            if (mounted && !ok && state.hasError) messenger.showSnackBar(SnackBar(content: Text(state.error.toString())));
                          },
                          child: state.isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Step Into Wellness', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1)),
                        ),
                      ),
                    ),
                  ]))),
                  const SizedBox(height: 48),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Already have an account? ", style: GoogleFonts.outfit(color: Colors.white54)),
                    GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen())), child: Text('Login', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stagger extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _Stagger({required this.animation, required this.child});
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(animation), child: child));
  }
}
