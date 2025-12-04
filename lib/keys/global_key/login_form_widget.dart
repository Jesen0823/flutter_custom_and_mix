import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/keys/global_key/input_widget.dart';

import 'debouncer.dart';

/// 登录表单
/// 组合输入框，接收GlobalKey关联Form
///
/// 优化:
// 表单整体添加RepaintBoundary（隔离表单与页面其他区域）；
// 布局优化：Column 设置mainAxisSize: MainAxisSize.min
// 输入框防抖：实时校验添加 50ms 防抖，减少高频校验触发的重绘；
// 缓存校验结果：用Map缓存输入值的校验结果，避免重复计算；
// 使用ListView替代 Column：若表单字段极多，用ListView(shrinkWrap: true)减少初始布局计算。

class LoginFormWidget extends StatefulWidget {
  // 接收外部传入的GlobalKey,用来跨组件关联FormState
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  // 扩展Form配置，支持自动验证,保存手机号/密码的回调,透传给输入框
  final void Function(String?)? onPhoneSaved;
  final void Function(String?)? onPasswordSaved;

  const LoginFormWidget({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.passwordController,
    this.onPhoneSaved,
    this.onPasswordSaved,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  late final Debouncer _formDebouncer; // 表单防抖器

  // 静态校验函数（引用固定，不随build变化）
  static String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) return "请输入手机号";
    if (!RegExp(r'^1\d{10}$').hasMatch(value)) return "请输入正确的手机号";
    return null;
  }
  // 静态校验函数（引用固定，不随build变化）
  static String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "请输入密码";
    } else if (value.length < 6 || value.length > 16) {
      return "密码长度需6-16位";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 配置Form的自动验证模式（方便currentWidget获取
    return RepaintBoundary(
      child: Form(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction, // 输入交互时自动验证
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhoneInput(
              key: const ValueKey("phone_input"),
              controller: widget.phoneController,
              // 验证规则由外部定义,组件只负责UI，不关心业务规则
              validator: _phoneValidator,
              onSaved: widget.onPhoneSaved, // 传递保存回调
            ),
            const SizedBox(height: 16),
            PasswordInput(
              key: const ValueKey("password_input"),
              controller: widget.passwordController,
              validator: _passwordValidator,
              onSaved: widget.onPasswordSaved,
            ),
          ],
        ),
      ),
    );
  }
}

