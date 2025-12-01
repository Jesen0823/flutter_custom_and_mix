package org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter
import android.content.Context
import android.graphics.Color
import android.view.Gravity
import android.widget.TextView

// 原生自定义View
class NativeCustomTextView(context: Context): TextView(context) {
    init {
        text = "我是Android原生控件TextView"
        textSize = 24f
        setTextColor(Color.RED)
        setBackgroundColor(Color.GRAY)
        gravity = Gravity.CENTER
    }
}