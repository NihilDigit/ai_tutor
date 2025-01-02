# ChatService 使用指南

## 概述
ChatService 是一个用于处理聊天相关操作的类，提供了与后端API通信的功能。

## 初始化
```dart
final chatService = ChatService();
```

## 获取消息历史
```dart
try {
  final messages = await chatService.getMessageHistory();
  // 处理消息列表
} catch (e) {
  // 处理错误
}
```

## 发送消息
```dart
try {
  final newMessage = await chatService.sendMessage('你好');
  // 处理新消息
} catch (e) {
  // 处理错误
}
```

## 关闭连接
```dart
await chatService.close();
```

## 错误处理
所有方法都可能抛出异常，建议使用try-catch进行错误处理。

## 示例
```dart
final chatService = ChatService();

// 获取消息历史
final messages = await chatService.getMessageHistory();

// 发送新消息
final newMessage = await chatService.sendMessage('你好');

// 关闭连接
await chatService.close();
```

## 注意事项
1. 确保在使用完毕后调用close()方法
2. 所有网络操作都是异步的，需要使用await
3. 建议在StatefulWidget的dispose方法中关闭连接
