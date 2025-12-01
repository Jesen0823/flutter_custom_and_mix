import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/inherited_widget/model.dart';
import 'package:flutter_custom_and_mix/custom/inherited_widget/user_inherited_widget.dart';
import 'package:flutter_custom_and_mix/custom/inherited_widget/user_provider.dart';

class UserInheritedWidgetExample extends StatelessWidget {
  const UserInheritedWidgetExample({super.key});

  // 模拟登录
  _mockLogin(BuildContext context) {
    final UserModel loginUser = UserModel(
      id: "1001",
      name: "Flutter开发者",
      avatar: "https://picsum.photos/200/300",
      isLogin: true,
    );
    UserInheritedWidget.of(context).updateUser(loginUser);
  }

  @override
  Widget build(BuildContext context) {
    return UserProvider(
      child: Scaffold(
        appBar: AppBar(title: const Text("用户信息共享")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 子组件获取用户信息
              Builder(
                builder: (context) {
                  final UserModel user = UserInheritedWidget.of(context).user;

                  return Column(
                    children: [
                      Text("用户名：${user.name}"),
                      Text("登录状态：${user.isLogin ? "已登录" : "未登录"}"),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _mockLogin(context),
                child: const Text("模拟登录"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
