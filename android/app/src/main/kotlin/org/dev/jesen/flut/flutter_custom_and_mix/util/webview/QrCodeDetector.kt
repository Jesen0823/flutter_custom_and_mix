package org.dev.jesen.flut.flutter_custom_and_mix.util.webview

import android.os.Handler
import android.os.Looper
import android.webkit.WebView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * 二维码检测工具类，负责从WebView页面中识别二维码图片链接
 */
class QrCodeDetector(
    private val webView: WebView,
    private val callback: QrCodeCallback
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val ioScope = CoroutineScope(Dispatchers.IO)
    private val mainScope = CoroutineScope(Dispatchers.Main)

    /**
     * 二维码检测回调接口
     */
    interface QrCodeCallback {
        fun onQrCodeLinksDetected(links: List<String>)
        fun onError(error: String)
    }

    /**
     * 从WebView当前页面中提取所有可能的二维码图片链接
     */
    fun detectQrCodeLinks() {
        val jsScript = buildQrCodeDetectionScript()
        executeJavaScript(jsScript) { result ->
            if (result != null && result != "null") {
                parseQrCodeLinks(result)
            }
        }
    }

    /**
     * 构建用于检测二维码的JavaScript脚本
     */
    private fun buildQrCodeDetectionScript(): String {
        return """
            (function() {
                var qrCodeLinks = new Set(); // 使用Set自动去重
                var images = document.querySelectorAll('img');
                
                for (var i = 0; i < images.length; i++) {
                    var img = images[i];
                    var src = img.src || img.getAttribute('data-src');
                    
                    if (!src) continue;
                    
                    var lowerSrc = src.toLowerCase();
                    var isQrCode = false;
                    
                    // 精确检查二维码相关关键词
                    if ((lowerSrc.includes('qr') && 
                         (lowerSrc.includes('code') || 
                          lowerSrc.includes('scan') || 
                          lowerSrc.includes('bar'))) || 
                        // 微信公众号二维码特征
                        lowerSrc.includes('mmbiz_qlogo') ||
                        lowerSrc.includes('mmbiz_jpg') ||
                        lowerSrc.includes('mmbiz_png')) {
                        isQrCode = true;
                    } else if (lowerSrc.endsWith('.png') ||
                               lowerSrc.endsWith('.jpg') ||
                               lowerSrc.endsWith('.jpeg')) {
                        // 对于图片文件，更严格地检查是否为二维码
                        var width = img.width || img.naturalWidth || img.offsetWidth;
                        var height = img.height || img.naturalHeight || img.offsetHeight;
                        
                        // 二维码通常有一定尺寸，过滤过小的图片
                        if (width > 50 && height > 50) {
                            var aspectRatio = Math.abs(width / height - 1);
                            // 更严格的宽高比检查（差异小于5%）
                            isQrCode = aspectRatio < 0.05;
                        }
                    }
                    
                    if (isQrCode) {
                        qrCodeLinks.add(src);
                    }
                }
                
                return Array.from(qrCodeLinks); // 转换为数组返回
            })();
        """
    }

    /**
     * 执行JavaScript代码
     */
    private fun executeJavaScript(script: String, resultCallback: ((String?) -> Unit)? = null) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            webView.evaluateJavascript(script) { result ->
                mainHandler.post {
                    resultCallback?.invoke(result)
                }
            }
        } else {
            webView.loadUrl("javascript:$script")
            mainHandler.post {
                resultCallback?.invoke(null)
            }
        }
    }

    /**
     * 解析JavaScript返回的二维码链接结果
     */
    private fun parseQrCodeLinks(result: String) {
        ioScope.launch {
            try {
                val qrCodeLinks = mutableListOf<String>()
                val jsonArray = org.json.JSONArray(result)
                for (i in 0 until jsonArray.length()) {
                    qrCodeLinks.add(jsonArray.getString(i))
                }
                withContext(Dispatchers.Main) {
                    callback.onQrCodeLinksDetected(qrCodeLinks)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    callback.onError("解析二维码链接失败: ${e.message}")
                }
            }
        }
    }
}