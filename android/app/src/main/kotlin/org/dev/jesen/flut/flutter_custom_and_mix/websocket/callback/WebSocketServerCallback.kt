package org.dev.jesen.flut.flutter_custom_and_mix.websocket.callback

import org.dev.jesen.flut.flutter_custom_and_mix.websocket.message.WebSocketMessage

/**
 * WebSocket服务器回调接口
 * 用于处理WebSocket服务器的各种事件
 */
interface WebSocketServerCallback {
    /**
     * 客户端连接打开回调
     * @param clientId 客户端标识
     */
    fun onClientConnected(clientId: String?)

    /**
     * 客户端文本消息接收回调（兼容旧版本）
     * @param clientId 客户端标识
     * @param message 接收到的文本消息
     */
    fun onClientMessageString(clientId: String?, message: String?)
    /**
     * 客户端WebSocket消息接收回调（支持多种消息类型）
     * @param clientId 客户端标识
     * @param message 接收到的WebSocket消息
     */
    fun onClientMessage(clientId: String?, message: WebSocketMessage?)

    /**
     * 客户端连接关闭回调
     * @param clientId 客户端标识
     * @param code 关闭代码
     * @param reason 关闭原因
     * @param remote 是否是远程关闭
     */
    fun onClientDisconnected(clientId: String?, code: Int, reason: String?, remote: Boolean)

    /**
     * 客户端连接错误回调
     * @param clientId 客户端标识
     * @param ex 异常信息
     */
    fun onClientError(clientId: String?, ex: Exception?)

    /**
     * 服务器启动成功回调
     */
    fun onServerStarted()

    /**
     * 服务器关闭回调
     */
    fun onServerStopped()

    /**
     * 服务器错误回调
     * @param ex 异常信息
     */
    fun onServerError(ex: Exception?)
}