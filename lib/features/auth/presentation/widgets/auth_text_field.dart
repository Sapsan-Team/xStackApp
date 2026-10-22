import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xstackapp/core/theme/app_theme.dart';

/// Input with a small terminal-style label above the box.
class TerminalField extends StatelessWidget {
  const TerminalField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.suffixIcon,
    this.enabled = true,
    this.autofillHints,
    this.autofocus = false,
    this.helper,
    this.helperColor,
    this.optional = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final String? helper;
  final Color? helperColor;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: colors.textSecondary,
              ),
            ),
            if (optional) ...[
              const SizedBox(width: 5),
              Text(
                '(optional)',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 9,
                  color: colors.textMuted,
                ),
              ),
            ],
            const Spacer(),
            if (helper != null)
              Flexible(
                child: Text(
                  helper!,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 9,
                    color: helperColor ?? colors.textMuted,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          enabled: enabled,
          autofillHints: autofillHints,
          autocorrect: false,
          enableSuggestions: !obscureText,
          inputFormatters: keyboardType == TextInputType.phone
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]'))]
              : null,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            color: colors.text,
            height: 1.35,
          ),
          cursorWidth: 1.5,
          decoration: InputDecoration(
            hint: hintText == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text(
                      hintText!,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
            suffixIcon: suffixIcon,
            suffixIconColor: colors.textMuted,
          ),
        ),
      ],
    );
  }
}
