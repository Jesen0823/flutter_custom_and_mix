// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushEvent _$PushEventFromJson(Map<String, dynamic> json) => PushEvent(
  pushId: json['pushId'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  type: (json['type'] as num).toInt(),
);

Map<String, dynamic> _$PushEventToJson(PushEvent instance) => <String, dynamic>{
  'pushId': instance.pushId,
  'title': instance.title,
  'content': instance.content,
  'type': instance.type,
};
