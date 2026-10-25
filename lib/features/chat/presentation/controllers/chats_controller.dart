import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/core/errors/failure_mapper.dart';
import 'package:xstackapp/features/chat/data/repositories/chat_repository.dart';
import 'package:xstackapp/features/chat/domain/entities/chat.dart';
import 'package:xstackapp/features/chat/presentation/controllers/thread_controller.dart';

enum ChatFilter { all, unread, groups }

class ChatsState {
  const ChatsState({
    this.chats = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.failure,
    this.query = '',
    this.filter = ChatFilter.all,
    this.selectedChatId,
    this.hasLoaded = false,
  });

  final List<ChatSummary> chats;
  final bool isLoading;
  final bool isRefreshing;
  final Failure? failure;
  final String query;
  final ChatFilter filter;
  final String? selectedChatId;
  final bool hasLoaded;

  ChatSummary? get selectedChat {
    for (final chat in chats) {
      if (chat.id == selectedChatId) return chat;
    }
    return null;
  }

  List<ChatSummary> get visibleChats {
    final needle = query.trim().toLowerCase();
    return chats
        .where((chat) {
          final unread = filter == ChatFilter.unread && chat.unreadCount == 0;
          if (unread) {
            return false;
          }
          final onlyGroups = filter == ChatFilter.groups && !chat.isGroup;
          if (onlyGroups) {
            return false;
          }
          if (needle.isEmpty) {
            return true;
          }
          return chat.displayName.toLowerCase().contains(needle) ||
              chat.handle.toLowerCase().contains(needle) ||
              (chat.lastMessage?.content ?? '').toLowerCase().contains(needle);
        })
        .toList(growable: false);
  }

  ChatsState copyWith({
    List<ChatSummary>? chats,
    bool? isLoading,
    bool? isRefreshing,
    Failure? failure,
    bool clearFailure = false,
    String? query,
    ChatFilter? filter,
    String? selectedChatId,
    bool clearSelection = false,
    bool? hasLoaded,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: clearFailure ? null : (failure ?? this.failure),
      query: query ?? this.query,
      filter: filter ?? this.filter,
      selectedChatId: clearSelection
          ? null
          : (selectedChatId ?? this.selectedChatId),
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

final chatsControllerProvider = NotifierProvider<ChatsController, ChatsState>(
  ChatsController.new,
);

class ChatsController extends Notifier<ChatsState> {
  @override
  ChatsState build() => const ChatsState();

  Future<void> refresh({bool silent = false}) async {
    if (state.isRefreshing) return;
    state = state.copyWith(
      isLoading: !state.hasLoaded && !silent,
      isRefreshing: true,
      clearFailure: true,
    );

    try {
      final chats = await ref.read(chatRepositoryProvider).getChats();
      state = state.copyWith(
        chats: chats,
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        clearFailure: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        failure: failureFrom(error),
      );
    }
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setFilter(ChatFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Selects a chat and opens its thread. [focusComposer] is handled by the UI.
  void openChat(String chatId) {
    if (state.selectedChatId == chatId) {
      return;
    }
    state = state.copyWith(selectedChatId: chatId);
    ref.read(threadControllerProvider.notifier).open(chatId);
  }

  void closeChat() {
    state = state.copyWith(clearSelection: true);
    ref.read(threadControllerProvider.notifier).clear();
  }

  void markUnread(String chatId, int unread) {
    final next = [
      for (final chat in state.chats)
        if (chat.id == chatId) chat.copyWith(unreadCount: unread) else chat,
    ];
    state = state.copyWith(chats: next);
  }

  void markReadLocally(String chatId) {
    markUnread(chatId, 0);
  }

  /// Bumps a chat to the top after a message is sent.
  void noteOutgoingMessage(ChatMessage message) {
    final index = state.chats.indexWhere((c) => c.id == message.chatId);
    if (index < 0) return;

    final chat = state.chats[index];
    final updated = chat.copyWith(
      lastMessage: ChatLastMessage(
        id: message.id,
        senderId: message.senderId,
        senderName: message.senderName,
        content: message.content,
        createdAt: message.createdAt,
        isRead: message.isRead,
        isDeleted: message.isDeleted,
      ),
      updatedAt: message.createdAt,
      unreadCount: 0,
    );

    final next = [...state.chats]..removeAt(index);
    state = state.copyWith(chats: [updated, ...next]);
  }

  /// Live or edited message pushed by the realtime hub. Moves the chat to the
  /// top and bumps the unread badge unless the thread is open in front of the
  /// user (it reads the message on its own).
  void noteIncomingMessage(ChatMessage message, {bool isEdit = false}) {
    final index = state.chats.indexWhere((c) => c.id == message.chatId);
    if (index < 0) {
      // A chat we have never seen — someone started a conversation or added us
      // to a group. Pull the list instead of silently dropping the message.
      unawaited(refresh(silent: true));
      return;
    }

    final chat = state.chats[index];
    final isOpen = state.selectedChatId == chat.id;
    final unread = isEdit || message.isMine
        ? chat.unreadCount
        : isOpen
        ? 0
        : chat.unreadCount + 1;

    final updated = chat.copyWith(
      lastMessage: ChatLastMessage(
        id: message.id,
        senderId: message.senderId,
        senderName: message.senderName,
        content: message.content,
        createdAt: message.createdAt,
        isRead: message.isRead,
        isDeleted: message.isDeleted,
      ),
      updatedAt: message.createdAt,
      unreadCount: unread,
    );

    final next = [...state.chats]..removeAt(index);
    state = state.copyWith(chats: [updated, ...next]);
  }

  void clearFailure() {
    if (state.failure != null) {
      state = state.copyWith(clearFailure: true);
    }
  }
}
