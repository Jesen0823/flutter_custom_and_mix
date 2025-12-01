import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 通过RenderObject-自定义渐变斜角卡片组件
//
// 单孩子 RenderObject（SingleChildRenderObjectWidget），实现核心能力：
// 自定义斜角角度与高度；
// 渐变背景填充；
// 斜角区域的精准命中测试；
// 增量属性更新（避免无意义重绘）；
// 严格的参数校验与边界处理。
//
/// 使用场景：
/// 渐变斜角卡片是电商 / 社交 APP 的高频 UI 需求（如活动卡片、商品标签卡），默认 Flutter Widget
/// 难以实现精准的斜角渐变效果，通过自定义RenderObject可高效实现该效果，且性能优于
/// ClipPath+DecoratedBox的组合方案（减少渲染节点嵌套）
///
class CustomGradientDiagonalCard extends SingleChildRenderObjectWidget {
  // 渐变颜色组
  final List<Color> gradientColors;

  // 斜角高度，决定斜角的陡峭程度
  final double diagonalHeight;

  // 渐变方向，默认左上角到右下角
  final GradientDirection gradientDirection;

  // 卡片内边距
  final EdgeInsetsGeometry padding;

  CustomGradientDiagonalCard({
    super.key,
    super.child,
    required this.gradientColors,
    this.diagonalHeight = 20.0,
    this.gradientDirection = GradientDirection.leftTpRight,
    this.padding = const EdgeInsets.all(16.0),
  }) : assert(
         gradientColors.length >= 2,
         "Gradient color requires at least two colors.",
       ),
       assert(
         diagonalHeight >= 0,
         "The diagonalHeight cannot be a negative number.",
       ),
       assert(
         padding.isNonNegative,
         "The Padding cannot be a negative number.",
       );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomGradientDiagonalCard(
      gradientColors: gradientColors,
      diagonalHeight: diagonalHeight,
      gradientDirection: gradientDirection,
      padding: padding.resolve(Directionality.of(context)),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomGradientDiagonalCard renderObject,
  ) {
    // 增量更新：仅当属性变化时才标记重绘/重布局，优化性能
    if (renderObject.gradientColors != gradientColors) {
      renderObject.gradientColors = gradientColors;
      renderObject.markNeedsPaint();
    }
    if (renderObject.diagonalHeight != diagonalHeight) {
      renderObject.diagonalHeight = diagonalHeight;
      renderObject.markNeedsLayout(); // 尺寸变化，需重新布局
    }
    if (renderObject.gradientDirection != gradientDirection) {
      renderObject.gradientDirection = gradientDirection;
      renderObject.markNeedsPaint();
    }
    final resolvedPadding = padding.resolve(Directionality.of(context));
    if (renderObject.padding != resolvedPadding) {
      renderObject.padding = resolvedPadding;
      renderObject.markNeedsLayout();
    }
  }
}

/// 2. 渐变方向枚举
enum GradientDirection {
  leftTpRight, // 左上到右下
  rightToLeft, // 右上到左下
}

/// 3. 父数据类：存储子组件的布局偏移（单孩子RenderObject必备）
class DiagonalCardParentData extends ContainerBoxParentData<RenderBox> {}

/// 4. 核心RenderObject实现：处理布局、绘制、命中测试
class RenderCustomGradientDiagonalCard extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DiagonalCardParentData>,
        RenderObjectWithChildMixin<RenderBox>,
        RenderBoxContainerDefaultsMixin<RenderBox, DiagonalCardParentData> {
  List<Color> _gradientColors;
  double _diagonalHeight;
  GradientDirection _gradientDirection;
  EdgeInsets _padding;

  RenderCustomGradientDiagonalCard({
    required List<Color> gradientColors,
    required double diagonalHeight,
    required GradientDirection gradientDirection,
    required EdgeInsets padding,
  }) : _gradientColors = gradientColors,
       _diagonalHeight = diagonalHeight,
       _gradientDirection = gradientDirection,
       _padding = padding;

  // 对外暴露的属性getter/setter（带参数校验）
  List<Color> get gradientColors => _gradientColors;

  set gradientColors(List<Color> value) {
    assert(value.length >= 2);
    _gradientColors = value;
  }

  double get diagonalHeight => _diagonalHeight;

  set diagonalHeight(double value) {
    assert(value >= 0);
    _diagonalHeight = value;
  }

  GradientDirection get gradientDirection => _gradientDirection;

  set gradientDirection(GradientDirection value) {
    _gradientDirection = value;
  }

  EdgeInsets get padding => _padding;

  set padding(EdgeInsets value) {
    assert(value.isNonNegative);
    _padding = value;
  }

  /// 初始化子组件的父数据（必须实现）
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DiagonalCardParentData) {
      child.parentData = DiagonalCardParentData();
    }
  }

  /// 核心布局逻辑：计算自身尺寸 + 子组件布局
  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    // 处理约束边界，最小尺寸为0，最大尺寸继承父约束
    final BoxConstraints childConstraints = constraints.deflate(padding);

    RenderBox? child = firstChild;
    // 布局子组件
    if (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      // 设置子组件的偏移，基于内边距
      final DiagonalCardParentData childParentData =
          child.parentData as DiagonalCardParentData;
      childParentData.offset = Offset(padding.left, padding.top);
    }

    // 计算自身最终尺寸
    final double selfWidth = constraints.constrainWidth(
      child?.size.width ?? 0 + padding.horizontal,
    );
    final double selfHeight = constraints.constrainHeight(
      child?.size.height ?? 0 + padding.vertical,
    );
    size = Size(selfWidth, selfHeight);
  }

  /// 核心绘制逻辑：绘制渐变斜角背景 + 子组件
  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) return;

    final Canvas canvas = context.canvas;
    canvas.save(); // 保存画布状态，避免影响后续绘制

    // 1. 创建斜角路径，根据方向生成斜角
    final Path diagonalPath = _createDiagonalPath();

    // 2. 创建渐变画笔
    final Gradient gradient = LinearGradient(
      colors: gradientColors,
      begin: gradientDirection == GradientDirection.leftTpRight
          ? Alignment.topLeft
          : Alignment.topRight,
      end: gradientDirection == GradientDirection.leftTpRight
          ? Alignment.bottomRight
          : Alignment.bottomLeft,
    );
    final Paint paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTRB(offset.dx, offset.dy, size.width, size.height),
      )
      ..isAntiAlias = true;

    // 3. 绘制渐变斜角背景
    canvas.drawPath(diagonalPath.shift(offset), paint);

    // 4. 绘制子组件（复用ContainerRenderObjectMixin的默认绘制）
    RenderBox? child = firstChild;
    if (child != null) {
      final DiagonalCardParentData cardParentData =
          child.parentData as DiagonalCardParentData;
      context.paintChild(child, offset + cardParentData.offset);
    }
    canvas.restore(); // 恢复画布状态
  }

  /// 生成斜角路径：根据方向和高度计算路径节点
  Path _createDiagonalPath() {
    final Path path = Path();
    final double width = size.width;
    final double height = size.height;
    final double diagonalH = diagonalHeight.clamp(
      0,
      height / 2,
    ); // 限制斜角高度，避免过度陡峭

    if (gradientDirection == GradientDirection.leftTpRight) {
      // 左上到右下斜角：起点 -> 右上-> 右下-> -> 左下 -> 左上
      path
        ..moveTo(0, diagonalH)
        ..lineTo(width, 0)
        ..lineTo(width, height)
        ..lineTo(0, height - diagonalH);
      path.close();
    } else {
      // 右上到左下斜角：起点→左上→左下→右下→右上
      path
        ..moveTo(width, diagonalH)
        ..lineTo(0, 0)
        ..lineTo(0, height)
        ..lineTo(width, height - diagonalH);
      path.close();
    }
    return path;
  }

  /// 命中测试：仅响应斜角区域内的点击
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    // 判断点击位置是否在斜角路径内
    final Path diagonalPath = _createDiagonalPath();
    if (!diagonalPath.contains(position)) return false;

    // 若子组件可点击，优先响应子组件命中测试
    RenderBox? child = firstChild;
    if (child != null) {
      final DiagonalCardParentData childParentData =
          child.parentData as DiagonalCardParentData;
      final bool childHit = hitTestChildren(
        result,
        position: position - childParentData.offset,
      );
      if (childHit) return true;
    }
    // 响应自身的点击事件
    result.add(HitTestEntry(this));
    return true;
  }

  /// 优化滚动性能：标记组件是否需要合成层
  @override
  bool get alwaysNeedsCompositing =>
      firstChild != null || super.alwaysNeedsCompositing;

  /// 干布局计算：预计算尺寸（可选，优化布局性能）
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final BoxConstraints childConstraints = constraints.deflate(padding);
    final Size childSize =
        firstChild?.computeDryLayout(childConstraints) ?? Size.zero;
    return constraints.constrain(
      Size(
        childSize.width + padding.horizontal,
        childSize.height + padding.vertical,
      ),
    );
  }
}
