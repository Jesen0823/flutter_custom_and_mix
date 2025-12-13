import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 自定义PlatformView：嵌入Android原生View
class InsertNativeView extends StatelessWidget {
  const InsertNativeView({super.key});

  @override
  Widget build(BuildContext context) {
    // 区分平台：Android使用AndroidView，iOS使用UiKitView
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter中嵌入原生View"),),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 8),
        color: Colors.pinkAccent.shade100,
        child: Center(
          child: Platform.isAndroid
              ? AndroidView(
            viewType:
            "org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter/native_view",
            layoutDirection: TextDirection.ltr,
            creationParams: const {"param": "flutter_param"},
            creationParamsCodec: const StandardMessageCodec(),
          )
              : const Text("IOS原生视图"),
        ),
      ),
    );
  }
}
