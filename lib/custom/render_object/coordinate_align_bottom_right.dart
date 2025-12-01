import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 1. 自定义高层Widget：单孩子右下角对齐组件（基于SingleChildRenderObjectWidget）
class CoordinateAlignBottomRight extends SingleChildRenderObjectWidget {
  const CoordinateAlignBottomRight({
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderAlignBottomRight();

  @override
  void updateRenderObject(BuildContext context, RenderAlignBottomRight renderObject) {}
}

// 2. 核心RenderObject：仅混入核心的RenderObjectWithChildMixin + 手动管理子组件生命周期
class RenderAlignBottomRight extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> { // 仅保留Flutter公开的核心Mixin

  /// 初始化子组件的父数据（使用可实例化的BoxParentData）
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  /// 布局核心逻辑：计算尺寸和子组件偏移
  @override
  void performLayout() {
    // 强制约束：父容器传递的固定尺寸
    final BoxConstraints constraints = this.constraints;
    // 确保自身尺寸严格等于父容器的约束尺寸
    size = constraints.isTight ? constraints.smallest : constraints.biggest;
    print("自身尺寸：${size.width} x ${size.height}"); // 调试打印

    if (child != null) {
      // 子组件约束：最大为父的80%，最小为0
      final BoxConstraints childConstraints = BoxConstraints(
        maxWidth: size.width * 0.8,
        maxHeight: size.height * 0.8,
        minWidth: 0,
        minHeight: 0,
      );
      // 执行子组件布局
      child!.layout(childConstraints, parentUsesSize: true);
      print("子组件尺寸：${child!.size.width} x ${child!.size.height}"); // 调试打印

      // 获取子组件的父数据，计算右下角偏移
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      final double childX = size.width - child!.size.width;
      final double childY = size.height - child!.size.height;
      childParentData.offset = Offset(childX, childY);
      print("子组件偏移：X=$childX, Y=$childY"); // 调试打印
    }
  }

  /// 绘制核心逻辑：手动应用子组件的偏移
  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      // 关键：叠加父组件偏移 + 子组件自身偏移
      final Offset childOffset = offset + childParentData.offset;
      // 绘制子组件，应用最终偏移
      context.paintChild(child!, childOffset);
    }

    /// 可选，绘制辅助线debug排查
    // 在paint方法中绘制父组件的坐标系原点和右下角（辅助调试）
    final Paint linePaint = Paint()..color = Colors.red..strokeWidth = 2;
    // 绘制X轴（从原点到右下角）
    context.canvas.drawLine(offset, Offset(offset.dx + size.width, offset.dy), linePaint);
    // 绘制Y轴（从原点到右下角）
    context.canvas.drawLine(offset, Offset(offset.dx, offset.dy + size.height), linePaint);
    // 绘制父组件的右下角点
    context.canvas.drawCircle(offset + Offset(size.width, size.height), 5, linePaint);
  }

  /// 命中测试：使用BoxHitTestResult，修复类型错误
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // 1. 判断点击位置是否在当前组件范围内
    if (!size.contains(position)) return false;

    // 2. 优先检测子组件的点击
    bool isHit = false;
    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      final Offset childPosition = position - childParentData.offset;
      // 子组件的命中测试需传入BoxHitTestResult
      isHit = child!.hitTest(result, position: childPosition);
      if(isHit) print("子组件被点击");
    }

    // 3. 若子组件未命中，标记当前组件为命中目标（可选）
    if (!isHit) {
      print("子组件未命中，即将对父组件命中测试");
      result.add(BoxHitTestEntry(this, position));
    }

    return true;
  }

  /// 手动实现子组件生命周期管理（移除无效Mixin后必须补充）
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (child != null) child!.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (child != null) child!.detach();
  }

  @override
  void redepthChildren() {
    if (child != null) redepthChild(child!);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (child != null) visitor(child!);
  }

  // 干布局：优化性能
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.smallest;
}
