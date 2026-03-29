import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/aura_background.dart';
import '../../../../../core/widgets/luxury_glass_card.dart';
import '../../../../../core/widgets/luxury_text_field.dart';
import '../../../../../core/widgets/luxury_stagger.dart';
import '../../../../../core/widgets/luxury_button.dart';
import '../../../../../core/widgets/wisp_logo.dart';
import '../../../../../core/widgets/social_login_button.dart';
import 'login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _email = TextEditingController(), _pass = TextEditingController();
  late AnimationController _main, _aura;
  late Animation<double> _logoAnim, _headAnim, _formAnim, _btnAnim, _socAnim;

  @override
  void initState() {
    super.initState();
    _main = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _aura = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    const c = Curves.fastOutSlowIn;
    _logoAnim = CurvedAnimation(parent: _main, curve: const Interval(0.0, 0.4, curve: c));
    _headAnim = CurvedAnimation(parent: _main, curve: const Interval(0.15, 0.55, curve: c));
    _formAnim = CurvedAnimation(parent: _main, curve: const Interval(0.3, 0.7, curve: c));
    _btnAnim = CurvedAnimation(parent: _main, curve: const Interval(0.45, 0.85, curve: c));
    _socAnim = CurvedAnimation(parent: _main, curve: const Interval(0.6, 1.0, curve: c));
    _main.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _main.dispose();
    _aura.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0E081A),
      body: Stack(children: [
        AuraBackground(animation: _aura),
        SafeArea(child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(children: [
            LuxuryStagger(
                animation: _logoAnim, 
                child: const WispLogo(
                  fontSize: 32, 
                  color: Colors.white,
                  heroTag: 'wisp_branding_hero',
                )),
            const SizedBox(height: 56),
            LuxuryStagger(animation: _headAnim, child: Column(children: [
              Text('Welcome Back', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
              const SizedBox(height: 12),
              Text('Log in to continue your wellness journey.', style: GoogleFonts.outfit(fontSize: 16, color: Colors.white54)),
            ])),
            const SizedBox(height: 48),
            LuxuryStagger(animation: _formAnim, child: LuxuryGlassCard(child: Column(children: [
              LuxuryTextField(controller: _email, label: 'EMAIL ADDRESS', hintText: 'Enter your email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 32),
              LuxuryTextField(controller: _pass, label: 'PASSWORD', hintText: 'Enter your password', prefixIcon: Icons.lock_outline, isPassword: true),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot Password?', style: TextStyle(color: Colors.white60, fontSize: 13)))),
            ]))),
            const SizedBox(height: 32),
            LuxuryStagger(animation: _btnAnim, child: LuxuryButton(
              text: 'Log In',
              isLoading: state.isLoading,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final ok = await ref.read(loginControllerProvider.notifier).login(_email.text, _pass.text);
                if (mounted && !ok && state.hasError) messenger.showSnackBar(SnackBar(content: Text(state.error.toString())));
              },
            )),
            const SizedBox(height: 48),
            LuxuryStagger(animation: _socAnim, child: Column(children: [
              const Row(children: [Expanded(child: Divider(color: Colors.white12)), Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('OR', style: TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2))), Expanded(child: Divider(color: Colors.white12))]),
              const SizedBox(height: 40),
              SocialLoginButton(text: 'Continue with Google', onPressed: () {}, iconData: Icons.g_mobiledata_rounded),
              const SizedBox(height: 16),
              SocialLoginButton(text: 'Continue with Apple', onPressed: () {}, iconData: Icons.apple),
              const SizedBox(height: 48),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account? ", style: GoogleFonts.outfit(color: Colors.white54)),
                GestureDetector(
                  onTap: () => context.go('/signup'), 
                  child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                ),
              ]),
            ])),
          ]),
        ))),
      ]),
    );
  }
}
