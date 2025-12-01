/// 用户信息模型
class UserModel {
  final String id;
  final String name;
  final String avatar;
  final bool isLogin;

  const UserModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.isLogin = false,
  });

  // 未登录状态
  static const UserModel unLogin = UserModel(id: "", name: "未登录", avatar: "");

  // 拷贝构造函数（便于状态更新，避免修改原对象）
  UserModel copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isLogin: isLogin ?? this.isLogin,
    );
  }
}
