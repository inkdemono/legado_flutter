import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/base/base_service.dart';
import '../../utils/app_log.dart';

/// 登录信息服务
/// 用于保存和获取书源的登录信息
class LoginInfoService extends BaseService {
  static final LoginInfoService instance = LoginInfoService._init();
  static const String _loginInfoPrefix = 'login_info_';

  LoginInfoService._init();

  /// 保存登录信息
  /// [sourceUrl] 书源URL
  /// [loginData] 登录数据（键值对）
  Future<void> saveLoginInfo(
      String sourceUrl, Map<String, String> loginData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_loginInfoPrefix${Uri.parse(sourceUrl).host}';
      await prefs.setString(key, jsonEncode(loginData));
    } catch (e) {
      AppLog.instance.put('保存书源登录信息失败: $sourceUrl', error: e);
    }
  }

  /// 获取登录信息
  /// [sourceUrl] 书源URL
  /// 返回登录数据（键值对），如果不存在则返回空Map
  Future<Map<String, String>> getLoginInfo(String sourceUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_loginInfoPrefix${Uri.parse(sourceUrl).host}';
      final loginInfoStr = prefs.getString(key);
      if (loginInfoStr != null) {
        final loginInfo = jsonDecode(loginInfoStr) as Map<String, dynamic>;
        return loginInfo.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (e) {
      AppLog.instance.put('读取书源登录信息失败: $sourceUrl', error: e);
    }
    return {};
  }

  /// 清除登录信息
  /// [sourceUrl] 书源URL
  Future<void> clearLoginInfo(String sourceUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_loginInfoPrefix${Uri.parse(sourceUrl).host}';
      await prefs.remove(key);
    } catch (e) {
      AppLog.instance.put('清除书源登录信息失败: $sourceUrl', error: e);
    }
  }

  /// 清除所有登录信息
  Future<void> clearAllLoginInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys =
          prefs.getKeys().where((key) => key.startsWith(_loginInfoPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      AppLog.instance.put('清除全部书源登录信息失败', error: e);
    }
  }
}
