import 'package:fpdart/fpdart.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/features/auth/domain/entities/auth_token.dart';
import 'package:xstackapp/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthToken>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, AuthToken>> register({
    required String phoneNumber,
    required String password,
    String? username,
    String? displayName,
  });

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<bool> isAuthenticated();
}
