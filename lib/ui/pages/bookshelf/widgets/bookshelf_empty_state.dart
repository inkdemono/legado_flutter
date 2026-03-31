import 'package:flutter/material.dart';

/// 书架空状态展示，与参考项目书架空态一致。
class BookshelfEmptyState extends StatelessWidget {
  const BookshelfEmptyState({
    super.key,
    required this.onSearchOnline,
    required this.onImportLocal,
  });

  final VoidCallback onSearchOnline;
  final VoidCallback onImportLocal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x24165DFF),
                    Color(0x144096FF),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14165DFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 62,
                  color: Color(0xFF165DFF),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '书架还没有书',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2329),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '空态直接给出两条主路径：去搜索在线书籍，或者导入本地文件，减少第一次进入时的决策成本。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF86909C),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSearchOnline,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF165DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('搜索在线书籍'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onImportLocal,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF165DFF),
                  side: const BorderSide(color: Color(0xFFD6E4FF)),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('导入本地书籍'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
