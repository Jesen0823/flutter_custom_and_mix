import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 带加载状态的按钮：继承ElevatedButton扩展功能
///
/// 继承式自定义 Widget（扩展现有组件）
// 继承式自定义 Widget 是基于 Flutter 现有 Widget（如ElevatedButton、TextField）继承扩展，
// 重写其build或状态逻辑，实现个性化功能。
// 这种方式适合对现有 Widget 做轻量级扩展，而非完全重写。
// 适用场景
// 带状态的按钮：如加载中按钮、倒计时按钮；
// 个性化输入框：如仅允许输入数字的 TextField、带验证码的输入框；
// 定制化列表：如可侧滑删除的 ListView。
//
class LoadingButtonWidget extends StatefulWidget {
  // 按钮文字
  final String text;

  // 点击回调
  final VoidCallback? onPressed;

  // 按钮颜色
  final Color color;

  // 文字颜色
  final Color textColor;

  const LoadingButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.color = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  State<LoadingButtonWidget> createState() => _LoadingButtonWidgetState();
}

class _LoadingButtonWidgetState extends State<LoadingButtonWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: _isLoading ? null : _handlePressed,
      child: _buildButtonContent(),
    );
  }

  /// 构建按钮内容（加载中显示进度指示器）
  Widget _buildButtonContent() {
    if (_isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Text("加载中...", style: TextStyle(color: widget.textColor)),
        ],
      );
    } else {
      return Text(widget.text, style: TextStyle(color: widget.textColor));
    }
  }

  void _handlePressed() async {
    if (widget.onPressed == null) return;
    setState(() => _isLoading = true);

    try {
      // await widget.onPressed!(); //TODO bug
      widget.onPressed!();
    } finally {
      // 恢复按钮状态（使用SchedulerBinding确保异步操作完成后更新）
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
