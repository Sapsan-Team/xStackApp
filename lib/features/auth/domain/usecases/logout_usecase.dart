import 'package:fpdart/fpdart.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call() {
    return _repository.logout();
  }
}
