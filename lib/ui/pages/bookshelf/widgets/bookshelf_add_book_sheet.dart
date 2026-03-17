import 'package:flutter/material.dart';

/// 添加书籍底部弹层：搜索在线 / 导入本地，与参考项目添加书籍入口一致。
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
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.blue),
              ),
              title: const Text(
                '搜索在线书籍',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('从书源搜索并添加书籍'),
              onTap: () {
                Navigator.pop(context);
                onSearchOnline();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder, color: Colors.orange),
              ),
              title: const Text(
                '导入本地书籍',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('从本地文件导入TXT/EPUB书籍'),
              onTap: () {
                Navigator.pop(context);
                onImportLocal();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
