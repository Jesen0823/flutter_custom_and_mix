import 'dart:async';
import 'package:get/get.dart';
import '../core/constants/app_routes.dart';
import '../core/helpers/hive_helper.dart';

/// 启动页控制器
class SplashController extends GetxController {
  final HiveHelper _hiveHelper = HiveHelper();
  late Timer _countDownTimer;
  final RxInt _countDown = 5.obs; // 倒计时（响应式状态）
  int get countDown => _countDown.value;

  @override
  void onInit() {
    super.onInit();
    _startCountDown(); // 初始化时启动倒计时
  }

  /// 启动5秒倒计时
  void _startCountDown() {
    _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countDown.value > 0) {
        _countDown.value--;
      } else {
        _countDownTimer.cancel(); // 倒计时结束，取消定时器
        _jumpToTargetPage(); // 跳转目标页面
      }
    });
  }

  /// 点击跳过按钮
  void onSkipClick() {
    _countDownTimer.cancel(); // 取消倒计时
    _jumpToTargetPage(); // 立即跳转
  }

  /// 根据账号状态跳转目标页面
  void _jumpToTargetPage() {
    final hasBinded = _hiveHelper.hasBindedAccount();
    if (hasBinded) {
      // 已绑定账号：跳首页，并移除启动页（无法返回）
      Get.offAllNamed(AppRoutes.comHome);
    } else {
      // 未绑定账号：跳未绑定页（全屏弹窗）
      Get.offAllNamed(AppRoutes.unbind);
    }
  }

  @override
  void onClose() {
    // 销毁时取消定时器，避免内存泄漏
    if (_countDownTimer.isActive) {
      _countDownTimer.cancel();
    }
    super.onClose();
  }
}