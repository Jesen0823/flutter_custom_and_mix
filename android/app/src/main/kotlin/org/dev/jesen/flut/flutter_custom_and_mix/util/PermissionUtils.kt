package org.dev.jesen.flut.flutter_custom_and_mix.util

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

/**
 * 权限适配工具类：处理API 33+通知权限动态申请
 */
object PermissionUtils {
    // 通知权限请求码
    const val REQUEST_POST_NOTIFICATIONS: Int = 1001

    /**
     * 检查是否拥有通知权限（API 33+需要动态申请，低版本默认授予）
     */
    fun hasNotificationPermission(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) { // API 33+
            return ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        }
        // 低版本无需动态申请，默认拥有
        return true
    }

    /**
     * 申请通知权限（API 33+）
     */
    fun requestNotificationPermission(activity: Activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (!hasNotificationPermission(activity)) {
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf<String>(Manifest.permission.POST_NOTIFICATIONS),
                    REQUEST_POST_NOTIFICATIONS
                )
            }
        }
    }
}