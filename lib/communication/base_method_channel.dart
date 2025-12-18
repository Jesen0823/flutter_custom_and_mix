import 'package:flutter/services.dart';
import 'package:flutter_custom_and_mix/communication/utils/app_logger.dart';
import 'package:logging/logging.dart';

import 'base/base_serializable.dart';
import 'channel_error.dart';
import 'i_channel_service.dart';

/// MethodChannel基类实现
class BaseMethodChannel implements IMethodChannelService {
  final MethodChannel _channel;
  final String _channelName;
  final Map<
    String,
    Future<BaseSerializable?> Function(BaseSerializable? params)
  >
  _methodHandlers = {};

  /// 构造函数（私有，通过工厂方法创建，避免重复实例）
  BaseMethodChannel._({required String channelName, MethodChannel? channel})
    : _channelName = channelName,
      _channel = channel ?? MethodChannel(channelName) {
    _registerMethodHandler();
  }

  /// 工厂方法（单例模式，同一channelName仅创建一个实例）
  factory BaseMethodChannel.create({required String channelName}) {
    return instanceMap.putIfAbsent(
      channelName,
      () => BaseMethodChannel._(channelName: channelName),
    );
  }

  static final Map<String, BaseMethodChannel> instanceMap = {};

  /// 注册原生调用Flutter的方法处理器
  @override
  void registerMethodHandler({
    required String method,
    required Future<BaseSerializable?> Function(BaseSerializable? params)
    handler,
  }) {
    if (_methodHandlers.containsKey(method)) {
      AppLogger().w('方法$method已注册，将覆盖原有实现');
    }
    _methodHandlers[method] = handler;
  }

  /// 调用原生方法（核心实现）
  @override
  Future<T> invokeMethod<T extends BaseSerializable?>({
    required String method,
    BaseSerializable? params,
    required T Function(Map<String, dynamic>?) resultConverter,
  }) async {
    // 1. 参数校验
    if (method.isEmpty) {
      throw ChannelError(code: ChannelErrorCode.paramError, message: '方法名不能为空');
    }

    // 2. 日志打印（生产环境可关闭）
    AppLogger().v('调用原生方法：$method，入参：${params?.toJson()}');

    try {
      // 3. 调用原生（序列化入参）
      final result = await _channel.invokeMethod<Map<String, dynamic>>(
        method,
        params?.toJson(),
      );

      // 4. 解析结果（通过转换器生成目标实体）
      AppLogger().v('原生方法$method返回结果：$result');
      return resultConverter(result);
    } on PlatformException catch (e) {
      // 5. 捕获原生异常（统一包装成ChannelError）
      AppLogger().e('原生方法$method调用失败：${e.code} - ${e.message}', error: e);
      throw ChannelError(
        code: int.tryParse(e.code) ?? ChannelErrorCode.nativeError,
        message: e.message ?? '原生未知错误',
        extra: e.details as Map<String, dynamic>?,
      );
    } catch (e) {
      // 6. 捕获其他异常（序列化、类型转换等）
      AppLogger().e('方法$method调用异常：${e.toString()}', error: e);
      throw ChannelError(
        code: ChannelErrorCode.serializeError,
        message: '调用失败：${e.toString()}',
      );
    }
  }

  /// 注册原生调用Flutter的统一处理器
  void _registerMethodHandler() {
    _channel.setMethodCallHandler((call) async {
      final method = call.method;
      final paramsJson = call.arguments as Map<String, dynamic>?;
      AppLogger().v('收到原生调用：$method，入参：$paramsJson');

      try {
        // 1. 查找方法处理器
        final handler = _methodHandlers[method];
        if (handler == null) {
          throw ChannelError(
            code: ChannelErrorCode.paramError,
            message: 'Flutter未注册方法：$method',
          );
        }

        // 2. 解析入参（如果需要，子类可扩展）
        BaseSerializable? params;
        if (paramsJson != null) {
          // 这里需根据具体方法的入参类型解析，可通过泛型优化（见进阶部分）
          params = BaseSerializable.fromJson(
            paramsJson,
            (json) => {} as BaseSerializable,
          );
        }

        // 3. 执行处理器并返回结果
        final result = await handler(params);
        AppLogger().v('Flutter处理方法$method完成，返回：${result?.toJson()}');
        return result?.toJson();
      } catch (e) {
        // 4. 异常兜底（返回统一错误模型给原生）
        AppLogger().e('Flutter处理方法$method失败：${e.toString()}', error: e);
        final error = e is ChannelError
            ? e
            : ChannelError(
                code: ChannelErrorCode.nativeError,
                message: e.toString(),
              );
        return error.toJson();
      }
    });
  }

  /// 销毁Channel（释放资源）
  void dispose() {
    _methodHandlers.clear();
    instanceMap.remove(_channelName);
    AppLogger().v('Channel $_channelName 已销毁');
  }
}
