import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/read_record.dart';
import '../../../services/book/book_service.dart';
import '../../../services/read_record_service.dart';
import '../../widgets/home/home_shell.dart';
import '../reader/reader_page.dart';

/// 阅读记录页面
class ReadRecordPage extends ConsumerStatefulWidget {
  const ReadRecordPage({super.key});

  @override
  ConsumerState<ReadRecordPage> createState() => _ReadRecordPageState();
}

class _ReadRecordPageState extends ConsumerState<ReadRecordPage> {
  final TextEditingController _searchController = TextEditingController();

  List<ReadRecordShow> _records = [];
  bool _isLoading = true;
  int _sortMode = 0; // 0: 按书名, 1: 按阅读时长, 2: 按最后阅读时间
  int _allTime = 0;
  String _searchKey = '';
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadAllTime();
    _loadRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadAllTime() async {
    try {
      final allTime = await ReadRecordService.instance.getAllTime();
      if (!mounted) return;
      setState(() {
        _allTime = allTime;
      });
    } catch (_) {}
  }

  Future<void> _loadRecords({String? searchKey}) async {
    final currentVersion = ++_loadVersion;
    final keyword = (searchKey ?? _searchKey).trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final records = keyword.isNotEmpty
          ? await ReadRecordService.instance.search(keyword)
          : await ReadRecordService.instance.getAllShow();

      records.sort((a, b) {
        switch (_sortMode) {
          case 1:
            return b.readTime.compareTo(a.readTime);
          case 2:
            return b.lastRead.compareTo(a.lastRead);
          default:
            return a.bookName.compareTo(b.bookName);
        }
      });

      if (!mounted || currentVersion != _loadVersion) return;
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || currentVersion != _loadVersion) return;
      setState(() {
        _isLoading = false;
      });
      _showMessage('加载阅读记录失败: $e');
    }
  }

  Future<void> _clearAllRecords() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除所有阅读记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ReadRecordService.instance.clear();
      await _loadAllTime();
      await _loadRecords();
      _showMessage('已清除所有阅读记录');
    } catch (e) {
      _showMessage('清除失败: $e');
    }
  }

  Future<void> _openRecord(ReadRecordShow record) async {
    try {
      final books = await BookService.instance.getBookshelfBooks();
      if (books.isEmpty) {
        _showMessage('当前书架为空，无法跳转');
        return;
      }

      dynamic targetBook;
      for (final book in books) {
        if (book.name == record.bookName) {
          targetBook = book;
          break;
        }
      }

      if (targetBook == null) {
        _showMessage('未找到书籍: ${record.bookName}');
        return;
      }

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReaderPage(
            book: targetBook,
            initialChapterIndex: targetBook.durChapterIndex,
          ),
        ),
      );
    } catch (e) {
      _showMessage('打开失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _records.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadAllTime();
                    await _loadRecords();
                  },
                  child: _buildBody(
                    context,
                    totalCount: totalCount,
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
      child: Column(
        children: [
          Row(
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
                      '阅读记录',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '查看阅读投入与最近回访的书籍',
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                tooltip: '更多操作',
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                color: HomePalette.card(context),
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: HomePalette.card(context).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: HomePalette.lineColor(context)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.tune_rounded,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'clear') {
                    _clearAllRecords();
                    return;
                  }

                  final mode = int.tryParse(value);
                  if (mode == null) return;
                  setState(() {
                    _sortMode = mode;
                  });
                  _loadRecords();
                },
                itemBuilder: (context) => [
                  _buildSortMenuItem(0, '按书名'),
                  _buildSortMenuItem(1, '按阅读时长'),
                  _buildSortMenuItem(2, '按最后阅读时间'),
                  if (_records.isNotEmpty) const PopupMenuDivider(),
                  if (_records.isNotEmpty)
                    const PopupMenuItem<String>(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text('清空记录'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          HomeSearchField(
            controller: _searchController,
            hintText: '搜索书名',
            onChanged: (value) {
              setState(() {
                _searchKey = value.trim();
              });
              _loadRecords(searchKey: _searchKey);
            },
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(int mode, String label) {
    return PopupMenuItem<String>(
      value: '$mode',
      child: Row(
        children: [
          Icon(
            _sortMode == mode
                ? Icons.check_rounded
                : Icons.radio_button_unchecked,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required int totalCount,
  }) {
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 220),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _buildHeroCard(context, totalCount: totalCount),
        const SizedBox(height: 18),
        _buildSectionHeader(
          context,
          title: _searchKey.isEmpty ? '记录列表' : '搜索结果',
          subtitle:
              _searchKey.isEmpty ? '轻点条目可回到对应书籍继续阅读' : '当前关键字：$_searchKey',
        ),
        const SizedBox(height: 10),
        if (_records.isEmpty)
          HomeSectionCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.history_toggle_off_rounded,
                  size: 52,
                  color: HomePalette.tertiaryText(context),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchKey.isEmpty ? '暂无阅读记录' : '没有匹配的阅读记录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchKey.isEmpty ? '开始阅读后会在这里自动累计数据' : '换个书名再试试',
                  style: TextStyle(color: HomePalette.secondaryText(context)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        else
          ..._records.map((record) => _buildRecordCard(context, record)),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required int totalCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F7CFF).withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '阅读投入',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDuration(_allTime),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricCard(
                value: '$totalCount',
                label: '记录',
              ),
              const SizedBox(width: 10),
              _buildMetricCard(
                value: _sortModeLabel,
                label: '排序',
              ),
              const SizedBox(width: 10),
              _buildMetricCard(
                value: _searchKey.isEmpty ? '全部' : '筛选中',
                label: '范围',
              ),
            ],
          ),
        ],
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
                fontSize: 14,
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

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
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
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, ReadRecordShow record) {
    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      onTap: () => _openRecord(record),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.bookName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      context,
                      icon: Icons.schedule_rounded,
                      text: _formatDuration(record.readTime),
                    ),
                    _buildInfoChip(
                      context,
                      icon: Icons.update_rounded,
                      text: _formatTime(record.lastRead),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: HomePalette.tertiaryText(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: HomePalette.mutedCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HomePalette.lineColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HomePalette.secondaryText(context)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: HomePalette.secondaryText(context),
            ),
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

  String get _sortModeLabel {
    switch (_sortMode) {
      case 1:
        return '时长';
      case 2:
        return '时间';
      default:
        return '书名';
    }
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;

    if (hours > 0) {
      return '$hours小时${minutes % 60}分钟';
    }
    if (minutes > 0) {
      return '$minutes分钟';
    }
    return '$seconds秒';
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
