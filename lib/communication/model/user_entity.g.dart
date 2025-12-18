// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserParam _$UserParamFromJson(Map<String, dynamic> json) =>
    UserParam(userId: json['userId'] as String, token: json['token'] as String);

Map<String, dynamic> _$UserParamToJson(UserParam instance) => <String, dynamic>{
  'userId': instance.userId,
  'token': instance.token,
};

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  userId: json['userId'] as String,
  username: json['username'] as String,
  age: (json['age'] as num).toInt(),
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'age': instance.age,
};
