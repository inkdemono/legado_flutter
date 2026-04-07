import 'dart:async';
import 'package:flutter/widgets.dart';

/// 自动管理 StreamSubscription 生命周期的 Mixin
///
/// 消除 StatefulWidget 中反复出现的手动订阅/取消样板代码。
///
/// ### 问题场景
/// 不使用此 Mixin 时，每个需要监听 Stream 的 Widget 都要：
/// - 声明多个 `StreamSubscription?` 字段
/// - 在 `initState` 里调用 `stream.listen(...)` 并保存引用
/// - 在 `dispose` 里对每个引用调用 `?.cancel()`
///
/// 忘记 `cancel` 会导致内存泄漏，Widget 销毁后仍会收到回调。
///
/// ### 使用方式
/// ```dart
/// class _MyPageState extends State<MyPage>
///     with AutoDisposeSubscriptionMixin {
///
///   @override
///   void initState() {
///     super.initState();
///     // 不需要保存引用，mixin 自动管理
///     listenStream(audioService.positionStream, (pos) {
///       setState(() => _position = pos);
///     });
///     listenStream(networkService.statusStream, (status) {
///       setState(() => _isOnline = status.isOnline);
///     });
///   }
///
///   // 不需要手写 dispose — mixin 自动 cancel 所有订阅
/// }
/// ```
///
/// ### 与 Riverpod 的关系
/// 若已使用 `ref.listen(...)` 监听 Provider，无需此 Mixin。
/// 此 Mixin 用于监听原生 Dart `Stream`（非 Riverpod Provider）的场景。
mixin AutoDisposeSubscriptionMixin<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// 订阅 [stream] 并在 Widget 销毁时自动取消。
  ///
  /// 返回 [StreamSubscription] 以便调用方可选地调用 `pause`/`resume`，
  /// 但无需手动调用 `cancel`。
  ///
  /// [onData]   收到数据时的回调
  /// [onError]  可选错误处理；未提供时错误会被忽略
  /// [onDone]   可选完成回调
  /// [cancelOnError] 错误时是否自动取消（默认 false）
  StreamSubscription<E> listenStream<E>(
    Stream<E> stream,
    void Function(E) onData, {
    Function? onError,
    void Function()? onDone,
    bool cancelOnError = false,
  }) {
    final sub = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(sub);
    return sub;
  }

  /// 手动取消某个订阅（并从托管列表中移除）。
  ///
  /// 通常不需要手动调用，`dispose` 会自动清理全部订阅。
  /// 仅在需要提前取消（如切换数据源）时使用。
  void cancelSubscription(StreamSubscription<dynamic> sub) {
    sub.cancel();
    _subscriptions.remove(sub);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
