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
    final colorScheme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0, // Material 3 推荐使用较低的海拔
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias, // 确保图片不会超出圆角
      child: InkWell(
        // 使用 InkWell 代替 GestureDetector 以获得涟漪效果
        onTap: _handleTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (metadata.imageUrl != null)
              SizedBox(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    metadata.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2, // Material 3 风格的细线条
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image_rounded, // 使用圆角图标
                      color: colorScheme.colorScheme.onSurfaceVariant
                          .withOpacity(0.4),
                      size: 32,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (metadata.title != null)
                    Text(
                      metadata.title!,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (metadata.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        metadata.description!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        if (metadata.favicon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.network(
                              metadata.favicon!,
                              width: 16,
                              height: 16,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            metadata.url ?? '',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
