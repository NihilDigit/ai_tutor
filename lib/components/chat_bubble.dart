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
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = isUserMessage
        ? colorScheme.primaryContainer
        : colorScheme.surfaceVariant;
    final textColor = isUserMessage
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    // 计算最大宽度，考虑边距
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = (screenWidth * 0.618) - 32; // 减去水平边距

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(
          elevation: 0,
          color: bubbleColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isUserMessage
                  ? const Radius.circular(20)
                  : const Radius.circular(4),
              bottomRight: isUserMessage
                  ? const Radius.circular(4)
                  : const Radius.circular(20),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_processedText != null && _processedText!.isNotEmpty)
                    Text(
                      _processedText!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor,
                          ),
                    ),
                  if (_isFetchingMetadata)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  if (_linkMetadata != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: maxWidth - 24, // 减去内边距
                        child: LinkPreviewCard(metadata: _linkMetadata!),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(widget.message.timestamp),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: textColor.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
  // @override
  // Widget build(BuildContext context) {
  //   final isUserMessage = widget.message.sender == 'user';
  //   final colorScheme = Theme.of(context).colorScheme;

  //   // Material 3 气泡颜色
  //   final bubbleColor = isUserMessage
  //       ? colorScheme.primaryContainer
  //       : colorScheme.surfaceVariant;

  //   // Material 3 文字颜色
  //   final textColor = isUserMessage
  //       ? colorScheme.onPrimaryContainer
  //       : colorScheme.onSurfaceVariant;

  //   double maxWidth = MediaQuery.of(context).size.width * 0.618;
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //     constraints: BoxConstraints(maxWidth: maxWidth),
  //     child: Row(
  //       mainAxisAlignment:
  //           isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
  //       children: [
  //         Flexible(
  //           child: Card(
  //             elevation: 0, // Material 3 推荐使用较低的海拔
  //             color: bubbleColor,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.only(
  //                 topLeft: const Radius.circular(20),
  //                 topRight: const Radius.circular(20),
  //                 bottomLeft: isUserMessage
  //                     ? const Radius.circular(20)
  //                     : const Radius.circular(4),
  //                 bottomRight: isUserMessage
  //                     ? const Radius.circular(4)
  //                     : const Radius.circular(20),
  //               ),
  //             ),
  //             child: Padding(
  //               padding: const EdgeInsets.all(12),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   if (_processedText != null && _processedText!.isNotEmpty)
  //                     Text(
  //                       _processedText!,
  //                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                             color: textColor,
  //                           ),
  //                     ),
  //                   if (_isFetchingMetadata)
  //                     Padding(
  //                       padding: const EdgeInsets.only(top: 8.0),
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         color: colorScheme.primary,
  //                       ),
  //                     ),
  //                   if (_linkMetadata != null)
  //                     Padding(
  //                       padding: const EdgeInsets.only(top: 8.0),
  //                       child: LinkPreviewCard(metadata: _linkMetadata!),
  //                     ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     DateFormat('HH:mm').format(widget.message.timestamp),
  //                     style: Theme.of(context).textTheme.labelSmall?.copyWith(
  //                           color: textColor.withOpacity(0.8),
  //                         ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

