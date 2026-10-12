import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:xstackapp/core/localization/locale_controller.dart';
import 'package:xstackapp/core/logging/talker_service.dart';
import 'package:xstackapp/core/router/app_router.dart';
import 'package:xstackapp/core/storage/preferences_storage.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/theme/theme_controller.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupTalkerErrorHandling();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      observers: [
        TalkerRiverpodObserver(talker: talker),
      ],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const XStackApp(),
    ),
  );
}

class XStackApp extends ConsumerStatefulWidget {
  const XStackApp({super.key});

  @override
  ConsumerState<XStackApp> createState() => _XStackAppState();
}

class _XStackAppState extends ConsumerState<XStackApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
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
