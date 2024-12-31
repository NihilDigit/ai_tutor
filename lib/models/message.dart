import 'package:chat_framework/models/quiz.dart'; // 导入 Quiz 模型

class Message {
  final String content;
  final String sender;
  final DateTime timestamp;
  final Quiz? quiz; // 可选的小测验字段

  Message({
    required this.content,
    required this.sender,
    required this.timestamp,
    this.quiz,
  });
}
