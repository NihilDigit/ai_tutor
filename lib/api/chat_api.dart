import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatService {
  static const String _baseUrl = 'https://api.example.com/chat';
  final http.Client _client;

  ChatService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Message>> getMessageHistory() async {
    final response = await _client.get(Uri.parse('$_baseUrl/history'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load message history');
    }
  }

  Future<Message> sendMessage(String content) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<void> close() async {
    _client.close();
  }
}
