package org.dev.esen.flut.flutter_custom_and_mix

import android.app.Application
import android.util.Log

class MyApplication : Application() {

    companion object {
        private const val TAG = "MyApplication"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "MyApplication onCreate")
        
        // 初始化应用程序级别的资源
        initializeAppResources()
    }

    // 初始化应用程序资源
    private fun initializeAppResources() {
        // 这里可以初始化全局资源，如：
        // - 初始化网络请求库
        // - 初始化日志库
        // - 初始化数据库
        // - 初始化其他第三方库
    }
}
