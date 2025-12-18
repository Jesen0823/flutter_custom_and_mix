import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_and_mix/communication/base_message_channel.dart';
import 'package:flutter_custom_and_mix/communication/model/chat_message_entity.dart';
import 'package:flutter_custom_and_mix/communication/utils/app_logger.dart';

import 'base_event_channel.dart';
import 'channel_manager.dart';
import 'channel_service/user_channel_service.dart';
import 'model/push_entity.dart';
import 'model/user_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ChannelManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Channel测试Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TestHomePage(),
    );
  }
}

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  State<TestHomePage> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  final IUserChannelService _userService = UserChannelServiceImpl();
  final BaseEventChannel<PushEvent> _pushChannel = ChannelManager()
      .getEventChannel(
        channelName: 'com.example.flutter_app/push',
        converter: (json) => PushEvent.fromJson(json!),
      );

  final BaseMessageChannel<ChatMessage> _messageChannel = ChannelManager()
      .getMessageChannel(
        channelName: 'com.company.app/message',
        converter: ChatMessage.fromJson,
      );

  UserInfo? _userInfo;
  String _log = '';
  StreamSubscription<PushEvent>? _pushSubscription;

  @override
  void initState() {
    super.initState();
    _registerLogoutHandler();
    _subscribePushEvent();
    listenNativeMessage();
  }

  // 注册退出登录回调
  void _registerLogoutHandler() {
    _userService.registerUserLogoutHandler(
      onLogout: () {
        setState(() {
          _log += '收到退出登录回调，跳转登录页\n';
        });
        // 模拟跳转登录页
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('退出登录'),
            content: const Text('Token已过期，请重新登录'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      },
    );
  }

  // 订阅推送事件
  void _subscribePushEvent() {
    _pushSubscription = _pushChannel
        .subscribe(tag: 'home_page')
        .listen(
          (event) {
            setState(() {
              _log +=
                  '收到推送：[${event.type == 1 ? '系统' : '业务'}] ${event.title} - ${event.content}\n';
            });
          },
          onError: (error) {
            setState(() {
              _log += '推送订阅失败：$error\n';
            });
          },
        );
  }

  // 测试获取用户信息
  Future<void> _testGetUserInfo() async {
    setState(() {
      _log += '开始获取用户信息...\n';
    });
    try {
      final param = UserParam(userId: '10001', token: 'test_token_2024');
      final userInfo = await _userService.getUserInfo(param: param);
      setState(() {
        _userInfo = userInfo;
        _log += '获取用户信息成功：${userInfo.username}（${userInfo.age}岁）\n';
      });
    } catch (e) {
      setState(() {
        _log += '获取用户信息失败：$e\n';
      });
    }
  }

  // 测试参数错误场景
  Future<void> _testParamError() async {
    setState(() {
      _log += '测试参数错误场景...\n';
    });
    try {
      final param = UserParam(userId: '', token: ''); // 空参数
      await _userService.getUserInfo(param: param);
    } catch (e) {
      setState(() {
        _log += '参数错误测试结果：$e\n';
      });
    }
  }

  // 发送消息
  void sendChatMessage() async {
    try {
      final message = ChatMessage(
        id: "flutter_${DateTime.now().millisecondsSinceEpoch}",
        content: "Hello 原生端",
      );
      final response = await _messageChannel.sendMessage(message);
      print("收到原生回复：${response?.toJson()}");
    } catch (e) {
      print("发送失败：$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Channel测试')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息展示
            if (_userInfo != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '用户信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('用户ID：${_userInfo?.userId}'),
                      Text('用户名：${_userInfo?.username}'),
                      Text('年龄：${_userInfo?.age}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            TextButton(onPressed: ()=>sendChatMessage, child: const Text("向原生发送消息")),
            const SizedBox(height: 20),

            // 测试按钮
            Row(
              children: [
                ElevatedButton(
                  onPressed: _testGetUserInfo,
                  child: const Text('测试获取用户信息'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _testParamError,
                  child: const Text('测试参数错误'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 日志展示
            const Text(
              '操作日志',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(child: Text(_log)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    _pushChannel.unsubscribe(tag: 'home_page');
    _messageChannel.dispose();
    super.dispose();
  }

  // 监听原生消息
  void listenNativeMessage() {
    _messageChannel.receiveMessages().listen((ChatMessage message) {
      print("收到原生主动消息：${message.toJson()}");
    });
  }
}
