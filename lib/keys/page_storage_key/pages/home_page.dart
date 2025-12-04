import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/keys/page_storage_key/widgets/nested_list_widget.dart';
import 'package:flutter_custom_and_mix/keys/page_storage_key/widgets/persistent_text_field.dart';

/// 核心页面：嵌套滚动（SingleChildScrollView + ListView）+ 持久化 TextField
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("首页 嵌套滚动")),
      // 外层滚动容器（设置PageStorageKey保存滚动位置）
      body: SingleChildScrollView(
        key: const PageStorageKey<String>("home_outer_scroll"),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "持久化输入框",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            PersistentTextField(
              storageKey: "home_text_field",
              hintText: "输入内容切换页面不丢失...",
            ),
            const SizedBox(height: 12),
            // 嵌套列表标题
            const Text(
              "以下是嵌套列表",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // 嵌套列表，设置独立PageStorageKey
            NestedListWidget(
              storageKey: const PageStorageKey<String>("home_inner_list"),
            ),
          ],
        ),
      ),
    );
  }
}
