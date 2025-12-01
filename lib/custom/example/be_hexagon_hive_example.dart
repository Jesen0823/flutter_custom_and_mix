import 'package:flutter/material.dart';

import '../painter/better_hexagon/be_hexagon_hive.dart';

class BeHexagonHiveExample extends StatelessWidget {
  const BeHexagonHiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("蜂窝组件（滑动点击精准版）"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        // 测试：设置大数量触发分块绘制（如rowCount=20, columnCount=10 → 200个）
        child: BeHexagonHive(
          rowCount: 20,
          columnCount: 10,
          sideLength: 25.0,
          gap: 4.0,
          normalColor: Color(0xFFE3F2FD),
          selectedColor: Color(0xFF2196F3),
          borderColor: Colors.deepOrange,
        ),
      ),
    );
  }
}
