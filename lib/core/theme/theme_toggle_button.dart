import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/theme/theme_controller.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeControllerProvider);
    final isDark = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => Theme.of(context).brightness == Brightness.dark,
    };

    return IconButton(
      tooltip: '${l10n?.toggleThemeTooltip ?? 'Toggle theme'}  ctrl+shift+l',
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        size: 15,
      ),
      onPressed: () => ref.read(themeControllerProvider.notifier).toggleTheme(
        context,
      ),
    );
  }
}
