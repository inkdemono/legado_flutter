import 'package:flutter_opencc_ffi_native/flutter_opencc_ffi_native.dart';
import 'package:flutter_opencc_ffi_platform_interface/flutter_opencc_ffi_platform_interface.dart';
import 'dart:io';
import 'app_log.dart';

/// 简繁转换工具类
/// 参考项目：ChineseUtils.kt
/// 
/// 参考项目使用了 `quick-chinese-transfer` 库
/// 当前项目使用 `flutter_opencc_ffi_native` 实现简繁转换
/// 
/// OpenCC 支持多种转换模式：
/// - s2t.json: 简体转繁体
/// - t2s.json: 繁体转简体
/// - s2tw.json: 简体转台湾繁体
/// - s2hk.json: 简体转香港繁体
/// - s2twp.json: 简体转台湾繁体（短语）
/// - t2tw.json: 繁体转台湾繁体
/// - tw2s.json: 台湾繁体转简体
/// - tw2sp.json: 台湾繁体转简体（短语）
/// - hk2s.json: 香港繁体转简体
/// - t2hk.json: 繁体转香港繁体
class ChineseUtils {
  static bool _initialized = false;
  static bool _available = true;
  static bool _loggedUnavailable = false;
  static dynamic _s2tConverter;
  static dynamic _t2sConverter;
  static const List<String> _configCandidates = [
    's2t.json',
    't2s.json',
  ];

  static void _markUnavailable([Object? error]) {
    _available = false;
    _initialized = true;
    if (!_loggedUnavailable) {
      _loggedUnavailable = true;
      if (error != null) {
        AppLog.instance.put('OpenCC 配置不可用，已跳过简繁转换初始化', error: error);
      } else {
        AppLog.instance.put('OpenCC 配置不可用，已跳过简繁转换初始化');
      }
    }
  }

  static String? _resolveConfigPath(String fileName) {
    final file = File(fileName);
    if (file.existsSync()) {
      return file.path;
    }
    return null;
  }

  /// 初始化 OpenCC
  static Future<void> _initialize() async {
    if (_initialized) return;
    
    try {
      final s2tPath = _resolveConfigPath(_configCandidates[0]);
      final t2sPath = _resolveConfigPath(_configCandidates[1]);
      if (s2tPath == null || t2sPath == null) {
        _markUnavailable();
        return;
      }

      // 注册平台实现
      FlutterOpenccFfi.registerPlatform();
      
      // 创建转换器
      _s2tConverter = FlutterOpenccFfiPlatform.instance.createConverter(s2tPath);
      _t2sConverter = FlutterOpenccFfiPlatform.instance.createConverter(t2sPath);
      
      _initialized = true;
    } catch (e) {
      _markUnavailable(e);
    }
  }

  /// 简体转繁体
  /// 参考项目：ChineseUtils.s2t
  static Future<String> s2t(String content) async {
    if (content.isEmpty) return content;
    
    try {
      await _initialize();
      if (!_available) return content;
      if (_s2tConverter != null) {
        return _s2tConverter!.convert(content);
      }
      return content;
    } catch (e) {
      AppLog.instance.put('简体转繁体失败', error: e);
      return content;
    }
  }

  /// 繁体转简体
  /// 参考项目：ChineseUtils.t2s
  static Future<String> t2s(String content) async {
    if (content.isEmpty) return content;
    
    try {
      await _initialize();
      if (!_available) return content;
      if (_t2sConverter != null) {
        return _t2sConverter!.convert(content);
      }
      return content;
    } catch (e) {
      AppLog.instance.put('繁体转简体失败', error: e);
      return content;
    }
  }

  /// 简体转繁体（同步版本，用于兼容现有代码）
  /// 注意：由于 OpenCC 是异步的，同步版本会立即返回原内容
  /// 实际转换应该在异步方法中进行
  static String s2tSync(String content) {
    if (content.isEmpty) return content;
    
    // 同步版本暂时返回原内容
    // 如果需要真正的同步转换，可以考虑使用其他方案
    // 或者将调用处改为异步
    return content;
  }

  /// 繁体转简体（同步版本，用于兼容现有代码）
  /// 注意：由于 OpenCC 是异步的，同步版本会立即返回原内容
  /// 实际转换应该在异步方法中进行
  static String t2sSync(String content) {
    if (content.isEmpty) return content;
    
    // 同步版本暂时返回原内容
    // 如果需要真正的同步转换，可以考虑使用其他方案
    // 或者将调用处改为异步
    return content;
  }

  /// 预加载转换字典（可选）
  /// 参考项目：ChineseUtils.preLoad
  static Future<void> preLoad({bool async = false}) async {
    if (!_available) return;
    await _initialize();
  }

  /// 卸载转换字典（可选）
  /// 参考项目：ChineseUtils.unLoad
  static void unLoad() {
    _s2tConverter?.dispose();
    _t2sConverter?.dispose();
    _s2tConverter = null;
    _t2sConverter = null;
    _initialized = false;
    _available = true;
    _loggedUnavailable = false;
  }
}
