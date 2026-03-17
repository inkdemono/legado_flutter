import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../utils/parsers/rule_parser.dart';
import '../utils/parsers/regex_cache.dart';

/// 规则解析器状态
class RuleParserState {
  final int regexCacheSize;

  const RuleParserState({
    required this.regexCacheSize,
  });

  RuleParserState copyWith({
    int? regexCacheSize,
  }) {
    return RuleParserState(
      regexCacheSize: regexCacheSize ?? this.regexCacheSize,
    );
  }
}

/// 规则解析器状态 Provider
final ruleParserProvider = NotifierProvider<RuleParserNotifier, RuleParserState>(() {
  return RuleParserNotifier();
});

/// 规则解析器通知器
class RuleParserNotifier extends Notifier<RuleParserState> {
  @override
  RuleParserState build() {
    return RuleParserState(
      regexCacheSize: RegexCache.instance.size,
    );
  }

  /// 清除所有缓存
  void clearAllCaches() {
    RegexCache.instance.clear();
    RuleParser.clearRuleFragmentCache();
    state = state.copyWith(regexCacheSize: 0);
  }

  /// 清除正则表达式缓存
  void clearRegexCache() {
    RegexCache.instance.clear();
    state = state.copyWith(regexCacheSize: 0);
  }

  /// 清除规则片段缓存
  void clearRuleFragmentCache() {
    RuleParser.clearRuleFragmentCache();
    // RuleParser doesn't expose cache size, so we don't update state here
  }

  /// 刷新状态（获取当前缓存大小）
  void refreshState() {
    state = state.copyWith(regexCacheSize: RegexCache.instance.size);
  }
}

/// 清除缓存的便捷方法Provider
final clearRuleParserCacheProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(ruleParserProvider.notifier).clearAllCaches();
  };
});
