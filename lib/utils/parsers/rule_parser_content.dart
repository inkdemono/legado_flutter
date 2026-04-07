part of 'rule_parser.dart';

/// 正文内容规则解析实现。
class _RuleParserContent {
  _RuleParserContent._();

  static Future<String?> parseContentRule(
    String html,
    ContentRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
    String? bookName,
    String? bookOrigin,
    bool applyReplaceRegex = true,
    int bookSourceType = 0,
  }) async {
    if (rule == null) return null;

    if (bookSourceType == 1) {
      return await _RuleParserMedia.parseAudioContent(html, rule,
          variables: variables, baseUrl: baseUrl);
    }

    if (bookSourceType == 2) {
      return await _RuleParserMedia.parseVideoContent(html, rule,
          variables: variables, baseUrl: baseUrl);
    }

    if (rule.content == null) return null;

    try {
      if (rule.webJs != null && rule.webJs!.isNotEmpty) {
        html = await RuleParser._executeJs(
              html,
              rule.webJs!,
              variables: variables,
            ) ??
            html;
      }

      String? content = await RuleParser.parseRuleAsync(
        html,
        rule.content,
        variables: variables,
        baseUrl: baseUrl,
      );

      if (content == null || content.isEmpty) {
        final contentPattern = RegExp(
          'id\\s*=\\s*["\']([^"\']*content[^"\']*)["\']',
          caseSensitive: false,
        );
        final contentMatches = contentPattern.allMatches(html);
        final contentIds = contentMatches
            .map((m) => m.group(1))
            .whereType<String>()
            .take(10)
            .toList();

        final contentClassPattern = RegExp(
          'class\\s*=\\s*["\']([^"\']*content[^"\']*)["\']',
          caseSensitive: false,
        );
        final contentClassMatches = contentClassPattern.allMatches(html);
        final contentClassesList = <String>[];
        for (final match in contentClassMatches) {
          final classAttr = match.group(1);
          if (classAttr != null) {
            final classes = classAttr.split(RegExp(r'\s+'));
            for (final cls in classes) {
              if (cls.contains('content') && !contentClassesList.contains(cls)) {
                contentClassesList.add(cls);
              }
            }
          }
        }
        final contentClasses = contentClassesList.take(10).toList();

        final otherIdPattern = RegExp(
          'id\\s*=\\s*["\']([^"\']*(?:nr|text|article|main|body|read|book)[^"\']*)["\']',
          caseSensitive: false,
        );
        final otherIdMatches = otherIdPattern.allMatches(html);
        final otherIds = otherIdMatches
            .map((m) => m.group(1))
            .whereType<String>()
            .take(10)
            .toList();

        final otherClassPattern = RegExp(
          'class\\s*=\\s*["\']([^"\']*(?:nr|text|article|main|body|read|book)[^"\']*)["\']',
          caseSensitive: false,
        );
        final otherClassMatches = otherClassPattern.allMatches(html);
        final otherClassesList = <String>[];
        for (final match in otherClassMatches) {
          final classAttr = match.group(1);
          if (classAttr != null) {
            final classes = classAttr.split(RegExp(r'\s+'));
            for (final cls in classes) {
              if ((cls.contains('nr') ||
                      cls.contains('text') ||
                      cls.contains('article') ||
                      cls.contains('main') ||
                      cls.contains('body') ||
                      cls.contains('read') ||
                      cls.contains('book')) &&
                  !otherClassesList.contains(cls) &&
                  !contentClassesList.contains(cls)) {
                otherClassesList.add(cls);
              }
            }
          }
        }
        final otherClasses = otherClassesList.take(10).toList();

        final fallbackRules = <String>[];
        for (final id in contentIds) {
          fallbackRules.add('id.$id@html');
          fallbackRules.add('id.$id@text');
        }
        for (final cls in contentClasses) {
          fallbackRules.add('class.$cls@html');
          fallbackRules.add('class.$cls@text');
        }
        for (final id in otherIds) {
          fallbackRules.add('id.$id@html');
          fallbackRules.add('id.$id@text');
        }
        for (final cls in otherClasses) {
          fallbackRules.add('class.$cls@html');
          fallbackRules.add('class.$cls@text');
        }

        fallbackRules.addAll([
          'id.content@html',
          'id.content@text',
          'class.content@html',
          'class.content@text',
          'id.nr1@html',
          'id.nr1@text',
          'class.nr1@html',
          'class.nr1@text',
          'id.text@html',
          'id.text@text',
          'class.text@html',
          'class.text@text',
          'div.content@html',
          'div.content@text',
          'div#content@html',
          'div#content@text',
        ]);

        for (final fallbackRule in fallbackRules) {
          final fallbackContent = RuleParser.parseRule(
            html,
            fallbackRule,
            variables: variables,
            baseUrl: baseUrl,
          );
          if (fallbackContent != null && fallbackContent.isNotEmpty) {
            content = fallbackContent;
            break;
          }
        }

        if (content == null || content.isEmpty) {
          return null;
        }
      }

      String processedContent = content;

      final sourceRegexValue = rule.sourceRegex;
      if (sourceRegexValue != null && sourceRegexValue.isNotEmpty) {
        try {
          final regex = RegexCache.instance.getOrCompile(
            sourceRegexValue,
            multiLine: true,
          );
          final matches = regex.allMatches(processedContent);
          if (matches.isNotEmpty) {
            final extractedParts = matches
                .map((match) {
                  for (int i = 1; i <= match.groupCount; i++) {
                    final group = match.group(i);
                    if (group != null && group.isNotEmpty) {
                      return group;
                    }
                  }
                  return match.group(0) ?? '';
                })
                .where((item) => item.isNotEmpty)
                .toList();
            final extractedContent = extractedParts.join('\n');
            if (extractedContent.isNotEmpty) {
              processedContent = extractedContent;
            }
          }
        } catch (e) {
          AppLog.instance.put(
            'parseContentRule: sourceRegex规则错误: $sourceRegexValue',
            error: e,
          );
        }
      }

      if (baseUrl != null && baseUrl.isNotEmpty) {
        final imgPattern1 = RegexCache.instance.getOrCompile(
          r'<img([^>]*?)src=["]([^"]*?)"([^>]*?)>',
          caseSensitive: false,
        );
        final imgPattern2 = RegexCache.instance.getOrCompile(
          r"<img([^>]*?)src=[']([^']*?)'([^>]*?)>",
          caseSensitive: false,
        );

        processedContent =
            processedContent.replaceAllMapped(imgPattern1, (match) {
          final beforeSrc = match.group(1) ?? '';
          final imgSrc = match.group(2) ?? '';
          final afterSrc = match.group(3) ?? '';

          String absoluteSrc = imgSrc;
          if (imgSrc.isNotEmpty &&
              !imgSrc.startsWith('http') &&
              !imgSrc.startsWith('data:')) {
            absoluteSrc = NetworkService.joinUrl(baseUrl, imgSrc);
          }

          return '<img$beforeSrc src="$absoluteSrc"$afterSrc>';
        });

        processedContent =
            processedContent.replaceAllMapped(imgPattern2, (match) {
          final beforeSrc = match.group(1) ?? '';
          final imgSrc = match.group(2) ?? '';
          final afterSrc = match.group(3) ?? '';

          String absoluteSrc = imgSrc;
          if (imgSrc.isNotEmpty &&
              !imgSrc.startsWith('http') &&
              !imgSrc.startsWith('data:')) {
            absoluteSrc = NetworkService.joinUrl(baseUrl, imgSrc);
          }

          return "<img$beforeSrc src='$absoluteSrc'$afterSrc>";
        });
      }

      if (processedContent.contains('&')) {
        processedContent = processedContent
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&#39;', "'")
            .replaceAll('&nbsp;', ' ');
        processedContent = processedContent.replaceAllMapped(
          RegexCache.instance.getOrCompile(r'&#(\d+);'),
          (match) {
            final code = int.tryParse(match.group(1) ?? '');
            if (code != null) {
              return String.fromCharCode(code);
            }
            return match.group(0) ?? '';
          },
        );
        processedContent = processedContent.replaceAllMapped(
          RegexCache.instance.getOrCompile(r'&#x([0-9a-fA-F]+);'),
          (match) {
            final code = int.tryParse(match.group(1) ?? '', radix: 16);
            if (code != null) {
              return String.fromCharCode(code);
            }
            return match.group(0) ?? '';
          },
        );
      }

      final imageStyleValue = rule.imageStyle;
      if (imageStyleValue != null && imageStyleValue.isNotEmpty) {
        try {
          final imgPattern = RegexCache.instance.getOrCompile(
            r'<img([^>]*)>',
            caseSensitive: false,
          );
          processedContent =
              processedContent.replaceAllMapped(imgPattern, (match) {
            final imgAttrs = match.group(1) ?? '';
            if (imgAttrs.contains('style=')) {
              return '<img$imgAttrs style="$imgAttrs;$imageStyleValue">';
            } else {
              return '<img$imgAttrs style="$imageStyleValue">';
            }
          });
        } catch (e) {
          AppLog.instance.put(
            'parseContentRule: imageStyle规则错误: $imageStyleValue',
            error: e,
          );
        }
      }

      processedContent = HtmlParser.cleanHtml(processedContent);

      if (applyReplaceRegex &&
          rule.replaceRegex != null &&
          rule.replaceRegex!.isNotEmpty) {
        final lines = processedContent.split('\n');
        processedContent = lines.map((line) => line.trim()).join('\n');
        processedContent = RuleParser._applyReplaceRegexInternal(
          processedContent,
          rule.replaceRegex!,
        );
        final processedLines = processedContent.split('\n');
        processedContent = processedLines.map((line) => '　　$line').join('\n');
      }

      processedContent = RuleParser._cleanWhitespace(processedContent);

      try {
        List<ReplaceRule>? rules;
        if (bookName != null && bookOrigin != null) {
          rules = await readService(AppServices.replaceRuleService)
              .getEnabledRulesByContentScope(
            bookName,
            bookOrigin,
          );
        }
        if (rules != null && rules.isNotEmpty) {
          processedContent = await readService(AppServices.replaceRuleService)
              .applyRules(processedContent, rules: rules);
        }
      } catch (e) {
        AppLog.instance.put('parseContentRule: 应用全局替换规则失败', error: e);
      }

      return processedContent;
    } catch (e) {
      return null;
    }
  }
}
