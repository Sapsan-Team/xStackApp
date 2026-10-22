import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:xstackapp/core/localization/locale_controller.dart';
import 'package:xstackapp/core/logging/talker_service.dart';
import 'package:xstackapp/core/router/app_router.dart';
import 'package:xstackapp/core/storage/preferences_storage.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/theme/theme_controller.dart';
import 'package:xstackapp/features/chat/data/realtime/chat_realtime_service.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupTalkerErrorHandling();
  await initializeDateFormatting();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      observers: [TalkerRiverpodObserver(talker: talker)],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const XStackApp(),
    ),
  );
}

class XStackApp extends ConsumerWidget {
  const XStackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Arms the SignalR connection for the whole session: it follows the auth
    // state (connect on sign-in/restore, disconnect on sign-out).
    ref.watch(chatRealtimeBinderProvider);

    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'XStack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
