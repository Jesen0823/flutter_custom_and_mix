import 'package:flutter/material.dart';

/// 验证码卡片组件,带倒计时状态，验证重建逻辑
class VerifyCodeCard extends StatefulWidget {
  final String cardTitle;
  final String verifyCode;

  const VerifyCodeCard({
    super.key,
    required this.cardTitle,
    required this.verifyCode,
  });

  @override
  State<VerifyCodeCard> createState() => _VerifyCodeCardState();
}

class _VerifyCodeCardState extends State<VerifyCodeCard> {
  // 倒计时状态
  int _countdown = 10;

  // Widget哈希值，标识是否重建
  late final int _widgetHashCode = hashCode;

  @override
  void initState() {
    super.initState();
    // 开始倒计时
    _startCountdown();
    // 日志：标记 Widget 初始化（重建时会再次打印）
    debugPrint('【${widget.cardTitle}】→ 触发 initState，HashCode：$_widgetHashCode');
  }

  @override
  void didUpdateWidget(covariant VerifyCodeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 日志：仅更新属性（未重建）时触发
    debugPrint(
      '【${widget.cardTitle}】→ 触发 didUpdateWidget（仅更新属性，未重建），'
      '旧验证码：${oldWidget.verifyCode}，新验证码：${widget.verifyCode}',
    );
  }

  @override
  void dispose() {
    debugPrint(
      '【${widget.cardTitle}】→ 触发 dispose（要死了），'
      '当前验证码：${widget.verifyCode}',
    );
    super.dispose();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 卡片标题
          Text(
            widget.cardTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          // 验证码
          Text(
            widget.verifyCode,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 15),
          // 倒计时，验证状态是否重置
          Text(
            "倒计时：$_countdown s",
            style: TextStyle(
              fontSize: 14,
              color: _countdown > 0 ? Colors.orange : Colors.green,
            ),
          ),
          const SizedBox(height: 15),
          // 显示Widget哈希值，标识是否重建
          Text(
            "当前HashCode: $_widgetHashCode",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
