import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/keys/global_key/login_form_widget.dart';

import 'debouncer.dart';
import 'login_widget.dart';

/// 登录页面
/// 负责页面布局、业务逻辑（登录触发、状态管理），
/// 持有 GlobalKey 并传递给表单组件，通过 Key 实现跨文件、跨组件的表单验证和值获取。
///
/// 添加「重置表单」「查看表单信息」按钮；
// 集成currentContext：获取表单组件尺寸、判断挂载状态、弹自定义 SnackBar；
// 集成currentWidget：打印 / 展示 Form 的配置属性（如 autovalidateMode）；
// 集成currentState：调用reset()（重置表单）、save()（保存表单值）、validate()（验证）；
///
/// 优化:
// 用ValueNotifier替代setState管理保存的表单值（局部更新）；
// 拆分 “保存值展示区”“功能按钮组” 为独立组件；
// 提取常量样式，避免临时对象；
// 关键区域添加RepaintBoundary；
// 延迟初始化控制器 / GlobalKey；
//
/// 开发中的额外规范
// 1. GlobalKey 的管理
// 避免在 Widget 树中频繁创建 GlobalKey（如在build方法中创建），应在State类中初始化（如案例中在_LoginPageState的成员变量中定义），确保 Key 的唯一性和稳定性；
// 若需多个 GlobalKey（如多表单场景），可封装为GlobalKeyManager单例类统一管理，避免散落在各个页面。
// 2. 组件复用性
// form_widgets.dart 中的组件（PhoneInput、PasswordInput）不绑定任何业务逻辑，通过参数接收验证规则、控制器等，可直接复用于注册页、修改手机号页等场景；
// 业务逻辑（如登录请求、参数校验）集中在LoginPage，符合 “单一职责原则”。
// 3. 内存泄漏防护
// 控制器（TextEditingController）的生命周期由业务页面（LoginPage）管理，在dispose方法中手动销毁，避免内存泄漏；
// GlobalKey 不会导致内存泄漏（Flutter 内部会自动管理 Element 的引用），但需确保不再使用时避免持有冗余引用。

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 创建GlobalKey,全局唯一，跨组件访问FormState
  late final GlobalKey<FormState> _formKey;

  // 输入框控制器，与表单分离
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  // 用ValueNotifier管理保存的表单值（局部更新，替代setState）
  final ValueNotifier<Map<String, String?>> _savedValueNotifier = ValueNotifier(
    {},
  );
  // 若必须保留onChanged，添加防抖（避免高频触发）
  static final Debouncer formDebouncer = Debouncer(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    // 初始化放在initState，避免build中重复创建
    _formKey = GlobalKey<FormState>();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  // 登录逻辑,currentContext
  Future<void> _handleLogin() async {
    // 使用currentState：核心表单操作
    final formState = _formKey.currentState;
    if (formState == null) {
      _showSnackBar("表单状态为空，请检查GlobalKey");
      return;
    }
    // 跨组件访问FormState：通过GlobalKey触发表单验证
    if (formState.validate()) {
      formState.save();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      // 仅更新ValueNotifier，不调用setState
      _savedValueNotifier.value = {
        'phone': phone,
        'password': password,
      };
      _showSnackBar("登录中... 手机号：$phone，密码：$password");
      await Future.delayed(const Duration(milliseconds: 3000));

      // 使用currentContext：判断挂载状态 + 导航
      if (_formKey.currentContext?.mounted ?? false) {
        Navigator.pushReplacementNamed(
          _formKey.currentContext!, // 直接使用表单的上下文导航（替代页面context）,
          "/global_home",
          arguments: {"phone": phone, "savedPhone": _savedValueNotifier.value['phone']},
        );
      }
    }
  }

  // 重置表单，currentState
  void _handleReset() {
    final formState = _formKey.currentState;
    if (formState == null) {
      _showSnackBar("表单状态为空，无法重置");
      return;
    }
    // 重置表单：清空输入框 + 清除验证错误提示
    formState.reset();
    // 清空保存的临时值
    _savedValueNotifier.value = {}; // 局部更新，仅触发SavedFormValueWidget重绘
    _showSnackBar("表单已重置");
  }

  // 查看表单信息（currentWidget + currentContext）
  void _showFormInfo() {
    // 使用currentWidget,获取Form的配置属性
    final formWidget = _formKey.currentWidget as Form?;
    // 使用currentContext：获取表单组件尺寸
    final formContext = _formKey.currentContext;
    if (formWidget == null || formContext == null) {
      _showSnackBar(formWidget == null ? "表单Widget为空！" : "表单上下文为空！");
      return;
    }

    // 获取表单组件的尺寸（通过RenderObject）
    final renderBox = formContext.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;
    final formInfo =
        """
    📋 表单配置信息：
    • 自动验证模式：${formWidget.autovalidateMode.name}
    • 表单尺寸：宽${size.width.toStringAsFixed(1)}px，高${size.height.toStringAsFixed(1)}px
    • 表单主题色：${Theme.of(formContext).primaryColor}
    """;
    _showDialog(formContext, "表单详细信息", formInfo);
  }

  // 封装SnackBar,使用表单的currentContext
  void _showSnackBar(String message) {
    final formContext = _formKey.currentContext;
    if (formContext?.mounted ?? false) {
      ScaffoldMessenger.of(formContext!).showSnackBar(
        SnackBar(duration: Duration(seconds: 2), content: Text(message)),
      );
    }
  }

  void _showDialog(BuildContext ctx, String title, String msg) {
    showDialog(
      context: ctx,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("关闭"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // 销毁控制器，避免内存泄漏
    _phoneController.dispose();
    _passwordController.dispose();
    _savedValueNotifier.dispose();
    formDebouncer.dispose();
    super.dispose();
  }

  // 手机号保存回调：引用固定，避免build中动态创建
  void _onPhoneSaved(String? value){
    _savedValueNotifier.value = {
      ..._savedValueNotifier.value,
      'phone': value?.trim(),
    };
  }

  // 密码保存回调：引用固定
  void _onPasswordSaved(String? value) {
    _savedValueNotifier.value = {
      ..._savedValueNotifier.value,
      'password': value?.trim(),
    };
  }

  // 表单内容独立组件：仅表单相关变化时重建
   Widget _formContent() {
    return Column(
      children: [
        // 保存值展示（局部更新，仅值变化时重绘）
        SavedFormValueWidget(savedValueNotifier: _savedValueNotifier),
        // 引入独立的表单容器，传递GlobalKey和控制器,跨组件关联
        LoginFormWidget(
          key: const ValueKey("login_form"), // 固定Key，避免重建
          formKey: _formKey,
          phoneController: _phoneController,
          passwordController: _passwordController,
          // 保存回调
          onPhoneSaved: _onPhoneSaved,
          onPasswordSaved: _onPasswordSaved,
        ),
        const SizedBox(height: 20),
        // 操作功能
        FormActionButtons(
          onLogin: _handleLogin,
          onReset: _handleReset,
          onShowInfo: _showFormInfo,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GlobalKey-模块化登录页面")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SingleChildScrollView(
          child: _formContent(),
        ),
      ),
    );
  }
}
