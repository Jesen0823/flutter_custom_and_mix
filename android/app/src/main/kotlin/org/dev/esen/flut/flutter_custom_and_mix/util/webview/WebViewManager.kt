package org.dev.esen.flut.flutter_custom_and_mix.util.webview

import android.content.Context
import android.os.Build
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient

/**
 * WebView管理类
 * 负责WebView的初始化、配置、生命周期管理
 */
class WebViewManager(context: Context, private val callback: WebViewCallback) {

    // WebView回调接口
    interface WebViewCallback {
        fun onPageStarted(url: String?)
        fun onPageFinished(url: String?)
        fun onReceivedError(error: String)
        fun onQrCodeLinksDetected(qrCodeUrls: List<String>)
    }

    private var _webView: WebView? = null
    val webView: WebView get() = _webView!!
    private var qrCodeDetector: QrCodeDetector? = null
    var isInitialized = false

    init {
        initializeWebView(context)
        setupWebViewClients()
    }

    // 初始化WebView
    private fun initializeWebView(context: Context) {
        _webView = WebView(context.applicationContext)
        qrCodeDetector = QrCodeDetector(webView)
        
        val settings = webView.settings
        
        // 启用JavaScript
        settings.javaScriptEnabled = true
        
        // 启用DOM存储
        settings.domStorageEnabled = true
        
        // 启用混合内容模式
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            settings.mixedContentMode = android.webkit.WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        }
        
        // 设置用户代理
        settings.userAgentString = "${settings.userAgentString} FlutterCustomWebView"
        
        // 启用缩放
        settings.setSupportZoom(true)
        settings.builtInZoomControls = true
        settings.displayZoomControls = false
        
        // 设置页面加载策略
        settings.loadWithOverviewMode = true
        settings.useWideViewPort = true
        
        // Android 11+ 适配
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            settings.setAlgorithmicDarkeningAllowed(false)
        }
        
        // Android 10+ 安全设置
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            settings.safeBrowsingEnabled = true
        }
        
        // Android 10+ 适配
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // 移除不存在的方法调用
        }
        
        // 设置缓存策略
        settings.cacheMode = android.webkit.WebSettings.LOAD_DEFAULT
        
        isInitialized = true
    }

    // 设置WebView客户端
    private fun setupWebViewClients() {
        webView.webViewClient = object : WebViewClient() {
            override fun onPageStarted(view: WebView?, url: String?, favicon: android.graphics.Bitmap?) {
                super.onPageStarted(view, url, favicon)
                callback.onPageStarted(url)
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                callback.onPageFinished(url)
                
                // 页面加载完成后自动检测二维码
                detectQrCodeLinks()
            }

            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                // 返回false让WebView处理所有URL加载
                return false
            }
        }

        webView.webChromeClient = object : WebChromeClient() {
            override fun onReceivedTitle(view: WebView?, title: String?) {
                super.onReceivedTitle(view, title)
            }
        }
    }

    // 加载URL
    fun loadUrl(url: String) {
        if (isInitialized) {
            webView.loadUrl(url)
        }
    }

    // 检测二维码链接
    fun detectQrCodeLinks() {
        qrCodeDetector?.detectEnhancedQrCodeLinks(object : QrCodeDetector.QrCodeDetectionCallback {
            override fun onQrCodeDetected(qrCodeUrls: List<String>) {
                callback.onQrCodeLinksDetected(qrCodeUrls)
            }

            override fun onDetectionError(error: String) {
                callback.onReceivedError(error)
            }
        })
    }

    // 清理WebView资源
    fun cleanup() {
        if (isInitialized) {
            webView.stopLoading()
            webView.webViewClient = WebViewClient()
            webView.webChromeClient = WebChromeClient()
            webView.loadUrl("about:blank")
            webView.removeAllViews()
            webView.destroy()
            _webView = null
            qrCodeDetector = null
            isInitialized = false
        }
    }

    // 后退
    fun goBack(): Boolean {
        return if (isInitialized && webView.canGoBack()) {
            webView.goBack()
            true
        } else {
            false
        }
    }

    // 前进
    fun goForward(): Boolean {
        return if (isInitialized && webView.canGoForward()) {
            webView.goForward()
            true
        } else {
            false
        }
    }

    // 重新加载
    fun reload() {
        if (isInitialized) {
            webView.reload()
        }
    }
}
