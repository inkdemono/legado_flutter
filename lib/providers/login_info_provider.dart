import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/source/login_info_service.dart';
import 'service_registry.dart';

/// 登录信息服务 Provider
///
/// P1-1 首个迁移切片：将 UI 层对 LoginInfoService 的访问统一收口到 Riverpod。
final loginInfoServiceProvider = Provider<LoginInfoService>((ref) {
  return ref.watch(AppServices.loginInfoService);
});

/// 单个书源登录信息 Provider
class LoginInfoNotifier extends AsyncNotifier<Map<String, String>> {
  LoginInfoNotifier(this.sourceUrl);

  final String sourceUrl;
  LoginInfoService get _service => ref.read(loginInfoServiceProvider);

  @override
  Future<Map<String, String>> build() {
    return _service.getLoginInfo(sourceUrl);
  }

  Future<void> save(Map<String, String> loginData) async {
    await _service.saveLoginInfo(sourceUrl, loginData);
    state = AsyncValue.data(loginData);
  }

  Future<void> clear() async {
    await _service.clearLoginInfo(sourceUrl);
    state = const AsyncValue.data(<String, String>{});
  }
}

final loginInfoProvider =
    AsyncNotifierProvider.family<LoginInfoNotifier, Map<String, String>, String>(
  LoginInfoNotifier.new,
);

/// 登录信息操作 Provider
final loginInfoOperationsProvider = Provider<LoginInfoOperations>((ref) {
  return LoginInfoOperations(ref);
});

class LoginInfoOperations {
  LoginInfoOperations(this._ref);

  final Ref _ref;

  Future<Map<String, String>> getLoginInfo(String sourceUrl) async {
    return _ref.read(loginInfoServiceProvider).getLoginInfo(sourceUrl);
  }

  Future<void> saveLoginInfo(
    String sourceUrl,
    Map<String, String> loginData,
  ) async {
    await _ref.read(loginInfoProvider(sourceUrl).notifier).save(loginData);
  }

  Future<void> clearLoginInfo(String sourceUrl) async {
    await _ref.read(loginInfoProvider(sourceUrl).notifier).clear();
  }

  Future<void> clearAllLoginInfo() async {
    await _ref.read(loginInfoServiceProvider).clearAllLoginInfo();
  }
}
