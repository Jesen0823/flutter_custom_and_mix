
/// MethodChannel抽象接口（同步/异步方法调用）
abstract class IMethodChannelService {
  /// 调用原生方法
  /// [method]：方法名（常量）
  /// [params]：入参（支持任意类型）
  /// [resultConverter]：结果转换器（将结果转换为目标类型）
  Future<T> invokeMethod<T>({
    required String method,
    dynamic params,
    required T Function(dynamic) resultConverter,
  });

  /// 简化版：调用原生方法，返回类型为dynamic
  Future<dynamic> invokeMethodDynamic({
    required String method,
    dynamic params,
  });

  /// 注册原生调用Flutter的方法
  void registerMethodHandler({
    required String method,
    required Future<dynamic> Function(dynamic params) handler,
  });
}

/// EventChannel抽象接口（原生推Flutter事件流）
abstract class IEventChannelService<T> {
  /// 订阅事件
  /// [tag]：订阅标签（用于区分多个订阅者，避免内存泄漏）
  Stream<T> subscribe({required String tag});

  /// 取消订阅
  void unsubscribe({required String tag});

  /// 销毁Channel
  void dispose();
}

/// BaseMessageChannel抽象接口（双向消息流，极少用）
abstract class IMessageChannelService<T> {
  /// 发送消息
  Future<T?> sendMessage(T message);

  /// 接收消息流
  Stream<T> receiveMessages();

  /// 销毁Channel
  void dispose();
}