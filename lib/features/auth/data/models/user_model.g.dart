// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  phoneNumber: json['phoneNumber'] as String,
  username: json['username'] as String?,
  displayName: json['displayName'] as String?,
  bio: json['bio'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phoneNumber': instance.phoneNumber,
      'username': instance.username,
      'displayName': instance.displayName,
      'bio': instance.bio,
    };
