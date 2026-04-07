part of 'rule_parser.dart';

/// 正则替换规则实现
///
/// 由 [RuleParser] 通过 `part` 机制引入，与主文件共享同一 Dart 库。
///
/// 职责范围：
/// - 解析 `##match##replace` / `sourceRegex@replaceRegex` 格式的替换规则
/// - 支持分组引用（`$1`、`$2`…）
/// - 替换全部匹配 / 替换第一个匹配（`###` 后缀）
class _RuleParserReplace {
  _RuleParserReplace._();

  /// 应用正则替换规则
  ///
  /// 支持格式：
  /// - `sourceRegex@replaceRegex`：替换所有匹配
  /// - `##match##replace`：替换所有匹配
  /// - `##match##replace###`：只替换第一个匹配
  ///
  /// 替换字符串中可使用 `$1`、`$2`…引用捕获组。
  static String apply(String content, String replaceRule) {
    if (replaceRule.isEmpty) return content;

    try {
      String sourceRegex;
      String replacement;
      bool replaceFirst = false;

      // ── 解析规则格式 ────────────────────────────────────────────────────
      if (replaceRule.contains('##')) {
        final parts = replaceRule.split('##');
        if (parts.length >= 3) {
          sourceRegex = parts[1];
          replacement = parts[2];
          // 如果有第四个部分（###），表示只替换第一个
          if (parts.length > 3 && parts[3].isNotEmpty) {
            replaceFirst = true;
          }
        } else {
          // 格式错误，返回原内容
          return content;
        }
      } else if (replaceRule.contains('@')) {
        // 旧格式：sourceRegex@replaceRegex
        final parts = replaceRule.split('@');
        if (parts.length != 2) return content;
        sourceRegex = parts[0];
        replacement = parts[1];
      } else {
        // 格式错误，返回原内容
        return content;
      }

      // ── 编译正则（使用缓存）─────────────────────────────────────────────
      RegExp pattern;
      try {
        pattern = RegexCache.instance.getOrCompile(sourceRegex, multiLine: true);
      } catch (e) {
        AppLog.instance
            .put('_RuleParserReplace.apply: 正则表达式错误: $sourceRegex, 错误: $e');
        return content;
      }

      // ── 执行替换 ────────────────────────────────────────────────────────
      if (replaceFirst) {
        // 只替换第一个匹配
        final match = pattern.firstMatch(content);
        if (match != null) {
          final matchedText = match.group(0)!;
          final processedReplacement = _processReplacementGroups(replacement, match);
          final replaced = matchedText.replaceFirst(pattern, processedReplacement);
          return content.replaceFirst(matchedText, replaced);
        }
        return content;
      } else {
        // 替换所有匹配
        return content.replaceAllMapped(pattern, (match) {
          if (match is RegExpMatch) {
            return _processReplacementGroups(replacement, match);
          }
          return replacement;
        });
      }
    } catch (e) {
      AppLog.instance.put('_RuleParserReplace.apply: 替换失败: $e');
      return content;
    }
  }

  /// 处理替换字符串中的分组引用（`$1`、`$2`…）
  static String _processReplacementGroups(String replacement, RegExpMatch match) {
    String result = replacement;
    final groupPattern = RegExp(r'\$(\d{1,2})');
    return result.replaceAllMapped(groupPattern, (m) {
      final groupIndex = int.tryParse(m.group(1) ?? '0') ?? 0;
      if (groupIndex > 0 && groupIndex <= match.groupCount) {
        return match.group(groupIndex) ?? '';
      }
      return m.group(0) ?? '';
    });
  }
}
