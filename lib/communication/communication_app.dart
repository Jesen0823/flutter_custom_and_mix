import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/communication/bindings/com_home_binding.dart';
import 'package:flutter_custom_and_mix/communication/bindings/user_info_binding.dart';
import 'package:flutter_custom_and_mix/communication/pages/splash_page.dart';
import 'package:flutter_custom_and_mix/communication/pages/unbind_page.dart';
import 'package:flutter_custom_and_mix/communication/pages/com_home_page.dart';
import 'package:flutter_custom_and_mix/communication/pages/user_info_page.dart';
import 'package:get/get.dart';
import 'bindings/splash_binding.dart';
import 'bindings/unbind_binding.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_styles.dart';

class CommunicationApp extends StatelessWidget {
  const CommunicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX 企业级Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: AppStyles.bgColor,
      ),
      debugShowCheckedModeBanner: false,
      // 初始路由
      initialRoute: AppRoutes.splash,
      // 路由配置
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashPage(),
          binding: SplashBinding(),
        ),
        GetPage(
          name: AppRoutes.unbind,
          page: () => const UnbindPage(),
          binding: UnbindBinding(),
          // 弹窗样式配置（更贴合需求）
          fullscreenDialog: true,
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: AppRoutes.comHome,
          page: () => const ComHomePage(),
          binding: ComHomeBinding(),
        ),
        GetPage(
          name: AppRoutes.userInfo,
          page: () => const UserInfoPagePage(),
          binding: UserInfoBinding(),
        ),

      ],
    );
  }
}