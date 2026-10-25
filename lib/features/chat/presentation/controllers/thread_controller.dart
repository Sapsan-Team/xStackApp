import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/core/errors/failure_mapper.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/chat/data/repositories/chat_repository.dart';
import 'package:xstackapp/features/chat/domain/entities/chat.dart';
import 'package:xstackapp/features/chat/presentation/controllers/chats_controller.dart';

class ThreadState {
  const ThreadState({
    this.chatId,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.failure,
    this.details,
  });

  final String? chatId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final Failure? failure;
  final ChatDetails? details;

  ThreadState copyWith({
    String? chatId,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    Failure? failure,
    bool clearFailure = false,
    bool clearChat = false,
    ChatDetails? details,
  }) {
    return ThreadState(
      chatId: clearChat ? null : (chatId ?? this.chatId),
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      failure: clearFailure ? null : (failure ?? this.failure),
      details: details ?? this.details,
    );
  }
}

final threadControllerProvider =
    NotifierProvider<ThreadController, ThreadState>(ThreadController.new);

class ThreadController extends Notifier<ThreadState> {
  int _request = 0;

  @override
  ThreadState build() => const ThreadState();

  Future<void> open(String chatId) async {
    final request = ++_request;
    state = ThreadState(chatId: chatId, isLoading: true);

    try {
      final repository = ref.read(chatRepositoryProvider);
      final messages = await repository.getMessages(chatId);
      if (request != _request) return;

      ChatDetails? details;
      try {
        details = await repository.getChatDetails(chatId);
      } catch (_) {
        // The thread is still usable without the metadata panel.
      }
      if (request != _request) return;

      state = state.copyWith(
        messages: messages,
        details: details,
        isLoading: false,
        clearFailure: true,
      );

      // Reading a thread clears its badge. Failures here are not worth
      // interrupting the conversation for.
      final lastId = messages.isEmpty ? null : messages.last.id;
      try {
        await ref
            .read(chatRepositoryProvider)
            .markRead(chatId, messageId: lastId);
        ref.read(chatsControllerProvider.notifier).markReadLocally(chatId);
      } catch (_) {}
    } catch (error) {
      if (request != _request) return;
      state = state.copyWith(isLoading: false, failure: failureFrom(error));
    }
  }

  Future<void> refresh() async {
    final chatId = state.chatId;
    if (chatId == null) return;

    try {
      final repository = ref.read(chatRepositoryProvider);
      final messages = await repository.getMessages(chatId);
      if (state.chatId != chatId) return;
      ChatDetails? details;
      try {
        details = await repository.getChatDetails(chatId);
      } catch (_) {}
      state = state.copyWith(
        messages: messages,
        details: details,
        isLoading: false,
        clearFailure: true,
      );
      ref.read(chatsControllerProvider.notifier).markReadLocally(chatId);
    } catch (error) {
      state = state.copyWith(failure: failureFrom(error));
    }
  }

  /// Quiet periodic tick from the workspace sync timer. It never surfaces
  /// errors into the UI and never disturbs an optimistic send in flight; the
  /// explicit ctrl+r refresh keeps the noisy behaviour for the user.
  Future<void> poll() async {
    final chatId = state.chatId;
    if (chatId == null || state.isLoading || state.isSending) return;
    if (state.messages.any((m) => m.isPending)) return;

    try {
      final repository = ref.read(chatRepositoryProvider);
      final messages = await repository.getMessages(chatId);
      if (state.chatId != chatId) return;
      if (_sameMessages(state.messages, messages)) return;

      state = state.copyWith(messages: messages, clearFailure: true);
      final lastId = messages.isEmpty ? null : messages.last.id;
      try {
        await ref
            .read(chatRepositoryProvider)
            .markRead(chatId, messageId: lastId);
        ref.read(chatsControllerProvider.notifier).markReadLocally(chatId);
      } catch (_) {}
    } catch (_) {
      // Transient failures stay invisible here on purpose.
    }
  }

  static bool _sameMessages(List<ChatMessage> a, List<ChatMessage> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      if (x.id != y.id ||
          x.updatedAt != y.updatedAt ||
          x.isRead != y.isRead ||
          x.content != y.content) {
        return false;
      }
    }
    return true;
  }

  /// Live message pushed by the realtime hub. Inserted in place unless it
  /// already arrived through the send flow or a poll tick.
  Future<void> applyIncoming(ChatMessage message) async {
    if (state.chatId != message.chatId) return;
    if (state.messages.any((m) => m.id == message.id)) return;

    state = state.copyWith(
      messages: [...state.messages, message],
      clearFailure: true,
    );

    if (message.isMine) return;
    final lastId = message.id;
    try {
      await ref
          .read(chatRepositoryProvider)
          .markRead(message.chatId, messageId: lastId);
      ref
          .read(chatsControllerProvider.notifier)
          .markReadLocally(message.chatId);
    } catch (_) {}
  }

  /// Live edit pushed by the realtime hub; sorted position does not change.
  void applyEdited(ChatMessage message) {
    if (state.chatId != message.chatId) return;
    final index = state.messages.indexWhere((m) => m.id == message.id);
    if (index < 0) return;

    final next = [...state.messages];
    next[index] = message;
    state = state.copyWith(messages: next);
  }

  /// Live soft-delete pushed by the realtime hub.
  void applyDeleted(String chatId, String messageId) {
    if (state.chatId != chatId) return;
    final index = state.messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;

    final next = [...state.messages];
    next[index] = next[index].copyWith(
      content: null,
      isDeleted: true,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(messages: next);
  }

  /// A per-user read cursor moved. [isMe] means it is our own cursor, so our
  /// incoming messages become read; otherwise the other side read our messages
  /// up to [lastReadMessageId].
  void applyRead(
    String chatId,
    String lastReadMessageId, {
    required bool isMe,
  }) {
    if (state.chatId != chatId) return;
    final index = state.messages.indexWhere((m) => m.id == lastReadMessageId);
    if (index < 0) return;

    var changed = false;
    final next = [...state.messages];
    for (var i = 0; i <= index; i++) {
      final message = next[i];
      final shouldMark = isMe ? !message.isMine : message.isMine;
      if (shouldMark && !message.isRead) {
        next[i] = message.copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      state = state.copyWith(messages: next);
    }
  }

  Future<bool> send(String rawContent) async {
    final chatId = state.chatId;
    final content = rawContent.trim();
    if (chatId == null || content.isEmpty || state.isSending) return false;

    final user = ref.read(authControllerProvider).user;
    final pending = ChatMessage.pending(
      chatId: chatId,
      content: content,
      createdAt: DateTime.now(),
      senderName: user?.displayName ?? user?.username,
    );

    state = state.copyWith(
      messages: [...state.messages, pending],
      isSending: true,
      clearFailure: true,
    );

    try {
      final sent = await ref
          .read(chatRepositoryProvider)
          .sendMessage(chatId, content);
      if (state.chatId != chatId) return true;

      final withoutPending = state.messages
          .where((m) => m.id != pending.id)
          .toList(growable: false);

      state = state.copyWith(
        messages: [...withoutPending, sent],
        isSending: false,
      );
      ref.read(chatsControllerProvider.notifier).noteOutgoingMessage(sent);
      return true;
    } catch (error) {
      if (state.chatId != chatId) return false;
      state = state.copyWith(
        messages: state.messages
            .where((m) => m.id != pending.id)
            .toList(growable: false),
        isSending: false,
        failure: failureFrom(error),
      );
      return false;
    }
  }

  void clear() {
    _request++;
    state = const ThreadState();
  }

  void clearFailure() {
    if (state.failure != null) {
      state = state.copyWith(clearFailure: true);
    }
  }
}
