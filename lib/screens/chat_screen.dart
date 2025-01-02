import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/chat_bubble.dart';
import '../components/quiz_widget.dart';
import '../components/message_input.dart';
import '../models/message.dart';
import '../models/quiz.dart';
import '../providers/theme_provider.dart';
import '../api/chat_api.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatApi _chatApi;

  @override
  void initState() {
    super.initState();
    _chatApi = ChatApi();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    await _chatApi.fetchMessages();
    if (_chatApi.getMessages().isEmpty) {
      _chatApi
        ..addSystemMessage('你好！这是一个示例对话。')
        ..addSystemMessage('https://www.bilibili.com/video/BV1Nf6dYGEFH')
        ..addSystemMessage('请观看上面的视频，然后回答以下问题：')
        ..addQuizMessage(Quiz(
          question: 'GPT 是如何处理文本的？',
          options: ['词嵌入转向量', '直接处理原始文本', '使用正则表达式', '基于规则分析'],
          correctAnswer: '词嵌入转向量',
        ));
    }
    setState(() {});
  }

  void _sendMessage(String content) {
    _chatApi.sendMessage(content);
    setState(() {});
  }

  void _handleQuizAnswer(String selectedAnswer, Quiz quiz) {
    _chatApi.handleQuizAnswer(selectedAnswer, quiz);
    setState(() {});
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
              itemCount: _chatApi.getMessages().length,
              itemBuilder: (context, index) {
                final message = _chatApi.getMessages()[index];
                if (message.quiz != null) {
                  return QuizWidget(
                    quiz: message.quiz!,
                    onAnswerSelected: (answer) =>
                        _handleQuizAnswer(answer, message.quiz!),
                    showResult: true,
                    config: const QuizConfig(),
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
