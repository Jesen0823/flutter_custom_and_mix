import 'package:flutter/material.dart';

import '../global_key/login_page.dart';
/// GlobalKey 打破了文件和组件的层级限制
/// 跨组件获取输入值
// 输入框的 TextEditingController 由 LoginPage 管理（业务层），而非表单组件（UI 层）；
// PhoneInput 和 PasswordInput 仅负责 UI 渲染，通过构造函数接收控制器；
// 验证通过后，LoginPage 可直接通过控制器获取输入值 ——实现 UI 组件与业务逻辑的解耦，同时跨组件传递数据。
class GlobalKeyLoginPageExampleApp extends StatelessWidget {
  const GlobalKeyLoginPageExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GlobalKey跨组件案例",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(), // 首页为登录页
      // 可扩展路由（示例：登录成功后跳转首页，传递用户信息）
      routes: {
        "/global_home": (context) {
          // 接收跨页面传值（通过ModalRoute获取arguments）
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          return Scaffold(
            appBar: AppBar(title: const Text("首页")),
            body: Center(child: Text("欢迎您，${args?["phone"] ?? "用户"}")),
          );
        },
      },
    );
  }
}
