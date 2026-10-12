import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/core/localization/language_selector_button.dart';
import 'package:xstackapp/core/router/routes.dart';
import 'package:xstackapp/core/storage/preferences_storage.dart';
import 'package:xstackapp/core/theme/theme_toggle_button.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final passwordFocusNode = useFocusNode();
    final isPasswordObscured = useState(true);

    // Prepopulate saved phone if available
    useEffect(() {
      final lastPhone = ref.read(preferencesStorageProvider).getLastPhone();
      if (lastPhone != null && lastPhone.isNotEmpty) {
        phoneController.text = lastPhone;
      }
      return null;
    }, const []);

    // Listen to error updates
    ref.listen<Failure?>(authControllerProvider.select((s) => s.failure), (
      prev,
      next,
    ) {
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
    });

    final isLoading = ref.watch(
      authControllerProvider.select((s) => s.isLoading),
    );

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final success = await ref
          .read(authControllerProvider.notifier)
          .login(
            phoneNumber: phoneController.text,
            password: passwordController.text,
          );

      if (success && context.mounted) {
        context.go(Routes.home);
      }
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: const [
          ThemeToggleButton(),
          LanguageSelectorButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Slogan with stylized inline SVG logo
                    Text.rich(
                      TextSpan(
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(text: '${l10n.welcomeTo} '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 2,
                              ),
                              child: SvgPicture.asset(
                                'assets/images/logo.svg',
                                height: 32,
                                fit: BoxFit.contain,
                                semanticsLabel: l10n.appName,
                              ),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Inputs
                    AuthTextField(
                      controller: phoneController,
                      label: l10n.phoneLabel,
                      hintText: l10n.phoneHint,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.enterPhoneValidation;
                        }
                        if (value.trim().length < 6) {
                          return l10n.shortPhoneValidation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: passwordController,
                      focusNode: passwordFocusNode,
                      label: l10n.passwordLabel,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: isPasswordObscured.value,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => submit(),
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Submit button
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
                          : Text(l10n.loginButton),
                    ),
                    const SizedBox(height: 16),

                    // Switch to Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.noAccountPrompt,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.push(Routes.register),
                          child: Text(l10n.createAccountButton),
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
