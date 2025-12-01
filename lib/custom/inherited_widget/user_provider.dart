import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/inherited_widget/model.dart';
import 'package:flutter_custom_and_mix/custom/inherited_widget/user_inherited_widget.dart';

/// 状态管理外层组件（组合InheritedWidget与StatefulWidget）
class UserProvider extends StatefulWidget {
  final Widget child;
  // 可选：初始用户状态
  final UserModel? initialUser;

  const UserProvider({super.key, required this.child,this.initialUser});

  // 对外暴露便捷获取方法（无需手动调用 UserInheritedWidget.of）
  static UserModel getUser(BuildContext context,{bool listen = true}){
    return of(context,listen:listen).user;
  }

  static Function(UserModel) getUpdateUser(BuildContext context) {
    return of(context, listen: false).updateUser;
  }

  static UserInheritedWidget of(BuildContext context,{bool listen=true}){
    return UserInheritedWidget.of(context,listen: listen);
  }

  @override
  State<UserProvider> createState() => _UserProviderState();
}

class _UserProviderState extends State<UserProvider> {
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    // 初始化用户状态（优先使用传入的 initialUser，否则使用未登录状态）
    _user = widget.initialUser ?? UserModel.unLogin;
  }

  // 更新用户信息
  void _updateUser(UserModel newUser) {
    if(_user == newUser) return; // 避免无意义的重绘
    setState(() => _user = newUser);
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
