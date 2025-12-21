package org.dev.jesen.flut.flutter_custom_and_mix.websocket.config

/**
 * WebSocket配置类
 * 集中管理WebSocket客户端和服务器的配置参数
 */
class WebSocketConfig private constructor() {
    
    /**
     * WebSocket客户端配置
     */
    data class ClientConfig(
        val url: String,
        val maxReconnectCount: Int = DEFAULT_MAX_RECONNECT_COUNT,
        val initialReconnectDelay: Long = DEFAULT_INITIAL_RECONNECT_DELAY,
        val maxReconnectDelay: Long = DEFAULT_MAX_RECONNECT_DELAY,
        val connectionTimeout: Int = DEFAULT_CONNECTION_TIMEOUT
    )
    
    /**
     * WebSocket服务器配置
     */
    data class ServerConfig(
        val port: Int,
        val maxConnections: Int = DEFAULT_MAX_CONNECTIONS
    )
    
    companion object {
        // 默认配置参数
        const val DEFAULT_MAX_RECONNECT_COUNT = 10
        const val DEFAULT_INITIAL_RECONNECT_DELAY = 1000L // 1秒
        const val DEFAULT_MAX_RECONNECT_DELAY = 8000L // 8秒
        const val DEFAULT_CONNECTION_TIMEOUT = 5000 // 5秒
        const val DEFAULT_MAX_CONNECTIONS = 10
        
        /**
         * 创建默认客户端配置
         */
        @JvmStatic
        fun createDefaultClientConfig(url: String): ClientConfig {
            return ClientConfig(
                url = url,
                maxReconnectCount = DEFAULT_MAX_RECONNECT_COUNT,
                initialReconnectDelay = DEFAULT_INITIAL_RECONNECT_DELAY,
                maxReconnectDelay = DEFAULT_MAX_RECONNECT_DELAY,
                connectionTimeout = DEFAULT_CONNECTION_TIMEOUT
            )
        }
        
        /**
         * 创建默认服务器配置
         */
        @JvmStatic
        fun createDefaultServerConfig(port: Int): ServerConfig {
            return ServerConfig(
                port = port,
                maxConnections = DEFAULT_MAX_CONNECTIONS
            )
        }
    }
}