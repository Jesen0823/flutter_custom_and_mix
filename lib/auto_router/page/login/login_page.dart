import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/auth_state.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  final Function(bool)? onResult; // 登录结果回调

  const LoginPage({super.key, this.onResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Container(
        color: Colors.yellowAccent.shade100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("登录页"),
              ElevatedButton(
                onPressed: () {
                  onResult?.call(true);
                  // 模拟登录成功：通过状态管理/回调传递结果
                  _mockLoginSuccess(context);
                },
                child: const Text('模拟登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mockLoginSuccess(BuildContext context) {
    // 1. 登录状态存入全局（比如Provider/SharedPreferences）
    AuthState.isLogin = true;
    // 2. 关闭登录页，返回上一级
    AutoRouter.of(context).pop();
  }
}
