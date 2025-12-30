package org.dev.jesen.flut.flutter_custom_and_mix.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import org.dev.jesen.flut.flutter_custom_and_mix.R
import org.dev.jesen.flut.flutter_custom_and_mix.util.Constant
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.callback.WebSocketServerCallback
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.config.WebSocketConfig
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.MessageType
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.TextMessage
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.WebSocketMessage
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.server.WebSocketServerManager

/**
 * 主进程，WebSocket客户端
 * 使用WebSocketServerManager进行WebSocket服务管理
 */
class MiddleWebSocketService : Service(), WebSocketServerCallback {
    private var mWebSocketServerManager: WebSocketServerManager? = null
    private var mNotificationManager: NotificationManager? = null
    private var mNotificationBuilder: NotificationCompat.Builder? = null
    private var serviceReady = false // 远程Service是否启动

    private val localBinder = LocalBinder()
    private var serviceCallback: ServiceCallback? = null
    private var mClientId: String? = null // WebSocket客户端ID
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val TAG = "MiddleWebSocketService"
        private const val PORT: Int = Constant.WEBSOCKET_PORT // WebSocket监听端口 // 连接远程进程服务器
        private const val NOTIFICATION_ID = 10086 // 通知唯一ID
        private const val CHANNEL_ID = "websocket_client_channel" // 通知渠道ID
        private const val CHANNEL_NAME = "WebSocket跨进程通信服务" // 通知渠道名称
        private const val CHANNEL_DESCRIPTION = "用于主进程与远程进程的WebSocket通信" // 渠道描述
    }

    // Binder for clients to access service
    inner class LocalBinder : Binder() {
        fun getService(): MiddleWebSocketService = this@MiddleWebSocketService
    }

    override fun onCreate() {
        super.onCreate()
        // 1. 初始化通知管理器和Builder（适配多版本）
        initNotification()

        initWebSocketServer();

        // 启动子进程Service
        startService()
    }

    /**
     * 初始化并启动WebSocket服务器
     */
    private fun initWebSocketServer() {
        val serverConfig: WebSocketConfig.ServerConfig =
            WebSocketConfig.createDefaultServerConfig(PORT)
        mWebSocketServerManager = WebSocketServerManager(serverConfig, this)
        mWebSocketServerManager!!.startServer()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        return super.onStartCommand(intent, flags, startId)
    }

    override fun onBind(intent: Intent?): IBinder? {
        startForeground(NOTIFICATION_ID, mNotificationBuilder!!.build())
        return localBinder
    }

    override fun onUnbind(intent: Intent?): Boolean {
        stopForeground(true)
        return super.onUnbind(intent)
    }

    /**
     * 发送消息
     */
    fun sendSocketMessage(clientId: String, message: String): Boolean {
        if (!serviceReady) {
            return false
        }
        if (mWebSocketServerManager?.isClientConnected(clientId) == false) {
            Log.d(TAG, "sendSocketMessage：$clientId not connected")
            return false
        }
        return mWebSocketServerManager?.sendMessageToClient(clientId, message) ?: false
    }

    /**
     * 初始化通知（兼容API 23-36）
     */
    private fun initNotification() {
        mNotificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager?

        // 步骤1：API 26+创建通知渠道（必需，否则通知不显示）
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // 渠道重要性：IMPORTANCE_DEFAULT（默认，有声音无震动）
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            )
            channel.description = CHANNEL_DESCRIPTION
            channel.setSound(null, null) // 关闭通知声音（可选）
            // 注册渠道（API 26+必需）
            mNotificationManager!!.createNotificationChannel(channel)
        }

        // 步骤2：构建通知（使用NotificationCompat兼容低版本）
        mNotificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification) // 必需：通知图标（建议用vector资源）
            .setContentTitle("WebSocket服务运行中") // 通知标题
            .setContentText("等待主进程连接...") // 初始文案
            .setPriority(NotificationCompat.PRIORITY_DEFAULT) // 优先级（低版本生效）
            .setOngoing(true) // 禁止滑动取消（前台服务通知特性）
            .setAutoCancel(false) // 点击后不取消

        // API 31+适配：设置前台服务类型（与Manifest中声明一致）
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            mNotificationBuilder!!.setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
        }
    }

    fun startService() {
        val intent = Intent(this, AuthService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // 5 秒内调用startForeground()：使用startForegroundService()启动服务后，必须在5 秒内在服务内部调用startForeground()，否则系统会停止服务并抛出 ANR 异常
            startForegroundService(intent); // API 26+ 启动前台服务
        } else {
            startService(intent); // 低版本兼容
        }
        serviceReady = true
    }

    /**
     * 动态更新通知文案（Service内部调用，实时刷新状态）
     */
    private fun updateNotification(contentText: String?) {
        if (mNotificationBuilder == null || mNotificationManager == null) {
            return
        }
        // 修改通知内容并更新
        mNotificationBuilder!!.setContentText(contentText)
        mNotificationManager!!.notify(NOTIFICATION_ID, mNotificationBuilder!!.build())
    }

    override fun onDestroy() {
        super.onDestroy()
        // 释放WebSocket资源
        mWebSocketServerManager?.release()

        // 停止远程进程Service（可选）
        stopService(Intent(this, AuthService::class.java))
        serviceReady = false
    }

    /**
     * 处理AuthService回送事件
     * */
    private fun handleWebSocketMessage(message: WebSocketMessage) {
        Log.d(TAG, "handleMessage：$message")
        mainHandler.post {
            if (message.getType() == MessageType.TEXT) {
                if (message.getContent().startsWith("JsCallback")) {
                    serviceCallback?.onWebViewLoaded()
                } else if (message.getContent().startsWith("WebViewClient")) {
                    serviceCallback?.onQrCodeDetected("https://bpic.588ku.com/element_origin_min_pic/23/04/24/c1bbb824416621b59c4818e4de0d6bc7.jpg")
                }
            }
        }
    }

    /**
     * 来自Flutter的消息
     * */
    fun loadUrl(url: String) {
        if (mClientId != null) {
            sendSocketMessage(mClientId!!, url)
        } else {
            Log.d(TAG, "loadUrl：mClientId is null.")
        }
    }

    fun startAuthService() {
        sendSocketMessage(mClientId!!, "startAuthService")
    }

    fun stopAuthService() {
        sendSocketMessage(mClientId!!, "stopAuthService")
    }

    fun setCallback(callback: ServiceCallback) {
        serviceCallback = callback
    }

    /**
     * WebSocketServerCallback
     */
    override fun onClientConnected(clientId: String?) {
        Log.d(TAG, "主进程客户端连接成功：$clientId")
        mClientId = clientId
        // 更新通知：连接成功
        sendSocketMessage(clientId!!, "已经连接客户端:$clientId")
        updateNotification("主进程已连接，等待消息...")
    }

    override fun onClientMessageString(clientId: String?, message: String?) {
        Log.d(TAG, "onClientMessageString,主进程收到客户端String消息：$message")
        mClientId?.run { clientId }
        message?.let {
            handleWebSocketMessage(TextMessage(it))
            // 更新通知：收到消息
            updateNotification("主进程收到消息：$it")
        }
    }

    override fun onClientMessage(
        clientId: String?,
        message: WebSocketMessage?
    ) {
        Log.d(
            TAG,
            "onClientMessage,主进程收到客户端WebSocketMessage消息类型：${message?.getType()?.name}"
        )
        mClientId?.run { clientId }
        message?.let {
            handleWebSocketMessage(it)
            // 更新通知：收到消息
            updateNotification("主进程收到消息：${it.getContent()}")
        }
    }

    override fun onClientDisconnected(
        clientId: String?,
        code: Int,
        reason: String?,
        remote: Boolean
    ) {
        Log.d(TAG, "客户端断开WebSocket连接：$reason")
        updateNotification("客户端断开WebSocket连接：$reason")
    }

    override fun onClientError(clientId: String?, ex: Exception?) {
        Log.e(TAG, "连接客户端错误：" + clientId + ", exception: " + ex!!.message)
        updateNotification("连接客户端错误：" + ex.message)
    }

    override fun onServerStarted() {
        Log.d(TAG, "WebSocket服务器已启动，监听端口：$PORT")
        updateNotification("WebSocket服务器已启动，等待客户端连接...")
    }

    override fun onServerStopped() {
        Log.d(TAG, "WebSocket服务器已停止")
        updateNotification("WebSocket服务器已停止")
    }

    override fun onServerError(ex: Exception?) {
        Log.e(TAG, "服务器错误：${ex?.message ?: ""}")
        updateNotification("服务器异常：${ex?.message ?: ""}")
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
}