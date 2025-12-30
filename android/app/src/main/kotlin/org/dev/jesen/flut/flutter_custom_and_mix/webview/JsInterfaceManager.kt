package org.dev.jesen.flut.flutter_custom_and_mix.webview

import android.os.Build
import android.os.Handler
import android.os.Looper
import android.webkit.JavascriptInterface
import android.webkit.WebView

/**
 * JS交互管理器，负责处理WebView与JavaScript之间的交互
 */
class JsInterfaceManager(
    private val webView: WebView,
    private val callback: JsCallback
) {

    /**
     * JS回调接口
     */
    interface JsCallback {
        fun onAuthSuccess(token: String)
        fun onAuthSuccess(token: String, userInfo: Map<String, Any>?)
        fun onMessageReceived(message: String)
        fun onError(error: String)
        fun onQrCodeLinksDetected(links: List<String>)
        fun onJsFunctionCalled(functionName: String, params: Map<String, Any>?)
    }

    companion object {
        private const val JS_INTERFACE_NAME = "AndroidInterface"
        private const val NATIVE_BRIDGE_NAME = "NativeBridge"
    }

    private var qrCodeDetector: QrCodeDetector? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * JavaScript接口实现
     */
    @Suppress("unused")
    inner class JsBridge {
        @JavascriptInterface
        fun onAuthSuccess(token: String) {
            mainHandler.post {
                callback.onAuthSuccess(token)
            }
        }

        @JavascriptInterface
        fun onMessage(message: String) {
            mainHandler.post {
                callback.onMessageReceived(message)
            }
        }
    }

    /**
     * JavaScript桥接接口实现（更通用的版本）
     */
    @Suppress("unused")
    inner class NativeBridge {
        @JavascriptInterface
        fun onAuthSuccess(token: String) {
            mainHandler.post {
                callback.onAuthSuccess(token)
            }
        }

        @JavascriptInterface
        fun sendMessage(message: String) {
            mainHandler.post {
                callback.onMessageReceived(message)
            }
        }

        @JavascriptInterface
        fun callFunction(functionName: String, params: String) {
            mainHandler.post {
                try {
                    // 这里可以根据需要解析params为Map
                    val paramMap = mutableMapOf<String, Any>()
                    // 简化处理，实际项目中可以使用Gson等库解析JSON
                    callback.onJsFunctionCalled(functionName, paramMap)
                } catch (e: Exception) {
                    callback.onJsFunctionCalled(functionName, null)
                }
            }
        }
    }

    /**
     * 初始化JS交互
     */
    fun initJsInterface() {
        webView.addJavascriptInterface(JsBridge(), JS_INTERFACE_NAME)
        webView.addJavascriptInterface(NativeBridge(), NATIVE_BRIDGE_NAME)
        initQrCodeDetector()
    }

    /**
     * 初始化二维码检测器
     */
    private fun initQrCodeDetector() {
        qrCodeDetector = QrCodeDetector(webView)
    }

    /**
     * 移除JS交互接口
     */
    fun removeJsInterface() {
        webView.removeJavascriptInterface(JS_INTERFACE_NAME)
        webView.removeJavascriptInterface(NATIVE_BRIDGE_NAME)
        qrCodeDetector = null
    }

    /**
     * 执行JavaScript代码
     * @param script 要执行的JavaScript代码
     * @param resultCallback 执行结果回调
     */
    fun executeJavaScript(script: String, resultCallback: ((String?) -> Unit)? = null) {
        mainHandler.post {
            if (webView.settings.javaScriptEnabled) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                    webView.evaluateJavascript(script, resultCallback)
                } else {
                    webView.loadUrl("javascript:$script")
                    resultCallback?.invoke(null)
                }
            }
        }
    }

    /**
     * 调用JS函数
     * @param functionName 函数名
     * @param params 参数列表
     */
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

    /**
     * 识别页面中的二维码图片链接
     */
    fun extractQrCodeImageLinks() {
        qrCodeDetector?.detectEnhancedQrCodeLinks(object : QrCodeDetector.QrCodeDetectionCallback {
            override fun onQrCodeDetected(qrCodeUrls: List<String>) {
                callback.onQrCodeLinksDetected(qrCodeUrls)
            }

            override fun onDetectionError(error: String) {
                callback.onError(error)
            }
        })
    }

    /**
     * 加载并识别指定URL中的二维码
     * @param url 要加载的URL
     */
    fun loadUrlAndExtractQrCode(url: String) {
        webView.loadUrl(url)
    }

    /**
     * 清理资源
     */
    fun cleanup() {
        removeJsInterface()
    }
}
