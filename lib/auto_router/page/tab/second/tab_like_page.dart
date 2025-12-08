import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/auto_router/router/app_router.dart';

@RoutePage()
class TabLikePage extends StatelessWidget {
  const TabLikePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent.shade100,
      child: Center(
        child: Column(
          children: [
            const Text("点赞页面"),
            ElevatedButton(
              onPressed: () {
                AutoRouter.of(context).navigate(const LikeDetailRoute());
              },
              child: const Text('跳转到点赞详情页（三级路由）'),
            ),
          ],
        ),
      ),
    );
  }
}
