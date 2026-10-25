import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Broadcasts session-level events that live outside the provider graph, so
/// the network layer can tell the auth layer that the session is gone without
/// depending on it (which would be circular).
final sessionEventsProvider = Provider<SessionEvents>((ref) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});

class SessionEvents {
  final _expired = StreamController<void>.broadcast();

  /// Fires when the refresh token was rejected and the user must log in again.
  Stream<void> get expired => _expired.stream;

  void notifyExpired() {
    if (!_expired.isClosed) {
      _expired.add(null);
    }
  }

  Future<void> dispose() => _expired.close();
}
