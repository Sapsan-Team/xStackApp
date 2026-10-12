import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/features/auth/domain/entities/user.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    User? user,
    Failure? failure,
  }) = _AuthState;
}
