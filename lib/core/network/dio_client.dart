import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:xstackapp/core/errors/exceptions.dart';
import 'package:xstackapp/core/logging/talker_service.dart';
import 'package:xstackapp/core/storage/token_storage.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return DioClient(tokenStorage: tokenStorage);
});

class DioClient {
  DioClient({required this.tokenStorage}) {
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
        onError: (DioException error, handler) {
          return handler.next(error);
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

  late final Dio _dio;
  final TokenStorage tokenStorage;

  Dio get dio => _dio;

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
