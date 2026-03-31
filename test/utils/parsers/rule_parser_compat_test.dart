import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/data/models/book_source_rule.dart';
import 'package:legado_flutter/utils/parsers/rule_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RuleParser compatibility', () {
    test('parseTocRule allows tag.a@href to read current anchor element', () {
      const html = '''
      <div class="chapters">
        <a href="/chapter/1.html">第一章</a>
      </div>
      ''';

      final result = RuleParser.parseTocRule(
        html,
        TocRule(
          chapterList: '.chapters a',
          chapterName: 'text',
          chapterUrl: 'tag.a@href',
        ),
        baseUrl: 'https://example.com/book/',
      );

      expect(result, hasLength(1));
      expect(result.first['chapterName'], equals('第一章'));
      expect(
        result.first['chapterUrl'],
        equals('https://example.com/chapter/1.html'),
      );
    });

    test('parseTocRule supports standalone href on html fragment root', () {
      const html = '''
      <div class="chapters">
        <a href="/chapter/2.html">第二章</a>
      </div>
      ''';

      final result = RuleParser.parseTocRule(
        html,
        TocRule(
          chapterList: '.chapters a',
          chapterName: 'text',
          chapterUrl: 'href',
        ),
        baseUrl: 'https://example.com/book/',
      );

      expect(result, hasLength(1));
      expect(result.first['chapterUrl'], equals('https://example.com/chapter/2.html'));
    });

    test('parseListRule supports leading minus to reverse result order', () {
      const html = '''
      <ul>
        <li>第一章</li>
        <li>第二章</li>
        <li>第三章</li>
      </ul>
      ''';

      final result = RuleParser.parseListRule(
        html,
        '-li',
      );

      expect(result, equals(['第三章', '第二章', '第一章']));
    });

    test('parseSearchRule supports AllInOne regex list with capture groups',
        () async {
      const html = '''
      <a href="/book/1" class="item">书名一|作者甲</a>
      <a href="/book/2" class="item">书名二|作者乙</a>
      ''';

      final result = await RuleParser.parseSearchRule(
        html,
        SearchRule(
          bookList: r'+<a href="([^"]+)" class="item">([^|<]+)\|([^<]+)</a>',
          bookUrl: r'$1',
          name: r'$2',
          author: r'$3',
        ),
        baseUrl: 'https://example.com',
      );

      expect(result, hasLength(2));
      expect(result.first['bookUrl'], equals('https://example.com/book/1'));
      expect(result.first['name'], equals('书名一'));
      expect(result.first['author'], equals('作者甲'));
      expect(result.last['bookUrl'], equals('https://example.com/book/2'));
      expect(result.last['name'], equals('书名二'));
      expect(result.last['author'], equals('作者乙'));
    });

    test('parseExploreRule supports JSON list rules with field context',
        () async {
      const json = '''
      {
        "data": {
          "data": [
            {
              "comic_id": "1001",
              "comic_newid": "abc123",
              "comic_name": "漫画一",
              "comic_author": "作者甲",
              "comic_type": "rexue|xuanhuan",
              "last_chapter_name": "第10话",
              "cartoon_desc": "简介一",
              "cover_img": "https://img.example.com/1.jpg",
              "update_time": 1710000000
            },
            {
              "comic_id": "1002",
              "comic_newid": "def456",
              "comic_name": "漫画二",
              "comic_author": "作者乙",
              "comic_type": "maoxian|kehuan",
              "last_chapter_name": "第20话",
              "cartoon_desc": "简介二",
              "cover_img": "https://img.example.com/2.jpg",
              "update_time": 1720000000
            }
          ]
        }
      }
      ''';

      final result = await RuleParser.parseExploreRule(
        json,
        ExploreRule(
          bookList: r'$.data.data[*]||$.data[*]',
          name: r'$.comic_name@put:{bid:$.comic_id}',
          author: r'$.comic_author',
          kind: r'$.comic_type##[a-zA-Z]|\|',
          lastChapter: r'$.last_chapter_name',
          intro: r'$.cartoon_desc',
          coverUrl: r'$..cover_img',
          bookUrl: r'https://m.manhuatai.com/{$.comic_newid}/',
        ),
        baseUrl: 'https://m.manhuatai.com/',
      );

      expect(result, hasLength(2));
      expect(result.first['name'], equals('漫画一'));
      expect(result.first['author'], equals('作者甲'));
      expect(result.first['bookUrl'], equals('https://m.manhuatai.com/abc123/'));
      expect(result.first['coverUrl'], equals('https://img.example.com/1.jpg'));
      expect(result.first['variable'], equals('{"bid":"1001"}'));
      expect(result.last['name'], equals('漫画二'));
      expect(result.last['bookUrl'], equals('https://m.manhuatai.com/def456/'));
      expect(result.last['variable'], equals('{"bid":"1002"}'));
    });

    test('parseTocRule supports AllInOne regex list with capture groups',
        () async {
      const html = '''
      <a href="/c1">第一章</a>
      <a href="/c2">第二章</a>
      ''';

      final result = RuleParser.parseTocRule(
        html,
        TocRule(
          chapterList: r'+<a href="([^"]+)">([^<]+)</a>',
          chapterUrl: r'$1',
          chapterName: r'$2',
        ),
        baseUrl: 'https://example.com/book',
      );

      expect(result, hasLength(2));
      expect(result.first['chapterUrl'], equals('https://example.com/c1'));
      expect(result.first['chapterName'], equals('第一章'));
      expect(result.last['chapterUrl'], equals('https://example.com/c2'));
      expect(result.last['chapterName'], equals('第二章'));
    });

    test('parseTocRule supports OnlyOne-style regex list rule', () async {
      const html = '''
      <a href="/c1">第一章</a>
      <a href="/c2">第二章</a>
      ''';

      final result = RuleParser.parseTocRule(
        html,
        TocRule(
          chapterList: r':<a href="([^"]+)">([^<]+)</a>',
          chapterUrl: r'$1',
          chapterName: r'$2',
        ),
        baseUrl: 'https://example.com/book',
      );

      expect(result, hasLength(2));
      expect(result.first['chapterUrl'], equals('https://example.com/c1'));
      expect(result.first['chapterName'], equals('第一章'));
      expect(result.last['chapterUrl'], equals('https://example.com/c2'));
      expect(result.last['chapterName'], equals('第二章'));
    });

    test('parseTocRuleWithNextUrl supports chapterUrl JS transformation',
        () async {
      const html = '''
      <ul class="chapter-list">
        <li><a href="https://m.manhuatai.com/abc/1001.html">第一话</a></li>
        <li><a href="https://m.manhuatai.com/abc/1002.html">第二话</a></li>
      </ul>
      ''';

      final result = await RuleParser.parseTocRuleWithNextUrl(
        html,
        TocRule(
          chapterList: 'class.chapter-list@li',
          chapterName: 'tag.a@text',
          chapterUrl:
              "tag.a@href\n@js:\nvar num=result.match(/.*\\/(.*).html/)[1];\n'https://m.manhuatai.com/api/getchapterinfov2?comic_id=@get:{bid}&chapter_newid='+num",
        ),
        baseUrl: 'https://m.manhuatai.com/book/1/',
        variables: {'bid': '42'},
      );

      final chapters = result['chapterList'] as List<Map<String, String?>>;
      expect(chapters, hasLength(2));
      expect(
        chapters.first['chapterUrl'],
        equals(
          'https://m.manhuatai.com/api/getchapterinfov2?comic_id=42&chapter_newid=1001',
        ),
      );
      expect(
        chapters.last['chapterUrl'],
        equals(
          'https://m.manhuatai.com/api/getchapterinfov2?comic_id=42&chapter_newid=1002',
        ),
      );
    });

    test('parseRuleAsync supports standalone textNodes attribute', () async {
      const html = '''
      <div>
        头部文本
        <span>子节点</span>
        尾部文本
      </div>
      ''';

      final result = await RuleParser.parseRuleAsync(html, 'textNodes');

      expect(result, contains('头部文本'));
      expect(result, contains('子节点'));
      expect(result, contains('尾部文本'));
    });

    test('parseRuleAsync normalizes dot-bracket JSONPath syntax', () async {
      const json = '''
      {
        "current_chapter": {
          "chapter_img_list": ["a.jpg", "b.jpg"]
        }
      }
      ''';

      final result = await RuleParser.parseRuleAsync(
        json,
        r'$..current_chapter.chapter_img_list.[*]',
      );

      expect(result, equals('a.jpg\nb.jpg'));
    });

    test('parseRuleAsync supports legado index selector semantics', () async {
      const html = '''
      <dl>
        <dd><span>第一项</span></dd>
        <dd><span>第二项</span></dd>
        <dd><span>第三项</span></dd>
      </dl>
      ''';

      final result = await RuleParser.parseRuleAsync(html, 'dd span.1@text');

      expect(result, equals('第二项'));
    });

    test('parseRuleAsync keeps put/get behavior for non-JS rules', () async {
      const html = '<div>ignored</div>';

      final result = await RuleParser.parseRuleAsync(
        html,
        '@put:{"foo":"bar"}@get:{foo}',
      );

      expect(result, equals('bar'));
    });

    test('parseRuleAsync does not expand @get inside JS fragments', () async {
      const html = '<div>ignored</div>';

      final result = await RuleParser.parseRuleAsync(
        html,
        '@put:{"foo":"bar"}<js>"@get:{foo}"</js>',
      );

      expect(result, equals('@get:{foo}'));
    });

    test('parseRuleAsync does not treat colon rule as regex outside allowed contexts',
        () async {
      const html = '<div>abc123</div>';

      final result = await RuleParser.parseRuleAsync(
        html,
        r':\d+',
      );

      expect(result, isNull);
    });

    test('parseUrlListRuleAsync supports JS array results for pagination rules',
        () async {
      const html = '<html><body><div>content</div></body></html>';

      final urls = await RuleParser.parseUrlListRuleAsync(
        html,
        '@js:JSON.stringify(["/page/2","/page/3"])',
        baseUrl: 'https://example.com/chapter/1',
      );

      expect(
        urls,
        equals([
          'https://example.com/page/2',
          'https://example.com/page/3',
        ]),
      );
    });

    test('parseContentRule prefers capture groups in sourceRegex', () async {
      const html = '''
      <div id="content">
        <p>第一段</p>
        <p>第二段</p>
      </div>
      ''';

      final result = await RuleParser.parseContentRule(
        html,
        ContentRule(
          content: 'id.content@html',
          sourceRegex: r'<p>(.*?)</p>',
        ),
      );

      expect(result, isNotNull);
      expect(result, contains('第一段'));
      expect(result, contains('第二段'));
      expect(result, isNot(contains('<p>')));
    });

    test('parseTocRuleWithNextUrl supports multi-link pagination rules',
        () async {
      const html = '''
      <div class="chapter">
        <a href="/c1">第一章</a>
      </div>
      <div class="pager">
        <a class="next" href="/toc/2">下一页</a>
        <a class="next" href="/toc/3">下下页</a>
      </div>
      ''';

      final result = await RuleParser.parseTocRuleWithNextUrl(
        html,
        TocRule(
          chapterList: 'class.chapter',
          chapterName: 'a@text',
          chapterUrl: 'a@href',
          nextTocUrl: 'class.next@href',
        ),
        baseUrl: 'https://example.com/toc/1',
      );

      expect(result['chapterList'], hasLength(1));
      expect(
        result['nextUrlList'],
        equals([
          'https://example.com/toc/2',
          'https://example.com/toc/3',
        ]),
      );
    });

    test('parseBookInfoRule supports regex init preprocessing', () async {
      const html = '''
      <script id="book-json">
        {"name":"正则预加载书籍","author":"作者甲"}
      </script>
      ''';

      final result = await RuleParser.parseBookInfoRule(
        html,
        BookInfoRule(
          init: r':\{[\s\S]*\}',
          name: r'$.name',
          author: r'$.author',
        ),
      );

      expect(result['name'], equals('正则预加载书籍'));
      expect(result['author'], equals('作者甲'));
    });
  });
}
