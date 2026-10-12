import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token.freezed.dart';

@freezed
abstract class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String accessToken,
    required String tokenType,
    required DateTime expiresAt,
  }) = _AuthToken;
}
