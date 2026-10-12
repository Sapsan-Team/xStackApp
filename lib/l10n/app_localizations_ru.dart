// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'XStack';

  @override
  String get loginTitle => 'Добро пожаловать';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get loginSubtitle => 'Войдите в аккаунт, чтобы продолжить общение';

  @override
  String get phoneLabel => 'Номер телефона';

  @override
  String get phoneHint => '+79991234567';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordHint => 'Минимум 8 символов';

  @override
  String get loginButton => 'Войти';

  @override
  String get noAccountPrompt => 'Нет аккаунта?';

  @override
  String get createAccountButton => 'Создать аккаунт';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerSubtitle => 'Создание профиля';

  @override
  String get registerDescription =>
      'Заполните данные для создания нового аккаунта';

  @override
  String get displayNameLabel => 'Имя (отображаемое имя)';

  @override
  String get displayNameHint => 'Например, Иван';

  @override
  String get usernameLabel => 'Юзернейм (@username)';

  @override
  String get usernameHint => 'user_123';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get haveAccountPrompt => 'Уже есть аккаунт?';

  @override
  String get enterPhoneValidation => 'Введите номер телефона';

  @override
  String get shortPhoneValidation => 'Слишком короткий номер';

  @override
  String get enterPasswordValidation => 'Введите пароль';

  @override
  String get shortPasswordValidation =>
      'Пароль должен содержать минимум 8 символов';

  @override
  String get shortUsernameValidation => 'Юзернейм должен быть от 3 символов';

  @override
  String get invalidUsernameValidation =>
      'Допустимы только латинские буквы, цифры и _';

  @override
  String get requiredField => 'Обязательное поле';

  @override
  String get logoutButton => 'Выйти';

  @override
  String get logoutConfirmation => 'Выйти из аккаунта';

  @override
  String get userDefaultName => 'Пользователь';

  @override
  String get talkerLogsTitle => 'Системные логи';

  @override
  String get talkerLogsTooltip => 'Просмотр логов (Talker)';

  @override
  String get language => 'Язык';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get serverErrorDefault => 'Произошла ошибка сервера';

  @override
  String get networkErrorDefault => 'Проверьте подключение к сети';

  @override
  String get authErrorDefault => 'Неверный номер телефона или пароль';

  @override
  String get sessionExpired => 'Сессия истекла. Войдите снова.';

  @override
  String get accountAlreadyExists =>
      'Пользователь с таким номером или логином уже существует';

  @override
  String get unexpectedError => 'Непредвиденная ошибка';

  @override
  String get themeMode => 'Тема оформления';

  @override
  String get themeLight => 'Светлая тема';

  @override
  String get themeDark => 'Тёмная тема';

  @override
  String get themeSystem => 'Системная тема';

  @override
  String get toggleThemeTooltip => 'Сменить тему';
}
