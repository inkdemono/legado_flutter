/// 鸿蒙平台存储实现
/// 
/// 通过 MethodChannel 与鸿蒙原生层通信
/// 使用 ArkTS File Kit 进行文件操作

import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../interface/storage_interface.dart';

class HarmonyOSStorageImpl implements StorageInterface {
  static const _channel = MethodChannel('legado_harmony/storage');
  static const _fileChannel = MethodChannel('legado_harmony/file');

  @override
  Future<String> getAppDocumentsPath() async {
    try {
      final result = await _channel.invokeMethod<String>('getAppDocumentsPath');
      if (result == null) {
        throw Exception('获取应用文档路径失败');
      }
      return result;
    } on PlatformException catch (e) {
      throw Exception('获取应用文档路径失败：${e.message}');
    }
  }

  @override
  Future<String> getAppCachePath() async {
    try {
      final result = await _channel.invokeMethod<String>('getAppCachePath');
      if (result == null) {
        throw Exception('获取应用缓存路径失败');
      }
      return result;
    } on PlatformException catch (e) {
      throw Exception('获取应用缓存路径失败：${e.message}');
    }
  }

  @override
  Future<void> saveFile(String path, List<int> data) async {
    try {
      await _fileChannel.invokeMethod('saveFile', {
        'path': path,
        'data': Uint8List.fromList(data),
      });
    } on PlatformException catch (e) {
      throw Exception('保存文件失败 [$path]: ${e.message}');
    }
  }

  @override
  Future<List<int>> readFile(String path) async {
    try {
      final result = await _fileChannel.invokeMethod<Uint8List>('readFile', {
        'path': path,
      });
      if (result == null) {
        throw Exception('读取文件失败：文件为空');
      }
      return result.toList();
    } on PlatformException catch (e) {
      throw Exception('读取文件失败 [$path]: ${e.message}');
    }
  }

  @override
  Future<bool> deleteFile(String path) async {
    try {
      final result = await _fileChannel.invokeMethod<bool>('deleteFile', {
        'path': path,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('删除文件失败 [$path]: ${e.message}');
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    try {
      final result = await _fileChannel.invokeMethod<bool>('fileExists', {
        'path': path,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('检查文件存在性失败 [$path]: ${e.message}');
    }
  }

  @override
  Future<void> createDirectory(String path) async {
    try {
      await _fileChannel.invokeMethod('createDirectory', {
        'path': path,
      });
    } on PlatformException catch (e) {
      throw Exception('创建目录失败 [$path]: ${e.message}');
    }
  }

  @override
  Future<List<String>> listDirectory(String path) async {
    try {
      final result = await _fileChannel.invokeMethod<List<dynamic>>(
        'listDirectory',
        {'path': path},
      );
      return result?.cast<String>() ?? [];
    } on PlatformException catch (e) {
      throw Exception('列出目录内容失败 [$path]: ${e.message}');
    }
  }

  @override
  Future<void> copyFile(String sourcePath, String destPath) async {
    try {
      await _fileChannel.invokeMethod('copyFile', {
        'sourcePath': sourcePath,
        'destPath': destPath,
      });
    } on PlatformException catch (e) {
      throw Exception('复制文件失败 [$sourcePath -> $destPath]: ${e.message}');
    }
  }

  @override
  Future<void> moveFile(String sourcePath, String destPath) async {
    try {
      await _fileChannel.invokeMethod('moveFile', {
        'sourcePath': sourcePath,
        'destPath': destPath,
      });
    } on PlatformException catch (e) {
      throw Exception('移动文件失败 [$sourcePath -> $destPath]: ${e.message}');
    }
  }

  @override
  Future<int> getFileSize(String path) async {
    try {
      final result = await _fileChannel.invokeMethod<int>('getFileSize', {
        'path': path,
      });
      return result ?? 0;
    } on PlatformException catch (e) {
      throw Exception('获取文件大小失败 [$path]: ${e.message}');
    }
  }

  @override
  Future<DateTime> getLastModified(String path) async {
    try {
      final timestamp = await _fileChannel.invokeMethod<int>(
        'getLastModified',
        {'path': path},
      );
      if (timestamp == null) {
        throw Exception('获取文件修改时间失败');
      }
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } on PlatformException catch (e) {
      throw Exception('获取文件修改时间失败 [$path]: ${e.message}');
    }
  }
}
