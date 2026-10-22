import 'package:xstackapp/core/errors/exceptions.dart';
import 'package:xstackapp/core/errors/failures.dart';

/// Converts transport-level exceptions into the failure types the UI knows how
/// to localize.
Failure failureFrom(Object error) {
  if (error is ServerException) {
    if (error.statusCode == 401) {
      return AuthFailure.sessionExpired(error.message);
    }
    if (error.statusCode == 409) {
      return ServerFailure(
        statusCode: error.statusCode,
        message: error.message,
      );
    }
    return ServerFailure(statusCode: error.statusCode, message: error.message);
  }
  if (error is NetworkException) {
    return NetworkFailure(error.message);
  }
  if (error is CacheException) {
    return CacheFailure(error.message);
  }
  return ServerFailure(message: error.toString());
}
