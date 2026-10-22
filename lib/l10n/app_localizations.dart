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

  /// No description provided for @authTagline.
  ///
  /// In ru, this message translates to:
  /// **'Мессенджер для команд, где всё делается с клавиатуры.'**
  String get authTagline;

  /// No description provided for @authDescription.
  ///
  /// In ru, this message translates to:
  /// **'Переписки, группы и люди — одно рабочее пространство, без лишнего.'**
  String get authDescription;

  /// No description provided for @authSignInHeading.
  ///
  /// In ru, this message translates to:
  /// **'Вход в xstack'**
  String get authSignInHeading;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона и пароль — остальное подождёт.'**
  String get authSignInSubtitle;

  /// No description provided for @authRegisterHeading.
  ///
  /// In ru, this message translates to:
  /// **'Создайте аккаунт'**
  String get authRegisterHeading;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Достаточно номера и пароля. Имя можно добавить, если хотите.'**
  String get authRegisterSubtitle;

  /// No description provided for @authSignInTab.
  ///
  /// In ru, this message translates to:
  /// **'вход'**
  String get authSignInTab;

  /// No description provided for @authRegisterTab.
  ///
  /// In ru, this message translates to:
  /// **'регистрация'**
  String get authRegisterTab;

  /// No description provided for @authSession.
  ///
  /// In ru, this message translates to:
  /// **'сессия'**
  String get authSession;

  /// No description provided for @authHost.
  ///
  /// In ru, this message translates to:
  /// **'хост'**
  String get authHost;

  /// No description provided for @authProtocol.
  ///
  /// In ru, this message translates to:
  /// **'api'**
  String get authProtocol;

  /// No description provided for @authProtocolValue.
  ///
  /// In ru, this message translates to:
  /// **'http · bearer'**
  String get authProtocolValue;

  /// No description provided for @authAuthMethod.
  ///
  /// In ru, this message translates to:
  /// **'авторизация'**
  String get authAuthMethod;

  /// No description provided for @authAuthValue.
  ///
  /// In ru, this message translates to:
  /// **'jwt · 24ч'**
  String get authAuthValue;

  /// No description provided for @authReady.
  ///
  /// In ru, this message translates to:
  /// **'готово'**
  String get authReady;

  /// No description provided for @authSubmitHint.
  ///
  /// In ru, this message translates to:
  /// **'enter — дальше'**
  String get authSubmitHint;

  /// No description provided for @authSubmitSubmitHint.
  ///
  /// In ru, this message translates to:
  /// **'ctrl+enter — отправить'**
  String get authSubmitSubmitHint;

  /// No description provided for @authSubmitShort.
  ///
  /// In ru, this message translates to:
  /// **'отправить'**
  String get authSubmitShort;

  /// No description provided for @authCapsLock.
  ///
  /// In ru, this message translates to:
  /// **'включён caps lock'**
  String get authCapsLock;

  /// No description provided for @authShowPassword.
  ///
  /// In ru, this message translates to:
  /// **'показать пароль'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In ru, this message translates to:
  /// **'скрыть пароль'**
  String get authHidePassword;

  /// No description provided for @authSigningIn.
  ///
  /// In ru, this message translates to:
  /// **'входим'**
  String get authSigningIn;

  /// No description provided for @authRegistering.
  ///
  /// In ru, this message translates to:
  /// **'создаём аккаунт'**
  String get authRegistering;

  /// No description provided for @authNewHere.
  ///
  /// In ru, this message translates to:
  /// **'впервые здесь?'**
  String get authNewHere;

  /// No description provided for @authHasAccount.
  ///
  /// In ru, this message translates to:
  /// **'уже есть аккаунт?'**
  String get authHasAccount;

  /// No description provided for @authSessionNote.
  ///
  /// In ru, this message translates to:
  /// **'сессия хранится только на этом устройстве'**
  String get authSessionNote;

  /// No description provided for @bootStarting.
  ///
  /// In ru, this message translates to:
  /// **'запуск сессии'**
  String get bootStarting;

  /// No description provided for @bootRestoring.
  ///
  /// In ru, this message translates to:
  /// **'восстанавливаем рабочее пространство'**
  String get bootRestoring;

  /// No description provided for @bootConfig.
  ///
  /// In ru, this message translates to:
  /// **'загружаем настройки'**
  String get bootConfig;

  /// No description provided for @bootWorkspace.
  ///
  /// In ru, this message translates to:
  /// **'открываем рабочее пространство'**
  String get bootWorkspace;

  /// No description provided for @bootHint.
  ///
  /// In ru, this message translates to:
  /// **'восстанавливаем локальную сессию'**
  String get bootHint;

  /// No description provided for @workspaceChats.
  ///
  /// In ru, this message translates to:
  /// **'чаты'**
  String get workspaceChats;

  /// No description provided for @workspaceFilterChats.
  ///
  /// In ru, this message translates to:
  /// **'фильтр чатов'**
  String get workspaceFilterChats;

  /// No description provided for @workspaceFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'все'**
  String get workspaceFilterAll;

  /// No description provided for @workspaceFilterUnread.
  ///
  /// In ru, this message translates to:
  /// **'непрочитанные'**
  String get workspaceFilterUnread;

  /// No description provided for @workspaceFilterGroups.
  ///
  /// In ru, this message translates to:
  /// **'группы'**
  String get workspaceFilterGroups;

  /// No description provided for @workspaceNoChats.
  ///
  /// In ru, this message translates to:
  /// **'пока нет переписок'**
  String get workspaceNoChats;

  /// No description provided for @workspaceNoChatsHint.
  ///
  /// In ru, this message translates to:
  /// **'начните новую — ctrl+n'**
  String get workspaceNoChatsHint;

  /// No description provided for @workspaceNoFilterResults.
  ///
  /// In ru, this message translates to:
  /// **'ничего не найдено'**
  String get workspaceNoFilterResults;

  /// No description provided for @workspaceNoFilterResultsHint.
  ///
  /// In ru, this message translates to:
  /// **'смените фильтр или очистите поиск'**
  String get workspaceNoFilterResultsHint;

  /// No description provided for @workspacePickChat.
  ///
  /// In ru, this message translates to:
  /// **'переписка не открыта'**
  String get workspacePickChat;

  /// No description provided for @workspacePickChatHint.
  ///
  /// In ru, this message translates to:
  /// **'выберите чат слева или нажмите ctrl+k'**
  String get workspacePickChatHint;

  /// No description provided for @workspaceLoading.
  ///
  /// In ru, this message translates to:
  /// **'загружаем переписки'**
  String get workspaceLoading;

  /// No description provided for @workspaceRetry.
  ///
  /// In ru, this message translates to:
  /// **'повторить'**
  String get workspaceRetry;

  /// No description provided for @workspaceMessageHint.
  ///
  /// In ru, this message translates to:
  /// **'напишите сообщение'**
  String get workspaceMessageHint;

  /// No description provided for @workspaceSendHint.
  ///
  /// In ru, this message translates to:
  /// **'enter — отправить · shift+enter — новая строка'**
  String get workspaceSendHint;

  /// No description provided for @workspaceSending.
  ///
  /// In ru, this message translates to:
  /// **'отправляем'**
  String get workspaceSending;

  /// No description provided for @workspaceMembers.
  ///
  /// In ru, this message translates to:
  /// **'участники'**
  String get workspaceMembers;

  /// No description provided for @workspaceMemberCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{нет участников} one{{count} участник} few{{count} участника} many{{count} участников} other{{count} участника}}'**
  String workspaceMemberCount(int count);

  /// No description provided for @workspaceFieldType.
  ///
  /// In ru, this message translates to:
  /// **'тип'**
  String get workspaceFieldType;

  /// No description provided for @workspaceFieldRole.
  ///
  /// In ru, this message translates to:
  /// **'роль'**
  String get workspaceFieldRole;

  /// No description provided for @workspaceFieldMembers.
  ///
  /// In ru, this message translates to:
  /// **'участники'**
  String get workspaceFieldMembers;

  /// No description provided for @workspaceFieldCreated.
  ///
  /// In ru, this message translates to:
  /// **'создан'**
  String get workspaceFieldCreated;

  /// No description provided for @workspaceFieldId.
  ///
  /// In ru, this message translates to:
  /// **'id'**
  String get workspaceFieldId;

  /// No description provided for @workspaceFieldPhone.
  ///
  /// In ru, this message translates to:
  /// **'телефон'**
  String get workspaceFieldPhone;

  /// No description provided for @workspaceFieldUser.
  ///
  /// In ru, this message translates to:
  /// **'логин'**
  String get workspaceFieldUser;

  /// No description provided for @workspaceEdited.
  ///
  /// In ru, this message translates to:
  /// **'изменено'**
  String get workspaceEdited;

  /// No description provided for @workspaceDeleted.
  ///
  /// In ru, this message translates to:
  /// **'сообщение удалено'**
  String get workspaceDeleted;

  /// No description provided for @workspaceToday.
  ///
  /// In ru, this message translates to:
  /// **'сегодня'**
  String get workspaceToday;

  /// No description provided for @workspaceYesterday.
  ///
  /// In ru, this message translates to:
  /// **'вчера'**
  String get workspaceYesterday;

  /// No description provided for @workspaceNewChat.
  ///
  /// In ru, this message translates to:
  /// **'новая переписка'**
  String get workspaceNewChat;

  /// No description provided for @workspaceNewChatHint.
  ///
  /// In ru, this message translates to:
  /// **'ищите людей по имени, @юзернейму или телефону'**
  String get workspaceNewChatHint;

  /// No description provided for @workspaceDirectMessage.
  ///
  /// In ru, this message translates to:
  /// **'личное сообщение'**
  String get workspaceDirectMessage;

  /// No description provided for @workspaceNewGroup.
  ///
  /// In ru, this message translates to:
  /// **'новая группа'**
  String get workspaceNewGroup;

  /// No description provided for @workspaceGroupTitle.
  ///
  /// In ru, this message translates to:
  /// **'название группы'**
  String get workspaceGroupTitle;

  /// No description provided for @workspaceGroupTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'например, дизайн-команда'**
  String get workspaceGroupTitleHint;

  /// No description provided for @workspaceAddPeople.
  ///
  /// In ru, this message translates to:
  /// **'добавить людей'**
  String get workspaceAddPeople;

  /// No description provided for @workspaceCreate.
  ///
  /// In ru, this message translates to:
  /// **'создать'**
  String get workspaceCreate;

  /// No description provided for @workspaceCancel.
  ///
  /// In ru, this message translates to:
  /// **'отмена'**
  String get workspaceCancel;

  /// No description provided for @workspaceNoUsers.
  ///
  /// In ru, this message translates to:
  /// **'никого не нашли'**
  String get workspaceNoUsers;

  /// No description provided for @workspaceSearching.
  ///
  /// In ru, this message translates to:
  /// **'ищем'**
  String get workspaceSearching;

  /// No description provided for @workspaceStartChat.
  ///
  /// In ru, this message translates to:
  /// **'начать чат'**
  String get workspaceStartChat;

  /// No description provided for @workspaceProfile.
  ///
  /// In ru, this message translates to:
  /// **'профиль'**
  String get workspaceProfile;

  /// No description provided for @workspaceAccount.
  ///
  /// In ru, this message translates to:
  /// **'аккаунт'**
  String get workspaceAccount;

  /// No description provided for @workspaceAppearance.
  ///
  /// In ru, this message translates to:
  /// **'оформление'**
  String get workspaceAppearance;

  /// No description provided for @workspaceTheme.
  ///
  /// In ru, this message translates to:
  /// **'тема'**
  String get workspaceTheme;

  /// No description provided for @workspaceLanguageLabel.
  ///
  /// In ru, this message translates to:
  /// **'язык'**
  String get workspaceLanguageLabel;

  /// No description provided for @workspaceLogs.
  ///
  /// In ru, this message translates to:
  /// **'системные логи'**
  String get workspaceLogs;

  /// No description provided for @workspaceSignOut.
  ///
  /// In ru, this message translates to:
  /// **'выйти'**
  String get workspaceSignOut;

  /// No description provided for @workspaceSignedInAs.
  ///
  /// In ru, this message translates to:
  /// **'вы вошли как'**
  String get workspaceSignedInAs;

  /// No description provided for @workspaceConnected.
  ///
  /// In ru, this message translates to:
  /// **'на связи'**
  String get workspaceConnected;

  /// No description provided for @workspaceOffline.
  ///
  /// In ru, this message translates to:
  /// **'нет связи'**
  String get workspaceOffline;

  /// No description provided for @workspaceSyncing.
  ///
  /// In ru, this message translates to:
  /// **'синхронизация'**
  String get workspaceSyncing;

  /// No description provided for @workspaceShortcuts.
  ///
  /// In ru, this message translates to:
  /// **'горячие клавиши'**
  String get workspaceShortcuts;

  /// No description provided for @workspaceCommands.
  ///
  /// In ru, this message translates to:
  /// **'команды'**
  String get workspaceCommands;

  /// No description provided for @workspaceCommandHint.
  ///
  /// In ru, this message translates to:
  /// **'введите команду или найдите переписку'**
  String get workspaceCommandHint;

  /// No description provided for @workspaceActions.
  ///
  /// In ru, this message translates to:
  /// **'действия'**
  String get workspaceActions;

  /// No description provided for @workspaceNavigation.
  ///
  /// In ru, this message translates to:
  /// **'переходы'**
  String get workspaceNavigation;

  /// No description provided for @workspaceNavigate.
  ///
  /// In ru, this message translates to:
  /// **'навигация'**
  String get workspaceNavigate;

  /// No description provided for @workspaceRun.
  ///
  /// In ru, this message translates to:
  /// **'выполнить'**
  String get workspaceRun;

  /// No description provided for @workspaceSelect.
  ///
  /// In ru, this message translates to:
  /// **'выбрать'**
  String get workspaceSelect;

  /// No description provided for @workspaceSendMessage.
  ///
  /// In ru, this message translates to:
  /// **'отправить сообщение'**
  String get workspaceSendMessage;

  /// No description provided for @workspaceNewLine.
  ///
  /// In ru, this message translates to:
  /// **'новая строка'**
  String get workspaceNewLine;

  /// No description provided for @workspaceConversations.
  ///
  /// In ru, this message translates to:
  /// **'переписки'**
  String get workspaceConversations;

  /// No description provided for @workspaceNoResults.
  ///
  /// In ru, this message translates to:
  /// **'совпадений нет'**
  String get workspaceNoResults;

  /// No description provided for @workspaceClose.
  ///
  /// In ru, this message translates to:
  /// **'закрыть'**
  String get workspaceClose;

  /// No description provided for @workspaceChatMembers.
  ///
  /// In ru, this message translates to:
  /// **'участники'**
  String get workspaceChatMembers;

  /// No description provided for @workspaceDirect.
  ///
  /// In ru, this message translates to:
  /// **'личный'**
  String get workspaceDirect;

  /// No description provided for @workspaceGroup.
  ///
  /// In ru, this message translates to:
  /// **'группа'**
  String get workspaceGroup;

  /// No description provided for @workspaceNoMessages.
  ///
  /// In ru, this message translates to:
  /// **'сообщений пока нет'**
  String get workspaceNoMessages;

  /// No description provided for @workspaceNoMessagesHint.
  ///
  /// In ru, this message translates to:
  /// **'напишите первым — enter отправит'**
  String get workspaceNoMessagesHint;

  /// No description provided for @workspaceConnectionFailed.
  ///
  /// In ru, this message translates to:
  /// **'сервер недоступен'**
  String get workspaceConnectionFailed;

  /// No description provided for @workspaceConnectionHint.
  ///
  /// In ru, this message translates to:
  /// **'проверьте, что API запущен, и повторите'**
  String get workspaceConnectionHint;

  /// No description provided for @workspaceToggleDetails.
  ///
  /// In ru, this message translates to:
  /// **'панель деталей'**
  String get workspaceToggleDetails;

  /// No description provided for @workspaceRefresh.
  ///
  /// In ru, this message translates to:
  /// **'обновить'**
  String get workspaceRefresh;

  /// No description provided for @workspaceFocusComposer.
  ///
  /// In ru, this message translates to:
  /// **'поле ввода'**
  String get workspaceFocusComposer;

  /// No description provided for @workspaceNextChat.
  ///
  /// In ru, this message translates to:
  /// **'следующий чат'**
  String get workspaceNextChat;

  /// No description provided for @workspacePrevChat.
  ///
  /// In ru, this message translates to:
  /// **'предыдущий чат'**
  String get workspacePrevChat;

  /// No description provided for @workspaceCloseOverlay.
  ///
  /// In ru, this message translates to:
  /// **'закрыть / выйти из поля'**
  String get workspaceCloseOverlay;

  /// No description provided for @workspaceToggleSidebar.
  ///
  /// In ru, this message translates to:
  /// **'список чатов'**
  String get workspaceToggleSidebar;

  /// No description provided for @workspaceDetails.
  ///
  /// In ru, this message translates to:
  /// **'детали'**
  String get workspaceDetails;

  /// No description provided for @workspaceOpenLogs.
  ///
  /// In ru, this message translates to:
  /// **'открыть логи'**
  String get workspaceOpenLogs;

  /// No description provided for @workspaceVersion.
  ///
  /// In ru, this message translates to:
  /// **'версия'**
  String get workspaceVersion;

  /// No description provided for @workspaceMemberSince.
  ///
  /// In ru, this message translates to:
  /// **'в xstack с'**
  String get workspaceMemberSince;

  /// No description provided for @workspaceSessionValid.
  ///
  /// In ru, this message translates to:
  /// **'сессия активна'**
  String get workspaceSessionValid;

  /// No description provided for @workspaceDelete.
  ///
  /// In ru, this message translates to:
  /// **'удалить'**
  String get workspaceDelete;

  /// No description provided for @workspaceEdit.
  ///
  /// In ru, this message translates to:
  /// **'изменить'**
  String get workspaceEdit;

  /// No description provided for @workspaceCopy.
  ///
  /// In ru, this message translates to:
  /// **'копировать'**
  String get workspaceCopy;

  /// No description provided for @workspaceCopied.
  ///
  /// In ru, this message translates to:
  /// **'скопировано'**
  String get workspaceCopied;

  /// No description provided for @workspaceNewChatAction.
  ///
  /// In ru, this message translates to:
  /// **'начать переписку'**
  String get workspaceNewChatAction;

  /// No description provided for @workspaceOpenProfileAction.
  ///
  /// In ru, this message translates to:
  /// **'профиль и настройки'**
  String get workspaceOpenProfileAction;

  /// No description provided for @workspaceToggleThemeAction.
  ///
  /// In ru, this message translates to:
  /// **'сменить тему'**
  String get workspaceToggleThemeAction;

  /// No description provided for @workspaceShowShortcutsAction.
  ///
  /// In ru, this message translates to:
  /// **'показать шпаргалку'**
  String get workspaceShowShortcutsAction;

  /// No description provided for @workspaceSignOutAction.
  ///
  /// In ru, this message translates to:
  /// **'завершить сессию'**
  String get workspaceSignOutAction;

  /// No description provided for @workspaceRefreshAction.
  ///
  /// In ru, this message translates to:
  /// **'перезагрузить переписки'**
  String get workspaceRefreshAction;

  /// No description provided for @workspaceJumpToChat.
  ///
  /// In ru, this message translates to:
  /// **'перейти к чату'**
  String get workspaceJumpToChat;

  /// No description provided for @workspaceSearchPeople.
  ///
  /// In ru, this message translates to:
  /// **'поиск людей'**
  String get workspaceSearchPeople;

  /// No description provided for @workspaceFilters.
  ///
  /// In ru, this message translates to:
  /// **'фильтры'**
  String get workspaceFilters;

  /// No description provided for @workspaceOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'настройки'**
  String get workspaceOpenSettings;

  /// No description provided for @workspaceRoleOwner.
  ///
  /// In ru, this message translates to:
  /// **'владелец'**
  String get workspaceRoleOwner;

  /// No description provided for @workspaceRoleAdmin.
  ///
  /// In ru, this message translates to:
  /// **'админ'**
  String get workspaceRoleAdmin;

  /// No description provided for @workspaceRoleMember.
  ///
  /// In ru, this message translates to:
  /// **'участник'**
  String get workspaceRoleMember;

  /// No description provided for @workspaceDirectChat.
  ///
  /// In ru, this message translates to:
  /// **'личный чат'**
  String get workspaceDirectChat;

  /// No description provided for @workspaceGroupChat.
  ///
  /// In ru, this message translates to:
  /// **'групповой чат'**
  String get workspaceGroupChat;

  /// No description provided for @workspaceReachable.
  ///
  /// In ru, this message translates to:
  /// **'api доступен'**
  String get workspaceReachable;

  /// No description provided for @workspaceUnreachable.
  ///
  /// In ru, this message translates to:
  /// **'api недоступен'**
  String get workspaceUnreachable;

  /// No description provided for @workspacePressEnter.
  ///
  /// In ru, this message translates to:
  /// **'нажмите enter'**
  String get workspacePressEnter;

  /// No description provided for @workspaceYouAre.
  ///
  /// In ru, this message translates to:
  /// **'вы'**
  String get workspaceYouAre;

  /// No description provided for @workspaceStartTyping.
  ///
  /// In ru, this message translates to:
  /// **'начните печатать сообщение'**
  String get workspaceStartTyping;

  /// No description provided for @workspaceOlder.
  ///
  /// In ru, this message translates to:
  /// **'более ранние сообщения'**
  String get workspaceOlder;

  /// No description provided for @workspaceEndOfThread.
  ///
  /// In ru, this message translates to:
  /// **'начало переписки'**
  String get workspaceEndOfThread;

  /// No description provided for @workspaceSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'введите запрос'**
  String get workspaceSearchHint;

  /// No description provided for @workspaceSelected.
  ///
  /// In ru, this message translates to:
  /// **'выбрано'**
  String get workspaceSelected;

  /// No description provided for @workspaceLoadingThread.
  ///
  /// In ru, this message translates to:
  /// **'загружаем сообщения'**
  String get workspaceLoadingThread;

  /// No description provided for @workspaceMessageNotSent.
  ///
  /// In ru, this message translates to:
  /// **'сообщение не отправлено'**
  String get workspaceMessageNotSent;

  /// No description provided for @workspaceProfileBio.
  ///
  /// In ru, this message translates to:
  /// **'био пока нет'**
  String get workspaceProfileBio;

  /// No description provided for @workspaceCloseDialog.
  ///
  /// In ru, this message translates to:
  /// **'esc — закрыть'**
  String get workspaceCloseDialog;

  /// No description provided for @workspaceSomeoneTyping.
  ///
  /// In ru, this message translates to:
  /// **'{names} печатает…'**
  String workspaceSomeoneTyping(Object names);
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
