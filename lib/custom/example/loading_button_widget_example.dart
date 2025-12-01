import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/redefine_widget/loading_button_widget.dart';

class LoadingButtonWidgetExample extends StatelessWidget {
  const LoadingButtonWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("继承ElevatedButton扩展-带加载状态的按钮")),
      body: Center(
        child: LoadingButtonWidget(
          text: "提交订单",
          color: Colors.redAccent,
          onPressed: _mockRequest,
        ),
      ),
    );
  }

  Future<void> _mockRequest() async {
    await Future.delayed(const Duration(seconds: 3));
  }
}
