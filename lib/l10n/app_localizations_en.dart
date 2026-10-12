// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'XStack';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get loginSubtitle => 'Sign in to your account to continue chatting';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '+79991234567';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get loginButton => 'Sign in';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get createAccountButton => 'Create account';

  @override
  String get registerTitle => 'Registration';

  @override
  String get registerSubtitle => 'Create profile';

  @override
  String get registerDescription =>
      'Enter your details to create a new account';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get displayNameHint => 'e.g., Alex';

  @override
  String get usernameLabel => 'Username (@username)';

  @override
  String get usernameHint => 'user_123';

  @override
  String get registerButton => 'Register';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get enterPhoneValidation => 'Enter phone number';

  @override
  String get shortPhoneValidation => 'Phone number is too short';

  @override
  String get enterPasswordValidation => 'Enter password';

  @override
  String get shortPasswordValidation =>
      'Password must be at least 8 characters';

  @override
  String get shortUsernameValidation =>
      'Username must be at least 3 characters';

  @override
  String get invalidUsernameValidation =>
      'Only latin letters, numbers, and _ are allowed';

  @override
  String get requiredField => 'Required field';

  @override
  String get logoutButton => 'Sign out';

  @override
  String get logoutConfirmation => 'Sign out from account';

  @override
  String get userDefaultName => 'User';

  @override
  String get talkerLogsTitle => 'System Logs';

  @override
  String get talkerLogsTooltip => 'View logs (Talker)';

  @override
  String get language => 'Language';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get serverErrorDefault => 'Server error occurred';

  @override
  String get networkErrorDefault => 'Please check your network connection';

  @override
  String get authErrorDefault => 'Invalid phone number or password';

  @override
  String get sessionExpired => 'Session expired. Please sign in again.';

  @override
  String get accountAlreadyExists =>
      'A user with this phone number or username already exists';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get themeLight => 'Light theme';

  @override
  String get themeDark => 'Dark theme';

  @override
  String get themeSystem => 'System theme';

  @override
  String get toggleThemeTooltip => 'Toggle theme';
}
