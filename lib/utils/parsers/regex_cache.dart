/// 正则表达式缓存
/// 避免重复编译相同的正则表达式，提高性能
class RegexCache {
  static final RegexCache instance = RegexCache._init();
  RegexCache._init();

  final Map<String, RegExp> _cache = {};
  static const int _maxSize = 100;

  /// 获取或编译正则表达式
  /// [pattern] 正则表达式模式
  /// [multiLine] 是否多行模式
  /// [caseSensitive] 是否区分大小写
  /// [dotAll] 是否允许 . 匹配换行符
  RegExp getOrCompile(
    String pattern, {
    bool multiLine = false,
    bool caseSensitive = true,
    bool dotAll = false,
  }) {
    final key = '$pattern|$multiLine|$caseSensitive|$dotAll';

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // 如果缓存已满，移除最早添加的项
    if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }

    return _cache[key] = RegExp(
      pattern,
      multiLine: multiLine,
      caseSensitive: caseSensitive,
      dotAll: dotAll,
    );
  }

  /// 清除所有缓存
  void clear() {
    _cache.clear();
  }

  /// 获取缓存大小
  int get size => _cache.length;

  /// 检查缓存是否包含指定的正则表达式
  bool contains(
    String pattern, {
    bool multiLine = false,
    bool caseSensitive = true,
    bool dotAll = false,
  }) {
    final key = '$pattern|$multiLine|$caseSensitive|$dotAll';
    return _cache.containsKey(key);
  }

  /// 移除指定的正则表达式
  void remove(
    String pattern, {
    bool multiLine = false,
    bool caseSensitive = true,
    bool dotAll = false,
  }) {
    final key = '$pattern|$multiLine|$caseSensitive|$dotAll';
    _cache.remove(key);
  }
}
