import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/md3_theme.dart';

/// 现代化书架示例页面 - 展示 Material Design 3 风格
class ModernBookshelfDemo extends ConsumerStatefulWidget {
  const ModernBookshelfDemo({super.key});

  @override
  ConsumerState<ModernBookshelfDemo> createState() =>
      _ModernBookshelfDemoState();
}

class _ModernBookshelfDemoState extends ConsumerState<ModernBookshelfDemo> {
  int _selectedGroupIndex = 0;
  final List<String> _groups = ['全部', '收藏', '在读', '完结'];
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MD3Palette.background(context),
      body: CustomScrollView(
        slivers: [
          // 毛玻璃效果顶栏
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: MD3Palette.surface(context).withValues(alpha: 0.9),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: MD3Palette.surface(context).withValues(alpha: 0.7),
                      border: Border(
                        bottom: BorderSide(
                          color: MD3Palette.outlineVariant(context),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '我的书架',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: MD3Palette.onSurface(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '共 12 本书籍',
                              style: TextStyle(
                                fontSize: 14,
                                color: MD3Palette.onSurfaceVariant(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                icon: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                  color: MD3Palette.onSurface(context),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search_rounded,
                  color: MD3Palette.onSurface(context),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: MD3Palette.onSurface(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) {},
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'manage',
                    child: ListTile(
                      leading: Icon(Icons.manage_accounts_outlined),
                      title: Text('书架管理'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text('布局设置'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 分组标签
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _groups.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedGroupIndex;
                    return MDPillChip(
                      label: _groups[index],
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedGroupIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // 搜索框
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: MD3SearchField(
                hintText: '搜索书籍...',
                onChanged: (value) {},
              ),
            ),
          ),

          // 书籍网格
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: _isGridView
                ? _buildGridBooks()
                : _buildListBooks(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: MD3Palette.primaryContainer(context),
        foregroundColor: MD3Palette.onPrimaryContainer(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('添加书籍'),
      ),
    );
  }

  SliverGrid _buildGridBooks() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildBookCard(index),
        childCount: 8,
      ),
    );
  }

  SliverList _buildListBooks() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildBookListItem(index),
        childCount: 8,
      ),
    );
  }

  Widget _buildBookCard(int index) {
    return MD3Card(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: MD3Palette.surfaceVariant(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 48,
                  color: MD3Palette.onSurfaceVariant(context).withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          // 信息
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '斗破苍穹 ${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: MD3Palette.onSurface(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '天蚕土豆',
                  style: TextStyle(
                    fontSize: 12,
                    color: MD3Palette.onSurfaceVariant(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.6 + index * 0.05,
                  backgroundColor: MD3Palette.surfaceVariant(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    MD3Palette.primary(context),
                  ),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookListItem(int index) {
    return MD3Card(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 封面缩略图
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: MD3Palette.surfaceVariant(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.menu_book_rounded,
                size: 32,
                color: MD3Palette.onSurfaceVariant(context).withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '斗破苍穹 ${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MD3Palette.onSurface(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '天蚕土豆',
                  style: TextStyle(
                    fontSize: 13,
                    color: MD3Palette.onSurfaceVariant(context),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.6 + index * 0.05,
                        backgroundColor: MD3Palette.surfaceVariant(context),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          MD3Palette.primary(context),
                        ),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${((0.6 + index * 0.05) * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: MD3Palette.primary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_rounded,
              color: MD3Palette.onSurfaceVariant(context),
            ),
          ),
        ],
      ),
    );
  }
}
