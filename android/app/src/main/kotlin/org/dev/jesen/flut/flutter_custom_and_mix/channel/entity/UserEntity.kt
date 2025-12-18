package org.dev.jesen.flut.flutter_custom_and_mix.channel.entity

// 实体类
data class UserParam(val userId: String, val token: String)
data class UserInfo(val userId: String, val username: String, val age: Int)
data class PushEvent(val pushId: String, val title: String, val content: String, val type: Int)
data class ChannelError(val code: Int, val message: String, val extra: Map<String, Any>? = null)