import 'package:flutter/material.dart';

import '../../widgets/home/home_shell.dart';

/// 帮助页面
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_TutorialSection> _tutorialSections = const [
    _TutorialSection(
      title: '快速开始',
      items: [
        _TutorialItem(
          title: '1. 添加书源',
          content: '在“我的”页面进入书源管理，可以从网络、本地文件等方式导入书源。',
        ),
        _TutorialItem(
          title: '2. 搜索书籍',
          content: '在书架页打开搜索，输入书名或作者名即可在多个书源中查找内容。',
        ),
        _TutorialItem(
          title: '3. 开始阅读',
          content: '从搜索结果加入书架后，打开书籍即可开始阅读与缓存章节。',
        ),
      ],
    ),
    _TutorialSection(
      title: '书源管理',
      items: [
        _TutorialItem(
          title: '导入书源',
          content: '支持 URL、本地文件、二维码等方式导入，网络导入更方便后续更新。',
        ),
        _TutorialItem(
          title: '编辑书源',
          content: '打开书源详情后可以调整规则，并检查搜索、目录、正文是否正常。',
        ),
        _TutorialItem(
          title: '测试书源',
          content: '在编辑页内可以直接测试搜索和正文解析，定位失效规则更快。',
        ),
      ],
    ),
    _TutorialSection(
      title: '阅读设置',
      items: [
        _TutorialItem(
          title: '字体设置',
          content: '阅读页菜单支持调整字体大小、字体、行距、边距等版式参数。',
        ),
        _TutorialItem(
          title: '主题设置',
          content: '可以保存多套阅读主题，自定义主色、背景色和强调色。',
        ),
        _TutorialItem(
          title: '翻页方式',
          content: '支持点击、滑动、音量键翻页等多种交互方式。',
        ),
      ],
    ),
  ];

  final List<_FaqItem> _faqItems = const [
    _FaqItem(
      question: '如何添加书源？',
      answer: '在“我的”页面进入书源管理，点击右上角新增按钮后，可以选择网络导入、本地导入或手动添加。',
    ),
    _FaqItem(
      question: '为什么搜索不到书籍？',
      answer: '通常和书源失效、网络异常或关键词不准确有关，建议切换书源并重新尝试。',
    ),
    _FaqItem(
      question: '如何备份数据？',
      answer: '在“我的”页面进入备份恢复，可导出到本地或同步到 WebDAV，建议定期备份。',
    ),
    _FaqItem(
      question: '阅读时出现乱码怎么办？',
      answer: '可能是编码或书源正文规则问题，优先尝试切换书源或调整编码方式。',
    ),
    _FaqItem(
      question: '如何清除缓存？',
      answer: '在“我的”页面进入缓存管理后，可以清理全部缓存或单本书籍缓存。',
    ),
    _FaqItem(
      question: 'Web 服务如何使用？',
      answer: '开启“我的”页面中的 Web 服务开关后，会显示访问地址，可在浏览器中管理书籍与书源。',
    ),
    _FaqItem(
      question: '如何导入本地书籍？',
      answer: '可从书架菜单导入，也可以在文件管理页面直接将 TXT、EPUB 等文件导入书架。',
    ),
    _FaqItem(
      question: '替换规则如何使用？',
      answer: '替换规则用于净化正文和修正内容，可在“我的”页面进入替换规则管理。',
    ),
  ];

  final List<_FeatureItem> _featureItems = const [
    _FeatureItem(
      icon: Icons.book_outlined,
      title: '多源阅读',
      description: '支持多个书源，搜索和阅读时可自由切换。',
      color: Color(0xFF1890FF),
    ),
    _FeatureItem(
      icon: Icons.palette_outlined,
      title: '自定义主题',
      description: '提供多套阅读配色方案，并支持主题保存。',
      color: Color(0xFF722ED1),
    ),
    _FeatureItem(
      icon: Icons.bookmark_outline_rounded,
      title: '书签功能',
      description: '支持添加书签和摘录，方便回到关键段落。',
      color: Color(0xFFFA8C16),
    ),
    _FeatureItem(
      icon: Icons.history_rounded,
      title: '阅读记录',
      description: '自动记录阅读时间与最近访问书籍。',
      color: Color(0xFF52C41A),
    ),
    _FeatureItem(
      icon: Icons.cloud_upload_outlined,
      title: '数据备份',
      description: '支持本地备份和 WebDAV 云端同步。',
      color: Color(0xFF13C2C2),
    ),
    _FeatureItem(
      icon: Icons.volume_up_outlined,
      title: '朗读功能',
      description: '支持 TTS 朗读和播放控制。',
      color: Color(0xFFEB2F96),
    ),
  ];

  final List<_ShortcutSection> _shortcutSections = const [
    _ShortcutSection(
      title: '阅读页面',
      items: [
        _ShortcutItem(keyLabel: '左侧点击', action: '上一页'),
        _ShortcutItem(keyLabel: '右侧点击', action: '下一页'),
        _ShortcutItem(keyLabel: '中央点击', action: '显示或隐藏菜单'),
        _ShortcutItem(keyLabel: '音量键', action: '翻页，需要在设置中开启'),
        _ShortcutItem(keyLabel: '双击屏幕', action: '添加或删除书签'),
      ],
    ),
    _ShortcutSection(
      title: '书架页面',
      items: [
        _ShortcutItem(keyLabel: '长按书籍', action: '打开操作菜单'),
        _ShortcutItem(keyLabel: '点击搜索', action: '搜索书籍'),
        _ShortcutItem(keyLabel: '点击分组', action: '切换书籍分组'),
      ],
    ),
    _ShortcutSection(
      title: '其他页面',
      items: [
        _ShortcutItem(keyLabel: '返回键', action: '返回上一页或退出'),
        _ShortcutItem(keyLabel: '更多菜单', action: '显示更多操作'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF1677FF), Color(0xFF4F7CFF)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: HomePillTabBar(
                  controller: _tabController,
                  items: const [
                    HomeTabItem(label: '教程', icon: Icons.school_outlined),
                    HomeTabItem(label: '问题', icon: Icons.help_outline_rounded),
                    HomeTabItem(label: '功能', icon: Icons.widgets_outlined),
                    HomeTabItem(label: '快捷键', icon: Icons.keyboard_rounded),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTutorialTab(context),
                    _buildFaqTab(context),
                    _buildFeaturesTab(context),
                    _buildShortcutsTab(context),
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
                  '帮助',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '集中查看教程、常见问题和功能说明',
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

  Widget _buildTutorialTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildHeroCard(
          context,
          title: '快速上手',
          value: '${_tutorialSections.length} 个模块',
          subtitle: '覆盖书源、阅读和基础设置的常用路径',
          gradient: const [Color(0xFF1677FF), Color(0xFF4F7CFF)],
          metrics: const [
            _HeroMetric(value: '3', label: '章节'),
            _HeroMetric(value: '新手', label: '对象'),
            _HeroMetric(value: '必看', label: '优先级'),
          ],
        ),
        const SizedBox(height: 18),
        ..._tutorialSections
            .map((section) => _buildTutorialSectionCard(context, section)),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildFaqTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildHeroCard(
          context,
          title: '高频问题',
          value: '${_faqItems.length} 条',
          subtitle: '先看这里，通常能直接解决导入、搜索和备份相关问题',
          gradient: const [Color(0xFF22C55E), Color(0xFF14B8A6)],
          metrics: const [
            _HeroMetric(value: 'FAQ', label: '类型'),
            _HeroMetric(value: '自助', label: '处理'),
            _HeroMetric(value: '常见', label: '频率'),
          ],
        ),
        const SizedBox(height: 18),
        HomeSectionCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              children: _faqItems
                  .asMap()
                  .entries
                  .map((entry) => _buildFaqItem(context, entry.value,
                      isLast: entry.key == _faqItems.length - 1))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildFeaturesTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildHeroCard(
          context,
          title: '核心功能',
          value: '${_featureItems.length} 项',
          subtitle: '阅读、主题、缓存、备份等能力都在这里概览',
          gradient: const [Color(0xFF7C5CFF), Color(0xFF4F7CFF)],
          metrics: const [
            _HeroMetric(value: '阅读', label: '核心'),
            _HeroMetric(value: '效率', label: '目标'),
            _HeroMetric(value: '扩展', label: '方向'),
          ],
        ),
        const SizedBox(height: 18),
        ..._featureItems.map((item) => _buildFeatureCard(context, item)),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildShortcutsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildHeroCard(
          context,
          title: '快捷操作',
          value:
              '${_shortcutSections.fold<int>(0, (sum, section) => sum + section.items.length)} 条',
          subtitle: '熟悉这些交互后，翻页和定位会明显更快',
          gradient: const [Color(0xFFF59E0B), Color(0xFFFB7185)],
          metrics: const [
            _HeroMetric(value: '交互', label: '类型'),
            _HeroMetric(value: '效率', label: '收益'),
            _HeroMetric(value: '进阶', label: '阶段'),
          ],
        ),
        const SizedBox(height: 18),
        ..._shortcutSections
            .map((section) => _buildShortcutSectionCard(context, section)),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required List<Color> gradient,
    required List<_HeroMetric> metrics,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: metrics
                .map(
                  (metric) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: metric == metrics.last ? 0 : 10,
                      ),
                      child: _buildMetricCard(metric),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(_HeroMetric metric) {
    return Container(
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
            metric.value,
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
            metric.label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSectionCard(
      BuildContext context, _TutorialSection section) {
    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 14),
          ...section.items.asMap().entries.map((entry) {
            final isLast = entry.key == section.items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: _buildTutorialItem(context, entry.value),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTutorialItem(BuildContext context, _TutorialItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: HomePalette.primaryText(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.content,
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: HomePalette.secondaryText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem(BuildContext context, _FaqItem item,
      {required bool isLast}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: EdgeInsets.zero,
        iconColor: HomePalette.secondaryText(context),
        collapsedIconColor: HomePalette.tertiaryText(context),
        title: Text(
          item.question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: HomePalette.primaryText(context),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item.answer,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: HomePalette.secondaryText(context),
              ),
            ),
          ),
          if (!isLast)
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              height: 1,
              color: HomePalette.lineColor(context),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem item) {
    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  item.color,
                  Color.lerp(item.color, Colors.black, 0.18) ?? item.color,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutSectionCard(
      BuildContext context, _ShortcutSection section) {
    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 14),
          ...section.items.asMap().entries.map((entry) {
            final isLast = entry.key == section.items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: _buildShortcutItem(context, entry.value),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(BuildContext context, _ShortcutItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: HomePalette.accentSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            item.keyLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: HomePalette.accentStrong,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.action,
            style: TextStyle(
              fontSize: 13,
              color: HomePalette.secondaryText(context),
            ),
          ),
        ),
      ],
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

class _TutorialSection {
  final String title;
  final List<_TutorialItem> items;

  const _TutorialSection({
    required this.title,
    required this.items,
  });
}

class _TutorialItem {
  final String title;
  final String content;

  const _TutorialItem({
    required this.title,
    required this.content,
  });
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _ShortcutSection {
  final String title;
  final List<_ShortcutItem> items;

  const _ShortcutSection({
    required this.title,
    required this.items,
  });
}

class _ShortcutItem {
  final String keyLabel;
  final String action;

  const _ShortcutItem({
    required this.keyLabel,
    required this.action,
  });
}

class _HeroMetric {
  final String value;
  final String label;

  const _HeroMetric({
    required this.value,
    required this.label,
  });
}
