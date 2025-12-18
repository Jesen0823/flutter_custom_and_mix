package org.dev.esen.flut.flutter_custom_and_mix.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

import org.dev.esen.flut.flutter_custom_and_mix.util.webview.WebViewManager
import org.dev.esen.flut.flutter_custom_and_mix.util.webview.JsInterfaceManager

/**
 * 鉴权服务类
 * 作为前台Service运行，负责管理WebView和JS交互，处理登录鉴权流程
 */
class AuthService : Service(), WebViewManager.WebViewCallback {

    companion object {
        private const val TAG = "AuthService"
        private const val CHANNEL_ID = "auth_service_channel"
        private const val NOTIFICATION_ID = 1001
    }

    // Service绑定器
    private val binder = LocalBinder()

    // 服务回调接口
    interface ServiceCallback {
        fun onWebViewLoaded()
        fun onQrCodeDetected(qrCodeUrls: List<String>)
        fun onAuthSuccess(token: String, userInfo: Map<String, Any>?)
        fun onAuthError(error: String)
    }

    // 内部绑定器类
    inner class LocalBinder : Binder() {
        fun getService(): AuthService = this@AuthService
    }

    private var serviceCallback: ServiceCallback? = null
    private var webViewManager: WebViewManager? = null
    private var jsInterfaceManager: JsInterfaceManager? = null
    private var isRunning = false

    // 设置服务回调
    fun setCallback(callback: ServiceCallback) {
        this.serviceCallback = callback
    }

    // 移除服务回调
    fun removeCallback() {
        this.serviceCallback = null
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "AuthService onCreate")
        isRunning = true
        initializeNotification()
        initializeWebViewManager()
    }

    override fun onBind(intent: Intent?): IBinder {
        Log.d(TAG, "AuthService onBind")
        return binder
    }

    override fun onUnbind(intent: Intent?): Boolean {
        Log.d(TAG, "AuthService onUnbind")
        return true
    }

    override fun onRebind(intent: Intent?) {
        Log.d(TAG, "AuthService onRebind")
        super.onRebind(intent)
    }

    override fun onDestroy() {
        Log.d(TAG, "AuthService onDestroy")
        isRunning = false
        cleanupResources()
        super.onDestroy()
    }

    // 初始化通知
    private fun initializeNotification() {
        createNotificationChannel()
        val notification = buildNotification()
        
        // 启动前台服务
        startForeground(NOTIFICATION_ID, notification)
    }

    // 创建通知渠道
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Auth Service Channel",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Authentication Service Channel"
                setShowBadge(true)
                // Android 12+ 适配
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    // 设置通知渠道的可见性
                    importance = NotificationManager.IMPORTANCE_HIGH
                    // 允许通知显示在锁屏上
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    // 允许通知闪光
                    setVibrationPattern(longArrayOf(100, 200, 300, 400))
                }
                // 确保通知声音可用
                setSound(null, null) // 使用默认声音
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    // 构建通知
    private fun buildNotification(): Notification {
        val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // API 30+ 需要使用 FLAG_IMMUTABLE
            PendingIntent.getActivity(
                this,
                0,
                Intent(this, Class.forName("io.flutter.embedding.android.FlutterActivity")),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
        } else {
            @Suppress("DEPRECATION")
            // API 30 以下使用传统 flag
            PendingIntent.getActivity(
                this,
                0,
                Intent(this, Class.forName("io.flutter.embedding.android.FlutterActivity")),
                PendingIntent.FLAG_UPDATE_CURRENT
            )
        }

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("flutter_custom_and_mix")
            .setContentText("Authentication Service is running")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setWhen(System.currentTimeMillis())

        // Android 11+ 适配
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            builder.setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
        }

        // Android 13+ 适配
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            builder.setCategory(NotificationCompat.CATEGORY_SERVICE)
        }

        return builder.build()
    }

    // 初始化WebView管理器
    private fun initializeWebViewManager() {
        webViewManager = WebViewManager(this.applicationContext, this)
        jsInterfaceManager = JsInterfaceManager(webViewManager!!.webView)
        
        // 初始化JS接口
        jsInterfaceManager?.initializeJsInterface()
        
        // 设置JS回调
        jsInterfaceManager?.setCallback(object : JsInterfaceManager.JsCallback {
            override fun onJsMessageReceived(message: String) {
                handleJsMessage(message)
            }

            override fun onJsFunctionCalled(functionName: String, params: Map<String, Any>?) {
                handleJsFunctionCall(functionName, params)
            }
        })
    }

    // 处理JS消息
    private fun handleJsMessage(message: String) {
        Log.d(TAG, "Received JS message: $message")
        // 可以根据消息内容进行处理
    }

    // 处理JS函数调用
    private fun handleJsFunctionCall(functionName: String, params: Map<String, Any>?) {
        Log.d(TAG, "JS function called: $functionName, params: $params")
        
        when (functionName) {
            "authSuccess" -> {
                val token = params?.get("token") as? String ?: ""
                serviceCallback?.onAuthSuccess(token, params)
            }
            "authError" -> {
                val error = params?.get("error") as? String ?: "Unknown error"
                serviceCallback?.onAuthError(error)
            }
            // 其他JS函数调用处理
        }
    }

    // 加载WebView页面
    fun loadUrl(url: String) {
        webViewManager?.loadUrl(url)
    }

    // 检测二维码
    fun detectQrCode() {
        webViewManager?.detectQrCodeLinks()
    }

    // 清理资源
    private fun cleanupResources() {
        serviceCallback?.let { removeCallback() }
        jsInterfaceManager?.let { it.cleanup() }
        webViewManager?.let { it.cleanup() }
        
        jsInterfaceManager = null
        webViewManager = null
    }

    // WebView回调实现
    override fun onPageStarted(url: String?) {
        Log.d(TAG, "WebView page started: $url")
    }

    override fun onPageFinished(url: String?) {
        Log.d(TAG, "WebView page finished: $url")
        serviceCallback?.onWebViewLoaded()
    }

    override fun onReceivedError(error: String) {
        Log.e(TAG, "WebView error: $error")
        serviceCallback?.onAuthError(error)
    }

    override fun onQrCodeLinksDetected(qrCodeUrls: List<String>) {
        Log.d(TAG, "Detected QR code links: $qrCodeUrls")
        serviceCallback?.onQrCodeDetected(qrCodeUrls)
    }
}
