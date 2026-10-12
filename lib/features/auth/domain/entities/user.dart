import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String phoneNumber,
    String? username,
    String? displayName,
    String? bio,
  }) = _User;
}
