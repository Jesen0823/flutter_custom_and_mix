import 'package:flutter/material.dart';

/// 如果你的主题色不是 Flutter 预定义的那些材质颜色，你可以通过定义 MaterialColor 来创建自己的调色板
///
// 自定义一个 MaterialColor（例如，主色为 0xFF913f91）
const MaterialColor myCustomPurple = MaterialColor(
  0xFF913f91, // 主要颜色的 ARGB 值
  <int, Color>{
    50: Color(0xFFf3e5f5),
    100: Color(0xFFe1bee7),
    200: Color(0xFFce93d8),
    300: Color(0xFFba68c8),
    400: Color(0xFFab47bc),
    500: Color(0xFF9c27b0), // 主要色调
    600: Color(0xFF8e24aa),
    700: Color(0xFF7b1fa2),
    800: Color(0xFF6a1b9a),
    900: Color(0xFF4a148c),
  },
);