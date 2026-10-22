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

  @override
  String get authTagline => 'A keyboard-first messenger for teams.';

  @override
  String get authDescription =>
      'Conversations, groups and people — one workspace, no noise.';

  @override
  String get authSignInHeading => 'Sign in to xstack';

  @override
  String get authSignInSubtitle =>
      'Your phone number and password. Everything else can wait.';

  @override
  String get authRegisterHeading => 'Create your account';

  @override
  String get authRegisterSubtitle =>
      'A phone number and password are enough. Add a name if you want one.';

  @override
  String get authSignInTab => 'sign in';

  @override
  String get authRegisterTab => 'register';

  @override
  String get authSession => 'session';

  @override
  String get authHost => 'host';

  @override
  String get authProtocol => 'api';

  @override
  String get authProtocolValue => 'http · bearer';

  @override
  String get authAuthMethod => 'auth';

  @override
  String get authAuthValue => 'jwt · 24h';

  @override
  String get authReady => 'ready';

  @override
  String get authSubmitHint => 'enter to continue';

  @override
  String get authSubmitSubmitHint => 'ctrl+enter to submit';

  @override
  String get authSubmitShort => 'submit';

  @override
  String get authCapsLock => 'caps lock is on';

  @override
  String get authShowPassword => 'show password';

  @override
  String get authHidePassword => 'hide password';

  @override
  String get authSigningIn => 'signing in';

  @override
  String get authRegistering => 'creating account';

  @override
  String get authNewHere => 'new here?';

  @override
  String get authHasAccount => 'already registered?';

  @override
  String get authSessionNote => 'your session stays on this device';

  @override
  String get bootStarting => 'starting session';

  @override
  String get bootRestoring => 'restoring workspace';

  @override
  String get bootConfig => 'loading preferences';

  @override
  String get bootWorkspace => 'opening workspace';

  @override
  String get bootHint => 'restoring local session';

  @override
  String get workspaceChats => 'chats';

  @override
  String get workspaceFilterChats => 'filter chats';

  @override
  String get workspaceFilterAll => 'all';

  @override
  String get workspaceFilterUnread => 'unread';

  @override
  String get workspaceFilterGroups => 'groups';

  @override
  String get workspaceNoChats => 'no conversations yet';

  @override
  String get workspaceNoChatsHint => 'start one with ctrl+n';

  @override
  String get workspaceNoFilterResults => 'nothing matches';

  @override
  String get workspaceNoFilterResultsHint =>
      'change the filter or clear the search';

  @override
  String get workspacePickChat => 'no conversation open';

  @override
  String get workspacePickChatHint => 'pick one from the list, or press ctrl+k';

  @override
  String get workspaceLoading => 'loading conversations';

  @override
  String get workspaceRetry => 'retry';

  @override
  String get workspaceMessageHint => 'write a message';

  @override
  String get workspaceSendHint => 'enter to send · shift+enter for a new line';

  @override
  String get workspaceSending => 'sending';

  @override
  String get workspaceMembers => 'members';

  @override
  String workspaceMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'no members',
    );
    return '$_temp0';
  }

  @override
  String get workspaceFieldType => 'type';

  @override
  String get workspaceFieldRole => 'role';

  @override
  String get workspaceFieldMembers => 'members';

  @override
  String get workspaceFieldCreated => 'created';

  @override
  String get workspaceFieldId => 'id';

  @override
  String get workspaceFieldPhone => 'phone';

  @override
  String get workspaceFieldUser => 'user';

  @override
  String get workspaceEdited => 'edited';

  @override
  String get workspaceDeleted => 'message deleted';

  @override
  String get workspaceToday => 'today';

  @override
  String get workspaceYesterday => 'yesterday';

  @override
  String get workspaceNewChat => 'new conversation';

  @override
  String get workspaceNewChatHint => 'find people by name, @username or phone';

  @override
  String get workspaceDirectMessage => 'direct message';

  @override
  String get workspaceNewGroup => 'new group';

  @override
  String get workspaceGroupTitle => 'group name';

  @override
  String get workspaceGroupTitleHint => 'e.g. design crew';

  @override
  String get workspaceAddPeople => 'add people';

  @override
  String get workspaceCreate => 'create';

  @override
  String get workspaceCancel => 'cancel';

  @override
  String get workspaceNoUsers => 'no people found';

  @override
  String get workspaceSearching => 'searching';

  @override
  String get workspaceStartChat => 'start chat';

  @override
  String get workspaceProfile => 'profile';

  @override
  String get workspaceAccount => 'account';

  @override
  String get workspaceAppearance => 'appearance';

  @override
  String get workspaceTheme => 'theme';

  @override
  String get workspaceLanguageLabel => 'language';

  @override
  String get workspaceLogs => 'system logs';

  @override
  String get workspaceSignOut => 'sign out';

  @override
  String get workspaceSignedInAs => 'signed in as';

  @override
  String get workspaceConnected => 'connected';

  @override
  String get workspaceOffline => 'offline';

  @override
  String get workspaceSyncing => 'syncing';

  @override
  String get workspaceShortcuts => 'keyboard shortcuts';

  @override
  String get workspaceCommands => 'commands';

  @override
  String get workspaceCommandHint => 'type a command or search conversations';

  @override
  String get workspaceActions => 'actions';

  @override
  String get workspaceNavigation => 'go to';

  @override
  String get workspaceNavigate => 'navigate';

  @override
  String get workspaceRun => 'run';

  @override
  String get workspaceSelect => 'select';

  @override
  String get workspaceSendMessage => 'send message';

  @override
  String get workspaceNewLine => 'new line';

  @override
  String get workspaceConversations => 'conversations';

  @override
  String get workspaceNoResults => 'no matches';

  @override
  String get workspaceClose => 'close';

  @override
  String get workspaceChatMembers => 'members';

  @override
  String get workspaceDirect => 'direct';

  @override
  String get workspaceGroup => 'group';

  @override
  String get workspaceNoMessages => 'no messages yet';

  @override
  String get workspaceNoMessagesHint => 'say something — enter sends';

  @override
  String get workspaceConnectionFailed => 'can\'t reach the server';

  @override
  String get workspaceConnectionHint =>
      'check that the API is running, then retry';

  @override
  String get workspaceToggleDetails => 'toggle details';

  @override
  String get workspaceRefresh => 'refresh';

  @override
  String get workspaceFocusComposer => 'focus composer';

  @override
  String get workspaceNextChat => 'next conversation';

  @override
  String get workspacePrevChat => 'previous conversation';

  @override
  String get workspaceCloseOverlay => 'close / leave field';

  @override
  String get workspaceToggleSidebar => 'toggle list';

  @override
  String get workspaceDetails => 'details';

  @override
  String get workspaceOpenLogs => 'open logs';

  @override
  String get workspaceVersion => 'version';

  @override
  String get workspaceMemberSince => 'member since';

  @override
  String get workspaceSessionValid => 'session active';

  @override
  String get workspaceDelete => 'delete';

  @override
  String get workspaceEdit => 'edit';

  @override
  String get workspaceCopy => 'copy';

  @override
  String get workspaceCopied => 'copied';

  @override
  String get workspaceNewChatAction => 'start a conversation';

  @override
  String get workspaceOpenProfileAction => 'open profile and settings';

  @override
  String get workspaceToggleThemeAction => 'switch light / dark';

  @override
  String get workspaceShowShortcutsAction => 'show this cheat sheet';

  @override
  String get workspaceSignOutAction => 'end the current session';

  @override
  String get workspaceRefreshAction => 'reload conversations';

  @override
  String get workspaceJumpToChat => 'jump to conversation';

  @override
  String get workspaceSearchPeople => 'search people';

  @override
  String get workspaceFilters => 'filters';

  @override
  String get workspaceOpenSettings => 'settings';

  @override
  String get workspaceRoleOwner => 'owner';

  @override
  String get workspaceRoleAdmin => 'admin';

  @override
  String get workspaceRoleMember => 'member';

  @override
  String get workspaceDirectChat => 'direct chat';

  @override
  String get workspaceGroupChat => 'group chat';

  @override
  String get workspaceReachable => 'api reachable';

  @override
  String get workspaceUnreachable => 'api unreachable';

  @override
  String get workspacePressEnter => 'press enter';

  @override
  String get workspaceYouAre => 'you';

  @override
  String get workspaceStartTyping => 'start typing a message';

  @override
  String get workspaceOlder => 'older messages';

  @override
  String get workspaceEndOfThread => 'start of the conversation';

  @override
  String get workspaceSearchHint => 'type to search';

  @override
  String get workspaceSelected => 'selected';

  @override
  String get workspaceLoadingThread => 'loading messages';

  @override
  String get workspaceMessageNotSent => 'message not sent';

  @override
  String get workspaceProfileBio => 'no bio yet';

  @override
  String get workspaceCloseDialog => 'esc to close';

  @override
  String workspaceSomeoneTyping(Object names) {
    return '$names typing…';
  }
}
