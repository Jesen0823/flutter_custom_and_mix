import 'package:hive/hive.dart';

import 'hive_helper.dart';

/// 手动编写 Account 适配器（替代 hive_generator 自动生成）
class AccountAdapter extends TypeAdapter<Account> {
  // 与之前的 typeId 保持一致（便于兼容已存储的数据）
  @override
  final int typeId = 0;

  // 序列化：将 Account 对象转为 Hive 可存储的基本类型（Map/List 等）
  @override
  void write(BinaryWriter writer, Account obj) {
    writer.writeString(obj.id); // 写入 id（字符串类型）
    writer.writeString(obj.name); // 写入 name（字符串类型）
  }

  // 反序列化：从 Hive 读取数据，构建 Account 对象
  @override
  Account read(BinaryReader reader) {
    final id = reader.readString(); // 读取 id
    final name = reader.readString(); // 读取 name
    return Account(id: id, name: name); // 构建 Account 对象
  }
}