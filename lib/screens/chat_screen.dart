import 'package:flutter/material.dart';
import 'package:chat_framework/components/chat_bubble.dart';
import 'package:chat_framework/components/message_input.dart';
import 'package:chat_framework/components/quiz_widget.dart';
import 'package:chat_framework/models/message.dart';
import 'package:chat_framework/models/quiz.dart';

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
    // 自动发送测验
    Message(
        content: '测验：GPT-3 是由哪个公司开发的？',
        sender: 'bot',
        timestamp: DateTime.now(),
        quiz: Quiz(
          question: 'GPT-3 是由哪个公司开发的？',
          options: ['Google', 'OpenAI', 'Microsoft', 'Facebook'],
          correctAnswer: 'OpenAI',
        )),
  ];

  void _sendMessage(String text) {
    final newMessage = Message(
      content: text,
      sender: 'user',
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(newMessage);
    });

    // 如果用户发送了特定内容，自动发送测验
    if (text.contains('GPT')) {
      _sendQuiz();
    }
  }

  void _sendQuiz() {
    final quiz = Quiz(
      question: 'GPT-3 是由哪个公司开发的？',
      options: ['Google', 'OpenAI', 'Microsoft', 'Facebook'],
      correctAnswer: 'OpenAI',
    );

    final quizMessage = Message(
      content: '测验：${quiz.question}',
      sender: 'bot',
      timestamp: DateTime.now(),
      quiz: quiz,
    );

    setState(() {
      _messages.add(quizMessage);
    });
  }

  void _handleQuizAnswer(String selectedAnswer, Quiz quiz) {
    final resultMessage = Message(
      content: selectedAnswer == quiz.correctAnswer
          ? '回答正确！'
          : '回答错误，正确答案是 ${quiz.correctAnswer}。',
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                if (message.quiz != null) {
                  return QuizWidget(
                    quiz: message.quiz!,
                    onAnswerSelected: (answer) =>
                        _handleQuizAnswer(answer, message.quiz!),
                  );
                }
                return ChatBubble(message: message);
              },
            ),
          ),
          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}
