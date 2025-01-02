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
  final List<Message> _messages = [];
  late ChatService _chatService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getMessageHistory();
      setState(() {
        _messages.addAll(messages);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载消息失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String content) async {
    try {
      final newMessage = await _chatService.sendMessage(content);
      setState(() {
        _messages.add(newMessage);
      });
    } catch (e) {
      setState(() {
        _errorMessage = '发送消息失败: $e';
      });
    }
  }

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
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
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
