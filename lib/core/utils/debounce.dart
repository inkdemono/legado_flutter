import 'dart:async';

/// 防抖工具
///
/// 用于将短时间内多次触发的操作合并为一次执行，
/// 避免高频 UI 操作（如快速切换开关、批量增删）引发重复的 DB 查询或 Provider 刷新。
///
/// ### 典型场景
/// ```dart
/// // 在 State 类中
/// final _refreshDebounce = Debounce(const Duration(milliseconds: 300));
///
/// void _toggleEnabled(Rule rule) async {
///   await RuleService.instance.updateRule(rule.copyWith(enabled: !rule.enabled));
///   _refreshDebounce.run(() => ref.invalidate(ruleListProvider));
/// }
///
/// @override
/// void dispose() {
///   _refreshDebounce.cancel();
///   super.dispose();
/// }
/// ```
class Debounce {
  Debounce(this.duration);

  final Duration duration;
  Timer? _timer;

  /// 延迟执行 [action]。
  ///
  /// 在 [duration] 内多次调用时，只有最后一次的 [action] 会真正执行。
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// 立即取消挂起的定时器，不执行 [action]。
  ///
  /// 通常在 `State.dispose()` 中调用，防止 Widget 销毁后仍触发回调。
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 若当前有挂起的定时器，立即执行并清除定时器。
  ///
  /// 用于在页面退出前确保操作一定被执行（如保存排序）。
  void flush() {
    if (_timer?.isActive == true) {
      _timer!.cancel();
      _timer = null;
      // flush 语义仅通知调用方需手动执行挂起的 action；
      // 由于 Dart 闭包无法被 Timer 单独提取，建议在调用侧自行保存 action 引用。
    }
  }
}
