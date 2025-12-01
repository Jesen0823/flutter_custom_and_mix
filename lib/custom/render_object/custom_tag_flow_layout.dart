import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 二、自定义RenderObject实现自动换行流式布局（MultiChildRenderObject）
///
/// 父数据管理：通过TagLayoutParentData存储子组件的位置信息，实现子组件的布局控制；
// 流式布局逻辑：遍历子组件，判断是否需要换行，根据对齐方式计算子组件的位置；
// 约束传递：为子组件传递固定行高的约束，保证标签的高度一致性；
// 复用 Mixin：使用ContainerRenderObjectMixin和RenderBoxContainerDefaultsMixin简化多子组件的管理，减少代码冗余。
//
// 需求场景：
// 社交 APP 的话题标签、电商 APP 的筛选标签，需要实现自定义行高、间距、换行规则的流式布局（默认的Wrap无法满足定制化的行高和间距需求）。
// 解决问题：
// 突破Wrap的布局限制，实现定制化的流式标签布局。

// 1. 定义子组件的布局数据，存储子组件的位置和尺寸
class TagLayoutParentData extends ContainerBoxParentData<RenderBox> {}

// 2. 定义Widget：对外暴露布局参数
class CustomTagFlowLayout extends MultiChildRenderObjectWidget {
  final double horizontalSpacing; // 标签子项水平间距
  final double verticalSpacing; // 标签子项垂直间距
  final double lineHeight; // 行高
  final MainAxisAlignment mainAxisAlignment;

  const CustomTagFlowLayout({
    super.key,
    required super.children,
    this.horizontalSpacing = 8.0,
    this.verticalSpacing = 8.0,
    this.lineHeight = 32.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : assert(
         horizontalSpacing >= 0,
         "Parameter 'horizontalSpacing >= 0' is must.",
       ),
       assert(verticalSpacing >= 0),
       assert(lineHeight >= 0); // 行内对齐方式

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomTagFlowLayout(
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
      lineHeight: lineHeight,
      mainAxisAlignment: mainAxisAlignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomTagFlowLayout renderObject,
  ) {
    if (renderObject.horizontalSpacing != horizontalSpacing) {
      renderObject.horizontalSpacing = horizontalSpacing;
    }
    if (renderObject.verticalSpacing != verticalSpacing) {
      renderObject.verticalSpacing = verticalSpacing;
    }
    if (renderObject.lineHeight != lineHeight) {
      renderObject.lineHeight = lineHeight;
    }
    if (renderObject.mainAxisAlignment != mainAxisAlignment) {
      renderObject.mainAxisAlignment = mainAxisAlignment;
    }
  }
}

class RenderCustomTagFlowLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TagLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TagLayoutParentData> {
  double _horizontalSpacing; // 标签子项水平间距
  double _verticalSpacing; // 标签子项垂直间距
  double _lineHeight; // 行高
  MainAxisAlignment _mainAxisAlignment;

  RenderCustomTagFlowLayout({
    required double horizontalSpacing,
    required double verticalSpacing,
    required double lineHeight,
    required MainAxisAlignment mainAxisAlignment,
  }) : _horizontalSpacing = horizontalSpacing,
       _verticalSpacing = verticalSpacing,
       _lineHeight = lineHeight,
       _mainAxisAlignment = mainAxisAlignment;

  // 对外暴露的属性
  double get horizontalSpacing => _horizontalSpacing;

  set horizontalSpacing(double value) {
    assert(value >= 0);
    if (_horizontalSpacing == value) return;
    _horizontalSpacing = value;
    markNeedsLayout();
  }

  double get verticalSpacing => _verticalSpacing;

  set verticalSpacing(double value) {
    assert(value >= 0);
    if (_verticalSpacing == value) return;
    _verticalSpacing = value;
    markNeedsLayout();
  }

  double get lineHeight => _lineHeight;

  set lineHeight(double value) {
    assert(lineHeight >= 0);
    if (_lineHeight == value) return;
    _lineHeight = value;
    markNeedsLayout();
  }

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;

  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment == value) return;
    _mainAxisAlignment = value;
    markNeedsLayout();
  }

  // 初始化子组件的ParentData
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! TagLayoutParentData) {
      child.parentData = TagLayoutParentData();
    }
  }

  // 4. 核心布局逻辑：流式标签布局
  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final double maxWidth = constraints.maxWidth;
    if (maxWidth == 0) {
      size = Size.zero;
      return;
    }

    // 子组件迭代器
    final RenderBox? firstChild = this.firstChild;
    if (firstChild == null) {
      size = Size(maxWidth, 0);
      return;
    }

    double currentX = 0.0; // 当前行的X坐标
    double currentY = 0.0; // 当前行的Y坐标
    double totalHeight = 0.0; // 总高度
    List<RenderBox> currentLineChildren = []; // 当前行的子组件
    List<double> currentLineWidths = []; // 当前行子组件宽度

    // 遍历所有子组件，计算布局
    RenderBox? child = firstChild;
    while (child != null) {
      // 布局子组件，传递约束，高度固定，宽度自适应
      child.layout(
        BoxConstraints(
          minWidth: 0,
          maxWidth: maxWidth,
          minHeight: lineHeight,
          maxHeight: lineHeight,
        ),
        parentUsesSize: true,
      );

      final double childWidth = child.size.width;
      final double childHeight = child.size.height;
      // 判断是否要换行
      if (currentX + childWidth > maxWidth && currentX > 0) {
        // 为当前行布局
        _layoutCurrentLine(
          currentLineChildren: currentLineChildren,
          currentLineWidths: currentLineWidths,
          currentY: currentY,
          maxWidth: maxWidth,
        );

        // 重置行参数
        currentY += lineHeight + verticalSpacing;
        currentX = 0.0;
        currentLineChildren.clear();
        currentLineWidths.clear();
      }

      // 添加到当前行
      currentLineChildren.add(child);
      currentLineWidths.add(childWidth);
      currentX += childWidth + horizontalSpacing;

      // 下一个子组件
      child = childAfter(child);
    }
    // 处理最后一行
    if (currentLineChildren.isNotEmpty) {
      _layoutCurrentLine(
        currentLineChildren: currentLineChildren,
        currentLineWidths: currentLineWidths,
        currentY: currentY,
        maxWidth: maxWidth,
      );
      totalHeight = currentY + lineHeight;
    }
    // 设置组件总尺寸
    size = Size(maxWidth, constraints.constrainHeight(totalHeight));
  }

  void _layoutCurrentLine({
    required List<RenderBox> currentLineChildren,
    required List<double> currentLineWidths,
    required double currentY,
    required double maxWidth,
  }) {
    final double totalChildWidth = currentLineWidths.fold(0, (a, b) => a + b);
    final double totalSpacing =
        (currentLineChildren.length - 1) * horizontalSpacing;
    final double lineTotalWidth = totalSpacing + totalChildWidth;
    double offsetX = 0.0;

    // 根据对齐方式计算X起始坐标
    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        offsetX = 0.0;
        break;
      case MainAxisAlignment.center:
        offsetX = (maxWidth - lineTotalWidth) / 2;
        break;
      case MainAxisAlignment.end:
        offsetX = maxWidth - lineTotalWidth;
        break;
      default:
        offsetX = 0.0;
    }

    // 设置子组件位置
    for (int i = 0; i < currentLineChildren.length; i++) {
      final RenderBox child = currentLineChildren[i];
      final TagLayoutParentData parentData =
          child.parentData as TagLayoutParentData;
      parentData.offset = Offset(offsetX, currentY);
      offsetX += currentLineWidths[i] + horizontalSpacing;
    }
  }

  // 5. 绘制子组件（复用ContainerRenderObjectMixin的绘制逻辑）
  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  // 6. 命中测试（复用ContainerRenderObjectMixin的逻辑）
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  ///计算由 getDryLayout 方法返回的值。请勿直接调用此函数，而应调用 getDryLayout 方法。
  // 在实现 performLayout 或 performResize 方法的子类中，或者在将 sizedByParent 设置为 true
  // 但未重写 performResize 方法的情况下，应重写此方法。此方法应返回此 RenderBox 在接收到提供的 BoxConstraints 时希望被赋予的大小。
  // 此方法返回的大小必须与 RenderBox 在 performLayout（或者如果 sizedByParent 为 true 时在 performResize 中）中为自身计算的大小相匹配。
  // 如果此算法依赖于子元素的大小，则应使用其 getDryLayout 方法获取该子元素的大小。
  // 这种布局被称为“干”布局，而不是由 performLayout 执行的常规“湿”布局，因为它在不改变任何内部状态的情况下为给定约束计算所需的大小。
  // 当无法确定大小时
  // 存在一些情况，使得渲染对象无法以高效的方式计算其大小。例如，大小可能由一个回调决定，而该渲染对象无法对此进行推理。
  // 在这种情况下，可能无法（或者至少不太实际）实际返回一个有效的答案。在这种情况下，该函数应在一个
  // 断言中调用 debugCannotComputeDryLayout 方法，并返回一个占位值 const Size(0, 0)。
  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return Size(constraints.maxWidth, 0);
  }
}
