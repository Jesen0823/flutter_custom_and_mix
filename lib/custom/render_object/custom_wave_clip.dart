import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 三、自定义异形裁剪组件（SingleChildRenderObject）
///
// 裁剪路径：通过Path绘制波浪形路径，使用canvas.clipPath实现画布裁剪；
// 代理绘制：继承RenderProxyBox（单子组件的 RenderObject），复用父类的子组件管理逻辑；
// 命中测试：仅响应裁剪区域内的点击，解决默认裁剪组件的点击区域问题；
// 性能优化：波浪路径的生成仅在绘制时执行，避免重复计算。
//
// 需求场景：
// 短视频 APP 的视频封面、社交 APP 的头像，需要实现波浪形的裁剪效果（默认的ClipRRect、ClipOval仅支持矩形 / 圆形裁剪）。
// 解决问题：
// 突破默认裁剪组件的样式限制，实现自定义异形裁剪。

// 1. 定义Widget：对外暴露裁剪参数
class CustomWaveClip extends SingleChildRenderObjectWidget {
  final double waveHeight; // 波浪高度
  final int waveCount; // 波浪数量

  const CustomWaveClip({
    super.key,
    required super.child,
    this.waveHeight = 20.0,
    this.waveCount = 3,
  }) : assert(waveHeight > 0),
       assert(waveCount > 0);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomWaveClip(waveHeight: waveHeight, waveCount: waveCount);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomWaveClip renderObject,
  ) {
    if (renderObject.waveHeight != waveHeight) {
      renderObject.waveHeight = waveHeight;
    }
    if (renderObject.waveCount != waveCount) {
      renderObject.waveCount = waveCount;
    }
  }
}

// 2. 定义RenderObject：处理裁剪与绘制
class RenderCustomWaveClip extends RenderProxyBox {
  double _waveHeight;
  int _waveCount;

  RenderCustomWaveClip({
    required double waveHeight,
    required int waveCount,
    RenderBox? child,
  }) : _waveHeight = waveHeight,
       _waveCount = waveCount,
       super(child);

  double get waveHeight => _waveHeight;

  set waveHeight(double value) {
    assert(value > 0);
    if (_waveHeight == value) return;
    _waveHeight = value;
    markNeedsPaint();
  }

  int get waveCount => _waveCount;

  set waveCount(int value) {
    assert(value > 0);
    if (_waveCount == value) return;
    _waveCount = value;
    markNeedsPaint();
  }

  // 3. 绘制逻辑：通过裁剪路径实现波浪效果
  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    // 创建裁剪路径
    final Path clipPath = _createWavePath();
    context.canvas.save();
    context.canvas.clipPath(clipPath.shift(offset)); // 裁剪画布
    super.paint(context, offset); // 绘制子组件
    context.canvas.restore(); // 恢复画布
  }

  // 生成波浪路径
  Path _createWavePath() {
    final double width = size.width;
    final double height = size.height;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height - waveHeight);

    // 计算波浪
    final double waveWidth = width / waveCount;
    for (int i = waveCount; i >= 0; i--) {
      final double x = i * waveWidth;
      final double nextX = (i - 1) * waveWidth;
      if (i % 2 == 0) {
        // 波谷贝塞尔曲线
        path.quadraticBezierTo(
          (x + nextX) / 2,
          height - waveHeight * 2,
          nextX,
          height - waveHeight,
        );
      } else {
        // 波峰
        path.quadraticBezierTo(
          (x + nextX) / 2,
          height,
          nextX,
          height - waveHeight,
        );
      }
    }
    // 左侧直线
    path.lineTo(0, height - waveHeight);
    path.close();
    return path;
  }

  // 4. 命中测试：仅响应裁剪区域内的点击
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final Path clipPath = _createWavePath();
    if (clipPath.contains(position)) {
      return super.hitTest(result, position: position);
    }
    return false;
  }
}
