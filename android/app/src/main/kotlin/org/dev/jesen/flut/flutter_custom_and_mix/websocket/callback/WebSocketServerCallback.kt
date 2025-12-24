package org.dev.jesen.flut.flutter_custom_and_mix.websocket.callback

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
     * 客户端消息接收回调
     * @param clientId 客户端标识
     * @param message 接收到的消息
     */
    fun onClientMessage(clientId: String?, message: String?)

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