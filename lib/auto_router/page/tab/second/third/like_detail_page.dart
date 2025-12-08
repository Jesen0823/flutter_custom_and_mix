import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LikeDetailPage extends StatelessWidget {
  const LikeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent.shade100,
      child: Center(
        child: Column(
          children: [
            const Text("点赞详情页面"),
            ElevatedButton(
              onPressed: () {
                AutoRouter.of(context).pop();
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
