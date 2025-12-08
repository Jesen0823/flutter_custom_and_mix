import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/auto_router/router/app_router.dart';

@RoutePage()
class TabPage extends StatelessWidget {
  const TabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tab")),
      body: const AutoRouter(),
      bottomNavigationBar: _buildTabBar(context),
    );
  }

  // 构建TabBar
  Widget _buildTabBar(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '收藏'),
        BottomNavigationBarItem(icon: Icon(Icons.thumb_up), label: '点赞'),
      ],
      currentIndex: _getCurrentIndex(context),
      onTap: (index) => _onTabTap(context, index),
    );
  }

  // 获取当前Tab索引
  _getCurrentIndex(BuildContext context) {
    final routeData = AutoRouter.of(context).current;
    if (routeData.name == TabSaveRoute.name) return 0;
    if (routeData.name == TabLikeRoute.name) return 1;
    return 0;
  }

  // Tab切换逻辑
  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        AutoRouter.of(context).navigate(const TabSaveRoute());
        break;
      case 1:
        AutoRouter.of(context).navigate(const TabLikeRoute());
        break;
    }
  }
}
