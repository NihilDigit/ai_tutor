import 'package:flutter/material.dart';
import 'package:chat_framework/components/chat_bubble.dart';
import 'package:chat_framework/components/message_input.dart';
import 'package:chat_framework/models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // 示例消息数据，后续将从后端获取
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
  ];

  // 模拟发送消息，后续将调用后端接口
  void _sendMessage(String text) {
    final newMessage = Message(
      content: text,
      sender: 'user',
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(newMessage);
    });
    // TODO: 在这里调用后端 API 发送消息
    // api.sendMessage(text).then((response) { ... });
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
              reverse: true, // 消息列表倒序排列
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
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
