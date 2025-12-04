import 'package:flutter/material.dart';

/// 独立 ListView 页面，测试滚动位置保存
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("发现页 独立列表")),
      // ListView设置PageStorageKey保存滚动位置
      body: ListView.builder(
        key: const PageStorageKey<String>("discover_list"),
        itemCount: 50,
        itemBuilder: (context, index) {
          return Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              "发现页-列表项 ${index + 1}",
              style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
          );
        },
      ),
    );
  }
}
