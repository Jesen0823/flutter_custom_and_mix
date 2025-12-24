import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'account_adapter.dart';

/// 账号模型（简单定义，企业级可扩展字段）
class Account {
  final String id;
  final String name;

  Account({required this.id, required this.name});
}

/// Hive 工具类（单例模式）
class HiveHelper {
  static final HiveHelper _instance = HiveHelper._internal();
  factory HiveHelper() => _instance;
  HiveHelper._internal();

  /// 账号列表箱名
  static const String _accountBoxName = "account_box";
  late Box _accountBox;

  /// 初始化Hive（在APP启动时调用）
  Future<void> initHive() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
    // 注册手动编写的适配器（关键步骤）
    Hive.registerAdapter(AccountAdapter());
    // 打开账号箱
    _accountBox = await Hive.openBox(_accountBoxName);
  }

  /// 保存账号列表
  Future<void> saveAccountList(List<Account> accountList) async {
    // 先清空旧数据
    await _accountBox.clear();
    // 存储账号（转成Map存储，Hive支持基本类型/Map/List）
    for (var account in accountList) {
      await _accountBox.put(account.id, {
        "id": account.id,
        "name": account.name,
      });
    }
  }

  /// 获取账号列表
  List<Account> getAccountList() {
    List<Account> list = [];
    for (var key in _accountBox.keys) {
      final map = _accountBox.get(key) as Map;
      list.add(Account(
        id: map["id"],
        name: map["name"],
      ));
    }
    return list;
  }

  /// 判断是否已绑定账号（核心方法：为空则未绑定）
  bool hasBindedAccount() {
    return _accountBox.isNotEmpty;
  }

  /// 关闭Hive（APP退出时调用）
  Future<void> closeHive() async {
    await Hive.close();
  }
}