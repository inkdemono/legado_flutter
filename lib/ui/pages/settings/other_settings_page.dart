import 'dart:io';
import 'package:legado_flutter/providers/service_registry.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/app_config.dart';
import '../../../services/reader/cache_service.dart';
import '../../../utils/app_log.dart';
import '../../widgets/home/home_shell.dart';
import '../config/cover_config_page.dart';
import '../welcome/welcome_config_page.dart';

/// 其他设置页面
class OtherSettingsPage extends StatefulWidget {
  const OtherSettingsPage({super.key});

  @override
  State<OtherSettingsPage> createState() => _OtherSettingsPageState();
}

class _OtherSettingsPageState extends State<OtherSettingsPage> {
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF06B6D4), Color(0xFF1677FF)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _buildHeroCard(context),
                    const SizedBox(height: 18),
                    _buildSection(
                      context,
                      title: '网络与下载',
                      subtitle: '请求头、缓存策略与服务端口',
                      children: [
                        _buildSettingItem(
                          context,
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF1677FF),
                          title: 'User Agent',
                          subtitle: AppConfig.getUserAgentWithDefault(),
                          onTap: _showUserAgentDialog,
                        ),
                        _buildSettingDivider(context),
                        _buildSettingItem(
                          context,
                          icon: Icons.download_rounded,
                          iconColor: const Color(0xFF22C55E),
                          title: '预下载数量',
                          subtitle:
                              '${AppConfig.getInt('pre_download_num', defaultValue: 0)} 章',
                          onTap: () => _showNumberPickerDialog(
                            title: '预下载数量',
                            currentValue: AppConfig.getInt('pre_download_num',
                                defaultValue: 0),
                            minValue: 0,
                            maxValue: 9999,
                            onChanged: (value) async {
                              await AppConfig.setInt('pre_download_num', value);
                              setState(() {});
                            },
                          ),
                        ),
                        _buildSettingDivider(context),
                        _buildSettingItem(
                          context,
                          icon: Icons.speed_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: '线程数',
                          subtitle:
                              '${AppConfig.getInt('thread_count', defaultValue: 10)} 个',
                          onTap: () => _showNumberPickerDialog(
                            title: '线程数',
                            currentValue: AppConfig.getInt('thread_count',
                                defaultValue: 10),
                            minValue: 1,
                            maxValue: 999,
                            onChanged: (value) async {
                              await AppConfig.setInt('thread_count', value);
                              setState(() {});
                            },
                          ),
                        ),
                        _buildSettingDivider(context),
                        _buildSettingItem(
                          context,
                          icon: Icons.web_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'Web 服务端口',
                          subtitle:
                              '${AppConfig.getInt('web_port', defaultValue: 1122)}',
                          onTap: () => _showNumberPickerDialog(
                            title: 'Web 服务端口',
                            currentValue: AppConfig.getInt('web_port',
                                defaultValue: 1122),
                            minValue: 1024,
                            maxValue: 60000,
                            onChanged: (value) async {
                              await AppConfig.setInt('web_port', value);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSection(
                      context,
                      title: '缓存与运行',
                      subtitle: '查看缓存体积并清理本地残留',
                      children: [
                        FutureBuilder<Map<String, dynamic>>(
                          future: _getCacheInfo(),
                          builder: (context, snapshot) {
                            final totalSize =
                                snapshot.data?['totalSize'] as int? ?? 0;
                            final fileCount =
                                snapshot.data?['fileCount'] as int? ?? 0;
                            final subtitle = snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? '正在统计缓存大小'
                                : '${_formatFileSize(totalSize)} • $fileCount 个文件';

                            return _buildSettingItem(
                              context,
                              icon: Icons.storage_rounded,
                              iconColor: const Color(0xFF06B6D4),
                              title: '缓存大小',
                              subtitle: subtitle,
                            );
                          },
                        ),
                        _buildSettingDivider(context),
                        _buildSettingItem(
                          context,
                          icon: Icons.delete_outline_rounded,
                          iconColor: const Color(0xFFE34D59),
                          title: '清除所有缓存',
                          subtitle: '清除所有书籍章节缓存，此操作不可恢复',
                          onTap: _showClearCacheDialog,
                          danger: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSection(
                      context,
                      title: '显示与行为',
                      subtitle: '控制书架展示与启动相关入口',
                      children: [
                        _buildSwitchItem(
                          context,
                          icon: Icons.bug_report_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          title: '记录日志',
                          subtitle: '开启后记录应用运行日志',
                          value: AppConfig.getBool('record_log',
                              defaultValue: false),
                          onChanged: (value) async {
                            await AppConfig.setBool('record_log', value);
                            setState(() {});
                          },
                        ),
                        _buildSettingDivider(context),
                        _buildSwitchItem(
                          context,
                          icon: Icons.explore_outlined,
                          iconColor: const Color(0xFF1677FF),
                          title: '显示发现',
                          subtitle: '在书架页面显示发现入口',
                          value: AppConfig.getBool('show_discovery',
                              defaultValue: true),
                          onChanged: (value) async {
                            await AppConfig.setBool('show_discovery', value);
                            setState(() {});
                          },
                        ),
                        _buildSettingDivider(context),
                        _buildSwitchItem(
                          context,
                          icon: Icons.rss_feed_rounded,
                          iconColor: const Color(0xFFFB7185),
                          title: '显示 RSS',
                          subtitle: '在书架页面显示 RSS 功能入口',
                          value:
                              AppConfig.getBool('show_rss', defaultValue: true),
                          onChanged: (value) async {
                            await AppConfig.setBool('show_rss', value);
                            setState(() {});
                          },
                        ),
                        _buildSettingDivider(context),
                        _buildSettingItem(
                          context,
                          icon: Icons.wb_sunny_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          title: '欢迎页配置',
                          subtitle: '自定义启动页样式',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const WelcomeConfigPage(),
                              ),
                            );
                          },
                        ),
                        _buildSettingDivider(context),
                        _buildSettingItem(
                          context,
                          icon: Icons.image_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          title: '封面配置',
                          subtitle: '设置默认封面和显示选项',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CoverConfigPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 90),
                  ],
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
                  '其它设置',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '网络、缓存与展示行为配置',
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final logEnabled = AppConfig.getBool('record_log', defaultValue: false);
    final showDiscovery =
        AppConfig.getBool('show_discovery', defaultValue: true);
    final showRss = AppConfig.getBool('show_rss', defaultValue: true);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06B6D4), Color(0xFF1677FF)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '行为控制台',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.98),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '这些设置主要影响网络请求、缓存策略和书架入口显示，调整后通常立即生效。',
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
                value: logEnabled ? '开启' : '关闭',
                label: '日志',
              ),
              const SizedBox(width: 10),
              _buildHeroMetric(
                value: showDiscovery ? '显示' : '隐藏',
                label: '发现',
              ),
              const SizedBox(width: 10),
              _buildHeroMetric(
                value: showRss ? '显示' : '隐藏',
                label: 'RSS',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric({
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(title: title, subtitle: subtitle),
        const SizedBox(height: 10),
        HomeSectionCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool danger = false,
  }) {
    final titleColor =
        danger ? const Color(0xFFE34D59) : HomePalette.primaryText(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: iconColor),
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
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: HomePalette.tertiaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: HomePalette.tertiaryText(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: iconColor),
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
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingDivider(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 68, right: 16),
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

  Future<void> _showUserAgentDialog() async {
    final defaultUserAgent = AppConfig.getUserAgentWithDefault();
    final customUserAgent = AppConfig.getString('user_agent', defaultValue: '');
    final initialValue =
        customUserAgent.isNotEmpty ? customUserAgent : defaultUserAgent;
    final controller = TextEditingController(text: initialValue);

    String? result;
    try {
      result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('User Agent'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '留空使用默认 User Agent',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text == defaultUserAgent) {
                  Navigator.of(context).pop('');
                } else {
                  Navigator.of(context).pop(text);
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    if (result != null) {
      await AppConfig.setString('user_agent', result);
      setState(() {});
    }
  }

  Future<void> _showNumberPickerDialog({
    required String title,
    required int currentValue,
    required int minValue,
    required int maxValue,
    required Function(int) onChanged,
  }) async {
    final controller = TextEditingController(text: currentValue.toString());

    int? result;
    try {
      result = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: '请输入 $minValue - $maxValue 之间的数字',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value >= minValue && value <= maxValue) {
                  Navigator.of(context).pop(value);
                } else {
                  _showMessage('请输入 $minValue - $maxValue 之间的数字');
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    if (result != null) {
      onChanged(result);
    }
  }

  Future<void> _showClearCacheDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await readService(AppServices.cacheService).clearAllCache();
      if (success) {
        _showMessage('缓存已清除');
        setState(() {});
      } else {
        _showMessage('清除缓存失败');
      }
    } catch (e) {
      AppLog.instance.put('清除缓存失败', error: e);
      _showMessage('清除缓存失败: $e');
    }
  }

  Future<Map<String, dynamic>> _getCacheInfo() async {
    try {
      final cacheDir = await readService(AppServices.cacheService).getCacheDir();
      if (!await cacheDir.exists()) {
        return {'totalSize': 0, 'fileCount': 0};
      }

      var totalSize = 0;
      var fileCount = 0;

      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            totalSize += stat.size;
            fileCount++;
          } catch (_) {}
        }
      }

      return {'totalSize': totalSize, 'fileCount': fileCount};
    } catch (_) {
      return {'totalSize': 0, 'fileCount': 0};
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
