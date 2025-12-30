import 'package:flutter_custom_and_mix/communication/channel/base/channel_error.dart';
import 'package:flutter_custom_and_mix/communication/channel_service/method/user_channel_service.dart';
import 'package:flutter_custom_and_mix/communication/model/user_entity.dart';
import 'package:get/get.dart';

class UserInfoController extends GetxController {
  static final IUserChannelService _channelService = UserChannelServiceImpl();

  // 加载状态管理
  final RxBool isLoadingJson = false.obs;
  final RxBool isLoadingModel = false.obs;
  final RxBool isLoadingNoParam = false.obs;
  final RxBool isLoadingString = false.obs;

  // 结果管理
  final Rx<UserInfo?> resultJson = Rx<UserInfo?>(null);
  final Rx<UserInfo?> resultModel = Rx<UserInfo?>(null);
  final Rx<UserInfo?> resultNoParam = Rx<UserInfo?>(null);
  final RxString resultString = "".obs;

  // 错误信息
  final RxString errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    _listenerNativeMethod();
  }

  /// 按钮点击事件 - 获取JSON格式用户信息
  Future<void> getUserInfoJson() async {
    try {
      isLoadingJson(true);
      errorMessage("");
      String paramStr = "Jesen.Mr";
      UserInfo info = await _channelService.getUserInfoJson(param: paramStr);
      resultJson(info);
    } catch (e) {
      _handleError(e, "JSON请求失败");
    } finally {
      isLoadingJson(false);
    }
  }

  /// 按钮点击事件 - 获取Model格式用户信息
  Future<void> getUserInfoModel() async {
    try {
      isLoadingModel(true);
      errorMessage("");
      UserParam user = UserParam(userId: "id_001", token: "test_token_2024");
      UserInfo info = await _channelService.getUserInfoModel(param: user);
      resultModel(info);
    } catch (e) {
      _handleError(e, "Model请求失败");
    } finally {
      isLoadingModel(false);
    }
  }

  /// 按钮点击事件 - 无参数获取用户信息
  Future<void> getUserInfoNoParam() async {
    try {
      isLoadingNoParam(true);
      errorMessage("");
      UserInfo info = await _channelService.getUserInfoNoParam();
      resultNoParam(info);
    } catch (e) {
      _handleError(e, "无参数请求失败");
    } finally {
      isLoadingNoParam(false);
    }
  }

  /// 按钮点击事件 - 获取字符串格式用户信息
  Future<void> getUserInfoString() async {
    try {
      isLoadingString(true);
      errorMessage("");
      String param = "ZhangXi";
      String info = await _channelService.getUserInfoString(param: param);
      resultString(info);
    } catch (e) {
      _handleError(e, "字符串请求失败");
    } finally {
      isLoadingString(false);
    }
  }

  /// 处理错误信息
  void _handleError(dynamic error, String defaultMessage) {
    if (error is ChannelError) {
      errorMessage("${error.message} (${error.code})");
    } else {
      errorMessage("$defaultMessage: ${error.toString()}");
    }
  }

  /// 监听原生方法调用
  void _listenerNativeMethod() {
    // 注册方法调用处理器，接收来自原生的回调
    _channelService.registerUserFunctionHandler(onHandler: () {
      // 处理原生调用的onLogout方法
      Get.snackbar("提示", "用户已退出登录");
      // 可以在这里执行退出登录后的逻辑，如清除用户信息、跳转到登录页等
    });
  }
}
