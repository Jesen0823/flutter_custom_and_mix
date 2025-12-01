import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/painter/custom_line_chart_painter.dart';

class CustomLineChartPainterExample extends StatelessWidget {
  const CustomLineChartPainterExample({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟金融收益数据
    final List<double> profitData = [10, 25, 15, 30, 20, 40, 35];

    return Scaffold(
      appBar: AppBar(title: const Text("自定义CustomPainter-绘制折线图")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: CustomPaint(
            painter: CustomLineChartPainter(data: profitData),
          ),
        ),
      ),
    );
  }
}
