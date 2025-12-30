package org.dev.jesen.flut.flutter_custom_and_mix.websocket.client

import android.os.Handler
import android.os.Looper
import android.util.Log
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.callback.WebSocketClientCallback
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.config.WebSocketConfig
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.JsonMessage
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.WebSocketMessage
import org.java_websocket.client.WebSocketClient
import org.java_websocket.handshake.ServerHandshake
import java.net.URI
import java.net.URISyntaxException
import java.nio.ByteBuffer
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService

/**
 * WebSocket客户端管理器
 * 封装WebSocket客户端的通用逻辑，包括连接管理、重连策略、消息发送等
 */
class WebSocketClientManager(
    private val config: WebSocketConfig.ClientConfig,
    private val callback: WebSocketClientCallback
) {
    
    private val TAG = WebSocketClientManager::class.java.simpleName
    
    private var webSocketClient: WebSocketClient? = null
    private var reconnectHandler: Handler = Handler(Looper.getMainLooper())
    private var reconnectExecutor: ScheduledExecutorService? = null
    private var reconnectCount = 0
    private var isReconnecting = false
    private var isConnected = false
    
    /**
     * 初始化并连接WebSocket
     */
    fun connect() {
        if (webSocketClient?.isOpen == true) {
            Log.d(TAG, "WebSocket already connected")
            return
        }
        
        try {
            val uri = URI(config.url)
            webSocketClient = object : WebSocketClient(uri) {
                override fun onOpen(handshakedata: ServerHandshake?) {
                    Log.d(TAG, "WebSocket connected successfully")
                    isConnected = true
                    resetReconnectState()
                    callback.onOpen()
                    callback.onConnectionStatusChanged(true)
                }
                
                override fun onMessage(message: String?) { // 文本消息
                    callback.onMessageString(message)
                    Log.d(TAG, "Received text message: $message")
                }

                override fun onMessage(bytes: ByteBuffer?) { // 二进制消息（JSON或Protobuf）
                    bytes?.let {
                        try {
                            val webSocketMessage = WebSocketMessage.fromBytes(it)
                            Log.d(TAG, "Received ${webSocketMessage.getType()} message")
                            callback.onMessageString(webSocketMessage)
                        } catch (e: Exception) {
                            Log.e(TAG, "Failed to parse message: ${e.message}", e)
                        }
                    }
                }
                
                override fun onClose(code: Int, reason: String?, remote: Boolean) {
                    Log.d(TAG, "WebSocket closed: code=$code, reason=$reason, remote=$remote")
                    isConnected = false
                    callback.onClose(code, reason.orEmpty(), remote)
                    callback.onConnectionStatusChanged(false)
                    
                    // 非主动关闭时触发重连
                    if (code != 1000 && !remote) {
                        startReconnect()
                    }
                }
                
                override fun onError(ex: Exception?) {
                    Log.e(TAG, "WebSocket error: ${ex?.message}")
                    isConnected = false
                    ex?.let { 
                        callback.onError(it)
                        callback.onConnectionStatusChanged(false)
                    }
                    startReconnect()
                }
            }
            
            // 在后台线程连接
            Executors.newSingleThreadExecutor().execute {
                webSocketClient?.connect()
            }
            
        } catch (e: URISyntaxException) {
            Log.e(TAG, "Invalid WebSocket URL: ${config.url}", e)
            callback.onError(e)
        }
    }
    
    /**
     * 发送文本消息
     * @param message 要发送的文本消息
     * @return 是否发送成功
     */
    fun sendString(message: String): Boolean {
        if (webSocketClient?.isOpen == true) {
            webSocketClient?.send(message)
            return true
        }
        Log.e(TAG, "Cannot send message, WebSocket is not connected")
        return false
    }
    
    /**
     * 发送WebSocket消息
     * @param message 要发送的WebSocket消息
     * @return 是否发送成功
     */
    fun sendString(message: WebSocketMessage): Boolean {
        if (webSocketClient?.isOpen == true) {
            val bytes = message.toBytes()
            webSocketClient?.send(bytes)
            return true
        }
        Log.e(TAG, "Cannot send message, WebSocket is not connected")
        return false
    }
    
    /**
     * 发送JSON对象
     * @param obj 要发送的JSON对象
     * @return 是否发送成功
     */
    fun sendJson(obj: Any): Boolean {
        return sendString(JsonMessage(obj))
    }
    
    /**
     * 发送JSON字符串
     * @param jsonStr 要发送的JSON字符串
     * @return 是否发送成功
     */
    fun sendJson(jsonStr: String): Boolean {
        return sendString(JsonMessage(jsonStr))
    }
    
    /**
     * 断开连接
     * @param code 关闭代码
     * @param reason 关闭原因
     */
    fun disconnect(code: Int = 1000, reason: String = "Normal closure") {
        stopReconnect()
        webSocketClient?.close(code, reason)
        webSocketClient = null
        isConnected = false
    }
    
    /**
     * 检查是否连接
     * @return 是否连接
     */
    fun isConnected(): Boolean {
        return webSocketClient?.isOpen == true
    }
    
    /**
     * 开始重连
     */
    private fun startReconnect() {
        if (isReconnecting || reconnectCount >= config.maxReconnectCount) {
            return
        }
        
        isReconnecting = true
        reconnectCount++
        
        // 计算重连间隔：指数退避策略
        val delay = (config.initialReconnectDelay * (1 shl (reconnectCount - 1))).coerceAtMost(config.maxReconnectDelay)
        Log.d(TAG, "Scheduling reconnect in ${delay}ms, attempt $reconnectCount/${config.maxReconnectCount}")
        
        reconnectHandler.postDelayed({
            reconnect()
        }, delay)
    }
    
    /**
     * 执行重连
     */
    private fun reconnect() {
        isReconnecting = false
        Log.d(TAG, "Attempting to reconnect...")
        connect()
    }
    
    /**
     * 停止重连
     */
    private fun stopReconnect() {
        isReconnecting = false
        reconnectHandler.removeCallbacksAndMessages(null)
    }
    
    /**
     * 重置重连状态
     */
    private fun resetReconnectState() {
        reconnectCount = 0
        isReconnecting = false
        reconnectHandler.removeCallbacksAndMessages(null)
    }
    
    /**
     * 释放资源
     */
    fun release() {
        stopReconnect()
        disconnect()
        reconnectExecutor?.shutdown()
    }
}