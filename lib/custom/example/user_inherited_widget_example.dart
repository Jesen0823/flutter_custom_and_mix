import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/inherited_widget/model.dart';
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
    // 关键：使用子树内的 context，且设置 listen: false（事件回调无需监听）
    UserProvider.getUpdateUser(context)(loginUser);
  }

  @override
  Widget build(BuildContext context) {
    // UserProvider 作为祖先组件，包裹需要共享状态的子树
    return UserProvider(
      child: Scaffold(
        appBar: AppBar(title: const Text("自定义InheritedWidget-用户信息共享")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 关键：通过 Builder 获取子树内的 context（处于 UserInheritedWidget 子树中）
              Builder(
                builder: (innerContext) {
                  // 获取用户状态（listen: true，监听状态变化并重绘）
                  final UserModel user = UserProvider.getUser(innerContext);

                  return Column(
                    children: [
                      // 显示用户头像（登录后显示，未登录显示默认图标）
                      user.isLogin
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(user.avatar),
                            )
                          : const CircleAvatar(
                              radius: 40,
                              child: Icon(Icons.person, size: 40),
                            ),
                      const SizedBox(height: 16),
                      Text(
                        "用户名：${user.name}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        "登录状态：${user.isLogin ? "已登录" : "未登录"}",
                        style: TextStyle(
                          fontSize: 16,
                          color: user.isLogin ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // 关键：通过 Builder 获取子树内的 context，传递给 _mockLogin
              Builder(
                builder: (innerContext) {
                  return ElevatedButton(
                    onPressed: () => _mockLogin(innerContext),
                    child: const Text("模拟登录"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
