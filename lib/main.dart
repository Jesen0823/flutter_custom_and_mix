import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/communication/pages/user_info_page.dart';

import 'auto_router/router/app_router.dart';
import 'communication/communication_app.dart';
import 'communication/core/helpers/hive_helper.dart';
import 'communication/utils/app_logger.dart';

// 全局路由实例（企业级：通过Provider管理，避免重复创建）
final appRouter = AppRouter();

//void main() {
  //runApp(const MyApp());

  //runApp(const RouterApp());

  //runApp(const GlobalKeyLoginPageExampleApp());
//}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger().init();
  // 初始化Hive
  await HiveHelper().initHive();
  runApp(const CommunicationApp());
}

class RouterApp extends StatelessWidget {
  const RouterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AutoRouter Demo',
      // 路由核心配置
      routerDelegate: AutoRouterDelegate(
        appRouter,
        navigatorObservers: () => [
          AutoRouteObserver(), // 路由生命周期监听（企业级：埋点/统计用）
        ],
      ),
      routeInformationParser: appRouter.defaultRouteParser(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
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
      home: UserInfoPagePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
