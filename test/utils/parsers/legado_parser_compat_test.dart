import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/data/models/book_source.dart';
import 'package:legado_flutter/data/models/book_source_rule.dart';
import 'package:legado_flutter/utils/parsers/legado_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LegadoParser compatibility', () {
    test('parseSearchList keeps checkKeyWord field', () async {
      final parser = LegadoParser();
      final source = BookSource(
        bookSourceUrl: 'https://example.com',
        ruleSearch: SearchRule(
          bookList: 'class.item',
          name: 'class.name@text',
          checkKeyWord: 'class.flag@text',
        ),
      );

      const html = '''
      <div class="item">
        <span class="name">测试书籍</span>
        <span class="flag">命中关键词</span>
      </div>
      ''';

      final result = await parser.parseSearchList(
        htmlContent: html,
        bookSource: source,
        baseUrl: 'https://example.com',
      );

      expect(result, hasLength(1));
      expect(result.first['checkKeyWord'], equals('命中关键词'));
    });

    test('parseContent follows unified sourceRegex and nextContentUrl logic',
        () async {
      final parser = LegadoParser();
      final source = BookSource(
        bookSourceUrl: 'https://example.com',
        ruleContent: ContentRule(
          content: 'id.content@html',
          sourceRegex: r'<p>(.*?)</p>',
          nextContentUrl: '@js:JSON.stringify(["/next-page"])',
        ),
      );

      const html = '''
      <div id="content">
        <p>第一段</p>
        <p>第二段</p>
      </div>
      ''';

      final result = await parser.parseContent(
        htmlContent: html,
        bookSource: source,
        baseUrl: 'https://example.com/chapter/1',
      );

      expect(result['content'], contains('第一段'));
      expect(result['content'], contains('第二段'));
      expect(result['content'], isNot(contains('<p>')));
      expect(
        result['nextContentUrl'],
        equals('https://example.com/next-page'),
      );
    });
  });
}
