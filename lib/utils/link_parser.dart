import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:chat_framework/models/link_metadata.dart';
import 'dart:convert';

Future<LinkMetadata?> fetchLinkMetadata(String url) async {
  print('Fetching metadata for: $url'); // 添加日志

  // 检查是否为 B站链接
  if (_isBilibiliLink(url)) {
    final metadata = await _fetchBilibiliMetadata(url);
    if (metadata != null) {
      return LinkMetadata(
        title: metadata['title'] ?? 'B站视频',
        description: metadata['description'] ?? '点击查看视频',
        imageUrl: metadata['imageUrl'],
        favicon: 'https://www.bilibili.com/favicon.ico',
        url: url,
      );
    }
  }

  // 如果不是 B站链接，继续之前的逻辑
  try {
    final response = await http.get(Uri.parse(url));
    print('Response status code: ${response.statusCode}'); // 添加日志

    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);
      final title = _extractTitle(document);
      final description = _extractDescription(document);
      final imageUrl = _extractImageUrl(document, url);
      final favicon = await _extractFavicon(document, url);

      print(
          'Title: $title, Description: $description, ImageUrl: $imageUrl'); // 添加日志

      return LinkMetadata(
        title: title,
        description: description,
        imageUrl: imageUrl,
        favicon: favicon,
        url: url,
      );
    } else {
      print(
          'Failed to fetch metadata. Status code: ${response.statusCode}'); // 添加日志
    }
  } catch (e) {
    print('Error fetching link metadata: $e');
  }
  return null;
}

// 提取 favicon 的函数
Future<String?> _extractFavicon(dom.Document document, String baseUrl) async {
  // 尝试多种可能的 favicon 位置
  final possibleFavicons = [
    // 1. 检查标准的 favicon link
    document.head?.querySelector('link[rel="icon"]')?.attributes['href'],
    document.head
        ?.querySelector('link[rel="shortcut icon"]')
        ?.attributes['href'],
    // 2. 检查 Apple Touch Icon
    document.head
        ?.querySelector('link[rel="apple-touch-icon"]')
        ?.attributes['href'],
    // 3. 检查 manifest 中的图标
    document.head?.querySelector('link[rel="manifest"]')?.attributes['href'],
    // 4. 默认 favicon 位置
    '/favicon.ico',
  ].where((url) => url != null).toList();

  // 基础 URL
  final baseUri = Uri.parse(baseUrl);

  // 尝试每个可能的 favicon URL
  for (var faviconPath in possibleFavicons) {
    try {
      final faviconUrl = _resolveUrl(baseUrl, faviconPath);
      final response = await http.get(Uri.parse(faviconUrl));

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('image') == true) {
        return faviconUrl;
      }
    } catch (e) {
      print('Error checking favicon at $faviconPath: $e');
      continue;
    }
  }

  // 如果是 HTTPS 链接，尝试使用 Google Favicon 服务
  if (baseUri.scheme == 'https') {
    return 'https://www.google.com/s2/favicons?domain=${baseUri.host}&sz=64';
  }

  return null;
}

// 如果是 manifest 文件，解析它来获取图标
Future<String?> _extractIconFromManifest(String manifestUrl) async {
  try {
    final response = await http.get(Uri.parse(manifestUrl));
    if (response.statusCode == 200) {
      final manifest = jsonDecode(response.body);
      final icons = manifest['icons'] as List?;
      if (icons != null && icons.isNotEmpty) {
        // 通常选择最大的图标
        final icon = icons.reduce((a, b) => (a['sizes'] ?? '0x0')
                    .split('x')[0]
                    .compareTo((b['sizes'] ?? '0x0').split('x')[0]) >
                0
            ? a
            : b);
        return icon['src'];
      }
    }
  } catch (e) {
    print('Error parsing manifest: $e');
  }
  return null;
}

// 判断是否为 B站链接
bool _isBilibiliLink(String url) {
  final regex = RegExp(r'https?://(www\.)?bilibili\.com/video/(av\d+|BV\w+)');
  return regex.hasMatch(url);
}

// 提取 B站视频的元数据（标题、描述、封面图）
Future<Map<String, String>?> _fetchBilibiliMetadata(String url) async {
  try {
    final regex = RegExp(r'av(\d+)|BV(\w+)');
    final match = regex.firstMatch(url);
    if (match == null) return null;

    final aid = match.group(1);
    final bvid = match.group(2);
    final apiUrl = aid != null
        ? 'https://api.bilibili.com/x/web-interface/view?aid=$aid'
        : 'https://api.bilibili.com/x/web-interface/view?bvid=$bvid';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'title': data['data']['title'],
        'description': data['data']['desc'],
        'imageUrl': data['data']['pic'],
      };
    }
  } catch (e) {
    print('Error fetching Bilibili metadata: $e');
  }
  return null;
}

// 以下为之前的代码
String? _extractTitle(dom.Document document) {
  final metaTitle = document.head?.querySelector('meta[property="og:title"]');
  if (metaTitle != null) {
    return metaTitle.attributes['content'];
  }
  return document.head?.querySelector('title')?.text;
}

String? _extractDescription(dom.Document document) {
  final metaDescription =
      document.head?.querySelector('meta[property="og:description"]');
  if (metaDescription != null) {
    return metaDescription.attributes['content'];
  }
  return document.head
      ?.querySelector('meta[name="description"]')
      ?.attributes['content'];
}

String? _extractImageUrl(dom.Document document, String baseUrl) {
  final metaImage = document.head?.querySelector('meta[property="og:image"]');
  if (metaImage != null) {
    final imageUrl = metaImage.attributes['content'];
    return _resolveUrl(baseUrl, imageUrl);
  }
  return null;
}

String _resolveUrl(String baseUrl, String? relativeUrl) {
  if (relativeUrl == null) {
    return baseUrl;
  }
  final baseUri = Uri.parse(baseUrl);
  final resolvedUri = baseUri.resolve(relativeUrl);
  return resolvedUri.toString();
}
