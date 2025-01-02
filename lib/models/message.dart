import 'package:chat_framework/models/quiz.dart'; // 导入 Quiz 模型

class Message {
  final String content;
  final String sender;
  final DateTime timestamp;
  final Quiz? quiz;

  Message({
    required this.content,
    required this.sender,
    required this.timestamp,
    this.quiz,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'quiz': quiz?.toJson(),
    };
  }
}
