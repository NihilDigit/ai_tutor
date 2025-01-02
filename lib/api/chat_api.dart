import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/quiz.dart';

class ChatApi {
  static const String _baseUrl = 'http://localhost:8000';
  final List<Message> _messages = [];

  /// Get all messages
  List<Message> getMessages() => _messages;

  /// Send a new message to server
  Future<void> sendMessage(String content) async {
    final newMessage = Message(
      content: content,
      sender: 'user',
      timestamp: DateTime.now(),
    );

    // Add to local storage immediately
    _messages.add(newMessage);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newMessage.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      // Handle network errors
      addSystemMessage(
          '发送测验结果失败，详细信息：\n错误类型：${e.runtimeType}\n错误信息：${e.toString()}');
    }
  }

  /// Handle quiz answer and generate response
  Future<void> handleQuizAnswer(String selectedAnswer, Quiz quiz) async {
    final resultMessage = Message(
      content: selectedAnswer == quiz.correctAnswer
          ? '正确！GPT 确实是通过词嵌入(embedding)将文本转换为向量来处理的。'
          : '不对哦。根据视频内容，GPT 的第一层是将词嵌入(embedding)为向量，这是处理文本的基础。',
      sender: 'bot',
      timestamp: DateTime.now(),
    );

    _messages.add(resultMessage);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'selectedAnswer': selectedAnswer,
          'quiz': quiz.toJson(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send quiz result');
      }
    } catch (e) {
      // Handle network errors
      addSystemMessage(
          '网络连接失败，详细信息：\n错误类型：${e.runtimeType}\n错误信息：${e.toString()}');
    }
  }

  /// Add a system message
  void addSystemMessage(String content) {
    _messages.add(Message(
      content: content,
      sender: 'system',
      timestamp: DateTime.now(),
    ));
  }

  /// Add a quiz message
  Future<void> addQuizMessage(Quiz quiz) async {
    final quizMessage = Message(
      content: '',
      sender: 'bot',
      timestamp: DateTime.now(),
      quiz: quiz,
    );

    _messages.add(quizMessage);

    try {
      // First check if server is reachable
      final pingResponse = await http.get(Uri.parse(_baseUrl));
      if (pingResponse.statusCode != 200) {
        throw Exception('无法连接到服务器，请检查服务器是否运行');
      }

      // Send quiz as part of message
      final message = Message(
        content: '',
        sender: 'bot',
        timestamp: DateTime.now(),
        quiz: quiz,
      );

      // Try sending message with retry logic
      int retries = 3;
      while (retries > 0) {
        try {
          final response = await http.post(
            Uri.parse('$_baseUrl/messages'),
            headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'content': message.content,
            'sender': message.sender,
            'timestamp': message.timestamp.toIso8601String(),
            'quiz': message.quiz?.toJson(),
          }),
          );

          if (response.statusCode == 200) {
            return;
          } else if (response.statusCode == 404) {
            throw Exception('服务器未找到/messages接口，请检查后端配置');
          } else {
            throw Exception('服务器返回错误状态码：${response.statusCode}');
          }
        } catch (e) {
          retries--;
          if (retries == 0) {
            rethrow;
          }
          await Future.delayed(Duration(seconds: 1));
        }
      }
    } on http.ClientException catch (e) {
      addSystemMessage('网络连接失败，请检查网络设置\n错误信息：${e.message}');
    } on FormatException catch (e) {
      addSystemMessage('数据格式错误，请检查数据\n错误信息：${e.message}');
    } catch (e) {
      addSystemMessage('发送测验失败\n错误信息：${e.toString()}');
    }
  }

  /// Fetch messages from server
  Future<void> fetchMessages() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/messages'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _messages.clear();
        _messages.addAll(data.map((json) => Message.fromJson(json)));
      } else {
        // Handle different HTTP error codes
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = '请求参数错误';
            break;
          case 401:
            errorMessage = '未授权访问';
            break;
          case 403:
            errorMessage = '访问被禁止';
            break;
          case 404:
            errorMessage = '服务器地址未找到';
            break;
          case 500:
            errorMessage = '服务器内部错误';
            break;
          default:
            errorMessage = '服务器返回错误状态码：${response.statusCode}';
        }
        addSystemMessage(
            '获取消息失败，详细信息：\n错误码：${response.statusCode}\n错误信息：$errorMessage');
      }
    } on http.ClientException catch (e) {
      // Handle client-side network errors
      addSystemMessage('网络连接失败，详细信息：\n错误类型：ClientException\n错误信息：${e.message}');
    } on FormatException catch (e) {
      // Handle JSON parsing errors
      addSystemMessage('数据解析失败，详细信息：\n错误类型：FormatException\n错误信息：${e.message}');
    } catch (e) {
      // Handle other unexpected errors
      addSystemMessage(
          '未知错误，详细信息：\n错误类型：${e.runtimeType}\n错误信息：${e.toString()}');
    }
  }
}
