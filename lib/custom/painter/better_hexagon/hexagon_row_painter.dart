import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/painter/better_hexagon/be_hexagon.dart';

/// 单行六边形绘制器（用于分块绘制）
class HexagonRowPainter extends CustomPainter {
  final List<BeHexagon> rowHexagons;
  final Color borderColor;
  final double borderWidth;

  // 优化：使用const构造，避免不必要的重建
  const HexagonRowPainter({
    super.repaint,
    required this.rowHexagons,
    required this.borderColor,
    required this.borderWidth,
  }):assert(borderWidth >=0,"边框宽度不能是负数");

  @override
  void paint(Canvas canvas, Size size) {
    // 初始化画笔
    final Paint fillPaint = Paint()..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = borderWidth;

    // 批量绘制所有六边形
    for (final hexagon in rowHexagons) {
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

  /// 精准重绘判断：仅当行内六边形状态/样式变化时重绘
  @override
  bool shouldRepaint(covariant HexagonRowPainter oldDelegate) {
    if (rowHexagons.length != oldDelegate.rowHexagons.length) return true;
    for (int i = 0; i < rowHexagons.length; i++) {
      if (rowHexagons[i].isSelected != oldDelegate.rowHexagons[i].isSelected) {
        return true;
      }
    }
    return oldDelegate.borderColor != borderColor || oldDelegate.borderWidth != borderWidth;
  }

  @override
  bool shouldRebuildSemantics(covariant HexagonRowPainter oldDelegate) => false;
}
