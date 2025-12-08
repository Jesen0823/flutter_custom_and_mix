import 'package:json_annotation/json_annotation.dart';

part 'goods_entity.g.dart';

@JsonSerializable()
class GoodsEntity {
  final String id;
  final String name;
  final double price;

  GoodsEntity({required this.id, required this.name, required this.price});

  // 序列化/反序列化方法（生成后自动生成）
  factory GoodsEntity.fromJson(Map<String, dynamic> json) =>
      _$GoodsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$GoodsEntityToJson(this);
}
