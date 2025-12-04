import 'package:flutter/material.dart';

import 'cart_product.dart';

/// 购物车列表项（带「选中」状态，常见带状态列表项）
class CartItemWidget extends StatefulWidget {
  final CartProduct product;

  // 回调：选中状态变化时通知父组件（跨组件状态同步标准方式）
  final ValueChanged<bool> onSelectChanged;

  // 初始选中状态（由父组件传递，确保状态统一）
  final bool isSelected;

  // 核心：用 productId（业务唯一ID）作为 ValueKey
  const CartItemWidget({super.key,
    required this.product,
    required this.onSelectChanged,
    required this.isSelected,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  // 父组件传递的 product 变化时（如排序后重新渲染），同步初始状态
  @override
  void didUpdateWidget(covariant CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.productId != widget.product.productId) {
      _isSelected = widget.isSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey[200]!, blurRadius: 2)],
      ),
      child: Row(
        children: [
          // 选中复选框
          Checkbox(
            value: _isSelected,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _isSelected = value);
              widget.onSelectChanged(value); // 通知父组件状态变化
            },
          ),
          const SizedBox(width: 12),
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              widget.product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 60),
            ),
          ),
          const SizedBox(width: 12),
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "¥${widget.product.price.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
