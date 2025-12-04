import 'package:flutter/material.dart';

/// LabeledGlobalKey 实现动态表单验证
/// 动态添加的表单（如添加联系人，可新增多个手机号输入框，每个输入框独立验证）。
class LabeledGlobalKeyDynamicFormPage extends StatefulWidget {
  const LabeledGlobalKeyDynamicFormPage({super.key});

  @override
  State<LabeledGlobalKeyDynamicFormPage> createState() =>
      _LabeledGlobalKeyDynamicFormPageState();
}

class _LabeledGlobalKeyDynamicFormPageState
    extends State<LabeledGlobalKeyDynamicFormPage> {
  // 存储多个LabeledGlobalKey,标签为输入框索引
  final List<LabeledGlobalKey<FormFieldState<String>>> _fieldKeys = [
    LabeledGlobalKey("0"), // 第一个输入框的Key
  ];

  // 存储输入框内容
  final List<TextEditingController> _controllers = [TextEditingController()];

  // 添加新的输入框
  void _addField() {
    setState(() {
      final index = _fieldKeys.length;
      _fieldKeys.add(LabeledGlobalKey("$index"));
      _controllers.add(TextEditingController());
    });
  }

  // 验证所有输入框
  void _validateAll() {
    bool allValid = true;
    for (final key in _fieldKeys) {
      if (!key.currentState!.validate()) {
        allValid = false;
      }
    }
    if (allValid) {
      final phones = _controllers.map((c) => c.text).toList();
      debugPrint("所有手机号：$phones");
    }
  }

  // 移除输入框
  void _removeField(int index) {
    setState(() {
      _fieldKeys.removeAt(index);
      _controllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("动态联系人表单")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 动态生成输入框
            ...List.generate(_fieldKeys.length, (index) {
              return TextFormField(
                key: _fieldKeys[index],
                // 用LabeledGlobalKey区分每个输入框
                controller: _controllers[index],
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "手机号 ${index + 1}",
                  suffixIcon: IconButton(
                    onPressed: () => _removeField(index),
                    icon: const Icon(Icons.delete),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "请输入手机号";
                  } else if (!RegExp(r'^1\d{10}$').hasMatch(value)) {
                    return "格式错误";
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _addField, child: const Text("添加手机号")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _validateAll, child: const Text("提交")),
          ],
        ),
      ),
    );
  }
}
