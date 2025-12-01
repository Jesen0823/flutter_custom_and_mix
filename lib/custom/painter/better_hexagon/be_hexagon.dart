import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 数据模型层：单个六边形的模型
/// 六边形数据模型（企业级开发：封装独立模型)

class BeHexagon {
  // 六边形唯一标识（用于重绘判断的性能优化）
  final int id;

  // 六边形中心坐标
  final Offset center;

  // 六边形边长
  final double sideLength;

  // 默认颜色与选中颜色
  final Color normalColor;
  final Color selectedColor;

  // 是否选中
  final bool isSelected;

  // 优化：一次性生成Path并缓存，不可变对象仅计算一次
  late final Path _path;

  BeHexagon({
    required this.id,
    required this.center,
    required this.sideLength,
    required this.normalColor,
    required this.selectedColor,
    this.isSelected = false,
  }) : assert(sideLength > 0, "六边形边长必须大于0"){
    _path = _createHexagonPath();
  }

  // 获取六边形的绘制路径
  Path get path =>_path;

  /// 一次性生成六边形路径（仅执行一次）
  Path _createHexagonPath() {
    final Path path = Path();
    final double radius = sideLength; // 正六边形外接圆半径 = 边长
    for (int i = 0; i < 6; i++) {
      // 起始角度-π/6（30°），确保六边形上下边水平，符合蜂窝视觉习惯
      final double angle = math.pi / 3 * i - math.pi / 6;
      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  /// 命中测试：添加坐标打印（调试用）判断点是否在六边形内（点击命中测试的核心）
  bool containsPoint(Offset point) {
    final bool isContain = path.contains(point);
    if (kDebugMode) {
      if (isContain) print("命中六边形ID：$id，坐标：$point");
    }
    return isContain;
  }

  /// 生成新的实例来切换选中状态
  BeHexagon toggleSelected() {
    if (kDebugMode) {
      print("六边形ID：$id，选中状态：$isSelected"); // 调试日志
    }
    return BeHexagon(
      id: id,
      center: center,
      sideLength: sideLength,
      normalColor: normalColor,
      selectedColor: selectedColor,
      isSelected: !isSelected, // 取反状态，创建新实例
    );
  }

  // 批量更新状态
  BeHexagon updateSelected(bool isSelected){
    return BeHexagon(
      id: id,
      center: center,
      sideLength: sideLength,
      normalColor: normalColor,
      selectedColor: selectedColor,
      isSelected: isSelected,
    );
  }
}
