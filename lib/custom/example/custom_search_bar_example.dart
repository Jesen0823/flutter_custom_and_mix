import 'package:flutter/material.dart';

import '../compose_widget/custom_search_bar.dart';

class CustomSearchBarExample extends StatelessWidget {
  const CustomSearchBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("组合式自定义Widget搜索框")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomSearchBar(
          controller: controller,
          hintText: "搜索商品/店铺",
          onSearch: (value) => print("搜索：$value"),
          onClear: () => print("清除输入"),
        ),
      ),
    );
  }
}