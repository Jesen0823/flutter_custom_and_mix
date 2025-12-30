package org.dev.jesen.flut.flutter_custom_and_mix.util

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.JsonPrimitive
import com.google.gson.JsonSerializationContext
import com.google.gson.JsonSerializer
import com.google.gson.TypeAdapter
import com.google.gson.TypeAdapterFactory
import com.google.gson.reflect.TypeToken
import com.google.gson.stream.JsonReader
import com.google.gson.stream.JsonWriter
import java.lang.reflect.Type
import java.math.BigDecimal

// 序列化工具（使用Gson）
object GsonConvecter {
    private val gson = GsonBuilder()
        .serializeNulls()
        .registerTypeAdapter(Double::class.java, DoubleSerializer())
        .registerTypeAdapter(Double::class.java, DoubleDeserializer())
        .create()

    fun <T> toJson(obj: T): Map<String, Any> {
        val jsonString = gson.toJson(obj)
        val type = object : TypeToken<Map<String, Any>>() {}.type
        val jsonMap = gson.fromJson<Map<String, Any>>(jsonString, type)
        // 转换Map中的Double为Int（如果是整数）
        return convertDoubleToInt(jsonMap)
    }

    fun <T> fromJson(json: Map<String, Any>, clazz: Class<T>): T {
        return gson.fromJson(gson.toJson(json), clazz)
    }

    // 自定义Double序列化器，将整数Double转为Int
    private class DoubleSerializer : JsonSerializer<Double> {
        override fun serialize(src: Double?, typeOfSrc: Type?, context: JsonSerializationContext?): JsonElement? {
            src?.let {
                // 如果是整数，则序列化为Int
                if (src == src.toLong().toDouble()) {
                    return JsonPrimitive(src.toLong())
                }
                return JsonPrimitive(src)
            }
            return null
        }
    }

    // 自定义Double反序列化器，将整数Double转为Int
    private class DoubleDeserializer : JsonDeserializer<Double> {
        override fun deserialize(json: JsonElement?, typeOfT: Type?, context: JsonDeserializationContext?): Double? {
            json?.let {
                return json.asDouble
            }
            return null
        }
    }

    // 处理Map<String, Any>中Double转Int的问题
    private fun convertDoubleToInt(map: Map<String, Any>): Map<String, Any> {
        val result = HashMap<String, Any>()
        for ((key, value) in map) {
            when (value) {
                is Double -> {
                    // 如果是整数，则转为Int
                    if (value == value.toLong().toDouble()) {
                        result[key] = value.toLong().toInt()
                    } else {
                        result[key] = value
                    }
                }
                is Map<*, *> -> {
                    // 递归处理嵌套Map
                    @Suppress("UNCHECKED_CAST")
                    result[key] = convertDoubleToInt(value as Map<String, Any>)
                }
                is List<*> -> {
                    // 处理List
                    val list = mutableListOf<Any>()
                    for (item in value) {
                        when (item) {
                            is Double -> {
                                if (item == item.toLong().toDouble()) {
                                    list.add(item.toLong().toInt())
                                } else {
                                    list.add(item)
                                }
                            }
                            is Map<*, *> -> {
                                @Suppress("UNCHECKED_CAST")
                                list.add(convertDoubleToInt(item as Map<String, Any>))
                            }
                            else -> {
                                list.add(item!!)
                            }
                        }
                    }
                    result[key] = list
                }
                else -> {
                    result[key] = value
                }
            }
        }
        return result
    }
}