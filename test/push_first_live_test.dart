import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/http_connection_options.dart';

/// Live push-first test against the backend. Requires the API to run at
/// http://127.0.0.1:5121 and writes a little data (two users, one group).
///
/// Skipped by default so `flutter test` stays hermetic; run it explicitly with
/// `flutter test --dart-define=LIVE_API=true test/push_first_live_test.dart`.
const bool _liveApi = bool.fromEnvironment('LIVE_API');

void main() {
  const base = 'http://127.0.0.1:5121';
  const password = 'password123';
  const phoneA = '+79990009001';
  const phoneB = '+79990009002';

  Future<String> accessToken(String phone) async {
    final login = await http.post(
      Uri.parse('$base/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phone, 'password': password}),
    );
    if (login.statusCode == 200) {
      return (jsonDecode(login.body) as Map<String, dynamic>)['accessToken']
          as String;
    }

    final register = await http.post(
      Uri.parse('$base/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phone, 'password': password}),
    );
    expect(
      register.statusCode,
      201,
      reason: 'register failed: ${register.body}',
    );
    return (jsonDecode(register.body) as Map<String, dynamic>)['accessToken']
        as String;
  }

  Future<String> userId(String token) async {
    final response = await http.get(
      Uri.parse('$base/api/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    expect(response.statusCode, 200, reason: 'me failed: ${response.body}');
    return (jsonDecode(response.body) as Map<String, dynamic>)['id'] as String;
  }

  Future<String> createDirect(String token, String recipientId) async {
    final response = await http.post(
      Uri.parse('$base/api/chats/direct'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'recipientUserId': recipientId}),
    );
    expect(
      response.statusCode,
      anyOf(200, 201),
      reason: 'direct chat failed: ${response.body}',
    );
    return (jsonDecode(response.body) as Map<String, dynamic>)['id'] as String;
  }

  Future<String> createGroup(
    String token,
    String title,
    String memberId,
  ) async {
    final response = await http.post(
      Uri.parse('$base/api/chats/group'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'memberUserIds': [memberId],
      }),
    );
    expect(
      response.statusCode,
      anyOf(200, 201),
      reason: 'group chat failed: ${response.body}',
    );
    return (jsonDecode(response.body) as Map<String, dynamic>)['id'] as String;
  }

  Future<void> sendMessage(String token, String chatId, String content) async {
    final response = await http.post(
      Uri.parse('$base/api/chats/$chatId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );
    expect(
      response.statusCode,
      201,
      reason: 'send failed: ${response.body}',
    );
  }

  test('messages reach a connected client without JoinChat', () async {
    final tokenA = await accessToken(phoneA);
    final tokenB = await accessToken(phoneB);
    final idB = await userId(tokenB);

    // 1. A chat that already exists when B connects: OnConnectedAsync has to
    //    subscribe the new connection to it.
    final directChatId = await createDirect(tokenA, idB);

    final received = <String, Completer<Map<String, dynamic>>>{};
    final connection = HubConnectionBuilder()
        .withUrl(
          '$base/hubs/chat',
          options: HttpConnectionOptions(accessTokenFactory: () async => tokenB),
        )
        .build();

    connection.on('ReceiveMessage', (args) {
      if (args is! List || args.isEmpty || args.first is! Map) return;
      final payload = (args.first as Map).cast<String, dynamic>();
      final chatId = payload['chatId'];
      if (chatId is! String) return;
      final completer = received[chatId];
      if (completer != null && !completer.isCompleted) {
        completer.complete(payload);
      }
    });

    try {
      await connection.start();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final directMessage = Completer<Map<String, dynamic>>();
      received[directChatId] = directMessage;
      await sendMessage(tokenA, directChatId, 'push-first direct');

      final direct = await directMessage.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw StateError(
          'B did not receive a message for an existing chat without JoinChat',
        ),
      );
      expect(direct['chatId'], directChatId);

      // 2. A group created while B is already connected: the live connection
      //    has to be subscribed to the brand-new room.
      final groupChatId = await createGroup(
        tokenA,
        'push-first ${DateTime.now().microsecondsSinceEpoch}',
        idB,
      );

      final groupMessage = Completer<Map<String, dynamic>>();
      received[groupChatId] = groupMessage;
      await sendMessage(tokenA, groupChatId, 'push-first group');

      final group = await groupMessage.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw StateError(
          'B did not receive a message for a chat created after connecting',
        ),
      );
      expect(group['chatId'], groupChatId);
    } finally {
      try {
        await connection.stop();
      } catch (_) {}
    }
  }, timeout: const Timeout(Duration(seconds: 90)), skip: !_liveApi);
}
