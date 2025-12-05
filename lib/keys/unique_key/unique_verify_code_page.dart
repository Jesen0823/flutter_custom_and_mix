import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/keys/unique_key/verify_code_card.dart';

/// 验证码刷新 + 状态重置（ValueKey vs UniqueKey 直观对比）
// 「短信验证码刷新组件」，核心需求：
// 【两个按钮：】
// 「刷新验证码（值变化）」：生成新验证码 → ValueKey 因 value 变化重建，UniqueKey 也重建；
// 「强制刷新（值不变）」：不修改验证码值 → ValueKey 因 value 不变不复用（仅更新属性），UniqueKey 仍强制重建；
// 【两个卡片】
// ValueKey 卡片：值不变时，倒计时继续走、HashCode 不变（未重建）；
// UniqueKey 卡片：无论值是否变，倒计时重置、HashCode 变化（必重建）；
// 强化日志输出和视觉对比，让差异一目了然。
// 左侧卡片：用 ValueKey 绑定验证码值 → 仅当验证码值变化时重建（值不变则状态残留）；
// 右侧卡片：用 UniqueKey → 无论验证码值是否变化，每次点击都强制重建（状态重置）；
// 可视化对比：通过 Widget 的 hashCode（是否重建）、倒计时状态（是否重置）、日志输出（生命周期触发），直观体现差异。
class UniqueVerifyCodePage extends StatefulWidget {
  const UniqueVerifyCodePage({super.key});

  @override
  State<UniqueVerifyCodePage> createState() => _UniqueVerifyCodePageState();
}

class _UniqueVerifyCodePageState extends State<UniqueVerifyCodePage> {
  // 验证码核心业务值
  String _currentVerifyCode = _generateRandomCode();

  // 生成4位随机数字验证码
  static String _generateRandomCode() {
    return Random().nextInt(999).toString().padLeft(4, '0');
  }

  /// 场景1：刷新验证码（值变化）→ ValueKey/UniqueKey 都重建
  void _onRefreshCodeWithNewValue() {
    setState(() {
      _currentVerifyCode = _generateRandomCode();
    });
    debugPrint('【_onRefresh】【验证码值变了】→ 点击【刷新验证码（值变化）】');
  }

  /// 场景2：强制刷新（值不变）→ 仅 UniqueKey 重建
  void _onForceRefreshWithoutValueChange() {
    setState(() {
      // 不修改 _currentVerifyCode，仅触发 build
    });
    debugPrint('【_onForceRefresh】【验证码值不变】→ 点击【强制刷新（值不变）】');
  }

  // 刷新验证码
  void _onRefreshCode() {
    setState(() {
      _currentVerifyCode = _generateRandomCode();
      debugPrint('【_onRefreshCode】→ 生成新验证码：$_currentVerifyCode');
    });
  }

  // 操作按钮
  Widget _operateButtons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _onRefreshCodeWithNewValue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
          child: const Column(
            children: [
              Text(
                '刷新验证码（值变化）',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              Text(
                '→ ValueKey/UniqueKey 都重建',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: _onForceRefreshWithoutValueChange,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
          child: const Column(
            children: [
              Text(
                '强制刷新（值不变）',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              Text(
                '→ 仅 UniqueKey 重建',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 结论
  Widget _resultDescription(){
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Text(
        '''核心差异观测点：\n1. 倒计时：ValueKey 卡片值不变时，倒计时继续走；UniqueKey 卡片无论值是否变，倒计时重置。'
                    \n2. HashCode：ValueKey 卡片值不变时，HashCode 不变；UniqueKey 卡片每次刷新都变。''',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UniqueKey vs ValueKey-验证码刷新对比")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 操作按钮区（核心：两个不同刷新逻辑）
            _operateButtons(),
            const SizedBox(height: 40),
            // 对比区域,两个验证码卡片
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                VerifyCodeCard(
                  key: ValueKey(_currentVerifyCode), // 核心：绑定验证码值
                  cardTitle: 'ValueKey 卡片',
                  verifyCode: _currentVerifyCode,
                ),
                // 右侧：UniqueKey 卡片（每次build生成新实例）
                VerifyCodeCard(
                  key: UniqueKey(), // 核心：强制重建
                  cardTitle: 'UniqueKey 卡片',
                  verifyCode: _currentVerifyCode,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 差异说明（辅助理解）
            _resultDescription(),
          ],
        ),
      ),
    );
  }
}
