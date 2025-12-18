package org.dev.jesen.flut.flutter_custom_and_mix.util.webview

import android.content.Context
import android.webkit.*

/**
 * WebView管理器，负责WebView的初始化、配置和生命周期管理
 */
class WebViewManager(
    context: Context,
    private val webViewCallback: WebViewCallback
) {

    /**
     * WebView回调接口
     */
    interface WebViewCallback {
        fun onPageFinished(url: String?)
        fun onReceivedError(error: String)
        fun onReceivedHttpError(url: String?, statusCode: Int, error: String)
    }

    private var _webView: WebView? = null
    val webView: WebView get() = _webView!!
    var isInitialized = false
        private set

    init {
        initializeWebView(context)
    }

    /**
     * 初始化WebView
     */
    private fun initializeWebView(context: Context) {
        _webView = WebView(context.applicationContext)
        configureWebView()
        setupWebViewClients()
        isInitialized = true
    }

    /**
     * 配置WebView设置
     */
    private fun configureWebView() {
        val webSettings = webView.settings
        
        // 启用JavaScript
        webSettings.javaScriptEnabled = true
        webSettings.domStorageEnabled = true
        
        // 允许内容访问和文件访问
        webSettings.allowContentAccess = true
        webSettings.allowFileAccess = true
        
        // 启用混合内容模式（适用于Android 5.0+）
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            webSettings.mixedContentMode = WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
        }
        
        // 设置用户代理
        webSettings.userAgentString = "${webSettings.userAgentString} AuthService"
        
        // 启用缩放
        webSettings.setSupportZoom(true)
        webSettings.builtInZoomControls = true
        webSettings.displayZoomControls = false
    }

    /**
     * 设置WebView客户端
     */
    private fun setupWebViewClients() {
        // 设置WebViewClient
        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                webViewCallback.onPageFinished(url)
            }
            
            override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
                super.onReceivedError(view, request, error)
                val errorMessage = "WebView错误: ${error?.description}"
                webViewCallback.onReceivedError(errorMessage)
            }
            
            override fun onReceivedHttpError(view: WebView?, request: WebResourceRequest?, errorResponse: WebResourceResponse?) {
                super.onReceivedHttpError(view, request, errorResponse)
                val url = request?.url?.toString()
                val statusCode = errorResponse?.statusCode ?: 0
                val errorMessage = "HTTP错误: ${errorResponse?.reasonPhrase}"
                webViewCallback.onReceivedHttpError(url, statusCode, errorMessage)
            }
        }
        
        // 设置WebChromeClient
        webView.webChromeClient = object : WebChromeClient() {
            override fun onJsAlert(view: WebView?, url: String?, message: String?, result: JsResult?): Boolean {
                result?.confirm()
                return true
            }
        }
    }

    /**
     * 清理WebView资源
     */
    fun cleanup() {
        if (isInitialized) {
            // 停止加载
            webView.stopLoading()
            
            // 移除所有回调
            webView.webViewClient = object : WebViewClient() {}
            webView.webChromeClient = object : WebChromeClient() {}
            
            // 加载空白页面
            webView.loadUrl("about:blank")
            
            // 移除视图
            val parent = webView.parent
            if (parent is WebView) {
                parent.removeAllViews()
            }
            
            // 销毁WebView
            webView.destroy()
            
            // 释放引用
            _webView = null
            isInitialized = false
        }
    }

    /**
     * 加载URL
     * @param url 要加载的URL
     */
    fun loadUrl(url: String) {
        if (isInitialized) {
            webView.loadUrl(url)
        } else {
            webViewCallback.onReceivedError("WebView未初始化")
        }
    }
}
