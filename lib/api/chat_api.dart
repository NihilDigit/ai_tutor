import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/quiz.dart';

class ChatService {
  static const String _apiVersion = 'v1';
  static const Duration _timeoutDuration = Duration(seconds: 10);
  static const int _maxRetries = 3;
  
  static String _baseUrl = 'http://127.0.0.1:8000';
  
  static String get _apiBaseUrl => '$_baseUrl/api/$_apiVersion';
  final http.Client _client;

  ChatService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client() {
    if (baseUrl != null) {
      _baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    }
  }

  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url : '$url/';
  }

  Future<List<Message>> getMessageHistory() async {
    print('Fetching message history from $_apiBaseUrl/messages');
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final response = await _client.get(
          Uri.parse('$_apiBaseUrl/messages'),
          headers: {'Accept': 'application/json'},
        ).timeout(_timeoutDuration);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((json) => Message.fromJson(json)).toList();
        } else if (response.statusCode >= 500) {
          attempt++;
          if (attempt < _maxRetries) {
            await Future.delayed(Duration(seconds: attempt));
            continue;
          }
        }
        throw ApiException(
          'Failed to load message history',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      } on ApiException {
        rethrow;
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetries) {
          throw ApiException('Network error: $e');
        }
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    throw ApiException('Max retries reached');
  }

  Future<Message> sendMessage(String content, {Quiz? quiz}) async {
    print('Sending message to $_apiBaseUrl/messages');
    print('Message content: $content');
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final messageData = {
          'content': content,
          if (quiz != null) 'quiz': quiz.toJson(),
        };

        final response = await _client.post(
          Uri.parse('$_apiBaseUrl/messages'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(messageData),
        ).timeout(_timeoutDuration);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          return Message.fromJson(jsonDecode(response.body));
        } else if (response.statusCode >= 500) {
          attempt++;
          if (attempt < _maxRetries) {
            await Future.delayed(Duration(seconds: attempt));
            continue;
          }
        }
        throw ApiException(
          'Failed to send message',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      } on ApiException {
        rethrow;
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetries) {
          throw ApiException('Network error: $e');
        }
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    throw ApiException('Max retries reached');
  }

  Future<Message> sendQuiz(Quiz quiz) async {
    print('Sending quiz to $_apiBaseUrl/quizzes');
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final response = await _client.post(
          Uri.parse('$_apiBaseUrl/quizzes'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(quiz.toJson()),
        ).timeout(_timeoutDuration);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          return Message.fromJson(jsonDecode(response.body));
        } else if (response.statusCode >= 500) {
          attempt++;
          if (attempt < _maxRetries) {
            await Future.delayed(Duration(seconds: attempt));
            continue;
          }
        }
        throw ApiException(
          'Failed to send quiz',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      } on ApiException {
        rethrow;
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetries) {
          throw ApiException('Network error: $e');
        }
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    throw ApiException('Max retries reached');
  }

  Future<void> deleteMessage(String messageId) async {
    print('Deleting message at $_apiBaseUrl/messages/$messageId');
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final response = await _client.delete(
          Uri.parse('$_apiBaseUrl/messages/$messageId'),
          headers: {'Accept': 'application/json'},
        ).timeout(_timeoutDuration);

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 204) {
          return;
        } else if (response.statusCode >= 500) {
          attempt++;
          if (attempt < _maxRetries) {
            await Future.delayed(Duration(seconds: attempt));
            continue;
          }
        }
        throw ApiException(
          'Failed to delete message',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      } on ApiException {
        rethrow;
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetries) {
          throw ApiException('Network error: $e');
        }
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    throw ApiException('Max retries reached');
  }

  Future<void> close() async {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  ApiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() {
    var msg = 'ApiException: $message';
    if (statusCode != null) {
      msg += ' (status code: $statusCode)';
    }
    if (responseBody != null) {
      msg += '\nResponse body: $responseBody';
    }
    return msg;
  }
}
