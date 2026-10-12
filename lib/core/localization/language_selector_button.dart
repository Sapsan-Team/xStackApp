import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/localization/locale_controller.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class LanguageSelectorButton extends ConsumerWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return PopupMenuButton<Locale>(
      tooltip: l10n?.language ?? 'Language',
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language_rounded, size: 20),
          const SizedBox(width: 4),
          Text(
            currentLocale.languageCode.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      onSelected: (locale) {
        ref.read(localeControllerProvider.notifier).setLocale(locale);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('ru'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'ru')
                const Icon(Icons.check, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(l10n?.languageRussian ?? 'Русский'),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(l10n?.languageEnglish ?? 'English'),
            ],
          ),
        ),
      ],
    );
  }
}
