import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/communication/controllers/com_home_controller.dart';
import 'package:get/get.dart';

import '../core/constants/app_styles.dart';
Size size = Size.zero;
/// 首页（占位）
class ComHomePage extends GetView<ComHomeController> {
  const ComHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent, // 透明背景，实现弹窗效果
        body: Center(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: const BoxDecoration(
              color: AppStyles.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppStyles.radiusTop),
                topRight: Radius.circular(AppStyles.radiusTop),
              ),
            ),
            child: Column(
              children: [
                // 顶部AppBar（自定义，更美观）
                _buildAppBar(),
                const SizedBox(height: AppStyles.paddingLarge),
                // 中间图片占位区
                _buildImageArea(),
                const Spacer(),
                // 底部绑定按钮
                _buildBindButton(),
                const SizedBox(height: AppStyles.marginBottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建自定义AppBar
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(AppStyles.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左侧关闭按钮
          IconButton(
            icon: const Icon(Icons.close, color: AppStyles.blackColor),
            onPressed: controller.onCloseClick,
            iconSize: 24,
          ),
          // 中间标题
          Text(
            "首页",
            style: TextStyle(
              fontSize: AppStyles.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppStyles.blackColor,
            ),
          ),
          // 右侧刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh, color: AppStyles.blackColor),
            onPressed: controller.onRefreshClick,
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  /// 构建图片占位区（加载动画+图片展示）
  Widget _buildImageArea() {
    return Obx(() {
      if (controller.isLoading) {
        // 绿色转圈加载动画
        return const CircularProgressIndicator(
          color: AppStyles.primaryColor,
          strokeWidth: 3,
        );
      } else if (controller.imageUrl.isNotEmpty) {
        // 图片展示（圆角+裁剪，美观）
        return Container(
          width: size.width * 0.8,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppStyles.grayColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CachedNetworkImage(
            imageUrl: controller.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(
              color: AppStyles.primaryColor,
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.nearby_off_sharp,
              size: 50,
              color: AppStyles.grayColor,
            ),
          ),
        );
      } else {
        // 图片加载失败占位
        return Container(
          width: size.width * 0.8,
          height: 200,
          decoration: BoxDecoration(
            color: AppStyles.bgColor,
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          ),
          child: const Icon(
            Icons.image,
            size: 50,
            color: AppStyles.grayColor,
          ),
        );
      }
    });
  }

  /// 构建绑定账号按钮
  Widget _buildBindButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppStyles.paddingLarge),
      child: ElevatedButton(
        style: AppStyles.primaryButtonStyle,
        onPressed: controller.onBindAccountClick,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_box, color: AppStyles.whiteColor),
            const SizedBox(width: 10),
            Text(
              "绑定账号",
              style: TextStyle(
                fontSize: AppStyles.fontSizeMedium,
                color: AppStyles.whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}