package org.dev.jesen.flut.flutter_custom_and_mix.channel.methodchannel

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.dev.jesen.flut.flutter_custom_and_mix.channel.ChannelError
import org.dev.jesen.flut.flutter_custom_and_mix.channel.entity.UserInfo
import org.dev.jesen.flut.flutter_custom_and_mix.channel.entity.UserParam
import org.dev.jesen.flut.flutter_custom_and_mix.util.Constant
import org.dev.jesen.flut.flutter_custom_and_mix.util.GsonConvecter

object UserServiceMethodChannel {
    private const val CHANNEL_NAME = Constant.METHOD_CHANNEL_USER
    private var channel: MethodChannel? = null
    private val TAG ="UserMethodChannel"

    /**
     * 注册AuthService的MethodChannel
     */
    fun register(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, CHANNEL_NAME)
        channel?.setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }
    }

    /**
     * 处理Flutter调用的方法
     */
    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getUserInfoModel" -> getUserInfoModel(call,result)
            "getUserInfoJson" -> getUserInfoJson(call, result)
            "getUserInfoNoParam" -> getUserInfoNoParam(call, result)
            "getUserInfoString" -> getUserInfoString(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getUserInfoString(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        Log.d(TAG,"====getUserInfoString")
        // 模拟耗时操作
        Thread {
            try {
                // 模拟网络请求延迟
                Thread.sleep(1500)
                val param = call.arguments as? String?:""
                // 模拟参数校验
                if (param.isEmpty()) {
                    val error = ChannelError(1001, "参数错误：param不能为空")
                    result.success(GsonConvecter.toJson(error))
                    return@Thread
                }
                // 模拟返回用户信息
                result.success("UserID:0000")
            } catch (e: Exception) {
                val error = ChannelError(1003, "原生错误：${e.message}")
                result.success(GsonConvecter.toJson(error))
            }
        }.start()
    }

    private fun getUserInfoNoParam(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG,"====getUserInfoNoParam")
        // 模拟耗时操作
        Thread {
            try {
                // 模拟网络请求延迟
                Thread.sleep(1000)
                // 模拟返回用户信息
                val userInfo = UserInfo("default_id", "默认用户", 25)
                result.success(GsonConvecter.toJson(userInfo))
            } catch (e: Exception) {
                val error = ChannelError(1003, "原生错误：${e.message}")
                result.success(GsonConvecter.toJson(error))
            }
        }.start()
    }

    private fun getUserInfoJson(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        Log.d(TAG,"====getUserInfoJson")
        // 模拟耗时操作
        Thread {
            try {
                // 模拟网络请求延迟
                Thread.sleep(2000)
                val param = call.arguments as? String?:""
                // 模拟参数校验
                if (param.isEmpty()) {
                    val error = ChannelError(1001, "参数错误：param不能为空")
                    result.success(GsonConvecter.toJson(error))
                    return@Thread
                }
                // 模拟返回用户信息
                val userInfo = UserInfo(param.length.toString(), "测试用户_${param}", 12)
                result.success(GsonConvecter.toJson<UserInfo>(userInfo))
            } catch (e: Exception) {
                val error = ChannelError(1003, "原生错误：${e.message}")
                result.success(GsonConvecter.toJson(error))
            }
        }.start()
    }

    private fun getUserInfoModel(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG,"====getUserInfoModel")
        // 模拟耗时操作
        Thread {
            try {
                // 模拟网络请求延迟
                Thread.sleep(2500)
                val param = GsonConvecter.fromJson(GsonConvecter.toJson(call.arguments), UserParam::class.java)
                // 模拟参数校验
                if (param.userId.isEmpty() || param.token.isEmpty()) {
                    val error = ChannelError(1001, "参数错误：userId或token不能为空")
                    result.success(GsonConvecter.toJson(error))
                    return@Thread
                }
                // 模拟Token校验
                if (param.token != "test_token_2024") {
                    val error = ChannelError(2001, "Token无效或过期")
                    result.success(GsonConvecter.toJson(error))
                    return@Thread
                }
                // 模拟返回用户信息
                val userInfo = UserInfo(param.userId, "测试用户_${param.userId}", 28)
                result.success(GsonConvecter.toJson(userInfo))
            } catch (e: Exception) {
                val error = ChannelError(1003, "原生错误：${e.message}")
                result.success(GsonConvecter.toJson(error))
            }
        }.start()
    }
}