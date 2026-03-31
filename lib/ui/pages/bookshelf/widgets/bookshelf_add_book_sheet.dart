import 'package:flutter/material.dart';

/// 添加书籍底部弹层：搜索在线 / 导入本地。
class BookshelfAddBookSheet extends StatelessWidget {
  const BookshelfAddBookSheet({
    super.key,
    required this.onSearchOnline,
    required this.onImportLocal,
  });

  final VoidCallback onSearchOnline;
  final VoidCallback onImportLocal;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F2329).withValues(alpha: 0.16),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D7E2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '添加书籍',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2329),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '这个弹层只承载路径选择，不混入过多配置项，保证点击后马上进入下一步。',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF86909C),
              ),
            ),
            const SizedBox(height: 18),
            _ActionCard(
              icon: Icons.search_rounded,
              title: '搜索在线书籍',
              description: '从书源里搜索作品并直接加入书架，适合第一次使用或找新书。',
              gradientColors: const [Color(0xFF1677FF), Color(0xFF69B1FF)],
              actionLabel: '进入搜索',
              onTap: () {
                Navigator.of(context).pop();
                onSearchOnline();
              },
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.folder_open_rounded,
              title: '导入本地书籍',
              description: '从设备文件中导入 TXT、EPUB 等内容，适合已有本地收藏的用户。',
              gradientColors: const [Color(0xFFFA8C16), Color(0xFFFFB65C)],
              actionLabel: '选择文件',
              onTap: () {
                Navigator.of(context).pop();
                onImportLocal();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final String actionLabel;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEDF0F4)),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2329),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF86909C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: gradientColors.first,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB8BEC8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
