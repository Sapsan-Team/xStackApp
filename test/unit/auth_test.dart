import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/features/auth/domain/entities/auth_token.dart';
import 'package:xstackapp/features/auth/domain/entities/user.dart';
import 'package:xstackapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:xstackapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:xstackapp/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository implements AuthRepository {
  Either<Failure, AuthToken>? loginResult;
  Either<Failure, AuthToken>? registerResult;

  @override
  Future<Either<Failure, AuthToken>> login({
    required String phoneNumber,
    required String password,
  }) async {
    return loginResult ??
        Right(
          AuthToken(
            accessToken: 'mock_token',
            refreshToken: 'mock_refresh_token',
            tokenType: 'Bearer',
            expiresAt: DateTime.now().add(const Duration(minutes: 30)),
          ),
        );
  }

  @override
  Future<Either<Failure, AuthToken>> register({
    required String phoneNumber,
    required String password,
    String? username,
    String? displayName,
  }) async {
    return registerResult ??
        Right(
          AuthToken(
            accessToken: 'mock_token',
            refreshToken: 'mock_refresh_token',
            tokenType: 'Bearer',
            expiresAt: DateTime.now().add(const Duration(minutes: 30)),
          ),
        );
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    return const Right(
      User(id: '1', phoneNumber: '+79991234567', username: 'alex'),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<bool> isAuthenticated() async => true;
}

void main() {
  group('LoginUseCase', () {
    late MockAuthRepository mockRepo;
    late LoginUseCase useCase;

    setUp(() {
      mockRepo = MockAuthRepository();
      useCase = LoginUseCase(mockRepo);
    });

    test('validates empty phone number', () async {
      final result = await useCase(
        const LoginParams(phoneNumber: '', password: 'password123'),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).type, ValidationType.emptyPhone);
        },
        (_) => fail('Expected failure'),
      );
    });

    test('validates empty password', () async {
      final result = await useCase(
        const LoginParams(phoneNumber: '+79991234567', password: ''),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).type, ValidationType.emptyPassword);
        },
        (_) => fail('Expected failure'),
      );
    });

    test('returns AuthToken on valid login', () async {
      final result = await useCase(
        const LoginParams(phoneNumber: '+79991234567', password: 'password123'),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success'),
        (token) => expect(token.accessToken, 'mock_token'),
      );
    });
  });

  group('RegisterUseCase', () {
    late MockAuthRepository mockRepo;
    late RegisterUseCase useCase;

    setUp(() {
      mockRepo = MockAuthRepository();
      useCase = RegisterUseCase(mockRepo);
    });

    test('validates password length under 8 characters', () async {
      final result = await useCase(
        const RegisterParams(phoneNumber: '+79991234567', password: 'short'),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).type, ValidationType.shortPassword);
        },
        (_) => fail('Expected failure'),
      );
    });

    test('returns AuthToken on valid register', () async {
      final result = await useCase(
        const RegisterParams(
          phoneNumber: '+79991234567',
          password: 'password123',
          username: 'alex',
        ),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success'),
        (token) => expect(token.accessToken, 'mock_token'),
      );
    });
  });
}
