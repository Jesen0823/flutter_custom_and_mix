import 'package:flutter/material.dart';

/// ## AnimatedSwitcher：列表加载状态切换
//
// 场景:
// 所有 App 的列表页面都需处理「加载中→空数据→有数据」三种状态，`AnimatedSwitcher`
// 实现状态间的平滑切换，提升用户体验。
//
// 要点:
// 1.核心要求：不同状态的子组件必须设置唯一 `key`，否则无法触发动画；
// 2. 扩展：
//    - 自定义 `transitionBuilder` 实现复合动画（缩放+淡入淡出），替代默认的仅淡入淡出；
//    - 状态枚举抽离为全局常量，保证多页面状态定义统一；
// 3. 业务适配：空数据状态提供“重新加载”按钮。
class AnimatedSwitcherStatePage extends StatefulWidget {
  const AnimatedSwitcherStatePage({super.key});

  @override
  State<AnimatedSwitcherStatePage> createState() =>
      _AnimatedSwitcherStatePageState();
}

// 定义加载状态枚举
enum ListLoadState { loading, empty, hasData }

class _AnimatedSwitcherStatePageState extends State<AnimatedSwitcherStatePage> {
  late ListLoadState _currentState;
  final List<String> _dataList = [];

  @override
  void initState() {
    super.initState();
    _loadDataRequest(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("列表状态切换（AnimatedSwitcher）")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          // 切换动画：缩放+淡入淡出
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          // 关键：不同状态的子组件必须设置唯一key
          child: _buildStateWidget(),
        ),
      ),
    );
  }

  void _loadDataRequest(bool reload) {
    setState(() => _currentState = ListLoadState.loading);
    // 延迟2秒返回数据
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (reload) {
          setState(() {
            // 模拟有数据返回
            _currentState = ListLoadState.hasData;
            _dataList.addAll(List.generate(12, (index) => "列表数据 ${index + 1}"));
          });
        } else {
          setState(() {
            // 模拟空数据场景
            _currentState = ListLoadState.empty;
          });
        }
      }
    });
  }

  // 重新加载数据
  void _reloadData() => _loadDataRequest(true);

  // 状态构建对应Widget
  Widget _buildStateWidget() {
    switch (_currentState) {
      case ListLoadState.loading:
        return _buildLoadingWidget();
      case ListLoadState.empty:
        return _buildEmptyWidget();
      case ListLoadState.hasData:
        return _buildDataWidget();
    }
  }

  // 加载中Widget
  Widget _buildLoadingWidget() {
    return const Center(
      key: ValueKey("loading"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("加载中..."),
        ],
      ),
    );
  }

  // 空数据Widget
  Widget _buildEmptyWidget() {
    return Center(
      key: ValueKey("empty"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/content_empty.png",
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          const Text("暂无数据"),
          ElevatedButton(onPressed: _reloadData, child: const Text("重新加载")),
        ],
      ),
    );
  }

  // 有数据Widget
  Widget _buildDataWidget() {
    return ListView.builder(
      key: ValueKey("data"),
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_dataList[index]),
          leading: const Icon(Icons.check_circle_outline),
        );
      },
    );
  }
}
