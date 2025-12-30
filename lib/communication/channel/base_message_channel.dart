import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_custom_and_mix/communication/utils/app_logger.dart';
import 'base/channel_error.dart';
import 'base/i_channel_service.dart';

class BaseMessageChannel<T> implements IMessageChannelService<T> {
  final BasicMessageChannel<Object?> _channel;
  final String _channelName;
  final T Function(dynamic) _converter;
  late final StreamController<T> _receiveController;
  bool _isDisposed = false;
  static final Map<String, BaseMessageChannel> instanceMap = {};

  BaseMessageChannel._({
    required String channelName,
    required T Function(dynamic) converter,
    required MessageCodec<Object?> codec,
    BasicMessageChannel<Object?>? channel,
  })  : _channelName = channelName,
        _converter = converter,
        _channel = channel ?? BasicMessageChannel<Object?>(
          channelName,
          codec,
        ) {
    _initReceiveStream();
    AppLogger().v('BaseMessageChannel[$_channelName] 初始化完成，使用Codec: ${codec.runtimeType}');
  }

  /// 默认StandardMessageCodec
  factory BaseMessageChannel.create({
    required String channelName,
    required T Function(dynamic) converter,
    MessageCodec<Object?>? codec,
  }) {
    return instanceMap.putIfAbsent(
      channelName,
          () => BaseMessageChannel._(
              channelName: channelName,
              converter: converter,
            codec: codec ?? StandardMessageCodec(),
          ),
    ) as BaseMessageChannel<T>;
  }

  /// 初始化接收流,支持多订阅
  void _initReceiveStream() {
    if (_isDisposed) throw StateError('Channel[$_channelName] 已销毁，无法初始化');
    _receiveController = StreamController<T>.broadcast(
      onCancel: () => AppLogger().v('Channel[$_channelName] 消息流取消订阅'),
      onListen: () => AppLogger().v('Channel[$_channelName] 消息流开始监听'),
    );
    _channel.setMessageHandler((Object? message) async {
      AppLogger().v('Channel[$_channelName] 收到原生消息：$message');
      try {
        final T data = _converter(message);
        if (!_receiveController.isClosed) {
          _receiveController.add(data);
        }
        return {'code': ChannelErrorCode.success};
      } catch (e) {
        AppLogger().e('消息处理失败：${e.toString()}', error: e);
        return ChannelError(
          code: ChannelErrorCode.serializeError,
          message: e.toString(),
        ).toJson();
      }
    });
  }

  /// 发送消息
  @override
  Future<T?> sendMessage(T message) async {
    if (_isDisposed) throw StateError('Channel[$_channelName] 已销毁，无法发送消息');
    try {
      // 直接使用消息，由用户定义的转换器处理序列化逻辑
      final dynamic sendData = message;
      
      AppLogger().v('Channel[$_channelName] 发送消息到原生：$sendData');
      final Object? result = await _channel.send(sendData);
      
      AppLogger().v('Channel[$_channelName] 收到原生返回：$result');
      
      // 检查原生端返回的错误码
      if (result is Map && result['code'] != null && result['code'] != ChannelErrorCode.success) {
        throw ChannelError(
          code: ChannelErrorCode.nativeError,
          message: result['message'] ?? '原生端返回未知错误',
          extra: result['extra'] as Map<String, dynamic>?,
        );
      }
      
      // 使用转换器处理结果
      return _converter(result);
    } catch (e,stack) {
      AppLogger().e('Channel[$_channelName] 消息发送失败', error: e, stackTrace: stack);
      if (e is ChannelError) rethrow;
      throw ChannelError(
        code: ChannelErrorCode.nativeError,
        message: e.toString(),
        extra: {'stack': stack.toString()},
      );
    }
  }

  /// 接收消息流
  @override
  Stream<T> receiveMessages() => _receiveController.stream;

  /// 销毁Channel
  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _receiveController.close();
    instanceMap.remove(_channelName);
    AppLogger().v('BaseMessageChannel[$_channelName] 已销毁');
  }

  Map<String, dynamic> _convertToSafeMap(Object? data) {
    if (data == null) return {};
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw ChannelError(
      code: ChannelErrorCode.paramError,
      message: '消息类型错误，期望Map，实际：${data.runtimeType}',
    );
  }

  /// 清空所有通道（全局销毁，如APP退出时）
  static void disposeAll() {
    instanceMap.forEach((key, channel) => channel.dispose());
    instanceMap.clear();
    AppLogger().v('所有BaseMessageChannel已销毁');
  }
}