import 'package:flutter_custom_and_mix/communication/controllers/com_home_controller.dart';
import 'package:flutter_custom_and_mix/communication/core/services/api_service.dart';
import 'package:get/get.dart';

/// 首页页绑定：注入ComHomeController
class ComHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiService()); // 接口服务
    Get.lazyPut(() => ComHomeController(Get.find<ApiService>())); // 控制器依赖注入
  }
}