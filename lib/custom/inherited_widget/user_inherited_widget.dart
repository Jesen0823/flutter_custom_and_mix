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

/// InheritedWidget 使用的核心注意事项
// Context 必须在子树内：
// 调用 InheritedWidget.of(context) 时，context 必须是 InheritedWidget 子树中的上下文（即 InheritedWidget 的 child 及其子组件的上下文）；
// 避免在 InheritedWidget 的父组件中使用其上下文查找，必然失败。
// 合理设置 listen 参数：
// UI 组件（如展示用户名、头像）：listen: true，确保状态更新时 UI 同步刷新；
// 事件回调（如按钮点击、接口请求）：listen: false，无需监听状态变化，提升性能。
// 精准实现 updateShouldNotify：
// 仅当 InheritedWidget 的核心状态变化时，返回 true，避免子组件无意义重绘；
// 不要直接返回 true（会导致每次父组件重绘都触发子组件重绘）。
// 封装上层 API：
// 不要让业务代码直接操作 InheritedWidget，通过 Provider 类（如 UserProvider）封装静态方法，降低使用成本和错误率。
// 避免 Context 泄漏：
// 不要在异步回调（如 Future.delayed、接口请求回调）中直接使用 context，需先判断 mounted，或使用 WidgetsBinding.instance.addPostFrameCallback。

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

  // 提供获取方法,增加 listen 参数，控制是否监听状态变化（默认 true）
  static UserInheritedWidget of(BuildContext context, {bool listen = true}) {
    if (listen) {
      // 监听状态变化：当 user 改变时，依赖的组件会重绘
      final result = context
          .dependOnInheritedWidgetOfExactType<UserInheritedWidget>();
      assert(result != null, "UserInheritedWidget not found in context.");
      return result!;
    } else {
      // 不监听状态变化：仅获取当前状态，适合事件回调等场景
    }
    final UserInheritedWidget? result =
        context
                .getElementForInheritedWidgetOfExactType<UserInheritedWidget>()
                ?.widget
            as UserInheritedWidget?;
    assert(result != null, "UserInheritedWidget not found in context also.");
    return result!;
  }

  @override
  bool updateShouldNotify(covariant UserInheritedWidget oldWidget) {
    // 仅当用户信息变化时，通知子孙组件重绘
    return oldWidget.user.id != user.id ||
        oldWidget.user.isLogin != user.isLogin ||
        oldWidget.user.name != user.name ||
        oldWidget.user.avatar != user.avatar;
  }
}
