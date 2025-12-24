import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_custom_and_mix/communication/utils/app_logger.dart';

import 'base/base_serializable.dart';
import 'channel_error.dart';
import 'i_channel_service.dart';

class BaseEventChannel<T extends BaseSerializable> implements IEventChannelService<T> {
  final EventChannel _channel;
  final String _channelName;
  final T Function(Map<String, dynamic>?) _converter; // 事件转换器
  final Map<String, Stream<T>> _eventStreams = {}; // 保存事件流,供外部监听
  final Map<String, StreamSubscription<T>> _streamSubscriptions = {}; // 保存订阅关系,用于取消

  static final Map<String, BaseEventChannel> instanceMap = {};

  /// 私有构造函数
  BaseEventChannel._({
    required String channelName,
    required T Function(Map<String, dynamic>?) converter,
    EventChannel? channel,
  })  : _channelName = channelName,
        _converter = converter,
        _channel = channel ?? EventChannel(channelName);

  /// 工厂方法（单例）
  factory BaseEventChannel.create({
    required String channelName,
    required T Function(Map<String, dynamic>?) converter,
  }) {
    return instanceMap.putIfAbsent(
      channelName,
          () => BaseEventChannel._(channelName: channelName, converter: converter),
    ) as BaseEventChannel<T>;
  }

  /// 订阅事件,绑定tag，支持取消
  @override
  Stream<T> subscribe({required String tag}) {
    // 如果已有该tag的流，直接返回,避免重复创建
    if (_eventStreams.containsKey(tag)) {
      AppLogger().w('tag=$tag已订阅，返回已有流');
      return _eventStreams[tag]!;
    }

    // 创建事件流,处理序列化、异常
    final stream = _channel.receiveBroadcastStream()
        .map((event) {
      AppLogger().v('收到原生事件：$event');
      return _converter(event as Map<String, dynamic>?);
    }).handleError((error) {
      AppLogger().e('事件流异常：${error.toString()}');
      throw ChannelError(
        code: ChannelErrorCode.nativeError,
        message: '事件接收失败：${error.toString()}',
      );
    }).asBroadcastStream(); // 显式转为广播流，支持多个监听者

    // 订阅流（空监听仅维持订阅关系，实际逻辑由外部监听处理）
    final subscription = stream.listen(
          (_) {},
      onError: (_) {},
    );

    // 保存流和订阅关系
    _eventStreams[tag] = stream;
    _streamSubscriptions[tag] = subscription;

    AppLogger().v('tag=$tag 订阅事件流成功');
    return stream;
  }

  /// 取消订阅（按tag释放）
  @override
  void unsubscribe({required String tag}) {
    // 移除并取消订阅关系
    final subscription = _streamSubscriptions.remove(tag);
    subscription?.cancel();
    // 同时移除流对象
    _eventStreams.remove(tag);
    AppLogger().v('tag=$tag 取消订阅事件流');
  }

  /// 销毁Channel（取消所有订阅）
  @override
  void dispose() {
    _streamSubscriptions.forEach((_, subscription) => subscription.cancel());
    _streamSubscriptions.clear();
    _eventStreams.clear();
    instanceMap.remove(_channelName);
    AppLogger().v('EventChannel $_channelName 已销毁');
  }
}