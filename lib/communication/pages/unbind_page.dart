import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/unbind_controller.dart';

/// 未绑定账号页（全屏弹窗）
class UnbindPage extends GetView<UnbindController> {
  const UnbindPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AuthService测试"),
        actions: [
          TextButton(
            onPressed: () => controller.goUserInfo(),
            child: const Text("个人信息"),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: controller.startAuthService,
                  child: const Text("启动AuthService"),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: controller.loadWechatUrl,
                  child: const Text("加载微信链接并识别二维码"),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: controller.stopAuthService,
                  child: const Text("停止AuthService"),
                ),
                const SizedBox(height: 30),
                Obx(() => Text(
                  "服务状态：${controller.status}",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 15),
                Obx(() => Text(
                  "WebView状态：${controller.webViewStatus}",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 15),
                Obx(() => Text(
                  "二维码链接：${controller.qrCodeUrls.isEmpty ? '未识别到二维码' : controller.qrCodeUrls.join('\n\n')}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 20),
                Obx(() => controller.qrCodeUrls.isNotEmpty
                    ? Column(
                        children: controller.qrCodeUrls
                            .map<Widget>(
                              (url) => Container(
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
                              ),
                            )
                            .toList(),
                      )
                    : const SizedBox()),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goComHomePage,
        child: const Icon(Icons.home, color: Colors.deepPurple),
      ),
    );
  }
}
