import 'package:fpdart/fpdart.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/features/auth/domain/entities/auth_token.dart';
import 'package:xstackapp/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    required this.phoneNumber,
    required this.password,
    this.username,
    this.displayName,
  });

  final String phoneNumber;
  final String password;
  final String? username;
  final String? displayName;
}

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthToken>> call(RegisterParams params) {
    final phone = params.phoneNumber.trim();
    if (phone.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(ValidationType.emptyPhone)),
      );
    }

    if (params.password.length < 8) {
      return Future.value(
        const Left(ValidationFailure(ValidationType.shortPassword)),
      );
    }

    final trimmedUsername = params.username?.trim();
    final cleanUsername = (trimmedUsername != null && trimmedUsername.isNotEmpty)
        ? trimmedUsername
        : null;

    final trimmedDisplayName = params.displayName?.trim();
    final cleanDisplayName = (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty)
        ? trimmedDisplayName
        : null;

    return _repository.register(
      phoneNumber: phone,
      password: params.password,
      username: cleanUsername,
      displayName: cleanDisplayName,
    );
  }
}
