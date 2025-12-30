import 'package:get/get.dart';
import '../core/services/api_service.dart';

/// 未绑定页控制器
class ComHomeController extends GetxController {
  final ApiService _apiService;
  final RxBool _isLoading = true.obs; // 加载状态（响应式）
  final RxString _imageUrl = "".obs; // 图片地址（响应式）

  ComHomeController(this._apiService);

  bool get isLoading => _isLoading.value;
  String get imageUrl => _imageUrl.value;

  @override
  void onInit() {
    super.onInit();
    _loadUnbindImage(); // 初始化时加载图片
  }

  /// 加载绑定页面图片
  Future<void> _loadUnbindImage() async {
    try {
      _isLoading.value = true;
      final url = await _apiService.getUnbindImage();
      _imageUrl.value = url;
    } catch (e) {
      // 异常处理
      _imageUrl.value = "";
    } finally {
      _isLoading.value = false;
    }
  }

  /// 点击刷新按钮（重新加载图片）
  void onRefreshClick() {
    _loadUnbindImage();
  }

  /// 点击关闭按钮（返回）
  void onCloseClick() {
    Get.back(); // 关闭弹窗
    // 若需返回首页，可使用：Get.offAllNamed(AppRoutes.home);
  }

  /// 点击绑定账号按钮
  void onBindAccountClick() {
    // 示例：跳首页（真实项目替换为绑定流程）
    //Get.offAllNamed(AppRoutes.comHome);
  }
}