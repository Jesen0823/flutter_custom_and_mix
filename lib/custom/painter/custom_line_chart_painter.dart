import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 自定义Painter-折线图（金融 APP 常用）
///
/// CustomPainter封装了Canvas绘制的核心逻辑，与CustomPaintWidget 配合使用，负责纯绘制逻辑，
/// 布局和事件由外层 Widget 处理。
//
// 适用场景
// 数据可视化：如折线图、饼图、进度条；
// 自定义形状：如波浪线、星形、异形图标；
// 动态绘制：如手写签名、涂鸦画板。
/// 核心优势
// 专注绘制：无需处理布局和事件，仅需实现paint和shouldRepaint；
// 性能优异：通过shouldRepaint控制重绘时机，避免无意义绘制；
// 上手简单：比RenderObject更易掌握，是自定义绘制的首选。

class CustomLineChartPainter extends CustomPainter {
  // 数据列表
  final List<double> data;

  // 折线颜色
  final Color lineColor;

  // 点的颜色
  final Color pointColor;

  // 填充颜色
  final Color fillColor;

  const CustomLineChartPainter({
    super.repaint,
    required this.data,
    this.lineColor = Colors.blue,
    this.pointColor = Colors.red,
    this.fillColor = const Color.fromARGB(40, 20, 20, 200),
  });

  @override
  void paint(Canvas canvas, ui.Size size) {
    if (data.isEmpty || data.length <= 1) return;
    // 计算坐标比例（适配画布尺寸）
    final double maxValue = data.reduce((a, b) => a > b ? a : b);
    final double xStep = size.width / (data.length - 1);
    final double yRatio = size.height / maxValue;

    // 画笔
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final Paint pointPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // 构建折线路径
    final Path linePath = Path();
    final Path fillPath = Path();

    // 起始点
    linePath.moveTo(0, size.height - data[0] * yRatio);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - data[0] * yRatio);

    // 绘制数据点
    for (int i = 0; i < data.length; i++) {
      final double x = i * xStep;
      final double y = size.height - data[i] * yRatio;
      if (i > 0) {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      // 绘制数据点
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
    // 填充折线下方区域
    fillPath.lineTo((data.length - 1) * xStep, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // 绘制折线
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomLineChartPainter oldDelegate) {
    // 仅当数据变化时重绘，优化性能
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointColor != pointColor;
  }
}
