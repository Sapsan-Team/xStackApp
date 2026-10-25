import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:xstackapp/core/errors/exceptions.dart';
import 'package:xstackapp/core/logging/talker_service.dart';
import 'package:xstackapp/core/network/session_events.dart';
import 'package:xstackapp/core/storage/token_storage.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final sessionEvents = ref.watch(sessionEventsProvider);
  return DioClient(tokenStorage: tokenStorage, sessionEvents: sessionEvents);
});

class DioClient {
  DioClient({required this.tokenStorage, required this.sessionEvents}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // A bare client for the refresh call: it must not run the 401 interceptor,
    // otherwise a rejected refresh token would recurse into itself.
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers[ApiConstants.authHeader] =
                '${ApiConstants.bearerPrefix}$token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (!_shouldRefresh(error)) {
            return handler.next(error);
          }

          final refreshed = await _refreshTokens();
          if (!refreshed) {
            sessionEvents.notifyExpired();
            return handler.next(error);
          }

          try {
            // The request interceptor re-reads the stored token, so the retry
            // goes out with the freshly issued access token.
            final response = await _dio.fetch<dynamic>(
              error.requestOptions.copyWith(
                extra: {...error.requestOptions.extra, _retriedKey: true},
              ),
            );
            return handler.resolve(response);
          } on DioException catch (retryError) {
            return handler.next(retryError);
          }
        },
      ),
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
        ),
      ),
    ]);
  }

  static const String _retriedKey = 'xstack_retried';

  /// Auth calls that must never trigger a refresh: the credentials are the
  /// subject of the call itself. `/api/auth/me` is deliberately absent, since
  /// an expired access token there is exactly what a refresh is for.
  static const Set<String> _noRefreshPaths = {
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.refresh,
    ApiConstants.logout,
  };

  late final Dio _dio;
  late final Dio _refreshDio;
  final TokenStorage tokenStorage;
  final SessionEvents sessionEvents;

  Future<bool>? _refreshing;

  Dio get dio => _dio;

  /// The interceptor-free client used for the refresh round-trip. Exposed so
  /// tests can stub it without touching a real network.
  @visibleForTesting
  Dio get refreshDio => _refreshDio;

  bool _shouldRefresh(DioException error) {
    if (error.response?.statusCode != 401) return false;
    if (error.requestOptions.extra[_retriedKey] == true) return false;
    return !_noRefreshPaths.contains(error.requestOptions.uri.path);
  }

  /// Single-flight: concurrent 401s share one refresh call, so a burst of
  /// requests cannot rotate the token several times and trip the replay guard.
  Future<bool> _refreshTokens() {
    final pending = _refreshing;
    if (pending != null) return pending;

    final future = _doRefresh();
    _refreshing = future;
    return future.whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      final accessToken = data?['accessToken'];
      final nextRefreshToken = data?['refreshToken'];
      if (accessToken is! String || nextRefreshToken is! String) {
        await tokenStorage.deleteTokens();
        return false;
      }

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );
      return true;
    } catch (error) {
      talker.warning('refresh failed: $error');
      await tokenStorage.deleteTokens();
      return false;
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException('Connection timeout or server is unreachable');
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;
      String message = 'Server error ($statusCode)';

      if (data is Map<String, dynamic>) {
        if (data['detail'] is String) {
          message = data['detail'] as String;
        } else if (data['title'] is String) {
          message = data['title'] as String;
        } else if (data['message'] is String) {
          message = data['message'] as String;
        } else if (data['errors'] is Map) {
          final errorsMap = data['errors'] as Map;
          final errorList = <String>[];
          for (final value in errorsMap.values) {
            if (value is List) {
              errorList.addAll(value.map((e) => e.toString()));
            } else if (value is String) {
              errorList.add(value);
            }
          }
          if (errorList.isNotEmpty) {
            message = errorList.join('\n');
          }
        }
      }

      return ServerException(message: message, statusCode: statusCode);
    }

    return ServerException(message: error.message ?? 'Unknown network error');
  }
}
