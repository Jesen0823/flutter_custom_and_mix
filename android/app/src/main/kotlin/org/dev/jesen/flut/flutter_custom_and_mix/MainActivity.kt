package org.dev.jesen.flut.flutter_custom_and_mix

import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.provider.CalendarContract
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.Toast
import androidx.core.view.marginTop
import androidx.core.view.setPadding
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.dev.jesen.flut.flutter_custom_and_mix.channel.ChannelRegistry
import org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter.NativeViewPlugin
import org.dev.jesen.flut.flutter_custom_and_mix.util.PermissionUtils

class MainActivity : FlutterActivity() {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var hasPermission = false // 是否有权限

    // 与Flutter端一致的Channel名称
    private val METHOD_CHANNEL_NAME = "org.dev.jesen.flut.flutter_custom_and_mix/native_method"
    private val EVENT_CHANNEL_NAME = "org.dev.jesen.flut.flutter_custom_and_mix/native_event"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        PermissionUtils.requestNotificationPermission(this@MainActivity)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        // 模拟原生触发调用（如添加原生按钮）
        addNativeButton()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 注册自定义View的插件
        flutterEngine.plugins.add(NativeViewPlugin())
        
        // 注册所有Channel
        ChannelRegistry.registerWith(flutterEngine, this.applicationContext)

        /**
         * 1.MethodChannel相关：
         * */
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL_NAME
        )
        // 注册MethodChannel，绑定FlutterEngine的BinaryMessenger
        methodChannel.setMethodCallHandler { call, result ->
            //  根据方法名处理调用
            when (call.method) {
                "getAndroidDeviceInfo" -> {
                    // 获取Flutter传递的参数
                    val param1 = call.argument<String>("param1")
                    val param2 = call.argument<Int>("param2")
                    // 执行原生逻辑
                    val deviceInfo = "Android版本：${Build.VERSION.RELEASE}，参数：$param1-$param2"
                    // 返回结果给Flutter
                    result.success(deviceInfo)
                }

                else -> {
                    // 处理未知方法
                    result.notImplemented()
                }
            }
        }

        /**
         * 2.  EventChannel相关
         * */
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            private var eventSink: EventChannel.EventSink? = null
            // Flutter端监听时会触发
            override fun onListen(
                arguments: Any?,
                events: EventChannel.EventSink?
            ) {
                eventSink = events
                // 每秒发送一个数字
                CoroutineScope(Dispatchers.IO).launch {
                    for (i in 1..100) {
                        delay(1000)
                        eventSink?.success("原生事件 $i")
                    }
                    eventSink?.endOfStream()
                }
            }

            // Flutter端取消监听时触发
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }

        })
    }

    // 处理权限申请结果
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String?>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PermissionUtils.REQUEST_POST_NOTIFICATIONS) {
            hasPermission = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun addNativeButton() {
        val nativeButton = Button(this@MainActivity)
        nativeButton.text = "原生调用Flutter显示Toast"
        nativeButton.setBackgroundColor(Color.RED)
        nativeButton.setTextColor(Color.WHITE)
        nativeButton.setPadding(20)
        nativeButton.setOnClickListener {
            // 主动调用Flutter方法
            val params = mapOf("msg" to "这是原生传递的Toast消息")
            val callback = object : MethodChannel.Result {
                override fun success(result: Any?) {
                    Toast.makeText(this@MainActivity, result.toString(), Toast.LENGTH_SHORT).show()
                }

                override fun error(
                    errorCode: String,
                    errorMessage: String?,
                    errorDetails: Any?
                ) {
                    Toast.makeText(this@MainActivity, errorMessage, Toast.LENGTH_SHORT).show()
                }

                override fun notImplemented() {
                    Toast.makeText(this@MainActivity, "方法没有实现", Toast.LENGTH_SHORT).show()
                }
            }
            methodChannel.invokeMethod("flutterShowToast", params, callback)
        }
        // 将原生按钮添加到FlutterActivity的布局中
        val layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, 90)
        val rootLayout = findViewById<FrameLayout>(android.R.id.content)
        rootLayout.addView(nativeButton, layoutParams)
    }
}
