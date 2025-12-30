package org.dev.jesen.flut.flutter_custom_and_mix.util

interface Constant {
    companion object{
        private const val CHANNEL_NAME_PREFIX = "org.dev.jesen.flut.flutter_custom_and_mix"
        const val METHOD_CHANNEL_AUTH = "$CHANNEL_NAME_PREFIX/auth_service"
        const val METHOD_CHANNEL_USER = "$CHANNEL_NAME_PREFIX/user"

        const val WEBSOCKET_PORT = 8888
    }
}