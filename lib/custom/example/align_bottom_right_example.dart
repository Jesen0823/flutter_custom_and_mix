import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/render_object/coordinate_align_bottom_right.dart';

class AlignBottomRightExample extends StatelessWidget {
  const AlignBottomRightExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("子组件右下角对齐（最终修正版）"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Container(
          width: 300, // 父容器固定宽度
          height: 300, // 父容器固定高度
          color: Colors.grey[200], // 父容器背景色
          // 关键：使用ConstrainedBox强制传递紧约束
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(Size(300, 300)),
            child: CoordinateAlignBottomRight(
              child: Container(
                width: 100, // 子组件固定宽度
                height: 100, // 子组件固定高度
                color: Colors.tealAccent, // 子组件背景色
                child: const Center(
                  child: Text(
                    "子组件",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
