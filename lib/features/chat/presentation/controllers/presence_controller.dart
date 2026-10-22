import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Presence snapshot of an app member, pushed by the realtime hub.
class PresenceInfo {
  const PresenceInfo({required this.isOnline, this.lastSeenAt});

  final bool isOnline;
  final DateTime? lastSeenAt;
}

/// userId -> presence. Never guessed: only users the hub reported about are
/// present in the map, everything else is treated as unknown.
final presenceControllerProvider =
    NotifierProvider<PresenceController, Map<String, PresenceInfo>>(
      PresenceController.new,
    );

class PresenceController extends Notifier<Map<String, PresenceInfo>> {
  @override
  Map<String, PresenceInfo> build() => const {};

  void setPresence(
    String userId, {
    required bool isOnline,
    DateTime? lastSeenAt,
  }) {
    state = {
      ...state,
      userId: PresenceInfo(isOnline: isOnline, lastSeenAt: lastSeenAt),
    };
  }

  void clear() {
    if (state.isNotEmpty) {
      state = const {};
    }
  }
}
