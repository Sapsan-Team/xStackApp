import 'package:fpdart/fpdart.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/features/auth/domain/entities/auth_token.dart';
import 'package:xstackapp/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({
    required this.phoneNumber,
    required this.password,
  });

  final String phoneNumber;
  final String password;
}

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthToken>> call(LoginParams params) {
    final phone = params.phoneNumber.trim();
    if (phone.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(ValidationType.emptyPhone)),
      );
    }

    if (params.password.isEmpty) {
      return Future.value(
        const Left(ValidationFailure(ValidationType.emptyPassword)),
      );
    }

    return _repository.login(
      phoneNumber: phone,
      password: params.password,
    );
  }
}
