import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:xstackapp/core/logging/talker_service.dart';
import 'package:xstackapp/core/storage/token_storage.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_state.dart';
import 'package:xstackapp/features/chat/domain/entities/chat.dart';
import 'package:xstackapp/features/chat/presentation/controllers/chats_controller.dart';
import 'package:xstackapp/features/chat/presentation/controllers/presence_controller.dart';
import 'package:xstackapp/features/chat/presentation/controllers/thread_controller.dart';
import 'package:xstackapp/features/chat/presentation/controllers/typing_controller.dart';

final chatRealtimeServiceProvider = Provider<ChatRealtimeService>((ref) {
  final service = ChatRealtimeService(ref);
  ref.onDispose(service.disconnect);
  return service;
});

/// Bridges the realtime connection to the auth lifecycle: connects after a
/// sign-in or a session restore, disconnects on sign-out. Watch it once from
/// the app root so it is armed for the whole session.
final chatRealtimeBinderProvider = Provider<void>((ref) {
  final service = ref.read(chatRealtimeServiceProvider);
  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    final user = next.user;
    if (next.isAuthenticated && user != null) {
      service.connect(myUserId: user.id);
    } else {
      service.disconnect();
    }
  }, fireImmediately: true);
  ref.onDispose(service.disconnect);
});

/// Client of the backend SignalR hub (`/hubs/chat`). Delivers live messages,
/// typing and presence events into the chat controllers. Connection failures
/// are quiet: silent polling keeps working as a fallback, and the hub retries
/// with automatic reconnects on its own.
class ChatRealtimeService {
  ChatRealtimeService(this._ref);

  final Ref _ref;
  HubConnection? _connection;
  String? _myUserId;

  /// The chat whose room we aim to be in. Remembered even before a connection
  /// exists, so `onreconnected` can rejoin after any drop.
  String? _joinedChatId;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  Future<void> connect({required String myUserId}) async {
    _myUserId = myUserId;
    await disconnect();
    _ref.read(presenceControllerProvider.notifier).clear();

    final token = await _ref.read(tokenStorageProvider).getToken();
    if (token == null || token.isEmpty) return;

    final connection = HubConnectionBuilder()
        .withUrl(
          '${ApiConstants.baseUrl}${ApiConstants.chatHubPath}',
          options: HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect(retryDelays: const [0, 2000, 5000, 15000])
        .build();

    connection
      ..on('ReceiveMessage', (args) => _onMessage(args, isEdit: false))
      ..on('MessageEdited', (args) => _onMessage(args, isEdit: true))
      ..on('MessageDeleted', _onMessageDeleted)
      ..on('MessagesRead', (_) {})
      ..on('UserTyping', _onUserTyping)
      ..on('UserPresenceChanged', _onPresenceChanged)
      ..onreconnected(({connectionId}) => _joinCurrentChat())
      ..onclose(({error}) {
        if (error != null) {
          talker.warning('realtime dropped: $error');
        }
      });

    _connection = connection;
    try {
      await connection.start();
      talker.info('realtime connected');
      await _joinCurrentChat();
    } catch (error) {
      talker.warning('realtime connect failed: $error');
      _connection = null;
      try {
        await connection.stop();
      } catch (_) {}
    }
  }

  Future<void> disconnect() async {
    final connection = _connection;
    _connection = null;
    _joinedChatId = null;
    if (connection == null) return;
    try {
      await connection.stop();
    } catch (_) {}
  }

  /// Remember the chat to receive live events for and join its room right
  /// away when already connected.
  Future<void> enterChat(String chatId) async {
    _joinedChatId = chatId;
    await _joinCurrentChat();
  }

  /// Throttled by the composer; safe to call even when disconnected.
  Future<void> sendTyping(String chatId) async {
    final connection = _connection;
    if (connection == null ||
        connection.state != HubConnectionState.Connected) {
      return;
    }
    try {
      await connection.invoke('SendTyping', args: [chatId]);
    } catch (_) {}
  }

  Future<void> _joinCurrentChat() async {
    final connection = _connection;
    final chatId = _joinedChatId;
    if (connection == null || chatId == null) return;
    if (connection.state != HubConnectionState.Connected) return;
    try {
      await connection.invoke('JoinChat', args: [chatId]);
    } catch (error) {
      talker.warning('realtime join $chatId failed: $error');
    }
  }

  /// Hub payloads reuse the REST [ChatMessage] JSON. One quirk: broadcasts
  /// stamp `isMine: true` for every recipient, so trust [senderId] instead.
  void _onMessage(List<Object?>? args, {required bool isEdit}) {
    final payload = (args == null || args.isEmpty) ? null : args.first;
    if (payload is! Map) return;

    final ChatMessage message;
    try {
      message = ChatMessage.fromJson(payload.cast<String, dynamic>());
    } catch (error) {
      talker.warning('realtime message payload ignored: $error');
      return;
    }

    final mine = message.senderId != null && message.senderId == _myUserId;
    final normalized = message.copyWith(isMine: mine);

    final thread = _ref.read(threadControllerProvider.notifier);
    if (isEdit) {
      thread.applyEdited(normalized);
    } else {
      // A landed message also stops the sender's typing indicator without
      // waiting for its expiry timer.
      if (!mine) {
        _ref
            .read(typingControllerProvider.notifier)
            .clearUser(message.chatId, message.senderId ?? '');
      }
      thread.applyIncoming(normalized);
    }
    _ref
        .read(chatsControllerProvider.notifier)
        .noteIncomingMessage(normalized, isEdit: isEdit);
  }

  void _onMessageDeleted(List<Object?>? args) {
    final chatId = args != null && args.isNotEmpty ? args[0] : null;
    final messageId = args != null && args.length > 1 ? args[1] : null;
    if (chatId is String && messageId is String) {
      _ref
          .read(threadControllerProvider.notifier)
          .applyDeleted(chatId, messageId);
    }
  }

  void _onUserTyping(List<Object?>? args) {
    final chatId = args != null && args.isNotEmpty ? args[0] : null;
    final userId = args != null && args.length > 1 ? args[1] : null;
    final name = args != null && args.length > 2 ? args[2] : null;
    if (userId is String && userId != _myUserId) {
      _ref
          .read(typingControllerProvider.notifier)
          .markTyping(
            chatId is String ? chatId : '',
            userId,
            name is String && name.isNotEmpty ? name : userId,
          );
    }
  }

  void _onPresenceChanged(List<Object?>? args) {
    final userId = args != null && args.isNotEmpty ? args[0] : null;
    final isOnline = args != null && args.length > 1 ? args[1] : null;
    final lastSeen = args != null && args.length > 2 ? args[2] : null;
    if (userId is String && isOnline is bool) {
      _ref
          .read(presenceControllerProvider.notifier)
          .setPresence(
            userId,
            isOnline: isOnline,
            lastSeenAt: lastSeen is String ? DateTime.tryParse(lastSeen) : null,
          );
    }
  }
}
