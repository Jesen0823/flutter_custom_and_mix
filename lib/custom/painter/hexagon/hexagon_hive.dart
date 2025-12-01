import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/painter/hexagon/hexagon_hive_painter.dart';
import 'package:flutter_custom_and_mix/custom/painter/hexagon/hexagon.dart';

/// 交互层：蜂窝组件（状态管理+交互）
/// 六边形蜂窝组件（对外暴露可配置参数，隐藏内部实现）
///
/// 六边形蜂窝组件是企业级开发中常见的可视化需求（如蜂窝布局的功能入口、地图热力图、资源调度面板），
/// 其实现难点在于正六边形的几何坐标计算、精准的点击命中测试、绘制性能优化。
///
/// 整体架构设计
// 采用分层封装思想，符合企业级代码规范：
// 数据模型层：定义Hexagon模型，存储单个六边形的坐标、状态、样式；
// 绘制层：HexagonHivePainter继承CustomPainter，负责批量绘制蜂窝；
// 交互层：HexagonHive为StatefulWidget，管理所有蜂窝的状态，处理点击事件；
// 使用层：提供简洁的组件调用示例。
///
/// 代码核心:
// 1. 分层封装：数据模型、绘制、交互分离，遵循单一职责原则，便于维护和扩展；
// 2. 性能优化：
//  2.1 缓存六边形的绘制路径，避免每次paint重新计算；
//  2.2 shouldRepaint精准判断重绘条件，减少无意义绘制；
//  2.3 点击命中后立即退出循环，避免无效遍历；
// 3. 参数校验：通过assert校验关键参数（如边长、行列数），避免运行时崩溃；
// 4. 交互精准：基于六边形的路径做命中测试，而非简单的矩形包围盒，保证点击准确性；
// 5. 配置灵活：对外暴露行数、列数、边长、颜色等参数，满足不同业务场景的定制需求；
// 6. 状态管理：通过StatefulWidget管理蜂窝的选中状态，符合 Flutter 的状态管理规范。
class HexagonHive extends StatefulWidget {
  // 蜂窝的行数
  final int rowCount;

  // 蜂窝列数
  final int columnCount;

  // 六边形边长
  final double sideLength;

  // 蜂窝之间的间距，中心点到中心点的间距
  final double gap;

  // 默认未选中颜色
  final Color normalColor;

  // 选中时的颜色
  final Color selectedColor;

  // 边框颜色
  final Color borderColor;

  // 边框宽度
  final double borderWidth;

  const HexagonHive({
    super.key,
    this.rowCount = 5,
    this.columnCount = 5,
    this.sideLength = 30.0,
    this.gap = 4.0, // 建议设为2-4，避免间隙过大
    this.normalColor = Colors.black54,
    this.selectedColor = Colors.deepPurple,
    this.borderColor = Colors.blue,
    this.borderWidth = 1.0,
  }) : assert(rowCount > 0, "行数必须大于0"),
       assert(columnCount > 0, "列数必须大于0"),
       assert(sideLength > 0, "边长必须大于0"),
       assert(gap > 0, "间距不能为负数");

  @override
  State<HexagonHive> createState() => _HexagonHiveState();
}

class _HexagonHiveState extends State<HexagonHive> {
  // 所有六边形实例
  late List<Hexagon> _hexagons;

  // 画布的实际尺寸,基于蜂窝布局计算
  late Size _canvasSize;

  @override
  void initState() {
    super.initState();
    // 初始化蜂窝的坐标和实例
    _initHexagons();
  }

  @override
  void didUpdateWidget(covariant HexagonHive oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当配置参数变化时，重新初始化蜂窝,处理参数更新的边界情况
    if (oldWidget.rowCount != widget.rowCount ||
        oldWidget.columnCount != widget.columnCount ||
        oldWidget.sideLength != widget.sideLength ||
        oldWidget.gap != widget.gap) {
      _initHexagons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      child: CustomPaint(
        size: _canvasSize,
        painter: HexagonHivePainter(
          hexagons: _hexagons,
          borderColor: widget.borderColor,
          borderWidth: widget.borderWidth,
        ),
      ),
    );
  }

  // 处理点击事件：判断点击位置并切换六边形颜色
  void _handleTapDown(TapDownDetails details) {
    final Offset tapPos = details.localPosition;
    if (kDebugMode) {
      print("点击坐标：$tapPos");
    }

    // 遍历找到被点击的六边形，生成新列表
    setState(() {
      _hexagons = _hexagons.map((hex) {
        if (hex.containsPoint(tapPos)) {
          // 点击命中：返回新的Hexagon实例
          return hex.toggleSelected();
        }
        // 未命中,返回原实例
        return hex;
      }).toList();
    });
  }

  void _initHexagons() {
    final double side = widget.sideLength;
    final double gap = widget.gap;
    final int rows = widget.rowCount;
    final int cols = widget.columnCount;

    // 正六边形核心几何参数
    final double R = side; // 外接圆半径=边长
    final double r = R * math.sqrt(3) / 2; // 内接圆半径 ≈0.866*side（蜂窝垂直间距核心）
    final double colStep = 1.5 * R; // 水平列间距,标准蜂窝值
    final double rowStep = R / 2 + r; // 垂直行间距
    // 叠加统一gap后的最终间距（行列间距比例一致）
    final double finalColStep = colStep + gap;
    final double finalRowStep = rowStep + gap;

    // 水平宽度：列数*列间距 + 边长（补全右侧） + 单侧gap
    final double canvasWidth = cols * finalColStep + R + gap;
    // 垂直高度：行数*行间距 + 内接圆半径（补全底部） + 单侧gap（单侧gap，避免第一行偏移过大）
    final double canvasHeight = rows * finalRowStep + r + gap;
    _canvasSize = Size(canvasWidth, canvasHeight);

    _hexagons = [];
    int hexId = 0;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        // 1. 水平坐标计算（偶数行偏移+基础偏移）
        final double hOffset = (row % 2 == 1)
            ? (colStep / 2)
            : 0.0; // 纯几何偏移，避免水平重叠
        final double centerX =
            col * finalColStep + hOffset + R + gap; // 基础偏移避免贴左

        // 2. 垂直坐标计算（核心：仅用单侧gap作为基础偏移，解决第一行截断）
        final double centerY = row * finalRowStep + r + gap; // 基础偏移仅gap，

        // 创建六边形实例
        final hexagon = Hexagon(
          id: hexId++,
          center: Offset(centerX, centerY),
          sideLength: side,
          normalColor: widget.normalColor,
          selectedColor: widget.selectedColor,
        );
        _hexagons.add(hexagon);
      }
    }
  }
}