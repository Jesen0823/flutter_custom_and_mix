package org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter
import android.content.Context
import android.graphics.Color
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

// 原生自定义View
class NativeCustomView(context: Context): LinearLayout(context) {
    init {
        orientation = VERTICAL
        setBackgroundColor(Color.GRAY)
        // 添加原生Button
        val nativeBtn = Button(context)
        nativeBtn.text = "这是Android原生Button"
        nativeBtn.setOnClickListener {
            android.widget.Toast.makeText(context, "原生Button被点击", android.widget.Toast.LENGTH_SHORT).show()
        }
        addView(nativeBtn)

        // 添加原生TextView
        val nativeTv = TextView(context)
        nativeTv.text = "Flutter嵌入的原生View"
        addView(nativeTv)
    }
}