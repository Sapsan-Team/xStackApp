import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/features/auth/domain/usecases/auth_usecases_providers.dart';
import 'package:xstackapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:xstackapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_state.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await ref.read(getCurrentUserUseCaseProvider)();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          failure: null,
        );
      },
    );
  }

  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await ref.read(loginUseCaseProvider)(
      LoginParams(phoneNumber: phoneNumber, password: password),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          failure: failure,
        );
        return false;
      },
      (token) async {
        await checkAuthStatus();
        return true;
      },
    );
  }

  Future<bool> register({
    required String phoneNumber,
    required String password,
    String? username,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await ref.read(registerUseCaseProvider)(
      RegisterParams(
        phoneNumber: phoneNumber,
        password: password,
        username: username,
        displayName: displayName,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          failure: failure,
        );
        return false;
      },
      (token) async {
        await checkAuthStatus();
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await ref.read(logoutUseCaseProvider)();
    state = const AuthState();
  }

  void clearError() {
    if (state.failure != null) {
      state = state.copyWith(failure: null);
    }
  }
}
