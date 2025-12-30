import 'package:flutter/services.dart';
import 'package:flutter_custom_and_mix/communication/model/chat_message_entity.dart';
import 'package:flutter_custom_and_mix/communication/utils/app_logger.dart';
import 'package:flutter_custom_and_mix/communication/utils/constant.dart';

import '../model/push_entity.dart';
import 'base_event_channel.dart';
import 'base_message_channel.dart';
import 'base_method_channel.dart';

/// Channel全局管理器（初始化、销毁、获取实例）
class ChannelManager {
  static final ChannelManager _instance = ChannelManager._();
  factory ChannelManager() => _instance;
  ChannelManager._();

  /// 初始化所有业务Channel（在main函数中调用）
  Future<void> init() async {
    AppLogger().i('开始初始化所有Channel...');
    // 1. 初始化基础配置（如日志级别、序列化配置）
    _initConfig();
    // 2. 预创建常用Channel（避免懒加载首次调用耗时）
    _preCreateChannels();
    AppLogger().i('Channel初始化完成');
  }

  /// 初始化配置
  void _initConfig() {
    // 生产环境关闭详细日志
    AppLogger().init(isRelease: bool.fromEnvironment('dart.vm.product'));
  }

  /// 预创建业务Channel（按模块划分）
  void _preCreateChannels() {
    // 用户模块MethodChannel
    BaseMethodChannel.create(channelName: Constant.methodChannelUser);
    // 支付模块MethodChannel
    BaseMethodChannel.create(channelName: Constant.methodChannelPay);
    // 鉴权模块MethodChannel
    BaseMethodChannel.create(channelName: Constant.methodChannelAuth);
    // 推送模块EventChannel
    BaseEventChannel<PushEvent>.create(
      channelName: Constant.eventChannelPush,
      converter: (dynamic json) => PushEvent.fromJson(json as Map<String, dynamic>),
    );
    // 消息模块
    BaseMessageChannel<ChatMessage>.create(
      channelName: Constant.basicChannelMsg,
      converter: (dynamic json) => ChatMessage.fromJson(json as Map<String, dynamic>?),
      codec: StandardMessageCodec(),
    );
  }

  /// 获取MethodChannel实例
  BaseMethodChannel getMethodChannel({required String channelName}) {
    return BaseMethodChannel.create(channelName: channelName);
  }

  /// 获取EventChannel实例
  BaseEventChannel<T> getEventChannel<T>({
    required String channelName,
    required T Function(dynamic) converter,
  }) {
    return BaseEventChannel.create(
      channelName: channelName,
      converter: converter,
    );
  }

  /// 获取MessageChannel实例
  BaseMessageChannel<T> getMessageChannel<T>({
    required String channelName,
    required T Function(dynamic) converter,
  }) {
    return BaseMessageChannel.create(
      channelName: channelName,
      converter: converter,
    );
  }

  /// 销毁所有Channel（APP退出时调用）
  void dispose() {
    AppLogger().i('开始销毁所有Channel...');
    BaseMethodChannel.instanceMap.forEach((_, channel) => channel.dispose());
    BaseEventChannel.instanceMap.forEach((_, channel) => channel.dispose());
    BaseMessageChannel.instanceMap.forEach((_, channel) => channel.dispose());
    AppLogger().i('所有Channel销毁完成');
  }
}