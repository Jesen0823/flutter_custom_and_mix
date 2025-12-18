package org.dev.jesen.flut.flutter_custom_and_mix.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.*
import androidx.core.app.NotificationCompat
import org.dev.jesen.flut.flutter_custom_and_mix.R
import org.dev.jesen.flut.flutter_custom_and_mix.util.webview.JsInterfaceManager
import org.dev.jesen.flut.flutter_custom_and_mix.util.webview.WebViewManager

/**
 * 认证服务，负责处理第三方登录鉴权
 * 采用前台Service模式运行，支持与客户端绑定通信
 */
class AuthService : Service(),
    WebViewManager.WebViewCallback,
    JsInterfaceManager.JsCallback {

    private val BINDER = LocalBinder()
    private lateinit var notificationManager: NotificationManager
    private var serviceCallback: ServiceCallback? = null
    private var webViewManager: WebViewManager? = null
    private var jsInterfaceManager: JsInterfaceManager? = null

    // Constants
    companion object {
        private const val CHANNEL_ID = "auth_service_channel"
        private const val NOTIFICATION_ID = 1
        private const val ACTION_STOP = "stop_service"
    }

    // Binder for clients to access service
    inner class LocalBinder : Binder() {
        fun getService(): AuthService = this@AuthService
    }

    // Callback interface for service-client communication
    interface ServiceCallback {
        fun onWebViewLoaded()
        fun onJsMessageReceived(message: String)
        fun onAuthSuccess(token: String)
        fun onQrCodeDetected(qrCodeUrl: String)
        fun onQrCodeLinksDetected(links: List<String>)
        fun onError(error: String)
    }

    override fun onCreate() {
        super.onCreate()
        initializeNotification()
        initializeWebViewManager()
        initializeJsInterfaceManager()
    }

    override fun onBind(intent: Intent?): IBinder? {
        startForeground(NOTIFICATION_ID, createNotification())
        return BINDER
    }

    override fun onUnbind(intent: Intent?): Boolean {
        stopForeground(true)
        return super.onUnbind(intent)
    }

    override fun onDestroy() {
        cleanupResources()
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
        }
        return START_STICKY
    }

    /**
     * 初始化通知相关组件
     */
    private fun initializeNotification() {
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
    }

    /**
     * 创建通知渠道（适配Android 8.0+）
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Auth Service Channel",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Channel for Authentication Service"
                lightColor = Color.BLUE
                enableLights(true)
                setShowBadge(false)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * 创建通知
     */
    private fun createNotification(): Notification {
        val stopIntent = Intent(this, AuthService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PendingIntent.getService(this, 0, stopIntent, PendingIntent.FLAG_IMMUTABLE)
        } else {
            PendingIntent.getService(this, 0, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.app_name))
            .setContentText("Authentication in progress...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setLargeIcon(BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher))
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .addAction(R.mipmap.ic_launcher, "Stop", stopPendingIntent)
            .build()
    }

    /**
     * 初始化WebView管理器
     */
    private fun initializeWebViewManager() {
        webViewManager = WebViewManager(this, this)
    }

    /**
     * 初始化JS交互管理器
     */
    private fun initializeJsInterfaceManager() {
        webViewManager?.let { manager ->
            jsInterfaceManager = JsInterfaceManager(manager.webView, this)
            jsInterfaceManager?.initJsInterface()
        }
    }

    /**
     * 清理资源
     */
    private fun cleanupResources() {
        // 清理JS交互管理器
        jsInterfaceManager?.let {
            it.removeJsInterface()
            jsInterfaceManager = null
        }

        // 清理WebView管理器
        webViewManager?.let {
            it.cleanup()
            webViewManager = null
        }
    }

    // Public methods for clients

    /**
     * 设置服务回调
     */
    fun setCallback(callback: ServiceCallback) {
        this.serviceCallback = callback
    }

    /**
     * 加载指定URL
     */
    fun loadUrl(url: String) {
        webViewManager?.loadUrl(url)
    }

    /**
     * 执行JavaScript代码
     */
    fun executeJavaScript(script: String) {
        jsInterfaceManager?.executeJavaScript(script) {
            serviceCallback?.onJsMessageReceived(it ?: "")
        }
    }

    /**
     * 识别页面中的二维码图片链接
     */
    fun detectQrCode() {
        jsInterfaceManager?.extractQrCodeImageLinks()
    }

    /**
     * 停止服务
     */
    fun stopService() {
        stopSelf()
    }

    // WebViewManager.WebViewCallback implementation

    override fun onPageFinished(url: String?) {
        serviceCallback?.onWebViewLoaded()
        // 页面加载完成后自动识别二维码
        detectQrCode()
    }

    override fun onReceivedError(error: String) {
        serviceCallback?.onError("WebView error: $error")
    }

    override fun onReceivedHttpError(url: String?, statusCode: Int, error: String) {
        serviceCallback?.onError("HTTP error ($statusCode): $error for URL: $url")
    }

    // JsInterfaceManager.JsCallback implementation

    override fun onAuthSuccess(token: String) {
        serviceCallback?.onAuthSuccess(token)
    }

    override fun onMessageReceived(message: String) {
        // 不再通过此方法处理二维码链接，改用onQrCodeLinksDetected
        serviceCallback?.onJsMessageReceived(message)
    }

    override fun onError(error: String) {
        serviceCallback?.onError("JS error: $error")
    }

    override fun onQrCodeLinksDetected(links: List<String>) {
        // 通知客户端检测到的所有二维码链接
        serviceCallback?.onQrCodeLinksDetected(links)
        
        // 同时为了向后兼容，对每个链接调用单个通知
        links.forEach {
            serviceCallback?.onQrCodeDetected(it)
        }
    }
}
