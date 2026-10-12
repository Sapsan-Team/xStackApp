import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/core/localization/language_selector_button.dart';
import 'package:xstackapp/core/router/routes.dart';
import 'package:xstackapp/core/theme/theme_toggle_button.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final usernameController = useTextEditingController();
    final displayNameController = useTextEditingController();

    final passwordFocusNode = useFocusNode();
    final usernameFocusNode = useFocusNode();
    final displayNameFocusNode = useFocusNode();

    final isPasswordObscured = useState(true);

    ref.listen<Failure?>(
      authControllerProvider.select((s) => s.failure),
      (prev, next) {
        if (next != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.localizedMessage(l10n)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          ref.read(authControllerProvider.notifier).clearError();
        }
      },
    );

    final isLoading = ref.watch(
      authControllerProvider.select((s) => s.isLoading),
    );

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final success = await ref.read(authControllerProvider.notifier).register(
            phoneNumber: phoneController.text,
            password: passwordController.text,
            username: usernameController.text,
            displayName: displayNameController.text,
          );

      if (success && context.mounted) {
        context.go(Routes.home);
      }
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: const [
          ThemeToggleButton(),
          LanguageSelectorButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.registerSubtitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.registerDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Phone
                    AuthTextField(
                      controller: phoneController,
                      label: '${l10n.phoneLabel} *',
                      hintText: l10n.phoneHint,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.requiredField;
                        }
                        if (value.trim().length < 6) {
                          return l10n.shortPhoneValidation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    AuthTextField(
                      controller: passwordController,
                      label: '${l10n.passwordLabel} *',
                      hintText: l10n.passwordHint,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: isPasswordObscured.value,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => displayNameFocusNode.requestFocus(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordObscured.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          isPasswordObscured.value = !isPasswordObscured.value;
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterPasswordValidation;
                        }
                        if (value.length < 8) {
                          return l10n.shortPasswordValidation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Display Name (optional)
                    AuthTextField(
                      controller: displayNameController,
                      focusNode: displayNameFocusNode,
                      label: l10n.displayNameLabel,
                      hintText: l10n.displayNameHint,
                      prefixIcon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.name],
                      onFieldSubmitted: (_) => usernameFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Username (optional)
                    AuthTextField(
                      controller: usernameController,
                      focusNode: usernameFocusNode,
                      label: l10n.usernameLabel,
                      hintText: l10n.usernameHint,
                      prefixIcon: Icons.alternate_email_rounded,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.username],
                      onFieldSubmitted: (_) => submit(),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final trimmed = value.trim();
                          if (trimmed.length < 3) {
                            return l10n.shortUsernameValidation;
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
                            return l10n.invalidUsernameValidation;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Submit
                    FilledButton(
                      onPressed: isLoading ? null : submit,
                      child: isLoading
                          ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Text(l10n.registerButton),
                    ),
                    const SizedBox(height: 16),

                    // Already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.haveAccountPrompt,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : () => context.pop(),
                          child: Text(l10n.loginButton),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
