import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/localization/language_selector_button.dart';
import 'package:xstackapp/core/router/routes.dart';
import 'package:xstackapp/core/theme/theme_toggle_button.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.terminal_rounded),
            tooltip: l10n.talkerLogsTooltip,
            onPressed: () => context.push(Routes.logs),
          ),
          const ThemeToggleButton(),
          const LanguageSelectorButton(),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.logoutButton,
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        child: Text(
                          (user?.displayName?.isNotEmpty ?? false)
                              ? user!.displayName![0].toUpperCase()
                              : (user?.phoneNumber.isNotEmpty ?? false)
                                  ? user!.phoneNumber[0].toUpperCase()
                                  : 'U',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.displayName ?? l10n.userDefaultName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.username != null && user!.username!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        user?.phoneNumber ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          ref.read(authControllerProvider.notifier).logout();
                        },
                        icon: const Icon(Icons.logout),
                        label: Text(l10n.logoutConfirmation),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
