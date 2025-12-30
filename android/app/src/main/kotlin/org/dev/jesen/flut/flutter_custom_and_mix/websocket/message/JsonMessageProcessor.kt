package org.dev.jesen.flut.flutter_custom_and_mix.websocket.message

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import java.lang.reflect.Type

/**
 * JSON消息处理器
 * 提供JSON消息的序列化和反序列化功能
 * 实现WebSocketMessageProcessor接口，应用策略模式
 */
object JsonMessageProcessor : MessageProcessor {
    
    private val gson: Gson by lazy {
        GsonBuilder()
            .setDateFormat("yyyy-MM-dd HH:mm:ss")
            .create()
    }
    
    /**
     * 将对象转换为WebSocket JSON消息
     */
    override fun <T> toWebSocketMessage(obj: T): WebSocketMessage {
        return JsonMessage(toJson(obj))
    }
    
    /**
     * 从WebSocket消息中解析JSON对象
     */
    override fun <T> fromWebSocketMessage(webSocketMessage: WebSocketMessage, type: Class<T>): T? {
        if (webSocketMessage !is JsonMessage) {
            return null
        }
        
        return try {
            gson.fromJson(webSocketMessage.getContent(), type)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    /**
     * 从WebSocket消息中解析JSON对象（支持泛型）
     */
    override fun <T> fromWebSocketMessage(webSocketMessage: WebSocketMessage, type: Type): T? {
        if (webSocketMessage !is JsonMessage) {
            return null
        }
        
        return try {
            gson.fromJson(webSocketMessage.getContent(), type)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    /**
     * 直接将JSON字符串解析为对象
     */
    fun <T> parseFromString(json: String, type: Class<T>): T? {
        return try {
            gson.fromJson(json, type)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    /**
     * 将对象转换为JSON字符串
     */
    fun <T> toJson(obj: T): String {
        return gson.toJson(obj)
    }
}