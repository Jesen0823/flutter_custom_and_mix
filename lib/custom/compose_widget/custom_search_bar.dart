import 'package:flutter/material.dart';

/// 自定义搜索框：组合TextField + IconButton + 装饰
///
/// 组合式自定义 Widget 是 Flutter 开发中最基础、最高频的方式，核心是将现有基础 Widget（如Container、Row、TextField）按业务需求组合封装，对外暴露简洁的 API，隐藏内部实现细节。
// 这种方式无需了解底层渲染原理，开发成本极低，是企业开发中80% 的自定义组件需求的解决方案。
// 适用场景
// 通用 UI 组件：如自定义搜索框、带图标的按钮、商品卡片、列表项；
// 业务组件：如电商的商品价格标签、社交的消息条目、金融的收益卡片。
//
// 核心优势
// 开发成本极低：仅需组合现有 Widget，无需了解底层渲染；
// 可维护性强：内部实现封装，对外暴露少量 API，便于团队协作；
// 扩展性好：可通过参数快速扩展功能（如添加搜索历史、联想词）。

class CustomSearchBar extends StatelessWidget {
  // 输入框控制器
  final TextEditingController? controller;

  // 提示文字
  final String hintText;

  // 搜索回调
  final ValueChanged<String>? onSearch;

  // 清除输入回调
  final VoidCallback? onClear;

  // 输入框宽度
  final double width;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.hintText = "请输入搜索内容",
    this.onSearch,
    this.onClear,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          // 搜索输入框
          Expanded(
            flex: 1,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
              onSubmitted: onSearch,
            ),
          ),
          // 清除按钮
          ?controller?.text.isNotEmpty == true?
            IconButton(
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
              icon: const Icon(Icons.clear, color: Colors.black54, size: 18),
            ):null,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
