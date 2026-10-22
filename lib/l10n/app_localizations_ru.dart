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

  @override
  String get authTagline =>
      'Мессенджер для команд, где всё делается с клавиатуры.';

  @override
  String get authDescription =>
      'Переписки, группы и люди — одно рабочее пространство, без лишнего.';

  @override
  String get authSignInHeading => 'Вход в xstack';

  @override
  String get authSignInSubtitle =>
      'Номер телефона и пароль — остальное подождёт.';

  @override
  String get authRegisterHeading => 'Создайте аккаунт';

  @override
  String get authRegisterSubtitle =>
      'Достаточно номера и пароля. Имя можно добавить, если хотите.';

  @override
  String get authSignInTab => 'вход';

  @override
  String get authRegisterTab => 'регистрация';

  @override
  String get authSession => 'сессия';

  @override
  String get authHost => 'хост';

  @override
  String get authProtocol => 'api';

  @override
  String get authProtocolValue => 'http · bearer';

  @override
  String get authAuthMethod => 'авторизация';

  @override
  String get authAuthValue => 'jwt · 24ч';

  @override
  String get authReady => 'готово';

  @override
  String get authSubmitHint => 'enter — дальше';

  @override
  String get authSubmitSubmitHint => 'ctrl+enter — отправить';

  @override
  String get authSubmitShort => 'отправить';

  @override
  String get authCapsLock => 'включён caps lock';

  @override
  String get authShowPassword => 'показать пароль';

  @override
  String get authHidePassword => 'скрыть пароль';

  @override
  String get authSigningIn => 'входим';

  @override
  String get authRegistering => 'создаём аккаунт';

  @override
  String get authNewHere => 'впервые здесь?';

  @override
  String get authHasAccount => 'уже есть аккаунт?';

  @override
  String get authSessionNote => 'сессия хранится только на этом устройстве';

  @override
  String get bootStarting => 'запуск сессии';

  @override
  String get bootRestoring => 'восстанавливаем рабочее пространство';

  @override
  String get bootConfig => 'загружаем настройки';

  @override
  String get bootWorkspace => 'открываем рабочее пространство';

  @override
  String get bootHint => 'восстанавливаем локальную сессию';

  @override
  String get workspaceChats => 'чаты';

  @override
  String get workspaceFilterChats => 'фильтр чатов';

  @override
  String get workspaceFilterAll => 'все';

  @override
  String get workspaceFilterUnread => 'непрочитанные';

  @override
  String get workspaceFilterGroups => 'группы';

  @override
  String get workspaceNoChats => 'пока нет переписок';

  @override
  String get workspaceNoChatsHint => 'начните новую — ctrl+n';

  @override
  String get workspaceNoFilterResults => 'ничего не найдено';

  @override
  String get workspaceNoFilterResultsHint =>
      'смените фильтр или очистите поиск';

  @override
  String get workspacePickChat => 'переписка не открыта';

  @override
  String get workspacePickChatHint => 'выберите чат слева или нажмите ctrl+k';

  @override
  String get workspaceLoading => 'загружаем переписки';

  @override
  String get workspaceRetry => 'повторить';

  @override
  String get workspaceMessageHint => 'напишите сообщение';

  @override
  String get workspaceSendHint =>
      'enter — отправить · shift+enter — новая строка';

  @override
  String get workspaceSending => 'отправляем';

  @override
  String get workspaceMembers => 'участники';

  @override
  String workspaceMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
      zero: 'нет участников',
    );
    return '$_temp0';
  }

  @override
  String get workspaceFieldType => 'тип';

  @override
  String get workspaceFieldRole => 'роль';

  @override
  String get workspaceFieldMembers => 'участники';

  @override
  String get workspaceFieldCreated => 'создан';

  @override
  String get workspaceFieldId => 'id';

  @override
  String get workspaceFieldPhone => 'телефон';

  @override
  String get workspaceFieldUser => 'логин';

  @override
  String get workspaceEdited => 'изменено';

  @override
  String get workspaceDeleted => 'сообщение удалено';

  @override
  String get workspaceToday => 'сегодня';

  @override
  String get workspaceYesterday => 'вчера';

  @override
  String get workspaceNewChat => 'новая переписка';

  @override
  String get workspaceNewChatHint =>
      'ищите людей по имени, @юзернейму или телефону';

  @override
  String get workspaceDirectMessage => 'личное сообщение';

  @override
  String get workspaceNewGroup => 'новая группа';

  @override
  String get workspaceGroupTitle => 'название группы';

  @override
  String get workspaceGroupTitleHint => 'например, дизайн-команда';

  @override
  String get workspaceAddPeople => 'добавить людей';

  @override
  String get workspaceCreate => 'создать';

  @override
  String get workspaceCancel => 'отмена';

  @override
  String get workspaceNoUsers => 'никого не нашли';

  @override
  String get workspaceSearching => 'ищем';

  @override
  String get workspaceStartChat => 'начать чат';

  @override
  String get workspaceProfile => 'профиль';

  @override
  String get workspaceAccount => 'аккаунт';

  @override
  String get workspaceAppearance => 'оформление';

  @override
  String get workspaceTheme => 'тема';

  @override
  String get workspaceLanguageLabel => 'язык';

  @override
  String get workspaceLogs => 'системные логи';

  @override
  String get workspaceSignOut => 'выйти';

  @override
  String get workspaceSignedInAs => 'вы вошли как';

  @override
  String get workspaceConnected => 'на связи';

  @override
  String get workspaceOffline => 'нет связи';

  @override
  String get workspaceSyncing => 'синхронизация';

  @override
  String get workspaceShortcuts => 'горячие клавиши';

  @override
  String get workspaceCommands => 'команды';

  @override
  String get workspaceCommandHint => 'введите команду или найдите переписку';

  @override
  String get workspaceActions => 'действия';

  @override
  String get workspaceNavigation => 'переходы';

  @override
  String get workspaceNavigate => 'навигация';

  @override
  String get workspaceRun => 'выполнить';

  @override
  String get workspaceSelect => 'выбрать';

  @override
  String get workspaceSendMessage => 'отправить сообщение';

  @override
  String get workspaceNewLine => 'новая строка';

  @override
  String get workspaceConversations => 'переписки';

  @override
  String get workspaceNoResults => 'совпадений нет';

  @override
  String get workspaceClose => 'закрыть';

  @override
  String get workspaceChatMembers => 'участники';

  @override
  String get workspaceDirect => 'личный';

  @override
  String get workspaceGroup => 'группа';

  @override
  String get workspaceNoMessages => 'сообщений пока нет';

  @override
  String get workspaceNoMessagesHint => 'напишите первым — enter отправит';

  @override
  String get workspaceConnectionFailed => 'сервер недоступен';

  @override
  String get workspaceConnectionHint =>
      'проверьте, что API запущен, и повторите';

  @override
  String get workspaceToggleDetails => 'панель деталей';

  @override
  String get workspaceRefresh => 'обновить';

  @override
  String get workspaceFocusComposer => 'поле ввода';

  @override
  String get workspaceNextChat => 'следующий чат';

  @override
  String get workspacePrevChat => 'предыдущий чат';

  @override
  String get workspaceCloseOverlay => 'закрыть / выйти из поля';

  @override
  String get workspaceToggleSidebar => 'список чатов';

  @override
  String get workspaceDetails => 'детали';

  @override
  String get workspaceOpenLogs => 'открыть логи';

  @override
  String get workspaceVersion => 'версия';

  @override
  String get workspaceMemberSince => 'в xstack с';

  @override
  String get workspaceSessionValid => 'сессия активна';

  @override
  String get workspaceDelete => 'удалить';

  @override
  String get workspaceEdit => 'изменить';

  @override
  String get workspaceCopy => 'копировать';

  @override
  String get workspaceCopied => 'скопировано';

  @override
  String get workspaceNewChatAction => 'начать переписку';

  @override
  String get workspaceOpenProfileAction => 'профиль и настройки';

  @override
  String get workspaceToggleThemeAction => 'сменить тему';

  @override
  String get workspaceShowShortcutsAction => 'показать шпаргалку';

  @override
  String get workspaceSignOutAction => 'завершить сессию';

  @override
  String get workspaceRefreshAction => 'перезагрузить переписки';

  @override
  String get workspaceJumpToChat => 'перейти к чату';

  @override
  String get workspaceSearchPeople => 'поиск людей';

  @override
  String get workspaceFilters => 'фильтры';

  @override
  String get workspaceOpenSettings => 'настройки';

  @override
  String get workspaceRoleOwner => 'владелец';

  @override
  String get workspaceRoleAdmin => 'админ';

  @override
  String get workspaceRoleMember => 'участник';

  @override
  String get workspaceDirectChat => 'личный чат';

  @override
  String get workspaceGroupChat => 'групповой чат';

  @override
  String get workspaceReachable => 'api доступен';

  @override
  String get workspaceUnreachable => 'api недоступен';

  @override
  String get workspacePressEnter => 'нажмите enter';

  @override
  String get workspaceYouAre => 'вы';

  @override
  String get workspaceStartTyping => 'начните печатать сообщение';

  @override
  String get workspaceOlder => 'более ранние сообщения';

  @override
  String get workspaceEndOfThread => 'начало переписки';

  @override
  String get workspaceSearchHint => 'введите запрос';

  @override
  String get workspaceSelected => 'выбрано';

  @override
  String get workspaceLoadingThread => 'загружаем сообщения';

  @override
  String get workspaceMessageNotSent => 'сообщение не отправлено';

  @override
  String get workspaceProfileBio => 'био пока нет';

  @override
  String get workspaceCloseDialog => 'esc — закрыть';

  @override
  String workspaceSomeoneTyping(Object names) {
    return '$names печатает…';
  }
}
