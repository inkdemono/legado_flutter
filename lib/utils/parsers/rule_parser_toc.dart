part of 'rule_parser.dart';

/// 目录规则解析实现（TOC-only 私有方法 + URL 列表工具）
///
/// 由 [RuleParser] 通过 `part` 机制引入，与主文件共享同一 Dart 库。
///
/// 包含以下职责：
/// - 异步目录规则解析 `_parseTocRuleAsync`（含 JS 的目录走此路径）
/// - 同步字段规则解析 `_parseFieldRuleSyncWithContext`（同步目录专用）
/// - `parseTocRuleWithNextUrl`（带分页 URL 的目录解析入口）
/// - `parseUrlListRuleAsync`（解析返回 URL 列表的规则）
/// - 四个 URL 列表工具私有方法
///
/// 注意：跨 TOC/Search 共用的 `_parseListEntries`、`_parseFieldRuleWithContext`
/// 等方法仍保留在 `rule_parser.dart` 主文件，由此文件通过 `RuleParser.xxx()` 调用。
class _RuleParserToc {
  _RuleParserToc._();

  // =========================================================================
  // 目录异步解析（含 JS 规则时走此路径）
  // =========================================================================

  /// 异步版目录规则解析
  ///
  /// 与 `RuleParser.parseTocRule`（同步）相比，此方法在每个章节字段的提取上
  /// 使用了 [RuleParser._parseFieldRuleWithContext]（异步），支持 JS 规则。
  static Future<List<Map<String, String?>>> _parseTocRuleAsync(
    String html,
    TocRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) async {
    if (rule == null || rule.chapterList == null) {
      return [];
    }

    final chapterEntries = RuleParser._parseListEntries(
      html,
      rule.chapterList,
      variables: variables,
      baseUrl: baseUrl,
    );

    final results = <Map<String, String?>>[];

    for (int i = 0; i < chapterEntries.length; i++) {
      final chapterHtml = chapterEntries[i].content;
      final itemVariables = <String, String>{
        ...?variables,
        ...chapterEntries[i].groups,
      };

      final chapterName = await RuleParser._parseFieldRuleWithContext(
            chapterHtml,
            rule.chapterName,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';
      final chapterUrl = await RuleParser._parseFieldRuleWithContext(
            chapterHtml,
            rule.chapterUrl,
            itemVariables,
            baseUrl: baseUrl,
            isUrl: true,
          ) ??
          '';
      final isVip = await RuleParser._parseFieldRuleWithContext(
            chapterHtml,
            rule.isVip,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';
      final isVolumeStr = await RuleParser._parseFieldRuleWithContext(
            chapterHtml,
            rule.isVolume,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';
      final updateTime = await RuleParser._parseFieldRuleWithContext(
            chapterHtml,
            rule.updateTime,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';
      final nextTocUrl = await RuleParser._parseFieldRuleWithContext(
            chapterHtml,
            rule.nextTocUrl,
            itemVariables,
            baseUrl: baseUrl,
            isUrl: true,
          ) ??
          '';
      // Phase 3：章节时长（音视频目录）
      final duration = await RuleParser._parseFieldRuleWithContext(
            chapterHtml,
            rule.duration,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';

      final isVolume = isVolumeStr.isNotEmpty &&
          (isVolumeStr.toLowerCase() == 'true' ||
              isVolumeStr == '1' ||
              isVolumeStr.trim().isNotEmpty);

      String? finalChapterUrl = chapterUrl;
      if (finalChapterUrl.isEmpty) {
        if (!isVolume) {
          finalChapterUrl = baseUrl;
        } else {
          finalChapterUrl = null;
        }
      }

      if (chapterName.isNotEmpty) {
        results.add({
          'chapterName': chapterName,
          'chapterUrl': finalChapterUrl,
          'isVip': isVip,
          'isVolume': isVolume ? '1' : '0',
          'updateTime': updateTime,
          'nextTocUrl': nextTocUrl,
          'duration': duration,
        });
      }
    }

    return results;
  }

  // =========================================================================
  // 同步字段规则（仅 parseTocRule 同步路径使用）
  // =========================================================================

  /// 同步版字段规则解析（含变量替换和正则后处理）
  ///
  /// 与 [RuleParser._parseFieldRuleWithContext]（异步）对应，
  /// 用于 `parseTocRule` 的同步快速路径（无 JS 规则时）。
  static String? _parseFieldRuleSyncWithContext(
    String html,
    String? rule,
    Map<String, String>? variables, {
    String? baseUrl,
    bool isUrl = false,
  }) {
    if (rule == null || rule.isEmpty) return null;
    final contextualRule = RuleParser._applyCaptureGroupVariables(rule, variables);
    final splitIndex = contextualRule.indexOf('##');
    final actualRule =
        splitIndex >= 0 ? contextualRule.substring(0, splitIndex) : contextualRule;
    final replaceRule = splitIndex >= 0 ? contextualRule.substring(splitIndex) : null;
    final literalResult = RuleParser._resolveCaptureGroupLiteral(
      rule,
      actualRule,
      baseUrl: baseUrl,
      isUrl: isUrl,
    );
    if (literalResult != null) {
      return replaceRule == null
          ? literalResult
          : RuleParser._applyReplaceRegexInternal(literalResult, replaceRule);
    }
    final parsed = RuleParser.parseRule(
      html,
      actualRule,
      variables: variables,
      baseUrl: baseUrl,
      isUrl: isUrl,
    );
    if (parsed == null || replaceRule == null) {
      return parsed;
    }
    return RuleParser._applyReplaceRegexInternal(parsed, replaceRule);
  }

  // =========================================================================
  // 带分页 URL 的目录解析（公开 API 实现）
  // =========================================================================

  /// 解析章节列表，同时提取下一页 URL 列表
  ///
  /// 参考项目：BookChapterList.analyzeChapterList (私有方法)
  /// 返回：`{'chapterList': List<...>, 'nextUrlList': List<String>}`
  static Future<Map<String, dynamic>> parseTocRuleWithNextUrl(
    String html,
    TocRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
    bool getNextUrl = true,
  }) async {
    // 先解析章节列表
    final chapterList = await _parseTocRuleAsync(
      html,
      rule,
      variables: variables,
      baseUrl: baseUrl,
    );

    // 获取下一页 URL 列表
    final nextUrlList = <String>[];
    if (getNextUrl &&
        rule?.nextTocUrl != null &&
        rule!.nextTocUrl!.isNotEmpty) {
      final urls = await parseUrlListRuleAsync(
        html,
        rule.nextTocUrl!,
        variables: variables,
        baseUrl: baseUrl,
      );
      nextUrlList.addAll(urls);

      // 过滤掉与当前 URL 相同的 URL，并拼接完整 URL
      final filteredUrls = nextUrlList
          .where((url) => url.isNotEmpty && url != baseUrl)
          .map((url) {
            try {
              return NetworkService.joinUrl(baseUrl ?? '', url);
            } catch (e) {
              AppLog.instance
                  .put('parseTocRuleWithNextUrl: 拼接URL失败: $url, 错误: $e');
              return url;
            }
          })
          .where((url) => url != baseUrl && url.isNotEmpty)
          .toList();

      nextUrlList.clear();
      nextUrlList.addAll(filteredUrls);
    }

    return {
      'chapterList': chapterList,
      'nextUrlList': nextUrlList,
    };
  }

  // =========================================================================
  // URL 列表规则解析（公开 API 实现）
  // =========================================================================

  /// 解析返回 URL 列表的规则
  ///
  /// 兼容说明页中 nextTocUrl/nextContentUrl 这类"可返回多个链接"的规则：
  /// 1. 普通 CSS/XPath/JSONPath 列表规则
  /// 2. JavaScript 规则返回 JSON 数组 / 文本列表 / 单个链接
  /// 3. 混合规则返回的单值结果
  static Future<List<String>> parseUrlListRuleAsync(
    String html,
    String? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) async {
    if (rule == null || rule.isEmpty) return const [];

    final results = <String>[];
    final seen = <String>{};

    void addValue(String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) return;
      results.add(trimmed);
    }

    void addAllValues(Iterable<String> values) {
      for (final value in values) {
        addValue(value);
      }
    }

    final hasExecutableJs = _ruleContainsExecutableJs(rule, variables);
    final jsOnlyRule = _isJsOnlyRule(rule);

    if (hasExecutableJs) {
      final jsResult = await RuleParser.parseRuleAsync(
        html,
        rule,
        variables: variables,
        baseUrl: baseUrl,
        isUrl: true,
      );
      addAllValues(_normalizeRuleListResult(jsResult));
    }

    if (!jsOnlyRule) {
      final listResult = RuleParser.parseListRule(
        html,
        rule,
        variables: variables,
        baseUrl: baseUrl,
        returnHtml: false,
      );
      addAllValues(listResult);
    }

    if (results.isEmpty) {
      final singleResult = await RuleParser.parseRuleAsync(
        html,
        rule,
        variables: variables,
        baseUrl: baseUrl,
        isUrl: true,
      );
      addAllValues(_normalizeRuleListResult(singleResult));
    }

    if (baseUrl == null || baseUrl.isEmpty) {
      return results;
    }

    return results
        .map((item) => item.startsWith('http') || item.startsWith('data:')
            ? item
            : NetworkService.joinUrl(baseUrl, item))
        .toList();
  }

  // =========================================================================
  // URL 列表工具私有方法
  // =========================================================================

  /// 判断规则是否含有需要执行的 JS（含变量引用未在 variables 中的情况）
  static bool _ruleContainsExecutableJs(
    String rule,
    Map<String, String>? variables,
  ) {
    if (rule.contains('<js>') ||
        rule.contains('</js>') ||
        rule.toLowerCase().contains('@js:')) {
      return true;
    }

    final varPattern = RegexCache.instance.getOrCompile(r'\{\{([^}]+)\}\}');
    for (final match in varPattern.allMatches(rule)) {
      final key = match.group(1)?.trim();
      if (key == null) continue;
      if (variables == null || !variables.containsKey(key)) {
        return true;
      }
    }
    return false;
  }

  /// 判断规则是否为纯 JS（无 CSS/XPath/JSONPath 部分）
  static bool _isJsOnlyRule(String rule) {
    final trimmed = rule.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('@js:')) return true;
    if (trimmed.startsWith('<js>') && trimmed.endsWith('</js>')) return true;
    if (trimmed.startsWith('{{') && trimmed.endsWith('}}')) return true;
    return false;
  }

  /// 将规则执行结果标准化为 `List<String>`
  ///
  /// 支持：JSON 数组字符串、`&&` 分隔多值、换行分隔多值、单值。
  static List<String> _normalizeRuleListResult(String? rawResult) {
    if (rawResult == null) return const [];

    final trimmed = rawResult.trim();
    if (trimmed.isEmpty ||
        trimmed == 'null' ||
        trimmed == 'undefined' ||
        trimmed == '[]') {
      return const [];
    }

    if ((trimmed.startsWith('[') && trimmed.endsWith(']')) ||
        (trimmed.startsWith('{') && trimmed.endsWith('}'))) {
      try {
        final decoded = jsonDecode(trimmed);
        return _flattenRuleListValue(decoded);
      } catch (_) {}
    }

    if (trimmed.contains('&&') || trimmed.contains('\n')) {
      return trimmed
          .split(RegExp(r'(?:&&|\r?\n)+'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [trimmed];
  }

  /// 递归展平 JSON 值为字符串列表
  static List<String> _flattenRuleListValue(dynamic value) {
    if (value == null) return const [];
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? const [] : [trimmed];
    }
    if (value is List) {
      return value.expand(_flattenRuleListValue).toList();
    }
    if (value is Map) {
      return value.values.expand(_flattenRuleListValue).toList();
    }
    return [value.toString()];
  }
}
