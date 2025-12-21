package org.dev.jesen.flut.flutter_custom_and_mix.websocket.callback

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
     * 消息接收回调
     * @param message 接收到的消息
     */
    fun onMessage(message: String)
    
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