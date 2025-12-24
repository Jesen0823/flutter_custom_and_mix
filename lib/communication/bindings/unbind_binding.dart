import 'package:get/get.dart';

import '../controllers/unbind_controller.dart';
import '../core/services/api_service.dart';
/// 未绑定页绑定：注入UnbindController和ApiService
class UnbindBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiService()); // 接口服务
    Get.lazyPut(() => UnbindController(Get.find<ApiService>())); // 控制器依赖注入
  }
}