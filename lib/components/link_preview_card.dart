import 'package:flutter/material.dart';
import 'package:chat_framework/models/link_metadata.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPreviewCard extends StatelessWidget {
  final LinkMetadata metadata;

  const LinkPreviewCard({Key? key, required this.metadata}) : super(key: key);

  Future<void> _handleTap() async {
    final url = metadata.url; // 假设 LinkMetadata 中有 url 字段
    if (url != null) {
      print('尝试打开链接: $url'); // 调试日志
      final uri = Uri.parse(url); // 将 String 转换为 Uri
      if (await canLaunchUrl(uri)) {
        print('可以打开链接: $uri'); // 调试日志
        await launchUrl(uri); // 使用默认浏览器打开链接
      } else {
        print('无法打开链接: $uri'); // 调试日志
        throw '无法打开链接: $url';
      }
    } else {
      print('URL 为空'); // 调试日志
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth =
        MediaQuery.of(context).size.width * 0.618; // 卡片宽度为屏幕宽度的 61.8%
    // final double imageAspectRatio = 16 / 9; // 缩略图比例 16:9

    return GestureDetector(
      onTap: _handleTap,
      // onTap: () {
      //   // TODO: 处理点击事件，例如打开链接
      // },
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth), // 限制卡片宽度
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (metadata.imageUrl != null)
              Container(
                width: maxWidth, // 缩略图宽度与卡片一致
                // height: maxWidth / imageAspectRatio, // 缩略图高度根据比例计算
                decoration: BoxDecoration(
                  color: Colors.grey[200], // 图片背景色
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    metadata.imageUrl!,
                    fit: BoxFit.cover, // 保持图片比例，完整显示
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16), // 增加内边距
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (metadata.title != null)
                    Text(
                      metadata.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // 增大标题字体大小
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (metadata.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8), // 增加描述与标题的间距
                      child: Text(
                        metadata.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                        maxLines: 3, // 增加描述的最大行数
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
