import 'package:flutter/material.dart';

import '../painter/hexagon/hexagon_hive.dart';

class HexagonHiveExample extends StatelessWidget {
  const HexagonHiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("六边形蜂窝组件（可交互）"),
        backgroundColor: Colors.blue,
      ),
      body: const SingleChildScrollView(
        child: Center(
        child: HexagonHive(
          rowCount: 6,
          columnCount: 6,
          sideLength: 25.0,
          gap: 4.0,
          normalColor: Color(0xFFe1bee7),
          selectedColor: Color(0xFF6a1b9a),
          borderColor: Color(0xFFBBDEFB),
        ),
      ),
      ),
    );
  }
}
