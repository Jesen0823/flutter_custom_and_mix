import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class TabSavePage extends StatelessWidget {
  const TabSavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent.shade100,
      child: Center(child: const Text("收藏页面")),
    );
  }
}
