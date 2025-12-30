import 'package:flutter/services.dart';
import 'package:flutter_custom_and_mix/communication/utils/constant.dart';
import 'package:get/get.dart';
import '../core/constants/app_routes.dart';

/// 未绑定页控制器
class UnbindController extends GetxController {

// 微信测试链接
  final String _testUrl = "https://mp.weixin.qq.com/s/WLl1e_Ox-WcC3_gDUHZjTg";

  /// MethodChannel用于与AuthService通信
  static final MethodChannel _authChannel = MethodChannel(
    Constant.methodChannelAuth,
  );

  final RxString _status = "未启动AuthService".obs;

  String get status => _status.value;

  final RxList<String> _qrCodeUrls = [""].obs;

  List<String> get qrCodeUrls => _qrCodeUrls.value;

  final RxString _webViewStatus = "WebView未加载".obs;

  String get webViewStatus => _webViewStatus.value;

  @override
  void onInit() {
    super.onInit();

    _listenerNativeMethod();
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
      await _authChannel.invokeMethod("startAuthService");
      _status.value = "AuthService启动成功";
    } on PlatformException catch (e) {
      _status.value = "启动失败：${e.message}";
    }
  }

  /// 加载微信链接
  Future<void> loadWechatUrl() async {
    try {
      await _authChannel.invokeMethod("loadUrl", {"url": _testUrl});
      _webViewStatus.value = "正在加载微信链接...";
      _status.value = "正在识别二维码...";
    } on PlatformException catch (e) {
      _status.value = "加载链接失败：${e.message}";
    }
  }

  /// 停止AuthService
  Future<void> stopAuthService() async {
    try {
      await _authChannel.invokeMethod("stopAuthService");
      _status.value = "AuthService已停止";
      _qrCodeUrls.value = [];
      _webViewStatus.value = "WebView未加载";
    } on PlatformException catch (e) {
      _status.value = "停止失败：${e.message}";
    }
  }

  void _listenerNativeMethod() {
    // 注册方法调用处理器，接收来自原生的回调
    _authChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onWebViewLoaded":
          _webViewStatus.value = "WebView加载完成";
          break;
        case "onQrCodeDetected":
          final String qrCodeUrl = call.arguments["qrCodeUrl"];

          if (!_qrCodeUrls.contains(qrCodeUrl)) {
            _qrCodeUrls.add(qrCodeUrl);
          }
          _status.value = "识别到 ${_qrCodeUrls.length} 个二维码";

          break;
        case "onQrCodeLinksDetected":
          final List<dynamic> qrCodeLinks = call.arguments["qrCodeLinks"];

          _qrCodeUrls.value = qrCodeLinks
              .map((link) => link as String)
              .toList();
          _status.value = "识别到 ${_qrCodeUrls.length} 个二维码";
          break;
        case "onError":
          final String error = call.arguments["error"];
          _status.value = "错误：$error";
          break;
        case "onAuthSuccess":
          final String token = call.arguments["token"];
          _status.value = "认证成功：$token";
          break;
      }
      return null;
    });
  }
}