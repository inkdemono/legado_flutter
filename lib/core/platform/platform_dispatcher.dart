/// 平台分发器
/// 
/// 根据运行平台自动选择对应的实现
/// 支持 Android、iOS 和 HarmonyOS

import 'dart:io' show Platform;
import '../interface/storage_interface.dart';
import '../interface/database_interface.dart';
import 'harmonyos/storage_impl.dart';
import 'harmonyos/database_impl.dart';

/// 平台类型枚举
enum PlatformType {
  android,
  ios,
  harmonyos,
  web,
  desktop,
  unknown,
}

/// 平台分发器单例
class PlatformDispatcher {
  static final PlatformDispatcher _instance = PlatformDispatcher._internal();
  
  factory PlatformDispatcher() {
    return _instance;
  }

  PlatformDispatcher._internal();

  /// 检测当前平台类型
  static PlatformType get currentPlatform {
    // 检测鸿蒙平台
    if (_isHarmonyOS()) {
      return PlatformType.harmonyos;
    }
    
    // 检测 Android
    if (Platform.isAndroid) {
      return PlatformType.android;
    }
    
    // 检测 iOS
    if (Platform.isIOS) {
      return PlatformType.ios;
    }
    
    // 检测 Web
    if (Platform.isWeb) {
      return PlatformType.web;
    }
    
    // 检测桌面平台
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return PlatformType.desktop;
    }
    
    return PlatformType.unknown;
  }

  /// 检测是否为鸿蒙平台
  static bool _isHarmonyOS() {
    // 通过环境变量检测
    if (Platform.environment['HARMONY'] == 'true') {
      return true;
    }
    
    // 通过系统属性检测（如果可用）
    try {
      final osName = Platform.operatingSystem;
      if (osName.toLowerCase().contains('harmony') ||
          osName.toLowerCase().contains('ohos')) {
        return true;
      }
    } catch (_) {
      // 忽略异常
    }
    
    return false;
  }

  /// 获取存储实现
  StorageInterface get storage {
    switch (currentPlatform) {
      case PlatformType.android:
        return _getAndroidStorage();
      case PlatformType.ios:
        return _getIOSStorage();
      case PlatformType.harmonyos:
        return HarmonyOSStorageImpl();
      case PlatformType.web:
        return _getWebStorage();
      case PlatformType.desktop:
        return _getDesktopStorage();
      default:
        throw UnsupportedError(
          '不支持的平台：${Platform.operatingSystem}',
        );
    }
  }

  /// 获取数据库实现
  DatabaseInterface get database {
    switch (currentPlatform) {
      case PlatformType.android:
        return _getAndroidDatabase();
      case PlatformType.ios:
        return _getIOSDatabase();
      case PlatformType.harmonyos:
        return HarmonyOSDatabaseImpl();
      case PlatformType.web:
        return _getWebDatabase();
      case PlatformType.desktop:
        return _getDesktopDatabase();
      default:
        throw UnsupportedError(
          '不支持的平台：${Platform.operatingSystem}',
        );
    }
  }

  /// 获取 Android 存储实现
  StorageInterface _getAndroidStorage() {
    // TODO: 实现 Android 版本
    throw UnimplementedError('Android 存储实现待完成');
  }

  /// 获取 iOS 存储实现
  StorageInterface _getIOSStorage() {
    // TODO: 实现 iOS 版本
    throw UnimplementedError('iOS 存储实现待完成');
  }

  /// 获取 Web 存储实现
  StorageInterface _getWebStorage() {
    // TODO: 实现 Web 版本 (使用 IndexedDB)
    throw UnimplementedError('Web 存储实现待完成');
  }

  /// 获取桌面存储实现
  StorageInterface _getDesktopStorage() {
    // TODO: 实现桌面版本
    throw UnimplementedError('桌面存储实现待完成');
  }

  /// 获取 Android 数据库实现
  DatabaseInterface _getAndroidDatabase() {
    // TODO: 实现 Android 版本 (使用 sqflite)
    throw UnimplementedError('Android 数据库实现待完成');
  }

  /// 获取 iOS 数据库实现
  DatabaseInterface _getIOSDatabase() {
    // TODO: 实现 iOS 版本 (使用 sqflite)
    throw UnimplementedError('iOS 数据库实现待完成');
  }

  /// 获取 Web 数据库实现
  DatabaseInterface _getWebDatabase() {
    // TODO: 实现 Web 版本 (使用 IndexedDB)
    throw UnimplementedError('Web 数据库实现待完成');
  }

  /// 获取桌面数据库实现
  DatabaseInterface _getDesktopDatabase() {
    // TODO: 实现桌面版本 (使用 sqlite3)
    throw UnimplementedError('桌面数据库实现待完成');
  }

  /// 是否为移动平台
  bool get isMobile {
    return currentPlatform == PlatformType.android ||
        currentPlatform == PlatformType.ios ||
        currentPlatform == PlatformType.harmonyos;
  }

  /// 是否为桌面平台
  bool get isDesktop {
    return currentPlatform == PlatformType.desktop;
  }

  /// 是否为 Web 平台
  bool get isWeb {
    return currentPlatform == PlatformType.web;
  }

  /// 是否需要原生桥接
  bool get needsNativeBridge {
    return isMobile || isDesktop;
  }
}

/// 便捷访问器
final platformDispatcher = PlatformDispatcher();

/// 获取当前平台类型
PlatformType get currentPlatform => PlatformDispatcher.currentPlatform;

/// 是否为鸿蒙平台
bool get isHarmonyOS => currentPlatform == PlatformType.harmonyos;
