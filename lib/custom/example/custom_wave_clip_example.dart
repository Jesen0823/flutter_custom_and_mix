import 'package:flutter/material.dart';

import '../render_object/custom_wave_clip.dart';

class CustomWaveClipExample extends StatelessWidget {
  const CustomWaveClipExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("自定义RenderObject实现波浪剪裁")),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 5.0,
                blurStyle: BlurStyle.normal,
              ),
            ],
          ),
          child: const SizedBox(
            width: 300,
            height: 200,
            child: CustomWaveClip(
              waveHeight: 30.0,
              waveCount: 4,
              child: Image(
                image: NetworkImage(
                  "https://fastly.picsum.photos/id/367/300/200.jpg?hmac=K6EKIeaLka1ZzMouoJwfIyU3_CLUfPQjlcMr3KHgARk",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
