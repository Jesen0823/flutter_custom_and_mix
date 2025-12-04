import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/keys/key_toggleable_tile.dart';

// 页面：两个列表项，点击按钮交换顺序

/// 【无 Key 时的问题：】
// 1.选中 “收藏1”（_isSelected = true）；
// 2.点击 “交换列表内容”，Widget 树中两个ToggleableTile的title交换；
// 3.实际效果：选中状态依然停留在第一个位置，而非跟随 “收藏1” 移动。
//
// 【问题根源：】
// 1.Flutter 按 “索引匹配” 复用 Element：
// 2.旧 Element 树：索引 0→ElementA（对应 “收藏1”，状态selected=true）、索引 1→ElementB（对应 “点赞2”，状态selected=false）；
// 3.新 Widget 树：索引 0→WidgetB（title=“点赞2”）、索引 1→WidgetA（title=“收藏1”）；
// 4.匹配逻辑：新 WidgetB 的runtimeType与旧 ElementA 一致 → 复用 ElementA（保留其selected=true状态），导致状态与 Widget 不匹配。

/// 【解决问题：】
/// 给item控件ToggleableTile添加ValueKey(title)：

/// 此时匹配逻辑变为：通过 “runtimeType + Key” 匹配：
// 新 WidgetA（title=“收藏1”，Key=ValueKey (“收藏1”)）→ 匹配旧 ElementA（Key 一致）→ 复用 ElementA（状态跟随 Widget 移动）；
// 新 WidgetB（title=“点赞2”，Key=ValueKey (“点赞2”)）→ 匹配旧 ElementB → 复用 ElementB；
// 最终效果：选中状态正确跟随 “收藏1” 移动。

/// 总结：无状态、固定顺序的简单 Widget（如静态文本、图片）可以不用 Key；
/// 但只要涉及 “状态、动态变化、跨组件交互”，必须合理使用 Key。
///
class KeyToggleableTileExample extends StatefulWidget {
  const KeyToggleableTileExample({super.key});

  @override
  State<KeyToggleableTileExample> createState() =>
      _KeyToggleableTileExampleState();
}

class _KeyToggleableTileExampleState extends State<KeyToggleableTileExample> {
  late List<String> _titles;

  @override
  void initState() {
    super.initState();
    _titles = ["收藏1", "点赞2"];
  }

  void _swapTitles() {
    setState(() => _titles = _titles.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("没有key，引发问题")),
      body: Column(
        children: [
          ElevatedButton(onPressed: _swapTitles, child: const Text("交换列表内容")),
          ListView(
            shrinkWrap: true,
            /*children: _titles
                .map((title) => KeyToggleableTile(title))
                .toList(),*/
            // 给ToggleableTile添加ValueKey(title)：
            children: _titles
                .map((title) => KeyToggleableTile(title, key: ValueKey(title)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
