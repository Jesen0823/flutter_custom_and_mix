// 测试页面（用ListView而非builder，排除懒加载干扰）
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/keys/value_key/list/simple_item_widget.dart';

import '../value_key/list/simple_product.dart';

/// 非 builder 列表的 Element 不回收，所以状态能借助key保留，但不适合大量数据。
///
class ValueKeySimpleListPageExample extends StatefulWidget {
  late List<SimpleProduct> initialProducts;

  ValueKeySimpleListPageExample({super.key});

  @override
  State<ValueKeySimpleListPageExample> createState() => _ValueKeySimpleListPageExampleState();
}

class _ValueKeySimpleListPageExampleState extends State<ValueKeySimpleListPageExample> {
  late List<SimpleProduct> _products;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _products = [
      const SimpleProduct(id: "p1", name: "iPhone", price: 9999),
      const SimpleProduct(id: "p2", name: "华为", price: 6999),
      const SimpleProduct(id: "p3", name: "小米", price: 5999),
      const SimpleProduct(id: "p4", name: "三星", price: 7999),
    ];
  }

  void _sort() {
    debugPrint("\n===== 开始排序（${_isAscending ? '升序' : '降序'}）=====");
    setState(() {
      // 排序时创建新列表，但商品实例是const，id不变
      _products = List.from(_products)
        ..sort((a, b) => _isAscending
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price));
      _isAscending = !_isAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("\n===== 页面build，商品列表顺序：${_products.map((p) => p.name).toList()} =====");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Key终极测试（无干扰）"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _sort,
            tooltip: "排序",
          ),
        ],
      ),
      // 用ListView（非builder），一次性创建所有item，排除懒加载干扰
      body: ListView(
        children: _products.map((product) {
          // 每个item的Key是固定的ValueKey(product.id)
          return SimpleItemWidget(
            key: ValueKey(product.id), // 核心：Key绑定固定的id
            product: product,
          );
        }).toList(),
      ),
    );
  }
}