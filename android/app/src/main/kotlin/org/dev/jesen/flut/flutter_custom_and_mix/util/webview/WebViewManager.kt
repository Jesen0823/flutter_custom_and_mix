package org.dev.jesen.flut.flutter_custom_and_mix.util.webview

import android.content.Context
import android.os.Build
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
        fun onPageStarted(url: String?)
        fun onPageFinished(url: String?)
        fun onReceivedError(error: String)
        fun onReceivedHttpError(url: String?, statusCode: Int, error: String)
        fun onQrCodeLinksDetected(qrCodeUrls: List<String>)
    }

    private var _webView: WebView? = null
    val webView: WebView get() = _webView!!
    var isInitialized = false
        private set
    private var qrCodeDetector: QrCodeDetector? = null

    init {
        initializeWebView(context)
        setupWebViewClients()
    }

    /**
     * 初始化WebView
     */
    private fun initializeWebView(context: Context) {
        _webView = WebView(context.applicationContext)
        qrCodeDetector = QrCodeDetector(webView)
        configureWebView()
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
        
        // 启用混合内容模式
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            webSettings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        }
        
        // 设置用户代理
        webSettings.userAgentString = "${webSettings.userAgentString} FlutterCustomWebView"
        
        // 启用缩放
        webSettings.setSupportZoom(true)
        webSettings.builtInZoomControls = true
        webSettings.displayZoomControls = false
        
        // 设置页面加载策略
        webSettings.loadWithOverviewMode = true
        webSettings.useWideViewPort = true
        
        // Android 11+ 适配
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            webSettings.setAlgorithmicDarkeningAllowed(false)
        }
        
        // Android 10+ 安全设置
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            webSettings.safeBrowsingEnabled = true
        }
    }

    /**
     * 设置WebView客户端
     */
    private fun setupWebViewClients() {
        // 设置WebViewClient
        webView.webViewClient = object : WebViewClient() {
            override fun onPageStarted(view: WebView?, url: String?, favicon: android.graphics.Bitmap?) {
                super.onPageStarted(view, url, favicon)
                webViewCallback.onPageStarted(url)
            }
            
            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                webViewCallback.onPageFinished(url)
                
                // 页面加载完成后自动检测二维码
                detectQrCodeLinks()
            }
            
            override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
                super.onReceivedError(view, request, error)
                val errorMessage = "WebView错误: ${error?.toString()}"
                webViewCallback.onReceivedError(errorMessage)
            }
            
            override fun onReceivedHttpError(view: WebView?, request: WebResourceRequest?, errorResponse: WebResourceResponse?) {
                super.onReceivedHttpError(view, request, errorResponse)
                val url = request?.url?.toString()
                val statusCode = errorResponse?.statusCode ?: 0
                val errorMessage = "HTTP错误: ${errorResponse?.reasonPhrase}"
                webViewCallback.onReceivedHttpError(url, statusCode, errorMessage)
            }
            
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                // 返回false让WebView处理所有URL加载
                return false
            }
        }
        
        // 设置WebChromeClient
        webView.webChromeClient = object : WebChromeClient() {
            override fun onJsAlert(view: WebView?, url: String?, message: String?, result: JsResult?): Boolean {
                result?.confirm()
                return true
            }
            
            override fun onReceivedTitle(view: WebView?, title: String?) {
                super.onReceivedTitle(view, title)
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
            qrCodeDetector = null
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
    
    /**
     * 检测二维码链接
     */
    fun detectQrCodeLinks() {
        qrCodeDetector?.detectEnhancedQrCodeLinks(object : QrCodeDetector.QrCodeDetectionCallback {
            override fun onQrCodeDetected(qrCodeUrls: List<String>) {
                webViewCallback.onQrCodeLinksDetected(qrCodeUrls)
            }

            override fun onDetectionError(error: String) {
                webViewCallback.onReceivedError(error)
            }
        })
    }
    
    /**
     * 后退
     */
    fun goBack(): Boolean {
        return if (isInitialized && webView.canGoBack()) {
            webView.goBack()
            true
        } else {
            false
        }
    }
    
    /**
     * 前进
     */
    fun goForward(): Boolean {
        return if (isInitialized && webView.canGoForward()) {
            webView.goForward()
            true
        } else {
            false
        }
    }
    
    /**
     * 重新加载
     */
    fun reload() {
        if (isInitialized) {
            webView.reload()
        }
    }
}
