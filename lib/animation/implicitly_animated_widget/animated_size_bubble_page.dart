import 'package:flutter/material.dart';

/// AnimatedSize：客服聊天气泡文本展开/收起
///
/// 场景:
// 客服/社交 App 的聊天气泡中，长文本默认折叠（显示2行），点击后展开全部内容，尺寸自适应动画过渡，提升阅读体验。
// 1. `AnimatedSize` 自动适配子组件尺寸变化，无需手动计算高度；
// 2. 关键参数 `alignment: Alignment.topLeft`：避免文本展开时位置偏移，保证动画自然；
class AnimatedSizeBubblePage extends StatefulWidget {
  const AnimatedSizeBubblePage({super.key});

  @override
  State<AnimatedSizeBubblePage> createState() => _AnimatedSizeBubblePageState();
}

class _AnimatedSizeBubblePageState extends State<AnimatedSizeBubblePage> {
  // 控制文本是否展开
  bool _isExpanded = false;

  // 消息内容
  final String _longText = """您好，关于您反馈的订单物流问题，我们已核实：
  您的订单（编号20250510001）已于今日上午9点由顺丰快递揽收，预计24小时内送达。
  若未按时送达，可联系快递员（电话13800138000）或拨打我司客服热线400-888-8888，我们会协助您处理。
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("客服聊天（AnimatedSize）")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "【客服小绿】",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // AnimatedSize 实现尺寸自适应
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.green, width: 1),
                    borderRadius: _isExpanded
                        ? BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          )
                        : BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  // 文本行数控制：展开时无限制，折叠时2行
                  child: Text(
                    _longText,
                    maxLines: _isExpanded ? 10 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 文本收起状态
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _isExpanded ? "收起" : "展开",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
