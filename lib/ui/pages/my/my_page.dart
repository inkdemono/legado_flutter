import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_config.dart';
import '../../../config/theme_config.dart';
import '../about/about_page.dart';
import '../bookmark/all_bookmark_page.dart';
import '../read_record/read_record_page.dart';
import '../book_source/book_source_manage_page.dart';
import '../txt_toc_rule/txt_toc_rule_manage_page.dart';
import '../dict_rule/dict_rule_manage_page.dart';
import '../replace_rule/replace_rule_manage_page.dart';
import '../backup/backup_restore_page.dart';
import '../theme/theme_settings_page.dart';
import '../file/file_manage_page.dart';
import '../settings/other_settings_page.dart';
import '../help/help_page.dart';
import '../cache/cache_manage_page.dart';
import '../../../services/web/web_service_manager.dart';
import '../../../services/book/book_service.dart';
import '../../../services/source/book_source_service.dart';
import '../../widgets/home/home_shell.dart';

/// 我的页面
class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  int _bookCount = 0;
  int _readingHours = 0;
  int _sourceCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final books = await BookService.instance.getBookshelfBooks();
      final sources = await BookSourceService.instance.getAllBookSources();
      if (mounted) {
        setState(() {
          _bookCount = books.length;
          _sourceCount = sources.length;
          // 简单估算阅读时间（可根据实际逻辑调整）
          _readingHours =
              (books.fold<int>(0, (sum, book) => sum + book.durChapterIndex) ~/
                  60);
        });
      }
    } catch (e) {
      // 忽略错误
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final webServiceEnabled = ref.watch(webServiceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '我的',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: HomePalette.primaryText(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '账户与规则配置中心',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: HomePalette.tertiaryText(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildTopAction(
                          icon: Icons.info_outline_rounded,
                          onTap: () => _navigateTo(const AboutPage()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF4F7CFF).withValues(alpha: 0.22),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text('📚',
                                style: TextStyle(fontSize: 32)),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Legado 阅读',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'v2.2.0 Flutter',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.76),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: HomeSectionCard(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            _buildStatItem(_bookCount.toString(), '书籍'),
                            _buildStatDivider(),
                            _buildStatItem(_readingHours.toString(), '小时'),
                            _buildStatDivider(),
                            _buildStatItem(_sourceCount.toString(), '书源'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSectionLabel('规则与书源', '常用规则入口与数据源维护'),
                    _buildMenuSection([
                      _buildMenuItem(
                        icon: Icons.source_rounded,
                        iconColor: const Color(0xFF1677FF),
                        title: '书源管理',
                        subtitle: '管理书源与发现分类',
                        onTap: () => _navigateTo(const BookSourceManagePage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.rule_folder_outlined,
                        iconColor: const Color(0xFF22C55E),
                        title: 'TXT目录规则',
                        subtitle: '配置 TXT 目录规则',
                        onTap: () => _navigateTo(const TxtTocRuleManagePage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.find_replace_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: '替换规则',
                        subtitle: '净化与替换文本内容',
                        onTap: () => _navigateTo(const ReplaceRuleManagePage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.translate_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        title: '字典规则',
                        subtitle: '配置查询和翻译规则',
                        onTap: () => _navigateTo(const DictRuleManagePage()),
                      ),
                    ]),
                    _buildSectionLabel('偏好与同步', '主题、服务与备份管理'),
                    _buildMenuSection([
                      _buildMenuItem(
                        icon: Icons.palette_outlined,
                        iconColor: const Color(0xFF06B6D4),
                        title: '主题模式',
                        subtitle: _getThemeModeText(themeMode),
                        onTap: () => _showThemeModeDialog(context, ref),
                      ),
                      _buildWebServiceTile(webServiceEnabled, ref),
                      _buildMenuItem(
                        icon: Icons.backup_outlined,
                        iconColor: const Color(0xFF22C55E),
                        title: '备份恢复',
                        subtitle: 'WebDAV 与备份恢复',
                        onTap: () => _navigateTo(const BackupRestorePage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.color_lens_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: '主题设置',
                        subtitle: '自定义主题与阅读风格',
                        onTap: () => _navigateTo(const ThemeSettingsPage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.tune_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: '其他设置',
                        subtitle: '更多行为与细节选项',
                        onTap: () => _navigateTo(const OtherSettingsPage()),
                      ),
                    ]),
                    _buildSectionLabel('记录与工具', '书签、历史、缓存和帮助'),
                    _buildMenuSection([
                      _buildMenuItem(
                        icon: Icons.bookmark_outline_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: '书签',
                        subtitle: '查看全部书签',
                        onTap: () => _navigateTo(const AllBookmarkPage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.history_rounded,
                        iconColor: const Color(0xFFEC4899),
                        title: '阅读记录',
                        subtitle: '查看最近阅读历史',
                        onTap: () => _navigateTo(const ReadRecordPage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.storage_rounded,
                        iconColor: const Color(0xFF06B6D4),
                        title: '缓存管理',
                        subtitle: '管理书籍缓存与空间占用',
                        onTap: () => _navigateTo(const CacheManagePage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.folder_outlined,
                        iconColor: const Color(0xFF1677FF),
                        title: '文件管理',
                        subtitle: '浏览本地文件与导入目录',
                        onTap: () => _navigateTo(const FileManagePage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        iconColor: const Color(0xFF06B6D4),
                        title: '帮助',
                        subtitle: '查看使用说明',
                        onTap: () => _navigateTo(const HelpPage()),
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        iconColor: const Color(0xFF22C55E),
                        title: '关于',
                        trailing: Text(
                          'v2.2.0',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: HomePalette.tertiaryText(context),
                          ),
                        ),
                        onTap: () => _navigateTo(const AboutPage()),
                      ),
                      if (Theme.of(context).platform ==
                              TargetPlatform.android ||
                          Theme.of(context).platform == TargetPlatform.iOS)
                        _buildMenuItem(
                          icon: Icons.exit_to_app_rounded,
                          iconColor: const Color(0xFFE34D59),
                          title: '退出',
                          subtitle: '退出当前应用',
                          onTap: () => _showExitDialog(context),
                        ),
                    ]),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: HomePalette.tertiaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 34,
      width: 1,
      color: HomePalette.lineColor(context),
    );
  }

  Widget _buildMenuSection(List<Widget> children) {
    return HomeSectionCard(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(children: _insertDividers(children)),
      ),
    );
  }

  List<Widget> _insertDividers(List<Widget> children) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Container(
          height: 1,
          margin: const EdgeInsets.only(left: 64, right: 16),
          color: HomePalette.lineColor(context),
        ));
      }
    }
    return result;
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
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
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
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
                      fontWeight: FontWeight.w600,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: HomePalette.tertiaryText(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebServiceTile(bool enabled, WidgetRef ref) {
    final manager = WebServiceManager.instance;

    return GestureDetector(
      onLongPress: enabled ? () => _showWebServiceMenu(context, ref) : null,
      child: InkWell(
        onTap: () async {
          await ref.read(webServiceProvider.notifier).setWebService(!enabled);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1677FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.language_rounded,
                  size: 20,
                  color: const Color(0xFF1677FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Web服务',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getWebServiceSubtitle(enabled, manager),
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (value) async {
                  await ref
                      .read(webServiceProvider.notifier)
                      .setWebService(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getWebServiceSubtitle(bool enabled, WebServiceManager manager) {
    if (!enabled) return '开启Web服务';
    if (manager.isRunning && manager.hostAddress != null) {
      return manager.hostAddress!;
    }
    return 'Web服务已开启';
  }

  Widget _buildSectionLabel(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
      child: HomeSectionTitle(
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  Widget _buildTopAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: HomePalette.card(context).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          child: Icon(
            icon,
            size: 20,
            color: HomePalette.primaryText(context),
          ),
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  void _showThemeModeDialog(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.read(themeModeProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('浅色'),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  setThemeMode(ref, value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('深色'),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  setThemeMode(ref, value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('跟随系统'),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  setThemeMode(ref, value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWebServiceMenu(BuildContext context, WidgetRef ref) {
    final manager = WebServiceManager.instance;
    if (!manager.isRunning || manager.hostAddress == null) {
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制地址'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: manager.hostAddress!));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('地址已复制到剪贴板')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('浏览器打开'),
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse(manager.hostAddress!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('无法打开链接: ${manager.hostAddress}')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出应用'),
        content: const Text('确定要退出应用吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

/// Web服务Provider
final webServiceProvider = NotifierProvider<WebServiceNotifier, bool>(() {
  return WebServiceNotifier();
});

/// Web服务Notifier
class WebServiceNotifier extends Notifier<bool> {
  @override
  bool build() {
    return AppConfig.getWebService();
  }

  Future<void> setWebService(bool value) async {
    await AppConfig.setWebService(value);
    state = value;

    // 启动/停止Web服务
    if (value) {
      final success = await WebServiceManager.instance.start();
      if (!success) {
        // 如果启动失败，恢复状态
        await AppConfig.setWebService(false);
        state = false;
      }
    } else {
      await WebServiceManager.instance.stop();
    }
  }
}
