package org.dev.jesen.flut.flutter_custom_and_mix.channel

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import org.dev.jesen.flut.flutter_custom_and_mix.channel.auth.AuthServiceMethodChannel


// Channel注册管理器
object ChannelRegistry {
    fun registerWith(flutterEngine: FlutterEngine, context: Context) {
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        // UserMethodChannel.register(messenger, context)
        // PushEventChannel.register(messenger, context)
        AuthServiceMethodChannel.register(messenger, context)
    }
}