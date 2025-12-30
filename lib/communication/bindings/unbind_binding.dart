import 'package:get/get.dart';

import '../controllers/unbind_controller.dart';
/// 未绑定页绑定：注入UnbindController和ApiService
class UnbindBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UnbindController());
  }
}