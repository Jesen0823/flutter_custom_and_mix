package org.dev.esen.flut.flutter_custom_and_mix.util.webview

import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.os.Handler
import android.os.Looper

/**
 * JS交互管理类
 * 负责JS接口注入和JS交互逻辑处理
 */
class JsInterfaceManager(private val webView: WebView) {

    // JS交互回调
    interface JsCallback {
        fun onJsMessageReceived(message: String)
        fun onJsFunctionCalled(functionName: String, params: Map<String, Any>?)
    }

    private var jsCallback: JsCallback? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // 设置回调
    fun setCallback(callback: JsCallback) {
        this.jsCallback = callback
    }

    // 初始化JS接口
    fun initializeJsInterface() {
        // 注入原生接口到JS
        webView.addJavascriptInterface(object : Any() {
            // JS调用原生方法：发送消息
            @JavascriptInterface
            fun sendMessage(message: String) {
                mainHandler.post {
                    jsCallback?.onJsMessageReceived(message)
                }
            }

            // JS调用原生方法：调用功能
            @JavascriptInterface
            fun callFunction(functionName: String, params: String) {
                mainHandler.post {
                    try {
                        // 这里可以根据需要解析params为Map
                        val paramMap = mutableMapOf<String, Any>()
                        // 简化处理，实际项目中可以使用Gson等库解析JSON
                        jsCallback?.onJsFunctionCalled(functionName, paramMap)
                    } catch (e: Exception) {
                        jsCallback?.onJsFunctionCalled(functionName, null)
                    }
                }
            }
        }, "NativeBridge")
    }

    // 执行JS代码
    fun executeJavaScript(script: String, resultCallback: ((String?) -> Unit)? = null) {
        mainHandler.post {
            if (webView.settings.javaScriptEnabled) {
                webView.evaluateJavascript(script, resultCallback)
            }
        }
    }

    // 调用JS函数
    fun callJsFunction(functionName: String, vararg params: Any) {
        val paramsString = params.joinToString(", ") { 
            when (it) {
                is String -> "'$it'"
                is Number -> it.toString()
                is Boolean -> it.toString()
                else -> "'${it.toString()}'"
            }
        }
        val jsScript = "javascript: if (typeof $functionName === 'function') { $functionName($paramsString); }"
        executeJavaScript(jsScript)
    }

    // 清理资源
    fun cleanup() {
        webView.removeJavascriptInterface("NativeBridge")
        jsCallback = null
    }
}
