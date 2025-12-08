import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import 'app_router.dart';
import 'auth_state.dart';

/// 登录守卫（必须继承AutoRouteGuard
class LoginGuard extends AutoRouteGuard{
  // 模拟登录状态
  bool get isLogin => false;

  @override
  FutureOr<void> onNavigation(NavigationResolver resolver, StackRouter router) {
    // resolver：路由解析器（决定是否放行）
    // router：路由实例（用于重定向）
    if (AuthState.isLogin) {
      resolver.next(true); // 已登录，放行
    } else {
      // 未登录，跳登录页（无需回调，登录后重新触发导航）
      router.push(LoginRoute(onResult: (bool isSuccess) {
        if (isSuccess) {
          // 登录成功：重新放行原路由
          resolver.next(true);
        } else {
          // 登录失败：取消导航
          resolver.next(false);
        }
      }),);
    }
  }
}

/// 全局守卫
class GlobalGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // 全局日志/埋点
    if (kDebugMode) {
      print('全局守卫：即将跳转 ${resolver.route.name}');
    }
    resolver.next(true);
  }
}