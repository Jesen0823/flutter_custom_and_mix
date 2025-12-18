package org.dev.jesen.flut.flutter_custom_and_mix.channel.user

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
// import org.dev.jesen.flut.flutter_custom_and_mix.channel.entity.PushEvent

// object PushEventChannel {
//     private const val CHANNEL_NAME = "com.example.flutter_app/push"
//     private val gson = Gson()
//     private var eventSink: MethodChannel.Result? = null

//     fun register(messenger: BinaryMessenger, context: Context) {
//         MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
//             eventSink = result
//             // 模拟3秒后推送一条消息
//             Thread {
//                 Thread.sleep(3000)
//                 val pushEvent = PushEvent(
//                     pushId = "push_1001",
//                     title = "系统通知",
//                     content = "您的账号已登录3天，可领取新手福利",
//                     type = 1
//                 )
//                 eventSink?.success(gson.toJson(pushEvent))
//             }.start()
//         }
//     }

//     // 模拟推送业务消息
//     fun sendBusinessPush() {
//         val pushEvent = PushEvent(
//             pushId = "push_1002",
//             title = "业务消息",
//             content = "您的订单已发货，物流单号：SF123456789",
//             type = 2
//         )
//         eventSink?.success(gson.toJson(pushEvent))
//     }
// }