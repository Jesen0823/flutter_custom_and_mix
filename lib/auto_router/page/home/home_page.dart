import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/auto_router/router/auth_state.dart';

import '../../model/goods_entity.dart';
import '../../router/app_router.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              AuthState.isLogin = false;
              AutoRouter.of(context).navigate(LoginRoute());
            },
            icon: Icon(Icons.logout, color: Colors.pinkAccent),
          ),
        ],
      ),
      body: Container(
        color: Colors.pinkAccent.shade100,
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // 基础跳转（无参数）
                  AutoRouter.of(context).push(DetailRoute());
                },
                child: const Text('不带参数-跳转到详情页'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 带参数跳转
                  AutoRouter.of(context).push(
                    DetailRoute(
                      id: '123456', // 路径参数（必选）
                      title: '商品详情', // 查询参数（可选）
                      count: 10,
                    ),
                  );
                },
                child: const Text('带参数-跳转到详情页'),
              ),
              ElevatedButton(
                onPressed: () {
                  final goods = GoodsEntity(
                    id: '123',
                    name: '手机',
                    price: 2999.99,
                  );
                  // 带对象跳转
                  AutoRouter.of(context).push(
                    DetailRoute(
                      id: '13579', // 路径参数（必选）
                      title: '带商品对象的-商品详情', // 查询参数（可选）
                      count: 12,
                      goods: goods,
                    ),
                  );
                },
                child: const Text('带自定义对象与参数-跳转到详情页'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // 跳转并等待返回值
                  final result = await AutoRouter.of(
                    context,
                  ).push<String>(DetailRoute(id: '123456'));
                  if (result != null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('返回值：$result')));
                    }
                  }
                },
                child: const Text('跳转详情并接收返回值'),
              ),
              ElevatedButton(
                onPressed: () {
                  AutoRouter.of(context).push(const TabRoute());
                },
                child: const Text('跳转到Tab页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
