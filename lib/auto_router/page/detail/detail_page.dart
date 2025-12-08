import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../model/goods_entity.dart';

/// 1. 定义基础类路由参数类（企业级：参数单独拆分，便于维护）
class DetailPageArgs {
  final String id; // 必选参数
  final String? title; // 可选参数
  final int count; // 必选参数（带默认值）

  DetailPageArgs({
    required this.id,
    this.title,
    this.count = 0, // 默认值
  });
}

@RoutePage()
class DetailPage extends StatelessWidget {
  // 接收路由参数（10.x 推荐用@pathParam/@queryParam注解，或直接传参）
  final String? id;
  final String? title;
  final int? count;
  final GoodsEntity? goods; // 自定义对象参数

  const DetailPage({
    super.key,
    @pathParam this.id = "", // 路径参数（拼接在URL中）
    @queryParam this.title, // 查询参数（?title=xxx）
    @queryParam this.count = 0,
    this.goods, // 自定义对象（非URL参数，内存传递）
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail")),
      body: Container(
        color: Colors.greenAccent.shade100,
        child: Center(
          child: Column(
            children: [
              Text("详情页 ID：$id\n数量：$count"),
              if (goods != null) Text('商品：${goods!.toJson().toString()}'),
              const SizedBox(height: 20),
              // 2. 详情页返回数据（detail_page.dart）
              ElevatedButton(
                onPressed: () {
                  // 返回数据并关闭页面
                  AutoRouter.of(context).pop('操作成功');
                },
                child: const Text('返回首页并传值'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
