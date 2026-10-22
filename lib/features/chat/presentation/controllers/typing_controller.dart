import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

/// One person typing in one chat. Value-based equality: repeated typing
/// events for the same user must not stack in the indicator.
class TypingUser {
  const TypingUser({required this.userId, required this.name});

  final String userId;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is TypingUser && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;
}

/// Who is typing in which chat up to right now. Entries expire on their own
/// so a dropped connection never leaves a stale indicator on screen.
final typingControllerProvider =
    NotifierProvider<TypingController, Map<String, List<TypingUser>>>(
      TypingController.new,
    );

class TypingController extends Notifier<Map<String, List<TypingUser>>> {
  static const _expiry = Duration(seconds: 4);

  final _timers = <String, Timer>{};

  @override
  Map<String, List<TypingUser>> build() {
    ref.onDispose(_cancelTimers);
    return const {};
  }

  void markTyping(String chatId, String userId, String name) {
    final users = <TypingUser>{
      for (final user in state[chatId] ?? const <TypingUser>[]) user,
      TypingUser(userId: userId, name: name),
    };

    state = {...state, chatId: users.toList(growable: false)};

    // One timer per chat resets the whole batch; extra events push it out.
    _timers[chatId]?.cancel();
    _timers[chatId] = Timer(_expiry, () => _expire(chatId));
  }

  void clearChat(String chatId) {
    _timers[chatId]?.cancel();
    if (state.containsKey(chatId)) {
      final next = {...state}..remove(chatId);
      state = next;
    }
  }

  /// Removes one user from the indicator; used when their message lands so
  /// the label does not linger for the expiry window after a send.
  void clearUser(String chatId, String userId) {
    final users = state[chatId];
    if (users == null || users.every((user) => user.userId != userId)) return;
    final remaining = users
        .where((user) => user.userId != userId)
        .toList(growable: false);
    state = {...state, chatId: remaining};
  }

  void _expire(String chatId) {
    if (state.containsKey(chatId)) {
      final next = {...state}..remove(chatId);
      state = next;
    }
  }

  void _cancelTimers() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
