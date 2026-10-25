import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xstackapp/features/auth/domain/entities/auth_token.dart';

part 'auth_token_model.freezed.dart';
part 'auth_token_model.g.dart';

@freezed
abstract class AuthTokenModel with _$AuthTokenModel {
  const factory AuthTokenModel({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required DateTime expiresAt,
  }) = _AuthTokenModel;

  const AuthTokenModel._();

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  AuthToken toDomain() => AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        expiresAt: expiresAt,
      );
}
