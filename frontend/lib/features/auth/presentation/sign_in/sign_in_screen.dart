import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/brand_button.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../auth_copy.dart';
import '../auth_scaffold.dart';
import 'sign_in_controller.dart';

/// Spec: docs/screens/02-sign-in.md
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _email.addListener(_onChanged);
    _password.addListener(_onChanged);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Typing clears a stale server error and re-evaluates the CTA.
  void _onChanged() => setState(() {
    _emailError = null;
    _passwordError = null;
  });

  bool get _ready => _email.text.trim().length > 3 && _password.text.length >= 6;

  void _submit() {
    if (!_ready) return;
    FocusScope.of(context).unfocus();
    ref.read(signInControllerProvider.notifier).signIn(_email.text.trim(), _password.text);
  }

  void _showError(Object error) {
    // Errors land under the field they belong to; anything else is a toast.
    final placement = AuthCopy.placeSignInError(error);
    setState(() {
      _emailError = placement.email;
      _passwordError = placement.password;
    });
    if (placement.toast != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(placement.toast!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    final state = ref.watch(signInControllerProvider);
    final submitting = state.isLoading;

    ref.listen<AsyncValue<void>>(signInControllerProvider, (previous, next) {
      if (!next.isLoading && next.hasError) _showError(next.error!);
    });

    return AuthScaffold(
      onBack: () => context.go(AppRoutes.welcome),
      children: [
        Text('Welcome back', style: AppType.displayLarge.copyWith(color: c.textPrimary)),
        const SizedBox(height: Space.sm),
        Text('Pick up where you left off.', style: AppType.bodyMedium.copyWith(color: c.textSecondary)),
        const SizedBox(height: Space.xl),
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabeledTextField(
                controller: _email,
                label: 'Email',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                textInputAction: TextInputAction.next,
                autocorrect: false,
                readOnly: submitting,
                errorText: _emailError,
              ),
              const SizedBox(height: Space.md),
              LabeledTextField(
                controller: _password,
                label: 'Password',
                hint: 'Your password',
                obscure: true,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                readOnly: submitting,
                errorText: _passwordError,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: QuietButton(
            label: 'Forgot password?',
            color: c.accentInk,
            onPressed: () =>
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AuthCopy.resetComingSoon))),
          ),
        ),
        const SizedBox(height: Space.sm),
        PrimaryButton(label: 'Sign in', loading: submitting, onPressed: _ready ? _submit : null),
        const SizedBox(height: Space.lg),
        const _OrDivider(),
        const SizedBox(height: Space.lg),
        BrandButton(provider: BrandProvider.google, onPressed: () => _providerComingSoon(context, 'Google')),
        const SizedBox(height: Space.md),
        BrandButton(provider: BrandProvider.apple, onPressed: () => _providerComingSoon(context, 'Apple')),
        const SizedBox(height: Space.lg),
        AuthFooterLink(prompt: 'New here?', link: 'Create an account', onPressed: () => context.go(AppRoutes.signUp)),
      ],
    );
  }

  void _providerComingSoon(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AuthCopy.providerComingSoon(provider))));
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return Row(
      children: [
        Expanded(child: Divider(color: c.lineSoft)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.base),
          child: Text('or', style: AppType.monoLabel.copyWith(color: c.textTertiary)),
        ),
        Expanded(child: Divider(color: c.lineSoft)),
      ],
    );
  }
}
