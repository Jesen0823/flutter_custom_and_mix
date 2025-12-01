package org.dev.jesen.flut.flutter_custom_and_mix.insert_flutter

import android.content.Context
import android.view.View
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

// 实现PlatformViewFactory,创建NativeView
class NativeViewFactory: PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(
        context: Context,
        viewId: Int,
        args: Any?
    ): PlatformView {
        return object : PlatformView{
            override fun getView(): View {
                return NativeCustomTextView(context)
            }

            override fun dispose() {

            }

        }
    }
}