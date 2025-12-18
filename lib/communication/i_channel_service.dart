import 'base/base_serializable.dart';

/// MethodChannel抽象接口（同步/异步方法调用）
abstract class IMethodChannelService {
  /// 调用原生方法
  /// [method]：方法名（常量）
  /// [params]：入参（必须继承BaseSerializable）
  /// [resultConverter]：结果转换器（将JSON转成目标实体）
  Future<T> invokeMethod<T extends BaseSerializable?>({
    required String method,
    BaseSerializable? params,
    required T Function(Map<String, dynamic>?) resultConverter,
  });

  /// 注册原生调用Flutter的方法
  void registerMethodHandler({
    required String method,
    required Future<BaseSerializable?> Function(BaseSerializable? params) handler,
  });
}

/// EventChannel抽象接口（原生推Flutter事件流）
abstract class IEventChannelService<T extends BaseSerializable> {
  /// 订阅事件
  /// [tag]：订阅标签（用于区分多个订阅者，避免内存泄漏）
  Stream<T> subscribe({required String tag});

  /// 取消订阅
  void unsubscribe({required String tag});

  /// 销毁Channel
  void dispose();
}

/// BaseMessageChannel抽象接口（双向消息流，极少用）
abstract class IMessageChannelService<T extends BaseSerializable> {
  /// 发送消息
  Future<T?> sendMessage(T message);

  /// 接收消息流
  Stream<T> receiveMessages();

  /// 销毁Channel
  void dispose();
}