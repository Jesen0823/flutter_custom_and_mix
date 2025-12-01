import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/example/custom_tag_flow_layout_example.dart';
import 'package:flutter_custom_and_mix/custom/example/custom_wave_clip_example.dart';
import 'package:flutter_custom_and_mix/custom/example/native_platform_view_example.dart';
import 'package:flutter_custom_and_mix/custom/example/user_inherited_widget_example.dart';

import 'custom/example/align_bottom_right_example.dart';
import 'custom/example/be_hexagon_hive_example.dart';
import 'custom/example/custom_gradient_diagonal_card_example.dart';
import 'custom/example/custom_line_chart_painter_example.dart';
import 'custom/example/custom_search_bar_example.dart';
import 'custom/example/hexagon_hive_example.dart';
import 'custom/example/loading_button_widget_example.dart';
import 'my_theme_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // 1. primarySwatch 和 primaryColor 是互斥的。如果同时设置了两者，primaryColor 会覆盖 primarySwatch 中的主色
        //primarySwatch: Colors.blue,
        // 2. 自定义MaterialColor
        //primarySwatch: myCustomPurple,
        // 3.以下是primaryColor方案
        useMaterial3: true,
        // 使用 Material 3 设计
        primaryColor: Colors.blue,
        // 主要颜色，用于导航栏、按钮等
        primaryColorDark: Colors.blue[800],
        // 主要颜色的深色变体
        primaryColorLight: Colors.blue[100],
        // 主要颜色的浅色变体
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        // 基于种子颜色生成配色方案
        scaffoldBackgroundColor: Colors.grey[50],
        // 页面背景色
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // AppBar 背景色
          foregroundColor: Colors.white, // AppBar 上的文字和图标颜色
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87), // 默认文本颜色
        ),
      ),
      home: const UserInheritedWidgetExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}
