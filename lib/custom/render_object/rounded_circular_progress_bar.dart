import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

/// 一、自定义Render实现-自定义圆角环形进度条（LeafRenderObject）
///
/// 参数校验：通过assert保证输入参数的合法性，避免运行时错误；
// 增量更新：updateRenderObject仅更新变化的属性，减少重绘开销；
// 布局计算：performLayout根据半径和线条宽度计算组件尺寸，遵循父组件的约束；
// 绘制优化：使用StrokeCap.round实现圆角线条，突破默认进度条的样式限制；
// 命中测试：自定义圆形点击区域，解决默认 Widget 矩形点击的问题。

/// 需求场景：
/// 电商 APP 的商品详情页、金融 APP 的加载进度展示，需要带圆角的环形进度条（默认的CircularProgressIndicator无圆角）。
/// 解决问题：
/// 突破默认进度条的样式限制，实现自定义圆角环形效果。

// 1. 定义Widget：对外暴露配置参数
class RoundedCircularProgressBar extends LeafRenderObjectWidget {
  final double progress; // 进度 0~1
  final double strokeWidth; // 线条宽度
  final Color progressColor; // 进度条颜色
  final Color backgroundColor; // 背景色
  final double radius; // 圆环半径

  const RoundedCircularProgressBar({
    required this.progress,
    this.strokeWidth = 4.0,
    this.progressColor = Colors.blue,
    this.backgroundColor = Colors.black12,
    this.radius = 2.0,
    super.key,
  }) : assert(progress >= 0 && progress <= 1, "Progress must between 0 and 1."),
       assert(strokeWidth > 0, "StrokeWidth min value is 0."),
       assert(radius > 0, "Radius min value is 0.");

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRoundedCircularProgressBar(
      progress: progress,
      strokeWidth: strokeWidth,
      progressColor: progressColor,
      backgroundColor: backgroundColor,
      radius: radius,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderRoundedCircularProgressBar renderObject,
  ) {
    // 增量更新属性，避免全量重绘
    if (renderObject.progress != progress) renderObject.progress = progress;
    if (renderObject.strokeWidth != strokeWidth) {
      renderObject.strokeWidth = strokeWidth;
    }
    if (renderObject.progressColor != progressColor) {
      renderObject.progressColor = progressColor;
    }
    if (renderObject.backgroundColor != backgroundColor) {
      renderObject.backgroundColor = backgroundColor;
    }
    if (renderObject.radius != radius) renderObject.radius = radius;
  }
}

// 2. 定义RenderObject：处理布局与绘制
class RenderRoundedCircularProgressBar extends RenderBox {
  double _progress;
  double _strokeWidth;
  Color _progressColor;
  Color _backgroundColor;
  double _radius;

  RenderRoundedCircularProgressBar({
    required double progress,
    required double strokeWidth,
    required Color progressColor,
    required Color backgroundColor,
    required double radius,
  }) : _progress = progress,
       _strokeWidth = strokeWidth,
       _progressColor = progressColor,
       _backgroundColor = backgroundColor,
       _radius = radius;

  /// 对外暴露的属性，设置时标为脏区
  double get progress => _progress;

  set progress(double value) {
    assert(value >= 0 && value <= 1);
    if (_progress == value) return;
    _progress = value;
    markNeedsPaint(); // 仅标记绘制脏区，无需重新布局
  }

  Color get progressColor => _progressColor;

  set progressColor(Color value) {
    if (_progressColor == value) return;
    _progressColor = value;
    markNeedsPaint();
  }

  Color get backgroundColor => _backgroundColor;

  set backgroundColor(Color value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  double get strokeWidth => _strokeWidth;

  set strokeWidth(double value) {
    assert(value > 0);
    if (_strokeWidth == value) return;
    _strokeWidth = value;
    markNeedsLayout(); // 尺寸变化，标记重绘
  }

  double get radius => _radius;

  set radius(double value) {
    assert(value > 0);
    if (_radius == value) return;
    _radius = value;
    markNeedsLayout();
  }

  // 3. 布局计算：确定组件的尺寸
  @override
  void performLayout() {
    // 约束处理：取父组件的约束与自身半径的最小值
    final double diameter = 2 * radius + strokeWidth;
    final double width = constraints.constrainWidth(diameter);
    final double height = constraints.constrainHeight(diameter);
    size = Size(width, height); // 设置组件尺寸
  }

  // 4. 绘制逻辑：绘制背景圆环与进度圆环（带圆角）
  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final Canvas canvas = context.canvas;
    final double centerX = offset.dx + size.width / 2;
    final double centerY = offset.dy + size.height / 2;
    final double effectiveRadius = radius - strokeWidth / 2;

    // 绘制背景圆环
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // 圆角线条
    canvas.drawCircle(
      Offset(centerX, centerY),
      effectiveRadius,
      backgroundPaint,
    );

    // 绘制进度圆环
    final Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final double sweepAngle = 2 * math.pi * progress; // 扫过角度
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: effectiveRadius,
      ),
      -0.5 * 3.1415926, // 起始角度（顶部）
      sweepAngle,
      false, // 不填充
      progressPaint,
    );
  }

  // 5. 命中测试：自定义圆形点击区域
  @override
  bool hitTest(HitTestResult result, {required Offset position}) {
    // 计算点击位置是否在圆环内
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double distance = (position - Offset(centerX, centerY)).distance;
    final bool isInCircle = distance <= radius + strokeWidth / 2;
    if (isInCircle) {
      result.add(HitTestEntry(this));
      return true;
    }
    return false;
  }

  // 6. 设置组件的最小尺寸（可选）
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final double diameter = 2 * radius + strokeWidth;
    return Size(
      constraints.constrainWidth(diameter),
      constraints.constrainHeight(diameter),
    );
  }
}
