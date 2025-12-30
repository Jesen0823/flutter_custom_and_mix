package org.dev.jesen.flut.flutter_custom_and_mix.websocket.server

import android.util.Log
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.callback.WebSocketServerCallback
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.config.WebSocketConfig
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.JsonMessage
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.WebSocketMessage
import org.java_websocket.WebSocket
import org.java_websocket.handshake.ClientHandshake
import org.java_websocket.server.WebSocketServer
import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.util.concurrent.ConcurrentHashMap

/**
 * WebSocket服务器管理器
 * 封装WebSocket服务器的通用逻辑，包括服务器启动、停止、客户端连接管理等
 */
class WebSocketServerManager(
    private val config: WebSocketConfig.ServerConfig,
    private val callback: WebSocketServerCallback
) {
    private var webSocketServer: WebSocketServer? = null
    private val clientConnections: MutableMap<String?, WebSocket> =
        ConcurrentHashMap<String?, WebSocket>()

    /**
     * 服务器是否已启动
     * @return 是否已启动
     */
    var isServerStarted: Boolean = false
        private set

    /**
     * 启动WebSocket服务器
     */
    fun startServer() {
        if (isServerStarted) {
            Log.d(TAG, "WebSocket server is already started")
            return
        }

        try {
            webSocketServer = object : WebSocketServer(InetSocketAddress(config.port)) {
                override fun onOpen(conn: WebSocket, handshake: ClientHandshake?) {
                    val clientId = getClientId(conn)
                    // 支持重复连接：替换旧连接
                    if (clientConnections.containsKey(clientId) && clientConnections.get(clientId)!!
                            .isOpen()
                    ) {
                        clientConnections.get(clientId)!!
                            .close(1000, "New connection established, closing old connection")
                    }
                    clientConnections.put(clientId, conn)
                    Log.d(TAG, "Client connected: " + clientId)
                    callback.onClientConnected(clientId)
                }

                override fun onClose(conn: WebSocket, code: Int, reason: String?, remote: Boolean) {
                    val clientId = getClientId(conn)
                    if (clientConnections.remove(clientId) != null) {
                        Log.d(TAG, "Client disconnected: " + clientId + ", reason: " + reason)
                        callback.onClientDisconnected(clientId, code, reason, remote)
                    }
                }

                override fun onMessage(conn: WebSocket, message: String?) {
                    val clientId = getClientId(conn)
                    Log.d(TAG, "Received text message from $clientId: $message")
                    callback.onClientMessageString(clientId, message)
                }

                override fun onMessage(conn: WebSocket, message: ByteBuffer?) {
                    val clientId = getClientId(conn)
                    try {
                        val webSocketMessage: WebSocketMessage = WebSocketMessage.fromBytes(message)
                        Log.d(
                            TAG,
                            "Received " + webSocketMessage.getType() + " message from " + clientId
                        )
                        callback.onClientMessage(clientId, webSocketMessage)
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to parse message from " + clientId + ": " + e.message, e)
                    }
                }

                override fun onError(conn: WebSocket?, ex: Exception) {
                    val clientId = if (conn != null) getClientId(conn) else "unknown"
                    Log.e(TAG, "Client error: " + clientId + ", exception: " + ex.message)
                    callback.onClientError(clientId, ex)
                }

                override fun onStart() {
                    Log.d(TAG, "WebSocket server started on port " + config.port)
                    isServerStarted = true
                    callback.onServerStarted()
                }
            }

            // 启动服务器
            webSocketServer?.start()
            Log.d(TAG, "WebSocket server starting on port " + config.port)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start WebSocket server", e)
            callback.onServerError(e)
        }
    }

    /**
     * 停止WebSocket服务器
     */
    fun stopServer() {
        if (!isServerStarted || webSocketServer == null) {
            Log.d(TAG, "WebSocket server is not started")
            return
        }

        try {
            // 关闭所有客户端连接
            for (conn in clientConnections.values) {
                if (conn.isOpen()) {
                    conn.close(1000, "Server is shutting down")
                }
            }
            clientConnections.clear()

            // 停止服务器
            webSocketServer?.stop()
            isServerStarted = false
            Log.d(TAG, "WebSocket server stopped")
            callback.onServerStopped()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop WebSocket server", e)
            callback.onServerError(e)
        }
    }

    /**
     * 发送文本消息给指定客户端
     * @param clientId 客户端标识
     * @param message 要发送的文本消息
     * @return 是否发送成功
     */
    fun sendMessageToClient(clientId: String?, message: String?): Boolean {
        val conn = clientConnections.get(clientId)
        if (conn != null && conn.isOpen()) {
            conn.send(message)
            Log.d(TAG, "Sent text message to " + clientId + ": " + message)
            return true
        }
        Log.e(TAG, "Cannot send message to client " + clientId + ", connection not found or closed")
        return false
    }

    /**
     * 发送WebSocket消息给指定客户端
     * @param clientId 客户端标识
     * @param message 要发送的WebSocket消息
     * @return 是否发送成功
     */
    fun sendMessageToClient(clientId: String?, message: WebSocketMessage): Boolean {
        val conn = clientConnections.get(clientId)
        if (conn != null && conn.isOpen()) {
            val bytes: ByteBuffer? = message.toBytes()
            conn.send(bytes)
            Log.d(TAG, "Sent " + message.getType() + " message to " + clientId)
            return true
        }
        Log.e(TAG, "Cannot send message to client " + clientId + ", connection not found or closed")
        return false
    }

    /**
     * 发送JSON对象给指定客户端
     * @param clientId 客户端标识
     * @param obj 要发送的JSON对象
     * @return 是否发送成功
     */
    fun sendJsonToClient(clientId: String?, obj: Any?): Boolean {
        return obj?.let {
            sendMessageToClient(clientId, JsonMessage(it))
        } ?: false
    }

    /**
     * 发送JSON字符串给指定客户端
     * @param clientId 客户端标识
     * @param jsonStr 要发送的JSON字符串
     * @return 是否发送成功
     */
    fun sendJsonToClient(clientId: String?, jsonStr: String?): Boolean {
        return jsonStr?.let {
            sendMessageToClient(clientId, JsonMessage(it))
        } ?: false
    }

    /**
     * 发送文本消息给所有客户端
     * @param message 要发送的文本消息
     * @return 发送成功的客户端数量
     */
    fun broadcastMessage(message: String?): Int {
        var sentCount = 0
        for (conn in clientConnections.values) {
            if (conn.isOpen()) {
                conn.send(message)
                sentCount++
            }
        }
        Log.d(TAG, "Broadcast text message sent to " + sentCount + " clients: " + message)
        return sentCount
    }

    /**
     * 发送WebSocket消息给所有客户端
     * @param message 要发送的WebSocket消息
     * @return 发送成功的客户端数量
     */
    fun broadcastMessage(message: WebSocketMessage): Int {
        var sentCount = 0
        val bytes: ByteBuffer? = message.toBytes()
        for (conn in clientConnections.values) {
            if (conn.isOpen()) {
                conn.send(bytes)
                sentCount++
            }
        }
        Log.d(TAG, "Broadcast " + message.getType() + " message sent to " + sentCount + " clients")
        return sentCount
    }

    /**
     * 发送JSON对象给所有客户端
     * @param obj 要发送的JSON对象
     * @return 发送成功的客户端数量
     */
    fun broadcastJson(obj: Any?): Int {
        return obj?.let { broadcastMessage(JsonMessage(it)) } ?: 0
    }

    /**
     * 发送JSON字符串给所有客户端
     * @param jsonStr 要发送的JSON字符串
     * @return 发送成功的客户端数量
     */
    fun broadcastJson(jsonStr: String?): Int {
        return jsonStr?.let { broadcastMessage(JsonMessage(it)) } ?: 0
    }

    val connectedClientCount: Int
        /**
         * 获取当前连接的客户端数量
         * @return 客户端数量
         */
        get() = clientConnections.size

    /**
     * 检查客户端是否连接
     * @param clientId 客户端标识
     * @return 是否连接
     */
    fun isClientConnected(clientId: String?): Boolean {
        val conn = clientConnections.get(clientId)
        return conn != null && conn.isOpen()
    }

    /**
     * 获取客户端连接
     * @param clientId 客户端标识
     * @return WebSocket连接对象
     */
    fun getClientConnection(clientId: String?): WebSocket? {
        return clientConnections.get(clientId)
    }

    /**
     * 生成客户端唯一标识
     * @param conn WebSocket连接
     * @return 客户端标识
     */
    private fun getClientId(conn: WebSocket): String {
        return conn.remoteSocketAddress.toString()
    }

    /**
     * 释放资源
     */
    fun release() {
        stopServer()
        clientConnections.clear()
        webSocketServer = null
    }

    companion object {
        private val TAG: String = WebSocketServerManager::class.java.getSimpleName()
    }
}