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
}
