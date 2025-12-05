import 'package:flutter/material.dart';

import 'keys/example/global_key_login_page_example_app.dart';
import 'keys/example/value_key_shopping_cart_page_example.dart';
import 'keys/labeled_global_key/labeled_global_key_dynamic_form_page.dart';
import 'keys/page_storage_key/page_storage_key_main_page.dart';
import 'keys/unique_key/unique_verify_code_page.dart';

void main() {
  runApp(const MyApp());
  //runApp(const GlobalKeyLoginPageExampleApp());
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
      home: UniqueVerifyCodePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
