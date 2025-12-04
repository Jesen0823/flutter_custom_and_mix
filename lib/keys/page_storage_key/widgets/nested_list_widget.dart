import 'package:flutter/material.dart';

/// 封装嵌套列表，解决滚动冲突并设置 PageStorageKey
class NestedListWidget extends StatelessWidget {
  // 唯一的PageStorageKey用来保存滚动位置
  final PageStorageKey<String> storageKey;

  // 列表长度
  final int itemCount;

  const NestedListWidget({
    super.key,
    required this.storageKey,
    this.itemCount = 30,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: storageKey,
      // 禁止嵌套列表独立滚动,交给外层SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      // 高度包裹（避免滚动冲突）
      // 外层 SingleChildScrollView 是 “无边界约束”（垂直方向高度随内容变化），
      // 若内层 ListView 保持 shrinkWrap: false，会因无法确定 “最大高度” 触发布局报错；
      // 设 shrinkWrap: true 后，内层 ListView 高度仅包裹自身子项，避免了无边界约束的冲突，
      // 配合 NeverScrollableScrollPhysics() 还能让滚动逻辑交给外层，解决嵌套滚动冲突。
      // shrinkWrap 的本质是牺牲性能换布局灵活性：仅在布局约束不允许 “占满最大尺寸” 时使用，否则优先保持默认值以避免不必要的性能损耗。
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            "嵌套列表项 ${index + 1}",
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }
}
