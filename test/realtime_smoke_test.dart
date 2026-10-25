import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/http_connection_options.dart';

/// Live smoke test against the backend SignalR hub. Requires the API to run
/// at http://127.0.0.1:5121. It exercises only hub round-trips (typing and
/// presence) so it never writes anything into the database.
///
/// Skipped by default so `flutter test` stays hermetic; run it explicitly with
/// `flutter test --dart-define=LIVE_API=true test/realtime_smoke_test.dart`.
const bool _liveApi = bool.fromEnvironment('LIVE_API');

void main() {
  const base = 'http://127.0.0.1:5121';

  Future<String> loginToken() async {
    final response = await http.post(
      Uri.parse('$base/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'phoneNumber': '+79991234567',
        'password': 'password123',
      }),
    );
    expect(response.statusCode, 200, reason: 'login failed: ${response.body}');
    return (jsonDecode(response.body) as Map<String, dynamic>)['accessToken']
        as String;
  }

  Future<String> firstChatId(String token) async {
    final response = await http.get(
      Uri.parse('$base/api/chats'),
      headers: {'Authorization': 'Bearer $token'},
    );
    expect(response.statusCode, 200, reason: 'chats failed: ${response.body}');
    final chats = jsonDecode(response.body) as List<dynamic>;
    expect(chats, isNotEmpty, reason: 'no chats for the smoke user');
    return (chats.first as Map<String, dynamic>)['id'] as String;
  }

  HubConnection buildConnection(String token) {
    return HubConnectionBuilder()
        .withUrl(
          '$base/hubs/chat',
          options: HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .build();
  }

  test('hub delivers typing and presence events to joined rooms', () async {
    final token = await loginToken();
    final chatId = await firstChatId(token);

    final listener = buildConnection(token);
    final sender = buildConnection(token);

    final typingCompleter = Completer<Map<String, Object?>>();
    final presenceCompleter = Completer<Map<String, Object?>>();

    listener
      ..on('UserTyping', (args) {
        if (!typingCompleter.isCompleted && args is List && args.length >= 3) {
          typingCompleter.complete(<String, Object?>{
            'chatId': args[0],
            'userId': args[1],
            'name': args[2],
          });
        }
      })
      ..on('UserPresenceChanged', (args) {
        if (!presenceCompleter.isCompleted &&
            args is List &&
            args.length >= 2) {
          presenceCompleter.complete(<String, Object?>{
            'userId': args[0],
            'isOnline': args[1],
          });
        }
      });

    try {
      await listener.start();
      await listener.invoke('JoinChat', args: [chatId]);

      await Future<void>.delayed(const Duration(milliseconds: 300));
      await sender.start();
      await sender.invoke('JoinChat', args: [chatId]);
      await sender.invoke('SendTyping', args: [chatId]);

      final typing = await typingCompleter.future.timeout(
        const Duration(seconds: 10),
      );
      expect(typing['chatId'], chatId);
      // The backend resolves the nickname from the database: it must not be
      // the generic "User" fallback.
      expect(typing['name'], isNot('User'));
      expect(typing['name'], isNotEmpty);

      final presence = await presenceCompleter.future.timeout(
        const Duration(seconds: 10),
      );
      expect(presence['userId'], isNotNull);
      expect(presence['isOnline'], isTrue);
    } finally {
      try {
        await sender.stop();
      } catch (_) {}
      try {
        await listener.stop();
      } catch (_) {}
    }
  }, timeout: const Timeout(Duration(seconds: 60)), skip: !_liveApi);
}
