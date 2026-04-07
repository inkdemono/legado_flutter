import 'dart:convert';
import 'package:legado_flutter/providers/service_registry.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/book_source.dart';
import '../../../services/source/book_source_service.dart';
import '../../../services/network/network_service.dart';
import '../../widgets/home/home_shell.dart';
import 'book_source_item_widget.dart';
import 'book_source_edit_page.dart';
import 'book_source_import_dialog.dart';
import 'book_source_group_manage_dialog.dart';
import 'check_source_page.dart';

class BookSourceManageNotifier extends AsyncNotifier<List<BookSource>> {
  IBookSourceService get _svc => readService(AppServices.bookSourceService);

  @override
  Future<List<BookSource>> build() => _svc.getAllBookSources();

  Future<void> reload({bool showLoading = false}) async {
    if (showLoading || !state.hasValue) {
      state = const AsyncValue.loading();
    }
    state = await AsyncValue.guard(_svc.getAllBookSources);
  }

  Future<void> toggleEnabled(BookSource source, bool enabled) async {
    final updatedSource = source.copyWith(enabled: enabled);
    await _svc.updateBookSource(updatedSource);
    state = AsyncValue.data(
      state.requireValue
          .map((item) =>
              item.bookSourceUrl == source.bookSourceUrl ? updatedSource : item)
          .toList(),
    );
  }

  Future<void> delete(String url) async {
    await _svc.deleteBookSource(url);
    state = AsyncValue.data(
      state.requireValue.where((item) => item.bookSourceUrl != url).toList(),
    );
  }

  Future<void> batchSetEnabled(List<String> urls, bool enabled) async {
    await _svc.batchSetEnabled(urls, enabled);
    final urlSet = urls.toSet();
    state = AsyncValue.data(
      state.requireValue
          .map((item) => urlSet.contains(item.bookSourceUrl)
              ? item.copyWith(enabled: enabled)
              : item)
          .toList(),
    );
  }

  Future<void> batchDelete(List<String> urls) async {
    await _svc.batchDeleteBookSources(urls);
    final urlSet = urls.toSet();
    state = AsyncValue.data(
      state.requireValue
          .where((item) => !urlSet.contains(item.bookSourceUrl))
          .toList(),
    );
  }

  Future<void> batchSetGroup(List<String> urls, String? groupName) async {
    await _svc.batchSetGroup(urls, groupName);
    final urlSet = urls.toSet();
    state = AsyncValue.data(
      state.requireValue
          .map((item) => urlSet.contains(item.bookSourceUrl)
              ? item.copyWith(bookSourceGroup: groupName)
              : item)
          .toList(),
    );
  }
}

final bookSourceManageNotifierProvider =
    AsyncNotifierProvider<BookSourceManageNotifier, List<BookSource>>(
  BookSourceManageNotifier.new,
);

/// 书源管理页面
class BookSourceManagePage extends ConsumerStatefulWidget {
  const BookSourceManagePage({super.key});

  @override
  ConsumerState<BookSourceManagePage> createState() =>
      _BookSourceManagePageState();
}

enum BookSourceSort {
  defaultSort,
  name,
  url,
  weight,
  update,
  enable,
  respond,
}

class _BookSourceManagePageState extends ConsumerState<BookSourceManagePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _showSearchBar = false;
  bool _isBatchMode = false;
  Set<String> _selectedUrls = {};
  BookSourceSort _sortType = BookSourceSort.defaultSort;
  bool _sortAscending = true;
  List<BookSource> _currentFilteredSources = [];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookSourcesAsync = ref.watch(bookSourceManageNotifierProvider);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: HomePalette.background(context),
      appBar: AppBar(
        toolbarHeight: 60,
        leadingWidth: canPop ? 56 : 0,
        backgroundColor: HomePalette.card(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: canPop
            ? Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              )
            : null,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('书源管理'),
        ),
        actions: [
          if (_isBatchMode)
            Center(
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showSearchBar = false;
                    _isBatchMode = false;
                    _selectedUrls.clear();
                  });
                },
              ),
            )
          else ...[
            Center(child: _buildAppBarSearchAction()),
            Center(
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add',
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text('添加书源'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'import_local',
                    child: Row(
                      children: [
                        Icon(Icons.file_upload, size: 20),
                        SizedBox(width: 8),
                        Text('导入本地'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'import_online',
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 20),
                        SizedBox(width: 8),
                        Text('导入在线'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.file_download, size: 20),
                        SizedBox(width: 8),
                        Text('导出书源'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 8),
                        Text('分享书源'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'group_manage',
                    child: Row(
                      children: [
                        Icon(Icons.folder_open_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('分组管理'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'batch',
                    child: Row(
                      children: [
                        Icon(Icons.select_all, size: 20),
                        SizedBox(width: 8),
                        Text('批量操作'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'check',
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, size: 20),
                        SizedBox(width: 8),
                        Text('批量校验'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'add':
                      _addBookSource();
                      break;
                    case 'import_local':
                      _importFromLocal();
                      break;
                    case 'import_online':
                      _importFromOnline();
                      break;
                    case 'export':
                      _exportBookSources();
                      break;
                    case 'share':
                      _shareBookSources();
                      break;
                    case 'group_manage':
                      _showGroupManageDialog();
                      break;
                    case 'batch':
                      setState(() {
                        _isBatchMode = true;
                      });
                      break;
                    case 'check':
                      _startBatchCheck();
                      break;
                  }
                },
              ),
            ),
          ],
        ],
      ),
      body: bookSourcesAsync.when(
        data: (sources) {
          final filteredSources = _filterAndSortSourcesSync(sources);
          _currentFilteredSources = filteredSources;

          return SafeArea(
            top: false,
            child: Column(
              children: [
                _buildSearchSection(sources),
                _buildStatsBar(
                  totalCount: sources.length,
                  filteredCount: filteredSources.length,
                ),
                if (_isBatchMode) _buildBatchActionBar(),
                Expanded(
                  child: _buildBookSourceList(filteredSources),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState('加载失败: $error'),
      ),
      floatingActionButton: _isBatchMode
          ? null
          : SizedBox(
              width: 58,
              height: 58,
              child: FloatingActionButton(
                onPressed: _addBookSource,
                backgroundColor: const Color(0xFF6B63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
    );
  }

  void _addBookSource() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const BookSourceEditPage(),
      ),
    )
        .then((result) {
      if (result == true) {
        ref.read(bookSourceManageNotifierProvider.notifier).reload();
      }
    });
  }

  void _editBookSource(BookSource source) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => BookSourceEditPage(bookSource: source),
      ),
    )
        .then((result) {
      if (result == true) {
        ref.read(bookSourceManageNotifierProvider.notifier).reload();
      }
    });
  }

  Future<void> _toggleEnabled(BookSource source, bool enabled) async {
    try {
      await ref
          .read(bookSourceManageNotifierProvider.notifier)
          .toggleEnabled(source, enabled);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(enabled ? '已启用' : '已禁用')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $error')),
      );
    }
  }

  void _deleteBookSource(BookSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除书源'),
        content: Text('确定要删除书源 "${source.bookSourceName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(bookSourceManageNotifierProvider.notifier)
                    .delete(source.bookSourceUrl);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除成功')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                }
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _batchEnable(bool enabled) async {
    if (_selectedUrls.isEmpty) return;
    final count = _selectedUrls.length;

    try {
      await ref
          .read(bookSourceManageNotifierProvider.notifier)
          .batchSetEnabled(_selectedUrls.toList(), enabled);

      if (mounted) {
        setState(() {
          _isBatchMode = false;
          _selectedUrls.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已${enabled ? '启用' : '禁用'} $count 个书源')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  /// 全选当前显示的书源
  void _selectAll() {
    setState(() {
      _selectedUrls =
          _currentFilteredSources.map((source) => source.bookSourceUrl).toSet();
    });
  }

  Future<void> _startBatchCheck() async {
    final sources =
        await readService(AppServices.bookSourceService).getAllBookSources();
    if (sources.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有可校验的书源')),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CheckSourcePage(initialSources: sources),
        ),
      );
    }
  }

  Future<void> _batchSetGroup() async {
    if (_selectedUrls.isEmpty) return;

    final controller = TextEditingController();

    // 获取所有现有分组
    final allGroups =
        await readService(AppServices.bookSourceService).getAllGroups();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量设置分组'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('已选择 ${_selectedUrls.length} 个书源'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '分组名称',
                hintText: '输入分组名称（留空表示移除分组）',
                border: OutlineInputBorder(),
              ),
            ),
            if (allGroups.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('现有分组：',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allGroups
                    .map((group) => ActionChip(
                          label: Text(group),
                          onPressed: () {
                            controller.text = group;
                          },
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final groupName = controller.text.trim();

              try {
                final count = _selectedUrls.length;
                final normalizedGroupName =
                    groupName.isEmpty ? null : groupName;
                await ref
                    .read(bookSourceManageNotifierProvider.notifier)
                    .batchSetGroup(
                      _selectedUrls.toList(),
                      normalizedGroupName,
                    );

                if (mounted) {
                  setState(() {
                    _isBatchMode = false;
                    _selectedUrls.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(normalizedGroupName == null
                          ? '已移除 $count 个书源的分组'
                          : '已将 $count 个书源设置为分组: $normalizedGroupName'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('设置分组失败: $e')),
                  );
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _batchDelete() {
    if (_selectedUrls.isEmpty) return;

    final count = _selectedUrls.length;
    // 获取要删除的书源名称列表
    final selectedSources = _currentFilteredSources
        .where((source) => _selectedUrls.contains(source.bookSourceUrl))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量删除'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('确定要删除 $count 个书源吗？此操作不可恢复。'),
              if (selectedSources.isNotEmpty &&
                  selectedSources.length <= 10) ...[
                const SizedBox(height: 16),
                const Text(
                  '将要删除的书源：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...selectedSources.map((source) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${source.bookSourceName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    )),
              ] else if (selectedSources.length > 10) ...[
                const SizedBox(height: 16),
                const Text(
                  '将要删除的书源（前10个）：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...selectedSources.take(10).map((source) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${source.bookSourceName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    )),
                Text(
                  '... 还有 ${selectedSources.length - 10} 个书源',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(bookSourceManageNotifierProvider.notifier)
                    .batchDelete(_selectedUrls.toList());

                if (mounted) {
                  setState(() {
                    _isBatchMode = false;
                    _selectedUrls.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已删除 $count 个书源')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromLocal() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        if (mounted) {
          _showImportDialog(content);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  void _importFromOnline() {
    final controller = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('从在线导入'),
          content: isLoading
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在获取书源...'),
                  ],
                )
              : TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: '请输入书源URL或JSON内容',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  autofocus: true,
                ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final content = controller.text.trim();
                      if (content.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入URL或JSON内容')),
                        );
                        return;
                      }

                      // 如果是URL，尝试从网络获取
                      final uri = Uri.tryParse(content);
                      if (uri != null && uri.hasScheme) {
                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          final response =
                              await readService(AppServices.networkService).get(
                            content,
                            retryCount: 1,
                          );
                          final fetchedContent =
                              await NetworkService.getResponseText(response);

                          if (!mounted) return;
                          Navigator.pop(context);
                          _showImportDialog(fetchedContent);
                        } catch (e) {
                          if (!mounted) return;
                          setDialogState(() {
                            isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('获取失败: $e')),
                          );
                        }
                      } else {
                        // 直接作为JSON内容处理
                        Navigator.pop(context);
                        _showImportDialog(content);
                      }
                    },
              child: const Text('导入'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBookSources() async {
    try {
      final sources =
          await readService(AppServices.bookSourceService).getAllBookSources();

      if (sources.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有可导出的书源')),
        );
        return;
      }

      final jsonString = jsonEncode(sources.map((s) => s.toJson()).toList());

      final result = await FilePicker.platform.saveFile(
        dialogTitle: '导出书源',
        fileName: 'bookSource-${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonString);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('导出成功')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  /// 分享书源
  Future<void> _shareBookSources() async {
    try {
      List<BookSource> sources;

      // 如果处于批量模式且有选中项，只分享选中的书源
      if (_isBatchMode && _selectedUrls.isNotEmpty) {
        final allSources = await readService(AppServices.bookSourceService)
            .getAllBookSources();
        sources = allSources
            .where((s) => _selectedUrls.contains(s.bookSourceUrl))
            .toList();
      } else {
        // 否则分享所有书源
        sources = await readService(AppServices.bookSourceService)
            .getAllBookSources();
      }

      if (sources.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有可分享的书源')),
        );
        return;
      }

      final jsonString = jsonEncode(sources.map((s) => s.toJson()).toList());

      // 使用 share_plus 包分享
      await Share.share(
        jsonString,
        subject: '书源分享 (${sources.length}个)',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已分享 ${sources.length} 个书源')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }

  void _showImportDialog(String content) {
    showDialog(
      context: context,
      builder: (context) => BookSourceImportDialog(
        content: content,
        onImportComplete: () {
          ref.read(bookSourceManageNotifierProvider.notifier).reload();
        },
      ),
    );
  }

  Widget _buildSearchSection(List<BookSource> sources) {
    final enabledCount = sources.where((source) => source.enabled).length;
    final disabledCount = sources.length - enabledCount;
    final loginCount = sources
        .where((source) => (source.loginUrl?.trim().isNotEmpty ?? false))
        .length;
    final noGroupCount = sources
        .where((source) => source.bookSourceGroup?.trim().isNotEmpty != true)
        .length;
    final exploreCount =
        sources.where((source) => source.enabledExplore).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildFilterChip('全部 (${sources.length})', ''),
            _buildFilterChip('已启用 ($enabledCount)', '启用'),
            _buildFilterChip('未启用 ($disabledCount)', '禁用'),
            _buildFilterChip('需要登录 ($loginCount)', '需要登录'),
            _buildFilterChip('无分组 ($noGroupCount)', '无分组'),
            _buildFilterChip('启用发现 ($exploreCount)', '启用发现'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String query) {
    final selected = _isFilterSelected(query);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (selected && query.isNotEmpty) {
            _applySearchShortcut('');
            return;
          }

          _applySearchShortcut(query);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? HomePalette.accentSoft
                : HomePalette.background(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? HomePalette.accent.withValues(alpha: 0.18)
                  : HomePalette.lineColor(context),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? HomePalette.accentStrong
                  : HomePalette.secondaryText(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar({
    required int totalCount,
    required int? filteredCount,
  }) {
    final count = filteredCount ?? totalCount;
    final countText = _searchQuery.isEmpty
        ? '共 $totalCount 个书源'
        : '共 $count / $totalCount 个书源';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: HomePalette.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HomePalette.lineColor(context)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                countText,
                style: TextStyle(
                  fontSize: 13,
                  color: HomePalette.tertiaryText(context),
                ),
              ),
            ),
            PopupMenuButton<Map<String, dynamic>>(
              padding: EdgeInsets.zero,
              onSelected: (value) {
                setState(() {
                  _sortType = value['sort'] as BookSourceSort;
                  _sortAscending = value['asc'] as bool;
                });
              },
              itemBuilder: (context) => [
                _buildSortMenuItem(BookSourceSort.defaultSort, '默认排序'),
                _buildSortMenuItem(BookSourceSort.name, '按名称'),
                _buildSortMenuItem(BookSourceSort.url, '按 URL'),
                _buildSortMenuItem(BookSourceSort.weight, '按权重'),
                _buildSortMenuItem(BookSourceSort.enable, '按启用状态'),
                _buildSortMenuItem(BookSourceSort.respond, '按响应时间'),
                _buildSortMenuItem(BookSourceSort.update, '按更新时间'),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: {'sort': _sortType, 'asc': !_sortAscending},
                  child: Row(
                    children: [
                      Icon(
                        _sortAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                      ),
                      const SizedBox(width: 8),
                      Text(_sortAscending ? '升序' : '降序'),
                    ],
                  ),
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getSortLabel(),
                    style: TextStyle(
                      fontSize: 13,
                      color: HomePalette.secondaryText(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: HomePalette.secondaryText(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchActionBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: HomePalette.card(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: HomePalette.lineColor(context)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: HomePalette.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '已选择 ${_selectedUrls.length} 项',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.accentStrong,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildBatchActionButton(
                icon: Icons.select_all_rounded,
                label: '全选',
                onTap: _selectAll,
              ),
              _buildBatchActionButton(
                icon: Icons.deselect_rounded,
                label: '取消',
                onTap: () {
                  setState(() {
                    _selectedUrls.clear();
                  });
                },
              ),
              if (_selectedUrls.isNotEmpty) ...[
                _buildBatchActionButton(
                  icon: Icons.check_circle_outline_rounded,
                  label: '启用',
                  onTap: () => _batchEnable(true),
                ),
                _buildBatchActionButton(
                  icon: Icons.block_rounded,
                  label: '禁用',
                  onTap: () => _batchEnable(false),
                ),
                _buildBatchActionButton(
                  icon: Icons.folder_open_rounded,
                  label: '分组',
                  onTap: _batchSetGroup,
                ),
                _buildBatchActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: '删除',
                  onTap: _batchDelete,
                  foregroundColor: Colors.red,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? foregroundColor,
  }) {
    final color = foregroundColor ?? HomePalette.secondaryText(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: HomePalette.background(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  PopupMenuItem<Map<String, dynamic>> _buildSortMenuItem(
    BookSourceSort sort,
    String label,
  ) {
    return PopupMenuItem(
      value: {'sort': sort, 'asc': _sortAscending},
      child: Row(
        children: [
          Icon(_sortType == sort ? Icons.check_rounded : null),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortType) {
      case BookSourceSort.name:
        return '按名称';
      case BookSourceSort.url:
        return '按 URL';
      case BookSourceSort.weight:
        return '按权重';
      case BookSourceSort.update:
        return '按更新时间';
      case BookSourceSort.enable:
        return '按启用状态';
      case BookSourceSort.respond:
        return '按响应时间';
      case BookSourceSort.defaultSort:
        return '默认排序';
    }
  }

  void _setSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _applySearchShortcut(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSearchBar = false;
      });
      _searchController.clear();
      _setSearchQuery('');
      return;
    }

    setState(() {
      _showSearchBar = true;
    });
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _setSearchQuery(query);
  }

  bool _isFilterSelected(String query) {
    return query.isEmpty ? _searchQuery.isEmpty : _searchQuery == query;
  }

  /// 过滤和排序书源
  List<BookSource> _filterAndSortSourcesSync(List<BookSource> sources) {
    final query = _searchQuery.trim().toLowerCase();
    List<BookSource> filteredSources;

    if (query.isEmpty) {
      filteredSources = List<BookSource>.from(sources);
    } else if (query == '启用' || query == 'enabled') {
      filteredSources = sources.where((source) => source.enabled).toList();
    } else if (query == '禁用' || query == 'disabled') {
      filteredSources = sources.where((source) => !source.enabled).toList();
    } else if (query == '需要登录' || query == 'need_login') {
      filteredSources = sources
          .where((source) => source.loginUrl?.trim().isNotEmpty ?? false)
          .toList();
    } else if (query == '无分组' || query == 'no_group') {
      filteredSources = sources
          .where((source) => source.bookSourceGroup?.trim().isNotEmpty != true)
          .toList();
    } else if (query == '启用发现' || query == 'enabled_explore') {
      filteredSources =
          sources.where((source) => source.enabledExplore).toList();
    } else if (query == '禁用发现' || query == 'disabled_explore') {
      filteredSources =
          sources.where((source) => !source.enabledExplore).toList();
    } else if (query.startsWith('group:')) {
      final groupName = query.substring(6).trim();
      filteredSources = sources.where((source) {
        final group = (source.bookSourceGroup ?? '').toLowerCase();
        return group.contains(groupName);
      }).toList();
    } else {
      filteredSources = sources.where((source) {
        final url = source.bookSourceUrl.toLowerCase();
        final name = source.bookSourceName.toLowerCase();
        final group = (source.bookSourceGroup ?? '').toLowerCase();
        final comment = (source.bookSourceComment ?? '').toLowerCase();
        final loginUrl = (source.loginUrl ?? '').toLowerCase();
        return name.contains(query) ||
            url.contains(query) ||
            group.contains(query) ||
            comment.contains(query) ||
            loginUrl.contains(query);
      }).toList();
    }

    return _sortSources(filteredSources);
  }

  /// 构建书源列表
  Widget _buildBookSourceList(List<BookSource> filteredSources) {
    if (filteredSources.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(bookSourceManageNotifierProvider.notifier).reload();
      },
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          scrollbars: false,
          overscroll: false,
        ),
        child: ListView.builder(
          cacheExtent: 720,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: filteredSources.length,
          itemBuilder: (context, index) {
            final source = filteredSources[index];
            final isSelected = _selectedUrls.contains(source.bookSourceUrl);

            return BookSourceItemWidget(
              index: index,
              bookSource: source,
              isBatchMode: _isBatchMode,
              isSelected: isSelected,
              onTap: () {
                if (_isBatchMode) {
                  setState(() {
                    if (isSelected) {
                      _selectedUrls.remove(source.bookSourceUrl);
                    } else {
                      _selectedUrls.add(source.bookSourceUrl);
                    }
                  });
                } else {
                  _editBookSource(source);
                }
              },
              onLongPress: () {
                if (!_isBatchMode) {
                  setState(() {
                    _isBatchMode = true;
                    _selectedUrls.add(source.bookSourceUrl);
                  });
                }
              },
              onToggleEnabled: (enabled) {
                _toggleEnabled(source, enabled);
              },
              onDelete: () {
                _deleteBookSource(source);
              },
              onEdit: () {
                _editBookSource(source);
              },
            );
          },
        ),
      ),
    );
  }

  /// 排序书源
  List<BookSource> _sortSources(List<BookSource> sources) {
    final sorted = List<BookSource>.from(sources);

    switch (_sortType) {
      case BookSourceSort.name:
        sorted.sort((a, b) {
          final result = a.bookSourceName.compareTo(b.bookSourceName);
          return _sortAscending ? result : -result;
        });
        break;
      case BookSourceSort.url:
        sorted.sort((a, b) {
          final result = a.bookSourceUrl.compareTo(b.bookSourceUrl);
          return _sortAscending ? result : -result;
        });
        break;
      case BookSourceSort.update:
        sorted.sort((a, b) {
          final result = a.lastUpdateTime.compareTo(b.lastUpdateTime);
          return _sortAscending ? result : -result;
        });
        break;
      case BookSourceSort.weight:
        sorted.sort((a, b) {
          final result = a.weight.compareTo(b.weight);
          return _sortAscending ? result : -result;
        });
        break;
      case BookSourceSort.enable:
        sorted.sort((a, b) {
          if (a.enabled != b.enabled) {
            return _sortAscending ? (a.enabled ? 1 : -1) : (a.enabled ? -1 : 1);
          }
          return a.bookSourceName.compareTo(b.bookSourceName);
        });
        break;
      case BookSourceSort.respond:
        sorted.sort((a, b) {
          final result = a.respondTime.compareTo(b.respondTime);
          return _sortAscending ? result : -result;
        });
        break;
      case BookSourceSort.defaultSort:
        // 默认排序：按 customOrder，然后按名称
        sorted.sort((a, b) {
          if (a.customOrder != b.customOrder) {
            return a.customOrder.compareTo(b.customOrder);
          }
          return a.bookSourceName.compareTo(b.bookSourceName);
        });
        break;
    }

    return sorted;
  }

  /// 显示分组管理对话框
  void _showGroupManageDialog() {
    showDialog(
      context: context,
      builder: (context) => const BookSourceGroupManageDialog(),
    ).then((_) {
      ref.read(bookSourceManageNotifierProvider.notifier).reload();
    });
  }

  Widget _buildAppBarSearchAction() {
    final showField = _showSearchBar || _searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              axisAlignment: 1,
              child: child,
            ),
          );
        },
        child: showField
            ? _buildAppBarSearchField()
            : IconButton(
                key: const ValueKey('search_icon'),
                icon: const Icon(Icons.search_rounded),
                onPressed: _openSearchBar,
              ),
      ),
    );
  }

  Widget _buildAppBarSearchField() {
    return Container(
      key: const ValueKey('search_field'),
      width: 190,
      height: 38,
      decoration: BoxDecoration(
        color: HomePalette.background(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomePalette.lineColor(context)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 6),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: HomePalette.tertiaryText(context),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1,
                color: HomePalette.primaryText(context),
              ),
              decoration: InputDecoration(
                hintText: '搜索书源',
                hintStyle: TextStyle(
                  color: HomePalette.tertiaryText(context),
                  fontSize: 13,
                  height: 1,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: _setSearchQuery,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: _handleSearchClose,
            icon: Icon(
              _searchQuery.isNotEmpty
                  ? Icons.close_rounded
                  : Icons.chevron_right,
              size: 18,
              color: HomePalette.tertiaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  void _openSearchBar() {
    setState(() {
      _showSearchBar = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _handleSearchClose() {
    if (_searchQuery.isNotEmpty) {
      _searchController.clear();
      _setSearchQuery('');
      return;
    }

    setState(() {
      _showSearchBar = false;
    });
    _searchFocusNode.unfocus();
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: HomePalette.card(context),
                shape: BoxShape.circle,
                border: Border.all(color: HomePalette.lineColor(context)),
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.source_outlined,
                size: 36,
                color: HomePalette.tertiaryText(context),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isSearching ? '没有找到匹配的书源' : '书源列表还是空的',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: HomePalette.primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? '试试搜索名称、域名，或者点击上方快捷筛选恢复全部结果。'
                  : '可以先导入现成书源，或者手动新增一条开始整理。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: HomePalette.secondaryText(context),
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _importFromOnline,
                    icon: const Icon(Icons.cloud_download_rounded),
                    label: const Text('在线导入'),
                  ),
                  FilledButton.icon(
                    onPressed: _addBookSource,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('添加书源'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: HomePalette.card(context),
                shape: BoxShape.circle,
                border: Border.all(color: HomePalette.lineColor(context)),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: HomePalette.secondaryText(context),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref
                    .read(bookSourceManageNotifierProvider.notifier)
                    .reload(showLoading: true);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
