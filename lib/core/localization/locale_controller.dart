import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/storage/preferences_storage.dart';

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final storage = ref.watch(preferencesStorageProvider);
    final savedCode = storage.getLocale();
    if (savedCode != null && savedCode.isNotEmpty) {
      return Locale(savedCode);
    }
    return const Locale('ru');
  }

  Future<void> setLocale(Locale newLocale) async {
    state = newLocale;
    final storage = ref.read(preferencesStorageProvider);
    await storage.saveLocale(newLocale.languageCode);
  }

  Future<void> toggleLocale() async {
    final nextCode = state.languageCode == 'ru' ? 'en' : 'ru';
    await setLocale(Locale(nextCode));
  }
}
