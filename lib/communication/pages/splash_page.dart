import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../core/constants/app_styles.dart';

/// 启动页
class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            Image.asset(
              "assets/images/splash_bg.png",
              fit: BoxFit.cover,
            ),
            // 右上角倒计时
            Positioned(
              top: AppStyles.paddingLarge,
              right: AppStyles.paddingLarge,
              child: Obx(() => Text(
                "${controller.countDown}s",
                style: AppStyles.countDownStyle,
              )),
            ),
            // 底部跳过按钮
            Positioned(
              bottom: AppStyles.marginBottom,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: controller.onSkipClick,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppStyles.paddingMedium,
                      vertical: AppStyles.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppStyles.whiteColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                    ),
                    child: Text(
                      "跳过",
                      style: TextStyle(
                        color: AppStyles.blackColor,
                        fontSize: AppStyles.fontSizeMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}