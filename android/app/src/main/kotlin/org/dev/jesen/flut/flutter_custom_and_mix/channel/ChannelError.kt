package org.dev.jesen.flut.flutter_custom_and_mix.channel
// 统一错误模型
data class ChannelError(
    val code: Int,
    val message: String,
    val extra: Map<String, Any>? = null
)
