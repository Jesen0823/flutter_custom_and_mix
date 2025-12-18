package org.dev.jesen.flut.flutter_custom_and_mix.channel.user

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.dev.jesen.flut.flutter_custom_and_mix.channel.ChannelError
import org.dev.jesen.flut.flutter_custom_and_mix.channel.entity.UserInfo
import org.dev.jesen.flut.flutter_custom_and_mix.channel.entity.UserParam

// 用户模块MethodChannel实现
// object UserMethodChannel {
//     private const val CHANNEL_NAME = "com.example.flutter_app/user"
//     private val gson = Gson()

//     fun register(messenger: BinaryMessenger, context: Context) {
//         MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
//             when (call.method) {
//                 "getUserInfo" -> getUserInfo(call, result)
//                 else -> result.notImplemented()
//             }
//         }
//     }

//     private fun getUserInfo(call: MethodCall, result: MethodChannel.Result) {
//         try {
//             val param = gson.fromJson(gson.toJson(call.arguments), UserParam::class.java)
//             // 模拟参数校验
//             if (param.userId.isEmpty() || param.token.isEmpty()) {
//                 val error = ChannelError(1001, "参数错误：userId或token不能为空")
//                 result.success(gson.toJson(error))
//                 return
//             }
//             // 模拟Token校验
//             if (param.token != "test_token_2024") {
//                 val error = ChannelError(2001, "Token无效或过期")
//                 result.success(gson.toJson(error))
//                 return
//             }
//             // 模拟返回用户信息
//             val userInfo = UserInfo(param.userId, "测试用户_${param.userId}", 28)
//             result.success(gson.toJson(userInfo))
//         } catch (e: Exception) {
//             val error = ChannelError(1003, "原生错误：${e.message}")
//             result.success(gson.toJson(error))
//         }
//     }

//     // 模拟原生触发退出登录（可在任意地方调用，如Token过期时）
//     fun triggerLogout(flutterEngine: FlutterEngine) {
//         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
//             .invokeMethod("onLogout", null)
//     }
// }