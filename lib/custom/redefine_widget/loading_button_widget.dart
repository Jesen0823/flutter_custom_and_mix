import 'dart:async';

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
/// 还可以进一步优化：
/// 异步回调优先：建议业务中优先使用返回 Future 的异步回调，便于统一控制加载状态；
// 异常处理策略：根据业务需求选择「捕获消化异常」或「抛出给上层处理」，避免吞掉关键异常；
// 样式统一：可基于该组件封装项目专属的「主题按钮」（如 PrimaryLoadingButton、DangerLoadingButton），统一产品视觉风格；
// 性能优化：若按钮频繁使用（如列表项中），可通过 const 构造函数、缓存样式等方式优化性能；
// 测试覆盖：需测试「同步回调」「异步回调」「异常场景」「组件销毁时回调完成」四种核心场景，确保状态切换正确。
class LoadingButtonWidget extends StatefulWidget {
  // 按钮文字
  final String text;

  // 点击回调,支持同步void或异步Future<void>
  final FutureOr<void> Function()? onPressed;

  /// 按钮激活状态颜色
  final Color activeColor;

  /// 按钮禁用状态颜色
  final Color disabledColor;

  /// 文字颜色
  final Color textColor;

  /// 加载指示器颜色
  final Color indicatorColor;

  /// 按钮圆角
  final double borderRadius;

  /// 按钮内边距
  final EdgeInsetsGeometry padding;

  /// 是否禁止重复点击（默认true，防止并发请求）
  final bool disableDuplicateClick;

  const LoadingButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.activeColor = Colors.blue,
    this.disabledColor = Colors.grey,
    this.textColor = Colors.white,
    this.indicatorColor = Colors.white,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.disableDuplicateClick = true,
  }) : assert(borderRadius >= 0, "圆角不能为负数");

  @override
  State<LoadingButtonWidget> createState() => _LoadingButtonWidgetState();
}

class _LoadingButtonWidgetState extends State<LoadingButtonWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // 按钮是否可用：未加载中 + 回调不为空
    final bool isEnabled = !_isLoading && widget.onPressed != null;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? widget.activeColor : widget.disabledColor,
        padding: widget.padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        // 禁用状态下的透明度
        disabledBackgroundColor: widget.disabledColor.withAlpha(160),
        disabledForegroundColor: widget.textColor.withAlpha(140),
      ),
      onPressed: isEnabled ? _handlePressed : null,
      child: _buildButtonContent(),
    );
  }

  /// 构建按钮内容（加载中显示进度指示器）
  Widget _buildButtonContent() {
    if (_isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(widget.indicatorColor),
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "加载中...",
            style: TextStyle(color: widget.textColor, fontSize: 14),
          ),
        ],
      );
    } else {
      return Text(
        widget.text,
        style: TextStyle(
          color: widget.textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  Future<void> _handlePressed() async {
    // 防重复点击（如果启用）
    if (widget.disableDuplicateClick && _isLoading) return;
    // 标记为加载中（立即更新UI，防止重复点击）
    _setLoadingState(true);

    try {
      // 执行回调（区分同步/异步回调，避免编译错误）
      final result = widget.onPressed!();
      // 若回调返回Future，则等待异步完成
      if (result is Future) {
        await result;
      }
    } catch (e, stackTrace) {
      // 生产环境：捕获所有异常，避免崩溃，同时上报日志
      debugPrint('LoadingButton 点击回调异常：$e\n$stackTrace');
      // 可选：触发全局异常上报（如Sentry、Bugly等）
      // CrashReport.report(e, stackTrace, tag: 'LoadingButton');
      rethrow; // 如需上层处理异常，可抛出；否则直接捕获消化
    } finally {
      // 恢复按钮状态（使用SchedulerBinding确保异步操作完成后更新,避免在build过程中执行setState）
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _setLoadingState(false);
        }
      });
    }
  }

  //统一设置加载状态（封装成方法，便于后续扩展）
  void _setLoadingState(bool isLoading) {
    if (_isLoading != isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }
}
