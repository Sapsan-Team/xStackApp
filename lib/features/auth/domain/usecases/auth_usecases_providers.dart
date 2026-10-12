import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:xstackapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:xstackapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:xstackapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:xstackapp/features/auth/domain/usecases/register_usecase.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUseCase(repo);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repo);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repo);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repo);
});
