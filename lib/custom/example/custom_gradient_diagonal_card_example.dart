import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/render_object/custom_gradient_diagonal_card.dart';

class CustomGradientDiagonalCardExample extends StatelessWidget {
  const CustomGradientDiagonalCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义RenderObject实现渐变斜角卡片'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 示例1：左到右渐变斜角卡片（商品活动卡）
            CustomGradientDiagonalCard(
              gradientColors: [Colors.deepPurple, Colors.pinkAccent,Colors.orangeAccent],
              diagonalHeight: 25,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "618年中大促",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "全场商品满300减50，限时抢购！",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                    ),
                    child: const Text("立即抢购"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // 示例2：右到左渐变斜角卡片（用户标签卡）
            CustomGradientDiagonalCard(
              gradientColors: [Colors.teal, Colors.cyanAccent],
              diagonalHeight: 15,
              gradientDirection: GradientDirection.rightToLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      "https://picsum.photos/200/200",
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Flutter开发者",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "自定义RenderObject实战",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
