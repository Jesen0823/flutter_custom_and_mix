import 'package:flutter/material.dart';

/// 全局样式常量
class AppStyles {
  // 颜色主题
  static const Color primaryColor = Color(0xFF00C853); // 主绿色（绑定按钮/加载动画）
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Color(0xFF333333);
  static const Color grayColor = Color(0xFF999999);
  static const Color bgColor = Color(0xFFF5F5F5);

  // 圆角半径
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 30.0;
  static const double radiusTop = 20.0; // 弹窗顶部圆角

  // 字体大小
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;

  // 内边距/外边距
  static const double paddingSmall = 10.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double marginBottom = 30.0; // 底部按钮外边距

  // 倒计时样式
  static const TextStyle countDownStyle = TextStyle(
    color: whiteColor,
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w500,
    shadows: [Shadow(color: blackColor, blurRadius: 2.0)],
  );

  // 按钮样式
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    minimumSize: Size(double.infinity, 50.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLarge),
    ),
    elevation: 0,
  );
}