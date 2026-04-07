import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/rss_article.dart';
import '../../../data/models/rss_source.dart';
import '../../../services/rss_service.dart';
import '../../../utils/helpers/source/rss_source_extensions.dart';
import 'rss_source_manage_page.dart';
import 'rss_articles_page.dart';
import 'rss_articles_sort_page.dart';
import 'rss_favorites_page.dart';
import 'rss_read_page.dart';
import '../../widgets/home/home_shell.dart';

/// RSS源列表Provider（仅启用的）
final enabledRssSourceListProvider =
    FutureProvider<List<RssSource>>((ref) async {
  final service = readService(AppServices.rssService);
  return await service.getEnabledRssSources();
});

/// RSS订阅页面
class RssPage extends ConsumerWidget {
  final bool embedded;

  const RssPage({
    super.key,
    this.embedded = false,
  });

  Future<void> _openSingleUrlSource(
    BuildContext context,
    RssSource source,
  ) async {
    final sortUrls = await source.sortUrls();
    final firstEntry =
        sortUrls.isNotEmpty ? sortUrls.first : MapEntry('', source.sourceUrl);
    final resolvedUrl = firstEntry.value.trim().isNotEmpty
        ? firstEntry.value.trim()
        : source.sourceUrl;

    if (resolvedUrl.startsWith('http://') ||
        resolvedUrl.startsWith('https://')) {
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RssReadPage(
            source: source,
            article: RssArticle(
              origin: source.sourceUrl,
              link: resolvedUrl,
              title: firstEntry.key.isNotEmpty
                  ? firstEntry.key
                  : source.sourceName,
            ),
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(resolvedUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rssSourcesAsync = ref.watch(enabledRssSourceListProvider);
    final content = rssSourcesAsync.when(
      data: (sources) => _buildContent(context, ref, sources),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('加载失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(enabledRssSourceListProvider);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('订阅')),
      body: content,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<RssSource> sources,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: HomeSectionCard(
            margin: EdgeInsets.zero,
            color: HomePalette.mutedCard(context),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildMetric(context, '${sources.length}', '已启用源'),
                    const SizedBox(width: 10),
                    _buildMetric(
                      context,
                      '${sources.where((s) => s.singleUrl).length}',
                      '单页源',
                    ),
                    const SizedBox(width: 10),
                    _buildMetric(
                      context,
                      '${sources.where((s) => (s.sortUrl ?? '').isNotEmpty).length}',
                      '分类源',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildToolButton(
                        context,
                        icon: Icons.star_outline_rounded,
                        label: '收藏',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RssFavoritesPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildToolButton(
                        context,
                        icon: Icons.settings_outlined,
                        label: '源管理',
                        onTap: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => const RssSourceManagePage(),
                            ),
                          )
                              .then((_) {
                            ref.invalidate(enabledRssSourceListProvider);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: sources.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rss_feed_rounded,
                          size: 64,
                          color: HomePalette.tertiaryText(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无 RSS 源',
                          style: TextStyle(
                            color: HomePalette.secondaryText(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RssSourceManagePage(),
                              ),
                            )
                                .then((_) {
                              ref.invalidate(enabledRssSourceListProvider);
                            });
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('添加 RSS 源'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: sources.length,
                  itemBuilder: (context, index) {
                    final source = sources[index];
                    return HomeSectionCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          if (source.singleUrl) {
                            await _openSingleUrlSource(context, source);
                            return;
                          }

                          if (source.sortUrl != null &&
                              source.sortUrl!.isNotEmpty) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RssArticlesSortPage(source: source),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RssArticlesPage(source: source),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: index.isEven
                                      ? const [
                                          Color(0xFF4F7CFF),
                                          Color(0xFF7C5CFF),
                                        ]
                                      : const [
                                          Color(0xFF38BDF8),
                                          Color(0xFF0EA5E9),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.rss_feed_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    source.sourceName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: HomePalette.primaryText(context),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    source.sourceGroup?.isNotEmpty == true
                                        ? source.sourceGroup!
                                        : (source.singleUrl
                                            ? '单页订阅源'
                                            : '列表订阅源'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: HomePalette.tertiaryText(context),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    source.sourceUrl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: HomePalette.secondaryText(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: source.enabled,
                              onChanged: (enabled) async {
                                await readService(AppServices.rssService)
                                    .updateRssSourceEnabled(
                                  source.sourceUrl,
                                  enabled,
                                );
                                ref.invalidate(enabledRssSourceListProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMetric(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: HomePalette.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HomePalette.lineColor(context)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: HomePalette.primaryText(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: HomePalette.tertiaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: HomePalette.accentStrong,
        side: BorderSide(color: HomePalette.lineColor(context)),
        backgroundColor: HomePalette.card(context),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
