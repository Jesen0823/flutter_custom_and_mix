import 'package:flutter/material.dart';

/// 负责封装通用表单组件（手机号输入框、密码输入框）
/// 不包含任何业务逻辑，可复用在其他页面
/// 手机号输入框
///
/// [表单场景的性能痛点分析]
// 登录表单本身是轻量级组件，默认情况下渲染性能问题不显著，但在以下场景会出现性能损耗：
// 1.局部更新导致整体重绘：
// 输入框实时校验、保存的表单值变化时，触发setState导致整个登录页面（包括按钮、空白区域）重绘；
// 2.频繁重绘：
// 输入框输入时，onChanged/ 实时校验会频繁触发重绘，若表单字段多（如新增验证码、昵称），损耗会放大；
// 3.不必要的布局计算：
// Column 嵌套无约束控制，导致布局范围过大；
// 4.临时对象创建：
// build 中创建样式、回调函数等临时对象，增加 GC 压力；
// 5.无绘制隔离：
// 输入框校验提示变化时，整个表单区域（甚至页面）一起重绘，而非仅重绘变化的输入框。
//
/// 二、核心优化手段（结合表单场景）
// 1. RepaintBoundary：隔离绘制层（核心）
// 原理：RepaintBoundary会为子组件创建独立的绘制图层（Layer），当子组件需要重绘时，仅重绘该图层，而非整个父组件 / 页面。适用场景：表单中 “频繁重绘的局部组件”（输入框、校验提示、保存值展示区）。注意：不要滥用！每个RepaintBoundary会增加图层开销，仅用于 “高频重绘” 的组件，轻量静态组件（如按钮、静态文本）无需添加。
// 2. 减少 build 次数（避免整体重建）
// 用ValueNotifier + Consumer替代全局setState：局部状态更新仅触发目标组件重建，而非整个页面；
// 拆分组件粒度：将 “保存值展示区”“功能按钮组” 拆为独立组件，避免局部状态变化导致整体 build；
// 利用const构造函数：无状态组件 / 静态样式用const，复用 Widget 实例，减少重建。
// 3. 避免临时对象创建
// 提取常量样式（如按钮样式、输入框装饰器）：避免在 build 中重复创建BoxDecoration/ElevatedButton.styleFrom；
// 回调函数提前绑定（如onSaved/validator）：避免 build 中每次创建新的函数实例。
// 4. 优化布局与渲染逻辑
// 限制布局范围：Column 设置mainAxisSize: MainAxisSize.min，避免无意义的布局计算；
// 延迟初始化：控制器 / GlobalKey 在initState创建（而非 build），避免重复创建；
// 优化表单校验：AutovalidateMode仅在用户交互时触发（onUserInteraction），避免初始 / 无意义的校验。

// 提取静态装饰器常量（避免build中重复创建）
const InputDecoration _phoneInputDecoration = InputDecoration(
  labelText: "手机号",
  hintText: "请输入11位手机号",
  border: OutlineInputBorder(borderRadius: BorderRadius.horizontal()),
);

const InputDecoration _passwordInputDecoration = InputDecoration(
  labelText: "密码",
  hintText: "请输入6-16位密码",
  border: OutlineInputBorder(),
);

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
    // 绘制边界：输入框校验提示变化时，仅重绘此区域
    return RepaintBoundary(
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: _passwordInputDecoration,
        validator: validator,
        onSaved: onSaved,
        // 绑定保存回调
        textInputAction: TextInputAction.next, // 下一步聚焦密码框
      ),
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
    // 绘制边界
    return RepaintBoundary(
      child: TextFormField(
        controller: controller,
        obscureText: true,
        // 隐藏密码
        decoration: _passwordInputDecoration,
        validator: validator,
        onSaved: onSaved,
        textInputAction: TextInputAction.done, // 完成输入
      ),
    );
  }
}
