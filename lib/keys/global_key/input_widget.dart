import 'package:flutter/material.dart';

/// 负责封装通用表单组件（手机号输入框、密码输入框）
/// 不包含任何业务逻辑，可复用在其他页面
/// 手机号输入框
class PhoneInput extends StatelessWidget {
  // 接收外部传入的控制器，用于跨组件获取输入值
  final TextEditingController controller;

  // 接收外部传递的验证器,用于表单验证
  final String? Function(String?) validator;

  // 表单保存时的回调（由FormState.save()触发
  final void Function(String?)? onSaved;

  const PhoneInput({
    super.key,
    required this.controller,
    required this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: "手机号",
        hintText: "请输入11位手机号",
        border: OutlineInputBorder(borderRadius: BorderRadius.horizontal()),
      ),
      validator: validator,
      onSaved: onSaved,
      // 绑定保存回调
      textInputAction: TextInputAction.next, // 下一步聚焦密码框
    );
  }
}

/// 通用密码输入框
class PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final void Function(String?)? onSaved;

  const PasswordInput({
    super.key,
    required this.controller,
    required this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      // 隐藏密码
      decoration: const InputDecoration(
        labelText: "密码",
        hintText: "请输入6-16位密码",
        border: OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
      textInputAction: TextInputAction.done, // 完成输入
    );
  }
}
