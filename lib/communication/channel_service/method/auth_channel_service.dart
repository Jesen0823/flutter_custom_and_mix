import 'package:flutter_custom_and_mix/communication/channel/base_method_channel.dart';
import 'package:flutter_custom_and_mix/communication/channel/channel_manager.dart';
import 'package:flutter_custom_and_mix/communication/utils/app_logger.dart';
import 'package:flutter_custom_and_mix/communication/utils/constant.dart';

/// Auth原生回调接口
abstract class IAuthCallback {
  void onWebViewLoaded();
  void onQrCodeDetected(String qrCodeUrl);
  void onQrCodeLinksDetected(List<String> qrCodeLinks);
  void onError(String error);
  void onAuthSuccess(String token);
}

/// 绑定/鉴权模块通信Service（业务层接口）
abstract class IAuthChannelService {
  /// 启动AuthService
  Future<void> startAuthService();

  /// 加载微信链接
  Future<void> loadWebUrl({required String url});

  /// 停止AuthService
  Future<void> stopAuthService();

  /// 注册原生回调
  void registerCallback(IAuthCallback callback);

  /// 取消注册原生回调
  void unregisterCallback();
}

/// 绑定/鉴权模块通信实现（依赖底层Channel）
class AuthChannelServiceImpl implements IAuthChannelService {
  final BaseMethodChannel _channel = ChannelManager().getMethodChannel(
    channelName: Constant.methodChannelAuth,
  );
  IAuthCallback? _callback;

  @override
  Future<void> startAuthService() async {
    return _channel.invokeMethod(
      method: 'startAuthService',
      resultConverter: (result) {
        AppLogger().d(
          "auth_channel_service,startAuthService, result type: ${result.runtimeType}, result:$result",
        );
      },
    );
  }

  @override
  Future<void> loadWebUrl({required String url}) async {
    return _channel.invokeMethod(
      method: 'loadUrl',
      params: Map.of({'url':url}),
      resultConverter: (result) {
        AppLogger().d(
          "auth_channel_service,loadWebUrl, result type: ${result.runtimeType}, result:$result",
        );
      },
    );
  }

  @override
  Future<void> stopAuthService() async {
    return _channel.invokeMethod(
      method: 'stopAuthService',
      resultConverter: (result) {
        AppLogger().d(
          "auth_channel_service,stopAuthService, result type: ${result.runtimeType}, result:$result",
        );
      },
    );
  }

  @override
  void registerCallback(IAuthCallback callback) {
    _callback = callback;
    print("===== AuthChannelServiceImpl: Callback registered");
    
    _channel.registerMethodHandler(
      method: 'onWebViewLoaded',
      handler: (params) async {
        print("===== AuthChannelServiceImpl: Received onWebViewLoaded callback");
        _callback?.onWebViewLoaded();
      },
    );
    
    _channel.registerMethodHandler(
      method: 'onQrCodeDetected',
      handler: (params) async {
        print("===== AuthChannelServiceImpl: Received onQrCodeDetected callback, params: $params");
        final String qrCodeUrl = params['qrCodeUrl'];
        _callback?.onQrCodeDetected(qrCodeUrl);
      },
    );
    
    _channel.registerMethodHandler(
      method: 'onQrCodeLinksDetected',
      handler: (params) async {
        print("===== AuthChannelServiceImpl: Received onQrCodeLinksDetected callback, params: $params");
        final List<dynamic> qrCodeLinks = params['qrCodeLinks'];
        _callback?.onQrCodeLinksDetected(qrCodeLinks.cast<String>());
      },
    );
    
    _channel.registerMethodHandler(
      method: 'onError',
      handler: (params) async {
        print("===== AuthChannelServiceImpl: Received onError callback, params: $params");
        final String error = params['error'];
        _callback?.onError(error);
      },
    );
    
    _channel.registerMethodHandler(
      method: 'onAuthSuccess',
      handler: (params) async {
        print("===== AuthChannelServiceImpl: Received onAuthSuccess callback, params: $params");
        final String token = params['token'];
        _callback?.onAuthSuccess(token);
      },
    );
  }

  @override
  void unregisterCallback() {
    _callback = null;
  }
}
