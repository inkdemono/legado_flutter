import 'package:flutter/foundation.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:xml/xml.dart' as xml;
import '../../core/base/base_service.dart';
import '../../data/models/book_source_rule.dart';
import '../../data/models/rss_source.dart';
import '../../data/models/rss_article.dart';
import '../network/network_service.dart';
import '../../utils/parsers/rule_parser.dart';
import '../../utils/app_log.dart';
import '../../utils/network_utils.dart';

/// RSS解析服务
/// 参考项目：Rss.kt 和 RssParserByRule.kt
class RssParserService extends BaseService {
  static final RssParserService instance = RssParserService._init();
  static const int _maxAutoNextPages = 10;
  RssParserService._init();

  /// 获取RSS文章列表
  /// 参考项目：Rss.getArticlesAwait
  Future<List<RssArticle>> getArticles({
    required RssSource source,
    String? sortName,
    String? sortUrl,
    int page = 1,
  }) async {
    try {
      final ruleArticles = source.ruleArticles;
      if (ruleArticles != null && ruleArticles.isNotEmpty) {
        return await _getArticlesByRule(
          source: source,
          sortName: sortName ?? '',
          sortUrl: sortUrl ?? source.sourceUrl,
          maxPages: page > 1 ? page : _maxAutoNextPages,
        );
      }

      // 确定要请求的URL
      final url = sortUrl ?? source.sourceUrl;

      // 发送请求
      final response = await readService(AppServices.networkService).get(
        url,
        headers: NetworkService.parseHeaders(source.header),
        retryCount: 1,
      );

      final body = await NetworkService.getResponseText(response);

      if (body.isEmpty) {
        throw Exception('获取RSS内容为空');
      }

      // 使用默认XML解析
      return _parseDefaultXML(
        xmlContent: body,
        sourceUrl: source.sourceUrl,
        sortName: sortName ?? '',
      );
    } catch (e) {
      AppLog.instance.put('获取RSS文章失败: ${source.sourceName}', error: e);
      rethrow;
    }
  }

  Future<List<RssArticle>> _getArticlesByRule({
    required RssSource source,
    required String sortName,
    required String sortUrl,
    required int maxPages,
  }) async {
    final articleList = <RssArticle>[];
    final articleKeys = <String>{};
    final visitedUrls = <String>{};
    var currentUrl = sortUrl;
    var pageCount = 0;

    while (currentUrl.isNotEmpty &&
        !visitedUrls.contains(currentUrl) &&
        pageCount < maxPages) {
      visitedUrls.add(currentUrl);
      pageCount++;

      final response = await readService(AppServices.networkService).get(
        currentUrl,
        headers: NetworkService.parseHeaders(source.header),
        retryCount: 1,
      );

      final body = await NetworkService.getResponseText(response);
      if (body.isEmpty) {
        throw Exception('获取RSS内容为空');
      }

      final pageArticles = await _parseByRule(
        source: source,
        html: body,
        sortName: sortName,
        sortUrl: currentUrl,
        redirectUrl: response.realUri.toString(),
      );

      for (final article in pageArticles) {
        final key = '${article.origin}::${article.link}';
        if (articleKeys.add(key)) {
          articleList.add(article);
        }
      }

      if (source.ruleNextPage == null || source.ruleNextPage!.isEmpty) {
        break;
      }

      final nextUrl = await resolveNextPageUrl(
        source: source,
        html: body,
        baseUrl: currentUrl,
        redirectUrl: response.realUri.toString(),
      );
      if (nextUrl == null ||
          nextUrl.isEmpty ||
          visitedUrls.contains(nextUrl) ||
          nextUrl == currentUrl) {
        break;
      }

      currentUrl = nextUrl;
    }

    return articleList;
  }

  /// 使用规则解析RSS文章
  /// 参考项目：RssParserByRule.parseXML
  Future<List<RssArticle>> _parseByRule({
    required RssSource source,
    required String html,
    required String sortName,
    required String sortUrl,
    required String redirectUrl,
  }) async {
    final articleList = <RssArticle>[];
    
    try {
      final ruleArticles = source.ruleArticles!;
      var actualRuleArticles = ruleArticles;
      var reverse = false;
      
      // 检查是否需要反转
      if (ruleArticles.startsWith('-')) {
        reverse = true;
        actualRuleArticles = ruleArticles.substring(1);
      }

      // 获取文章列表元素（返回HTML以便后续解析属性）
      final collections = RuleParser.parseListRule(
        html,
        actualRuleArticles,
        baseUrl: sortUrl,
        returnHtml: true, // 返回HTML以便后续解析各个字段
      );

      if (collections.isEmpty) {
        return articleList;
      }

      // 解析每个文章项
      for (int index = 0; index < collections.length; index++) {
        final item = collections[index];
        final article = await _parseArticleItem(
          source: source,
          item: item,
          baseUrl: sortUrl,
          redirectUrl: redirectUrl,
        );
        
        if (article != null && article.title.isNotEmpty) {
          final finalArticle = article.copyWith(
            sort: sortName,
            origin: source.sourceUrl,
          );
          articleList.add(finalArticle);
        }
      }

      if (reverse) {
        return articleList.reversed.toList();
      }

      return articleList;
    } catch (e) {
      AppLog.instance.put('使用规则解析RSS文章失败', error: e);
      return articleList;
    }
  }

  /// 解析单个文章项
  /// 参考项目：RssParserByRule.getItem
  Future<RssArticle?> _parseArticleItem({
    required RssSource source,
    required String item,
    required String baseUrl,
    required String redirectUrl,
    Future<String?> Function(String url)? contentLoader,
  }) async {
    try {
      String title = '';
      String link = source.sourceUrl; // 默认使用源URL
      String? pubDate;
      String? description;
      String? content;
      String? image;

      // 解析标题
      if (source.ruleTitle != null && source.ruleTitle!.isNotEmpty) {
        final titleResult = await RuleParser.parseRuleAsync(
          item,
          source.ruleTitle!,
          baseUrl: baseUrl,
        );
        if (titleResult != null && titleResult.isNotEmpty) {
          title = titleResult;
        }
      }

      // 解析链接
      if (source.ruleLink != null && source.ruleLink!.isNotEmpty) {
        final linkResult = await RuleParser.parseRuleAsync(
          item,
          source.ruleLink!,
          baseUrl: baseUrl,
          isUrl: true,
        );
        if (linkResult != null && linkResult.isNotEmpty) {
          link = NetworkUtils.getAbsoluteURL(source.sourceUrl, linkResult);
        }
      }

      // 解析发布日期
      if (source.rulePubDate != null && source.rulePubDate!.isNotEmpty) {
        final pubDateResult = await RuleParser.parseRuleAsync(
          item,
          source.rulePubDate!,
          baseUrl: baseUrl,
        );
        if (pubDateResult != null && pubDateResult.isNotEmpty) {
          pubDate = pubDateResult;
        }
      }

      // 解析描述
      if (source.ruleDescription != null && source.ruleDescription!.isNotEmpty) {
        final descriptionResult = await RuleParser.parseRuleAsync(
          item,
          source.ruleDescription!,
          baseUrl: baseUrl,
        );
        if (descriptionResult != null && descriptionResult.isNotEmpty) {
          description = descriptionResult;
        }
      }

      if ((description == null || description.isEmpty) &&
          source.ruleContent != null &&
          source.ruleContent!.isNotEmpty &&
          link.isNotEmpty &&
          link != source.sourceUrl) {
        content = await _loadArticleContent(
          source: source,
          articleUrl: link,
          contentLoader: contentLoader,
        );
      }

      // 解析图片
      if (source.ruleImage != null && source.ruleImage!.isNotEmpty) {
        final imageResult = await RuleParser.parseRuleAsync(
          item,
          source.ruleImage!,
          baseUrl: baseUrl,
          isUrl: true,
        );
        if (imageResult != null && imageResult.isNotEmpty) {
          image = NetworkUtils.getAbsoluteURL(source.sourceUrl, imageResult);
        }
      }

      if (title.isEmpty) {
        return null;
      }

      return RssArticle(
        origin: source.sourceUrl,
        link: link,
        title: title,
        pubDate: pubDate,
        description: description,
        content: content,
        image: image,
      );
    } catch (e) {
      AppLog.instance.put('解析RSS文章项失败', error: e);
      return null;
    }
  }

  Future<String?> resolveNextPageUrl({
    required RssSource source,
    required String html,
    required String baseUrl,
    required String redirectUrl,
  }) async {
    final ruleNextPage = source.ruleNextPage;
    if (ruleNextPage == null || ruleNextPage.isEmpty) {
      return null;
    }

    try {
      final result = await RuleParser.parseRuleAsync(
        html,
        ruleNextPage,
        baseUrl: baseUrl,
      );
      if (result == null || result.isEmpty) {
        return null;
      }

      return NetworkUtils.getAbsoluteURL(redirectUrl, result);
    } catch (e) {
      AppLog.instance.put('解析 RSS 下一页失败', error: e);
      return null;
    }
  }

  Future<String?> _loadArticleContent({
    required RssSource source,
    required String articleUrl,
    Future<String?> Function(String url)? contentLoader,
  }) async {
    try {
      if (contentLoader != null) {
        return await contentLoader(articleUrl);
      }

      final response = await readService(AppServices.networkService).get(
        articleUrl,
        headers: NetworkService.parseHeaders(source.header),
        retryCount: 1,
      );
      final html = await NetworkService.getResponseText(response);
      if (html.isEmpty) {
        return null;
      }

      final contentRule = ContentRule(content: source.ruleContent);
      return await RuleParser.parseContentRule(
        html,
        contentRule,
        baseUrl: response.realUri.toString(),
        bookName: null,
        bookOrigin: null,
      );
    } catch (e) {
      AppLog.instance.put('预取 RSS 正文失败: $articleUrl', error: e);
      return null;
    }
  }

  @visibleForTesting
  Future<List<RssArticle>> parseArticlesByRuleForTesting({
    required RssSource source,
    required String html,
    String sortName = '',
    String? sortUrl,
    String? redirectUrl,
  }) {
    final resolvedSortUrl = sortUrl ?? source.sourceUrl;
    return _parseByRule(
      source: source,
      html: html,
      sortName: sortName,
      sortUrl: resolvedSortUrl,
      redirectUrl: redirectUrl ?? resolvedSortUrl,
    );
  }

  @visibleForTesting
  Future<RssArticle?> parseArticleItemForTesting({
    required RssSource source,
    required String item,
    String? baseUrl,
    String? redirectUrl,
    Future<String?> Function(String url)? contentLoader,
  }) {
    final resolvedBaseUrl = baseUrl ?? source.sourceUrl;
    return _parseArticleItem(
      source: source,
      item: item,
      baseUrl: resolvedBaseUrl,
      redirectUrl: redirectUrl ?? resolvedBaseUrl,
      contentLoader: contentLoader,
    );
  }

  @visibleForTesting
  Future<String?> resolveNextPageUrlForTesting({
    required RssSource source,
    required String html,
    String? baseUrl,
    String? redirectUrl,
  }) {
    final resolvedBaseUrl = baseUrl ?? source.sourceUrl;
    return resolveNextPageUrl(
      source: source,
      html: html,
      baseUrl: resolvedBaseUrl,
      redirectUrl: redirectUrl ?? resolvedBaseUrl,
    );
  }

  /// 使用默认XML解析RSS文章
  /// 参考项目：RssParserDefault.parseXML
  List<RssArticle> _parseDefaultXML({
    required String xmlContent,
    required String sourceUrl,
    required String sortName,
  }) {
    final articleList = <RssArticle>[];
    
    try {
      final document = xml.XmlDocument.parse(xmlContent);
      
      // 查找所有item元素
      final items = document.findAllElements('item');
      
      for (final item in items) {
        String title = '';
        String link = sourceUrl;
        String? pubDate;
        String? description;
        String? image;

        // 解析标题
        final titleElements = item.findElements('title');
        if (titleElements.isNotEmpty) {
          title = titleElements.first.innerText.trim();
        }

        // 解析链接
        final linkElements = item.findElements('link');
        if (linkElements.isNotEmpty) {
          link = linkElements.first.innerText.trim();
        }

        // 解析描述
        final descriptionElements = item.findElements('description');
        if (descriptionElements.isNotEmpty) {
          description = descriptionElements.first.innerText.trim();
          // 从描述中提取图片
          if ((image ?? '').isEmpty) {
            image = _extractImageFromHtml(description);
          }
        }

        // 解析内容
        final contentEncodedElements = item.findElements('content:encoded');
        final contentElements = item.findElements('content');
        String? content;
        if (contentEncodedElements.isNotEmpty) {
          content = contentEncodedElements.first.innerText.trim();
        } else if (contentElements.isNotEmpty) {
          content = contentElements.first.innerText.trim();
        }
        
        // 从内容中提取图片
        if (content != null && (image == null || image.isEmpty)) {
          image = _extractImageFromHtml(content);
        }

        // 解析发布日期
        final pubDateElements = item.findElements('pubDate');
        final publishedElements = item.findElements('published');
        if (pubDateElements.isNotEmpty) {
          pubDate = pubDateElements.first.innerText.trim();
        } else if (publishedElements.isNotEmpty) {
          pubDate = publishedElements.first.innerText.trim();
        }

        // 解析图片（从enclosure或media:thumbnail）
        if (image == null || image.isEmpty) {
          final enclosureElements = item.findElements('enclosure');
          if (enclosureElements.isNotEmpty) {
            final enclosure = enclosureElements.first;
            final type = enclosure.getAttribute('type');
            if (type != null && type.contains('image/')) {
              image = enclosure.getAttribute('url');
            }
          }
        }

        if (image == null || image.isEmpty) {
          final thumbnailElements = item.findElements('media:thumbnail');
          if (thumbnailElements.isNotEmpty) {
            image = thumbnailElements.first.getAttribute('url');
          }
        }

        if (title.isNotEmpty) {
          articleList.add(RssArticle(
            origin: sourceUrl,
            link: link,
            sort: sortName,
            title: title,
            pubDate: pubDate,
            description: description,
            image: image,
            content: content,
          ));
        }
      }
    } catch (e) {
      AppLog.instance.put('解析RSS XML失败', error: e);
    }

    return articleList;
  }

  /// 从HTML中提取图片URL
  String? _extractImageFromHtml(String html) {
    try {
      // 匹配 <img src="..." 或 <img src='...'
      // 先尝试双引号
      var pattern = RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false);
      var match = pattern.firstMatch(html);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
      // 再尝试单引号
      pattern = RegExp(r"<img[^>]+src='([^']+)'", caseSensitive: false);
      match = pattern.firstMatch(html);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    } catch (e) {
      // 忽略错误
    }
    return null;
  }
}
