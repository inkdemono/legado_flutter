import 'dart:convert';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:json_path/json_path.dart';
import 'html_parser.dart';
import '../../data/models/book_source_rule.dart';
import '../../data/models/replace_rule.dart';
import '../../data/models/book_source.dart';
import '../../data/models/book.dart';
import '../../services/network/network_service.dart';
import '../../services/replace_rule_service.dart';
import '../app_log.dart';
import 'rule_analyzer.dart';
import '../js_engine.dart';
import '../js_extensions.dart';
import 'elements_single.dart';
import 'analyze_by_regex.dart';
import 'regex_cache.dart';

// ── 拆分出去的实现模块（part 文件共享同一 Dart 库，可访问库级私有符号）──────────
part 'rule_parser_media.dart';   // 音视频解析：_RuleParserMedia
part 'rule_parser_replace.dart'; // 正则替换：  _RuleParserReplace
part 'rule_parser_toc.dart';     // 目录解析：  _RuleParserToc

/// 规则片段类型
enum _RuleFragmentType {
  normal, // 普通规则（CSS/XPath/JSONPath）
  javascript, // JavaScript 代码
}

/// 规则片段
class _RuleFragment {
  final _RuleFragmentType type;
  final String content;

  _RuleFragment({
    required this.type,
    required this.content,
  });
}

class _ListRuleEntry {
  final String content;
  final Map<String, String> groups;

  const _ListRuleEntry({
    required this.content,
    this.groups = const {},
  });
}

class _PreparedFieldRule {
  final String rule;
  final String? replaceRule;
  final List<MapEntry<String, String>> putAssignments;

  const _PreparedFieldRule({
    required this.rule,
    this.replaceRule,
    this.putAssignments = const [],
  });
}

/// 规则解析器
/// 参考项目：io.legado.app.model.analyzeRule.AnalyzeRule
///
/// 主要差异说明：
/// 1. JavaScript 引擎：参考项目使用 Rhino（Java），当前项目使用 flutter_js（QuickJS）
///    - 参考项目可以直接调用 Java 类和方法，当前项目需要通过桥接函数
///    - 部分同步函数在参考项目中是同步的，但当前项目实现为异步（返回 Promise）
///
/// 2. HTML 解析库：参考项目使用 JSoup（Java），当前项目使用 html + xpath_selector（Dart）
///    - CSS 选择器功能基本一致，但某些高级特性可能不同
///    - XPath 实现基于 xpath_selector，与 JXPath 的行为可能略有差异
///
/// 3. 卷名处理：已完善，支持 isVolume 规则解析
///
/// 4. URL 处理：使用 NetworkService.joinUrl，逻辑与参考项目基本一致
///
/// 5. 规则组合：支持 &&、||、%% 组合，实现逻辑与参考项目一致
class RuleParser {
  // 变量存储（用于@get:和@put:）
  static final Map<String, String> _variables = {};

  // 规则片段缓存（缓存解析后的规则片段）
  static final Map<String, List<_RuleFragment>> _ruleFragmentCache = {};
  static const int _maxRuleFragmentCacheSize = 200;

  /// 清除规则片段缓存
  static void clearRuleFragmentCache() {
    _ruleFragmentCache.clear();
  }

  /// 处理规则（变量替换、put规则、正则替换等）
  /// 参考项目：AnalyzeRule.splitSourceRule 和 SourceRule.makeUpRule
  static String _processRule(
    String rule,
    Map<String, String> variables, {
    bool processPutGet = true,
  }) {
    String result = rule;

    if (processPutGet) {
      // 1. 处理 @put:{key:value} 规则
      final putPattern = RegexCache.instance.getOrCompile(
        r'@put:\s*(\{[^}]+\})',
        caseSensitive: false,
      );
      result = result.replaceAllMapped(putPattern, (match) {
        try {
          // 解析JSON对象
          final jsonStr = match.group(1)!;
          // 简单的JSON解析（只支持简单的key:value格式）
          final keyValuePattern = RegexCache.instance.getOrCompile(
            r'"([^"]+)":\s*"([^"]*)"',
          );
          keyValuePattern.allMatches(jsonStr).forEach((m) {
            final key = m.group(1)!;
            final value = m.group(2) ?? '';
            _variables[key] = value;
            variables[key] = value;
          });
        } catch (e) {
          AppLog.instance.put('_processRule: 解析@put规则失败: $e');
        }
        return ''; // 移除@put规则
      });
    }

    // 2. 处理变量替换 {{key}} 和 @{{key}}
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
      result = result.replaceAll('@{{$key}}', value);
    });

    if (processPutGet) {
      // 3. 处理 @get:{key} 规则
      final getPattern = RegexCache.instance.getOrCompile(
        r'@get:\s*\{([^}]+)\}',
        caseSensitive: false,
      );
      result = result.replaceAllMapped(getPattern, (match) {
        final key = match.group(1)!.trim();
        return variables[key] ?? _variables[key] ?? '';
      });
    }

    // 4. 处理 {{js}} JavaScript代码
    // 注意：{{js}} 的处理在 SourceRule.makeUpRule 中实现

    // 5. 处理正则替换 ##match##replace 或 ##match##replace###
    // 这部分在解析后处理，这里只提取规则部分

    return result;
  }

  /// 处理变量替换（向后兼容）
  static String _replaceVariables(String rule, Map<String, String>? variables) {
    if (variables == null || variables.isEmpty) return rule;

    String result = rule;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
      result = result.replaceAll('@{{$key}}', value);
    });
    return result;
  }

  static String _replaceTemplateVariables(
    String rule,
    Map<String, String>? variables,
  ) {
    return _replaceVariables(rule, variables);
  }

  static String? _encodeTransientVariables(
    Map<String, String> originalVariables,
    Map<String, String> currentVariables,
  ) {
    final diff = <String, String>{};
    for (final entry in currentVariables.entries) {
      if (originalVariables[entry.key] != entry.value) {
        diff[entry.key] = entry.value;
      }
    }
    if (diff.isEmpty) return null;
    return jsonEncode(diff);
  }

  /// 解析规则并提取内容（同步版本，不支持JavaScript执行）
  /// [isUrl] 如果为true，表示解析的是URL，需要特殊处理（参考 AnalyzeRule.getString with isUrl=true）
  /// 支持规则组合（&&/||）和变量替换
  /// 注意：如果规则包含{{js}}代码，请使用parseRuleAsync
  static String? parseRule(
    String html,
    String? rule, {
    String? baseUrl,
    Map<String, String>? variables,
    bool isUrl = false,
    bool allowRegexRule = false,
  }) {
    if (rule == null || rule.isEmpty) {
      // 如果是URL且为空，返回baseUrl（参考项目逻辑）
      if (isUrl && baseUrl != null) {
        return baseUrl;
      }
      return null;
    }

    // 检查是否包含JavaScript代码
    if (rule.contains('{{') && rule.contains('}}')) {
      AppLog.instance.put('parseRule: 警告 - 规则包含{{js}}代码，请使用parseRuleAsync');
      // 同步版本不支持JS执行，跳过JS部分
    }

    try {
      // 合并外部变量和内部变量
      final allVariables = <String, String>{..._variables};
      if (variables != null) {
        allVariables.addAll(variables);
      }

      // 处理变量替换和put规则
      String processedRule = _processRule(rule, allVariables);

      // 判断是否包含规则组合（&&/||）
      final analyzer = RuleAnalyzer(processedRule);
      final splitRules = analyzer.splitRule(['&&', '||', '%%']);
      final elementsType = analyzer.elementsType;

      if (splitRules.length > 1) {
        // 有规则组合，需要分别解析每个规则
        return _parseRuleCombinationSync(
            html, splitRules, elementsType, baseUrl, allVariables,
            allowRegexRule: allowRegexRule,
            isUrl: isUrl);
      } else {
        // 单个规则，直接解析
        return _parseSingleRuleSync(html, processedRule, baseUrl, allVariables,
            allowRegexRule: allowRegexRule,
            isUrl: isUrl);
      }
    } catch (e, stackTrace) {
      AppLog.instance.put('parseRule: 解析失败', error: e);
      AppLog.instance.put('parseRule: 错误堆栈: $stackTrace');
      // 如果是URL且解析失败，返回baseUrl
      if (isUrl && baseUrl != null) {
        return baseUrl;
      }
      return null;
    }
  }

  /// 解析规则并提取内容（异步版本，支持JavaScript执行）
  /// [isUrl] 如果为true，表示解析的是URL，需要特殊处理（参考 AnalyzeRule.getString with isUrl=true）
  /// 支持规则组合（&&/||）、变量替换和JavaScript执行
  static Future<String?> parseRuleAsync(
    String html,
    String? rule, {
    String? baseUrl,
    Map<String, String>? variables,
    bool isUrl = false,
    bool allowRegexRule = false,
  }) async {
    return _parseRuleAsync(html, rule,
        baseUrl: baseUrl,
        variables: variables,
        isUrl: isUrl,
        allowRegexRule: allowRegexRule);
  }

  /// 异步解析规则（内部方法，支持JavaScript执行）
  static Future<String?> _parseRuleAsync(
    String html,
    String? rule, {
    String? baseUrl,
    Map<String, String>? variables,
    bool isUrl = false,
    bool allowRegexRule = false,
  }) async {
    if (rule == null || rule.isEmpty) {
      // 如果是URL且为空，返回baseUrl（参考项目逻辑）
      if (isUrl && baseUrl != null) {
        return baseUrl;
      }
      return null;
    }

    try {
      // 合并外部变量和内部变量
      final allVariables = <String, String>{..._variables};
      if (variables != null) {
        allVariables.addAll(variables);
      }

      // 处理变量替换和put规则
      String processedRule = _replaceTemplateVariables(rule, allVariables);

      // 判断是否包含规则组合（&&/||）
      final analyzer = RuleAnalyzer(processedRule);
      final splitRules = analyzer.splitRule(['&&', '||', '%%']);
      final elementsType = analyzer.elementsType;

      if (splitRules.length > 1) {
        // 有规则组合，需要分别解析每个规则
        return await _parseRuleCombination(
            html, splitRules, elementsType, baseUrl, allVariables,
            allowRegexRule: allowRegexRule,
            isUrl: isUrl);
      } else {
        // 单个规则，直接解析
        return await _parseSingleRule(
            html, processedRule, baseUrl, allVariables,
            allowRegexRule: allowRegexRule,
            isUrl: isUrl);
      }
    } catch (e, stackTrace) {
      AppLog.instance.put('_parseRuleAsync: 解析失败', error: e);
      AppLog.instance.put('_parseRuleAsync: 错误堆栈: $stackTrace');
      // 如果是URL且解析失败，返回baseUrl
      if (isUrl && baseUrl != null) {
        return baseUrl;
      }
      return null;
    }
  }

  /// 解析单个规则（同步版本，不包含组合，不支持JavaScript执行）
  static String? _parseSingleRuleSync(
    String html,
    String rule,
    String? baseUrl,
    Map<String, String> variables, {
    bool isUrl = false,
    bool allowRegexRule = false,
  }) {
    // 检查是否包含正则替换规则
    String? replaceRule;
    String actualRule = rule;

    if (rule.contains('##')) {
      final parts = rule.split('##');
      if (parts.length >= 3) {
        // 提取实际规则和替换规则
        actualRule = parts[0];
        replaceRule = rule.substring(parts[0].length); // 保留 ##match##replace 部分
      }
    }

    String? result;

    // 判断是 XPath 还是 CSS 选择器
    // 参考项目：SourceRule 构造函数中的模式识别逻辑
    String processedRule = actualRule;

    // 处理 Regex 模式（以 : 开头，但注意与伪类选择器冲突）
    // 参考项目：if (allInOne && ruleStr.startsWith(":")) { mMode = Mode.Regex }
    if (allowRegexRule && actualRule.startsWith(':') && actualRule.length > 1) {
      final afterColon = actualRule.substring(1).trim();
      final isPseudoClass = RegExp(r'^[a-zA-Z-]').hasMatch(afterColon);

      if (!isPseudoClass) {
        // Regex 模式：移除开头的 :，然后按 && 分割正则表达式
        processedRule = afterColon;
        final regexList = processedRule
            .split('&&')
            .map((r) => r.trim())
            .where((r) => r.isNotEmpty)
            .toList();
        if (regexList.isNotEmpty) {
          final regexResult = AnalyzeByRegex.getElement(html, regexList);
          if (regexResult != null && regexResult.isNotEmpty) {
            // 返回第一个分组（$0），如果有多个分组，用换行符连接
            result = regexResult.join('\n');
          }
        }
      } else {
        // 伪类选择器，按CSS处理
        result = _parseCss(html, actualRule, baseUrl, isUrl: isUrl);
      }
    }
    // 处理 @CSS: 前缀（强制使用CSS选择器）
    else if (actualRule.startsWith('@CSS:') || actualRule.startsWith('@css:')) {
      processedRule = actualRule.substring(5).trim();
      // 强制使用CSS选择器，即使规则看起来像XPath或JSONPath
      result = _parseCss(html, processedRule, baseUrl, isUrl: isUrl);
    }
    // 处理 @@ 前缀（转义，使用Default模式）
    else if (actualRule.startsWith('@@')) {
      processedRule = actualRule.substring(2);
      // 强制使用CSS选择器（Default模式）
      result = _parseCss(html, processedRule, baseUrl, isUrl: isUrl);
    }
    // 处理 @XPath: 前缀
    else if (actualRule.startsWith('@XPath:') ||
        actualRule.startsWith('@xpath:')) {
      processedRule = actualRule.substring(7).trim();
      result = _parseXPath(html, processedRule, baseUrl, isUrl: isUrl);
    }
    // 处理 @Json: 前缀
    else if (actualRule.startsWith('@Json:') ||
        actualRule.startsWith('@json:')) {
      processedRule = actualRule.substring(6).trim();
      result = _parseJsonPath(html, processedRule, baseUrl, isUrl: isUrl);
    }
    // 判断规则类型
    else if (processedRule.startsWith('//') || processedRule.startsWith('/')) {
      // XPath模式
      result = _parseXPath(html, processedRule, baseUrl, isUrl: isUrl);
    } else if (processedRule.startsWith('\$.') ||
        processedRule.startsWith('\$[')) {
      // JSONPath模式
      result = _parseJsonPath(html, processedRule, baseUrl, isUrl: isUrl);
    } else {
      // CSS选择器模式（默认）
      result = _parseCss(html, processedRule, baseUrl, isUrl: isUrl);
    }

    // 如果结果为空且是URL，返回baseUrl
    if (isUrl && (result == null || result.isEmpty) && baseUrl != null) {
      result = baseUrl;
    }

    // 应用正则替换规则
    if (result != null && replaceRule != null && replaceRule.isNotEmpty) {
      result = _applyReplaceRegexInternal(result, replaceRule);
    }

    return result;
  }

  /// 解析单个规则（异步版本，不包含组合，支持JavaScript执行）
  /// 参考项目：AnalyzeRule.getString
  /// 支持正则替换：##match##replace 或 ##match##replace###
  /// 支持JavaScript执行：{{js代码}} 或 <js>代码</js> 或 @js:代码
  /// 关键：按 {{js}} 分割规则，顺序执行每个片段，每个片段的结果作为下一个片段的输入
  static Future<String?> _parseSingleRule(
    String html,
    String rule,
    String? baseUrl,
    Map<String, String> variables, {
    bool isUrl = false,
    bool allowRegexRule = false,
  }) async {
    // 分离正则替换规则（##match##replace）
    String? replaceRule;
    String actualRule = rule;

    if (rule.contains('##')) {
      final parts = rule.split('##');
      if (parts.length >= 3) {
        actualRule = parts[0];
        replaceRule = rule.substring(parts[0].length); // 保留 ##match##replace 部分
      }
    }

    // 检查是否包含明确的 JavaScript 标记（<js>...</js> 或 @js:...）
    // 注意：{{...}} 格式需要更谨慎处理，因为变量替换也使用这个格式
    // 只有在规则中明确包含 <js> 或 @js: 时才进行分割处理
    final hasExplicitJs = actualRule.contains('<js>') ||
        actualRule.contains('</js>') ||
        actualRule.toLowerCase().contains('@js:');

    // 如果没有明确的 JavaScript 标记，直接按普通规则处理
    if (!hasExplicitJs) {
      // 检查是否包含 {{...}} 格式（可能是变量替换或 JavaScript）
      // 如果包含 {{...}}，先尝试作为变量替换处理，如果变量不存在，再作为 JavaScript
      if (actualRule.contains('{{') && actualRule.contains('}}')) {
        // 先尝试变量替换
        String processedRule = actualRule;
        bool hasJsCode = false;

        // 检查 {{...}} 是否是变量替换
        final varPattern = RegexCache.instance.getOrCompile(r'\{\{([^}]+)\}\}');
        for (final match in varPattern.allMatches(actualRule)) {
          final key = match.group(1)?.trim();
          if (key != null && variables.containsKey(key)) {
            // 是变量替换
            processedRule =
                processedRule.replaceAll(match.group(0)!, variables[key]!);
          } else {
            // 不是变量替换，可能是 JavaScript 代码
            hasJsCode = true;
            break;
          }
        }

        if (!hasJsCode) {
          // 所有 {{...}} 都是变量替换，使用处理后的规则
          actualRule = processedRule;
        }
        // 如果有 JavaScript 代码，继续下面的分割处理
      } else {
        // 没有 {{...}}，直接按普通规则处理
        final processedNonJsRule = _processRule(actualRule, variables);
        final putGetLiteral = _resolvePutGetLiteral(
          actualRule,
          processedNonJsRule,
          baseUrl: baseUrl,
          isUrl: isUrl,
        );
        if (putGetLiteral != null) {
          return putGetLiteral;
        }
        return _parseSingleRuleSync(
          html,
          processedNonJsRule,
          baseUrl,
          variables,
          allowRegexRule: allowRegexRule,
          isUrl: isUrl,
        );
      }
    }

    // 有明确的 JavaScript 标记或包含 {{...}} 且不是变量替换，进行分割处理
    // 匹配 <js>...</js> 或 @js:... 或 {{...}}（但排除变量替换）
    final jsPattern = RegexCache.instance.getOrCompile(
      r'<js>([\w\W]*?)</js>|@js:([\w\W]*)|(?<!\\)\{\{([\w\W]*?)\}\}',
      caseSensitive: false,
    );

    // 检查是否可以使用缓存（规则不包含{{...}}变量引用时可以缓存）
    final canUseCache = !actualRule.contains('{{');
    List<_RuleFragment> ruleFragments;

    if (canUseCache && _ruleFragmentCache.containsKey(actualRule)) {
      ruleFragments = _ruleFragmentCache[actualRule]!;
    } else {
      // 分割规则片段
      ruleFragments = <_RuleFragment>[];
      int lastEnd = 0;

      for (final match in jsPattern.allMatches(actualRule)) {
        // 添加 JavaScript 之前的普通规则片段
        if (match.start > lastEnd) {
          final normalRule = actualRule.substring(lastEnd, match.start).trim();
          if (normalRule.isNotEmpty) {
            ruleFragments.add(_RuleFragment(
              type: _RuleFragmentType.normal,
              content: normalRule,
            ));
          }
        }

        // 提取 JavaScript 代码
        String? jsCode;
        if (match.group(1) != null) {
          // <js>...</js> 格式
          jsCode = match.group(1);
        } else if (match.group(2) != null) {
          // @js:... 格式
          jsCode = match.group(2);
        } else if (match.group(3) != null) {
          // {{...}} 格式，检查是否是变量替换
          final key = match.group(3)?.trim();
          if (key != null && variables.containsKey(key)) {
            // 是变量替换，作为普通文本处理
            ruleFragments.add(_RuleFragment(
              type: _RuleFragmentType.normal,
              content: variables[key]!,
            ));
            lastEnd = match.end;
            continue;
          } else {
            // 不是变量替换，作为 JavaScript 代码
            jsCode = match.group(3);
          }
        }

        if (jsCode != null && jsCode.isNotEmpty) {
          if (match.group(2) != null) {
            jsCode = _processRule(
              _replaceTemplateVariables(jsCode, variables),
              variables,
            );
          }
          ruleFragments.add(_RuleFragment(
            type: _RuleFragmentType.javascript,
            content: jsCode,
          ));
        }

        lastEnd = match.end;
      }

      // 添加最后一个普通规则片段
      if (lastEnd < actualRule.length) {
        final normalRule = actualRule.substring(lastEnd).trim();
        if (normalRule.isNotEmpty) {
          ruleFragments.add(_RuleFragment(
            type: _RuleFragmentType.normal,
            content: normalRule,
          ));
        }
      }

      // 缓存结果（仅当规则不包含变量引用时）
      if (canUseCache) {
        if (_ruleFragmentCache.length >= _maxRuleFragmentCacheSize) {
          _ruleFragmentCache.remove(_ruleFragmentCache.keys.first);
        }
        _ruleFragmentCache[actualRule] = List.from(ruleFragments);
      }
    }

    // 如果没有找到任何片段，整个规则作为普通规则
    if (ruleFragments.isEmpty) {
        return _parseSingleRuleSync(
          html,
          _processRule(actualRule, variables),
          baseUrl,
          variables,
          allowRegexRule: allowRegexRule,
          isUrl: isUrl,
        );
    }

    // 参考项目：顺序执行每个规则片段，每个片段的结果作为下一个片段的输入
    dynamic result = html;

    // 检查整个规则是否包含JavaScript代码（用于决定是否在CSS解析时自动拼接URL）
    final hasJsInRule =
        ruleFragments.any((f) => f.type == _RuleFragmentType.javascript);

    for (final fragment in ruleFragments) {
      if (result == null) break;

      try {
        if (fragment.type == _RuleFragmentType.javascript) {
          // 执行 JavaScript 代码
          // 参考项目：evalJS(jsCode, result)
          final jsResult = await _executeJs(
            result.toString(),
            fragment.content,
            baseUrl: baseUrl,
            variables: variables,
          );
          if (jsResult != null) {
            result = jsResult;
          } else {
            result = result.toString();
          }
        } else {
          // 解析普通规则（CSS/XPath/JSONPath）
          final ruleStr = fragment.content;
          if (ruleStr.isEmpty) {
            continue;
          }

          final processedFragmentRule = _processRule(
            ruleStr,
            variables,
          );
          if (processedFragmentRule.isEmpty) {
            continue;
          }

          // 判断规则类型
          // 参考项目：SourceRule 构造函数中的模式识别逻辑
          String actualRuleStr = processedFragmentRule;
          bool forceCss = false;

          // 处理 Regex 模式（以 : 开头）
          if (allowRegexRule &&
              actualRuleStr.startsWith(':') &&
              actualRuleStr.length > 1) {
            final afterColon = actualRuleStr.substring(1).trim();
            final isPseudoClass = RegExp(r'^[a-zA-Z-]').hasMatch(afterColon);

            if (!isPseudoClass) {
              // Regex 模式
              actualRuleStr = afterColon;
              final regexList = actualRuleStr
                  .split('&&')
                  .map((r) => r.trim())
                  .where((r) => r.isNotEmpty)
                  .toList();
              if (regexList.isNotEmpty) {
                final regexResult =
                    AnalyzeByRegex.getElement(result.toString(), regexList);
                if (regexResult != null && regexResult.isNotEmpty) {
                  result = regexResult.join('\n');
                } else {
                  result = null;
                }
              }
              if (result == null || (result is String && result.isEmpty)) {
                continue;
              }
              continue;
            }
          }
          // 处理 @CSS: 前缀（强制使用CSS选择器）
          else if (actualRuleStr.startsWith('@CSS:') ||
              actualRuleStr.startsWith('@css:')) {
            actualRuleStr = actualRuleStr.substring(5).trim();
            forceCss = true;
          }
          // 处理 @@ 前缀（转义，使用Default模式）
          else if (actualRuleStr.startsWith('@@')) {
            actualRuleStr = actualRuleStr.substring(2);
            forceCss = true;
          }
          // 处理 @XPath: 前缀
          else if (actualRuleStr.startsWith('@XPath:') ||
              actualRuleStr.startsWith('@xpath:')) {
            actualRuleStr = actualRuleStr.substring(7).trim();
            result = _parseXPath(result.toString(), actualRuleStr, baseUrl,
                isUrl: isUrl);
            if (result == null || (result is String && result.isEmpty)) {
              continue;
            }
            continue;
          }
          // 处理 @Json: 前缀
          else if (actualRuleStr.startsWith('@Json:') ||
              actualRuleStr.startsWith('@json:')) {
            actualRuleStr = actualRuleStr.substring(6).trim();
            result = _parseJsonPath(result.toString(), actualRuleStr, baseUrl,
                isUrl: isUrl);
            if (result == null || (result is String && result.isEmpty)) {
              continue;
            }
            continue;
          }

          // 根据规则类型选择解析方法
          if (forceCss ||
              actualRuleStr.startsWith('//') == false &&
                  actualRuleStr.startsWith('/') == false) {
            // CSS 选择器或强制CSS模式
            if (actualRuleStr.startsWith('\$.') ||
                actualRuleStr.startsWith('\$[')) {
              // JSONPath（以$.或$[开头）
              result = _parseJsonPath(result.toString(), actualRuleStr, baseUrl,
                  isUrl: isUrl);
            } else {
              // CSS 选择器
              // 如果规则包含JavaScript代码，不应该在 _parseCss 中自动拼接URL
              // 因为JavaScript代码会处理URL拼接
              final shouldAutoJoinUrl = isUrl && !hasJsInRule;
              result = _parseCss(result.toString(), actualRuleStr, baseUrl,
                  isUrl: shouldAutoJoinUrl);
            }
          } else {
            // XPath（以//或/开头）
            result = _parseXPath(result.toString(), actualRuleStr, baseUrl,
                isUrl: isUrl);
          }

          if (result == null || (result is String && result.isEmpty)) {
            // 如果结果为空，继续处理下一个片段（参考项目逻辑）
            continue;
          }
        }
      } catch (e) {
        AppLog.instance
            .put('_parseSingleRule: 规则片段执行失败: ${fragment.content}', error: e);
        // 继续处理下一个片段
        continue;
      }
    }

    // 如果结果为空且是URL，返回baseUrl
    if (isUrl &&
        (result == null || (result is String && result.isEmpty)) &&
        baseUrl != null) {
      result = baseUrl;
    }

    // 应用正则替换规则
    if (result != null && replaceRule != null && replaceRule.isNotEmpty) {
      result = _applyReplaceRegexInternal(result.toString(), replaceRule);
    }

    final resultStr = result?.toString();
    return resultStr;
  }

  /// 解析规则组合（同步版本）
  static String? _parseRuleCombinationSync(
    String html,
    List<String> rules,
    String elementsType,
    String? baseUrl,
    Map<String, String> variables, {
    bool isUrl = false,
    bool allowRegexRule = false,
  }) {
    final results = <String>[];

    for (final rule in rules) {
      final result = _parseSingleRuleSync(html, rule.trim(), baseUrl, variables,
          allowRegexRule: allowRegexRule,
          isUrl: isUrl);
      if (result != null && result.isNotEmpty) {
        results.add(result);
        // 如果是 || 组合，找到第一个非空结果就返回
        if (elementsType == '||') {
          return result;
        }
      }
    }

    if (results.isEmpty) {
      return null;
    }

    // && 组合：返回所有结果的连接
    if (elementsType == '&&') {
      return results.join('\n');
    }

    // %% 组合：按索引交叉组合（参考项目逻辑）
    if (elementsType == '%%') {
      final maxLength = results
          .map((r) => r.split('\n').length)
          .reduce((a, b) => a > b ? a : b);
      final combined = <String>[];
      for (int i = 0; i < maxLength; i++) {
        for (final result in results) {
          final lines = result.split('\n');
          if (i < lines.length) {
            combined.add(lines[i]);
          }
        }
      }
      return combined.join('\n');
    }

    // 默认：返回所有结果的连接
    return results.join('\n');
  }

  /// 解析规则组合（异步版本，&&/||/%%）
  static Future<String?> _parseRuleCombination(
    String html,
    List<String> rules,
    String elementsType,
    String? baseUrl,
    Map<String, String> variables, {
    bool isUrl = false,
    bool allowRegexRule = false,
  }) async {
    final results = <String>[];

    for (final rule in rules) {
      final result = await _parseSingleRule(
          html, rule.trim(), baseUrl, variables,
          allowRegexRule: allowRegexRule,
          isUrl: isUrl);
      if (result != null && result.isNotEmpty) {
        results.add(result);
        // 如果是 || 组合，找到第一个非空结果就返回
        if (elementsType == '||') {
          return result;
        }
      }
    }

    if (results.isEmpty) {
      return null;
    }

    // && 组合：返回所有结果的连接
    if (elementsType == '&&') {
      return results.join('\n');
    }

    // %% 组合：按索引交叉组合（参考项目逻辑）
    if (elementsType == '%%') {
      final maxLength = results
          .map((r) => r.split('\n').length)
          .reduce((a, b) => a > b ? a : b);
      final combined = <String>[];
      for (int i = 0; i < maxLength; i++) {
        for (final result in results) {
          final lines = result.split('\n');
          if (i < lines.length) {
            combined.add(lines[i]);
          }
        }
      }
      return combined.join('\n');
    }

    // 默认：返回所有结果的连接
    return results.join('\n');
  }

  /// 解析 CSS 选择器规则（参考 AnalyzeByJSoup）
  static String? _parseCss(String html, String selector, String? baseUrl,
      {bool isUrl = false}) {
    final document = html_parser.parse(html);

    // 规范化CSS选择器（处理JSoup格式）
    selector = _normalizeCssSelector(selector);

    // 检查是否包含 @ 分隔符（例如：img@src, a@href, class.title@text, id.pic@img@src）
    // 支持嵌套选择器：id.pic@img@src -> 先选择id.pic，再选择img，最后获取src属性
    final allAtIndices = <int>[];
    for (int i = 0; i < selector.length; i++) {
      if (selector[i] == '@') {
        allAtIndices.add(i);
      }
    }

    if (allAtIndices.isNotEmpty) {
      // 如果有多个@，最后一个@后面的部分是属性名，前面的是选择器链
      // 例如：id.pic@img@src -> elementSelectorChain=["id.pic", "img"], attributeName="src"
      final lastAtIndex = allAtIndices.last;
      final elementSelectorChain = selector.substring(0, lastAtIndex).trim();
      final attributeName = selector.substring(lastAtIndex + 1).trim();

      if (elementSelectorChain.isNotEmpty && attributeName.isNotEmpty) {
        // 检查是否包含多个@，即嵌套选择器（如 id.pic@img@src）
        html_dom.Element? element;
        if (allAtIndices.length > 1) {
          // 嵌套选择器：先选择第一个元素，再在该元素内选择第二个元素
          // 例如：id.pic@img -> 先选择#pic，再在#pic内选择img
          final selectorParts = elementSelectorChain.split('@');
          if (selectorParts.length >= 2) {
            // 第一步：选择根元素（如 id.pic -> #pic）
            final rootSelector = selectorParts[0].trim();
            String normalizedRootSelector;
            if (rootSelector.startsWith('class.')) {
              normalizedRootSelector = '.${rootSelector.substring(6)}';
            } else if (rootSelector.startsWith('id.')) {
              normalizedRootSelector = '#${rootSelector.substring(3)}';
            } else {
              normalizedRootSelector = rootSelector;
            }

            element =
                HtmlParser.selectElement(document, normalizedRootSelector);

            if (element != null) {
              // 第二步：在根元素内选择子元素（如 img）
              for (int i = 1; i < selectorParts.length; i++) {
                final childSelector = selectorParts[i].trim();
                if (childSelector.isNotEmpty && element != null) {
                  final childElement =
                      HtmlParser.selectElement(element, childSelector);
                  if (childElement != null) {
                    element = childElement;
                  } else {
                    element = null;
                    break;
                  }
                }
              }
            }
          }
        } else {
          // 单个选择器（如 img@src, id.pic@text）
          // 检查是否包含特殊前缀（tag., class., id., children., text.）
          final hasSpecialPrefix = elementSelectorChain.startsWith('tag.') ||
              elementSelectorChain.startsWith('class.') ||
              elementSelectorChain.startsWith('id.') ||
              elementSelectorChain.startsWith('children.') ||
              elementSelectorChain.startsWith('text.');

          if (hasSpecialPrefix) {
            // 对于 class.xxx 和 id.xxx，优先使用 CSS 选择器（更可靠）
            // 对于 tag.xxx 和 children.xxx，使用 ElementsSingle
            final useCssSelector = elementSelectorChain.startsWith('class.') ||
                elementSelectorChain.startsWith('id.');

            if (useCssSelector) {
              // 手动规范化 class.xxx 和 id.xxx
              String normalizedSelector;
              if (elementSelectorChain.startsWith('class.')) {
                normalizedSelector = '.${elementSelectorChain.substring(6)}';
              } else if (elementSelectorChain.startsWith('id.')) {
                normalizedSelector = '#${elementSelectorChain.substring(3)}';
              } else {
                normalizedSelector = elementSelectorChain;
              }
              element = HtmlParser.selectElement(document, normalizedSelector);
            } else {
              // 使用 ElementsSingle 处理 tag.xxx 和 children.xxx
              try {
                // 对于HTML片段，应该使用body或documentElement作为根元素
                // 但是如果documentElement是html标签，应该使用body或第一个子元素
                html_dom.Element? searchRoot;
                if (document.body != null) {
                  searchRoot = document.body;
                } else if (document.documentElement != null) {
                  // 如果documentElement是html标签，尝试使用第一个子元素或整个documentElement
                  final docElement = document.documentElement!;
                  if (docElement.children.isNotEmpty) {
                    // 对于HTML片段，第一个子元素通常是实际的根元素
                    searchRoot = docElement.children.first;
                  } else {
                    searchRoot = docElement;
                  }
                } else {
                  searchRoot = null;
                }

                if (searchRoot != null) {
                  final elements = ElementsSingle.getElementsSingle(
                      searchRoot, elementSelectorChain);
                  if (elements.isNotEmpty) {
                    element = elements[0];
                  } else {
                    // 回退到普通CSS选择器：将 tag.a.0 转换为 a（移除tag.前缀和索引）
                    // tag.a.0 -> a.0 -> a（移除所有数字后缀）
                    var fallbackSelector =
                        elementSelectorChain.replaceFirst('tag.', '');
                    // 移除索引后缀（如 .0, .1, .-1 等）
                    fallbackSelector =
                        fallbackSelector.replaceAll(RegExp(r'\.-?\d+$'), '');
                    element =
                        HtmlParser.selectElement(document, fallbackSelector);

                  }
                }
              } catch (e) {
                // 回退到普通CSS选择器
                final fallbackSelector =
                    elementSelectorChain.replaceFirst('tag.', '');
                element = HtmlParser.selectElement(document, fallbackSelector);
              }
            }
          } else {
            // 处理索引选择器（如 a.1, span.2 表示第N个元素）
            element = _selectElementWithIndex(document, elementSelectorChain);
          }
        }

        if (element != null) {
          // 特殊处理：@text, @html, @textNodes, @ownText, @all 等
          // 参考项目：AnalyzeByJSoup.getResultLast
          final attrLower = attributeName.toLowerCase();
          if (attrLower == 'text') {
            final text = HtmlParser.getText(element);
            return text;
          } else if (attrLower == 'html') {
            // 参考项目：移除script和style标签后再返回
            final html = HtmlParser.getHtmlWithoutScriptAndStyle(element);
            return html;
          } else if (attrLower == 'textnodes') {
            // 参考项目：获取文本节点（不包括子元素的文本）
            final textNodes = HtmlParser.getTextNodes(element);
            return textNodes;
          } else if (attrLower == 'owntext') {
            // 参考项目：获取元素自身的文本（不包括子元素）
            final ownText = HtmlParser.getOwnText(element);
            return ownText;
          } else if (attrLower == 'all') {
            // 参考项目：获取完整的outerHTML（不删除script和style）
            final allHtml = HtmlParser.getAllHtml(element);
            return allHtml;
          }

          // 获取属性值
          final attrValue = HtmlParser.getAttribute(element, attributeName);
          if (attrValue != null && attrValue.isNotEmpty) {
            // 如果是URL相关的属性（href, src, data-src等），且isUrl=true，使用baseUrl处理
            // 注意：如果规则包含@js:，不应该在这里拼接URL，应该让JavaScript代码处理
            if (isUrl &&
                baseUrl != null &&
                (attributeName == 'href' ||
                    attributeName == 'src' ||
                    attributeName == 'data-src' ||
                    attributeName.startsWith('data-'))) {
              final joinedUrl = NetworkService.joinUrl(baseUrl, attrValue);
              return joinedUrl;
            }
            return attrValue;
          }
        }
      }
      return null;
    }

    // 检查是否是独立的属性名（如 textNodes, href, text 等）
    // 这种情况下应该从当前文档/元素获取属性，而不是选择新元素
    final standaloneAttr = _getStandaloneAttribute(document, selector, isUrl: isUrl, baseUrl: baseUrl);
    if (standaloneAttr != null) {
      return standaloneAttr;
    }

    // 没有 @ 分隔符，按普通选择器处理
    final element = HtmlParser.selectElement(document, selector);
    if (element == null) {
      return null;
    }

    // 如果是URL解析，优先尝试获取链接属性
    if (isUrl) {
      // 尝试获取 href 属性（链接）
      final href = HtmlParser.getAttribute(element, 'href');
      if (href != null && href.isNotEmpty) {
        return baseUrl != null ? NetworkService.joinUrl(baseUrl, href) : href;
      }
      // 尝试获取其他可能的URL属性
      final src = HtmlParser.getAttribute(element, 'src');
      if (src != null && src.isNotEmpty) {
        return baseUrl != null ? NetworkService.joinUrl(baseUrl, src) : src;
      }
      // 如果都没有，返回文本内容（可能是相对路径）
      final text = HtmlParser.getText(element);
      if (text != null && text.isNotEmpty && baseUrl != null) {
        return NetworkService.joinUrl(baseUrl, text);
      }
      return text;
    }

    // 如果是链接元素，尝试获取 href 属性
    if (element.localName == 'a') {
      final href = HtmlParser.getAttribute(element, 'href');
      if (href != null && href.isNotEmpty && baseUrl != null) {
        return NetworkService.joinUrl(baseUrl, href);
      }
      return href ?? HtmlParser.getText(element);
    }

    // 如果是图片元素，尝试获取 src 或 data-src 属性
    if (element.localName == 'img') {
      var src = HtmlParser.getAttribute(element, 'src');
      if (src == null || src.isEmpty) {
        src = HtmlParser.getAttribute(element, 'data-src');
      }
      if (src != null && src.isNotEmpty && baseUrl != null) {
        return NetworkService.joinUrl(baseUrl, src);
      }
      return src ?? HtmlParser.getText(element);
    }

    // 默认返回文本内容
    return HtmlParser.getText(element);
  }

  /// 处理独立的属性名（如 textNodes, href, text 等）
  /// 当规则只是属性名而没有选择器前缀时调用
  static String? _getStandaloneAttribute(
    dynamic document,
    String attributeName, {
    bool isUrl = false,
    String? baseUrl,
  }) {
    final attrLower = attributeName.toLowerCase();

    // 检查是否是特殊的属性名
    final specialAttrs = [
      'text', 'html', 'textnodes', 'owntext', 'all',
      'href', 'src', 'title', 'alt',
    ];

    if (!specialAttrs.contains(attrLower)) {
      return null; // 不是特殊属性，返回null让调用者继续处理
    }

    // 获取当前上下文元素。对于 HTML 片段，优先取第一个实际元素，而不是 body/html 包装节点。
    html_dom.Element? rootElement;
    if (document is html_dom.Document) {
      final body = document.body;
      if (body != null && body.children.length == 1) {
        rootElement = body.children.first;
      } else if (body != null && body.children.isNotEmpty) {
        rootElement = body;
      } else if (document.documentElement != null &&
          document.documentElement!.children.length == 1) {
        rootElement = document.documentElement!.children.first;
      } else {
        rootElement = body ?? document.documentElement;
      }
    } else if (document is html_dom.Element) {
      rootElement = document;
    }

    if (rootElement == null) {
      return null;
    }

    // 根据属性名返回对应的值
    switch (attrLower) {
      case 'text':
        return HtmlParser.getText(rootElement);
      case 'html':
        return HtmlParser.getHtmlWithoutScriptAndStyle(rootElement);
      case 'textnodes':
        return HtmlParser.getTextNodes(rootElement);
      case 'owntext':
        return HtmlParser.getOwnText(rootElement);
      case 'all':
        return HtmlParser.getAllHtml(rootElement);
      case 'href':
        final href = HtmlParser.getAttribute(rootElement, 'href');
        if (href != null && href.isNotEmpty) {
          if (isUrl && baseUrl != null) {
            return NetworkService.joinUrl(baseUrl, href);
          }
          return href;
        }
        return null;
      case 'src':
        final src = HtmlParser.getAttribute(rootElement, 'src') ??
            HtmlParser.getAttribute(rootElement, 'data-src');
        if (src != null && src.isNotEmpty) {
          if (isUrl && baseUrl != null) {
            return NetworkService.joinUrl(baseUrl, src);
          }
          return src;
        }
        return null;
      case 'title':
        return HtmlParser.getAttribute(rootElement, 'title');
      case 'alt':
        return HtmlParser.getAttribute(rootElement, 'alt');
      default:
        return null;
    }
  }

  /// 选择带有索引的元素
  /// 支持 Legado 风格的索引选择器，如：
  /// - a.1 表示第2个 a 元素（0-indexed）
  /// - span.0 表示第1个 span 元素
  /// - div.-1 表示倒数第1个 div 元素
  /// - dd span.1 表示所有 dd 元素下的所有 span 元素中的第2个
  static html_dom.Element? _selectElementWithIndex(
    dynamic container,
    String selector,
  ) {
    // 检查是否包含空格（后代选择器）
    if (selector.contains(' ')) {
      // 对于后代选择器，Legado 的处理方式是：
      // "dd span.1" 表示从所有 dd 元素下的所有 span 元素中取第2个
      // 而不是从第一个 dd 元素下的 span 中取第2个

      // 解析选择器部分
      final parts = selector.split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return null;

      // 检查最后一部分是否有索引
      final lastPart = parts.last;
      final indexPattern = RegExp(r'^([a-zA-Z*][a-zA-Z0-9*\-]*)\.(-?\d+)$');
      final lastIndexMatch = indexPattern.firstMatch(lastPart);

      if (lastIndexMatch != null) {
        // 最后部分有索引，使用 Legado 风格的后代选择器
        // 构建 CSS 选择器（移除索引部分）
        final cssParts = <String>[];
        for (int i = 0; i < parts.length; i++) {
          final part = parts[i];
          final match = indexPattern.firstMatch(part);
          if (match != null) {
            // 有索引的部分，只取标签名
            cssParts.add(match.group(1)!);
          } else {
            cssParts.add(part);
          }
        }

        final cssSelector = cssParts.join(' ');
        final index = int.parse(lastIndexMatch.group(2)!);


        try {
          // 使用 CSS 选择器获取所有匹配的元素
          final allElements = HtmlParser.selectElements(container, cssSelector);

          if (allElements.isEmpty) {
            return null;
          }

          // 计算有效索引
          int effectiveIndex;
          if (index < 0) {
            effectiveIndex = allElements.length + index;
          } else {
            effectiveIndex = index;
          }

          if (effectiveIndex < 0 || effectiveIndex >= allElements.length) {
            return null;
          }

          final element = allElements[effectiveIndex];
          return element;
        } catch (e) {
          return null;
        }
      } else {
        // 没有索引，使用普通 CSS 选择器
        try {
          return HtmlParser.selectElement(container, selector);
        } catch (e) {
        return null;
        }
      }
    }

    // 单一选择器（无空格）
    // 匹配 "tagname.N" 模式，其中 N 是数字（可正可负）
    final indexPattern = RegExp(r'^([a-zA-Z*][a-zA-Z0-9*\-]*)\.(-?\d+)$');
    final match = indexPattern.firstMatch(selector);

    if (match != null) {
      final tagName = match.group(1)!;
      final indexStr = match.group(2)!;
      final index = int.parse(indexStr);


      // 获取所有匹配的元素
      List<html_dom.Element> elements;
      if (tagName == '*') {
        elements = HtmlParser.selectElements(container, '*');
      } else {
        elements = HtmlParser.selectElements(container, tagName);
      }

      if (elements.isEmpty) {
        return null;
      }

      // 处理负索引（-1 表示最后一个，-2 表示倒数第二个，以此类推）
      int effectiveIndex;
      if (index < 0) {
        effectiveIndex = elements.length + index;
      } else {
        effectiveIndex = index;
      }

      // 检查索引是否有效
      if (effectiveIndex < 0 || effectiveIndex >= elements.length) {
        return null;
      }

      final element = elements[effectiveIndex];
      return element;
    }

    // 如果不是索引选择器，使用普通的 CSS 选择器
    try {
      return HtmlParser.selectElement(container, selector);
    } catch (e) {
      return null;
    }
  }

  /// 解析 XPath 规则（参考 AnalyzeByXPath）
  /// 支持属性选择（@href, @src等）和文本提取
  /// 参考项目：AnalyzeByXPath.getString - 使用 JXNode.asString() 获取节点值
  static String? _parseXPath(String html, String xpath, String? baseUrl,
      {bool isUrl = false}) {
    try {
      final document = html_parser.parse(html);
      final nodes = HtmlParser.selectXPath(document, xpath);

      if (nodes.isEmpty) return null;

      // 参考项目：AnalyzeByXPath.getString - 使用 TextUtils.join("\n", it) 连接多个结果
      // 参考项目：getResult(rule)?.let { return TextUtils.join("\n", it) }
      // 其中 it 是 List<JXNode>，每个节点调用 asString() 获取字符串表示
      final results = <String>[];

      for (final node in nodes) {
        String? value;

        // 参考项目：JXNode.asString() 会自动处理属性和文本
        // 如果 XPath 查询的是属性节点（如 //a/@href），asString() 返回属性值
        // 如果 XPath 查询的是元素节点（如 //a），asString() 返回文本内容

        // 检查 XPath 是否包含属性选择（@attributeName）
        if (xpath.contains('@')) {
          // 尝试从 XPath 表达式中提取属性名
          // 支持格式：//a/@href, //img/@src, //div/@data-id 等
          final attrMatch = RegExp(r'@(\w+(?:-\w+)*)').firstMatch(xpath);
          if (attrMatch != null) {
            final attrName = attrMatch.group(1);
            if (attrName != null) {
              // 如果 XPath 查询的是属性节点，node.text 应该就是属性值
              // 参考项目：JXNode.asString() 对于属性节点返回属性值
              value = HtmlParser.getXPathNodeString(node);

              // 如果获取失败，尝试使用专门的属性获取方法
              if (value == null || value.isEmpty) {
                value = HtmlParser.getXPathNodeAttribute(node, attrName);
              }
            }
          }
        }

        // 如果不是属性选择或属性获取失败，使用 asString() 的等价方法
        if (value == null || value.isEmpty) {
          // 参考项目：JXNode.asString() 对于元素节点返回文本内容
          value = HtmlParser.getXPathNodeString(node);
        }

        if (value != null && value.isNotEmpty) {
          // 如果是URL相关的属性，使用baseUrl处理
          // 参考项目：在 AnalyzeRule.getString 中，如果 isUrl=true，会进行 URL 处理
          if (baseUrl != null &&
              (isUrl ||
                  (xpath.contains('@href') ||
                      xpath.contains('@src') ||
                      xpath.contains('@data-src') ||
                      xpath.contains('@data-')))) {
            value = NetworkService.joinUrl(baseUrl, value);
          }
          results.add(value);
        }
      }

      if (results.isEmpty) return null;

      // 参考项目：多个结果用换行符连接
      // TextUtils.join("\n", it) 等价于 results.join('\n')
      final result = results.join('\n');

      // 如果是URL解析，尝试从文本内容构建URL
      // 参考项目：在 AnalyzeRule.getString 中，如果 isUrl=true 且结果不是完整URL，会使用 baseUrl 拼接
      if (isUrl &&
          result.isNotEmpty &&
          baseUrl != null &&
          !result.startsWith('http')) {
        return NetworkService.joinUrl(baseUrl, result);
      }

      return result;
    } catch (e) {
      AppLog.instance.put('_parseXPath: XPath解析失败: $xpath', error: e);
      return null;
    }
  }

  /// 规范化CSS选择器（将JSoup格式转换为标准CSS格式）
  /// 例如：class.hot_sale -> .hot_sale, id.main -> #main
  /// 注意：如果选择器包含 @ 分隔符，只规范化 @ 之前的部分
  /// 注意：如果选择器包含特殊前缀（tag., class., id., children., text.），不进行规范化
  static String _normalizeCssSelector(String selector) {
    // 如果包含 @ 分隔符，分别处理选择器部分和属性部分
    final lastAtIndex = selector.lastIndexOf('@');
    if (lastAtIndex > 0 && lastAtIndex < selector.length - 1) {
      final elementSelector = selector.substring(0, lastAtIndex).trim();
      final attributeName = selector.substring(lastAtIndex + 1).trim();

      // 检查是否包含特殊前缀，如果包含则不规范化（这些规则需要使用 ElementsSingle 处理）
      final hasSpecialPrefix = elementSelector.startsWith('tag.') ||
          elementSelector.startsWith('class.') ||
          elementSelector.startsWith('id.') ||
          elementSelector.startsWith('children.') ||
          elementSelector.startsWith('text.');

      if (hasSpecialPrefix) {
        // 不规范化，保持原样
        return '$elementSelector@$attributeName';
      }

      // 只规范化选择器部分
      final normalizedSelector = _normalizeSelectorPart(elementSelector);
      return '$normalizedSelector@$attributeName';
    }

    // 检查是否包含特殊前缀，如果包含则不规范化
    final hasSpecialPrefix = selector.startsWith('tag.') ||
        selector.startsWith('class.') ||
        selector.startsWith('id.') ||
        selector.startsWith('children.') ||
        selector.startsWith('text.');

    if (hasSpecialPrefix) {
      // 不规范化，保持原样
      return selector;
    }

    // 没有 @ 分隔符，直接规范化整个选择器
    return _normalizeSelectorPart(selector);
  }

  /// 规范化选择器部分（不包含 @ 的部分）
  static String _normalizeSelectorPart(String selector) {
    // 处理 class.xxx 格式 -> .xxx
    selector = selector.replaceAllMapped(
      RegExp(r'\bclass\.([\w-]+)'),
      (match) => '.${match.group(1)}',
    );
    // 处理 id.xxx 格式 -> #xxx
    selector = selector.replaceAllMapped(
      RegExp(r'\bid\.([\w-]+)'),
      (match) => '#${match.group(1)}',
    );
    // 处理 tag.xxx 格式 -> xxx（标签名直接使用）
    selector = selector.replaceAllMapped(
      RegExp(r'\btag\.([\w-]+)'),
      (match) => match.group(1)!,
    );
    return selector;
  }

  /// 解析列表规则
  /// [returnHtml] 如果为true，返回元素的HTML内容（innerHTML），否则返回文本内容
  /// 支持前缀：
  /// - `-` 表示倒序列表
  /// - `+` 表示使用 AllInOne 正则（由调用方处理）
  static List<String> parseListRule(
    String html,
    String? rule, {
    Map<String, String>? variables,
    String? baseUrl,
    bool returnHtml = false,
  }) {
    if (rule == null || rule.isEmpty) return [];

    try {
      String processedRule = _replaceVariables(rule, variables);

      // 处理列表倒置前缀（参考项目：AnalyzeRule.getElements）
      // 获取列表的最前面加上负号`-`可以使列表倒置
      bool reverse = false;
      if (processedRule.startsWith('-')) {
        reverse = true;
        processedRule = processedRule.substring(1);
      }

      if (_isRegexListRule(processedRule)) {
        final entries = _parseRegexListEntries(html, processedRule);
        final regexResults = entries
            .map((entry) => returnHtml ? entry.content : entry.content)
            .where((item) => item.isNotEmpty)
            .toList();
        if (reverse && regexResults.isNotEmpty) {
          return regexResults.reversed.toList();
        }
        return regexResults;
      }

      final document = html_parser.parse(html);
      List<String> results = [];

      if (processedRule.startsWith('//') || processedRule.startsWith('/')) {
        final nodes = HtmlParser.selectXPath(document, processedRule);
        if (returnHtml) {
          // 对于XPath，返回HTML内容（outerHTML）
          // 参考项目：JXNode.asString() 返回字符串表示
          // 使用 HtmlParser.getXPathNodeOuterHtml 获取节点的完整HTML
          results = nodes
              .map((node) {
                try {
                  final html = HtmlParser.getXPathNodeOuterHtml(node);
                  return html?.trim() ?? '';
                } catch (e) {
                  // 如果获取失败，尝试使用 toString() 作为后备
                  try {
                    return node.toString().trim();
                  } catch (e2) {
                    return '';
                  }
                }
              })
              .where((html) => html.isNotEmpty)
              .toList();
        } else {
          // 返回文本内容
          // 参考项目：JXNode.asString() 对于元素节点返回文本内容
          results = nodes
              .map((node) {
                // 使用 getXPathNodeString 获取节点字符串表示
                // 参考项目：JXNode.asString() 的行为
                final text = HtmlParser.getXPathNodeString(node);
                return text?.trim() ?? '';
              })
              .where((text) => text.isNotEmpty)
              .toList();
        }
      } else {
        // 参考项目：如果规则包含 @ 分隔符，需要区分两种情况：
        // 1. 元素选择器链：id.list@tag.dd（选择 id.list，然后在结果中选择 tag.dd）
        // 2. 属性选择器：tag.a@text, tag.a@href（选择 tag.a，然后获取 text 或 href 属性）
        //
        // 判断规则是元素选择器链还是属性选择器：
        // - 如果最后一个 @ 后面是属性名（text, html, href, src等），则是属性选择器，不应该分割
        // - 否则是元素选择器链，需要分割

        // 检查是否是属性选择器（@text, @html, @href, @src等）
        final lastAtIndex = processedRule.lastIndexOf('@');
        bool isAttributeSelector = false;
        if (lastAtIndex > 0 && lastAtIndex < processedRule.length - 1) {
          final afterAt = processedRule.substring(lastAtIndex + 1).trim();
          // 常见的属性名（包括特殊属性）
          final attributeNames = [
            'text',
            'html',
            'textnodes',
            'owntext',
            'all',
            'href',
            'src',
            'data-src',
            'alt',
            'title',
            'class',
            'id'
          ];
          isAttributeSelector = attributeNames.contains(afterAt.toLowerCase());
        }

        if (isAttributeSelector) {
          // 属性选择器，不分割，直接使用 _parseCss 处理
          // 但 parseListRule 需要返回元素列表，所以需要先选择元素，再获取属性
          final elementSelector =
              processedRule.substring(0, lastAtIndex).trim();
          final attributeName = processedRule.substring(lastAtIndex + 1).trim();

          String normalizedRule;
          if (elementSelector.startsWith('class.')) {
            normalizedRule = '.${elementSelector.substring(6)}';
          } else if (elementSelector.startsWith('id.')) {
            normalizedRule = '#${elementSelector.substring(3)}';
          } else {
            normalizedRule = _normalizeCssSelector(elementSelector);
          }
          final elements = HtmlParser.selectElements(document, normalizedRule);

          for (final element in elements) {
            final attrLower = attributeName.toLowerCase();
            String? value;

            // 参考项目：AnalyzeByJSoup.getResultLast - 处理特殊属性
            if (attrLower == 'text') {
              value = HtmlParser.getText(element);
            } else if (attrLower == 'html') {
              // 移除script和style标签
              value = HtmlParser.getHtmlWithoutScriptAndStyle(element);
            } else if (attrLower == 'textnodes') {
              value = HtmlParser.getTextNodes(element);
            } else if (attrLower == 'owntext') {
              value = HtmlParser.getOwnText(element);
            } else if (attrLower == 'all') {
              value = HtmlParser.getAllHtml(element);
            } else {
              // 其他属性（href, src等）
              value = HtmlParser.getAttribute(element, attributeName);
            }

            if (value != null && value.isNotEmpty) {
              results.add(value);
            }
          }
        } else {
          // 元素选择器链，按 @ 分割，依次应用每个规则片段
          // 例如：id.list@tag.dd 会被分割为 ["id.list", "tag.dd"]
          // 先选择 id.list，然后在结果中选择 tag.dd
          final ruleParts = processedRule.split('@');

          if (ruleParts.length > 1) {
            // 包含 @ 分隔符，需要依次应用每个规则片段

            // 从 document 开始，依次应用每个规则片段
            // 参考项目：从 temp（当前上下文）开始，依次应用每个规则片段
            List<html_dom.Element> currentElements = [];
            final rootElement = document.documentElement ?? document.body;
            if (rootElement != null) {
              currentElements.add(rootElement);
            }

            for (int i = 0; i < ruleParts.length; i++) {
              final rulePart = ruleParts[i].trim();
              if (rulePart.isEmpty) continue;

              // 参考项目：AnalyzeByJSoup.getElements - 对于非CSS规则，总是使用 ElementsSingle
              // 检查规则是否包含特殊前缀（tag., class., id., children., text.）
              // 这些规则应该使用 ElementsSingle 处理，即使没有索引
              final hasSpecialPrefix = rulePart.startsWith('tag.') ||
                  rulePart.startsWith('class.') ||
                  rulePart.startsWith('id.') ||
                  rulePart.startsWith('children.') ||
                  rulePart.startsWith('text.');

              // 检查规则是否包含索引选择（例如：tag.div.0:3 或 tag.div[-1, 2]）
              final hasIndex = rulePart.contains('.') &&
                  (RegExp(r'[:\-\[\]!]').hasMatch(rulePart) ||
                      RegExp(r'\.\d').hasMatch(rulePart));

              final nextElements = <html_dom.Element>[];
              for (final element in currentElements) {
                // 参考项目：如果规则包含特殊前缀或索引，使用 ElementsSingle
                if (hasSpecialPrefix || hasIndex) {
                  // 对于 id. 和 class. 前缀，优先使用 CSS 选择器（更可靠）
                  // 对于 tag. 和 children. 前缀，使用 ElementsSingle
                  final useCssSelector = rulePart.startsWith('id.') ||
                      rulePart.startsWith('class.');

                  if (useCssSelector) {
                    // 使用 CSS 选择器处理 id. 和 class.
                    // 手动规范化 id.xxx -> #xxx, class.xxx -> .xxx
                    String normalizedRule;
                    if (rulePart.startsWith('id.')) {
                      normalizedRule = '#${rulePart.substring(3)}';
                    } else if (rulePart.startsWith('class.')) {
                      normalizedRule = '.${rulePart.substring(6)}';
                    } else {
                      normalizedRule = _normalizeCssSelector(rulePart);
                    }
                    final selected =
                        HtmlParser.selectElements(element, normalizedRule);
                    nextElements.addAll(selected);
                  } else {
                    // 使用 ElementsSingle 处理 tag. 和 children.
                    // 对于 tag.dd 这种简单规则，也可以尝试直接使用 CSS 选择器
                    try {
                      final selected =
                          ElementsSingle.getElementsSingle(element, rulePart);
                      nextElements.addAll(selected);
                      if (selected.isEmpty) {
                        // 回退到 CSS 选择器：tag.dd -> dd
                        String normalizedRule;
                        if (rulePart.startsWith('tag.')) {
                          normalizedRule =
                              rulePart.substring(4); // tag.dd -> dd
                        } else {
                          normalizedRule = _normalizeCssSelector(rulePart);
                        }
                        final cssSelected =
                            HtmlParser.selectElements(element, normalizedRule);
                        nextElements.addAll(cssSelected);
                      }
                    } catch (e) {
                      // 回退到 CSS 选择器：tag.dd -> dd
                      String normalizedRule;
                      if (rulePart.startsWith('tag.')) {
                        normalizedRule = rulePart.substring(4); // tag.dd -> dd
                      } else {
                        normalizedRule = _normalizeCssSelector(rulePart);
                      }
                      final selected =
                          HtmlParser.selectElements(element, normalizedRule);
                      nextElements.addAll(selected);
                    }
                  }
                } else {
                  // 普通CSS选择器
                  final normalizedRule = _normalizeCssSelector(rulePart);
                  final selected =
                      HtmlParser.selectElements(element, normalizedRule);
                  nextElements.addAll(selected);
                }
              }
              currentElements = nextElements;

              // 如果某个规则片段没有找到元素，停止处理
              if (currentElements.isEmpty) {
                break;
              }
            }

            // 处理最终结果
            for (final element in currentElements) {
              if (returnHtml) {
                // 返回 outerHTML（包含元素本身的标签），以便后续可以解析属性（如 href）
                final html = HtmlParser.getOuterHtml(element) ?? '';
                if (html.isNotEmpty) {
                  results.add(html);
                }
              } else {
                final text = HtmlParser.getText(element) ?? '';
                if (text.isNotEmpty) {
                  results.add(text);
                }
              }
            }
          } else {
            // 没有 @ 分隔符，检查是否是特殊前缀规则
            final hasSpecialPrefix = processedRule.startsWith('tag.') ||
                processedRule.startsWith('class.') ||
                processedRule.startsWith('id.') ||
                processedRule.startsWith('children.') ||
                processedRule.startsWith('text.');

            if (hasSpecialPrefix) {
              // 对于 class.xxx 和 id.xxx，优先使用 CSS 选择器（更可靠）
              // 对于 tag.xxx 和 children.xxx，使用 ElementsSingle
              final useCssSelector = processedRule.startsWith('class.') ||
                  processedRule.startsWith('id.');

              if (useCssSelector) {
                // 使用 CSS 选择器
                // 对于 class.xxx 和 id.xxx，直接规范化（不使用 _normalizeCssSelector，因为它会跳过特殊前缀）
                String normalizedRule;
                if (processedRule.startsWith('class.')) {
                  // class.hot_sale -> .hot_sale
                  normalizedRule = '.${processedRule.substring(6)}';
                } else if (processedRule.startsWith('id.')) {
                  // id.main -> #main
                  normalizedRule = '#${processedRule.substring(3)}';
                } else {
                  normalizedRule = _normalizeCssSelector(processedRule);
                }
                final elements =
                    HtmlParser.selectElements(document, normalizedRule);

                if (returnHtml) {
                  results = elements
                      .map((e) => HtmlParser.getOuterHtml(e) ?? '')
                      .toList();
                } else {
                  results =
                      elements.map((e) => HtmlParser.getText(e) ?? '').toList();
                }
              } else {
                // 使用 ElementsSingle 处理 tag.xxx 和 children.xxx
                try {
                  final rootElement = document.documentElement ?? document.body;
                  if (rootElement != null) {
                    final selectedElements = ElementsSingle.getElementsSingle(
                        rootElement, processedRule);

                    if (returnHtml) {
                      results = selectedElements
                          .map((e) => HtmlParser.getOuterHtml(e) ?? '')
                          .toList();
                    } else {
                      results = selectedElements
                          .map((e) => HtmlParser.getText(e) ?? '')
                          .toList();
                    }
                  }
                } catch (e) {
                  final normalizedRule = _normalizeCssSelector(processedRule);
                  final elements =
                      HtmlParser.selectElements(document, normalizedRule);
                  if (returnHtml) {
                    results = elements
                        .map((e) => HtmlParser.getOuterHtml(e) ?? '')
                        .toList();
                  } else {
                    results = elements
                        .map((e) => HtmlParser.getText(e) ?? '')
                        .toList();
                  }
                }
              }
            } else {
              // 普通CSS选择器
              final normalizedRule = _normalizeCssSelector(processedRule);
              final elements =
                  HtmlParser.selectElements(document, normalizedRule);
              if (returnHtml) {
                // 返回 outerHTML（包含元素本身的标签），以便后续可以解析属性（如 href）
                results = elements
                    .map((e) => HtmlParser.getOuterHtml(e) ?? '')
                    .toList();
              } else {
                // 返回文本内容
                results =
                    elements.map((e) => HtmlParser.getText(e) ?? '').toList();
              }
            }
          }
        }
      }

      final filtered = results.where((r) => r.isNotEmpty).toList();

      // 如果需要倒序，返回反转后的列表
      if (reverse && filtered.isNotEmpty) {
        return filtered.reversed.toList();
      }
      return filtered;
    } catch (e) {
      return [];
    }
  }

  /// 解析搜索规则
  static Future<List<Map<String, String?>>> parseSearchRule(
    String html,
    SearchRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) async {
    if (rule == null || rule.bookList == null) return [];

    // 对于bookList，需要返回HTML内容（returnHtml=true），以便后续解析子元素
    final listEntries = _parseListEntries(
      html,
      rule.bookList,
      variables: variables,
      baseUrl: baseUrl,
    );
    final results = <Map<String, String?>>[];

    for (int i = 0; i < listEntries.length; i++) {
      final bookHtml = listEntries[i].content;
      final itemVariables = <String, String>{
        ...?variables,
        ...listEntries[i].groups,
      };
      final originalItemVariables = Map<String, String>.from(itemVariables);

      // 解析bookUrl时使用isUrl=true，参考项目逻辑
      final bookUrl = await _parseFieldRuleWithContext(
        bookHtml,
        rule.bookUrl,
        itemVariables,
        baseUrl: baseUrl,
        isUrl: true,
      );
      final nameRaw = await _parseFieldRuleWithContext(
        bookHtml,
        rule.name,
        itemVariables,
        baseUrl: baseUrl,
      );
      final authorRaw = await _parseFieldRuleWithContext(
        bookHtml,
        rule.author,
        itemVariables,
        baseUrl: baseUrl,
      );
      final kindRaw = await _parseFieldRuleWithContext(
        bookHtml,
        rule.kind,
        itemVariables,
        baseUrl: baseUrl,
      );
      final wordCount = await _parseFieldRuleWithContext(
        bookHtml,
        rule.wordCount,
        itemVariables,
        baseUrl: baseUrl,
      );
      final lastChapter = await _parseFieldRuleWithContext(
        bookHtml,
        rule.lastChapter,
        itemVariables,
        baseUrl: baseUrl,
      );
      final intro = await _parseFieldRuleWithContext(
        bookHtml,
        rule.intro,
        itemVariables,
        baseUrl: baseUrl,
      );
      final coverUrl = await _parseFieldRuleWithContext(
        bookHtml,
        rule.coverUrl,
        itemVariables,
        baseUrl: baseUrl,
      );
      final checkKeyWord = await _parseFieldRuleWithContext(
        bookHtml,
        rule.checkKeyWord,
        itemVariables,
        baseUrl: baseUrl,
      );

      // 处理 name、author、kind：trim 并清理 HTML 标签（如果存在）
      final name = nameRaw?.trim();
      final author = authorRaw?.trim();
      String? kind = kindRaw?.trim();
      // 如果 kind 包含 HTML 标签，清理它们（参考项目：kind 字段应该只包含纯文本）
      if (kind != null && kind.isNotEmpty && kind.contains('<')) {
        kind = HtmlParser.cleanHtml(kind).trim();
      }

      results.add({
        'name': name,
        'author': author,
        'kind': kind,
        'wordCount': wordCount,
        'lastChapter': lastChapter,
        'intro': intro,
        'coverUrl': coverUrl,
        'bookUrl': bookUrl, // 使用isUrl=true解析的结果
        'checkKeyWord': checkKeyWord, // 用于验证搜索结果是否包含关键词
        'variable': _encodeTransientVariables(
          originalItemVariables,
          itemVariables,
        ),
      });
    }

    return results;
  }

  /// 解析书籍详情规则
  static Future<Map<String, String?>> parseBookInfoRule(
    String html,
    BookInfoRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) async {
    if (rule == null) return {};

    // 执行初始化脚本（如果有）
    if (rule.init != null && rule.init!.isNotEmpty) {
      final initRule = rule.init!.trim();
      if (initRule.startsWith(':')) {
        html = await parseRuleAsync(
              html,
              initRule,
              variables: variables,
              baseUrl: baseUrl,
              allowRegexRule: true,
            ) ??
            html;
      } else {
        html = await _executeJs(
              html,
              initRule,
              variables: variables,
            ) ??
            html;
      }
    }

    // 解析各个字段
    final nameRaw = await parseRuleAsync(html, rule.name,
        variables: variables, baseUrl: baseUrl);
    final authorRaw = await parseRuleAsync(html, rule.author,
        variables: variables, baseUrl: baseUrl);
    final kindRaw = await parseRuleAsync(html, rule.kind,
        variables: variables, baseUrl: baseUrl);

    // 处理 name、author、kind：trim 并清理 HTML 标签（如果存在）
    final name = nameRaw?.trim();
    final author = authorRaw?.trim();
    String? kind = kindRaw?.trim();
    // 如果 kind 包含 HTML 标签，清理它们（参考项目：kind 字段应该只包含纯文本）
    if (kind != null && kind.isNotEmpty && kind.contains('<')) {
      kind = HtmlParser.cleanHtml(kind).trim();
    }

    return {
      'name': name,
      'author': author,
      'kind': kind,
      'wordCount': await parseRuleAsync(html, rule.wordCount,
          variables: variables, baseUrl: baseUrl),
      'lastChapter': await parseRuleAsync(html, rule.lastChapter,
          variables: variables, baseUrl: baseUrl),
      'intro': await parseRuleAsync(html, rule.intro,
          variables: variables, baseUrl: baseUrl),
      'coverUrl': await parseRuleAsync(html, rule.coverUrl,
          variables: variables, baseUrl: baseUrl, isUrl: true),
      'tocUrl': await parseRuleAsync(html, rule.tocUrl,
          variables: variables, baseUrl: baseUrl, isUrl: true),
      'canReName': await parseRuleAsync(html, rule.canReName,
          variables: variables, baseUrl: baseUrl), // 用于判断书籍是否可以重命名
    };
  }

  /// 解析章节列表规则
  /// 参考项目：BookChapterList.analyzeChapterList
  /// 注意：preUpdateJs 应该在调用此方法之前执行，但为了兼容性，这里也检查并执行
  static List<Map<String, String?>> parseTocRule(
    String html,
    TocRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) {
    if (rule == null || rule.chapterList == null) {
      return [];
    }

    // 参考项目：preUpdateJs 在解析目录前执行（虽然参考项目中没有明确显示，但根据字段名推测）
    // 注意：这里使用同步方法，因为 parseTocRule 是同步的
    // 如果 preUpdateJs 需要异步执行，应该在调用 parseTocRule 之前执行
    // 但为了确保兼容性，这里先不执行（因为同步方法无法执行异步JS）

    // 对于chapterList，需要返回HTML内容（returnHtml=true），以便后续解析子元素
    final chapterEntries = _parseListEntries(
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

      // 参考项目：先解析所有字段
      // 参考项目：getString 在规则为空时返回空字符串，而不是 null
      // 参考项目：getString0 会先获取列表再取第一个元素
      // 注意：参考项目的 getString 返回 String（非空），当前项目返回 String?（可空）
      // 为了保持一致，将 null 转换为空字符串
      final chapterName = _RuleParserToc._parseFieldRuleSyncWithContext(
            chapterHtml,
            rule.chapterName,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';
      final chapterUrl = _RuleParserToc._parseFieldRuleSyncWithContext(
            chapterHtml,
            rule.chapterUrl,
            itemVariables,
            baseUrl: baseUrl,
            isUrl: true,
          ) ??
          '';
      final isVip = _RuleParserToc._parseFieldRuleSyncWithContext(
            chapterHtml,
            rule.isVip,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';
      final isVolumeStr = _RuleParserToc._parseFieldRuleSyncWithContext(
            chapterHtml,
            rule.isVolume,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';
      final updateTime = _RuleParserToc._parseFieldRuleSyncWithContext(
            chapterHtml,
            rule.updateTime,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';
      final nextTocUrl = _RuleParserToc._parseFieldRuleSyncWithContext(
            chapterHtml,
            rule.nextTocUrl,
            itemVariables,
            baseUrl: baseUrl,
            isUrl: true,
          ) ??
          '';
      // Phase 3：章节时长（音视频目录）
      final duration = _RuleParserToc._parseFieldRuleSyncWithContext(
            chapterHtml,
            rule.duration,
            itemVariables,
            baseUrl: baseUrl,
          ) ??
          '';

      // 判断是否是卷名（参考项目逻辑）
      // isVolume 规则如果返回非空值（通常是 "true"、"1" 或非空字符串），则认为是卷名
      final isVolume = isVolumeStr.isNotEmpty &&
          (isVolumeStr.toLowerCase() == 'true' ||
              isVolumeStr == '1' ||
              isVolumeStr.trim().isNotEmpty);

      // 参考项目：如果 chapterUrl 为空，根据情况设置默认值
      String? finalChapterUrl = chapterUrl;
      if (finalChapterUrl.isEmpty) {
        // 参考项目逻辑：
        // 1. 如果是卷名（isVolume），URL 可以为空（卷名不需要链接）
        // 2. 如果不是卷名且URL为空，使用baseUrl作为默认值
        if (!isVolume) {
          finalChapterUrl = baseUrl;
        } else {
          // 卷名不需要URL，设置为空字符串或null
          finalChapterUrl = null;
        }
      }

      // 参考项目：只添加 title.isNotEmpty 的章节
      // 注意：参考项目会检查 title.isNotEmpty，即使 URL 为空也会添加（使用 baseUrl）
      // 对于卷名，即使没有URL也会添加
      if (chapterName.isNotEmpty) {
        results.add({
          'chapterName': chapterName,
          'chapterUrl': finalChapterUrl,
          'isVip': isVip,
          'isVolume': isVolume ? '1' : '0', // 转换为字符串格式，与数据库存储一致
          'updateTime': updateTime,
          'nextTocUrl': nextTocUrl,
          'duration': duration,
        });
      }
    }

    return results;
  }

  // _parseTocRuleAsync → 已迁移至 rule_parser_toc.dart → _RuleParserToc._parseTocRuleAsync

  static List<_ListRuleEntry> _parseListEntries(
    String html,
    String? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) {
    if (rule == null || rule.isEmpty) return const [];

    final processedRule = _replaceVariables(rule, variables);
    final analyzer = RuleAnalyzer(processedRule);
    final splitRules = analyzer.splitRule(['&&', '||', '%%']);
    if (splitRules.length > 1 && analyzer.elementsType == '||') {
      for (final splitRule in splitRules) {
        final entries = _parseListEntries(
          html,
          splitRule.trim(),
          variables: variables,
          baseUrl: baseUrl,
        );
        if (entries.isNotEmpty) {
          return entries;
        }
      }
      return const [];
    }

    if (processedRule.startsWith('@Json:') ||
        processedRule.startsWith('@json:') ||
        processedRule.startsWith(r'$.') ||
        processedRule.startsWith(r'$[')) {
      return _parseJsonListEntries(html, processedRule);
    }

    if (_isRegexListRule(processedRule)) {
      return _parseRegexListEntries(html, processedRule);
    }

    final items = parseListRule(
      html,
      processedRule,
      variables: variables,
      baseUrl: baseUrl,
      returnHtml: true,
    );
    return items.map((item) => _ListRuleEntry(content: item)).toList();
  }

  static List<_ListRuleEntry> _parseJsonListEntries(
    String html,
    String rule,
  ) {
    try {
      var actualRule = rule.trim();
      if (actualRule.startsWith('@Json:') || actualRule.startsWith('@json:')) {
        actualRule = actualRule.substring(6).trim();
      }

      dynamic jsonData;
      try {
        jsonData = jsonDecode(html);
      } catch (_) {
        return const [];
      }

      final jsonPath = JsonPath(actualRule);
      final values = jsonPath.read(jsonData).map((match) => match.value).toList();
      if (values.isEmpty) return const [];

      return values.map((value) {
        if (value is Map || value is List) {
          return _ListRuleEntry(content: jsonEncode(value));
        }
        return _ListRuleEntry(content: value?.toString() ?? '');
      }).where((entry) => entry.content.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  static List<_ListRuleEntry> _parseRegexListEntries(
    String html,
    String rule,
  ) {
    var actualRule = rule.trim();
    var reverse = false;
    if (actualRule.startsWith('-')) {
      reverse = true;
      actualRule = actualRule.substring(1).trimLeft();
    }
    if (!_isRegexListRule(actualRule)) return const [];

    final regexChain = actualRule
        .substring(1)
        .split('&&')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (regexChain.isEmpty) return const [];

    final matches = AnalyzeByRegex.getElements(html, regexChain);
    final entries = matches.map((groups) {
      final variables = <String, String>{};
      for (int i = 0; i < groups.length; i++) {
        variables['\$$i'] = groups[i];
      }
      return _ListRuleEntry(
        content: groups.isNotEmpty ? groups.first : '',
        groups: variables,
      );
    }).where((entry) => entry.content.isNotEmpty).toList();

    if (reverse && entries.isNotEmpty) {
      return entries.reversed.toList();
    }
    return entries;
  }

  static bool _isRegexListRule(String rule) {
    var trimmed = rule.trimLeft();
    if (trimmed.startsWith('-')) {
      trimmed = trimmed.substring(1).trimLeft();
    }
    return trimmed.startsWith('+') || trimmed.startsWith(':');
  }

  static String _applyCaptureGroupVariables(
    String rule,
    Map<String, String>? variables,
  ) {
    if (rule.isEmpty || variables == null || variables.isEmpty) {
      return rule;
    }

    final splitIndex = rule.indexOf('##');
    final mainRule = splitIndex >= 0 ? rule.substring(0, splitIndex) : rule;
    final suffix = splitIndex >= 0 ? rule.substring(splitIndex) : '';

    final replacedMain = mainRule.replaceAllMapped(
      RegexCache.instance.getOrCompile(r'\$(\d+)'),
      (match) => variables['\$${match.group(1)!}'] ?? match.group(0)!,
    );
    return '$replacedMain$suffix';
  }

  static Future<String?> _parseFieldRuleWithContext(
    String html,
    String? rule,
    Map<String, String>? variables, {
    String? baseUrl,
    bool isUrl = false,
  }) async {
    if (rule == null || rule.isEmpty) return null;
    final preparedRule = await _prepareContextualFieldRule(
      html,
      rule,
      variables,
      baseUrl: baseUrl,
    );
    final contextualRule = preparedRule.rule;
    if (contextualRule.contains('{') && contextualRule.contains('}')) {
      final resolvedRule = await _resolveEmbeddedRuleTemplates(
        html,
        contextualRule,
        variables,
        baseUrl: baseUrl,
      );
      if (resolvedRule != rule && !_looksLikeParserRule(resolvedRule)) {
        if (isUrl && baseUrl != null && baseUrl.isNotEmpty) {
          final literal = resolvedRule.startsWith('http') || resolvedRule.startsWith('data:')
              ? resolvedRule
              : NetworkService.joinUrl(baseUrl, resolvedRule);
          return preparedRule.replaceRule == null
              ? literal
              : _applyReplaceRegexInternal(literal, preparedRule.replaceRule!);
        }
        final literal = resolvedRule;
        return preparedRule.replaceRule == null
            ? literal
            : _applyReplaceRegexInternal(literal, preparedRule.replaceRule!);
      }
    }
    final literalResult = _resolveCaptureGroupLiteral(
      rule,
      contextualRule,
      baseUrl: baseUrl,
      isUrl: isUrl,
    );
    if (literalResult != null) {
      await _applyContextualPutAssignments(
        html,
        preparedRule.putAssignments,
        variables,
        baseUrl: baseUrl,
        fallbackResult: literalResult,
      );
      return preparedRule.replaceRule == null
          ? literalResult
          : _applyReplaceRegexInternal(literalResult, preparedRule.replaceRule!);
    }
    final parsed = await parseRuleAsync(
      html,
      contextualRule,
      variables: variables,
      baseUrl: baseUrl,
      isUrl: isUrl,
    );
    await _applyContextualPutAssignments(
      html,
      preparedRule.putAssignments,
      variables,
      baseUrl: baseUrl,
      fallbackResult: parsed,
    );
    if (parsed == null || preparedRule.replaceRule == null) {
      return parsed;
    }
    return _applyReplaceRegexInternal(parsed, preparedRule.replaceRule!);
  }

  static Future<String> _resolveEmbeddedRuleTemplates(
    String html,
    String rule,
    Map<String, String>? variables, {
    String? baseUrl,
  }) async {
    final pattern = RegexCache.instance.getOrCompile(r'\{(@?Json:[^{}]+|@?json:[^{}]+|\$[^{}]+)\}');
    var result = rule;
    for (final match in pattern.allMatches(rule).toList().reversed) {
      final innerRule = match.group(1);
      if (innerRule == null || innerRule.isEmpty) continue;
      final resolved = await parseRuleAsync(
            html,
            innerRule,
            variables: variables,
            baseUrl: baseUrl,
          ) ??
          '';
      result = result.replaceRange(match.start, match.end, resolved);
    }
    return result;
  }

  // _parseFieldRuleSyncWithContext → 已迁移至 rule_parser_toc.dart → _RuleParserToc._parseFieldRuleSyncWithContext

  static Future<_PreparedFieldRule> _prepareContextualFieldRule(
    String html,
    String rule,
    Map<String, String>? variables, {
    String? baseUrl,
  }) async {
    var contextualRule = _applyCaptureGroupVariables(rule, variables);
    final splitIndex = contextualRule.indexOf('##');
    final actualRule =
        splitIndex >= 0 ? contextualRule.substring(0, splitIndex) : contextualRule;
    final replaceRule = splitIndex >= 0 ? contextualRule.substring(splitIndex) : null;
    final resolvedRule = await _resolveDoubleBraceRuleTemplates(
      html,
      actualRule,
      variables,
      baseUrl: baseUrl,
    );
    final putExtraction = _extractContextualPutAssignments(resolvedRule);
    return _PreparedFieldRule(
      rule: putExtraction.cleanedRule,
      replaceRule: replaceRule,
      putAssignments: putExtraction.assignments,
    );
  }

  static ({
    String cleanedRule,
    List<MapEntry<String, String>> assignments,
  }) _extractContextualPutAssignments(String rule) {
    final assignments = <MapEntry<String, String>>[];
    final putPattern = RegexCache.instance.getOrCompile(
      r'@put:\s*\{([^}]+)\}',
      caseSensitive: false,
    );
    final cleanedRule = rule.replaceAllMapped(putPattern, (match) {
      final body = match.group(1)?.trim() ?? '';
      if (body.isEmpty) {
        return '';
      }

      final normalizedBody = body
          .replaceAllMapped(
            RegexCache.instance.getOrCompile(r'"([^"]+)"\s*:'),
            (m) => '${m.group(1)}:',
          )
          .replaceAllMapped(
            RegexCache.instance.getOrCompile(r"'([^']+)'\s*:"),
            (m) => '${m.group(1)}:',
          );

      for (final segment in normalizedBody.split(',')) {
        final pair = segment.trim();
        if (pair.isEmpty) continue;
        final separatorIndex = pair.indexOf(':');
        if (separatorIndex <= 0) continue;
        final key = pair.substring(0, separatorIndex).trim();
        var valueRule = pair.substring(separatorIndex + 1).trim();
        if (key.isEmpty || valueRule.isEmpty) continue;
        if ((valueRule.startsWith('"') && valueRule.endsWith('"')) ||
            (valueRule.startsWith("'") && valueRule.endsWith("'"))) {
          valueRule = valueRule.substring(1, valueRule.length - 1);
        }
        assignments.add(MapEntry(key, valueRule));
      }
      return '';
    }).trim();

    return (cleanedRule: cleanedRule, assignments: assignments);
  }

  static Future<void> _applyContextualPutAssignments(
    String html,
    List<MapEntry<String, String>> assignments,
    Map<String, String>? variables, {
    String? baseUrl,
    String? fallbackResult,
  }) async {
    if (assignments.isEmpty || variables == null) return;

    for (final assignment in assignments) {
      final valueRule = assignment.value.trim();
      if (valueRule.isEmpty) continue;

      String resolvedValue;
      if (valueRule == 'result') {
        resolvedValue = fallbackResult ?? '';
      } else if (_looksLikeParserRule(valueRule) ||
          valueRule.startsWith(r'$.') ||
          valueRule.startsWith(r'$[')) {
        resolvedValue = await parseRuleAsync(
              html,
              valueRule,
              variables: variables,
              baseUrl: baseUrl,
            ) ??
            '';
      } else {
        resolvedValue = valueRule;
      }

      variables[assignment.key] = resolvedValue;
      _variables[assignment.key] = resolvedValue;
    }
  }

  static Future<String> _resolveDoubleBraceRuleTemplates(
    String html,
    String rule,
    Map<String, String>? variables, {
    String? baseUrl,
  }) async {
    final pattern = RegexCache.instance.getOrCompile(r'\{\{(@@[^}]+|[^}]+)\}\}');
    var result = rule;
    for (final match in pattern.allMatches(rule).toList().reversed) {
      final innerRule = match.group(1)?.trim();
      if (innerRule == null || innerRule.isEmpty) continue;
      if (variables != null && variables.containsKey(innerRule)) {
        result = result.replaceRange(match.start, match.end, variables[innerRule]!);
        continue;
      }
      final normalizedInnerRule =
          innerRule.startsWith('@@') ? innerRule.substring(1) : innerRule;
      if (!_looksLikeParserRule(normalizedInnerRule)) {
        continue;
      }
      final resolved = await parseRuleAsync(
            html,
            normalizedInnerRule,
            variables: variables,
            baseUrl: baseUrl,
          ) ??
          '';
      result = result.replaceRange(match.start, match.end, resolved);
    }
    return result;
  }

  static String? _resolveCaptureGroupLiteral(
    String originalRule,
    String contextualRule, {
    String? baseUrl,
    bool isUrl = false,
  }) {
    if (!RegexCache.instance
        .getOrCompile(r'\$\d+')
        .hasMatch(originalRule)) {
      return null;
    }
    if (RegexCache.instance.getOrCompile(r'\$\d+').hasMatch(contextualRule)) {
      return null;
    }
    if (_looksLikeParserRule(contextualRule)) {
      return null;
    }

    if (isUrl && baseUrl != null && baseUrl.isNotEmpty) {
      return contextualRule.startsWith('http') || contextualRule.startsWith('data:')
          ? contextualRule
          : NetworkService.joinUrl(baseUrl, contextualRule);
    }
    return contextualRule;
  }

  static String? _resolvePutGetLiteral(
    String originalRule,
    String processedRule, {
    String? baseUrl,
    bool isUrl = false,
  }) {
    if (!originalRule.contains('@get:') && !originalRule.contains('@put:')) {
      return null;
    }
    if (processedRule.contains('@get:') || processedRule.contains('@put:')) {
      return null;
    }
    if (_looksLikeParserRule(processedRule)) {
      return null;
    }

    if (isUrl && baseUrl != null && baseUrl.isNotEmpty) {
      return processedRule.startsWith('http') || processedRule.startsWith('data:')
          ? processedRule
          : NetworkService.joinUrl(baseUrl, processedRule);
    }
    return processedRule;
  }

  static bool _looksLikeParserRule(String rule) {
    final trimmed = rule.trim();
    if (trimmed.isEmpty) return false;

    if (trimmed.startsWith('@CSS:') ||
        trimmed.startsWith('@css:') ||
        trimmed.startsWith('@@') ||
        trimmed.startsWith('@XPath:') ||
        trimmed.startsWith('@xpath:') ||
        trimmed.startsWith('@Json:') ||
        trimmed.startsWith('@json:') ||
        trimmed.startsWith('@js:') ||
        trimmed.startsWith('<js>') ||
        trimmed.startsWith('//') ||
        trimmed.startsWith(r'$.') ||
        trimmed.startsWith(r'$[') ||
        trimmed.startsWith('class.') ||
        trimmed.startsWith('id.') ||
        trimmed.startsWith('tag.') ||
        trimmed.startsWith('children.') ||
        trimmed.startsWith('text.') ||
        trimmed.startsWith('+') ||
        trimmed.startsWith('-')) {
      return true;
    }

    if (trimmed.startsWith(':') &&
        trimmed.length > 1 &&
        !RegExp(r'^[a-zA-Z-]').hasMatch(trimmed.substring(1).trim())) {
      return true;
    }

    return trimmed.contains('@') || trimmed.contains('##');
  }

  /// 解析章节列表规则，并返回章节列表和下一页URL列表
  ///
  /// 实现在 `rule_parser_toc.dart` → [_RuleParserToc.parseTocRuleWithNextUrl]
  static Future<Map<String, dynamic>> parseTocRuleWithNextUrl(
    String html,
    TocRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
    bool getNextUrl = true,
  }) =>
      _RuleParserToc.parseTocRuleWithNextUrl(html, rule,
          variables: variables, baseUrl: baseUrl, getNextUrl: getNextUrl);

  /// 解析返回 URL 列表的规则
  ///
  /// 实现在 `rule_parser_toc.dart` → [_RuleParserToc.parseUrlListRuleAsync]
  static Future<List<String>> parseUrlListRuleAsync(
    String html,
    String? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) =>
      _RuleParserToc.parseUrlListRuleAsync(html, rule,
          variables: variables, baseUrl: baseUrl);

  // _ruleContainsExecutableJs / _isJsOnlyRule / _normalizeRuleListResult
  // / _flattenRuleListValue → 已迁移至 rule_parser_toc.dart → _RuleParserToc

  /// 解析正文内容规则
  /// [applyReplaceRegex] 是否应用replaceRegex规则，默认为true
  /// 参考项目：replaceRegex是在所有页面内容合并后统一应用的，而不是每页单独应用
  /// [bookSourceType] 书源类型：0=文本 1=音频 2=图片/视频 3=文件
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

    // ── 音频源（bookSourceType == 1）专用解析路径 ──────────────────────────
    // 优先使用书源作者明确配置的 audioUrl 规则；
    // 若未配置则退回 content + sourceRegex 通用机制（可兼容旧书源）。
    // 实现在 rule_parser_media.dart → _RuleParserMedia.parseAudioContent
    if (bookSourceType == 1) {
      return await _RuleParserMedia.parseAudioContent(html, rule,
          variables: variables, baseUrl: baseUrl);
    }

    // ── 视频/图片源（bookSourceType == 2）专用解析路径 ────────────────────
    // 实现在 rule_parser_media.dart → _RuleParserMedia.parseVideoContent
    if (bookSourceType == 2) {
      return await _RuleParserMedia.parseVideoContent(html, rule,
          variables: variables, baseUrl: baseUrl);
    }

    if (rule.content == null) return null;

    try {
      // 执行网页 JavaScript（如果有）
      if (rule.webJs != null && rule.webJs!.isNotEmpty) {
        html =
            await _executeJs(html, rule.webJs!, variables: variables) ?? html;
      }

      // 提取正文内容
      // 参考项目：使用 unescape = false，先获取HTML内容，然后再处理转义
      String? content = await parseRuleAsync(html, rule.content,
          variables: variables, baseUrl: baseUrl);

      // 如果原始规则失败，尝试智能降级（类似目录获取的降级机制）
      if (content == null || content.isEmpty) {
        // 检查HTML中是否有常见的content容器
        // 参考目录获取的降级机制：动态查找内容容器
        final contentPattern = RegExp(
            'id\\s*=\\s*["\']([^"\']*content[^"\']*)["\']',
            caseSensitive: false);
        final contentMatches = contentPattern.allMatches(html);
        final contentIds = contentMatches
            .map((m) => m.group(1))
            .whereType<String>()
            .take(10)
            .toList();

        final contentClassPattern = RegExp(
            'class\\s*=\\s*["\']([^"\']*content[^"\']*)["\']',
            caseSensitive: false);
        final contentClassMatches = contentClassPattern.allMatches(html);
        final contentClassesList = <String>[];
        for (final match in contentClassMatches) {
          final classAttr = match.group(1);
          if (classAttr != null) {
            final classes = classAttr.split(RegExp(r'\s+'));
            for (final cls in classes) {
              if (cls.contains('content') &&
                  !contentClassesList.contains(cls)) {
                contentClassesList.add(cls);
              }
            }
          }
        }
        final contentClasses = contentClassesList.take(10).toList();

        // 尝试查找其他可能的内容容器（如nr1, text, article等）
        final otherIdPattern = RegExp(
            'id\\s*=\\s*["\']([^"\']*(?:nr|text|article|main|body|read|book)[^"\']*)["\']',
            caseSensitive: false);
        final otherIdMatches = otherIdPattern.allMatches(html);
        final otherIds = otherIdMatches
            .map((m) => m.group(1))
            .whereType<String>()
            .take(10)
            .toList();

        final otherClassPattern = RegExp(
            'class\\s*=\\s*["\']([^"\']*(?:nr|text|article|main|body|read|book)[^"\']*)["\']',
            caseSensitive: false);
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

        // 尝试常见的content容器选择器
        final fallbackRules = <String>[];

        // 优先尝试找到的包含"content"的ID和class
        for (final id in contentIds) {
          fallbackRules.add('id.$id@html');
          fallbackRules.add('id.$id@text');
        }
        for (final cls in contentClasses) {
          fallbackRules.add('class.$cls@html');
          fallbackRules.add('class.$cls@text');
        }

        // 然后尝试其他可能的内容容器
        for (final id in otherIds) {
          fallbackRules.add('id.$id@html');
          fallbackRules.add('id.$id@text');
        }
        for (final cls in otherClasses) {
          fallbackRules.add('class.$cls@html');
          fallbackRules.add('class.$cls@text');
        }

        // 最后尝试常见的正文容器（即使没有找到）
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

        // 尝试每个降级规则
        for (final fallbackRule in fallbackRules) {
          final fallbackContent = parseRule(html, fallbackRule,
              variables: variables, baseUrl: baseUrl);
          if (fallbackContent != null && fallbackContent.isNotEmpty) {
            content = fallbackContent;
            break;
          }
        }

        if (content == null || content.isEmpty) {
          return null;
        }
      }

      // 此时 content 已确定不为 null 且不为空（前面已经检查过）
      // 编译器已识别 content 不为 null，直接使用
      String processedContent = content;

      // 应用 sourceRegex 规则（如果存在，在清理HTML之前应用）
      // 参考项目：sourceRegex 用于从HTML中提取特定内容，通常在清理HTML之前应用
      final sourceRegexValue = rule.sourceRegex;
      if (sourceRegexValue != null && sourceRegexValue.isNotEmpty) {
        try {
          final regex = RegexCache.instance.getOrCompile(
            sourceRegexValue,
            multiLine: true,
          );
          final matches = regex.allMatches(processedContent);
          if (matches.isNotEmpty) {
            // 与说明页保持更一致：
            // 如果正则存在捕获组，优先使用第一个非空捕获组；否则退回 group(0)。
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
              error: e);
        }
      }

      // 参考项目：HtmlFormatter.formatKeepImg(content, rUrl)
      // 格式化图片URL，确保图片URL是绝对URL
      // 参考项目：formatKeepImg 会处理图片的src属性，确保是绝对URL
      if (baseUrl != null && baseUrl.isNotEmpty) {
        // 匹配img标签，支持单引号和双引号
        final imgPattern1 = RegexCache.instance.getOrCompile(
            r'<img([^>]*?)src=["]([^"]*?)"([^>]*?)>',
            caseSensitive: false);
        final imgPattern2 = RegexCache.instance.getOrCompile(
            r"<img([^>]*?)src=[']([^']*?)'([^>]*?)>",
            caseSensitive: false);

        processedContent =
            processedContent.replaceAllMapped(imgPattern1, (match) {
          final beforeSrc = match.group(1) ?? '';
          final imgSrc = match.group(2) ?? '';
          final afterSrc = match.group(3) ?? '';

          // 如果是相对URL，转换为绝对URL
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

          // 如果是相对URL，转换为绝对URL
          String absoluteSrc = imgSrc;
          if (imgSrc.isNotEmpty &&
              !imgSrc.startsWith('http') &&
              !imgSrc.startsWith('data:')) {
            absoluteSrc = NetworkService.joinUrl(baseUrl, imgSrc);
          }

          return "<img$beforeSrc src='$absoluteSrc'$afterSrc>";
        });

      }

      // 参考项目：如果内容包含 &，进行HTML解码
      // 参考项目：if (content.indexOf('&') > -1) { content = StringEscapeUtils.unescapeHtml4(content) }
      if (processedContent.contains('&')) {
        // 使用HTML解析器解码HTML实体
        // 注意：这里只解码常见的HTML实体，如 &amp; -> &, &lt; -> <, &gt; -> >
        processedContent = processedContent
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&#39;', "'")
            .replaceAll('&nbsp;', ' ');
        // 处理数字实体，如 &#123; 或 &#x1F;
        processedContent =
            processedContent.replaceAllMapped(RegexCache.instance.getOrCompile(r'&#(\d+);'), (match) {
          final code = int.tryParse(match.group(1) ?? '');
          if (code != null) {
            return String.fromCharCode(code);
          }
          return match.group(0) ?? '';
        });
        processedContent = processedContent
            .replaceAllMapped(RegexCache.instance.getOrCompile(r'&#x([0-9a-fA-F]+);'), (match) {
          final code = int.tryParse(match.group(1) ?? '', radix: 16);
          if (code != null) {
            return String.fromCharCode(code);
          }
          return match.group(0) ?? '';
        });

      }

      // 应用 imageStyle 规则（如果存在，在清理HTML之前应用）
      // 参考项目：imageStyle 用于设置图片样式，如宽度、高度等
      final imageStyleValue = rule.imageStyle;
      if (imageStyleValue != null && imageStyleValue.isNotEmpty) {
        try {
          // imageStyle 规则应该是一个CSS样式字符串，应用到所有img标签
          final imgPattern = RegexCache.instance.getOrCompile(r'<img([^>]*)>', caseSensitive: false);
          processedContent =
              processedContent.replaceAllMapped(imgPattern, (match) {
            final imgAttrs = match.group(1) ?? '';
            // 检查是否已经有style属性
            if (imgAttrs.contains('style=')) {
              // 如果已有style，追加新的样式
              return '<img$imgAttrs style="$imgAttrs;$imageStyleValue">';
            } else {
              // 如果没有style，添加新的样式
              return '<img$imgAttrs style="$imageStyleValue">';
            }
          });
        } catch (e) {
          AppLog.instance.put(
              'parseContentRule: imageStyle规则错误: $imageStyleValue',
              error: e);
        }
      }

      processedContent = HtmlParser.cleanHtml(processedContent);

      // 应用正则替换（书源规则中的替换）
      // 参考项目：replaceRegex是在所有页面内容合并后统一应用的，而不是每页单独应用
      // 如果applyReplaceRegex为false，跳过此步骤（在合并后统一处理）
      if (applyReplaceRegex &&
          rule.replaceRegex != null &&
          rule.replaceRegex!.isNotEmpty) {
        // 参考项目逻辑：先将内容按行分割并trim，应用替换规则，然后在每行前添加全角空格
        // 按行分割并trim每行
        final lines = processedContent.split('\n');
        processedContent = lines.map((line) => line.trim()).join('\n');

        // 应用replaceRegex规则
        processedContent =
            _applyReplaceRegexInternal(processedContent, rule.replaceRegex!);

        // 按行分割并在每行前添加全角空格（段落缩进）
        final processedLines = processedContent.split('\n');
        processedContent = processedLines.map((line) => '　　$line').join('\n');

      }

      // 清理多余空白
      processedContent = _cleanWhitespace(processedContent);

      // 应用全局替换规则（净化替换规则）
      // 如果提供了书籍信息，使用作用范围过滤规则
      try {
        List<ReplaceRule>? rules;
        if (bookName != null && bookOrigin != null) {
          rules =
              await readService(AppServices.replaceRuleService).getEnabledRulesByContentScope(
            bookName,
            bookOrigin,
          );
        }
        if (rules != null && rules.isNotEmpty) {
          processedContent = await readService(AppServices.replaceRuleService)
              .applyRules(processedContent, rules: rules);
        }
      } catch (e) {
        // 如果应用替换规则失败，继续使用原始内容
        AppLog.instance.put('parseContentRule: 应用全局替换规则失败', error: e);
      }

      return processedContent;
    } catch (e) {
      return null;
    }
  }

  // ── Phase 2：音视频专用解析方法（实现已迁移至 rule_parser_media.dart）────────

  /// 解析音视频章节辅助字段（Phase 3）
  ///
  /// 实现在 `rule_parser_media.dart` → [_RuleParserMedia.parseAudioExtras]
  static Future<Map<String, String?>> parseAudioExtras(
    String html,
    ContentRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) =>
      _RuleParserMedia.parseAudioExtras(html, rule,
          variables: variables, baseUrl: baseUrl);

  /// 执行 payAction（Phase 3 基础实现）
  ///
  /// 实现在 `rule_parser_media.dart` → [_RuleParserMedia.executePayAction]
  static Future<bool> executePayAction(
    String html,
    String payAction, {
    Map<String, String>? variables,
    BookSource? source,
    Book? book,
    String? baseUrl,
  }) =>
      _RuleParserMedia.executePayAction(html, payAction,
          variables: variables, source: source, book: book, baseUrl: baseUrl);

  /// 应用正则替换规则（公开方法，供外部调用）
  ///
  /// 支持格式：`##match##replace` 或 `##match##replace###`（只替换第一个）
  /// 实现在 `rule_parser_replace.dart` → [_RuleParserReplace.apply]
  static String applyReplaceRegex(String content, String replaceRule) =>
      _RuleParserReplace.apply(content, replaceRule);

  /// 内部正则替换（供类内调用，委托给 [_RuleParserReplace]）
  ///
  /// 主文件内有多处直接调用此私有方法（parseRule、parseContentRule 等），
  /// 通过此 shim 保持内部调用链完整，无需逐一修改。
  static String _applyReplaceRegexInternal(String content, String replaceRule) =>
      _RuleParserReplace.apply(content, replaceRule);

  /// 清理多余空白
  static String _cleanWhitespace(String text) {
    // 参考项目：清理多余空白，但保留换行符
    // 将多个连续空格/制表符替换为单个空格（但保留换行符）
    text = text.replaceAll(RegexCache.instance.getOrCompile(r'[ \t]+'), ' ');
    // 移除行首行尾空白（但保留换行符）
    text = text.replaceAll(RegexCache.instance.getOrCompile(r'^[ \t]+|[ \t]+$', multiLine: true), '');
    // 移除多余空行（连续多个换行符合并为一个）
    text = text.replaceAll(RegexCache.instance.getOrCompile(r'\n{3,}'), '\n\n');
    // 移除行首行尾的空白（包括换行符），但保留内容中的换行符
    return text.trim();
  }

  /// 解析JSONPath规则
  /// 参考项目：AnalyzeByJSonPath
  static String? _parseJsonPath(
    String html,
    String rule,
    String? baseUrl, {
    bool isUrl = false,
  }) {
    try {
      // 移除 @Json: 前缀
      if (rule.startsWith('@Json:') || rule.startsWith('@json:')) {
        rule = rule.substring(6).trim();
      }

      // 兼容部分 Legado 规则里常见的 `foo.[*]` 写法，json_path 包要求写成 `foo[*]`
      rule = rule.replaceAllMapped(
        RegExp(r'\.\[([^\]]+)\]'),
        (match) => '[${match.group(1)}]',
      );

      // 尝试解析HTML为JSON
      // 注意：这里需要判断HTML是否实际上是JSON
      dynamic jsonData;
      try {
        // 先尝试直接解析为JSON
        jsonData = jsonDecode(html);
      } catch (e) {
        // 如果不是JSON，尝试从HTML中提取JSON
        // 查找 <script> 标签中的JSON数据
        final scriptPattern =
            RegexCache.instance.getOrCompile(r'<script[^>]*>(.*?)</script>', dotAll: true);
        final matches = scriptPattern.allMatches(html);
        for (final match in matches) {
          final scriptContent = match.group(1)?.trim() ?? '';
          if (scriptContent.startsWith('{') || scriptContent.startsWith('[')) {
            try {
              jsonData = jsonDecode(scriptContent);
              break;
            } catch (e) {
              // 继续尝试下一个
            }
          }
        }
      }

      if (jsonData == null) {
        AppLog.instance.put('_parseJsonPath: 无法解析为JSON');
        return null;
      }

      // 使用json_path包解析JSONPath
      try {
        final jsonPath = JsonPath(rule);
        final results = jsonPath.readValues(jsonData);

        if (results.isEmpty) {
          AppLog.instance.put('_parseJsonPath: JSONPath未找到匹配结果: $rule');
          return null;
        }

        // 如果只有一个结果，返回字符串
        if (results.length == 1) {
          final value = results.first;
          if (value == null) return null;
          return value.toString();
        }

        // 多个结果，用换行符连接
        return results
            .map((v) => v?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .join('\n');
      } catch (e) {
        AppLog.instance.put('_parseJsonPath: JSONPath解析失败: $rule, 错误: $e');
        return null;
      }
    } catch (e) {
      AppLog.instance.put('_parseJsonPath: 解析失败: $e');
      return null;
    }
  }

  /// 执行 JavaScript 代码（公开方法，供外部调用）
  /// 参考项目：AnalyzeRule.evalJS
  ///
  /// 用于执行webJs、preUpdateJs等JavaScript代码
  static Future<String?> executeJs(
    String html,
    String jsCode, {
    Map<String, String>? variables,
    BookSource? source,
    Book? book,
    String? baseUrl,
    String? chapterTitle,
  }) async {
    return _executeJs(html, jsCode,
        variables: variables,
        source: source,
        book: book,
        baseUrl: baseUrl,
        chapterTitle: chapterTitle);
  }

  /// 执行 JavaScript 代码（内部方法）
  /// 参考项目：AnalyzeRule.evalJS
  ///
  /// 用于执行webJs等JavaScript代码
  static Future<String?> _executeJs(
    String html,
    String jsCode, {
    Map<String, String>? variables,
    BookSource? source,
    Book? book,
    String? baseUrl,
    String? chapterTitle,
  }) async {
    try {
      // 参考项目：evalJS(jsCode, result)
      // 提供全局对象：java, cookie, cache, source, book, result, baseUrl等
      final extensions = JSExtensions(
        source: source,
        book: book,
        baseUrl: baseUrl,
        chapterTitle: chapterTitle,
      );
      final jsBindings = extensions.createBindings();
      jsBindings['result'] = html;

      if (variables != null) {
        jsBindings.addAll(variables);
      }

      final jsResult = await JSEngine.evalJS(jsCode, bindings: jsBindings);
      if (jsResult != null) {
        return jsResult.toString();
      }
      return html;
    } catch (e) {
      AppLog.instance.put('_executeJs: JavaScript执行失败: $e');
      return html;
    }
  }

  /// 设置变量（供外部调用）
  static void setVariable(String key, String value) {
    _variables[key] = value;
  }

  /// 获取变量（供外部调用）
  static String? getVariable(String key) {
    return _variables[key];
  }

  /// 清除所有变量（供外部调用）
  static void clearVariables() {
    _variables.clear();
  }

  /// 解析发现规则
  static Future<List<Map<String, String?>>> parseExploreRule(
    String html,
    ExploreRule? rule, {
    Map<String, String>? variables,
    String? baseUrl,
  }) async {
    if (rule == null || rule.bookList == null) {
      return [];
    }

    final bookEntries = _parseListEntries(
      html,
      rule.bookList,
      variables: variables,
      baseUrl: baseUrl,
    );

    if (bookEntries.isEmpty) {
      return [];
    }

    final results = <Map<String, String?>>[];

    for (int i = 0; i < bookEntries.length; i++) {
      final bookHtml = bookEntries[i].content;
      final itemVariables = <String, String>{
        ...?variables,
        ...bookEntries[i].groups,
      };
      final originalItemVariables = Map<String, String>.from(itemVariables);

      final bookUrl = await _parseFieldRuleWithContext(
        bookHtml,
        rule.bookUrl,
        itemVariables,
        baseUrl: baseUrl,
        isUrl: true,
      );
      final nameRaw = await _parseFieldRuleWithContext(
        bookHtml,
        rule.name,
        itemVariables,
        baseUrl: baseUrl,
      );
      final authorRaw = await _parseFieldRuleWithContext(
        bookHtml,
        rule.author,
        itemVariables,
        baseUrl: baseUrl,
      );
      final kindRaw = await _parseFieldRuleWithContext(
        bookHtml,
        rule.kind,
        itemVariables,
        baseUrl: baseUrl,
      );
      String? kind = kindRaw?.trim();
      if (kind != null && kind.isNotEmpty && kind.contains('<')) {
        kind = HtmlParser.cleanHtml(kind).trim();
      }
      final wordCount = await _parseFieldRuleWithContext(
        bookHtml,
        rule.wordCount,
        itemVariables,
        baseUrl: baseUrl,
      );
      final lastChapter = await _parseFieldRuleWithContext(
        bookHtml,
        rule.lastChapter,
        itemVariables,
        baseUrl: baseUrl,
      );
      final intro = await _parseFieldRuleWithContext(
        bookHtml,
        rule.intro,
        itemVariables,
        baseUrl: baseUrl,
      );
      final coverUrl = await _parseFieldRuleWithContext(
        bookHtml,
        rule.coverUrl,
        itemVariables,
        baseUrl: baseUrl,
      );

      final name = nameRaw?.trim();
      final author = authorRaw?.trim();

      if ((name != null && name.isNotEmpty) ||
          (bookUrl != null && bookUrl.isNotEmpty)) {
        results.add({
          'name': name,
          'author': author,
          'kind': kind,
          'wordCount': wordCount,
          'lastChapter': lastChapter,
          'intro': intro,
          'coverUrl': coverUrl,
          'bookUrl': bookUrl, // 使用isUrl=true解析的结果
          'variable': _encodeTransientVariables(
            originalItemVariables,
            itemVariables,
          ),
        });
      }
    }

    return results;
  }
}
