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
            children: [
              // 左侧斜角示例
              CustomGradientDiagonalCard(
                diagonalHeight: 24,
                gradient: RadialGradient(
                  radius: 3.0,
                  stops:const [0.2,0.4,0.7] ,
                  tileMode: TileMode.decal,
                  colors: [Colors.redAccent, Colors.purple.shade400, Colors.blue.shade600],
                ),
                padding: const EdgeInsets.all(20),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('卡片被点击')),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '左侧斜角卡片',
                      style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '精准命中测试 · 增量更新 · 参数校验',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 右侧斜角示例
              CustomGradientDiagonalCard(
                diagonalHeight: 32,
                diagonalLocation: DiagonalLocation.rightBottom,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.teal.shade400, Colors.green.shade600,Colors.yellow],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('卡片被点击')),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '右侧斜角卡片',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '边界处理 · 语义化支持',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),),
    );
  }
}
