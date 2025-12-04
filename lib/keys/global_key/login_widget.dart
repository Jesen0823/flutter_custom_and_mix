import 'package:flutter/material.dart';

/// 保存值展示组件（独立组件 + 绘制隔离 + ValueListenableBuilder）
class SavedFormValueWidget extends StatelessWidget {
  final ValueNotifier<Map<String, String?>> savedValueNotifier;

  const SavedFormValueWidget({super.key, required this.savedValueNotifier});

  @override
  Widget build(BuildContext context) {
    // 绘制边界：仅值变化时重绘此区域
    return RepaintBoundary(
      child: ValueListenableBuilder<Map<String, String?>>(
        valueListenable: savedValueNotifier,
        builder: (context, value, child) {
          final phone = value['phone'];
          final password = value['password'];
          if (phone == null) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "💾 已保存的表单值：手机号=$phone，密码=$password",
              style: const TextStyle(color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}

/// 功能按钮组，独立组件，避免表单变化时重绘
class FormActionButtons extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onReset;
  final VoidCallback onShowInfo;

  const FormActionButtons({
    super.key,
    required this.onLogin,
    required this.onReset,
    required this.onShowInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: onReset,
              child: const Text("重置表单", style: TextStyle(color: Colors.orange)),
            ),
            TextButton(
              onPressed: onShowInfo,
              child: const Text(
                "查看表单信息",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // 登录按钮
        ElevatedButton(
          onPressed: onLogin,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text("登录"),
        ),
      ],
    );
  }
}