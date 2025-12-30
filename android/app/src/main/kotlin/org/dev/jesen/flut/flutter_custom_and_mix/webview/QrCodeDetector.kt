package org.dev.jesen.flut.flutter_custom_and_mix.webview

import android.webkit.WebView
import com.google.gson.Gson

/**
 * 二维码链接检测工具类
 * 负责从WebView页面中识别和提取二维码图片链接
 */
class QrCodeDetector(private val webView: WebView) {

    // 二维码图片链接检测回调
    interface QrCodeDetectionCallback {
        fun onQrCodeDetected(qrCodeUrls: List<String>)
        fun onDetectionError(error: String)
    }

    // 检测页面中的二维码图片链接
    fun detectQrCodeLinks(callback: QrCodeDetectionCallback) {
        val jsScript = """
            (function() {
                // 收集所有可能的二维码图片元素
                var imageElements = document.querySelectorAll('img');
                var potentialQrCodes = [];
                
                // 遍历所有图片元素
                for (var i = 0; i < imageElements.length; i++) {
                    var img = imageElements[i];
                    var src = img.src || img.getAttribute('data-src') || img.getAttribute('data-original') || '';
                    
                    // 如果图片链接为空，跳过
                    if (!src) continue;
                    
                    // 转换为小写便于匹配
                    var srcLower = src.toLowerCase();
                    
                    // 检查是否包含二维码特征
                    var isPotentialQrCode = false;
                    
                    // 1. 检查URL是否包含二维码相关关键词
                    var qrKeywords = ['qr', 'qrcode', 'qrcode', 'scan', 'barcode', 'mmbiz', 'weixin', 'wechat'];
                    for (var j = 0; j < qrKeywords.length; j++) {
                        if (srcLower.includes(qrKeywords[j])) {
                            isPotentialQrCode = true;
                            break;
                        }
                    }
                    
                    // 2. 检查是否包含图片文件后缀
                    var imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];
                    var hasImageExtension = false;
                    for (var j = 0; j < imageExtensions.length; j++) {
                        if (srcLower.endsWith(imageExtensions[j])) {
                            hasImageExtension = true;
                            break;
                        }
                    }
                    
                    // 3. 检查图片尺寸，二维码通常是正方形且尺寸适中
                    var width = img.width || img.offsetWidth || 0;
                    var height = img.height || img.offsetHeight || 0;
                    var isSquare = width > 0 && height > 0 && Math.abs(width - height) < 20;
                    var isAppropriateSize = width >= 100 && width <= 500 && height >= 100 && height <= 500;
                    
                    // 4. 检查是否是微信公众号的二维码（通常包含mmbiz前缀）
                    var isWechatOfficialQrCode = srcLower.includes('mmbiz') && srcLower.includes('qrscene');
                    
                    // 如果满足任一条件，添加到潜在二维码列表
                    if (isPotentialQrCode || isWechatOfficialQrCode || (isSquare && isAppropriateSize && hasImageExtension)) {
                        potentialQrCodes.push(src);
                    }
                }
                
                // 去重
                var uniqueQrCodes = potentialQrCodes.filter(function(item, index) {
                    return potentialQrCodes.indexOf(item) === index;
                });
                
                return uniqueQrCodes;
            })();
        """

        // 执行JS脚本并处理结果
        webView.evaluateJavascript(jsScript) {
            try {
                // 解析JSON结果
                val qrCodeUrls = Gson().fromJson(it, Array<String>::class.java).toList()
                callback.onQrCodeDetected(qrCodeUrls)
            } catch (e: Exception) {
                callback.onDetectionError("Failed to parse QR code detection result: ${e.message}")
            }
        }
    }

    // 增强版二维码检测，支持检测更多类型的二维码
    fun detectEnhancedQrCodeLinks(callback: QrCodeDetectionCallback) {
        val jsScript = """
            (function() {
                var allImages = [];
                
                // 1. 收集所有标准img标签
                var imgTags = document.querySelectorAll('img');
                for (var i = 0; i < imgTags.length; i++) {
                    allImages.push(imgTags[i]);
                }
                
                // 2. 收集所有背景图片元素
                var allElements = document.querySelectorAll('*');
                for (var i = 0; i < allElements.length; i++) {
                    var element = allElements[i];
                    var style = window.getComputedStyle(element);
                    var backgroundImage = style.backgroundImage;
                    
                    if (backgroundImage && backgroundImage !== 'none') {
                        // 提取背景图片URL
                        var urlMatch = backgroundImage.match(/url\(['"]?([^'"]+)['"]?\)/g);
                        if (urlMatch) {
                            for (var j = 0; j < urlMatch.length; j++) {
                                var singleUrlMatch = urlMatch[j].match(/url\(['"]?([^'"]+)['"]?\)/);
                                if (singleUrlMatch && singleUrlMatch[1]) {
                                    // 创建临时img对象来存储背景图片信息
                                    var tempImg = {
                                        src: singleUrlMatch[1],
                                        width: element.offsetWidth || 0,
                                        height: element.offsetHeight || 0
                                    };
                                    allImages.push(tempImg);
                                }
                            }
                        }
                    }
                }
                
                var qrCodeCandidates = [];
                
                // 遍历所有收集到的图片
                for (var i = 0; i < allImages.length; i++) {
                    var img = allImages[i];
                    var src = img.src || '';
                    
                    if (!src) continue;
                    
                    // 去除URL中的查询参数和哈希值，仅保留基础URL
                    var baseSrc = src.split('?')[0].split('#')[0];
                    var srcLower = src.toLowerCase();
                    var baseSrcLower = baseSrc.toLowerCase();
                    
                    // 检查微信公众号二维码特征 - 扩大匹配范围
                    if (srcLower.includes('mmbiz') && (srcLower.includes('qrcode') || srcLower.includes('qrscene') || srcLower.includes('qr'))) {
                        qrCodeCandidates.push(src);
                        continue;
                    }
                    
                    // 检查是否包含二维码相关关键词 - 扩大关键词范围
                    if (srcLower.includes('qr') || srcLower.includes('qrcode') || srcLower.includes('weixin') || 
                        srcLower.includes('wechat') || srcLower.includes('barcode') || srcLower.includes('scan') ||
                        srcLower.includes('qrcode') || srcLower.includes('qr-')) {
                        qrCodeCandidates.push(src);
                        continue;
                    }
                    
                    // 检查图片尺寸和比例 - 更宽松的条件
                    var width = img.width || img.offsetWidth || 0;
                    var height = img.height || img.offsetHeight || 0;
                    
                    // 如果没有获取到尺寸，尝试从样式中获取
                    if (width <= 0 || height <= 0) {
                        try {
                            var style = window.getComputedStyle(img);
                            width = parseInt(style.width) || 0;
                            height = parseInt(style.height) || 0;
                        } catch (e) {
                            // 忽略错误
                        }
                    }
                    
                    if (width > 0 && height > 0) {
                        var aspectRatio = width / height;
                        // 接近正方形 - 更宽松的比例范围
                        if (aspectRatio >= 0.8 && aspectRatio <= 1.2) {
                            // 尺寸适中 - 扩大尺寸范围
                            if ((width >= 50 && width <= 800) && (height >= 50 && height <= 800)) {
                                qrCodeCandidates.push(src);
                                continue;
                            }
                        }
                    }
                    
                    // 检查图片文件类型
                    var imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
                    for (var j = 0; j < imageExtensions.length; j++) {
                        if (baseSrcLower.endsWith(imageExtensions[j])) {
                            // 如果是图片文件，且尺寸信息无法获取，也添加到候选列表
                            if (width <= 0 || height <= 0) {
                                qrCodeCandidates.push(src);
                                break;
                            }
                        }
                    }
                }
                
                // 去重并返回结果
                var uniqueQrCodes = [...new Set(qrCodeCandidates)];
                return uniqueQrCodes;
            })();
        """

        // 执行JS脚本并处理结果
        webView.evaluateJavascript(jsScript) {
            try {
                val qrCodeUrls = Gson().fromJson(it, Array<String>::class.java).toList()
                callback.onQrCodeDetected(qrCodeUrls)
            } catch (e: Exception) {
                callback.onDetectionError("Failed to parse enhanced QR code detection result: ${e.message}")
            }
        }
    }
}
