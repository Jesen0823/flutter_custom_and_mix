package org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin

// 注册PlatformView
class NativeViewPlugin: FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val registry = binding.platformViewRegistry
        registry.registerViewFactory(
            "org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter/native_text_view",
            NativeViewFactory()
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}