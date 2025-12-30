import 'package:flutter/services.dart';
import 'package:flutter_custom_and_mix/communication/channel_service/method/auth_channel_service.dart';
import 'package:flutter_custom_and_mix/communication/core/constants/app_routes.dart';
import 'package:get/get.dart';

/// 未绑定页控制器
class UnbindController extends GetxController implements IAuthCallback {

// 微信测试链接
  final String _testUrl = "https://mp.weixin.qq.com/s/WLl1e_Ox-WcC3_gDUHZjTg";

  static final IAuthChannelService _channelService = AuthChannelServiceImpl();

  final RxString _status = "未启动AuthService".obs;

  String get status => _status.value;

  final RxList<String> _qrCodeUrls = [""].obs;

  List<String> get qrCodeUrls => _qrCodeUrls;

  final RxString _webViewStatus = "WebView未加载".obs;

  String get webViewStatus => _webViewStatus.value;

  @override
  void onInit() {
    super.onInit();

    _channelService.registerCallback(this);
  }

  @override
  void onClose() {
    super.onClose();
    _channelService.unregisterCallback();
  }

  Future<void> goUserInfo() async{
    Get.toNamed(AppRoutes.userInfo);
  }

  Future<void> goComHomePage() async{
    Get.toNamed(AppRoutes.comHome);
  }

  /// 启动AuthService
  Future<void> startAuthService() async {
    try {
      await _channelService.startAuthService();
      _status.value = "AuthService启动成功";
    } on PlatformException catch (e) {
      _status.value = "启动失败：${e.message}";
    }
  }

  /// 加载微信链接
  Future<void> loadWechatUrl() async {
    try {
      await _channelService.loadWebUrl(url:_testUrl);
      _webViewStatus.value = "正在加载微信链接...";
      _status.value = "正在识别二维码...";
    } on PlatformException catch (e) {
      _status.value = "加载链接失败：${e.message}";
    }
  }

  /// 停止AuthService
  Future<void> stopAuthService() async {
    try {
      await _channelService.stopAuthService();
      _status.value = "AuthService已停止";
      _qrCodeUrls.value = [];
      _webViewStatus.value = "WebView未加载";
    } on PlatformException catch (e) {
      _status.value = "停止失败：${e.message}";
    }
  }

  @override
  void onWebViewLoaded() {
    print("===== onWebViewLoaded called, updating _webViewStatus");
    _webViewStatus.value = "WebView加载完成";
    print("===== _webViewStatus updated to: ${_webViewStatus.value}");
  }

  @override
  void onQrCodeDetected(String qrCodeUrl) {
    print("===== onQrCodeDetected called, qrCodeUrl: $qrCodeUrl");
    if (!_qrCodeUrls.contains(qrCodeUrl)) {
      _qrCodeUrls.add(qrCodeUrl);
      print("===== added qrCodeUrl to list, current count: ${_qrCodeUrls.length}");
    }
    _status.value = "识别到 ${_qrCodeUrls.length} 个二维码";
    print("===== _status updated to: ${_status.value}");
  }

  @override
  void onQrCodeLinksDetected(List<String> qrCodeLinks) {
    print("===== onQrCodeLinksDetected called, links count: ${qrCodeLinks.length}");
    _qrCodeUrls.value = qrCodeLinks;
    _status.value = "识别到 ${_qrCodeUrls.length} 个二维码";
    print("===== _qrCodeUrls updated, count: ${_qrCodeUrls.length}");
  }

  @override
  void onError(String error) {
    print("===== onError called, error: $error");
    _status.value = "错误：$error";
  }

  @override
  void onAuthSuccess(String token) {
    print("===== onAuthSuccess called, token: $token");
    _status.value = "认证成功：$token";
  }
}