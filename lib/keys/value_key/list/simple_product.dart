import 'package:flutter/material.dart';

@immutable
class SimpleProduct {
  final String id;
  final String name;
  final double price;

  // const构造函数：确保相同参数创建同一实例
  const SimpleProduct({
    required this.id,
    required this.name,
    required this.price,
  });
}
