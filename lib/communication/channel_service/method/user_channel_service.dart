import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/communication/channel/base/channel_error.dart';
import 'package:flutter_custom_and_mix/communication/channel/base_method_channel.dart';
import 'package:flutter_custom_and_mix/communication/channel/channel_manager.dart';
import 'package:flutter_custom_and_mix/communication/model/user_entity.dart';
import 'package:flutter_custom_and_mix/communication/utils/constant.dart';
import 'package:get/utils.dart';

/// 用户模块通信Service（业务层接口）
abstract class IUserChannelService {
  Future<UserInfo> getUserInfoModel({required UserParam param});
  Future<UserInfo> getUserInfoJson({required String param});
  Future<String> getUserInfoString({required String param});
  Future<UserInfo> getUserInfoNoParam();
  void registerUserFunctionHandler({required Function() onHandler});
}

/// 用户模块通信实现（依赖底层Channel）
class UserChannelServiceImpl implements IUserChannelService {
  final BaseMethodChannel _channel = ChannelManager().getMethodChannel(
    channelName: Constant.methodChannelUser,
  );

  /// 调用原生获取用户信息
  @override
  Future<UserInfo> getUserInfoModel({required UserParam param}) async {
    return _channel.invokeMethod<UserInfo>(
      method: 'getUserInfoModel',
      params: param,
      resultConverter: (json) {
        if (json == null) {
          throw ChannelError(code: ChannelErrorCode.paramError, message: '用户信息为空');
        }
        // 检查是否为错误结果
        if (json is Map && json.containsKey('code') && json['code'] != 0) {
          throw ChannelError(
            code: json['code'] as int,
            message: json['message'] as String,
            extra: json['extra'] != null ? Map<String, dynamic>.from(json['extra'] as Map) : null,
          );
        }
        // 确保json是Map类型
        if (json is Map) {
          // 安全转换为Map<String, dynamic>类型
          final jsonMap = Map<String, dynamic>.from(json);
          return UserInfo.fromJson(jsonMap);
        } else {
          throw ChannelError(code: ChannelErrorCode.nativeError, message: '返回数据格式错误，不是Map类型');
        }
      },
    );
  }

  /// 注册原生调用Flutter的结果回调
  @override
  void registerUserFunctionHandler({required Function() onHandler}) {
    _channel.registerMethodHandler(
      method: 'onLogout',
      handler: (params) async {
        onHandler();
        return null;
      },
    );
  }

  @override
  Future<UserInfo> getUserInfoJson({required String param}) async {
    return _channel.invokeMethod<UserInfo>(
      method: 'getUserInfoJson',
      params: param, // 直接传递字符串参数
      resultConverter: (json) {
        if (json == null) {
          throw ChannelError(code: ChannelErrorCode.paramError, message: '用户信息为空');
        }
        // 检查是否为错误结果
        if (json is Map && json.containsKey('code') && json['code'] != 0) {
          throw ChannelError(
            code: json['code'] as int,
            message: json['message'] as String,
            extra: json['extra'] != null ? Map<String, dynamic>.from(json['extra'] as Map) : null,
          );
        }
        // 确保json是Map类型
        if (json is Map) {
          // 安全转换为Map<String, dynamic>类型
          final jsonMap = Map<String, dynamic>.from(json);
          return UserInfo.fromJson(jsonMap);
        } else {
          throw ChannelError(code: ChannelErrorCode.nativeError, message: '返回数据格式错误，不是Map类型');
        }
      },
    );
  }

  @override
  Future<UserInfo> getUserInfoNoParam() async {
    return _channel.invokeMethod<UserInfo>(
      method: 'getUserInfoNoParam',
      params: null, // 不传递参数
      resultConverter: (json) {
        if (json == null) {
          throw ChannelError(code: ChannelErrorCode.paramError, message: '用户信息为空');
        }
        // 检查是否为错误结果
        if (json is Map && json.containsKey('code') && json['code'] != 0) {
          throw ChannelError(
            code: json['code'] as int,
            message: json['message'] as String,
            extra: json['extra'] != null ? Map<String, dynamic>.from(json['extra'] as Map) : null,
          );
        }
        // 确保json是Map类型
        if (json is Map) {
          // 安全转换为Map<String, dynamic>类型
          final jsonMap = Map<String, dynamic>.from(json);
          return UserInfo.fromJson(jsonMap);
        } else {
          throw ChannelError(code: ChannelErrorCode.nativeError, message: '返回数据格式错误，不是Map类型');
        }
      },
    );
  }

  @override
  Future<String> getUserInfoString({required String param}) async {
    return _channel.invokeMethod<String>(
      method: 'getUserInfoString',
      params: param, // 直接传递字符串参数
      resultConverter: (result) {
        // 检查是否为错误结果
        debugPrint("getUserInfoString, result: $result, result type: ${result.runtimeType}");
        // 更明确的条件检查和日志
        if (result is! String) {
          debugPrint("Result is not String type: ${result.runtimeType}");
          throw ChannelError(
            code: ChannelErrorCode.nativeError,
            message: "result is not String type",
            extra: null,
          );
        }
        if (result.isEmpty) {
          debugPrint("Result is empty string");
          throw ChannelError(
            code: ChannelErrorCode.nativeError,
            message: "result is empty string",
            extra: null,
          );
        }
        return result;
      },
    );
  }
}