import 'package:flutter/material.dart';
import '../render_object/rounded_circular_progress_bar.dart';

class RoundedProgressBarExample extends StatelessWidget {
  const RoundedProgressBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自定义RenderObject实现圆角环形进度条')),
      body: const Center(
        child: RoundedCircularProgressBar(
          progress: 0.7,
          strokeWidth: 8.0,
          progressColor: Colors.redAccent,
          radius: 40.0,
        ),
      ),
    );
  }
}
