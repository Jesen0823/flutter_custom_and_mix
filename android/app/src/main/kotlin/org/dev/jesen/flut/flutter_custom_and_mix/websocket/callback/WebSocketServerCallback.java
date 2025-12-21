package org.dev.jesen.flut.flutter_custom_and_mix.websocket.callback;

/**
 * WebSocket服务器回调接口
 * 用于处理WebSocket服务器的各种事件
 */
public interface WebSocketServerCallback {
    
    /**
     * 客户端连接打开回调
     * @param clientId 客户端标识
     */
    void onClientConnected(String clientId);
    
    /**
     * 客户端消息接收回调
     * @param clientId 客户端标识
     * @param message 接收到的消息
     */
    void onClientMessage(String clientId, String message);
    
    /**
     * 客户端连接关闭回调
     * @param clientId 客户端标识
     * @param code 关闭代码
     * @param reason 关闭原因
     * @param remote 是否是远程关闭
     */
    void onClientDisconnected(String clientId, int code, String reason, boolean remote);
    
    /**
     * 客户端连接错误回调
     * @param clientId 客户端标识
     * @param ex 异常信息
     */
    void onClientError(String clientId, Exception ex);
    
    /**
     * 服务器启动成功回调
     */
    void onServerStarted();
    
    /**
     * 服务器关闭回调
     */
    void onServerStopped();
    
    /**
     * 服务器错误回调
     * @param ex 异常信息
     */
    void onServerError(Exception ex);
}