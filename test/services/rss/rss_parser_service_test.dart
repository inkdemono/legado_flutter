import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/data/models/rss_source.dart';
import 'package:legado_flutter/services/rss/rss_parser_service.dart';

void main() {
  group('RssParserService', () {
    test('parseArticlesByRuleForTesting parses article items', () async {
      const html = '''
<html>
  <body>
    <ul class="articles">
      <li class="item">
        <a class="link" href="/article-1">第一篇</a>
        <span class="date">2026-03-01</span>
      </li>
      <li class="item">
        <a class="link" href="/article-2">第二篇</a>
        <span class="date">2026-03-02</span>
      </li>
    </ul>
  </body>
</html>
''';

      final source = RssSource(
        sourceUrl: 'https://example.com/feed',
        sourceName: 'Test RSS',
        ruleArticles: '.item',
        ruleTitle: '.link@text',
        ruleLink: '.link@href',
        rulePubDate: '.date@text',
      );

      final articles = await RssParserService.instance.parseArticlesByRuleForTesting(
        source: source,
        html: html,
        sortName: '默认分类',
        sortUrl: 'https://example.com/feed',
      );

      expect(articles, hasLength(2));
      expect(articles[0].title, '第一篇');
      expect(articles[0].link, 'https://example.com/article-1');
      expect(articles[0].pubDate, '2026-03-01');
      expect(articles[0].sort, '默认分类');
      expect(articles[1].title, '第二篇');
      expect(articles[1].link, 'https://example.com/article-2');
    });

    test('resolveNextPageUrlForTesting resolves relative next page URL', () async {
      const html = '''
<html>
  <body>
    <a class="next" href="/feed/page/2">下一页</a>
  </body>
</html>
''';

      final source = RssSource(
        sourceUrl: 'https://example.com/feed',
        sourceName: 'Test RSS',
        ruleArticles: '.item',
        ruleNextPage: '.next@href',
      );

      final nextUrl = await RssParserService.instance.resolveNextPageUrlForTesting(
        source: source,
        html: html,
        baseUrl: 'https://example.com/feed',
        redirectUrl: 'https://example.com/feed',
      );

      expect(nextUrl, 'https://example.com/feed/page/2');
    });

    test('resolveNextPageUrlForTesting returns null when rule does not match', () async {
      const html = '<html><body><p>没有下一页</p></body></html>';

      final source = RssSource(
        sourceUrl: 'https://example.com/feed',
        sourceName: 'Test RSS',
        ruleArticles: '.item',
        ruleNextPage: '.next@href',
      );

      final nextUrl = await RssParserService.instance.resolveNextPageUrlForTesting(
        source: source,
        html: html,
      );

      expect(nextUrl, isNull);
    });

    test('parseArticleItemForTesting preloads content when description is missing', () async {
      const item = '''
<li class="item">
  <a class="link" href="/article-1">第一篇</a>
</li>
''';

      final source = RssSource(
        sourceUrl: 'https://example.com/feed',
        sourceName: 'Test RSS',
        ruleTitle: '.link@text',
        ruleLink: '.link@href',
        ruleContent: '.article@text',
      );

      var loaderCalls = 0;
      final article = await RssParserService.instance.parseArticleItemForTesting(
        source: source,
        item: item,
        baseUrl: 'https://example.com/feed',
        contentLoader: (url) async {
          loaderCalls++;
          expect(url, 'https://example.com/article-1');
          return '正文内容';
        },
      );

      expect(article, isNotNull);
      expect(article!.content, '正文内容');
      expect(loaderCalls, 1);
    });

    test('parseArticleItemForTesting skips content preload when description exists', () async {
      const item = '''
<li class="item">
  <a class="link" href="/article-1">第一篇</a>
  <p class="desc">摘要</p>
</li>
''';

      final source = RssSource(
        sourceUrl: 'https://example.com/feed',
        sourceName: 'Test RSS',
        ruleTitle: '.link@text',
        ruleLink: '.link@href',
        ruleDescription: '.desc@text',
        ruleContent: '.article@text',
      );

      var loaderCalls = 0;
      final article = await RssParserService.instance.parseArticleItemForTesting(
        source: source,
        item: item,
        baseUrl: 'https://example.com/feed',
        contentLoader: (url) async {
          loaderCalls++;
          return '正文内容';
        },
      );

      expect(article, isNotNull);
      expect(article!.description, '摘要');
      expect(article.content, isNull);
      expect(loaderCalls, 0);
    });
  });
}
