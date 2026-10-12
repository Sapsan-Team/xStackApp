import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main() via overrideWithValue');
});

final preferencesStorageProvider = Provider<PreferencesStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesStorage(prefs);
});

class PreferencesStorage {
  const PreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _lastPhoneKey = 'last_logged_in_phone';
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'app_locale';

  Future<void> saveLastPhone(String phone) async {
    await _prefs.setString(_lastPhoneKey, phone);
  }

  String? getLastPhone() {
    return _prefs.getString(_lastPhoneKey);
  }

  Future<void> clearLastPhone() async {
    await _prefs.remove(_lastPhoneKey);
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(_themeModeKey);
  }

  Future<void> saveLocale(String languageCode) async {
    await _prefs.setString(_localeKey, languageCode);
  }

  String? getLocale() {
    return _prefs.getString(_localeKey);
  }
}
