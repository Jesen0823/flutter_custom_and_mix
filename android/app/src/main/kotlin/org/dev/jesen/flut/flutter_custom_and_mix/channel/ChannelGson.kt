package org.dev.jesen.flut.flutter_custom_and_mix.channel

// 序列化工具（使用Gson）
 object ChannelGson {
     private val gson = GsonBuilder()
         .serializeNulls()
         .create()

     fun <T> toJson(obj: T): Map<String, Any> {
         return gson.fromJson(gson.toJson(obj), object : TypeToken<Map<String, Any>>() {}.type)
     }

     fun <T> fromJson(json: Map<String, Any>?, clazz: Class<T>): T? {
         if (json == null) return null
         return gson.fromJson(gson.toJson(json), clazz)
     }
 }