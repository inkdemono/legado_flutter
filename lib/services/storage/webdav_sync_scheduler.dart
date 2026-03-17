import 'dart:async';
import '../../config/app_config.dart';
import '../../utils/app_log.dart';
import 'webdav_service.dart';
import 'backup_service.dart';
import 'restore_service.dart';

/// 同步状态
enum SyncStatus {
  idle,       // 空闲
  syncing,    // 同步中
  success,    // 成功
  failed,     // 失败
  conflict,   // 冲突
}

/// 同步类型
enum SyncType {
  backup,     // 备份到云端
  restore,    // 从云端恢复
  auto,       // 自动同步（根据时间戳决定）
}

/// 冲突解决策略
enum ConflictResolution {
  keepLocal,      // 保留本地版本
  keepRemote,     // 保留云端版本
  keepNewer,      // 保留较新的版本（基于时间戳）
  merge,          // 尝试合并（对于书籍进度等）
  ask,            // 询问用户
}

/// 冲突信息
class ConflictInfo {
  final String itemType;       // 冲突项类型（book, source, bookmark等）
  final String itemId;         // 冲突项标识
  final DateTime localTime;    // 本地修改时间
  final DateTime remoteTime;   // 云端修改时间
  final String? localData;     // 本地数据描述
  final String? remoteData;    // 云端数据描述

  ConflictInfo({
    required this.itemType,
    required this.itemId,
    required this.localTime,
    required this.remoteTime,
    this.localData,
    this.remoteData,
  });

  /// 获取冲突描述
  String get description {
    return '$itemType($itemId): 本地=${localTime.toString()}, 云端=${remoteTime.toString()}';
  }

  /// 判断哪个更新
  bool get isRemoteNewer => remoteTime.isAfter(localTime);
  bool get isLocalNewer => localTime.isAfter(remoteTime);
}

/// 同步结果
class SyncResult {
  final SyncStatus status;
  final String? message;
  final DateTime timestamp;
  final SyncType type;
  final bool hadConflicts;
  final String? conflictDetails;
  final List<ConflictInfo> conflicts;

  SyncResult({
    required this.status,
    this.message,
    required this.timestamp,
    required this.type,
    this.hadConflicts = false,
    this.conflictDetails,
    this.conflicts = const [],
  });

  bool get isSuccess => status == SyncStatus.success;
  bool get hasConflict => status == SyncStatus.conflict || hadConflicts;
}

/// WebDAV 自动同步调度器
/// 支持定时自动同步、应用启动时检查同步
class WebDavSyncScheduler {
  static final WebDavSyncScheduler instance = WebDavSyncScheduler._init();
  WebDavSyncScheduler._init();

  Timer? _syncTimer;
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncResult? _lastSyncResult;
  final List<void Function(SyncStatus, SyncResult?)> _statusListeners = [];

  /// 默认同步间隔（分钟）
  static const int defaultSyncIntervalMinutes = 30;

  /// 最小同步间隔（分钟）
  static const int minSyncIntervalMinutes = 5;

  /// 获取当前同步状态
  SyncStatus get currentStatus => _currentStatus;

  /// 获取最后同步结果
  SyncResult? get lastSyncResult => _lastSyncResult;

  /// 获取自动同步间隔（分钟）
  int get syncIntervalMinutes {
    return AppConfig.getWebDavSyncInterval();
  }

  /// 设置自动同步间隔
  Future<void> setSyncInterval(int minutes) async {
    final clampedMinutes = minutes.clamp(minSyncIntervalMinutes, 24 * 60);
    await AppConfig.setWebDavSyncInterval(clampedMinutes);
    _restartTimerIfNeeded();
  }

  /// 是否启用自动同步
  bool get isAutoSyncEnabled {
    return AppConfig.getWebDavAutoSync();
  }

  /// 设置是否启用自动同步
  Future<void> setAutoSyncEnabled(bool enabled) async {
    await AppConfig.setWebDavAutoSync(enabled);
    if (enabled) {
      startAutoSync();
    } else {
      stopAutoSync();
    }
  }

  /// 是否启用启动时同步
  bool get isStartupSyncEnabled {
    return AppConfig.getWebDavStartupSync();
  }

  /// 设置是否启用启动时同步
  Future<void> setStartupSyncEnabled(bool enabled) async {
    await AppConfig.setWebDavStartupSync(enabled);
  }

  /// 添加状态监听器
  void addStatusListener(void Function(SyncStatus, SyncResult?) listener) {
    _statusListeners.add(listener);
  }

  /// 移除状态监听器
  void removeStatusListener(void Function(SyncStatus, SyncResult?) listener) {
    _statusListeners.remove(listener);
  }

  /// 通知状态变化
  void _notifyStatusChange(SyncStatus status, SyncResult? result) {
    _currentStatus = status;
    for (final listener in _statusListeners) {
      listener(status, result);
    }
  }

  /// 启动自动同步
  void startAutoSync() {
    if (_syncTimer != null) return;

    final interval = syncIntervalMinutes;
    _syncTimer = Timer.periodic(Duration(minutes: interval), (timer) {
      performAutoSync();
    });

    AppLog.instance.put('WebDAV自动同步已启动，间隔: $interval 分钟');
  }

  /// 停止自动同步
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    AppLog.instance.put('WebDAV自动同步已停止');
  }

  /// 重启定时器（如果需要）
  void _restartTimerIfNeeded() {
    if (_syncTimer != null && isAutoSyncEnabled) {
      stopAutoSync();
      startAutoSync();
    }
  }

  /// 应用启动时检查同步
  Future<SyncResult> checkStartupSync() async {
    if (!isStartupSyncEnabled) {
      return SyncResult(
        status: SyncStatus.idle,
        message: '启动同步未启用',
        timestamp: DateTime.now(),
        type: SyncType.auto,
      );
    }

    return await performAutoSync();
  }

  /// 执行自动同步
  /// 根据本地和云端的时间戳决定是备份还是恢复
  Future<SyncResult> performAutoSync() async {
    if (_currentStatus == SyncStatus.syncing) {
      return SyncResult(
        status: SyncStatus.syncing,
        message: '同步正在进行中',
        timestamp: DateTime.now(),
        type: SyncType.auto,
      );
    }

    _notifyStatusChange(SyncStatus.syncing, null);

    try {
      // 加载 WebDAV 配置
      await WebDavService.instance.loadConfig();

      if (!WebDavService.instance.isConfigured) {
        final result = SyncResult(
          status: SyncStatus.failed,
          message: 'WebDAV 未配置',
          timestamp: DateTime.now(),
          type: SyncType.auto,
        );
        _lastSyncResult = result;
        _notifyStatusChange(SyncStatus.failed, result);
        return result;
      }

      // 检查连接
      final isOk = await WebDavService.instance.check();
      if (!isOk) {
        final result = SyncResult(
          status: SyncStatus.failed,
          message: 'WebDAV 连接失败',
          timestamp: DateTime.now(),
          type: SyncType.auto,
        );
        _lastSyncResult = result;
        _notifyStatusChange(SyncStatus.failed, result);
        return result;
      }

      // 获取本地最后备份时间
      final localBackupTime = BackupService.instance.getLastBackupTime();
      final localBackupTimeMs = localBackupTime * 1000;

      // 获取云端最后备份文件
      final cloudBackup = await WebDavService.instance.getLastBackup();
      final cloudBackupTimeMs = cloudBackup?.lastModified.millisecondsSinceEpoch ?? 0;

      // 比较时间戳决定同步方向
      SyncResult result;

      if (cloudBackup == null || cloudBackupTimeMs == 0) {
        // 云端没有备份，执行备份
        result = await _performBackup();
      } else if (localBackupTimeMs == 0) {
        // 本地没有备份，执行恢复
        result = await _performRestore(cloudBackup.name);
      } else if (localBackupTimeMs >= cloudBackupTimeMs) {
        // 本地更新或相同，执行备份
        result = await _performBackup();
      } else {
        // 云端更新，执行恢复
        result = await _performRestore(cloudBackup.name);
      }

      _lastSyncResult = result;
      _notifyStatusChange(result.status, result);
      return result;

    } catch (e) {
      final result = SyncResult(
        status: SyncStatus.failed,
        message: '同步失败: $e',
        timestamp: DateTime.now(),
        type: SyncType.auto,
      );
      _lastSyncResult = result;
      _notifyStatusChange(SyncStatus.failed, result);
      AppLog.instance.put('WebDAV自动同步失败', error: e);
      return result;
    }
  }

  /// 手动备份到云端
  Future<SyncResult> backupToCloud() async {
    if (_currentStatus == SyncStatus.syncing) {
      return SyncResult(
        status: SyncStatus.syncing,
        message: '同步正在进行中',
        timestamp: DateTime.now(),
        type: SyncType.backup,
      );
    }

    _notifyStatusChange(SyncStatus.syncing, null);

    try {
      final result = await _performBackup();
      _lastSyncResult = result;
      _notifyStatusChange(result.status, result);
      return result;
    } catch (e) {
      final result = SyncResult(
        status: SyncStatus.failed,
        message: '备份失败: $e',
        timestamp: DateTime.now(),
        type: SyncType.backup,
      );
      _lastSyncResult = result;
      _notifyStatusChange(SyncStatus.failed, result);
      return result;
    }
  }

  /// 手动从云端恢复
  Future<SyncResult> restoreFromCloud({String? backupFileName}) async {
    if (_currentStatus == SyncStatus.syncing) {
      return SyncResult(
        status: SyncStatus.syncing,
        message: '同步正在进行中',
        timestamp: DateTime.now(),
        type: SyncType.restore,
      );
    }

    _notifyStatusChange(SyncStatus.syncing, null);

    try {
      String fileName = backupFileName ?? '';

      if (fileName.isEmpty) {
        // 获取最新的备份文件
        final lastBackup = await WebDavService.instance.getLastBackup();
        if (lastBackup == null) {
          final result = SyncResult(
            status: SyncStatus.failed,
            message: '云端没有备份文件',
            timestamp: DateTime.now(),
            type: SyncType.restore,
          );
          _lastSyncResult = result;
          _notifyStatusChange(SyncStatus.failed, result);
          return result;
        }
        fileName = lastBackup.name;
      }

      final result = await _performRestore(fileName);
      _lastSyncResult = result;
      _notifyStatusChange(result.status, result);
      return result;
    } catch (e) {
      final result = SyncResult(
        status: SyncStatus.failed,
        message: '恢复失败: $e',
        timestamp: DateTime.now(),
        type: SyncType.restore,
      );
      _lastSyncResult = result;
      _notifyStatusChange(SyncStatus.failed, result);
      return result;
    }
  }

  /// 执行备份
  Future<SyncResult> _performBackup() async {
    try {
      await BackupService.instance.backupToWebDav();

      return SyncResult(
        status: SyncStatus.success,
        message: '备份成功',
        timestamp: DateTime.now(),
        type: SyncType.backup,
      );
    } catch (e) {
      AppLog.instance.put('WebDAV备份失败', error: e);
      rethrow;
    }
  }

  /// 执行恢复
  Future<SyncResult> _performRestore(String backupFileName) async {
    try {
      await RestoreService.instance.restoreFromWebDav(backupFileName);

      return SyncResult(
        status: SyncStatus.success,
        message: '恢复成功',
        timestamp: DateTime.now(),
        type: SyncType.restore,
      );
    } catch (e) {
      AppLog.instance.put('WebDAV恢复失败', error: e);
      rethrow;
    }
  }

  /// 获取可用备份列表
  Future<List<String>> getAvailableBackups() async {
    try {
      await WebDavService.instance.loadConfig();
      if (!WebDavService.instance.isConfigured) {
        return [];
      }
      return await WebDavService.instance.getBackupNames();
    } catch (e) {
      AppLog.instance.put('获取备份列表失败', error: e);
      return [];
    }
  }

  /// 获取同步状态描述
  String get statusDescription {
    switch (_currentStatus) {
      case SyncStatus.idle:
        return '空闲';
      case SyncStatus.syncing:
        return '同步中...';
      case SyncStatus.success:
        return '同步成功';
      case SyncStatus.failed:
        return '同步失败';
      case SyncStatus.conflict:
        return '存在冲突';
    }
  }

  // ========== 冲突检测与解决 ==========

  /// 获取冲突解决策略
  ConflictResolution get conflictResolution {
    final strategy = AppConfig.getString('webdav_conflict_resolution', defaultValue: 'keepNewer');
    return ConflictResolution.values.firstWhere(
      (e) => e.name == strategy,
      orElse: () => ConflictResolution.keepNewer,
    );
  }

  /// 设置冲突解决策略
  Future<void> setConflictResolution(ConflictResolution resolution) async {
    await AppConfig.setString('webdav_conflict_resolution', resolution.name);
  }

  /// 检测同步冲突
  /// 返回检测到的冲突列表
  Future<List<ConflictInfo>> detectConflicts() async {
    final conflicts = <ConflictInfo>[];

    try {
      // 获取本地最后备份时间
      final localBackupTime = BackupService.instance.getLastBackupTime();
      final localBackupTimeMs = localBackupTime * 1000;

      // 获取云端最后备份文件
      final cloudBackup = await WebDavService.instance.getLastBackup();
      final cloudBackupTimeMs = cloudBackup?.lastModified.millisecondsSinceEpoch ?? 0;

      // 检查时间差异（如果差异小于5分钟，不认为有冲突）
      const conflictThresholdMs = 5 * 60 * 1000; // 5分钟
      final timeDiff = (localBackupTimeMs - cloudBackupTimeMs).abs();

      if (timeDiff > conflictThresholdMs && localBackupTimeMs > 0 && cloudBackupTimeMs > 0) {
        // 两边都有数据且时间差异超过阈值
        conflicts.add(ConflictInfo(
          itemType: 'backup',
          itemId: 'main',
          localTime: DateTime.fromMillisecondsSinceEpoch(localBackupTimeMs),
          remoteTime: DateTime.fromMillisecondsSinceEpoch(cloudBackupTimeMs),
          localData: '本地备份',
          remoteData: '云端备份: ${cloudBackup?.name}',
        ));
      }

      // 检查书籍进度冲突
      if (AppConfig.getSyncBookProgress()) {
        final progressConflicts = await _detectBookProgressConflicts();
        conflicts.addAll(progressConflicts);
      }
    } catch (e) {
      AppLog.instance.put('检测同步冲突失败', error: e);
    }

    return conflicts;
  }

  /// 检测书籍进度冲突
  Future<List<ConflictInfo>> _detectBookProgressConflicts() async {
    // 这里可以扩展检测具体书籍的进度冲突
    // 当前简化实现，不检测具体冲突
    return [];
  }

  /// 使用当前策略解决冲突
  /// 返回应该执行的操作
  SyncType resolveConflict(List<ConflictInfo> conflicts) {
    if (conflicts.isEmpty) {
      return SyncType.auto;
    }

    final resolution = conflictResolution;

    switch (resolution) {
      case ConflictResolution.keepLocal:
        return SyncType.backup;

      case ConflictResolution.keepRemote:
        return SyncType.restore;

      case ConflictResolution.keepNewer:
        // 检查哪个更新的数据更多
        final localNewerCount = conflicts.where((c) => c.isLocalNewer).length;
        final remoteNewerCount = conflicts.where((c) => c.isRemoteNewer).length;

        if (localNewerCount >= remoteNewerCount) {
          return SyncType.backup;
        } else {
          return SyncType.restore;
        }

      case ConflictResolution.merge:
        // 合并策略：对于书籍进度，选择较新的版本
        // 对于其他数据，默认使用云端版本
        return SyncType.restore;

      case ConflictResolution.ask:
        // 询问用户策略，返回冲突状态让调用者处理
        return SyncType.auto;
    }
  }

  /// 带冲突检测的自动同步
  Future<SyncResult> performAutoSyncWithConflictDetection() async {
    if (_currentStatus == SyncStatus.syncing) {
      return SyncResult(
        status: SyncStatus.syncing,
        message: '同步正在进行中',
        timestamp: DateTime.now(),
        type: SyncType.auto,
      );
    }

    _notifyStatusChange(SyncStatus.syncing, null);

    try {
      // 加载 WebDAV 配置
      await WebDavService.instance.loadConfig();

      if (!WebDavService.instance.isConfigured) {
        final result = SyncResult(
          status: SyncStatus.failed,
          message: 'WebDAV 未配置',
          timestamp: DateTime.now(),
          type: SyncType.auto,
        );
        _lastSyncResult = result;
        _notifyStatusChange(SyncStatus.failed, result);
        return result;
      }

      // 检查连接
      final isOk = await WebDavService.instance.check();
      if (!isOk) {
        final result = SyncResult(
          status: SyncStatus.failed,
          message: 'WebDAV 连接失败',
          timestamp: DateTime.now(),
          type: SyncType.auto,
        );
        _lastSyncResult = result;
        _notifyStatusChange(SyncStatus.failed, result);
        return result;
      }

      // 检测冲突
      final conflicts = await detectConflicts();

      if (conflicts.isNotEmpty && conflictResolution == ConflictResolution.ask) {
        // 有冲突且策略是询问用户
        final result = SyncResult(
          status: SyncStatus.conflict,
          message: '检测到同步冲突，需要用户决定',
          timestamp: DateTime.now(),
          type: SyncType.auto,
          hadConflicts: true,
          conflicts: conflicts,
        );
        _lastSyncResult = result;
        _notifyStatusChange(SyncStatus.conflict, result);
        return result;
      }

      // 根据冲突解决策略决定同步方向
      final syncType = conflicts.isNotEmpty
          ? resolveConflict(conflicts)
          : await _determineSyncDirection();

      SyncResult result;

      switch (syncType) {
        case SyncType.backup:
          result = await _performBackup();
          break;
        case SyncType.restore:
          final lastBackup = await WebDavService.instance.getLastBackup();
          if (lastBackup == null) {
            result = SyncResult(
              status: SyncStatus.failed,
              message: '云端没有备份文件',
              timestamp: DateTime.now(),
              type: SyncType.restore,
            );
          } else {
            result = await _performRestore(lastBackup.name);
          }
          break;
        case SyncType.auto:
          result = await performAutoSync();
          break;
      }

      // 如果有冲突但已自动解决，记录在结果中
      if (conflicts.isNotEmpty && result.isSuccess) {
        result = SyncResult(
          status: result.status,
          message: '${result.message} (已自动解决${conflicts.length}个冲突)',
          timestamp: result.timestamp,
          type: result.type,
          hadConflicts: true,
          conflicts: conflicts,
        );
      }

      _lastSyncResult = result;
      _notifyStatusChange(result.status, result);
      return result;

    } catch (e) {
      final result = SyncResult(
        status: SyncStatus.failed,
        message: '同步失败: $e',
        timestamp: DateTime.now(),
        type: SyncType.auto,
      );
      _lastSyncResult = result;
      _notifyStatusChange(SyncStatus.failed, result);
      AppLog.instance.put('WebDAV自动同步失败', error: e);
      return result;
    }
  }

  /// 确定同步方向（无冲突时）
  Future<SyncType> _determineSyncDirection() async {
    // 获取本地最后备份时间
    final localBackupTime = BackupService.instance.getLastBackupTime();
    final localBackupTimeMs = localBackupTime * 1000;

    // 获取云端最后备份文件
    final cloudBackup = await WebDavService.instance.getLastBackup();
    final cloudBackupTimeMs = cloudBackup?.lastModified.millisecondsSinceEpoch ?? 0;

    if (cloudBackup == null || cloudBackupTimeMs == 0) {
      return SyncType.backup;
    } else if (localBackupTimeMs == 0) {
      return SyncType.restore;
    } else if (localBackupTimeMs >= cloudBackupTimeMs) {
      return SyncType.backup;
    } else {
      return SyncType.restore;
    }
  }

  /// 释放资源
  void dispose() {
    stopAutoSync();
    _statusListeners.clear();
  }
}
