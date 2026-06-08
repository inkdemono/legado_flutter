/// 鸿蒙平台数据库实现
/// 
/// 通过 MethodChannel 与鸿蒙原生层通信
/// 使用 ArkTS 关系型数据库 (RDB) 进行数据操作

import 'package:flutter/services.dart';
import '../interface/database_interface.dart';

class HarmonyOSDatabaseImpl implements DatabaseInterface {
  static const _channel = MethodChannel('legado_harmony/database');
  
  String? _dbPath;
  bool _isOpen = false;

  @override
  Future<void> openDatabase(String path) async {
    try {
      await _channel.invokeMethod('openDatabase', {'path': path});
      _dbPath = path;
      _isOpen = true;
    } on PlatformException catch (e) {
      throw Exception('打开数据库失败 [$path]: ${e.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    _checkOpen();
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('query', {
        'sql': sql,
        'arguments': arguments ?? [],
      });
      return result
          ?.map((item) => Map<String, dynamic>.from(item as Map))
          .toList() ??
          [];
    } on PlatformException catch (e) {
      throw Exception('执行查询失败：${e.message}');
    }
  }

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
  }) async {
    _checkOpen();
    try {
      final result = await _channel.invokeMethod<int>('insert', {
        'table': table,
        'values': values,
        'nullColumnHack': nullColumnHack,
      });
      return result ?? 0;
    } on PlatformException catch (e) {
      throw Exception('插入数据失败：${e.message}');
    }
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    _checkOpen();
    try {
      final result = await _channel.invokeMethod<int>('update', {
        'table': table,
        'values': values,
        'where': where,
        'whereArgs': whereArgs ?? [],
      });
      return result ?? 0;
    } on PlatformException catch (e) {
      throw Exception('更新数据失败：${e.message}');
    }
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    _checkOpen();
    try {
      final result = await _channel.invokeMethod<int>('delete', {
        'table': table,
        'where': where,
        'whereArgs': whereArgs ?? [],
      });
      return result ?? 0;
    } on PlatformException catch (e) {
      throw Exception('删除数据失败：${e.message}');
    }
  }

  @override
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    _checkOpen();
    try {
      await _channel.invokeMethod('execute', {
        'sql': sql,
        'arguments': arguments ?? [],
      });
    } on PlatformException catch (e) {
      throw Exception('执行 SQL 失败：${e.message}');
    }
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    _checkOpen();
    try {
      await _channel.invokeMethod('beginTransaction');
      try {
        final result = await action();
        await _channel.invokeMethod('commitTransaction');
        return result;
      } catch (e) {
        await _channel.invokeMethod('rollbackTransaction');
        rethrow;
      }
    } on PlatformException catch (e) {
      throw Exception('执行事务失败：${e.message}');
    }
  }

  @override
  Future<void> close() async {
    if (!_isOpen) return;
    try {
      await _channel.invokeMethod('closeDatabase');
      _isOpen = false;
      _dbPath = null;
    } on PlatformException catch (e) {
      throw Exception('关闭数据库失败：${e.message}');
    }
  }

  @override
  Future<bool> tableExists(String tableName) async {
    _checkOpen();
    try {
      final result = await _channel.invokeMethod<bool>('tableExists', {
        'tableName': tableName,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('检查表存在性失败：${e.message}');
    }
  }

  @override
  Future<int> getVersion() async {
    _checkOpen();
    try {
      final result = await _channel.invokeMethod<int>('getVersion');
      return result ?? 0;
    } on PlatformException catch (e) {
      throw Exception('获取数据库版本失败：${e.message}');
    }
  }

  @override
  Future<void> setVersion(int version) async {
    _checkOpen();
    try {
      await _channel.invokeMethod('setVersion', {'version': version});
    } on PlatformException catch (e) {
      throw Exception('设置数据库版本失败：${e.message}');
    }
  }

  void _checkOpen() {
    if (!_isOpen) {
      throw Exception('数据库未打开，请先调用 openDatabase()');
    }
  }
}
