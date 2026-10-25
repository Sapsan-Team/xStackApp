import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:xstackapp/core/network/dio_client.dart';
import 'package:xstackapp/core/network/session_events.dart';
import 'package:xstackapp/core/storage/token_storage.dart';

/// Live check of the refresh-token lifecycle against the backend. Requires the
/// API at http://127.0.0.1:5121 and writes rows into refresh_tokens.
///
/// Skipped by default; run with
/// `flutter test --dart-define=LIVE_API=true test/auth_refresh_live_test.dart`.
const bool _liveApi = bool.fromEnvironment('LIVE_API');

void main() {
  const base = 'http://127.0.0.1:5121';
  const headers = {'Content-Type': 'application/json'};

  Future<Map<String, dynamic>> login() async {
    final response = await http.post(
      Uri.parse('$base/api/auth/login'),
      headers: headers,
      body: jsonEncode({
        'phoneNumber': '+79991234567',
        'password': 'password123',
      }),
    );
    expect(response.statusCode, 200, reason: 'login failed: ${response.body}');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<http.Response> refresh(String refreshToken) => http.post(
        Uri.parse('$base/api/auth/refresh'),
        headers: headers,
        body: jsonEncode({'refreshToken': refreshToken}),
      );

  test('refresh rotates the token and a replay kills the session', () async {
    final session = await login();
    final firstRefresh = session['refreshToken'] as String;

    final rotated = await refresh(firstRefresh);
    expect(rotated.statusCode, 200, reason: rotated.body);
    final rotatedBody = jsonDecode(rotated.body) as Map<String, dynamic>;
    final secondRefresh = rotatedBody['refreshToken'] as String;
    expect(secondRefresh, isNot(firstRefresh));

    final me = await http.get(
      Uri.parse('$base/api/auth/me'),
      headers: {'Authorization': 'Bearer ${rotatedBody['accessToken']}'},
    );
    expect(me.statusCode, 200);

    // Presenting the rotated-away token must fail and invalidate the family.
    expect((await refresh(firstRefresh)).statusCode, 401);
    expect((await refresh(secondRefresh)).statusCode, 401);
  }, timeout: const Timeout(Duration(seconds: 60)), skip: !_liveApi);

  test('logout revokes the refresh token', () async {
    final session = await login();
    final refreshToken = session['refreshToken'] as String;

    final logout = await http.post(
      Uri.parse('$base/api/auth/logout'),
      headers: headers,
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    expect(logout.statusCode, 204);

    expect((await refresh(refreshToken)).statusCode, 401);
  }, timeout: const Timeout(Duration(seconds: 60)), skip: !_liveApi);

  test('the dio client refreshes an invalid access token and retries', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final storage = TokenStorage(const FlutterSecureStorage());
    final events = SessionEvents();
    final client = DioClient(tokenStorage: storage, sessionEvents: events);

    final session = await login();
    await storage.saveTokens(
      accessToken: 'not-a-valid-jwt',
      refreshToken: session['refreshToken'] as String,
    );

    final response = await client.get<Map<String, dynamic>>(ApiConstants.me);

    expect(response.statusCode, 200);
    expect(response.data?['phoneNumber'], '+79991234567');
    expect(await storage.getToken(), isNot('not-a-valid-jwt'));
    expect(await storage.getRefreshToken(), isNot(session['refreshToken']));

    await events.dispose();
  }, timeout: const Timeout(Duration(seconds: 60)), skip: !_liveApi);
}
