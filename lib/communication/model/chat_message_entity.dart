
import '../channel/base/base_serializable.dart';

class ChatMessage extends BaseSerializable {
  final String id;
  final String content;
  final int? time;

  ChatMessage({required this.id, required this.content, this.time});

  // 从Map转换为模型
  static ChatMessage fromJson(Map<String, dynamic>? json) {
    return ChatMessage(
      id: json?['id'] ?? '',
      content: json?['content'] ?? '',
      time: json?['time'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'content': content, 'time': time};
  }
}