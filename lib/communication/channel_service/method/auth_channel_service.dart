import 'package:flutter_custom_and_mix/communication/channel/base_method_channel.dart';
import 'package:flutter_custom_and_mix/communication/channel/channel_manager.dart';
import 'package:flutter_custom_and_mix/communication/utils/constant.dart';

/// 用户模块通信Service（业务层接口）
abstract class IAuthChannelService {

}

/// 用户模块通信实现（依赖底层Channel）
class AuthChannelServiceImpl implements IAuthChannelService {
  final BaseMethodChannel _channel = ChannelManager().getMethodChannel(
    channelName: Constant.methodChannelAuth,
  );


}