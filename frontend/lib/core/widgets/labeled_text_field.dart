import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_typography.dart';
import 'app_buttons.dart';

/// A label in [AppType.label] above a 54px field styled by the theme's
/// `inputDecorationTheme`. Password fields get a show/hide eye with a full
/// 44×44 tap target.
class LabeledTextField extends StatefulWidget {
  const LabeledTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.validator,
    this.errorText,
    this.readOnly = false,
    this.autofocus = false,
    this.onSubmitted,
    this.autocorrect = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;

  /// Server-side error to show under the field, e.g. a wrong password.
  final String? errorText;
  final bool readOnly;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final bool autocorrect;

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppType.label.copyWith(color: c.textSecondary)),
        const SizedBox(height: Space.sm),
        TextFormField(
          controller: widget.controller,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.autocorrect,
          onFieldSubmitted: widget.onSubmitted,
          style: AppType.bodyMedium.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            errorMaxLines: 2,
            constraints: const BoxConstraints(minHeight: kControlHeight),
            suffixIcon: widget.obscure
                ? TapTargetIconButton(
                    icon: _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                    tooltip: _hidden ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
