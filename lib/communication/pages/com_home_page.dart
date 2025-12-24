import 'package:flutter/material.dart';

import '../core/constants/app_styles.dart';

/// 首页（占位）
class ComHomePage extends StatelessWidget {
  const ComHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("首页"),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: const Center(
        child: Text(
          "已绑定账号，进入首页",
          style: TextStyle(
            fontSize: AppStyles.fontSizeXLarge,
            color: AppStyles.blackColor,
          ),
        ),
      ),
    );
  }
}