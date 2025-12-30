package org.dev.jesen.flut.flutter_custom_and_mix.websocket.callback

import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.TextMessage
import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.WebSocketMessage

/**
 * WebSocket客户端回调接口
 * 用于处理WebSocket连接的各种事件
 */
interface WebSocketClientCallback {
    
    /**
     * 连接打开回调
     */
    fun onOpen()
    
    /**
     * 文本消息接收回调（兼容旧版本）
     * @param message 接收到的文本消息
     */
    fun onMessageString(message: String?) {
        // 默认实现，将文本消息转换为WebSocketMessage
        message?.let { onMessageString(TextMessage(it)) }
    }
    
    /**
     * WebSocket消息接收回调（支持多种消息类型）
     * @param message 接收到的WebSocket消息
     */
    fun onMessageString(message: WebSocketMessage)
    
    /**
     * 连接关闭回调
     * @param code 关闭代码
     * @param reason 关闭原因
     * @param remote 是否是远程关闭
     */
    fun onClose(code: Int, reason: String, remote: Boolean)
    
    /**
     * 连接错误回调
     * @param ex 异常信息
     */
    fun onError(ex: Exception)
    
    /**
     * 连接状态变化回调
     * @param isConnected 是否连接
     */
    fun onConnectionStatusChanged(isConnected: Boolean)
}