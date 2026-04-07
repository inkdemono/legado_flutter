part of 'rule_parser.dart';

/// 通用规则解析实现。
///
/// 职责范围：
/// - 变量替换 / put-get 处理
/// - `parseRule` / `parseRuleAsync`
/// - 单规则解析与规则组合解析
class _RuleParserBase {
  _RuleParserBase._();

  static String processRule(
    String rule,
    Map<String, String> variables, {
    bool processPutGet = true,
  }) {
    String result = rule;

    if (processPutGet) {
      final putPattern = RegexCache.instance.getOrCompile(
        r'@put:\s*(\{[^}]+\})',
        caseSensitive: false,
      );
      result = result.replaceAllMapped(putPattern, (match) {
        try {
          final jsonStr = match.group(1)!;
          final keyValuePattern = RegexCache.instance.getOrCompile(
            r'"([^"]+)":\s*"([^"]*)"',
          );
          keyValuePattern.allMatches(jsonStr).forEach((m) {
            final key = m.group(1)!;
            final value = m.group(2) ?? '';
            RuleParser._variables[key] = value;
            variables[key] = value;
          });
        } catch (e) {
          AppLog.instance.put(
            '_processRule: 解析@put规则失败: $e',
            category: LogCategory.reader,
            tag: AppLogTag.parser,
          );
        }
        return '';
      });
    }

    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
      result = result.replaceAll('@{{$key}}', value);
    });

    if (processPutGet) {
      final getPattern = RegexCache.instance.getOrCompile(
        r'@get:\s*\{([^}]+)\}',
        caseSensitive: false,
      );
      result = result.replaceAllMapped(getPattern, (match) {
        final key = match.group(1)!.trim();
        return variables[key] ?? RuleParser._variables[key] ?? '';
      });
    }

    return result;
  }

  static String replaceVariables(String rule, Map<String, String>? variables) {
    if (variables == null || variables.isEmpty) return rule;

    String result = rule;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
      result = result.replaceAll('@{{$key}}', value);
    });
    return result;
  }

  static String replaceTemplateVariables(
    String rule,
    Map<String, String>? variables,
  ) {
    return replaceVariables(rule, variables);
  }

  static String? encodeTransientVariables(
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

  static String? parseRule(
    String html,
    String? rule, {
    String? baseUrl,
    Map<String, String>? variables,
    bool isUrl = false,
    bool allowRegexRule = false,
  }) {
    if (rule == null || rule.isEmpty) {
      if (isUrl && baseUrl != null) {
        return baseUrl;
      }
      return null;
    }

    if (rule.contains('{{') && rule.contains('}}')) {
      AppLog.instance.put(
        'parseRule: 警告 - 规则包含{{js}}代码，请使用parseRuleAsync',
        level: LogLevel.warning,
        category: LogCategory.reader,
        tag: AppLogTag.parser,
      );
    }

    try {
      final allVariables = <String, String>{...RuleParser._variables};
      if (variables != null) {
        allVariables.addAll(variables);
      }

      final processedRule = processRule(rule, allVariables);
      final analyzer = RuleAnalyzer(processedRule);
      final splitRules = analyzer.splitRule(['&&', '||', '%%']);
      final elementsType = analyzer.elementsType;

      if (splitRules.length > 1) {
        return parseRuleCombinationSync(
            html, splitRules, elementsType, baseUrl, allVariables,
            allowRegexRule: allowRegexRule, isUrl: isUrl);
      }

      return parseSingleRuleSync(html, processedRule, baseUrl, allVariables,
          allowRegexRule: allowRegexRule, isUrl: isUrl);
    } catch (e, stackTrace) {
      AppLog.instance.put(
        'parseRule: 解析失败',
        error: e,
        category: LogCategory.reader,
        tag: AppLogTag.parser,
      );
      AppLog.instance.put(
        'parseRule: 错误堆栈: $stackTrace',
        level: LogLevel.debug,
        category: LogCategory.reader,
        tag: AppLogTag.parser,
      );
      if (isUrl && baseUrl != null) {
        return baseUrl;
      }
      return null;
    }
  }

  static Future<String?> parseRuleAsync(
    String html,
    String? rule, {
    String? baseUrl,
    Map<String, String>? variables,
    bool isUrl = false,
    bool allowRegexRule = false,
  }) async {
    if (rule == null || rule.isEmpty) {
      if (isUrl && baseUrl != null) {
        return baseUrl;
      }
      return null;
    }

    try {
      final allVariables = <String, String>{...RuleParser._variables};
      if (variables != null) {
        allVariables.addAll(variables);
      }

      final processedRule = replaceTemplateVariables(rule, allVariables);
      final analyzer = RuleAnalyzer(processedRule);
      final splitRules = analyzer.splitRule(['&&', '||', '%%']);
      final elementsType = analyzer.elementsType;

      if (splitRules.length > 1) {
        return await parseRuleCombination(
            html, splitRules, elementsType, baseUrl, allVariables,
            allowRegexRule: allowRegexRule, isUrl: isUrl);
      }

      return await parseSingleRule(html, processedRule, baseUrl, allVariables,
          allowRegexRule: allowRegexRule, isUrl: isUrl);
    } catch (e, stackTrace) {
      AppLog.instance.put(
        '_parseRuleAsync: 解析失败',
        error: e,
        category: LogCategory.reader,
        tag: AppLogTag.parser,
      );
      AppLog.instance.put(
        '_parseRuleAsync: 错误堆栈: $stackTrace',
        level: LogLevel.debug,
        category: LogCategory.reader,
        tag: AppLogTag.parser,
      );
      if (isUrl && baseUrl != null) {
        return baseUrl;
      }
      return null;
    }
  }

  static String? parseSingleRuleSync(
    String html,
    String rule,
    String? baseUrl,
    Map<String, String> variables, {
    bool isUrl = false,
    bool allowRegexRule = false,
  }) {
    String? replaceRule;
    String actualRule = rule;

    if (rule.contains('##')) {
      final parts = rule.split('##');
      if (parts.length >= 3) {
        actualRule = parts[0];
        replaceRule = rule.substring(parts[0].length);
      }
    }

    String? result;
    String processedRule = actualRule;

    if (allowRegexRule && actualRule.startsWith(':') && actualRule.length > 1) {
      final afterColon = actualRule.substring(1).trim();
      final isPseudoClass = RegExp(r'^[a-zA-Z-]').hasMatch(afterColon);

      if (!isPseudoClass) {
        processedRule = afterColon;
        final regexList = processedRule
            .split('&&')
            .map((r) => r.trim())
            .where((r) => r.isNotEmpty)
            .toList();
        if (regexList.isNotEmpty) {
          final regexResult = AnalyzeByRegex.getElement(html, regexList);
          if (regexResult != null && regexResult.isNotEmpty) {
            result = regexResult.join('\n');
          }
        }
      } else {
        result = RuleParser._parseCss(html, actualRule, baseUrl, isUrl: isUrl);
      }
    } else if (actualRule.startsWith('@CSS:') ||
        actualRule.startsWith('@css:')) {
      processedRule = actualRule.substring(5).trim();
      result = RuleParser._parseCss(html, processedRule, baseUrl, isUrl: isUrl);
    } else if (actualRule.startsWith('@@')) {
      processedRule = actualRule.substring(2);
      result = RuleParser._parseCss(html, processedRule, baseUrl, isUrl: isUrl);
    } else if (actualRule.startsWith('@XPath:') ||
        actualRule.startsWith('@xpath:')) {
      processedRule = actualRule.substring(7).trim();
      result =
          RuleParser._parseXPath(html, processedRule, baseUrl, isUrl: isUrl);
    } else if (actualRule.startsWith('@Json:') ||
        actualRule.startsWith('@json:')) {
      processedRule = actualRule.substring(6).trim();
      result =
          RuleParser._parseJsonPath(html, processedRule, baseUrl, isUrl: isUrl);
    } else if (processedRule.startsWith('//') ||
        processedRule.startsWith('/')) {
      result =
          RuleParser._parseXPath(html, processedRule, baseUrl, isUrl: isUrl);
    } else if (processedRule.startsWith(r'$.') ||
        processedRule.startsWith(r'$[')) {
      result =
          RuleParser._parseJsonPath(html, processedRule, baseUrl, isUrl: isUrl);
    } else {
      result = RuleParser._parseCss(html, processedRule, baseUrl, isUrl: isUrl);
    }

    if (isUrl && (result == null || result.isEmpty) && baseUrl != null) {
      result = baseUrl;
    }

    if (result != null && replaceRule != null && replaceRule.isNotEmpty) {
      result = RuleParser._applyReplaceRegexInternal(result, replaceRule);
    }

    return result;
  }

  static Future<String?> parseSingleRule(
    String html,
    String rule,
    String? baseUrl,
    Map<String, String> variables, {
    bool isUrl = false,
    bool allowRegexRule = false,
  }) async {
    String? replaceRule;
    String actualRule = rule;

    if (rule.contains('##')) {
      final parts = rule.split('##');
      if (parts.length >= 3) {
        actualRule = parts[0];
        replaceRule = rule.substring(parts[0].length);
      }
    }

    final hasExplicitJs = actualRule.contains('<js>') ||
        actualRule.contains('</js>') ||
        actualRule.toLowerCase().contains('@js:');

    if (!hasExplicitJs) {
      if (actualRule.contains('{{') && actualRule.contains('}}')) {
        String processedRule = actualRule;
        bool hasJsCode = false;
        final varPattern = RegexCache.instance.getOrCompile(r'\{\{([^}]+)\}\}');
        for (final match in varPattern.allMatches(actualRule)) {
          final key = match.group(1)?.trim();
          if (key != null && variables.containsKey(key)) {
            processedRule =
                processedRule.replaceAll(match.group(0)!, variables[key]!);
          } else {
            hasJsCode = true;
            break;
          }
        }

        if (!hasJsCode) {
          actualRule = processedRule;
        }
      } else {
        final processedNonJsRule = processRule(actualRule, variables);
        final putGetLiteral = RuleParser._resolvePutGetLiteral(
          actualRule,
          processedNonJsRule,
          baseUrl: baseUrl,
          isUrl: isUrl,
        );
        if (putGetLiteral != null) {
          return putGetLiteral;
        }
        return parseSingleRuleSync(
          html,
          processedNonJsRule,
          baseUrl,
          variables,
          allowRegexRule: allowRegexRule,
          isUrl: isUrl,
        );
      }
    }

    final jsPattern = RegexCache.instance.getOrCompile(
      r'<js>([\w\W]*?)</js>|@js:([\w\W]*)|(?<!\\)\{\{([\w\W]*?)\}\}',
      caseSensitive: false,
    );

    final canUseCache = !actualRule.contains('{{');
    List<_RuleFragment> ruleFragments;

    if (canUseCache && RuleParser._ruleFragmentCache.containsKey(actualRule)) {
      ruleFragments = RuleParser._ruleFragmentCache[actualRule]!;
    } else {
      ruleFragments = <_RuleFragment>[];
      int lastEnd = 0;

      for (final match in jsPattern.allMatches(actualRule)) {
        if (match.start > lastEnd) {
          final normalRule = actualRule.substring(lastEnd, match.start).trim();
          if (normalRule.isNotEmpty) {
            ruleFragments.add(_RuleFragment(
              type: _RuleFragmentType.normal,
              content: normalRule,
            ));
          }
        }

        String? jsCode;
        if (match.group(1) != null) {
          jsCode = match.group(1);
        } else if (match.group(2) != null) {
          jsCode = match.group(2);
        } else if (match.group(3) != null) {
          final key = match.group(3)?.trim();
          if (key != null && variables.containsKey(key)) {
            ruleFragments.add(_RuleFragment(
              type: _RuleFragmentType.normal,
              content: variables[key]!,
            ));
            lastEnd = match.end;
            continue;
          } else {
            jsCode = match.group(3);
          }
        }

        if (jsCode != null && jsCode.isNotEmpty) {
          if (match.group(2) != null) {
            jsCode = processRule(
              replaceTemplateVariables(jsCode, variables),
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

      if (lastEnd < actualRule.length) {
        final normalRule = actualRule.substring(lastEnd).trim();
        if (normalRule.isNotEmpty) {
          ruleFragments.add(_RuleFragment(
            type: _RuleFragmentType.normal,
            content: normalRule,
          ));
        }
      }

      if (canUseCache) {
        if (RuleParser._ruleFragmentCache.length >=
            RuleParser._maxRuleFragmentCacheSize) {
          RuleParser._ruleFragmentCache
              .remove(RuleParser._ruleFragmentCache.keys.first);
        }
        RuleParser._ruleFragmentCache[actualRule] = List.from(ruleFragments);
      }
    }

    if (ruleFragments.isEmpty) {
      return parseSingleRuleSync(
        html,
        processRule(actualRule, variables),
        baseUrl,
        variables,
        allowRegexRule: allowRegexRule,
        isUrl: isUrl,
      );
    }

    dynamic result = html;
    final hasJsInRule =
        ruleFragments.any((f) => f.type == _RuleFragmentType.javascript);

    for (final fragment in ruleFragments) {
      if (result == null) break;

      try {
        if (fragment.type == _RuleFragmentType.javascript) {
          final jsResult = await RuleParser._executeJs(
            result.toString(),
            fragment.content,
            baseUrl: baseUrl,
            variables: variables,
          );
          result = jsResult ?? result.toString();
        } else {
          final ruleStr = fragment.content;
          if (ruleStr.isEmpty) continue;

          final processedFragmentRule = processRule(ruleStr, variables);
          if (processedFragmentRule.isEmpty) continue;

          String actualRuleStr = processedFragmentRule;
          bool forceCss = false;

          if (allowRegexRule &&
              actualRuleStr.startsWith(':') &&
              actualRuleStr.length > 1) {
            final afterColon = actualRuleStr.substring(1).trim();
            final isPseudoClass = RegExp(r'^[a-zA-Z-]').hasMatch(afterColon);

            if (!isPseudoClass) {
              actualRuleStr = afterColon;
              final regexList = actualRuleStr
                  .split('&&')
                  .map((r) => r.trim())
                  .where((r) => r.isNotEmpty)
                  .toList();
              if (regexList.isNotEmpty) {
                final regexResult =
                    AnalyzeByRegex.getElement(result.toString(), regexList);
                result = (regexResult != null && regexResult.isNotEmpty)
                    ? regexResult.join('\n')
                    : null;
              }
              if (result == null || (result is String && result.isEmpty)) {
                continue;
              }
              continue;
            }
          } else if (actualRuleStr.startsWith('@CSS:') ||
              actualRuleStr.startsWith('@css:')) {
            actualRuleStr = actualRuleStr.substring(5).trim();
            forceCss = true;
          } else if (actualRuleStr.startsWith('@@')) {
            actualRuleStr = actualRuleStr.substring(2);
            forceCss = true;
          } else if (actualRuleStr.startsWith('@XPath:') ||
              actualRuleStr.startsWith('@xpath:')) {
            actualRuleStr = actualRuleStr.substring(7).trim();
            result = RuleParser._parseXPath(
                result.toString(), actualRuleStr, baseUrl,
                isUrl: isUrl);
            if (result == null || (result is String && result.isEmpty)) {
              continue;
            }
            continue;
          } else if (actualRuleStr.startsWith('@Json:') ||
              actualRuleStr.startsWith('@json:')) {
            actualRuleStr = actualRuleStr.substring(6).trim();
            result = RuleParser._parseJsonPath(
                result.toString(), actualRuleStr, baseUrl,
                isUrl: isUrl);
            if (result == null || (result is String && result.isEmpty)) {
              continue;
            }
            continue;
          }

          if (forceCss ||
              !actualRuleStr.startsWith('//') &&
                  !actualRuleStr.startsWith('/')) {
            if (actualRuleStr.startsWith(r'$.') ||
                actualRuleStr.startsWith(r'$[')) {
              result = RuleParser._parseJsonPath(
                  result.toString(), actualRuleStr, baseUrl,
                  isUrl: isUrl);
            } else {
              final shouldAutoJoinUrl = isUrl && !hasJsInRule;
              result = RuleParser._parseCss(
                  result.toString(), actualRuleStr, baseUrl,
                  isUrl: shouldAutoJoinUrl);
            }
          } else {
            result = RuleParser._parseXPath(
                result.toString(), actualRuleStr, baseUrl,
                isUrl: isUrl);
          }

          if (result == null || (result is String && result.isEmpty)) {
            continue;
          }
        }
      } catch (e) {
        AppLog.instance
            .put('_parseSingleRule: 规则片段执行失败: ${fragment.content}', error: e);
        continue;
      }
    }

    if (isUrl &&
        (result == null || (result is String && result.isEmpty)) &&
        baseUrl != null) {
      result = baseUrl;
    }

    if (result != null && replaceRule != null && replaceRule.isNotEmpty) {
      result =
          RuleParser._applyReplaceRegexInternal(result.toString(), replaceRule);
    }

    return result?.toString();
  }

  static String? parseRuleCombinationSync(
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
      final result = parseSingleRuleSync(html, rule.trim(), baseUrl, variables,
          allowRegexRule: allowRegexRule, isUrl: isUrl);
      if (result != null && result.isNotEmpty) {
        results.add(result);
        if (elementsType == '||') {
          return result;
        }
      }
    }

    if (results.isEmpty) {
      return null;
    }

    if (elementsType == '&&') {
      return results.join('\n');
    }

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

    return results.join('\n');
  }

  static Future<String?> parseRuleCombination(
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
      final result = await parseSingleRule(
          html, rule.trim(), baseUrl, variables,
          allowRegexRule: allowRegexRule, isUrl: isUrl);
      if (result != null && result.isNotEmpty) {
        results.add(result);
        if (elementsType == '||') {
          return result;
        }
      }
    }

    if (results.isEmpty) {
      return null;
    }

    if (elementsType == '&&') {
      return results.join('\n');
    }

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

    return results.join('\n');
  }
}
