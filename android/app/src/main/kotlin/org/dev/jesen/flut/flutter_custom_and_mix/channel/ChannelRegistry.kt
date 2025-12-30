package org.dev.jesen.flut.flutter_custom_and_mix.channel

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import org.dev.jesen.flut.flutter_custom_and_mix.channel.methodchannel.AuthServiceMethodChannel
import org.dev.jesen.flut.flutter_custom_and_mix.channel.methodchannel.UserServiceMethodChannel

// Channel注册管理器
object ChannelRegistry {
    fun registerWith(flutterEngine: FlutterEngine, context: Context) {
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        AuthServiceMethodChannel.register(messenger, context)
        //PushEventChannel.register(messenger, context)
        UserServiceMethodChannel.register(messenger)
    }
}