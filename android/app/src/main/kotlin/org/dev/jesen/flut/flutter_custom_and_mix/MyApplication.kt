package org.dev.jesen.flut.flutter_custom_and_mix

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import org.dev.jesen.flut.flutter_custom_and_mix.channel.ChannelRegistry
import org.dev.jesen.flut.flutter_custom_and_mix.util.FlutterEngineManager

class MyApplication : Application() {
    lateinit var flutterEngine:FlutterEngine

    override fun onCreate() {
        super.onCreate()
        // 初始化FlutterEngin
        FlutterEngineManager.initFlutterEngin(this)

        flutterEngine = FlutterEngineManager.getFlutterEngine()!!

        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        // 注册Channel
        ChannelRegistry.registerWith(flutterEngine,this)
    }
}