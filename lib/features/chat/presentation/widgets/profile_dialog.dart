import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/localization/locale_controller.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/theme/theme_controller.dart';
import 'package:xstackapp/core/widgets/app_status_bar.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/chat/presentation/widgets/workspace_widgets.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class ProfileDialog extends ConsumerWidget {
  const ProfileDialog({
    super.key,
    required this.onSignOut,
    required this.onLogs,
  });

  final VoidCallback onSignOut;
  final VoidCallback onLogs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : (user?.username?.trim().isNotEmpty == true
              ? user!.username!
              : (user?.phoneNumber ?? l10n.userDefaultName));
    final handle = user?.username?.isNotEmpty == true
        ? '@${user!.username}'
        : (user?.phoneNumber ?? '');

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: 450,
          constraints: const BoxConstraints(maxHeight: 560),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.only(left: 14, right: 6),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.workspaceProfile,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: '${l10n.workspaceClose}  esc',
                      icon: const Icon(Icons.close, size: 14),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InitialsAvatar(name: name, size: 42, accent: true),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  handle,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 10,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          user.bio!,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            height: 1.6,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          StatusDot(color: colors.success),
                          const SizedBox(width: 6),
                          Text(
                            l10n.workspaceSessionValid,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 10,
                              color: colors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            user == null
                                ? ''
                                : (user.id.length > 8
                                      ? user.id.substring(0, 8)
                                      : user.id),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 9,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: colors.borderMuted),
                          ),
                        ),
                        child: Column(
                          children: [
                            _Row(
                              label: 'phone',
                              value: user?.phoneNumber ?? '—',
                            ),
                            if (user?.username != null)
                              _Row(label: 'user', value: '@${user!.username}'),
                            _Row(
                              label: 'host',
                              value: Uri.parse(ApiConstants.baseUrl).authority,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        l10n.workspaceAppearance,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(height: 1, color: colors.borderMuted),
                      const SizedBox(height: 10),
                      _ChoiceRow(
                        label: l10n.workspaceTheme,
                        options: [
                          _Choice(
                            label: l10n.themeLight,
                            icon: Icons.light_mode_outlined,
                            selected: themeMode == ThemeMode.light,
                            onTap: () => ref
                                .read(themeControllerProvider.notifier)
                                .setThemeMode(ThemeMode.light),
                          ),
                          _Choice(
                            label: l10n.themeDark,
                            icon: Icons.dark_mode_outlined,
                            selected: themeMode == ThemeMode.dark,
                            onTap: () => ref
                                .read(themeControllerProvider.notifier)
                                .setThemeMode(ThemeMode.dark),
                          ),
                          _Choice(
                            label: l10n.themeSystem,
                            icon: Icons.desktop_windows_outlined,
                            selected: themeMode == ThemeMode.system,
                            onTap: () => ref
                                .read(themeControllerProvider.notifier)
                                .setThemeMode(ThemeMode.system),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ChoiceRow(
                        label: l10n.workspaceLanguageLabel,
                        options: [
                          _Choice(
                            label: 'EN',
                            selected: locale.languageCode == 'en',
                            onTap: () => ref
                                .read(localeControllerProvider.notifier)
                                .setLocale(const Locale('en')),
                          ),
                          _Choice(
                            label: 'RU',
                            selected: locale.languageCode == 'ru',
                            onTap: () => ref
                                .read(localeControllerProvider.notifier)
                                .setLocale(const Locale('ru')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(height: 1, color: colors.borderMuted),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onLogs();
                            },
                            icon: const Icon(Icons.terminal, size: 13),
                            label: Text(l10n.workspaceLogs),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onSignOut();
                            },
                            icon: Icon(
                              Icons.logout,
                              size: 13,
                              color: colors.danger,
                            ),
                            label: Text(
                              l10n.workspaceSignOut,
                              style: TextStyle(color: colors.danger),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 9,
                color: colors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 10,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Choice {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.label, required this.options});

  final String label;
  final List<_Choice> options;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              color: colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final option in options)
                InkWell(
                  onTap: option.onTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: option.selected
                          ? colors.accentMuted
                          : Colors.transparent,
                      border: Border.all(
                        color: option.selected
                            ? colors.accent.withValues(alpha: 0.55)
                            : colors.borderMuted,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (option.icon != null) ...[
                          Icon(
                            option.icon,
                            size: 12,
                            color: option.selected
                                ? colors.accent
                                : colors.textMuted,
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          option.label,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 9.5,
                            color: option.selected
                                ? colors.accent
                                : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
