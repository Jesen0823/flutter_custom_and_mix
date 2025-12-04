import 'package:flutter/material.dart';

/// SingleChildScrollView 页面，测试复杂布局的滚动位置保存
class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("我的页面，滚动布局")),
      body: SingleChildScrollView(
        key: const PageStorageKey<String>("mine_scroll"),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像区域
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              "用户名：Yalon",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // 功能列表（20项）
            ...List.generate(20, (index) {
              return Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('我的功能 ${index + 1}'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
