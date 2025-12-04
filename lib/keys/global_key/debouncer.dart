import 'dart:async';
import 'dart:ui';


/// 防抖工具类
class Debouncer {
  final int milliseconds;
  VoidCallback? _callback;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback callback) {
    _timer?.cancel();
    _callback = callback;
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _callback?.call();
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}