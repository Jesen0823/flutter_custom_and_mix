// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goods_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoodsEntity _$GoodsEntityFromJson(Map<String, dynamic> json) => GoodsEntity(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$GoodsEntityToJson(GoodsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
    };
