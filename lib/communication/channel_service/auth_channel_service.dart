import '../base_method_channel.dart';
import '../channel_error.dart';
import '../channel_manager.dart';
import '../model/user_entity.dart';

/// 用户模块通信Service（业务层接口）
abstract class IAuthChannelService {
  Future<UserInfo> getUserInfo({required UserParam param});
  void registerUserLogoutHandler({required Function() onLogout});
}

/// 用户模块通信实现（依赖底层Channel）
class AuthChannelServiceImpl implements IAuthChannelService {
  final BaseMethodChannel _channel = ChannelManager().getMethodChannel(
    channelName: 'com.company.app/user',
  );

  /// 调用原生获取用户信息
  @override
  Future<UserInfo> getUserInfo({required UserParam param}) async {
    return _channel.invokeMethod<UserInfo>(
      method: 'getUserInfo',
      params: param,
      resultConverter: (json) {
        if (json == null) {
          throw ChannelError(code: 2002, message: '用户信息为空');
        }
        // 检查是否为错误结果
        if (json.containsKey('code') && json['code'] != 0) {
          throw ChannelError(
            code: json['code'] as int,
            message: json['message'] as String,
            extra: json['extra'] as Map<String, dynamic>?,
          );
        }
        return UserInfo.fromJson(json);
      },
    );
  }

  /// 注册原生调用Flutter的退出登录回调
  @override
  void registerUserLogoutHandler({required Function() onLogout}) {
    _channel.registerMethodHandler(
      method: 'onLogout',
      handler: (params) async {
        onLogout();
        return null;
      },
    );
  }
}