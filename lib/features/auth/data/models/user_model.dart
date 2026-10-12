import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xstackapp/features/auth/domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String phoneNumber,
    String? username,
    String? displayName,
    String? bio,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toDomain() => User(
        id: id,
        phoneNumber: phoneNumber,
        username: username,
        displayName: displayName,
        bio: bio,
      );
}
