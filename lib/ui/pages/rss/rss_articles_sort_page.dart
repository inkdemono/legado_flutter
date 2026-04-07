import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/rss_source.dart';
import '../../../data/models/rss_article.dart';
import '../../../utils/helpers/source/rss_source_extensions.dart';
import 'rss_article_item_widget.dart';
import 'rss_read_page.dart';
import '../../widgets/common/custom_tab_bar.dart';

/// RSS文章排序/分类页面
/// 参考项目：RssSortActivity.kt
/// 支持多个分类Tab，每个Tab显示对应分类的文章列表
class RssArticlesSortPage extends ConsumerStatefulWidget {
  final RssSource source;

  const RssArticlesSortPage({
    super.key,
    required this.source,
  });

  @override
  ConsumerState<RssArticlesSortPage> createState() =>
      _RssArticlesSortPageState();
}

class _RssArticlesSortPageState extends ConsumerState<RssArticlesSortPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<MapEntry<String, String>> _sortList = [];
  bool _isLoading = true;
  final Map<String, List<RssArticle>> _articlesBySort = {};
  final Set<String> _loadingSorts = {};
  final Map<String, Object> _errorsBySort = {};

  @override
  void initState() {
    super.initState();
    _loadSortUrls();
  }

  Future<void> _loadSortUrls() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sortUrls = await widget.source.sortUrls();
      if (mounted) {
        setState(() {
          _sortList = sortUrls;
          _tabController?.dispose();
          _tabController = _sortList.isEmpty
              ? null
              : TabController(
                  length: _sortList.length,
                  vsync: this,
                );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载分类失败: $e')),
        );
      }
    }
  }

  Future<void> _clearSortCache() async {
    await widget.source.removeSortCache();
    if (!mounted) return;
    _articlesBySort.clear();
    _errorsBySort.clear();
    await _loadSortUrls();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已清除分类缓存')),
    );
  }

  String _sortKey(String sortName, String sortUrl) => '$sortName::$sortUrl';

  Future<void> _loadArticles(
    String sortName,
    String sortUrl, {
    bool force = false,
  }) async {
    final key = _sortKey(sortName, sortUrl);
    if (!force && (_articlesBySort.containsKey(key) || _loadingSorts.contains(key))) {
      return;
    }

    setState(() {
      _loadingSorts.add(key);
      if (force) {
        _errorsBySort.remove(key);
      }
    });

    try {
      final articles = await readService(AppServices.rssParserService).getArticles(
        source: widget.source,
        sortName: sortName,
        sortUrl: sortUrl,
      );
      if (!mounted) return;
      setState(() {
        _articlesBySort[key] = articles;
        _errorsBySort.remove(key);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorsBySort[key] = e;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingSorts.remove(key);
        });
      }
    }
  }

  Future<void> _openArticle(
    String sortName,
    String sortUrl,
    RssArticle article,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RssReadPage(
          source: widget.source,
          article: article,
        ),
      ),
    );

    final key = _sortKey(sortName, sortUrl);
    final current = _articlesBySort[key];
    if (current == null || !mounted) {
      return;
    }
    setState(() {
      _articlesBySort[key] = current
          .map((item) => item.link == article.link ? item.copyWith(read: true) : item)
          .toList();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.source.sourceName),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 如果只有一个分类，直接显示文章列表
    if (_sortList.length == 1) {
      final sort = _sortList.first;
      return _buildArticlesList(sort.key, sort.value);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.source.sourceName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearSortCache,
            tooltip: '刷新分类',
          ),
        ],
        bottom: CustomTabBar(
          controller: _tabController!,
          isScrollable: _sortList.length > 3,
          tabs: _sortList.map((sort) {
            final name = sort.key.isEmpty ? '全部' : sort.key;
            return Tab(text: name);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController!,
        children: _sortList.map((sort) {
          return _buildArticlesList(sort.key, sort.value);
        }).toList(),
      ),
    );
  }

  Widget _buildArticlesList(String sortName, String sortUrl) {
    final key = _sortKey(sortName, sortUrl);
    final articles = _articlesBySort[key];
    final error = _errorsBySort[key];
    final isLoading = _loadingSorts.contains(key);

    if (articles == null && error == null && !isLoading) {
      _loadArticles(sortName, sortUrl);
    }

    if (isLoading && articles == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && articles == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('加载失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadArticles(sortName, sortUrl, force: true),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final resolved = articles ?? const <RssArticle>[];
    if (resolved.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无文章',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadArticles(sortName, sortUrl, force: true),
      child: ListView.builder(
        itemCount: resolved.length,
        itemBuilder: (context, index) {
          final article = resolved[index];
          return RssArticleItemWidget(
            article: article,
            sourceName: widget.source.sourceName,
            onTap: () => _openArticle(sortName, sortUrl, article),
          );
        },
      ),
    );
  }
}
