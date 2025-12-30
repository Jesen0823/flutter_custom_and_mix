package org.dev.jesen.flut.flutter_custom_and_mix.channel.methodchannel

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.dev.jesen.flut.flutter_custom_and_mix.service.AuthService
import org.dev.jesen.flut.flutter_custom_and_mix.service.MiddleWebSocketService
import org.dev.jesen.flut.flutter_custom_and_mix.util.Constant

/**
 * AuthService的MethodChannel实现，用于Flutter与AuthService通信
 */
object AuthServiceMethodChannel {
    private const val CHANNEL_NAME = Constant.METHOD_CHANNEL_AUTH
    private var context: Context? = null
    private var webSocketService: MiddleWebSocketService? = null
    private var channel: MethodChannel? = null
    private var isBound = false

    /**
     * 注册AuthService的MethodChannel
     */
    fun register(messenger: BinaryMessenger, appContext: Context) {
        context = appContext
        channel = MethodChannel(messenger, CHANNEL_NAME)
        channel?.setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }
    }

    /**
     * 处理Flutter调用的方法
     */
    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startAuthService" -> startAuthService(result)
            "loadUrl" -> loadUrl(call, result)
            "stopAuthService" -> stopAuthService(result)
            else -> result.notImplemented()
        }
    }

    /**
     * 启动AuthService并绑定
     */
    private fun startAuthService(result: MethodChannel.Result) {
        val context = context ?: run {
            result.error("CONTEXT_NULL", "Context is null", null)
            return
        }

        if (isBound) {
            result.success(true)
            return
        }

        val serviceIntent = Intent(context, AuthService::class.java)
        context.bindService(serviceIntent, serviceConnection, Context.BIND_AUTO_CREATE)
        webSocketService?.startAuthService()
        result.success(true)
    }

    /**
     * 加载指定URL
     */
    fun loadUrl(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url") ?: run {
            result.error("URL_NULL", "URL is null", null)
            return
        }

        if (!isBound || webSocketService == null) {
            result.error("SERVICE_NOT_BOUND", "AuthService is not bound", null)
            return
        }

        webSocketService?.loadUrl(url)
        result.success(true)
    }

    /**
     * 停止AuthService并解绑
     */
    private fun stopAuthService(result: MethodChannel.Result) {
        if (isBound) {
            webSocketService?.stopAuthService()
            context?.unbindService(serviceConnection)
            isBound = false
            webSocketService = null
        }
        result.success(true)
    }

    /**
     * 发送单个二维码检测结果到Flutter
     */
    fun sendQrCodeDetected(qrCodeUrl: String) {
        channel?.invokeMethod("onQrCodeDetected", mapOf("qrCodeUrl" to qrCodeUrl))
    }

    /**
     * 发送所有检测到的二维码链接到Flutter
     */
    fun sendQrCodeLinksDetected(links: List<String>) {
        channel?.invokeMethod("onQrCodeLinksDetected", mapOf("qrCodeLinks" to links))
    }

    /**
     * 发送WebView加载完成事件到Flutter
     */
    fun sendWebViewLoaded() {
        channel?.invokeMethod("onWebViewLoaded", null)
    }

    /**
     * 发送错误信息到Flutter
     */
    fun sendError(error: String) {
        channel?.invokeMethod("onError", mapOf("error" to error))
    }

    /**
     * 发送认证成功事件到Flutter
     */
    fun sendAuthSuccess(token: String) {
        channel?.invokeMethod("onAuthSuccess", mapOf("token" to token))
    }

    /**
     * Service连接回调
     */
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, serviceBinder: IBinder?) {
                val binder = serviceBinder as MiddleWebSocketService.LocalBinder
            webSocketService = binder.getService()
            isBound = true

            // 设置AuthService的回调
            webSocketService?.setCallback(object : MiddleWebSocketService.ServiceCallback {
                override fun onWebViewLoaded() {
                    sendWebViewLoaded()
                }

                override fun onJsMessageReceived(message: String) {
                    // 不需要处理JS消息
                }

                override fun onAuthSuccess(token: String) {
                    sendAuthSuccess(token)
                }

                override fun onQrCodeDetected(qrCodeUrl: String) {
                    sendQrCodeDetected(qrCodeUrl)
                }

                override fun onQrCodeLinksDetected(links: List<String>) {
                    sendQrCodeLinksDetected(links)
                }

                override fun onError(error: String) {
                    sendError(error)
                }
            })
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            isBound = false
            webSocketService = null
        }
    }
}