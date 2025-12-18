/// 跨平台通信统一错误模型
class ChannelError extends Error {
  final int code; // 错误码（0成功，非0失败）
  final String message; // 错误描述
  final Map<String, dynamic>? extra; // 附加信息

  ChannelError({
    required this.code,
    required this.message,
    this.extra,
  });

  // 序列化用于原生传递
  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'extra': extra,
  };

  @override
  String toString() => '[ChannelError] $code: $message ${extra ?? ''}';
}

/// 错误码常量（按模块划分）
class ChannelErrorCode {
  static const int success = 0;
  static const int paramError = 1001; // 参数错误
  static const int platformNotSupport = 1002; // 平台不支持
  static const int nativeError = 1003; // 原生内部错误
  static const int serializeError = 1004; // 序列化失败
}