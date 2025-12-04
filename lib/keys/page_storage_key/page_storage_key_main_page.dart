import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/keys/page_storage_key/pages/discover_page.dart';
import 'package:flutter_custom_and_mix/keys/page_storage_key/pages/home_page.dart';
import 'package:flutter_custom_and_mix/keys/page_storage_key/pages/mine_page.dart';

/// PageStorageKey 保存滚动位置
///
/// 案例实现PageStorage + PageStorageKey 的核心能力：
// 保存多页面切换时的滚动位置（ListView/SingleChildScrollView）
// 保存 TextField 输入内容（基于 PageStorage 持久化）
// 处理列表嵌套的滚动冲突与位置保存

/// 核心特性
// PageStorageKey 唯一性：每个可滚动组件 / TextField 都有唯一的 key（如home_outer_scroll、discover_list），确保存储位置不冲突
// 嵌套滚动处理：内部 ListView 设置NeverScrollableScrollPhysics，交给外层 SingleChildScrollView 统一滚动，避免冲突
// TextField 持久化：通过PageStorage.of(context).writeState/readState保存 / 读取输入内容
// 页面状态保持：使用IndexedStack而非PageView，确保切换页面时不销毁组件，PageStorage 能正常读写

class PageStorageKeyMainPage extends StatefulWidget {
  const PageStorageKeyMainPage({super.key});

  @override
  State<PageStorageKeyMainPage> createState() => _PageStorageKeyMainPageState();
}

class _PageStorageKeyMainPageState extends State<PageStorageKeyMainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [HomePage(), DiscoverPage(), MinePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PageStorageKey的使用")),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "首页"),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: "发现",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
        ],
      ),
    );
  }
}
