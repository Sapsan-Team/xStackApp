import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'XStack'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать'**
  String get loginTitle;

  /// No description provided for @welcomeTo.
  ///
  /// In ru, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в аккаунт, чтобы продолжить общение'**
  String get loginSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In ru, this message translates to:
  /// **'+79991234567'**
  String get phoneHint;

  /// No description provided for @passwordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 8 символов'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта?'**
  String get noAccountPrompt;

  /// No description provided for @createAccountButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccountButton;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создание профиля'**
  String get registerSubtitle;

  /// No description provided for @registerDescription.
  ///
  /// In ru, this message translates to:
  /// **'Заполните данные для создания нового аккаунта'**
  String get registerDescription;

  /// No description provided for @displayNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя (отображаемое имя)'**
  String get displayNameLabel;

  /// No description provided for @displayNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, Иван'**
  String get displayNameHint;

  /// No description provided for @usernameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Юзернейм (@username)'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In ru, this message translates to:
  /// **'user_123'**
  String get usernameHint;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerButton;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get haveAccountPrompt;

  /// No description provided for @enterPhoneValidation.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона'**
  String get enterPhoneValidation;

  /// No description provided for @shortPhoneValidation.
  ///
  /// In ru, this message translates to:
  /// **'Слишком короткий номер'**
  String get shortPhoneValidation;

  /// No description provided for @enterPasswordValidation.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get enterPasswordValidation;

  /// No description provided for @shortPasswordValidation.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать минимум 8 символов'**
  String get shortPasswordValidation;

  /// No description provided for @shortUsernameValidation.
  ///
  /// In ru, this message translates to:
  /// **'Юзернейм должен быть от 3 символов'**
  String get shortUsernameValidation;

  /// No description provided for @invalidUsernameValidation.
  ///
  /// In ru, this message translates to:
  /// **'Допустимы только латинские буквы, цифры и _'**
  String get invalidUsernameValidation;

  /// No description provided for @requiredField.
  ///
  /// In ru, this message translates to:
  /// **'Обязательное поле'**
  String get requiredField;

  /// No description provided for @logoutButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logoutButton;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get logoutConfirmation;

  /// No description provided for @userDefaultName.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь'**
  String get userDefaultName;

  /// No description provided for @talkerLogsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Системные логи'**
  String get talkerLogsTitle;

  /// No description provided for @talkerLogsTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Просмотр логов (Talker)'**
  String get talkerLogsTooltip;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @serverErrorDefault.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка сервера'**
  String get serverErrorDefault;

  /// No description provided for @networkErrorDefault.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте подключение к сети'**
  String get networkErrorDefault;

  /// No description provided for @authErrorDefault.
  ///
  /// In ru, this message translates to:
  /// **'Неверный номер телефона или пароль'**
  String get authErrorDefault;

  /// No description provided for @sessionExpired.
  ///
  /// In ru, this message translates to:
  /// **'Сессия истекла. Войдите снова.'**
  String get sessionExpired;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь с таким номером или логином уже существует'**
  String get accountAlreadyExists;

  /// No description provided for @unexpectedError.
  ///
  /// In ru, this message translates to:
  /// **'Непредвиденная ошибка'**
  String get unexpectedError;

  /// No description provided for @themeMode.
  ///
  /// In ru, this message translates to:
  /// **'Тема оформления'**
  String get themeMode;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая тема'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная тема'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная тема'**
  String get themeSystem;

  /// No description provided for @toggleThemeTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Сменить тему'**
  String get toggleThemeTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
