import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/keys/global_key/input_widget.dart';

/// 登录表单
/// 组合输入框，接收GlobalKey关联Form
class LoginFormWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // 配置Form的自动验证模式（方便currentWidget获取
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction, // 输入交互时自动验证
      onChanged: () {
        // 表单内容变化时的回调（可通过currentWidget获取）
        debugPrint("表单内容已变化");
      },
      child: Column(
        children: [
          PhoneInput(
            controller: phoneController,
            // 验证规则由外部定义,组件只负责UI，不关心业务规则
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "请输入手机号";
              } else if (!RegExp(r'^1\d{10}$').hasMatch(value)) {
                return "请输入正确的手机号";
              }
              return null;
            },
            onSaved: onPhoneSaved, // 传递保存回调
          ),
          const SizedBox(height: 16),
          PasswordInput(
            controller: passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "请输入密码";
              } else if (value.length < 6 || value.length > 16) {
                return "密码长度需6-16位";
              }
              return null;
            },
            onSaved: onPasswordSaved,
          ),
        ],
      ),
    );
  }
}
