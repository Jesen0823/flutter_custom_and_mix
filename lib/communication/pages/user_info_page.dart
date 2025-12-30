import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/communication/controllers/user_info_controller.dart';
import 'package:get/get.dart';

class UserInfoPagePage extends GetView<UserInfoController> {
  const UserInfoPagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户信息获取'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 错误信息展示
              Obx(() {
                if (controller.errorMessage.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // 按钮1 - 获取JSON格式用户信息
              ElevatedButton(
                onPressed: controller.getUserInfoJson,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Obx(() {
                  return controller.isLoadingJson.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('获取JSON格式用户信息');
                }),
              ),

              // 结果展示1
              Obx(() {
                if (controller.resultJson.value != null) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('JSON格式结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('用户ID: ${controller.resultJson.value?.userId}'),
                          Text('用户名称: ${controller.resultJson.value?.username}'),
                          Text('用户年龄: ${controller.resultJson.value?.age}'),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 12);
              }),

              // 按钮2 - 获取Model格式用户信息
              ElevatedButton(
                onPressed: controller.getUserInfoModel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Obx(() {
                  return controller.isLoadingModel.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('获取Model格式用户信息');
                }),
              ),

              // 结果展示2
              Obx(() {
                if (controller.resultModel.value != null) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Model格式结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('用户ID: ${controller.resultModel.value?.userId}'),
                          Text('用户名称: ${controller.resultModel.value?.username}'),
                          Text('用户年龄: ${controller.resultModel.value?.age}'),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 12);
              }),

              // 按钮3 - 无参数获取用户信息
              ElevatedButton(
                onPressed: controller.getUserInfoNoParam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Obx(() {
                  return controller.isLoadingNoParam.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('无参数获取用户信息');
                }),
              ),

              // 结果展示3
              Obx(() {
                if (controller.resultNoParam.value != null) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('无参数结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('用户ID: ${controller.resultNoParam.value?.userId}'),
                          Text('用户名称: ${controller.resultNoParam.value?.username}'),
                          Text('用户年龄: ${controller.resultNoParam.value?.age}'),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 12);
              }),

              // 按钮4 - 获取字符串格式用户信息
              ElevatedButton(
                onPressed: controller.getUserInfoString,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Obx(() {
                  return controller.isLoadingString.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('获取字符串格式用户信息');
                }),
              ),

              // 结果展示4
              Obx(() {
                if (controller.resultString.value.isNotEmpty) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('字符串格式结果:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(controller.resultString.value),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 12);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
