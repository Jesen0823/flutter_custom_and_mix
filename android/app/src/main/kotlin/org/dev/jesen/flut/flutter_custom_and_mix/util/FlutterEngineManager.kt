package org.dev.jesen.flut.flutter_custom_and_mix.util

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * 创建`FlutterEngineManager`管理FlutterEngine，减少内存开销
 * */
object FlutterEngineManager {
    private const val ENGINE_ID = "my_flutter_engine"

    // 初始化并缓存FlutterEngine
    fun initFlutterEngin(context: Context){
        val flutterEngin = FlutterEngine(context)
        // 执行Flutter的入口函数（main.dart中的runApp）
        flutterEngin.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        // 缓存Engine，供全局使用
        FlutterEngineCache.getInstance().put(ENGINE_ID,flutterEngin)
    }

    // 获取缓存的FlutterEngine
    fun getFlutterEngine() = FlutterEngineCache.getInstance().get(ENGINE_ID)
}

/**
 * Activity中可以借助FlutterFragment:
 * // 获取缓存的FlutterEngine
 *         val flutterEngine = FlutterEngineManager.getFlutterEngine()
 *         // 创建FlutterFragment
 *         val flutterFragment = FlutterFragment.withCachedEngine("my_flutter_engine")
 *             .build()
 *
 *         // 将FlutterFragment添加到容器中
 *         supportFragmentManager.beginTransaction()
 *             .replace(R.id.flutter_container, flutterFragment)
 *             .commit()
 *
 * */