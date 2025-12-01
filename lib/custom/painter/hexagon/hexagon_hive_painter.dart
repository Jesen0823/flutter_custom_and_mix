import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/painter/hexagon/hexagon.dart';

/// 六边形蜂窝绘制器（Painter仅负责绘制，不管理状态，遵循单一职责）
class HexagonHivePainter extends CustomPainter {
  // 蜂窝列表
  final List<Hexagon> hexagons;

  // 六边形边框的颜色
  final Color borderColor;

  // 六边形边框宽度
  final double borderWidth;

  const HexagonHivePainter({
    required this.hexagons,
    this.borderColor = Colors.black38,
    this.borderWidth = 1.0,
  }) : assert(borderWidth >= 0, "边框宽度不能是负数");

  @override
  void paint(Canvas canvas, Size size) {
    // 初始化画笔
    final Paint fillPaint = Paint()..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = borderWidth;

    // 批量绘制所有六边形
    for (final hexagon in hexagons) {
      // 根据选中状态动态设置填充颜色
      fillPaint.color = hexagon.isSelected
          ? hexagon.selectedColor
          : hexagon.normalColor;
      // 绘制填充
      canvas.drawPath(hexagon.path, fillPaint);
      // 绘制边框
      canvas.drawPath(hexagon.path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HexagonHivePainter oldDelegate) {
    // 数量不同直接重绘
    if (hexagons.length != oldDelegate.hexagons.length) return true;
    // 遍历对比每个六边形的选中状态
    for (int i = 0; i < hexagons.length; i++) {
      if (hexagons[i].isSelected != oldDelegate.hexagons[i].isSelected) {
        if (kDebugMode) {
          print("重绘触发：六边形ID${hexagons[i].id}选中状态变化");
        }
        return true;
      }
    }
    // 样式参数变化重绘
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
