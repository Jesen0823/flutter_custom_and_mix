package org.dev.jesen.flut.flutter_custom_and_mix.websocket.message

import com.google.gson.Gson
import java.nio.ByteBuffer

/**
 * WebSocket消息类型枚举
 */
enum class MessageType {
    TEXT,    // 纯文本消息
    JSON   // JSON格式消息
}

/**
 * WebSocket消息抽象类
 * 所有消息类型的基类
 */
abstract class WebSocketMessage {
    
    /**
     * 获取消息类型
     */
    abstract fun getType(): MessageType
    
    /**
     * 将消息转换为发送格式
     */
    abstract fun toBytes(): ByteBuffer

    abstract fun getContent(): String
    
    companion object {
        val gson = Gson()
        
        /**
         * 根据消息内容自动解析消息类型
         */
        @JvmStatic
        fun fromBytes(data: ByteBuffer?): WebSocketMessage {
            // 简单实现：根据内容格式判断消息类型
            // 在实际应用中，可能需要更复杂的协议头来标识消息类型
            if (data == null) return TextMessage("")
            data.rewind()
            val bytes = ByteArray(data.remaining())
            data.get(bytes)
            
            // 尝试解析为JSON
            try {
                val jsonStr = String(bytes)
                if (jsonStr.startsWith("{") && jsonStr.endsWith("}")) {
                    return JsonMessage(jsonStr)
                }
            } catch (e: Exception) {
                // 不是JSON
            }
            
            // 默认为文本消息
            data.rewind()
            return TextMessage(String(bytes))
        }
    }
}

/**
 * 文本消息实现
 */
class TextMessage(private val content: String) : WebSocketMessage() {
    override fun getType(): MessageType = MessageType.TEXT
    
    override fun toBytes(): ByteBuffer {
        return ByteBuffer.wrap(content.toByteArray())
    }
    
    override fun getContent(): String {
        return content
    }
}

/**
 * JSON消息实现
 */
class JsonMessage(private val content: String) : WebSocketMessage() {
    override fun getType(): MessageType = MessageType.JSON
    
    override fun toBytes(): ByteBuffer {
        return ByteBuffer.wrap(content.toByteArray())
    }
    
    override fun getContent(): String {
        return content
    }
    
    /**
     * 将对象转换为JSON消息
     */
    constructor(obj: Any) : this(gson.toJson(obj))
}

