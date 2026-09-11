import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_metrics.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_buttons.dart';
import '../../../../../core/widgets/labeled_text_field.dart';
import '../auth_copy.dart';
import '../auth_scaffold.dart';
import '../validators.dart';
import 'sign_up_controller.dart';

/// No dedicated spec — mirrors docs/screens/02-sign-in.md with a name field.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    for (final controller in [_name, _email, _password]) {
      controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {
    _emailError = null;
    _passwordError = null;
  });

  bool get _ready =>
      _name.text.trim().isNotEmpty && _email.text.trim().length > 3 && _password.text.length >= minPasswordLength;

  void _submit() {
    if (!_ready || _formKey.currentState?.validate() != true) return;
    FocusScope.of(context).unfocus();
    ref
        .read(signUpControllerProvider.notifier)
        .signUp(name: _name.text.trim(), email: _email.text.trim(), password: _password.text);
  }

  void _showError(Object error) {
    final placement = AuthCopy.placeSignUpError(error);
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
    final state = ref.watch(signUpControllerProvider);
    final submitting = state.isLoading;

    ref.listen<AsyncValue<void>>(signUpControllerProvider, (previous, next) {
      if (!next.isLoading && next.hasError) _showError(next.error!);
    });

    return AuthScaffold(
      onBack: () => context.go(AppRoutes.welcome),
      children: [
        Text('Create an account', style: AppType.displayLarge.copyWith(color: c.textPrimary)),
        const SizedBox(height: Space.sm),
        Text('A few details and you are in.', style: AppType.bodyMedium.copyWith(color: c.textSecondary)),
        const SizedBox(height: Space.xl),
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LabeledTextField(
                  controller: _name,
                  label: 'Name',
                  hint: 'What should we call you?',
                  keyboardType: TextInputType.name,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  readOnly: submitting,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Add a name so we know what to call you.' : null,
                ),
                const SizedBox(height: Space.md),
                LabeledTextField(
                  controller: _email,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  readOnly: submitting,
                  validator: validateEmail,
                  errorText: _emailError,
                ),
                const SizedBox(height: Space.md),
                LabeledTextField(
                  controller: _password,
                  label: 'Password',
                  hint: 'At least $minPasswordLength characters',
                  obscure: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  readOnly: submitting,
                  validator: validatePassword,
                  errorText: _passwordError,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.lg),
        PrimaryButton(label: 'Create account', loading: submitting, onPressed: _ready ? _submit : null),
        const SizedBox(height: Space.base),
        Text(
          'Nothing you write is shared unless you choose to share it.',
          textAlign: TextAlign.center,
          style: AppType.caption.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: Space.lg),
        AuthFooterLink(
          prompt: 'Already have an account?',
          link: 'Sign in',
          onPressed: () => context.go(AppRoutes.signIn),
        ),
      ],
    );
  }
}
