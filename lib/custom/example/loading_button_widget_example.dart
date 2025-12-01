import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/redefine_widget/loading_button_widget.dart';

class LoadingButtonWidgetExample extends StatelessWidget {
  const LoadingButtonWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("继承ElevatedButton扩展-带加载状态的按钮"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 同步回调示例
            LoadingButtonWidget(
              text: "同步提交订单（立即完成）",
              activeColor: Colors.green,
              onPressed: _mockRequestSync,
            ),
            const SizedBox(height: 16),
            // 异步回调示例
            LoadingButtonWidget(
              text: "异步提交订单（3秒后完成）",
              activeColor: Colors.blue,
              onPressed: _mockRequestAsync,
              disableDuplicateClick: true, // 启用防重复点击
            ),
            const SizedBox(height: 16),
            // 禁用状态示例（无onPressed回调）
            LoadingButtonWidget(text: "禁用状态（无回调）", onPressed: null),
          ],
        ),
      ),
    );
  }

  /// 示例1：同步回调（返回void）
  void _mockRequestSync() {
    debugPrint("同步回调执行完成");
    // 生产环境：同步业务逻辑（如本地数据存储、状态更新等）
  }

  /// 示例2：异步回调（返回Future<void>）
  Future<void> _mockRequestAsync() async {
    // 模拟接口请求（生产环境替换为真实API调用）
    await Future.delayed(const Duration(seconds: 3));
    debugPrint("异步回调执行完成");
    // 可选：抛出异常测试异常处理
    // throw Exception("模拟接口请求失败");
  }
}
