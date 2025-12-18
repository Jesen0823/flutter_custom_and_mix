import 'package:json_annotation/json_annotation.dart';

import '../base/base_serializable.dart';

part 'user_entity.g.dart';

@JsonSerializable()
class UserParam extends BaseSerializable {
  final String userId;
  final String token;

  const UserParam({required this.userId, required this.token});

  factory UserParam.fromJson(Map<String, dynamic> json) => _$UserParamFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$UserParamToJson(this);
}

@JsonSerializable()
class UserInfo extends BaseSerializable {
  final String userId;
  final String username;
  final int age;

  const UserInfo({required this.userId, required this.username, required this.age});

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

// 生成序列化代码（执行flutter pub run build_runner build）