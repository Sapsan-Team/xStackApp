class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'Network error']);

  final String message;

  @override
  String toString() => message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error']);

  final String message;

  @override
  String toString() => message;
}
