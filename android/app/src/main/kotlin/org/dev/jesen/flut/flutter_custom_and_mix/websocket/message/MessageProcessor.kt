package org.dev.jesen.flut.flutter_custom_and_mix.websocket.message

import java.lang.reflect.Type
/**
 * WebSocket消息处理器接口
 * 定义消息处理的通用方法，应用策略模式
 */
interface MessageProcessor {
    
    /**
     * 将对象转换为WebSocket消息
     */
    fun <T> toWebSocketMessage(obj: T): WebSocketMessage
    
    /**
     * 从WebSocket消息中解析对象
     */
    fun <T> fromWebSocketMessage(webSocketMessage: WebSocketMessage, type: Class<T>): T?
    
    /**
     * 从WebSocket消息中解析对象（支持泛型）
     */
    fun <T> fromWebSocketMessage(webSocketMessage: WebSocketMessage, type: Type): T?
}

