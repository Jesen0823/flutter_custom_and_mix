// 通用防抖工具类
import 'dart:ui';

class DebounceUtil {
  static final Map<String, bool> _locks = {};

  /// 防抖执行
  /// [key] 锁的唯一标识
  /// [duration] 锁的时长
  /// [action] 要执行的操作
  static void execute(String key, Duration duration, VoidCallback action) {
    if (_locks[key] ?? false) return;
    _locks[key] = true;
    action();
    Future.delayed(duration, () => _locks[key] = false);
  }
}

/// 使用方式
/// DebounceUtil.execute("cartButton", Duration(milliseconds: 50), () {
// _isScrolled = true;
// setState(() {});
// });