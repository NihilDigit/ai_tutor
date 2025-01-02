# Chat API Documentation

## Overview
The Chat API provides a clean interface for interacting with the chat backend. It handles message sending/receiving, quiz management, and error handling.

## Installation
Add the following dependency to your `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

## Usage
```dart
import 'package:your_app/api/chat_api.dart';

final chatService = ChatService();

// Get message history
final messages = await chatService.getMessageHistory();

// Send a message
final newMessage = await chatService.sendMessage('Hello World!');

// Send a quiz
final quiz = Quiz(...);
final quizMessage = await chatService.sendQuiz(quiz);

// Delete a message
await chatService.deleteMessage('message-id');
```

## Configuration
```dart
// Set custom base URL
ChatService.setBaseUrl('https://api.example.com');

// Use custom HTTP client
final customClient = http.Client();
final chatService = ChatService(client: customClient);
```

## Error Handling
The API throws `ApiException` for all errors. It includes:
- Error message
- HTTP status code (if available)
- Response body (if available)

Example error handling:
```dart
try {
  await chatService.sendMessage('Hello');
} on ApiException catch (e) {
  print('Error: ${e.message}');
  if (e.statusCode != null) {
    print('Status code: ${e.statusCode}');
  }
}
```

## API Reference

### ChatService
```dart
class ChatService {
  /// Creates a new ChatService instance
  ChatService({http.Client? client, String? baseUrl});

  /// Sets the base URL for all API requests
  static void setBaseUrl(String url);

  /// Gets the message history
  Future<List<Message>> getMessageHistory();

  /// Sends a new message
  Future<Message> sendMessage(String content, {Quiz? quiz});

  /// Sends a quiz
  Future<Message> sendQuiz(Quiz quiz);

  /// Deletes a message
  Future<void> deleteMessage(String messageId);

  /// Closes the HTTP client
  Future<void> close();
}
```

### ApiException
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  ApiException(this.message, {this.statusCode, this.responseBody});
}
```

## Best Practices
1. Always close the service when done:
```dart
await chatService.close();
```

2. Handle errors appropriately using try/catch blocks

3. Use the same ChatService instance throughout your app

4. Set the base URL early in your app initialization
