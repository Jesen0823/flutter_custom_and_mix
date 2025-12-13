import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Flutter端（Dart）创建MethodChannel并调用原生方法
/// 需要在原生端注册MethodChannel并处理调用
class FlutCallNativePage extends StatefulWidget {
  const FlutCallNativePage({super.key});

  @override
  State<FlutCallNativePage> createState() => _FlutCallNativePageState();
}

class _FlutCallNativePageState extends State<FlutCallNativePage> {
  /// 1. MethodChannel相关：
  // 创建MethodChannel，命名需唯一,建议使用包名+通道名
  static const MethodChannel _methodChannel = MethodChannel(
    'org.dev.jesen.flut.flutter_custom_and_mix/native_method',
  );
  String _nativeResult = "未调用原生方法";

  // 主动调用Android原生
  Future<void> _callNativeMethod() async {
    try {
      final String result = await _methodChannel.invokeMethod(
        "getAndroidDeviceInfo",
        {'param1': 'flutter_PARAM', 'param2': 1022},
      );
      setState(() => _nativeResult = result);
    } on PlatformException catch (e) {
      // 捕获原生抛出的异常
      setState(() => _nativeResult = "call FAILED:${e.message}");
    }
  }

  /// 2. EventChannel相关：
  static const EventChannel _eventChannel = EventChannel(
    'org.dev.jesen.flut.flutter_custom_and_mix/native_event',
  );
  StreamSubscription? _eventSubscription;
  String _eventData = "未接收原生事件";

  @override
  void initState() {
    super.initState();
    // 注册方法调用处理器，接收原生的调用
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "flutterShowToast":
          // 获取原生传递的参数
          final String msg = call.arguments["msg"];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.thumb_up, color: Colors.red),
                  Text(msg),
                ],
              ),
            ),
          );
          return "Toast显示成功"; // 返回结果给原生
        default:
          throw MissingPluginException("未实现的方法：${call.method}");
      }
    });

    // EventChannel
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (data) {
        setState(() => _eventData = data.toString());
      },
      onError: (error) {
        setState(() => _eventData = "事件错误：$error");
      },
      onDone: () {
        setState(() => _eventData = "事件流结束");
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter调用原生")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _callNativeMethod,
              child: const Text("调用原生，获取设备信息"),
            ),
            const SizedBox(height: 20),
            Text("原生返回结果：$_nativeResult"),
            const SizedBox(height: 20),
            Text("源源不断接收原生的流事件：$_eventData"),
          ],
        ),
      ),
    );
  }
}
