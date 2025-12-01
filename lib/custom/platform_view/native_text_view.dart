import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 自定义PlatformView：嵌入Android原生TextView
class NativeTextView extends StatelessWidget {
  const NativeTextView({super.key});

  @override
  Widget build(BuildContext context) {
    // 区分平台：Android使用AndroidView，iOS使用UiKitView
    return Platform.isAndroid
        ? AndroidView(
            viewType:
                "org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter/native_text_view",
            layoutDirection: TextDirection.ltr,
            creationParams: const {},
            creationParamsCodec: const StandardMessageCodec(),
          )
        : const Center(child: Text("IOS原生视图"));
  }
}
