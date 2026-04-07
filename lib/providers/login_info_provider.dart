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
final loginInfoProvider =
    FutureProvider.family<Map<String, String>, String>((ref, sourceUrl) async {
  final service = ref.read(loginInfoServiceProvider);
  return service.getLoginInfo(sourceUrl);
});

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
    await _ref
        .read(loginInfoServiceProvider)
        .saveLoginInfo(sourceUrl, loginData);
    _ref.invalidate(loginInfoProvider(sourceUrl));
  }

  Future<void> clearLoginInfo(String sourceUrl) async {
    await _ref.read(loginInfoServiceProvider).clearLoginInfo(sourceUrl);
    _ref.invalidate(loginInfoProvider(sourceUrl));
  }

  Future<void> clearAllLoginInfo() async {
    await _ref.read(loginInfoServiceProvider).clearAllLoginInfo();
  }
}
