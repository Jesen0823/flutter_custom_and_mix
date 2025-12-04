import 'package:flutter/material.dart';

/// 商品模型（不可变类，确保 ValueKey 匹配稳定性）
@immutable
class CartProduct {
  /// 业务唯一标识（电商系统中由后端返回，全局唯一）
  final String productId;

  /// 商品名称
  final String name;

  /// 单价
  final double price;

  /// 商品图片（模拟 URL）
  final String imageUrl;

  const CartProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  // 重写 == 和 hashCode（企业开发规范：不可变类必须实现，确保对象比较正确性）
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartProduct &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          name == other.name &&
          price == other.price &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(productId, name, price, imageUrl);

  // 复制对象（不可变类修改属性时使用，避免直接修改原对象）
  CartProduct copyWith({
    String? productId,
    String? name,
    double? price,
    String? imageUrl,
  }) {
    return CartProduct(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
