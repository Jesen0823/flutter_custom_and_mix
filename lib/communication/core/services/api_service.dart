import 'package:dio/dio.dart';

/// 接口服务（单例+依赖注入，企业级规范）
class ApiService {
  late Dio _dio;

  ApiService() {
    // 初始化Dio
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));
    // 可添加拦截器（日志、token、错误处理）
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  /// 模拟获取绑定页面图片（真实项目替换为后端接口）
  Future<String> getUnbindImage() async {
    // 模拟接口延迟
    await Future.delayed(const Duration(milliseconds: 1500));
    // 测试图片地址（网络图片）
    return "https://picsum.photos/800/400";
  }
}