import 'package:flutter_custom_and_mix/communication/controllers/user_info_controller.dart';
import 'package:get/get.dart';

/// 用户信息页绑定：注入UserInfoController
class UserInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserInfoController());
  }
}