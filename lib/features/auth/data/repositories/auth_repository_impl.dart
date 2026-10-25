import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/errors/exceptions.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/core/storage/preferences_storage.dart';
import 'package:xstackapp/core/storage/token_storage.dart';
import 'package:xstackapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:xstackapp/features/auth/domain/entities/auth_token.dart';
import 'package:xstackapp/features/auth/domain/entities/user.dart';
import 'package:xstackapp/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final preferencesStorage = ref.watch(preferencesStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    tokenStorage: tokenStorage,
    preferencesStorage: preferencesStorage,
  );
});

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.preferencesStorage,
  });

  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final PreferencesStorage preferencesStorage;

  @override
  Future<Either<Failure, AuthToken>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final tokenModel = await remoteDataSource.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      await tokenStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );
      await preferencesStorage.saveLastPhone(phoneNumber);

      return Right(tokenModel.toDomain());
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        return const Left(AuthFailure.invalidCredentials());
      }
      return Left(ServerFailure(statusCode: e.statusCode, message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> register({
    required String phoneNumber,
    required String password,
    String? username,
    String? displayName,
  }) async {
    try {
      final tokenModel = await remoteDataSource.register(
        phoneNumber: phoneNumber,
        password: password,
        username: username,
        displayName: displayName,
      );

      await tokenStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );
      await preferencesStorage.saveLastPhone(phoneNumber);

      return Right(tokenModel.toDomain());
    } on ServerException catch (e) {
      if (e.statusCode == 409) {
        return const Left(ServerFailure(statusCode: 409));
      }
      return Left(ServerFailure(statusCode: e.statusCode, message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final hasToken = await tokenStorage.hasToken();
    if (!hasToken) {
      return const Left(AuthFailure.invalidCredentials());
    }

    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel.toDomain());
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        await tokenStorage.deleteTokens();
        return const Left(AuthFailure.sessionExpired());
      }
      return Left(ServerFailure(statusCode: e.statusCode, message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Best-effort server-side revocation: a network failure must not keep
      // the user logged in locally.
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await remoteDataSource.logout(refreshToken);
        } catch (_) {}
      }
      await tokenStorage.deleteTokens();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return tokenStorage.hasToken();
  }
}
