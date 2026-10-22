import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstackapp/core/storage/preferences_storage.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/features/auth/domain/entities/user.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_state.dart';
import 'package:xstackapp/features/auth/presentation/screens/auth_screen.dart';
import 'package:xstackapp/features/boot/presentation/controllers/boot_controller.dart';
import 'package:xstackapp/features/boot/presentation/screens/boot_screen.dart';
import 'package:xstackapp/features/chat/data/repositories/chat_repository.dart';
import 'package:xstackapp/features/chat/domain/entities/chat.dart';
import 'package:xstackapp/features/chat/presentation/screens/workspace_screen.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class _FakeAuthController extends AuthController {
  @override
  AuthState build() => const AuthState(
    isAuthenticated: true,
    user: User(
      id: 'd2ff79be-0d97-4896-9fb4-05877ef92ba6',
      phoneNumber: '+79990000001',
      username: 'alice',
      displayName: 'Alice Petrova',
      bio: 'product design · keyboards · coffee',
    ),
  );
}

class _FakeBootController extends BootController {
  @override
  BootState build() => const BootState(phase: BootPhase.restoringSession);

  @override
  Future<void> run() async {}
}

class _FakeChatRepository implements ChatRepository {
  _FakeChatRepository() {
    // Pin the clock to a fixed time of day so goldens do not drift minute by
    // minute, while still rendering as "today" in the thread and chat list.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 20, 56);
    final createdAt = DateTime(2026, 10, 10, 9, 30);
    chats = [
      ChatSummary(
        id: 'group-1',
        type: 'group',
        title: 'design crew',
        createdAt: createdAt,
        updatedAt: today.subtract(const Duration(minutes: 2)),
        currentUserRole: 'owner',
        unreadCount: 2,
        lastMessage: ChatLastMessage(
          id: 'm1',
          senderName: 'Alice Petrova',
          content: 'go for it. keep them short — one command line, one hint.',
          createdAt: today.subtract(const Duration(minutes: 2)),
          isRead: false,
          isDeleted: false,
        ),
      ),
      ChatSummary(
        id: 'direct-1',
        type: 'private',
        createdAt: createdAt,
        updatedAt: today.subtract(const Duration(minutes: 26)),
        currentUserRole: 'member',
        unreadCount: 0,
        otherMemberId: 'bob-id',
        otherMemberUsername: 'bob',
        otherMemberDisplayName: 'Bob Ivanov',
        lastMessage: ChatLastMessage(
          id: 'm2',
          senderName: 'Bob Ivanov',
          content: 'I also moved the thread to a terminal-style log.',
          createdAt: today.subtract(const Duration(minutes: 26)),
          isRead: true,
          isDeleted: false,
        ),
      ),
      ChatSummary(
        id: 'direct-2',
        type: 'private',
        createdAt: createdAt,
        updatedAt: today.subtract(const Duration(hours: 3)),
        currentUserRole: 'member',
        unreadCount: 0,
        otherMemberId: 'carol-id',
        otherMemberUsername: 'carol',
        otherMemberDisplayName: 'Carol Sokolova',
        lastMessage: ChatLastMessage(
          id: 'm3',
          senderName: 'Carol Sokolova',
          content: 'the hairline borders look sharp.',
          createdAt: today.subtract(const Duration(hours: 3)),
          isRead: true,
          isDeleted: false,
        ),
      ),
    ];
    final start = today.subtract(const Duration(minutes: 40));
    messages = {
      'group-1': [
        ChatMessage(
          id: 'a',
          chatId: 'group-1',
          senderId: 'alice-id',
          senderName: 'Alice Petrova',
          content: 'design crew: shipping the dark theme today.',
          isRead: true,
          isEdited: false,
          isDeleted: false,
          isMine: true,
          createdAt: start,
          updatedAt: start,
        ),
        ChatMessage(
          id: 'b',
          chatId: 'group-1',
          senderId: 'carol-id',
          senderName: 'Carol Sokolova',
          content: 'the hairline borders look sharp. checking contrast on the muted text.',
          isRead: true,
          isEdited: false,
          isDeleted: false,
          isMine: false,
          createdAt: start.add(const Duration(minutes: 4)),
          updatedAt: start.add(const Duration(minutes: 4)),
        ),
        ChatMessage(
          id: 'c',
          chatId: 'group-1',
          senderId: 'bob-id',
          senderName: 'Bob Ivanov',
          content: 'I can take the empty states if you want.',
          isRead: true,
          isEdited: false,
          isDeleted: false,
          isMine: false,
          createdAt: start.add(const Duration(minutes: 9)),
          updatedAt: start.add(const Duration(minutes: 9)),
        ),
        ChatMessage(
          id: 'd',
          chatId: 'group-1',
          senderId: 'alice-id',
          senderName: 'Alice Petrova',
          content: 'go for it. keep them short — one command line, one hint.',
          isRead: false,
          isEdited: false,
          isDeleted: false,
          isMine: true,
          createdAt: start.add(const Duration(minutes: 13)),
          updatedAt: start.add(const Duration(minutes: 13)),
        ),
      ],
    };
  }

  late final List<ChatSummary> chats;
  late final Map<String, List<ChatMessage>> messages;

  @override
  Future<List<ChatSummary>> getChats() async => chats;

  @override
  Future<List<ChatMessage>> getMessages(
    String chatId, {
    int limit = 60,
  }) async => messages[chatId] ?? const [];

  @override
  Future<ChatMessage> sendMessage(String chatId, String content) async {
    final message = ChatMessage(
      id: 'sent',
      chatId: chatId,
      content: content,
      isRead: false,
      isEdited: false,
      isDeleted: false,
      isMine: true,
      senderName: 'Alice Petrova',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    messages.putIfAbsent(chatId, () => []).add(message);
    return message;
  }

  @override
  Future<void> markRead(String chatId, {String? messageId}) async {}

  @override
  Future<List<UserSearchResult>> searchUsers(
    String query, {
    int limit = 20,
  }) async => const [
    UserSearchResult(
      id: 'bob-id',
      phoneNumber: '+79990000002',
      username: 'bob',
      displayName: 'Bob Ivanov',
    ),
    UserSearchResult(
      id: 'carol-id',
      phoneNumber: '+79990000003',
      username: 'carol',
      displayName: 'Carol Sokolova',
    ),
  ];

  @override
  Future<ChatDetails> getChatDetails(String chatId) async {
    final chat = chats.firstWhere((c) => c.id == chatId);
    return ChatDetails(
      id: chat.id,
      type: chat.type,
      title: chat.title,
      createdAt: chat.createdAt,
      updatedAt: chat.updatedAt,
      currentUserRole: 'owner',
      otherMemberId: chat.otherMemberId,
      otherMemberUsername: chat.otherMemberUsername,
      otherMemberDisplayName: chat.otherMemberDisplayName,
      members: [
        ChatMember(
          userId: 'alice-id',
          phoneNumber: '+79990000001',
          username: 'alice',
          displayName: 'Alice Petrova',
          role: 'owner',
          joinedAt: chat.createdAt,
        ),
        ChatMember(
          userId: 'bob-id',
          phoneNumber: '+79990000002',
          username: 'bob',
          displayName: 'Bob Ivanov',
          role: 'member',
          joinedAt: chat.createdAt,
        ),
        ChatMember(
          userId: 'carol-id',
          phoneNumber: '+79990000003',
          username: 'carol',
          displayName: 'Carol Sokolova',
          role: 'member',
          joinedAt: chat.createdAt,
        ),
      ],
    );
  }

  @override
  Future<ChatDetails> createDirectChat(String userId) async =>
      getChatDetails('direct-1');

  @override
  Future<ChatDetails> createGroupChat(
    String title,
    List<String> memberUserIds,
  ) async => getChatDetails('group-1');
}

Future<void> _loadFonts() async {
  final loader = FontLoader(AppTheme.fontFamily);
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('assets/fonts/JetBrainsMono-$weight.ttf')
        .readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final materialIcons = flutterRoot == null
      ? null
      : File(
          '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
        );
  if (materialIcons != null && materialIcons.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons');
    iconLoader.addFont(
      Future.value(ByteData.sublistView(materialIcons.readAsBytesSync())),
    );
    await iconLoader.load();
  }
}

Future<ProviderContainer> _container({
  required bool authenticated,
  ChatRepository? repository,
}) async {
  SharedPreferences.setMockInitialValues({'app_locale': 'en'});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (authenticated)
        authControllerProvider.overrideWith(_FakeAuthController.new),
      if (repository != null)
        chatRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _app(
  Widget home,
  ProviderContainer container, {
  ThemeMode mode = ThemeMode.dark,
  Locale locale = const Locale('en'),
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void main() {
  setUpAll(_loadFonts);

  void sizeTo(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  void sizeToDesktop(WidgetTester tester) {
    sizeTo(tester, const Size(1440, 900));
  }

  testWidgets('boot golden', (tester) async {
    sizeToDesktop(tester);
    final container = await _container(authenticated: false);
    container.dispose();
    final bootContainer = ProviderContainer(
      overrides: [bootControllerProvider.overrideWith(_FakeBootController.new)],
    );
    addTearDown(bootContainer.dispose);
    await tester.pumpWidget(_app(const BootScreen(), bootContainer));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/boot_dark.png'),
    );
  });

  testWidgets('auth dark golden', (tester) async {
    sizeToDesktop(tester);
    final container = await _container(authenticated: false);
    await tester.pumpWidget(
      _app(const AuthScreen(mode: AuthMode.login), container),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/auth_dark.png'),
    );
  });

  testWidgets('auth light golden', (tester) async {
    sizeToDesktop(tester);
    final container = await _container(authenticated: false);
    await tester.pumpWidget(
      _app(
        const AuthScreen(mode: AuthMode.login),
        container,
        mode: ThemeMode.light,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/auth_light.png'),
    );
  });

  testWidgets('workspace dark golden', (tester) async {
    sizeToDesktop(tester);
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(_app(const WorkspaceScreen(), container));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/workspace_dark.png'),
    );
  });

  testWidgets('workspace light golden', (tester) async {
    sizeToDesktop(tester);
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(
      _app(const WorkspaceScreen(), container, mode: ThemeMode.light),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/workspace_light.png'),
    );
  });

  testWidgets('workspace mid golden', (tester) async {
    sizeTo(tester, const Size(951, 1031));
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(_app(const WorkspaceScreen(), container));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/workspace_mid.png'),
    );
  });

  testWidgets('workspace compact golden', (tester) async {
    sizeTo(tester, const Size(1024, 768));
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(_app(const WorkspaceScreen(), container));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/workspace_compact.png'),
    );
  });

  testWidgets('workspace narrow golden', (tester) async {
    sizeTo(tester, const Size(800, 600));
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(_app(const WorkspaceScreen(), container));
    await tester.pumpAndSettle();
    await tester.tap(find.text('design crew').first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/workspace_narrow.png'),
    );
  });

  testWidgets('new chat dialog golden', (tester) async {
    sizeToDesktop(tester);
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(_app(const WorkspaceScreen(), container));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/new_chat_dialog.png'),
    );
  });

  testWidgets('profile dialog golden', (tester) async {
    sizeToDesktop(tester);
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(_app(const WorkspaceScreen(), container));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('ctrl+,'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/profile_dialog.png'),
    );
  });

  testWidgets('shortcuts dialog golden', (tester) async {
    sizeToDesktop(tester);
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(_app(const WorkspaceScreen(), container));
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/shortcuts_dialog.png'),
    );
  });

  testWidgets('workspace russian golden', (tester) async {
    sizeToDesktop(tester);
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(
      _app(const WorkspaceScreen(), container, locale: const Locale('ru')),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/workspace_ru.png'),
    );
  });

  testWidgets('command palette golden', (tester) async {
    sizeToDesktop(tester);
    final repo = _FakeChatRepository();
    final container = await _container(authenticated: true, repository: repo);
    await tester.pumpWidget(_app(const WorkspaceScreen(), container));
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/palette_dark.png'),
    );
  });
}
