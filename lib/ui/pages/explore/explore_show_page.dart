import 'package:cached_network_image/cached_network_image.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/book.dart';
import '../../../data/models/book_source.dart';
import '../../../services/explore_service.dart';
import '../../../services/network/network_service.dart';
import '../../widgets/home/home_shell.dart';
import '../bookshelf/book_info/book_info_page.dart';

/// 发现分类书籍列表页面
class ExploreShowPage extends ConsumerStatefulWidget {
  final BookSource bookSource;
  final String exploreName;
  final String exploreUrl;

  const ExploreShowPage({
    super.key,
    required this.bookSource,
    required this.exploreName,
    required this.exploreUrl,
  });

  @override
  ConsumerState<ExploreShowPage> createState() => _ExploreShowPageState();
}

class _ExploreShowPageState extends ConsumerState<ExploreShowPage> {
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String?>> _books = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBooks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || _isLoading || !_hasMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 280) {
      _loadMore();
    }
  }

  Future<void> _loadBooks({bool loadMore = false}) async {
    if (_isLoading) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      if (!loadMore) {
        _page = 1;
        _books = [];
        _hasMore = true;
      }
    });

    try {
      final books = await readService(AppServices.exploreService).exploreBooks(
        widget.bookSource,
        widget.exploreUrl,
        page: _page,
      );

      if (!mounted) return;
      setState(() {
        if (loadMore) {
          _books.addAll(books);
        } else {
          _books = books;
        }
        _hasMore = books.isNotEmpty;
        if (books.isNotEmpty) {
          _page++;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading || _isLoadingMore) return;
    _isLoadingMore = true;
    await _loadBooks(loadMore: true);
    _isLoadingMore = false;
  }

  Future<void> _showBookInfo(Map<String, String?> bookData) async {
    final nameRaw = bookData['name'] ?? '';
    final authorRaw = bookData['author'] ?? '';
    var bookUrl = bookData['bookUrl'] ?? '';
    final coverUrlRaw = bookData['coverUrl'];
    final introRaw = bookData['intro'] ?? '';
    final infoHtml = bookData['infoHtml'];
    final variable = bookData['variable'];

    final name = nameRaw.trim().isNotEmpty ? nameRaw.trim() : '未知书籍';
    var author = authorRaw.trim();
    if (author.startsWith('作者：') || author.startsWith('作者:')) {
      author = author.replaceFirst(RegExp(r'^作者[：:]'), '').trim();
    }
    final finalAuthor = author.isNotEmpty ? author : '未知作者';

    String? coverUrl;
    if (coverUrlRaw != null && coverUrlRaw.isNotEmpty) {
      coverUrl = NetworkService.joinUrl(
        widget.bookSource.bookSourceUrl,
        coverUrlRaw,
      );
    }

    final intro = introRaw.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (bookUrl.isEmpty) {
      if (coverUrl != null && coverUrl.isNotEmpty) {
        final coverUrlPattern = RegExp(r'/files/article/image/(\d+)/(\d+)/');
        final match = coverUrlPattern.firstMatch(coverUrl);
        if (match != null) {
          final bookId = '${match.group(1)}_${match.group(2)}';
          try {
            final sourceUri = Uri.parse(widget.bookSource.bookSourceUrl);
            var host = sourceUri.host;
            if (host.startsWith('www.')) {
              host = 'm.${host.substring(4)}';
            }
            bookUrl = '${sourceUri.scheme}://$host/$bookId/';
          } catch (_) {}
        }
      }
    } else {
      bookUrl = NetworkService.joinUrl(widget.bookSource.bookSourceUrl, bookUrl);
    }

    if (bookUrl.isEmpty) {
      _showMessage('书籍URL为空，无法打开详情');
      return;
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookInfoPage(
          key: ValueKey('book_info_$bookUrl'),
          bookUrl: bookUrl,
          bookName: name,
          author: finalAuthor,
          sourceUrl: widget.bookSource.bookSourceUrl,
          coverUrl: coverUrl,
          intro: intro.isNotEmpty ? intro : null,
          initialInfoHtml: infoHtml,
          initialVariable: variable,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadBooks(),
                  child: _buildBody(context),
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
                  widget.exploreName,
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
                  widget.bookSource.bookSourceName,
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
            icon: Icons.refresh_rounded,
            onTap: () => _loadBooks(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null && _books.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _buildBanner(context),
          const SizedBox(height: 24),
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
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _loadBooks(),
                  child: const Text('重试'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      );
    }

    if (_isLoading && _books.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _books.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildBanner(context),
          );
        }

        if (index == _books.length + 1) {
          if (_isLoadingMore) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 18),
              child: Center(
                child: Text(
                  '正在加载更多内容…',
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
              ),
            );
          }

          if (!_hasMore && _books.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 18),
              child: Center(
                child: Text(
                  '没有更多内容了',
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
              ),
            );
          }

          if (_books.isEmpty) {
            return HomeSectionCard(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    Icons.menu_book_outlined,
                    size: 52,
                    color: HomePalette.tertiaryText(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无书籍',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: HomePalette.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '当前分类下还没有可展示的内容',
                    style: TextStyle(
                      fontSize: 13,
                      color: HomePalette.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }

          return const SizedBox(height: 24);
        }

        final bookData = _books[index - 1];
        return _ExploreBookCard(
          bookData: bookData,
          sourceUrl: widget.bookSource.bookSourceUrl,
          onTap: () => _showBookInfo(bookData),
        );
      },
    );
  }

  Widget _buildBanner(BuildContext context) {
    final tags = <String>[
      widget.bookSource.bookSourceName,
      if (_books.isNotEmpty) '${_books.length} 本',
      if (_hasMore || _isLoadingMore) '支持分页',
      if (_error == null) '可刷新',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFF67E8F9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.bookSource.bookSourceName} · ${widget.exploreName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '来源、分类名称和结果状态集中在顶部，进入二级列表后也能立刻知道当前来自哪个书源。',
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
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
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
}

class _ExploreBookCard extends StatelessWidget {
  final Map<String, String?> bookData;
  final String sourceUrl;
  final VoidCallback onTap;

  const _ExploreBookCard({
    required this.bookData,
    required this.sourceUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nameRaw = bookData['name'] ?? '';
    final authorRaw = bookData['author'] ?? '';
    final introRaw = bookData['intro'] ?? '';
    final kind = (bookData['kind'] ?? '').trim();
    final wordCount = (bookData['wordCount'] ?? '').trim();
    final lastChapter = (bookData['lastChapter'] ?? '').trim();
    final coverUrlRaw = bookData['coverUrl'];

    final name = nameRaw.trim().isNotEmpty ? nameRaw.trim() : '未知书籍';
    var author = authorRaw.trim();
    if (author.startsWith('作者：') || author.startsWith('作者:')) {
      author = author.replaceFirst(RegExp(r'^作者[：:]'), '').trim();
    }
    author = author.isNotEmpty ? author : '未知作者';
    final intro = introRaw.trim().replaceAll(RegExp(r'\s+'), ' ');

    String? fullCoverUrl;
    if (coverUrlRaw != null && coverUrlRaw.isNotEmpty) {
      fullCoverUrl = NetworkService.joinUrl(sourceUrl, coverUrlRaw);
    }

    final tags = <String>[
      if (kind.isNotEmpty) kind,
      if (wordCount.isNotEmpty) wordCount,
      if (lastChapter.isNotEmpty) '最新',
    ];

    final previewBook = Book(
      bookUrl: bookData['bookUrl'] ?? '',
      name: name,
      author: author,
      coverUrl: fullCoverUrl,
      intro: intro,
      kind: kind,
      wordCount: wordCount,
      latestChapterTitle: lastChapter,
    );

    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCover(context, previewBook),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastChapter.isNotEmpty ? '$author · $lastChapter' : author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
                if (intro.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    intro,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: HomePalette.tertiaryText(context),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFEFF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (wordCount.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        wordCount,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(BuildContext context, Book book) {
    return Container(
      width: 72,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: HomePalette.mutedCard(context),
        border: Border.all(color: HomePalette.lineColor(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: book.displayCover != null && book.displayCover!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: book.displayCover!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _coverFallback(context),
                errorWidget: (context, url, error) => _coverFallback(context),
              )
            : _coverFallback(context),
      ),
    );
  }

  Widget _coverFallback(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF22C1C3), Color(0xFF144870)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book_rounded,
        color: Colors.white,
      ),
    );
  }
}
