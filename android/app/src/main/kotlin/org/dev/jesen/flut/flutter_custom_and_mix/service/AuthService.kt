package org.dev.jesen.flut.flutter_custom_and_mix.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import org.dev.jesen.flut.flutter_custom_and_mix.R
import org.dev.jesen.flut.flutter_custom_and_mix.util.Constant
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.callback.WebSocketClientCallback
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.client.WebSocketClientManager
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.config.WebSocketConfig
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.JsonMessage
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.MessageType
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.TextMessage
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.WebSocketMessage
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.server.WebSocketServerManager
import org.dev.jesen.flut.flutter_custom_and_mix.webview.JsInterfaceManager
import org.dev.jesen.flut.flutter_custom_and_mix.webview.WebViewManager

/**
 * 认证服务，负责处理第三方登录鉴权
 * 采用前台Service模式运行
 */
class AuthService : Service(), WebViewManager.WebViewCallback, JsInterfaceManager.JsCallback,
    WebSocketClientCallback {

    private var mWebSocketClientManager: WebSocketClientManager? = null
    private lateinit var mNotificationManager: NotificationManager
    private lateinit var mNotificationBuilder: NotificationCompat.Builder
    private var webViewManager: WebViewManager? = null
    private var jsInterfaceManager: JsInterfaceManager? = null
    private val webSocketUrl: String = "ws://localhost:${Constant.WEBSOCKET_PORT}" // 连接远程进程服务器
    private var mCurrentStatus: String = "初始化中..."
    private val mainHandle = Handler(Looper.getMainLooper())

    // Constants
    companion object {
        private const val TAG: String = "AuthService"
        private const val CHANNEL_ID = "auth_service_channel"
        private const val NOTIFICATION_ID = 10087
        private const val ACTION_STOP = "stop_service"
        private const val CHANNEL_NAME: String = "Auth跨进程通信服务" // 通知渠道名称
        private const val CHANNEL_DESCRIPTION: String = "用于主进程与远程进程的Auth通信" // 渠道描述
    }

    override fun onCreate() {
        super.onCreate()

        // 1. 初始化通知管理器和Builder（适配多版本）
        initNotification()

        // 2. 初始化并启动WebSocket服务器管理器
        initWebSocketClient()

        initializeWebViewManager()
        initializeJsInterfaceManager()
    }

    private fun initWebSocketClient() {
        val config = WebSocketConfig.ClientConfig(
            webSocketUrl
        )
        mWebSocketClientManager = WebSocketClientManager(config, this)
        mWebSocketClientManager?.connect()
    }

    override fun onBind(intent: Intent?): IBinder? {
        startForeground(NOTIFICATION_ID, mNotificationBuilder.build())
        return null
    }

    override fun onUnbind(intent: Intent?): Boolean {
        stopForeground(true)
        return super.onUnbind(intent)
    }

    override fun onDestroy() {
        cleanupResources()
        super.onDestroy()

        // 关闭WebSocket服务器并释放资源
        mWebSocketClientManager?.release()
        mWebSocketClientManager =null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
        }
        val notificationId = NOTIFICATION_ID
        startForeground(notificationId, mNotificationBuilder.build())
        return START_STICKY
    }

    /**
     * 初始化通知相关组件
     */
    private fun initNotification() {
        mNotificationManager =
            (getSystemService(android.content.Context.NOTIFICATION_SERVICE) as NotificationManager?)!!

        // 步骤1：API 26+创建通知渠道（必需，否则通知不显示）
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // 渠道重要性：IMPORTANCE_DEFAULT（默认，有声音无震动）
            val channel = NotificationChannel(
                CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_DEFAULT
            )
            channel.description = CHANNEL_DESCRIPTION
            channel.setSound(null, null) // 关闭通知声音（可选）
            // 注册渠道（API 26+必需）
            mNotificationManager.createNotificationChannel(channel)
        }

        // 步骤2：构建通知（使用NotificationCompat兼容低版本）
        val stopIntent = Intent(this, AuthService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PendingIntent.getService(this, 0, stopIntent, PendingIntent.FLAG_IMMUTABLE)
        } else {
            PendingIntent.getService(this, 0, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        }
        mNotificationBuilder = NotificationCompat.Builder(
            this, CHANNEL_ID
        ).setSmallIcon(R.drawable.ic_notification) // 必需：通知图标（建议用vector资源）
            .setContentTitle("Auth服务运行中") // 通知标题
            .setContentText("鉴权中...") // 初始文案
            .setPriority(NotificationCompat.PRIORITY_DEFAULT) // 优先级（低版本生效）
            .setOngoing(true) // 禁止滑动取消（前台服务通知特性）
            .setAutoCancel(false) // 点击后不取消
            .addAction(R.mipmap.ic_launcher, "Stop", stopPendingIntent)


        // API 31+适配：设置前台服务类型（与Manifest中声明一致）
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            mNotificationBuilder.setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
        }
    }

    /**
     * 动态更新通知文案（Service内部调用，实时刷新状态）
     */
    private fun updateNotification(contentText: String?) {
        // 修改通知内容并更新
        mNotificationBuilder.setContentText(contentText)
        mNotificationManager.notify(
            NOTIFICATION_ID, mNotificationBuilder.build()
        )
    }

    /**
     * 更新Service状态
     */
    private fun updateServiceStatus(status: String) {
        mCurrentStatus = status
        updateNotification(contentText = status)
        Log.d(TAG, "Service 状态: $status")
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
            Log.d(TAG, "js注入")
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

    override fun onPageStarted(url: String?) {
        sendWebSocketMessage("WebViewClient:PageStarted")
    }

    override fun onPageFinished(url: String?) {
        sendWebSocketMessage("WebViewClient:onPageFinished")
        // 页面加载完成后自动识别二维码
        detectQrCode()
    }

    override fun onReceivedError(error: String) {
        sendWebSocketMessage("WebViewClient:onReceivedError:$error")
    }

    override fun onReceivedHttpError(url: String?, statusCode: Int, error: String) {
        sendWebSocketMessage("WebViewClient:onReceivedHttpError error ($statusCode): $error for URL: $url")
    }

    // JsInterfaceManager.JsCallback implementation

    override fun onAuthSuccess(token: String) {
        updateServiceStatus("鉴权成功")
        sendWebSocketMessage("JsCallback:onAuthSuccess:$token")
    }

    override fun onAuthSuccess(token: String, userInfo: Map<String, Any>?) {
        updateServiceStatus("鉴权成功")
        sendWebSocketMessage("JsCallback:onAuthSuccess:$token")
    }

    override fun onJsFunctionCalled(functionName: String, params: Map<String, Any>?) {
        // Handle JS function calls if needed
        updateServiceStatus("方法${functionName}调用完成")
        sendWebSocketMessage("JsCallback:onJsFunctionCalled:$functionName")
    }

    override fun onMessageReceived(message: String) {
        // 不再通过此方法处理二维码链接，改用onQrCodeLinksDetected
        updateServiceStatus("收到二维码")
        sendWebSocketMessage("JsCallback:onMessageReceived:$message")
    }

    override fun onError(error: String) {
        updateServiceStatus("ERROR:$error")
        sendWebSocketMessage("JsCallback:onError:$error")
    }

    override fun onQrCodeLinksDetected(links: List<String>) {
        updateServiceStatus("收到${links.size}条二维码")
        // 通知客户端检测到的所有二维码链接
        //serviceCallback?.onQrCodeLinksDetected(links)
        // 同时为了向后兼容，对每个链接调用单个通知
        links.forEach {
            sendWebSocketMessage("JsCallback:onQrCodeDetected:$it")
        }
    }

    /**
     * 处理主进程的WebSocket消息
     */
    private fun handleWebSocketMessage(message: WebSocketMessage?) {
        if (message != null && message.getType() == MessageType.TEXT) {
            mainHandle.post {
                when {
                    message.getContent() == "startAuthService" -> Log.e(TAG, "handleWebSocketMessage, 已经启动")
                    message.getContent() == "stopAuthService" -> stopSelf()
                    message.getContent().startsWith("http") -> loadUrl(message.getContent())
                    else -> {}//result.notImplemented()
                }
            }
        }
    }

    /**
     * 向主进程的WebSocket服务端发送消息
     */
    private fun sendWebSocketMessage(message: String) {
        mWebSocketClientManager?.sendString(message)
    }

    override fun onOpen() {
        Log.d(TAG, "WebSocket客户端连接成功")
    }

    override fun onMessageString(message: WebSocketMessage) {
        sendWebSocketMessage("己收到消息:$message")
        handleWebSocketMessage(message)
    }

    override fun onClose(code: Int, reason: String, remote: Boolean) {
        Log.d(TAG, "WebSocket连接断开：$reason")
    }

    override fun onError(ex: Exception) {
        Log.d(TAG, "WebSocket连接失败：${ex.message}")
    }

    override fun onConnectionStatusChanged(isConnected: Boolean) {
        val status = if (isConnected) "已连接" else "未连接"
        Log.d(TAG, "WebSocket连接状态：$status")
    }
}