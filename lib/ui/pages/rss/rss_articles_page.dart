import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/rss_article.dart';
import '../../../data/models/rss_source.dart';
import '../../../services/rss_service.dart';
import '../../widgets/home/home_shell.dart';
import 'rss_article_item_widget.dart';
import 'rss_favorites_page.dart';
import 'rss_read_page.dart';
import 'rss_read_record_dialog.dart';

/// RSS文章列表Provider
final rssArticlesProvider =
    FutureProvider.family<List<RssArticle>, String?>((ref, origin) async {
  final service = readService(AppServices.rssService);
  return await service.getRssArticles(origin: origin, limit: 100);
});

enum _RssArticleViewMode {
  latest,
  unreadFirst,
  unreadOnly,
}

/// RSS文章列表页面
class RssArticlesPage extends ConsumerStatefulWidget {
  final RssSource source;

  const RssArticlesPage({
    super.key,
    required this.source,
  });

  @override
  ConsumerState<RssArticlesPage> createState() => _RssArticlesPageState();
}

class _RssArticlesPageState extends ConsumerState<RssArticlesPage> {
  _RssArticleViewMode _viewMode = _RssArticleViewMode.latest;
  bool _isRefreshing = false;

  Future<void> _refreshArticles() async {
    if (_isRefreshing) return;

    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      final count = await readService(AppServices.rssService).refreshRssArticles(widget.source);
      ref.invalidate(rssArticlesProvider(widget.source.sourceUrl));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('刷新完成，获取到 $count 篇文章'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('刷新失败: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _openReadRecord() {
    showDialog(
      context: context,
      builder: (context) => const RssReadRecordDialog(),
    );
  }

  Future<void> _openFavorites() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RssFavoritesPage(),
      ),
    );
  }

  Future<void> _openArticle(RssArticle article) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RssReadPage(
          source: widget.source,
          article: article,
        ),
      ),
    );

    ref.invalidate(rssArticlesProvider(widget.source.sourceUrl));
  }

  List<RssArticle> _resolveArticles(List<RssArticle> articles) {
    switch (_viewMode) {
      case _RssArticleViewMode.latest:
        return articles;
      case _RssArticleViewMode.unreadFirst:
        final reordered = [...articles];
        reordered.sort((a, b) {
          if (a.read == b.read) {
            return b.order.compareTo(a.order);
          }
          return a.read ? 1 : -1;
        });
        return reordered;
      case _RssArticleViewMode.unreadOnly:
        return articles.where((article) => !article.read).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync =
        ref.watch(rssArticlesProvider(widget.source.sourceUrl));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFFF97316), Color(0xFFFB923C)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: articlesAsync.when(
                  data: (articles) => RefreshIndicator(
                    onRefresh: _refreshArticles,
                    child: _buildBody(context, articles),
                  ),
                  loading: () => ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 220),
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                  error: (error, stack) => RefreshIndicator(
                    onRefresh: _refreshArticles,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        _buildHeroCard(
                          context,
                          totalCount: 0,
                          unreadCount: 0,
                          readCount: 0,
                        ),
                        const SizedBox(height: 18),
                        HomeSectionCard(
                          margin: EdgeInsets.zero,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Icon(
                                Icons.error_outline_rounded,
                                size: 52,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '加载失败',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: HomePalette.primaryText(context),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$error',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: HomePalette.secondaryText(context),
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () {
                                  ref.invalidate(
                                    rssArticlesProvider(
                                        widget.source.sourceUrl),
                                  );
                                },
                                child: const Text('重试'),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  widget.source.sourceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'RSS 文章列表',
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
            icon: Icons.history_rounded,
            onTap: _openReadRecord,
          ),
          const SizedBox(width: 8),
          _buildHeaderButton(
            context,
            icon: _isRefreshing ? Icons.sync_rounded : Icons.refresh_rounded,
            onTap: _refreshArticles,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<RssArticle> articles) {
    final resolvedArticles = _resolveArticles(articles);
    final unreadCount = articles.where((article) => !article.read).length;
    final readCount = articles.length - unreadCount;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildHeroCard(
          context,
          totalCount: articles.length,
          unreadCount: unreadCount,
          readCount: readCount,
        ),
        const SizedBox(height: 18),
        _buildFilterStrip(context),
        const SizedBox(height: 18),
        _buildSectionHeader(
          context,
          title: '文章摘要',
          subtitle: resolvedArticles.isEmpty
              ? '当前筛选条件下没有可显示的内容'
              : '保留源信息、阅读状态和摘要密度，点击即可进入正文阅读',
        ),
        const SizedBox(height: 10),
        if (resolvedArticles.isEmpty)
          HomeSectionCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.article_outlined,
                  size: 52,
                  color: HomePalette.tertiaryText(context),
                ),
                const SizedBox(height: 16),
                Text(
                  articles.isEmpty ? '暂无文章' : '没有匹配内容',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  articles.isEmpty
                      ? '下拉刷新后会重新抓取最新 RSS 内容'
                      : '切换为“最新文章”或“未读优先”可以查看全部结果',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _refreshArticles,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('刷新文章'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        else
          ...resolvedArticles.map(
            (article) => RssArticleItemWidget(
              article: article,
              sourceName: widget.source.sourceName,
              onTap: () => _openArticle(article),
            ),
          ),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required int totalCount,
    required int unreadCount,
    required int readCount,
  }) {
    final groupLabel = (widget.source.sourceGroup ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '订阅流概览',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.source.sourceName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '把刷新、筛选和阅读记录收在同一页里，进入列表后能快速判断哪些内容值得先看。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeroTag(widget.source.sourceName),
              if (groupLabel.isNotEmpty) _buildHeroTag(groupLabel),
              _buildHeroTag('最近 100 篇'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricCard(value: '$totalCount', label: '文章'),
              const SizedBox(width: 10),
              _buildMetricCard(value: '$unreadCount', label: '未读'),
              const SizedBox(width: 10),
              _buildMetricCard(value: '$readCount', label: '已读'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
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
                fontSize: 15,
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

  Widget _buildFilterStrip(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: '最新文章',
            isActive: _viewMode == _RssArticleViewMode.latest,
            onTap: () {
              setState(() {
                _viewMode = _RssArticleViewMode.latest;
              });
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: '未读优先',
            isActive: _viewMode == _RssArticleViewMode.unreadFirst,
            onTap: () {
              setState(() {
                _viewMode = _RssArticleViewMode.unreadFirst;
              });
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: '仅未读',
            isActive: _viewMode == _RssArticleViewMode.unreadOnly,
            onTap: () {
              setState(() {
                _viewMode = _RssArticleViewMode.unreadOnly;
              });
            },
          ),
          const SizedBox(width: 8),
          _buildActionChip(
            context,
            icon: Icons.star_outline_rounded,
            label: '收藏',
            onTap: _openFavorites,
          ),
          const SizedBox(width: 8),
          _buildActionChip(
            context,
            icon: Icons.history_rounded,
            label: '阅读记录',
            onTap: _openReadRecord,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isActive ? const Color(0xFFFFEDD5) : HomePalette.card(context),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFF97316).withValues(alpha: 0.24)
                  : HomePalette.lineColor(context),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? const Color(0xFFEA580C)
                  : HomePalette.secondaryText(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: HomePalette.card(context),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: HomePalette.secondaryText(context),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: HomePalette.secondaryText(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
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
