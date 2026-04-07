import 'dart:io' show Platform;
import 'package:legado_flutter/providers/service_registry.dart';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/app_config.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../services/about/heap_dump_service.dart';
import '../../../services/about/log_save_service.dart';
import '../../../services/update/app_update_github.dart';
import '../../../utils/app_log.dart';
import '../../dialogs/update_dialog.dart';
import '../../widgets/home/home_shell.dart';
import '../help/help_page.dart';
import 'app_log_page.dart';
import 'crash_logs_page.dart';
import 'markdown_viewer_page.dart';

/// 关于页面
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _appName = 'Legado Flutter';
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appName = packageInfo.appName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
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
                    _buildSectionLabel(
                      context,
                      title: '项目支持',
                      subtitle: '源码、帮助文档、问题反馈和运行日志',
                    ),
                    const SizedBox(height: 10),
                    _buildMenuSection(
                      context,
                      [
                        _buildMenuItem(
                          context,
                          icon: Icons.code_rounded,
                          iconColor: const Color(0xFF1677FF),
                          title: '开源地址',
                          subtitle: 'GitHub 仓库',
                          onTap: () => _launchURL(
                            'https://github.com/zhishouxun/legado_flutter',
                          ),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.menu_book_outlined,
                          iconColor: const Color(0xFF22C55E),
                          title: '使用说明',
                          subtitle: '查看帮助与常见问题',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const HelpPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.bug_report_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          title: '问题反馈',
                          subtitle: '提交 Bug 或建议',
                          onTap: () => _launchURL(
                            'https://github.com/zhishouxun/legado_flutter/issues',
                          ),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.description_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          title: '应用日志',
                          subtitle: '查看运行日志',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AppLogPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '版本与文档',
                      subtitle: '更新、许可证、隐私政策等基础信息',
                    ),
                    const SizedBox(height: 10),
                    _buildMenuSection(
                      context,
                      [
                        _buildMenuItem(
                          context,
                          icon: Icons.refresh_rounded,
                          iconColor: const Color(0xFF14B8A6),
                          title: '检查更新',
                          subtitle: '当前版本 $_version',
                          onTap: _checkUpdate,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.history_rounded,
                          iconColor: const Color(0xFF1677FF),
                          title: '更新日志',
                          subtitle: '查看版本变更',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MarkdownViewerPage(
                                  title: '更新日志',
                                  assetPath: 'assets/updateLog.md',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.gavel_rounded,
                          iconColor: const Color(0xFF22C55E),
                          title: '许可证',
                          subtitle: '查看开源许可证',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MarkdownViewerPage(
                                  title: '许可证',
                                  assetPath: 'assets/LICENSE.md',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          title: '隐私政策',
                          subtitle: '查看隐私政策',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MarkdownViewerPage(
                                  title: '隐私政策',
                                  assetPath: 'assets/privacyPolicy.md',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '诊断工具',
                      subtitle: '崩溃记录、日志导出和堆转储',
                    ),
                    const SizedBox(height: 10),
                    _buildMenuSection(
                      context,
                      [
                        _buildMenuItem(
                          context,
                          icon: Icons.warning_amber_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: '崩溃日志',
                          subtitle: '查看应用崩溃记录',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CrashLogsPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.save_outlined,
                          iconColor: const Color(0xFF14B8A6),
                          title: '保存日志',
                          subtitle: '导出日志到备份目录',
                          onTap: _saveLogs,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.memory_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: '创建堆转储',
                          subtitle: '生成堆转储文件',
                          onTap: _createHeapDump,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '社区与声明',
                      subtitle: '免责声明与社区入口',
                    ),
                    const SizedBox(height: 10),
                    _buildMenuSection(
                      context,
                      [
                        _buildMenuItem(
                          context,
                          icon: Icons.info_outline_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: '免责声明',
                          subtitle: '查看免责声明',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MarkdownViewerPage(
                                  title: '免责声明',
                                  assetPath: 'assets/disclaimer.md',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.groups_outlined,
                          iconColor: const Color(0xFF1677FF),
                          title: '加入 QQ 群',
                          subtitle: '获取社区支持',
                          onTap: _joinQQGroup,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildFooter(context),
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
                  '关于',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '应用信息、文档入口与诊断工具',
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
            icon: Icons.star_outline_rounded,
            onTap: _openAppStore,
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            context,
            icon: Icons.share_outlined,
            onTap: () {
              SharePlus.instance.share(
                ShareParams(
                  text: 'Legado Flutter - 一个免费开源的小说阅读器',
                  subject: _appName,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F7CFF).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.menu_book_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _appName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '版本 $_version (Build $_buildNumber)',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '一个免费开源的小说阅读器\nLegado（开源阅读）Flutter 版本',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricCard(value: _version, label: '版本'),
              const SizedBox(width: 10),
              _buildMetricCard(value: _buildNumber, label: '构建'),
              const SizedBox(width: 10),
              _buildMetricCard(value: '开源', label: '协议'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
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

  Widget _buildSectionLabel(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: HomePalette.tertiaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, List<Widget> children) {
    return HomeSectionCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(children: _insertDividers(context, children)),
      ),
    );
  }

  List<Widget> _insertDividers(BuildContext context, List<Widget> children) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 64, right: 16),
            color: HomePalette.lineColor(context),
          ),
        );
      }
    }
    return result;
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                  const SizedBox(height: 3),
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
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: HomePalette.tertiaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          Text(
            'Copyright © 2024 Legado Flutter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: HomePalette.tertiaryText(context),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '基于 Legado（开源阅读）项目',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: HomePalette.tertiaryText(context),
              height: 1.7,
            ),
          ),
        ],
      ),
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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('无法打开链接: $url');
    }
  }

  Future<void> _checkUpdate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在检查更新...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final updateService = AppUpdateGitHub.instance;
      final coroutine = updateService.check();
      final updateInfo = await coroutine.future;

      if (!mounted) return;
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => UpdateDialog(updateInfo: updateInfo),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      String errorMessage;
      if (e is NoStackTraceException) {
        errorMessage = e.message;
      } else {
        errorMessage = '检查更新失败: $e';
        AppLog.instance.put('检查更新失败', error: e);
      }

      _showMessage(errorMessage);
    }
  }

  Future<void> _saveLogs() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在保存日志...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await readService(AppServices.logSaveService).saveLogs();

      if (!mounted) return;
      Navigator.of(context).pop();
      _showMessage('日志已保存至备份目录');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      String errorMessage;
      if (e is NoStackTraceException) {
        errorMessage = e.message;
      } else {
        errorMessage = '保存日志失败: $e';
        AppLog.instance.put('保存日志失败', error: e);
      }

      _showMessage(errorMessage);
    }
  }

  Future<void> _createHeapDump() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在创建堆转储...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await readService(AppServices.heapDumpService).createHeapDump();

      if (!mounted) return;
      Navigator.of(context).pop();
      _showMessage('堆转储已保存至备份目录');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();

      String errorMessage;
      if (e is NoStackTraceException) {
        errorMessage = e.message;
      } else {
        errorMessage = '创建堆转储失败: $e';
        AppLog.instance.put('创建堆转储失败', error: e);
      }

      _showMessage(errorMessage);
    }
  }

  Future<void> _joinQQGroup() async {
    try {
      final qqGroupKey = AppConfig.getString('qq_group_key', defaultValue: '');

      if (qqGroupKey.isEmpty) {
        _showMessage('QQ群号未配置');
        return;
      }

      final qqUrl =
          'mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3D$qqGroupKey';
      final uri = Uri.parse(qqUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showMessage('无法打开QQ，请手动添加QQ群');
      }
    } catch (e) {
      _showMessage('加入QQ群失败: $e');
    }
  }

  Future<void> _openAppStore() async {
    try {
      late final String url;
      if (Platform.isAndroid) {
        const packageName = 'com.legado.flutter';
        url = 'https://play.google.com/store/apps/details?id=$packageName';
      } else if (Platform.isIOS) {
        const appId = '1234567890';
        url = 'https://apps.apple.com/app/id$appId';
      } else {
        _showMessage('当前平台不支持应用商店评分');
        return;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showMessage('无法打开应用商店');
      }
    } catch (e) {
      _showMessage('打开应用商店失败: $e');
    }
  }
}
