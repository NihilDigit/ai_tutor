import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/chat_bubble.dart';
import '../components/quiz_widget.dart';
import '../models/message.dart';
import '../models/quiz.dart';
import '../providers/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [
    Message(
        content: '你好！',
        sender: 'user',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
    Message(
        content: '你好！有什么可以帮你的？',
        sender: 'bot',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3))),
    Message(
        content: '我想了解一下 GPT',
        sender: 'user',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2))),
    Message(
        content: '我推荐你看看这个视频： https://www.bilibili.com/video/av1353986541',
        sender: 'bot',
        timestamp: DateTime.now()),
    Message(
      content: '',
      sender: 'bot',
      timestamp: DateTime.now(),
      quiz: Quiz(
        question: 'GPT 是如何处理文本的？',
        options: ['词嵌入转向量', '直接处理原始文本', '使用正则表达式', '基于规则分析'],
        correctAnswer: '词嵌入转向量',
      ),
    ),
  ];

  void _handleQuizAnswer(String selectedAnswer, Quiz quiz) {
    print('用户选择的答案: $selectedAnswer'); // 调试信息
    final resultMessage = Message(
      content: selectedAnswer == quiz.correctAnswer
          ? '正确！GPT 确实是通过词嵌入(embedding)将文本转换为向量来处理的。'
          : '不对哦。根据视频内容，GPT 的第一层是将词嵌入(embedding)为向量，这是处理文本的基础。',
      sender: 'bot',
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(resultMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天界面'),
      ),
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          if (message.quiz != null) {
            return QuizWidget(
              quiz: message.quiz!,
              onAnswerSelected: (answer) =>
                  _handleQuizAnswer(answer, message.quiz!),
              showResult: true, // 确保设置为 true
              config: const QuizConfig(),
            );
          }
          return ChatBubble(message: message);
        },
      ),
    );
  }
}
