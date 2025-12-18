package org.dev.esen.flut.flutter_custom_and_mix

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import org.dev.esen.flut.flutter_custom_and_mix.service.AuthService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "MainActivity"
    }

    private var authService: AuthService? = null
    private var isServiceBound = false

    // Service连接对象
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            Log.d(TAG, "AuthService connected")
            val binder = service as AuthService.LocalBinder
            authService = binder.getService()
            isServiceBound = true
            
            // 设置服务回调
            authService?.setCallback(object : AuthService.ServiceCallback {
                override fun onWebViewLoaded() {
                    Log.d(TAG, "WebView loaded")
                    // 页面加载完成，可以进行后续操作
                }

                override fun onQrCodeDetected(qrCodeUrls: List<String>) {
                    Log.d(TAG, "Detected QR codes: $qrCodeUrls")
                    // 处理检测到的二维码链接
                }

                override fun onAuthSuccess(token: String, userInfo: Map<String, Any>?) {
                    Log.d(TAG, "Authentication successful: $token")
                    // 处理登录成功
                }

                override fun onAuthError(error: String) {
                    Log.e(TAG, "Authentication error: $error")
                    // 处理登录错误
                }
            })
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            Log.d(TAG, "AuthService disconnected")
            authService?.removeCallback()
            authService = null
            isServiceBound = false
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 启动AuthService
        startAuthService()
    }

    override fun onDestroy() {
        super.onDestroy()
        // 解绑AuthService
        if (isServiceBound) {
            unbindService(serviceConnection)
            isServiceBound = false
        }
    }

    // 启动AuthService
    private fun startAuthService() {
        val intent = Intent(this, AuthService::class.java)
        
        // 绑定服务
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
        
        // 启动为前台服务
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    // 加载WebView页面
    fun loadAuthPage(url: String) {
        if (isServiceBound) {
            authService?.loadUrl(url)
        }
    }

    // 手动检测二维码
    fun detectQrCode() {
        if (isServiceBound) {
            authService?.detectQrCode()
        }
    }
}
