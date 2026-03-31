import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/ui/pages/rss/rss_read_page.dart';

void main() {
  group('rss_read_page helpers', () {
    test('rssUrlMatchesRule supports prefix and regex rules', () {
      expect(rssUrlMatchesRule('https://example.com/a.png', 'https://example.com/'), isTrue);
      expect(rssUrlMatchesRule('https://cdn.example.com/a.png', r'^https://cdn\.example\.com/.+\.png$'), isTrue);
      expect(rssUrlMatchesRule('https://example.com/a.png', r'['), isFalse);
    });

    test('rssShouldFilterResource applies blacklist before whitelist', () {
      expect(
        rssShouldFilterResource(
          'https://ads.example.com/banner.js',
          whitelist: const ['https://example.com/'],
          blacklist: const ['https://ads.example.com/'],
        ),
        isTrue,
      );
    });

    test('rssShouldFilterResource removes non-whitelisted resource when whitelist exists', () {
      expect(
        rssShouldFilterResource(
          'https://cdn.example.com/image.jpg',
          whitelist: const ['https://example.com/'],
          blacklist: const [],
        ),
        isTrue,
      );
      expect(
        rssShouldFilterResource(
          'https://example.com/image.jpg',
          whitelist: const ['https://example.com/'],
          blacklist: const [],
        ),
        isFalse,
      );
    });

    test('rssJsResultIsTrue recognizes true-like strings', () {
      expect(rssJsResultIsTrue('true'), isTrue);
      expect(rssJsResultIsTrue(' TRUE '), isTrue);
      expect(rssJsResultIsTrue('1'), isTrue);
      expect(rssJsResultIsTrue('false'), isFalse);
      expect(rssJsResultIsTrue(null), isFalse);
    });

    test('rssShouldOpenOriginalPage follows legado fallback rule', () {
      expect(
        rssShouldOpenOriginalPage(ruleContent: null, description: null),
        isTrue,
      );
      expect(
        rssShouldOpenOriginalPage(ruleContent: '', description: '摘要'),
        isFalse,
      );
      expect(
        rssShouldOpenOriginalPage(ruleContent: '.content@text', description: null),
        isFalse,
      );
    });
  });
}
