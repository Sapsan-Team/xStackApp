import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/core/localization/language_selector_button.dart';
import 'package:xstackapp/core/router/routes.dart';
import 'package:xstackapp/core/storage/preferences_storage.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/theme/theme_toggle_button.dart';
import 'package:xstackapp/core/widgets/app_status_bar.dart';
import 'package:xstackapp/core/widgets/brand.dart';
import 'package:xstackapp/core/widgets/failure_banner.dart';
import 'package:xstackapp/core/widgets/key_hint.dart';
import 'package:xstackapp/core/widgets/terminal_spinner.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

enum AuthMode { login, register }

class AuthScreen extends HookConsumerWidget {
  const AuthScreen({super.key, required this.mode});

  final AuthMode mode;

  bool get _isLogin => mode == AuthMode.login;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final savedPhone = useMemoized(
      () => ref.read(preferencesStorageProvider).getLastPhone() ?? '',
    );

    final phoneController = useTextEditingController(
      text: _isLogin ? savedPhone : '',
    );
    final passwordController = useTextEditingController();
    final usernameController = useTextEditingController();
    final displayNameController = useTextEditingController();

    final phoneFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    final usernameFocus = useFocusNode();
    final displayNameFocus = useFocusNode();

    final passwordObscured = useState(true);
    final passwordFocused = useState(false);
    final capsLock = useState(false);

    useEffect(() {
      void listener() => passwordFocused.value = passwordFocus.hasFocus;
      passwordFocus.addListener(listener);
      return () => passwordFocus.removeListener(listener);
    }, [passwordFocus]);

    useEffect(() {
      bool handler(KeyEvent event) {
        final enabled = HardwareKeyboard.instance.lockModesEnabled.contains(
          KeyboardLockMode.capsLock,
        );
        if (capsLock.value != enabled) capsLock.value = enabled;
        return false;
      }

      HardwareKeyboard.instance.addHandler(handler);
      return () => HardwareKeyboard.instance.removeHandler(handler);
    }, []);

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final failure = authState.failure;

    void switchMode(AuthMode next) {
      if (next == mode) return;
      ref.read(authControllerProvider.notifier).clearError();
      context.go(next == AuthMode.login ? Routes.login : Routes.register);
    }

    Future<void> submit() async {
      if (isLoading) return;
      if (!(formKey.currentState?.validate() ?? false)) return;

      FocusScope.of(context).unfocus();

      final notifier = ref.read(authControllerProvider.notifier);
      final success = _isLogin
          ? await notifier.login(
              phoneNumber: phoneController.text.trim(),
              password: passwordController.text,
            )
          : await notifier.register(
              phoneNumber: phoneController.text.trim(),
              password: passwordController.text,
              username: usernameController.text.trim(),
              displayName: displayNameController.text.trim(),
            );

      if (success && context.mounted) {
        context.go(Routes.home);
      }
    }

    final host = Uri.parse(ApiConstants.baseUrl);
    final hostLabel = '${host.host}:${host.port}';

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, alt: true): () =>
            switchMode(AuthMode.login),
        const SingleActivator(LogicalKeyboardKey.digit2, alt: true): () =>
            switchMode(AuthMode.register),
        const SingleActivator(LogicalKeyboardKey.enter, control: true): submit,
        const SingleActivator(LogicalKeyboardKey.escape): () {
          FocusScope.of(context).unfocus();
          ref.read(authControllerProvider.notifier).clearError();
        },
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _AuthTopBar(isLogin: _isLogin),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    return Row(
                      children: [
                        if (wide)
                          Expanded(
                            flex: 11,
                            child: _BrandPane(hostLabel: hostLabel),
                          ),
                        if (wide)
                          Container(
                            width: 1,
                            color: colors.border,
                          ),
                        Expanded(
                          flex: 10,
                          child: _FormPane(
                            formKey: formKey,
                            wide: wide,
                            isLogin: _isLogin,
                            isLoading: isLoading,
                            failure: failure,
                            phoneController: phoneController,
                            passwordController: passwordController,
                            usernameController: usernameController,
                            displayNameController: displayNameController,
                            phoneFocus: phoneFocus,
                            passwordFocus: passwordFocus,
                            usernameFocus: usernameFocus,
                            displayNameFocus: displayNameFocus,
                            passwordObscured: passwordObscured,
                            capsLock: capsLock.value && passwordFocused.value,
                            onSubmit: submit,
                            onSwitchMode: switchMode,
                            onDismissFailure: () => ref
                                .read(authControllerProvider.notifier)
                                .clearError(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _AuthStatusBar(isLogin: _isLogin, l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar({required this.isLogin});

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final path = isLogin ? '~/auth/sign-in' : '~/auth/register';

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          const BrandWordmark(),
          const SizedBox(width: 12),
          Container(width: 1, height: 14, color: colors.border),
          const SizedBox(width: 12),
          Text(
            path,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              color: colors.textMuted,
            ),
          ),
          const Spacer(),
          const ThemeToggleButton(),
          const SizedBox(width: 4),
          const LanguageSelectorButton(),
        ],
      ),
    );
  }
}

class _BrandPane extends StatelessWidget {
  const _BrandPane({required this.hostLabel});

  final String hostLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return ColoredBox(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 48, 48, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const BrandMark(barWidth: 6, height: 34),
                const SizedBox(width: 14),
                Text(
                  'xstack',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                    color: colors.text,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 56),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                l10n.authTagline,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                  height: 1.35,
                  color: colors.text,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                l10n.authDescription,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  height: 1.7,
                  color: colors.textSecondary,
                ),
              ),
            ),
            const Spacer(),
            _SessionPanel(hostLabel: hostLabel),
            const SizedBox(height: 18),
            const _BlinkingPrompt(),
          ],
        ),
      ),
    );
  }
}

class _SessionPanel extends StatelessWidget {
  const _SessionPanel({required this.hostLabel});

  final String hostLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.authSession,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          _SessionRow(label: l10n.authHost, value: hostLabel),
          _SessionRow(
            label: l10n.authProtocol,
            value: l10n.authProtocolValue,
          ),
          _SessionRow(label: l10n.authAuthMethod, value: l10n.authAuthValue),
          _SessionRow(
            label: 'status',
            value: l10n.authReady,
            valueColor: colors.success,
            dot: true,
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.dot = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 10,
                color: colors.textMuted,
              ),
            ),
          ),
          if (dot) ...[
            StatusDot(color: valueColor ?? colors.success, size: 5),
            const SizedBox(width: 6),
          ],
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              color: valueColor ?? colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingPrompt extends StatefulWidget {
  const _BlinkingPrompt();

  @override
  State<_BlinkingPrompt> createState() => _BlinkingPromptState();
}

class _BlinkingPromptState extends State<_BlinkingPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final animate = !MediaQuery.of(context).disableAnimations;
    final style = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: 12,
      color: colors.textMuted,
    );

    return Row(
      children: [
        Text('\$', style: style),
        const SizedBox(width: 7),
        if (animate)
          FadeTransition(
            opacity: Tween<double>(begin: 0.15, end: 1).animate(_controller),
            child: Container(width: 7, height: 14, color: colors.textSecondary),
          )
        else
          Container(width: 7, height: 14, color: colors.textSecondary),
      ],
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({
    required this.formKey,
    required this.wide,
    required this.isLogin,
    required this.isLoading,
    required this.failure,
    required this.phoneController,
    required this.passwordController,
    required this.usernameController,
    required this.displayNameController,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.usernameFocus,
    required this.displayNameFocus,
    required this.passwordObscured,
    required this.capsLock,
    required this.onSubmit,
    required this.onSwitchMode,
    required this.onDismissFailure,
  });

  final GlobalKey<FormState> formKey;
  final bool wide;
  final bool isLogin;
  final bool isLoading;
  final Failure? failure;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;
  final TextEditingController displayNameController;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final FocusNode usernameFocus;
  final FocusNode displayNameFocus;
  final ValueNotifier<bool> passwordObscured;
  final bool capsLock;
  final Future<void> Function() onSubmit;
  final void Function(AuthMode) onSwitchMode;
  final VoidCallback onDismissFailure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final phonePrefilled = phoneController.text.trim().isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 40 : 24,
            vertical: 32,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 64,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 388),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!wide) ...[
                        const BrandWordmark(fontSize: 15),
                        const SizedBox(height: 28),
                      ],
                      _ModeTabs(
                        isLogin: isLogin,
                        onChanged: onSwitchMode,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        isLogin
                            ? l10n.authSignInHeading
                            : l10n.authRegisterHeading,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: colors.text,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLogin
                            ? l10n.authSignInSubtitle
                            : l10n.authRegisterSubtitle,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          height: 1.6,
                          color: colors.textSecondary,
                        ),
                      ),
                      if (failure != null) ...[
                        const SizedBox(height: 18),
                        FailureBanner(
                          failure: failure!,
                          onDismiss: onDismissFailure,
                        ),
                      ],
                      const SizedBox(height: 22),
                      TerminalField(
                        controller: phoneController,
                        focusNode: phoneFocus,
                        label: l10n.phoneLabel,
                        hintText: l10n.phoneHint,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        enabled: !isLoading,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        autofocus: isLogin
                            ? phoneController.text.trim().isEmpty
                            : true,
                        onFieldSubmitted: (_) => passwordFocus.requestFocus(),
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
                      const SizedBox(height: 14),
                      TerminalField(
                        controller: passwordController,
                        focusNode: passwordFocus,
                        label: l10n.passwordLabel,
                        hintText: l10n.passwordHint,
                        obscureText: passwordObscured.value,
                        textInputAction: isLogin
                            ? TextInputAction.done
                            : TextInputAction.next,
                        enabled: !isLoading,
                        autofocus: isLogin && phonePrefilled,
                        autofillHints: [
                          isLogin
                              ? AutofillHints.password
                              : AutofillHints.newPassword,
                        ],
                        helper: capsLock ? l10n.authCapsLock : null,
                        helperColor: colors.warning,
                        onFieldSubmitted: (_) => isLogin
                            ? onSubmit()
                            : usernameFocus.requestFocus(),
                        suffixIcon: IconButton(
                          tooltip: passwordObscured.value
                              ? l10n.authShowPassword
                              : l10n.authHidePassword,
                          icon: Icon(
                            passwordObscured.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 14,
                          ),
                          onPressed: () {
                            passwordObscured.value = !passwordObscured.value;
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterPasswordValidation;
                          }
                          if (!isLogin && value.length < 8) {
                            return l10n.shortPasswordValidation;
                          }
                          return null;
                        },
                      ),
                      if (!isLogin) ...[
                        const SizedBox(height: 14),
                        TerminalField(
                          controller: usernameController,
                          focusNode: usernameFocus,
                          label: l10n.usernameLabel,
                          hintText: l10n.usernameHint,
                          optional: true,
                          textInputAction: TextInputAction.next,
                          enabled: !isLoading,
                          autofillHints: const [AutofillHints.username],
                          onFieldSubmitted: (_) =>
                              displayNameFocus.requestFocus(),
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) return null;
                            if (trimmed.length < 3) {
                              return l10n.shortUsernameValidation;
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
                              return l10n.invalidUsernameValidation;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TerminalField(
                          controller: displayNameController,
                          focusNode: displayNameFocus,
                          label: l10n.displayNameLabel,
                          hintText: l10n.displayNameHint,
                          optional: true,
                          textInputAction: TextInputAction.done,
                          enabled: !isLoading,
                          autofillHints: const [AutofillHints.name],
                          onFieldSubmitted: (_) => onSubmit(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _SubmitButton(
                        isLogin: isLogin,
                        isLoading: isLoading,
                        onSubmit: onSubmit,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin ? l10n.authNewHere : l10n.authHasAccount,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: isLoading
                                ? null
                                : () => onSwitchMode(
                                      isLogin
                                          ? AuthMode.register
                                          : AuthMode.login,
                                    ),
                            borderRadius: BorderRadius.circular(3),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 2,
                              ),
                              child: Text(
                                isLogin
                                    ? l10n.authRegisterTab
                                    : l10n.authSignInTab,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.accent,
                                  decoration: TextDecoration.underline,
                                  decorationColor: colors.accent.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!wide) ...[
                        const SizedBox(height: 20),
                        Text(
                          l10n.authSessionNote,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 9,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.isLogin, required this.onChanged});

  final bool isLogin;
  final void Function(AuthMode) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: l10n.authSignInTab,
            active: isLogin,
            onTap: () => onChanged(AuthMode.login),
          ),
          const SizedBox(width: 20),
          _ModeTab(
            label: l10n.authRegisterTab,
            active: !isLogin,
            onTap: () => onChanged(AuthMode.register),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? colors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? colors.text : colors.textMuted,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 5),
              Text(
                '·',
                style: TextStyle(fontSize: 11, color: colors.accent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isLogin,
    required this.isLoading,
    required this.onSubmit,
  });

  final bool isLogin;
  final bool isLoading;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return SizedBox(
      height: 38,
      child: FilledButton(
        onPressed: isLoading ? null : onSubmit,
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TerminalSpinner(
                    color: colors.canvas,
                    label: isLogin ? l10n.authSigningIn : l10n.authRegistering,
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLogin ? l10n.loginButton : l10n.registerButton,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.canvas.withValues(alpha: 0.35),
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '↵',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 10,
                        height: 1.2,
                        color: colors.canvas.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _AuthStatusBar extends StatelessWidget {
  const _AuthStatusBar({required this.isLogin, required this.l10n});

  final bool isLogin;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final wide = MediaQuery.sizeOf(context).width >= 760;

    return AppStatusBar(
      left: [
        StatusDot(color: colors.success),
        const SizedBox(width: 6),
        StatusText(l10n.authReady, color: colors.textSecondary),
        const SizedBox(width: 14),
        StatusText('v0.1.0'),
      ],
      hints: wide
          ? [
              ShortcutHint(
                keys: const ['alt', '1'],
                label: l10n.authSignInTab,
                onTap: () => context.go(Routes.login),
              ),
              ShortcutHint(
                keys: const ['alt', '2'],
                label: l10n.authRegisterTab,
                onTap: () => context.go(Routes.register),
              ),
              ShortcutHint(
                keys: const ['ctrl', 'enter'],
                label: l10n.authSubmitShort,
              ),
            ]
          : const [],
      right: [
        StatusText('utf-8'),
        const SizedBox(width: 12),
        StatusText(isLogin ? 'auth.login' : 'auth.register'),
      ],
    );
  }
}
