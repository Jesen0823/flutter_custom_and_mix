import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/inherited_widget/model.dart';

/// 自定义InheritedWidget（跨组件状态共享）
// InheritedWidget是 Flutter 中跨组件状态共享的底层实现，用于将状态从祖先组件传递给子孙组件，无需手动层层传递参数。
// 企业开发中，InheritedWidget常被用于实现全局状态共享（如用户信息、主题配置、语言设置），也是Provider、Bloc等状态管理库的底层基础。
//
// 适用场景
// 全局状态共享：如用户登录信息、应用主题；
// 局部状态共享：如页面内的筛选条件、列表分页信息；
// 配置传递：如多语言配置、字体大小配置。
//
// 核心优势
// 高效状态传递：跨组件传递状态，无需层层传递参数；
// 细粒度更新：仅当状态变化时，通知依赖的子孙组件重绘；
// 底层可定制：是实现自定义状态管理的基础，灵活性高。

/// 自定义InheritedWidget：共享用户信息
class UserInheritedWidget extends InheritedWidget {
  // 用户信息
  final UserModel user;

  // 更新用户信息的回调
  final Function(UserModel) updateUser;

  const UserInheritedWidget({
    super.key,
    required this.updateUser,
    required this.user,
    required super.child,
  });

  // 提供获取方法
  static UserInheritedWidget of(BuildContext context){
    final UserInheritedWidget? result = context.dependOnInheritedWidgetOfExactType<UserInheritedWidget>();
    assert(result !=null,"UserInheritedWidget not found in context.");
    return result!;
  }

  @override
  bool updateShouldNotify(covariant UserInheritedWidget oldWidget) {
    // 仅当用户信息变化时，通知子孙组件重绘
    return oldWidget.user.id != user.id || oldWidget.user.isLogin != user.isLogin;
  }
}
