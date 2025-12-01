import 'package:flutter/material.dart';

import '../platform_view/native_text_view.dart';

class NativePlatformViewExample extends StatelessWidget {
  const NativePlatformViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter嵌入原生视图")),
      body: const Center(
        child: Column(
          children: [
            Text("下面将会展示原生TextView:"),
            SizedBox(height: 16),
            SizedBox(
              width: 300,
              height: 100,
              child: NativeTextView(),
            ),
          ],
        ),
      ),
    );
  }
}
