import 'package:flutter/material.dart';

/// AnimatedOpacity：消息列表项删除确认动画
// 场景：
// 社交 / 办公 App 的消息列表中，点击 “删除” 后先将条目半透明（提示用户），延迟后隐藏，避免直接消失的突兀感，符合移动端交互设计规范。
// AnimatedOpacity 仅控制透明度，无布局重算，性能最优
class AnimatedOpacityMessagePage extends StatefulWidget {
  const AnimatedOpacityMessagePage({super.key});

  @override
  State<AnimatedOpacityMessagePage> createState() =>
      _AnimatedOpacityMessagePageState();
}

class _AnimatedOpacityMessagePageState
    extends State<AnimatedOpacityMessagePage> {
  final List<Map<String, dynamic>> _messages = [
    {"id": "m1", "content": "周一上午10点开产品评审会", "sender": "产品经理"},
    {"id": "m2", "content": "这个版本的Bug已修复，可提测", "sender": "开发工程师"},
    {"id": "m3", "content": "请确认本周的周报是否提交", "sender": "HR"},
  ];

  // 待删除消息的ID
  final Set<String> _pendingDeleteIds = {};

  // 触发删除动画
  void _onDelete(String messageId) {
    setState(() {
      _pendingDeleteIds.add(messageId);
    });
    // 延迟1秒后真正删除数据
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.removeWhere((msg) => msg['id'] == messageId);
          _pendingDeleteIds.remove(messageId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("消息列表（AnimatedOpacity）")),
      body: _messages.isNotEmpty?ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isPendingDelete = _pendingDeleteIds.contains(message["id"]);
          return _buildMessageItem(message, isPendingDelete);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: _messages.length,
      ):const Center(child: Text("列表已经没有数据了~"),),
    );
  }

  // 构建消息条目（AnimatedOpacity 动画）
  Widget _buildMessageItem(Map<String, dynamic> message, bool isPendingDelete) {
    return AnimatedOpacity(
      opacity: isPendingDelete ? 0.3 : 1.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.bounceOut,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    message["sender"],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message["content"],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            // 删除按钮
            IconButton(
              onPressed: () => _onDelete(message["id"]),
              icon: const Icon(Icons.delete_outlined, color: Colors.redAccent),
              disabledColor: Colors.grey,
              enableFeedback: !isPendingDelete,
            ),
          ],
        ),
      ),
    );
  }
}
