import 'package:flutter/material.dart';

import '../../../data/models/rss_article.dart';
import '../../widgets/home/home_shell.dart';

/// RSS文章项组件
class RssArticleItemWidget extends StatelessWidget {
  final RssArticle article;
  final String sourceName;
  final VoidCallback onTap;

  const RssArticleItemWidget({
    super.key,
    required this.article,
    required this.sourceName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = article.title.trim().isEmpty ? '未命名文章' : article.title.trim();
    final description =
        (article.description ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    final pubDate = (article.pubDate ?? '').trim();
    final sort = article.sort.trim();
    final group = article.group.trim();
    final metaTags = <String>[
      if (sort.isNotEmpty) sort,
      if (group.isNotEmpty && group != '默认分组' && group != sort) group,
      if (article.image != null && article.image!.isNotEmpty) '含图',
    ];

    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeading(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sort.isNotEmpty ? sort : sourceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pubDate.isNotEmpty ? pubDate : '暂无发布时间',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w800,
              color: article.read
                  ? HomePalette.secondaryText(context)
                  : HomePalette.primaryText(context),
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: HomePalette.secondaryText(context),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: metaTags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: HomePalette.mutedCard(context),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: HomePalette.lineColor(context),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: HomePalette.tertiaryText(context),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: HomePalette.tertiaryText(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    final imageUrl = article.image?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackIcon();
                },
              )
            : _buildFallbackIcon(),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return const Center(
      child: Icon(
        Icons.rss_feed_rounded,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isRead = article.read;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isRead ? const Color(0xFFF2F3F5) : const Color(0xFFEEF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isRead ? '已读' : '未读',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isRead ? const Color(0xFF86909C) : const Color(0xFF165DFF),
        ),
      ),
    );
  }
}
