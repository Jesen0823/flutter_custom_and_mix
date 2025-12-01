import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/custom/render_object/custom_tag_flow_layout.dart';

class CustomTagFlowLayoutExample extends StatelessWidget {
  const CustomTagFlowLayoutExample({super.key});

  final List<String> tags = const [
    "Flutter3.0",
    "自定义RenderObject实现",
    "流式布局",
    "dart",
    "可指定间距",
    "MultiChildRenderObjectWidget",
    "RenderBox",
    "with",
    "ContainerRenderObjectMixin",
    "RenderBoxContainerDefaultsMixin",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("自定义RenderObject实现流式布局")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomTagFlowLayout(
          horizontalSpacing: 12.0,
          verticalSpacing: 12.0,
          lineHeight: 36.0,
          mainAxisAlignment: MainAxisAlignment.start,
          children: tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.pink.withAlpha(120),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                tag,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blue),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
