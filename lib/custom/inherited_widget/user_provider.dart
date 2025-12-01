import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/inherited_widget/model.dart';
import 'package:flutter_custom_and_mix/custom/inherited_widget/user_inherited_widget.dart';

/// 状态管理外层组件（组合InheritedWidget与StatefulWidget）
class UserProvider extends StatefulWidget {
  final Widget child;

  const UserProvider({super.key, required this.child});

  @override
  State<UserProvider> createState() => _UserProviderState();
}

class _UserProviderState extends State<UserProvider> {
  UserModel _user = UserModel.unLogin;

  // 更新用户信息
  void _updateUser(UserModel user) {
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    return UserInheritedWidget(
      updateUser: _updateUser,
      user: _user,
      child: widget.child,
    );
  }
}
