import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:xstackapp/core/errors/exceptions.dart';
import 'package:xstackapp/core/network/dio_client.dart';
import 'package:xstackapp/core/network/session_events.dart';
import 'package:xstackapp/core/storage/token_storage.dart';

/// Stubs HTTP at the adapter level, so the real interceptors (and therefore
/// the refresh-and-retry path) run exactly as they do in the app.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Map<String, Object?> _tokenPair(String access, String refresh) => {
      'accessToken': access,
      'refreshToken': refresh,
      'tokenType': 'Bearer',
      'expiresAt': DateTime.utc(2026, 1, 1).toIso8601String(),
    };

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  late TokenStorage storage;
  late SessionEvents events;
  late DioClient client;

  setUp(() async {
    storage = TokenStorage(const FlutterSecureStorage());
    await storage.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
    );
    events = SessionEvents();
    client = DioClient(tokenStorage: storage, sessionEvents: events);
  });

  tearDown(() => events.dispose());

  test('concurrent 401s share one refresh and are retried', () async {
    var refreshCalls = 0;
    final seenAuth = <String?>[];

    ResponseBody handler(RequestOptions options) {
      if (options.path == ApiConstants.refresh) {
        refreshCalls++;
        return _json(_tokenPair('new-access', 'new-refresh'), 200);
      }

      final auth = options.headers[ApiConstants.authHeader] as String?;
      seenAuth.add(auth);
      if (auth == 'Bearer new-access') {
        return _json({'ok': true}, 200);
      }
      return _json({'title': 'Unauthorized'}, 401);
    }

    client.dio.httpClientAdapter = _StubAdapter((o) async => handler(o));
    client.refreshDio.httpClientAdapter = _StubAdapter((o) async {
      // Both requests must wait for the same in-flight refresh.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return handler(o);
    });

    final responses = await Future.wait([
      client.get<Map<String, dynamic>>(ApiConstants.chats),
      client.get<Map<String, dynamic>>(ApiConstants.chats),
    ]);

    expect(responses.map((r) => r.statusCode), [200, 200]);
    expect(refreshCalls, 1, reason: 'refresh must be single-flight');
    expect(seenAuth.where((a) => a == 'Bearer old-access'), hasLength(2));
    expect(seenAuth.where((a) => a == 'Bearer new-access'), hasLength(2));
    expect(await storage.getToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');
  });

  test('a rejected refresh clears the session and reports expiry', () async {
    final expired = <void>[];
    final subscription = events.expired.listen(expired.add);

    client.dio.httpClientAdapter = _StubAdapter(
      (o) async => _json({'title': 'Unauthorized'}, 401),
    );
    client.refreshDio.httpClientAdapter = _StubAdapter(
      (o) async => _json({'title': 'Invalid refresh token'}, 401),
    );

    await expectLater(
      client.get<Map<String, dynamic>>(ApiConstants.chats),
      throwsA(isA<ServerException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(expired, hasLength(1));
    expect(await storage.getToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);

    await subscription.cancel();
  });

  test('a 401 from the login endpoint is not refreshed', () async {
    var refreshCalls = 0;
    final expired = <void>[];
    final subscription = events.expired.listen(expired.add);

    client.dio.httpClientAdapter = _StubAdapter(
      (o) async => _json({'title': 'Invalid credentials'}, 401),
    );
    client.refreshDio.httpClientAdapter = _StubAdapter((o) async {
      refreshCalls++;
      return _json(_tokenPair('new-access', 'new-refresh'), 200);
    });

    await expectLater(
      client.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'phoneNumber': '+70000000000', 'password': 'wrong-password'},
      ),
      throwsA(isA<ServerException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(refreshCalls, 0);
    expect(expired, isEmpty);
    expect(await storage.getToken(), 'old-access');

    await subscription.cancel();
  });

  test('a 401 on /me is refreshed before giving up', () async {
    client.dio.httpClientAdapter = _StubAdapter((options) async {
      final auth = options.headers[ApiConstants.authHeader] as String?;
      return auth == 'Bearer new-access'
          ? _json({'id': '1', 'phoneNumber': '+70000000000'}, 200)
          : _json({'title': 'Unauthorized'}, 401);
    });
    client.refreshDio.httpClientAdapter = _StubAdapter(
      (o) async => _json(_tokenPair('new-access', 'new-refresh'), 200),
    );

    final response = await client.get<Map<String, dynamic>>(ApiConstants.me);
    expect(response.statusCode, 200);
    expect(await storage.getToken(), 'new-access');
  });
}
