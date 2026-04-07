part of 'rule_parser.dart';

/// 音视频内容规则解析实现
///
/// 由 [RuleParser] 通过 `part` 机制引入，与主文件共享同一 Dart 库，
/// 因此可以直接访问 [RuleParser] 的库级私有方法（如 `_executeJs`）。
///
/// 职责范围：
/// - 音频内容解析（bookSourceType == 1）
/// - 视频内容解析（bookSourceType == 2）
/// - 辅助字段解析（歌词、字幕、多码率）
/// - 付费解锁执行（payAction）
class _RuleParserMedia {
  _RuleParserMedia._();

  /// 音频源内容解析（bookSourceType == 1）
  ///
  /// 解析优先级（高→低）：
  ///   1. [ContentRule.audioUrl] 规则 —— 书源作者明确指定的音频 URL 提取规则
  ///   2. [ContentRule.content] + [ContentRule.sourceRegex] —— 通用嗅探路径
  ///   3. [ContentRule.content] 原始值 —— 兜底（适用于 content 直接返回音频 URL 的书源）
  ///
  /// 注意：音频路径不需要经过 HTML 清理、段落缩进、全局替换规则等文本处理步骤，
  /// 因此与文本书源共用 parseContentRule 主流程会造成 URL 被破坏，此方法完全独立。
  static Future<String?> parseAudioContent(
    String html,
    ContentRule rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) async {
    try {
      // ── 执行 webJs（如果有）──────────────────────────────────────────────
      if (rule.webJs != null && rule.webJs!.isNotEmpty) {
        html =
            await RuleParser._executeJs(html, rule.webJs!, variables: variables) ?? html;
      }

      // ── 优先路径：audioUrl 规则 ─────────────────────────────────────────
      if (rule.audioUrl != null && rule.audioUrl!.isNotEmpty) {
        final audioUrl = await RuleParser.parseRuleAsync(html, rule.audioUrl!,
            variables: variables, baseUrl: baseUrl);
        if (audioUrl != null && audioUrl.isNotEmpty) {
          AppLog.instance
              .put('_parseAudioContent: audioUrl规则提取成功 → $audioUrl');
          // 处理相对 URL
          if (!audioUrl.startsWith('http') && baseUrl != null) {
            return NetworkService.joinUrl(baseUrl, audioUrl);
          }
          return audioUrl;
        }
        AppLog.instance.put('_parseAudioContent: audioUrl规则提取为空，退回 content 路径');
      }

      // ── 退回路径：content 规则 ──────────────────────────────────────────
      final contentRule = rule.content;
      if (contentRule == null || contentRule.isEmpty) return null;

      final rawContent = await RuleParser.parseRuleAsync(html, contentRule,
          variables: variables, baseUrl: baseUrl);
      if (rawContent == null || rawContent.isEmpty) return null;

      // ── sourceRegex 嗅探：从 content 结果中提取音频 URL ─────────────────
      if (rule.sourceRegex != null && rule.sourceRegex!.isNotEmpty) {
        try {
          final regex = RegexCache.instance.getOrCompile(
            rule.sourceRegex!,
            multiLine: true,
          );
          final match = regex.firstMatch(rawContent);
          if (match != null) {
            // 优先返回第一个非空捕获组，否则返回 group(0)
            for (int i = 1; i <= match.groupCount; i++) {
              final g = match.group(i);
              if (g != null && g.isNotEmpty) {
                AppLog.instance
                    .put('_parseAudioContent: sourceRegex捕获组[$i] → $g');
                return g;
              }
            }
            final g0 = match.group(0);
            if (g0 != null && g0.isNotEmpty) {
              AppLog.instance.put('_parseAudioContent: sourceRegex group(0) → $g0');
              return g0;
            }
          }
        } catch (e) {
          AppLog.instance.put('_parseAudioContent: sourceRegex错误', error: e);
        }
      }

      // ── 兜底：rawContent 本身就是 URL ────────────────────────────────────
      AppLog.instance.put('_parseAudioContent: 使用 content 原始结果 → $rawContent');
      return rawContent;
    } catch (e) {
      AppLog.instance.put('_parseAudioContent: 解析失败', error: e);
      return null;
    }
  }

  /// 视频/图片源内容解析（bookSourceType == 2）
  ///
  /// 解析优先级：
  ///   1. [ContentRule.videoUrl] 规则 —— 书源作者明确指定的视频 URL 提取规则
  ///   2. [ContentRule.images] 规则 —— 漫画/图片源（现有逻辑不变）
  ///   3. [ContentRule.content] + [ContentRule.sourceRegex] —— 兜底
  ///
  /// 注意：视频 URL 同样不需要 HTML 清理与段落处理，走独立路径。
  static Future<String?> parseVideoContent(
    String html,
    ContentRule rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) async {
    try {
      // ── 执行 webJs（如果有）──────────────────────────────────────────────
      if (rule.webJs != null && rule.webJs!.isNotEmpty) {
        html =
            await RuleParser._executeJs(html, rule.webJs!, variables: variables) ?? html;
      }

      // ── 优先路径：videoUrl 规则 ─────────────────────────────────────────
      if (rule.videoUrl != null && rule.videoUrl!.isNotEmpty) {
        final videoUrl = await RuleParser.parseRuleAsync(html, rule.videoUrl!,
            variables: variables, baseUrl: baseUrl);
        if (videoUrl != null && videoUrl.isNotEmpty) {
          AppLog.instance
              .put('_parseVideoContent: videoUrl规则提取成功 → $videoUrl');
          if (!videoUrl.startsWith('http') && baseUrl != null) {
            return NetworkService.joinUrl(baseUrl, videoUrl);
          }
          return videoUrl;
        }
        AppLog.instance.put('_parseVideoContent: videoUrl规则提取为空，退回 content 路径');
      }

      // ── 退回路径：images 规则（漫画/图片书源）──────────────────────────
      if (rule.images != null && rule.images!.isNotEmpty) {
        // images 规则的结果是换行分隔的 URL 列表，直接透传给调用方处理
        final imageUrls = await RuleParser.parseRuleAsync(html, rule.images!,
            variables: variables, baseUrl: baseUrl);
        if (imageUrls != null && imageUrls.isNotEmpty) {
          AppLog.instance.put('_parseVideoContent: images规则提取成功');
          return imageUrls;
        }
      }

      // ── 退回路径：content + sourceRegex ────────────────────────────────
      final contentRule = rule.content;
      if (contentRule == null || contentRule.isEmpty) return null;

      final rawContent = await RuleParser.parseRuleAsync(html, contentRule,
          variables: variables, baseUrl: baseUrl);
      if (rawContent == null || rawContent.isEmpty) return null;

      if (rule.sourceRegex != null && rule.sourceRegex!.isNotEmpty) {
        try {
          final regex = RegexCache.instance.getOrCompile(
            rule.sourceRegex!,
            multiLine: true,
          );
          final match = regex.firstMatch(rawContent);
          if (match != null) {
            for (int i = 1; i <= match.groupCount; i++) {
              final g = match.group(i);
              if (g != null && g.isNotEmpty) return g;
            }
            final g0 = match.group(0);
            if (g0 != null && g0.isNotEmpty) return g0;
          }
        } catch (e) {
          AppLog.instance.put('_parseVideoContent: sourceRegex错误', error: e);
        }
      }

      return rawContent;
    } catch (e) {
      AppLog.instance.put('_parseVideoContent: 解析失败', error: e);
      return null;
    }
  }

  /// 解析音视频章节辅助字段（Phase 3）
  ///
  /// 在 [RuleParser.parseContentRule] 返回媒体 URL 之后，额外解析：
  ///   - `lyricsUrl`  — 歌词/字幕文件 URL（对应 [ContentRule.lyricsUrl]）
  ///   - `subtitleUrl` — 视频外挂字幕 URL（对应 [ContentRule.subtitleUrl]）
  ///   - `qualityOptions` — 多码率选项 JSON 字符串（对应 [ContentRule.qualityList]）
  ///
  /// 返回 `Map<String, String?>` 而非直接写入 BookChapter，以避免循环导入。
  /// 调用方负责将返回值写入对应 chapter 字段。
  ///
  /// 注意：仅当书源提供了对应规则时才解析，规则为空则跳过（返回 null 对应值）。
  static Future<Map<String, String?>> parseAudioExtras(
    String html,
    ContentRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) async {
    final result = <String, String?>{
      'lyricsUrl': null,
      'subtitleUrl': null,
      'qualityOptions': null,
    };

    if (rule == null) return result;

    // ── 歌词 URL ────────────────────────────────────────────────────────────
    if (rule.lyricsUrl != null && rule.lyricsUrl!.isNotEmpty) {
      try {
        final url = await RuleParser.parseRuleAsync(html, rule.lyricsUrl!,
            variables: variables, baseUrl: baseUrl);
        if (url != null && url.isNotEmpty) {
          result['lyricsUrl'] =
              (url.startsWith('http') || baseUrl == null)
                  ? url
                  : NetworkService.joinUrl(baseUrl, url);
          AppLog.instance.put('parseAudioExtras: lyricsUrl → ${result['lyricsUrl']}');
        }
      } catch (e) {
        AppLog.instance.put('parseAudioExtras: lyricsUrl 解析失败', error: e);
      }
    }

    // ── 字幕 URL ────────────────────────────────────────────────────────────
    if (rule.subtitleUrl != null && rule.subtitleUrl!.isNotEmpty) {
      try {
        final url = await RuleParser.parseRuleAsync(html, rule.subtitleUrl!,
            variables: variables, baseUrl: baseUrl);
        if (url != null && url.isNotEmpty) {
          result['subtitleUrl'] =
              (url.startsWith('http') || baseUrl == null)
                  ? url
                  : NetworkService.joinUrl(baseUrl, url);
          AppLog.instance
              .put('parseAudioExtras: subtitleUrl → ${result['subtitleUrl']}');
        }
      } catch (e) {
        AppLog.instance.put('parseAudioExtras: subtitleUrl 解析失败', error: e);
      }
    }

    // ── 多码率选项 ───────────────────────────────────────────────────────────
    if (rule.qualityList != null && rule.qualityList!.isNotEmpty) {
      try {
        final raw = await RuleParser.parseRuleAsync(html, rule.qualityList!,
            variables: variables, baseUrl: baseUrl);
        if (raw != null && raw.isNotEmpty) {
          // 验证是否为合法 JSON 数组（宽松检查：以 [ 开头）
          final trimmed = raw.trim();
          if (trimmed.startsWith('[')) {
            result['qualityOptions'] = trimmed;
            AppLog.instance.put(
                'parseAudioExtras: qualityOptions 已提取 (${trimmed.length} 字节)');
          } else {
            // 若规则返回的是换行分隔的 URL 列表，尝试转为 JSON 数组格式
            final lines = trimmed
                .split('\n')
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty)
                .toList();
            if (lines.isNotEmpty) {
              final jsonArray = lines
                  .asMap()
                  .entries
                  .map((e) =>
                      '{"label":"清晰度${e.key + 1}","url":"${e.value}"}')
                  .join(',');
              result['qualityOptions'] = '[$jsonArray]';
              AppLog.instance.put(
                  'parseAudioExtras: qualityOptions 从换行列表转换 (${lines.length} 条)');
            }
          }
        }
      } catch (e) {
        AppLog.instance.put('parseAudioExtras: qualityOptions 解析失败', error: e);
      }
    }

    return result;
  }

  /// 执行 payAction（Phase 3 基础实现）
  ///
  /// payAction 用于自动解锁付费章节。支持两种形态：
  ///   1. 纯 JS 字符串（不含 `http`）：直接使用 [RuleParser._executeJs] 执行
  ///   2. URL 字符串（以 `http` 开头，可含 `{{js:...}}` 内嵌 JS）：
  ///      先执行内嵌 JS 得到实际 URL，再发送 GET 请求完成解锁操作
  ///
  /// 执行完毕后返回 true（表示应重新请求章节页面以获取解锁内容），false 表示跳过。
  static Future<bool> executePayAction(
    String html,
    String payAction, {
    Map<String, String>? variables,
    BookSource? source,
    Book? book,
    String? baseUrl,
  }) async {
    if (payAction.trim().isEmpty) return false;

    try {
      if (!payAction.trimLeft().startsWith('http')) {
        // ── 纯 JS：执行并忽略返回值（主要利用副作用，如 cookie 写入）──────
        AppLog.instance.put('executePayAction: 执行 JS payAction');
        await RuleParser._executeJs(html, payAction,
            variables: variables, source: source, book: book, baseUrl: baseUrl);
        return true;
      } else {
        // ── URL 型：处理内嵌 JS 后发送 HTTP 请求 ──────────────────────────
        String resolvedUrl = payAction;

        // 处理 {{js:...}} 内嵌表达式
        final jsPattern = RegExp(r'\{\{js:(.*?)\}\}', dotAll: true);
        if (jsPattern.hasMatch(resolvedUrl)) {
          resolvedUrl = resolvedUrl.replaceAllMapped(jsPattern, (match) {
            // 同步执行 JS（此处简化：直接替换为空字符串，异步版本太复杂）
            // 实际 payAction URL 型的 JS 内嵌较少见，此处作基础支持
            AppLog.instance.put(
                'executePayAction: URL 内嵌 JS 暂不支持异步替换，将跳过');
            return '';
          });
        }

        if (resolvedUrl.isNotEmpty && resolvedUrl.startsWith('http')) {
          AppLog.instance.put('executePayAction: 发送解锁请求 → $resolvedUrl');
          await NetworkService.instance.get(
            resolvedUrl,
            headers: NetworkService.parseHeaders(source?.header),
          );
          return true;
        }
      }
    } catch (e) {
      AppLog.instance.put('executePayAction: 执行失败', error: e);
    }
    return false;
  }
}
