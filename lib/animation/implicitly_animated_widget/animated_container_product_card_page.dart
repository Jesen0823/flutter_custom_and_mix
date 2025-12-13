import 'package:flutter/material.dart';

/// 电商商品卡片 AnimatedContainer
///
/// 电商 App 商品列表中，卡片点击 / 选中时的视觉反馈（边框、背景色、阴影、圆角动画过渡），
/// 提升交互体验，是电商类 App 高频交互场景。
///
/// AnimatedContainer 自动监听 decoration/padding/width 等属性变化，无需手动管理 AnimationController；
// 交互逻辑贴合电商场景：选中状态的视觉反馈符合用户认知。
class AnimatedContainerProductCardPage extends StatefulWidget {
  const AnimatedContainerProductCardPage({super.key});

  @override
  State<AnimatedContainerProductCardPage> createState() =>
      _AnimatedContainerProductCardPageState();
}

class _AnimatedContainerProductCardPageState
    extends State<AnimatedContainerProductCardPage> {
  // 选中的商品ID
  String? _selectedProductId;
  static const int AppAnimationDuration = 300;

  // 商品数据
  final List<Map<String, dynamic>> _products = [
    {
      "id": "1001",
      "name": "2025新款无线耳机",
      "price": "¥299",
      "imageUrl": "https://free.picui.cn/free/2025/12/12/693bb4b4377a1.jpg",
    },
    {
      "id": "1002",
      "name": "快充充电宝20000mAh",
      "price": "¥159",
      "imageUrl": "https://free.picui.cn/free/2025/12/12/693bb550a9242.jpg",
    },
    {
      "id": "1003",
      "name": "高清钢化膜（3片装）",
      "price": "¥19.9",
      "imageUrl": "https://free.picui.cn/free/2025/12/12/693bb4b439976.jpg",
    },
  ];

  // 切换选中状态
  void _toggleSelected(String productId) {
    setState(() {
      _selectedProductId = _selectedProductId == productId ? null : productId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("商品列表（AnimatedContainer）")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            final isSelected = _selectedProductId == product['id'];
            return _buildProductCard(product, isSelected);
          },
        ),
      ),
    );
  }

  // 构建商品卡片
  _buildProductCard(Map<String, dynamic> product, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSelected(product['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppAnimationDuration),
        curve: Curves.easeInOut,
        // 动画过渡
        decoration: BoxDecoration(
          color: Colors.white,
          // 边框
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          // 阴影
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(isSelected ? 12 : 8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 商品图片
            Center(
              child: Image.network(
                product["imageUrl"],
                width: 120,
                height:120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            // 商品名称
            Text(
              product['name'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            // 商品价格
            Text(
              product["price"],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
