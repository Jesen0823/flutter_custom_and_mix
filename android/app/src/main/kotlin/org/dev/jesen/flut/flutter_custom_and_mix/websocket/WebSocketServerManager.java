package org.dev.jesen.flut.flutter_custom_and_mix.websocket;

import android.util.Log;
import org.dev.jesen.androidwebsocket.websocket.callback.WebSocketServerCallback;
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.config.WebSocketConfig;
import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;

import java.net.InetSocketAddress;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebSocket服务器管理器
 * 封装WebSocket服务器的通用逻辑，包括服务器启动、停止、客户端连接管理等
 */
public class WebSocketServerManager {

    private static final String TAG = WebSocketServerManager.class.getSimpleName();
    
    private final WebSocketConfig.ServerConfig config;
    private final WebSocketServerCallback callback;
    private WebSocketServer webSocketServer;
    private final Map<String, WebSocket> clientConnections = new ConcurrentHashMap<>();
    private boolean isServerStarted = false;

    /**
     * 构造函数
     * @param config 服务器配置
     * @param callback 回调接口
     */
    public WebSocketServerManager(WebSocketConfig.ServerConfig config, WebSocketServerCallback callback) {
        this.config = config;
        this.callback = callback;
    }

    /**
     * 启动WebSocket服务器
     */
    public void startServer() {
        if (isServerStarted) {
            Log.d(TAG, "WebSocket server is already started");
            return;
        }

        try {
            webSocketServer = new WebSocketServer(new InetSocketAddress(config.getPort())) {
                @Override
                public void onOpen(WebSocket conn, ClientHandshake handshake) {
                    String clientId = getClientId(conn);
                    // 支持重复连接：替换旧连接
                    if (clientConnections.containsKey(clientId) && clientConnections.get(clientId).isOpen()) {
                        clientConnections.get(clientId).close(1000, "New connection established, closing old connection");
                    }
                    clientConnections.put(clientId, conn);
                    Log.d(TAG, "Client connected: " + clientId);
                    callback.onClientConnected(clientId);
                }

                @Override
                public void onClose(WebSocket conn, int code, String reason, boolean remote) {
                    String clientId = getClientId(conn);
                    if (clientConnections.remove(clientId) != null) {
                        Log.d(TAG, "Client disconnected: " + clientId + ", reason: " + reason);
                        callback.onClientDisconnected(clientId, code, reason, remote);
                    }
                }

                @Override
                public void onMessage(WebSocket conn, String message) {
                    String clientId = getClientId(conn);
                    Log.d(TAG, "Received message from " + clientId + ": " + message);
                    callback.onClientMessage(clientId, message);
                }

                @Override
                public void onError(WebSocket conn, Exception ex) {
                    String clientId = conn != null ? getClientId(conn) : "unknown";
                    Log.e(TAG, "Client error: " + clientId + ", exception: " + ex.getMessage());
                    callback.onClientError(clientId, ex);
                }

                @Override
                public void onStart() {
                    Log.d(TAG, "WebSocket server started on port " + config.getPort());
                    isServerStarted = true;
                    callback.onServerStarted();
                }
            };

            // 启动服务器
            webSocketServer.start();
            Log.d(TAG, "WebSocket server starting on port " + config.getPort());

        } catch (Exception e) {
            Log.e(TAG, "Failed to start WebSocket server", e);
            callback.onServerError(e);
        }
    }

    /**
     * 停止WebSocket服务器
     */
    public void stopServer() {
        if (!isServerStarted || webSocketServer == null) {
            Log.d(TAG, "WebSocket server is not started");
            return;
        }

        try {
            // 关闭所有客户端连接
            for (WebSocket conn : clientConnections.values()) {
                if (conn.isOpen()) {
                    conn.close(1000, "Server is shutting down");
                }
            }
            clientConnections.clear();

            // 停止服务器
            webSocketServer.stop();
            isServerStarted = false;
            Log.d(TAG, "WebSocket server stopped");
            callback.onServerStopped();

        } catch (Exception e) {
            Log.e(TAG, "Failed to stop WebSocket server", e);
            callback.onServerError(e);
        }
    }

    /**
     * 发送消息给指定客户端
     * @param clientId 客户端标识
     * @param message 要发送的消息
     * @return 是否发送成功
     */
    public boolean sendMessageToClient(String clientId, String message) {
        WebSocket conn = clientConnections.get(clientId);
        if (conn != null && conn.isOpen()) {
            conn.send(message);
            Log.d(TAG, "Sent message to " + clientId + ": " + message);
            return true;
        }
        Log.e(TAG, "Cannot send message to client " + clientId + ", connection not found or closed");
        return false;
    }

    /**
     * 发送消息给所有客户端
     * @param message 要发送的消息
     * @return 发送成功的客户端数量
     */
    public int broadcastMessage(String message) {
        int sentCount = 0;
        for (WebSocket conn : clientConnections.values()) {
            if (conn.isOpen()) {
                conn.send(message);
                sentCount++;
            }
        }
        Log.d(TAG, "Broadcast message sent to " + sentCount + " clients: " + message);
        return sentCount;
    }

    /**
     * 获取当前连接的客户端数量
     * @return 客户端数量
     */
    public int getConnectedClientCount() {
        return clientConnections.size();
    }

    /**
     * 检查客户端是否连接
     * @param clientId 客户端标识
     * @return 是否连接
     */
    public boolean isClientConnected(String clientId) {
        WebSocket conn = clientConnections.get(clientId);
        return conn != null && conn.isOpen();
    }

    /**
     * 获取客户端连接
     * @param clientId 客户端标识
     * @return WebSocket连接对象
     */
    public WebSocket getClientConnection(String clientId) {
        return clientConnections.get(clientId);
    }

    /**
     * 服务器是否已启动
     * @return 是否已启动
     */
    public boolean isServerStarted() {
        return isServerStarted;
    }

    /**
     * 生成客户端唯一标识
     * @param conn WebSocket连接
     * @return 客户端标识
     */
    private String getClientId(WebSocket conn) {
        return conn.getRemoteSocketAddress().toString();
    }

    /**
     * 释放资源
     */
    public void release() {
        stopServer();
        clientConnections.clear();
        webSocketServer = null;
    }
}