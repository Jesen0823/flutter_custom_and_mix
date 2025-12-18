import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 测试AuthService的页面，用于加载微信链接并识别二维码
class AuthServiceTestPage extends StatefulWidget {
  const AuthServiceTestPage({super.key});

  @override
  State<AuthServiceTestPage> createState() => _AuthServiceTestPageState();
}

class _AuthServiceTestPageState extends State<AuthServiceTestPage> {
  /// MethodChannel用于与AuthService通信
  static const MethodChannel _authChannel = MethodChannel(
    'org.dev.jesen.flut.flutter_custom_and_mix/auth_service',
  );

  String _status = "未启动AuthService";
  List<String> _qrCodeUrls = [];
  String _webViewStatus = "WebView未加载";
  
  // 微信测试链接
  final String _testUrl = "https://mp.weixin.qq.com/s/WLl1e_Ox-WcC3_gDUHZjTg";

  @override
  void initState() {
    super.initState();
    
    // 注册方法调用处理器，接收来自原生的回调
    _authChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onWebViewLoaded":
          setState(() => _webViewStatus = "WebView加载完成");
          break;
        case "onQrCodeDetected":
          final String qrCodeUrl = call.arguments["qrCodeUrl"];
          setState(() {
            if (!_qrCodeUrls.contains(qrCodeUrl)) {
              _qrCodeUrls.add(qrCodeUrl);
            }
            _status = "识别到 ${_qrCodeUrls.length} 个二维码";
          });
          break;
        case "onQrCodeLinksDetected":
          final List<dynamic> qrCodeLinks = call.arguments["qrCodeLinks"];
          setState(() {
            _qrCodeUrls = qrCodeLinks.map((link) => link as String).toList();
            _status = "识别到 ${_qrCodeUrls.length} 个二维码";
          });
          break;
        case "onError":
          final String error = call.arguments["error"];
          setState(() => _status = "错误：$error");
          break;
        case "onAuthSuccess":
          final String token = call.arguments["token"];
          setState(() => _status = "认证成功：$token");
          break;
      }
      return null;
    });
  }

  /// 启动AuthService
  Future<void> _startAuthService() async {
    try {
      await _authChannel.invokeMethod("startAuthService");
      setState(() => _status = "AuthService启动成功");
    } on PlatformException catch (e) {
      setState(() => _status = "启动失败：${e.message}");
    }
  }

  /// 加载微信链接
  Future<void> _loadWechatUrl() async {
    try {
      await _authChannel.invokeMethod("loadUrl", {"url": _testUrl});
      setState(() {
        _webViewStatus = "正在加载微信链接...";
        _status = "正在识别二维码...";
      });
    } on PlatformException catch (e) {
      setState(() => _status = "加载链接失败：${e.message}");
    }
  }

  /// 停止AuthService
  Future<void> _stopAuthService() async {
    try {
      await _authChannel.invokeMethod("stopAuthService");
      setState(() {
        _status = "AuthService已停止";
        _qrCodeUrls = [];
        _webViewStatus = "WebView未加载";
      });
    } on PlatformException catch (e) {
      setState(() => _status = "停止失败：${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AuthService测试")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startAuthService,
                  child: const Text("启动AuthService"),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _loadWechatUrl,
                  child: const Text("加载微信链接并识别二维码"),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _stopAuthService,
                  child: const Text("停止AuthService"),
                ),
                const SizedBox(height: 30),
                Text(
                  "服务状态：$_status",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  "WebView状态：$_webViewStatus",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  "二维码链接：${_qrCodeUrls.isEmpty ? '未识别到二维码' : _qrCodeUrls.join('\n\n')}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _qrCodeUrls.isNotEmpty
                    ? Column(
                        children: _qrCodeUrls.map<Widget>((url) => Container(
                              width: 200,
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Image.network(
                                url,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Text(
                                      "图片加载失败",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                },
                              ),
                            )).toList(),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
