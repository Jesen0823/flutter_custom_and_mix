package org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin

// 注册PlatformView
class NativeViewPlugin: FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val registry = binding.platformViewRegistry
        // 注册PlatformViewFactory，参数=View的唯一标识,与Flutter端对应
        registry.registerViewFactory(
            "org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter/native_view",
            NativeViewFactory(binding.applicationContext)
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}