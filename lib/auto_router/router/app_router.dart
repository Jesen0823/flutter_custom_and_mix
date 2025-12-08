import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/auto_router/page/tab/second/tab_like_page.dart';
import 'package:flutter_custom_and_mix/auto_router/page/tab/second/third/like_detail_page.dart';

// 先导入所有页面,页面必须加@RoutePage()
import '../model/goods_entity.dart';
import '../page/home/home_page.dart';
import '../page/detail/detail_page.dart';
import '../page/tab/second/tab_save_page.dart';
import '../page/tab/tab_page.dart';
import '../page/login/login_page.dart';
import 'router_guards.dart';

// 生成的路由代码会输出到这个文件
part 'app_router.gr.dart';

/// 核心路由配置类
// 自动替换路由名称中的Page/Route后缀
// # 一次性生成
// flutter pub run build_runner build --delete-conflicting-outputs
// # 开发期实时生成（推荐）
// flutter pub run build_runner watch --delete-conflicting-outputs
//
@AutoRouterConfig(replaceInRouteName: 'Page,Route') // 自动替换路由名称中的Page/Route后缀
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // 1. 基础路由（首页，作为初始路由）
    AutoRoute(
      path: '/',
      page: HomeRoute.page,
      initial: true, // 标记为初始路由
    ),
    // 2. 详情页路由（带参数）
    AutoRoute(
      path: '/detail:id', // :id 表示路径参数
      page: DetailRoute.page,
      guards: [LoginGuard()], // 仅详情页触发登录守卫
    ),
    // 3. 登录页路由
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(
      page: TabRoute.page,
      children: [
        // 二级路由 收藏页面
        AutoRoute(
          path: 'tab_save',
          page: TabSaveRoute.page,
          initial: true, // Tab默认显示的子路由
        ),
        // 二级路由 点赞页面
        AutoRoute(
          path: 'tab_like',
          page: TabLikeRoute.page,
          children: [
            // 三级路由：点赞详情
            AutoRoute(
              path: 'like_detail',
              page: LikeDetailRoute.page,
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  List<AutoRouteGuard> get guards => [
    GlobalGuard(), // 全局守卫（所有路由都会触发）
    // 可添加多个全局守卫，按顺序执行
  ];

  @override
  List<AutoRouteGuard> get routeGuards => [
    GlobalGuard(), // 全局守卫（所有路由都会触发）
    // 可添加多个全局守卫，按顺序执行
  ];

  /// 自定义路由样式,统一配置过渡动画、主题
  @override
  RouteType get defaultRouteType => const RouteType.material();
}
