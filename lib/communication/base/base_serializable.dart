import 'package:json_annotation/json_annotation.dart';

import '../channel_error.dart';

/// 序列化基类（所有入参/出参实体继承此类）
abstract class BaseSerializable {
  const BaseSerializable();

  // 转JSON,强制非空，避免原生解析NPE
  Map<String, dynamic> toJson() => _$defaultToJson(this);

  // 从JSON构建实例（子类需通过json_serializable生成fromJson）
  static T fromJson<T extends BaseSerializable>(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    try {
      return fromJson(json);
    } catch (e) {
      throw ChannelError(
        code: ChannelErrorCode.serializeError,
        message: '序列化失败：${e.toString()}',
        extra: {'json': json},
      );
    }
  }
}

// 默认序列化实现（处理空值）
Map<String, dynamic> _$defaultToJson(BaseSerializable instance) {
  Map<String, dynamic> json = {};
  json = instance is JsonSerializable
      ? (instance as JsonSerializable).toJson()
      : {};
  ///if (instance is User) {
  //       json['id'] = instance.id;
  //       json['name'] = instance.name;
  //       json['age'] = instance.age;
  //     }
  // 过滤空值，避免原生侧解析异常
  return  Map<String, dynamic>.from(json)..removeWhere((key, value) => value == null);
}