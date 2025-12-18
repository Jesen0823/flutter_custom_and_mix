package org.dev.jesen.flut.flutter_custom_and_mix.util.webview

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
        fun onMessageReceived(message: String)
        fun onError(error: String)
        fun onQrCodeLinksDetected(links: List<String>)
    }

    companion object {
        private const val JS_INTERFACE_NAME = "AndroidInterface"
    }

    private var qrCodeDetector: QrCodeDetector? = null

    /**
     * JavaScript接口实现
     */
    @Suppress("unused")
    inner class JsBridge {
        @JavascriptInterface
        fun onAuthSuccess(token: String) {
            Handler(Looper.getMainLooper()).post {
                callback.onAuthSuccess(token)
            }
        }

        @JavascriptInterface
        fun onMessage(message: String) {
            Handler(Looper.getMainLooper()).post {
                callback.onMessageReceived(message)
            }
        }
    }

    /**
     * 初始化JS交互
     */
    fun initJsInterface() {
        webView.addJavascriptInterface(JsBridge(), JS_INTERFACE_NAME)
        initQrCodeDetector()
    }

    /**
     * 初始化二维码检测器
     */
    private fun initQrCodeDetector() {
        qrCodeDetector = QrCodeDetector(webView, object : QrCodeDetector.QrCodeCallback {
            override fun onQrCodeLinksDetected(links: List<String>) {
                callback.onQrCodeLinksDetected(links)
            }

            override fun onError(error: String) {
                callback.onError(error)
            }
        })
    }

    /**
     * 移除JS交互接口
     */
    fun removeJsInterface() {
        webView.removeJavascriptInterface(JS_INTERFACE_NAME)
        qrCodeDetector = null
    }

    /**
     * 执行JavaScript代码
     * @param script 要执行的JavaScript代码
     * @param resultCallback 执行结果回调
     */
    fun executeJavaScript(script: String, resultCallback: ((String?) -> Unit)? = null) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            webView.evaluateJavascript(script) { result ->
                resultCallback?.invoke(result)
            }
        } else {
            webView.loadUrl("javascript:$script")
            resultCallback?.invoke(null)
        }
    }

    /**
     * 识别页面中的二维码图片链接
     */
    fun extractQrCodeImageLinks() {
        qrCodeDetector?.detectQrCodeLinks()
    }

    /**
     * 加载并识别指定URL中的二维码
     * @param url 要加载的URL
     */
    fun loadUrlAndExtractQrCode(url: String) {
        webView.loadUrl(url)
    }
}
