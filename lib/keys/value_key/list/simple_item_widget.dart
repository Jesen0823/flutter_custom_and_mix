// 带状态列表项（打印Key详情）
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/keys/value_key/list/simple_product.dart';

class SimpleItemWidget extends StatefulWidget {
  final SimpleProduct product;

  const SimpleItemWidget({super.key,
    required this.product,
  });

  @override
  State<SimpleItemWidget> createState() => _SimpleItemWidgetState();
}

class _SimpleItemWidgetState extends State<SimpleItemWidget> {
  late bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    // 打印Key的类型、value、hashCode（确认Key唯一且不变）
    final key = widget.key as ValueKey<String>;
    debugPrint(
      "【初始化】商品：${widget.product.name}，Key：${key.value}（hash：${key.hashCode}）",
    );
  }

  @override
  void didUpdateWidget(covariant SimpleItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKey = oldWidget.key as ValueKey<String>;
    final newKey = widget.key as ValueKey<String>;
    debugPrint(
      "【更新Widget】旧商品：${oldWidget.product.name}（Key：${oldKey.value}）→ 新商品：${widget.product.name}（Key：${newKey.value}）",
    );
    if (oldWidget.product.id != widget.product.id) {
      _isSelected = false;
      debugPrint("【状态重置】商品替换，选中状态重置为false");
    } else {
      debugPrint("【状态复用】商品不变，选中状态：$_isSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.key as ValueKey<String>;
    debugPrint(
      "【构建】商品：${widget.product.name}，Key：${key.value}，选中状态：$_isSelected",
    );
    return ListTile(
      title: Text(widget.product.name),
      subtitle: Text("¥${widget.product.price} | Key：${key.value}"),
      trailing: Checkbox(
        value: _isSelected,
        onChanged: (value) => setState(() {
          _isSelected = value!;
          debugPrint("【修改状态】${widget.product.name} → 选中：$_isSelected");
        }),
      ),
    );
  }
}