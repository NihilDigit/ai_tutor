import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chat_framework/models/message.dart';
import 'package:chat_framework/utils/link_parser.dart';
import 'package:chat_framework/components/link_preview_card.dart';
import 'package:chat_framework/models/link_metadata.dart';

class ChatBubble extends StatefulWidget {
  final Message message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  LinkMetadata? _linkMetadata;
  bool _isFetchingMetadata = false;
  String? _processedText; // 处理后的文本（去除链接）

  @override
  void initState() {
    super.initState();
    _checkForLink();
  }

  @override
  void didUpdateWidget(covariant ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.content != widget.message.content) {
      _linkMetadata = null;
      _processedText = null;
      _checkForLink();
    }
  }

  void _checkForLink() {
    final content = widget.message.content;
    final link = _extractLink(content);
    if (link != null) {
      setState(() {
        _isFetchingMetadata = true;
      });
      fetchLinkMetadata(link).then((metadata) {
        if (mounted) {
          setState(() {
            _linkMetadata = metadata;
            _isFetchingMetadata = false;
          });
        }
      });
    }
    // 处理文本，去除链接
    _processedText = _removeLinkFromText(content);
  }

  // 提取文本中的第一个链接
  String? _extractLink(String input) {
    final regex = RegExp(
        r'(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');
    final match = regex.firstMatch(input);
    return match?.group(0);
  }

  // 从文本中去除链接
  String _removeLinkFromText(String input) {
    final regex = RegExp(
        r'(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');
    return input.replaceAll(regex, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final isUserMessage = widget.message.sender == 'user';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Theme.of(context).primaryColor
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUserMessage
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                  bottomRight: isUserMessage
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_processedText != null && _processedText!.isNotEmpty)
                    Text(
                      _processedText!,
                      style: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black),
                    ),
                  if (_isFetchingMetadata)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (_linkMetadata != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: LinkPreviewCard(metadata: _linkMetadata!),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(widget.message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isUserMessage
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
