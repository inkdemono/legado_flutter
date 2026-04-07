import 'package:file_picker/file_picker.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/storage/backup_service.dart';
import '../../../services/storage/restore_service.dart';
import '../../../services/storage/webdav_service.dart';
import '../../../utils/app_log.dart';
import '../../widgets/home/home_shell.dart';
import 'backup_config_page.dart';

/// 备份恢复管理页面
class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  bool _isLoading = false;
  bool _isLoadingBackups = false;
  bool _isWebDavConfigured = false;
  List<String> _webDavBackups = [];
  String _webDavLocation = '';

  @override
  void initState() {
    super.initState();
    _loadWebDavBackups();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadWebDavBackups() async {
    setState(() {
      _isLoadingBackups = true;
    });

    await readService(AppServices.webDavService).loadConfig();

    if (!mounted) return;
    setState(() {
      _isWebDavConfigured = readService(AppServices.webDavService).isConfigured;
      _webDavLocation = readService(AppServices.webDavService).rootUrl;
    });

    try {
      final backups = await readService(AppServices.restoreService).getWebDavBackupList();
      if (!mounted) return;
      setState(() {
        _webDavBackups = backups;
      });
    } catch (e) {
      AppLog.instance.put('加载WebDAV备份列表失败', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBackups = false;
        });
      }
    }
  }

  Future<void> _backupToLocal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '保存备份文件',
        fileName:
            'backup_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null) {
        await readService(AppServices.backupService).backupToLocal(result);
        _showMessage('备份成功');
      }
    } catch (e) {
      _showMessage('备份失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _backupToWebDav() async {
    await readService(AppServices.webDavService).loadConfig();
    if (!readService(AppServices.webDavService).isConfigured) {
      if (!mounted) return;
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('WebDAV未配置'),
          content: const Text('请先配置 WebDAV 设置'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('去设置'),
            ),
          ],
        ),
      );

      if (result == true) {
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const BackupConfigPage()),
        );
        await _loadWebDavBackups();
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await readService(AppServices.backupService).backupToWebDav();
      _showMessage('备份到 WebDAV 成功');
      await _loadWebDavBackups();
    } catch (e) {
      _showMessage('备份到 WebDAV 失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restoreFromLocal() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    final confirmed = await _confirmRestore('恢复本地备份将覆盖当前数据，是否继续？');
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await readService(AppServices.restoreService).restoreFromLocal(filePath);
      _showMessage('恢复成功');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showMessage('恢复失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restoreFromWebDav(String backupName) async {
    final confirmed = await _confirmRestore('恢复备份 "$backupName" 将覆盖当前数据，是否继续？');
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await readService(AppServices.restoreService).restoreFromWebDav(backupName);
      _showMessage('恢复成功');
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showMessage('恢复失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool?> _confirmRestore(String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Future<void> _openWebDavSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BackupConfigPage()),
    );
    await _loadWebDavBackups();
  }

  String _backupSubtitle(String backupName) {
    final match = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(backupName);
    if (match != null) {
      return '备份日期 ${match.group(1)}';
    }
    return '云端备份文件';
  }

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: _loadWebDavBackups,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _buildHeroCard(context),
          const SizedBox(height: 16),
          _buildSectionHeader(
            context,
            title: '备份操作',
            subtitle: '先导出一份完整快照，迁移和回滚都更稳妥',
          ),
          const SizedBox(height: 10),
          HomeSectionCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.save_alt_rounded,
                  iconColor: const Color(0xFF1677FF),
                  title: '备份到本地',
                  subtitle: '导出 zip 备份包到设备文件系统',
                  onTap: _isLoading ? null : _backupToLocal,
                ),
                _buildDivider(context),
                _buildActionTile(
                  context,
                  icon: Icons.cloud_upload_rounded,
                  iconColor: const Color(0xFF22C55E),
                  title: '备份到 WebDAV',
                  subtitle: _isWebDavConfigured
                      ? '同步到 $_webDavLocation'
                      : '先配置 WebDAV 后再同步',
                  onTap: _isLoading ? null : _backupToWebDav,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(
            context,
            title: '恢复入口',
            subtitle: '恢复会覆盖当前数据，操作前建议先做一次备份',
          ),
          const SizedBox(height: 10),
          HomeSectionCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.folder_open_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: '从本地恢复',
                  subtitle: '选择之前导出的 zip 备份文件',
                  onTap: _isLoading ? null : _restoreFromLocal,
                ),
                _buildDivider(context),
                _buildActionTile(
                  context,
                  icon: Icons.settings_remote_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'WebDAV 设置',
                  subtitle: _isWebDavConfigured ? '已连接远端备份空间' : '配置账号、目录与连接信息',
                  onTap: _isLoading ? null : _openWebDavSettings,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(
            context,
            title: '云端备份',
            subtitle: '可直接从 WebDAV 历史备份恢复',
            trailing: IconButton(
              onPressed: _isLoadingBackups ? null : _loadWebDavBackups,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: '刷新',
            ),
          ),
          const SizedBox(height: 10),
          HomeSectionCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: _isLoadingBackups
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _webDavBackups.isEmpty
                    ? _buildEmptyBackups(context)
                    : Column(
                        children: List.generate(_webDavBackups.length, (index) {
                          final backup = _webDavBackups[index];
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1677FF)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.archive_outlined,
                                    color: Color(0xFF1677FF),
                                  ),
                                ),
                                title: Text(
                                  backup,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: HomePalette.primaryText(context),
                                  ),
                                ),
                                subtitle: Text(
                                  _backupSubtitle(backup),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: HomePalette.tertiaryText(context),
                                  ),
                                ),
                                trailing: FilledButton.tonal(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _restoreFromWebDav(backup),
                                  child: const Text('恢复'),
                                ),
                              ),
                              if (index != _webDavBackups.length - 1)
                                _buildDivider(context),
                            ],
                          );
                        }),
                      ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF1677FF), Color(0xFF22C55E)],
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: content),
                ],
              ),
              if (_isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.08),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _buildHeaderButton(
            context,
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '备份恢复',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '管理本地与 WebDAV 备份',
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildHeaderButton(
            context,
            icon: Icons.settings_rounded,
            onTap: _openWebDavSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1677FF), Color(0xFF22C55E)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF).withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数据守护',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.98),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isWebDavConfigured
                ? 'WebDAV 已连接，可随时同步远端备份并从历史版本恢复。'
                : '建议先完成 WebDAV 配置，避免只依赖单机备份。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildHeroMetric(
                context,
                value: _isWebDavConfigured ? '已连接' : '未配置',
                label: 'WebDAV',
              ),
              const SizedBox(width: 10),
              _buildHeroMetric(
                context,
                value: '${_webDavBackups.length}',
                label: '云端备份',
              ),
              const SizedBox(width: 10),
              _buildHeroMetric(
                context,
                value: DateFormat('MM-dd').format(DateTime.now()),
                label: '今天',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return HomeSectionTitle(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: HomePalette.tertiaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: HomePalette.tertiaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBackups(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: HomePalette.mutedCard(context),
              shape: BoxShape.circle,
              border: Border.all(color: HomePalette.lineColor(context)),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.cloud_off_rounded,
              size: 34,
              color: HomePalette.tertiaryText(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无云端备份',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isWebDavConfigured
                ? '先执行一次备份到 WebDAV，之后这里会显示历史备份列表。'
                : '完成 WebDAV 配置后，远端备份会出现在这里。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: HomePalette.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 72, right: 16),
      color: HomePalette.lineColor(context),
    );
  }

  Widget _buildHeaderButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: HomePalette.card(context).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: HomePalette.primaryText(context),
          ),
        ),
      ),
    );
  }
}
