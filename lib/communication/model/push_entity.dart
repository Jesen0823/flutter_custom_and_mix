// lib/model/push_entity.dart
import 'package:json_annotation/json_annotation.dart';

import '../channel/base/base_serializable.dart';

part 'push_entity.g.dart';

@JsonSerializable()
class PushEvent extends BaseSerializable {
  final String pushId;
  final String title;
  final String content;
  final int type; // 1=系统通知，2=业务消息

  const PushEvent({
    required this.pushId,
    required this.title,
    required this.content,
    required this.type,
  });

  factory PushEvent.fromJson(Map<String, dynamic> json) =>
      _$PushEventFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PushEventToJson(this);
}