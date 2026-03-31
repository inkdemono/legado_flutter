import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../services/book/local_book_service.dart';
import '../../../services/file_manage_service.dart';
import '../../../utils/app_log.dart';
import '../../widgets/home/home_shell.dart';
import 'file_detail_dialog.dart';

/// 文件管理页面
class FileManagePage extends StatefulWidget {
  const FileManagePage({super.key});

  @override
  State<FileManagePage> createState() => _FileManagePageState();
}

class _FileManagePageState extends State<FileManagePage> {
  final FileManageService _fileService = FileManageService.instance;
  final TextEditingController _searchController = TextEditingController();

  Directory? _currentDirectory;
  List<FileInfo> _files = [];
  List<Directory> _pathStack = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRootDirectory();
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

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  Future<void> _loadRootDirectory() async {
    setState(() {
      _isLoading = true;
      _pathStack.clear();
    });

    try {
      final rootDir = await _fileService.getAppDocumentsDirectory();
      await _loadDirectory(rootDir);
    } catch (e) {
      AppLog.instance.put('加载根目录失败', error: e);
      _showMessage('加载目录失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDirectory(Directory directory) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final files = await _fileService.getFilesInDirectory(directory);
      if (!mounted) return;
      setState(() {
        _currentDirectory = directory;
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      AppLog.instance.put('加载目录失败: ${directory.path}', error: e);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showMessage('加载目录失败: $e');
    }
  }

  void _enterDirectory(FileInfo fileInfo) {
    if (fileInfo.name == '..') {
      if (_pathStack.isNotEmpty) {
        final parentDir = _pathStack.removeLast();
        _loadDirectory(parentDir);
      } else {
        _loadRootDirectory();
      }
      return;
    }

    if (fileInfo.isDirectory) {
      final dir = Directory(fileInfo.path);
      if (_currentDirectory != null) {
        _pathStack.add(_currentDirectory!);
      }
      _loadDirectory(dir);
      return;
    }

    _openFile(fileInfo);
  }

  Future<void> _openFile(FileInfo fileInfo) async {
    try {
      if (_fileService.isBookFile(fileInfo.name)) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('导入书籍'),
            content: Text('是否将 "${fileInfo.name}" 导入为书籍？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('导入'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await _importBook(fileInfo.path);
        }
        return;
      }

      final result = await OpenFilex.open(fileInfo.path);
      if (result.type != ResultType.done) {
        _showMessage('无法打开文件: ${result.message}');
      }
    } catch (e) {
      AppLog.instance.put('打开文件失败', error: e);
      _showMessage('打开文件失败: $e');
    }
  }

  Future<void> _importBook(String filePath) async {
    try {
      final book = await LocalBookService.instance.importBook(filePath);
      if (book != null) {
        _showMessage('导入成功: ${book.name}');
      }
    } catch (e) {
      AppLog.instance.put('导入书籍失败', error: e);
      _showMessage('导入失败: $e');
    }
  }

  Future<void> _deleteFile(FileInfo fileInfo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text(
          '确定要删除 "${fileInfo.name}" 吗？${fileInfo.isDirectory ? '\n（将删除目录及其所有内容）' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _fileService.deleteFile(fileInfo.path);
      if (!success) {
        _showMessage('删除失败');
        return;
      }

      if (_currentDirectory != null) {
        await _loadDirectory(_currentDirectory!);
      }
      _showMessage('删除成功');
    } catch (e) {
      AppLog.instance.put('删除文件失败', error: e);
      _showMessage('删除失败: $e');
    }
  }

  void _showFileMenu(FileInfo fileInfo) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('文件信息'),
              onTap: () {
                Navigator.pop(context);
                _showFileDetail(fileInfo);
              },
            ),
            if (!fileInfo.isDirectory)
              ListTile(
                leading: const Icon(Icons.open_in_new_rounded),
                title: const Text('打开'),
                onTap: () {
                  Navigator.pop(context);
                  _openFile(fileInfo);
                },
              ),
            if (_fileService.isBookFile(fileInfo.name))
              ListTile(
                leading: const Icon(Icons.menu_book_rounded),
                title: const Text('导入为书籍'),
                onTap: () {
                  Navigator.pop(context);
                  _importBook(fileInfo.path);
                },
              ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(fileInfo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFileDetail(FileInfo fileInfo) {
    showDialog(
      context: context,
      builder: (context) => FileDetailDialog(
        fileInfo: fileInfo,
        onOpen: fileInfo.isDirectory ? null : () => _openFile(fileInfo),
        onImportBook: _fileService.isBookFile(fileInfo.name)
            ? () => _importBook(fileInfo.path)
            : null,
        onDelete: () => _deleteFile(fileInfo),
      ),
    );
  }

  void _navigateToPath(int index) {
    if (index == -1) {
      _loadRootDirectory();
      return;
    }

    if (index < _pathStack.length) {
      final targetDir = _pathStack[index];
      _pathStack = _pathStack.sublist(0, index);
      _loadDirectory(targetDir);
    }
  }

  List<FileInfo> get _visibleFiles {
    final baseFiles = _files.where((file) {
      if (file.name == '.') return false;
      if (file.name == '..' && _pathStack.isEmpty) return false;
      return true;
    }).toList();

    if (_searchQuery.isEmpty) {
      return baseFiles;
    }

    return baseFiles.where((file) {
      if (file.name == '..') return true;
      return file.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleFiles = _visibleFiles;
    final fileCount = visibleFiles.where((file) => file.name != '..').length;
    final directoryName = _currentDirectory == null
        ? '加载中'
        : _currentDirectory!.path.split('/').last;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF1677FF), Color(0xFF0F62FE)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (_currentDirectory != null) {
                      await _loadDirectory(_currentDirectory!);
                    } else {
                      await _loadRootDirectory();
                    }
                  },
                  child: _buildBody(
                    context,
                    visibleFiles: visibleFiles,
                    fileCount: fileCount,
                    directoryName:
                        directoryName.isEmpty ? 'Documents' : directoryName,
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
                      '文件管理',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '浏览应用目录并管理导入文件',
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
                icon: Icons.home_rounded,
                onTap: _loadRootDirectory,
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                context,
                icon: Icons.refresh_rounded,
                onTap: () {
                  if (_currentDirectory != null) {
                    _loadDirectory(_currentDirectory!);
                  } else {
                    _loadRootDirectory();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          HomeSearchField(
            controller: _searchController,
            hintText: '搜索文件或目录',
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required List<FileInfo> visibleFiles,
    required int fileCount,
    required String directoryName,
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
        _buildHeroCard(
          context,
          directoryName: directoryName,
          fileCount: fileCount,
        ),
        const SizedBox(height: 16),
        if (_currentDirectory != null) ...[
          HomeSectionCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbs(context),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
        _buildSectionHeader(
          context,
          title: _searchQuery.isEmpty ? '目录内容' : '筛选结果',
          subtitle:
              _searchQuery.isEmpty ? '长按条目可查看详情、删除或导入' : '关键字：$_searchQuery',
        ),
        const SizedBox(height: 10),
        if (visibleFiles.isEmpty)
          HomeSectionCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.folder_open_rounded,
                  size: 52,
                  color: HomePalette.tertiaryText(context),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? '目录为空' : '未找到匹配的文件',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchQuery.isEmpty ? '当前目录下还没有内容' : '可以换个关键词重试',
                  style: TextStyle(color: HomePalette.secondaryText(context)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        else
          ...visibleFiles.map(
            (fileInfo) => _FileItemCard(
              fileInfo: fileInfo,
              onTap: () => _enterDirectory(fileInfo),
              onLongPress: () => _showFileMenu(fileInfo),
            ),
          ),
        const SizedBox(height: 90),
      ],
    );
  }

  List<Widget> _buildBreadcrumbs(BuildContext context) {
    final widgets = <Widget>[
      _PathChip(
        label: 'root',
        icon: Icons.home_rounded,
        onTap: () => _navigateToPath(-1),
      ),
    ];

    for (var index = 0; index < _pathStack.length; index++) {
      final dir = _pathStack[index];
      final name = dir.path.split('/').last;
      widgets.add(_buildBreadcrumbArrow(context));
      widgets.add(
        _PathChip(
          label: name.isEmpty ? 'root' : name,
          onTap: () => _navigateToPath(index),
        ),
      );
    }

    if (_currentDirectory != null) {
      widgets.add(_buildBreadcrumbArrow(context));
      widgets.add(
        _PathChip(
          label: _currentDirectory!.path.split('/').last.isEmpty
              ? 'root'
              : _currentDirectory!.path.split('/').last,
          isCurrent: true,
        ),
      );
    }

    return widgets;
  }

  Widget _buildBreadcrumbArrow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: HomePalette.tertiaryText(context),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required String directoryName,
    required int fileCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1677FF), Color(0xFF0F62FE)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1677FF).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前目录',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            directoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricCard(value: '$fileCount', label: '条目'),
              const SizedBox(width: 10),
              _buildMetricCard(
                value:
                    _pathStack.isEmpty ? '根目录' : '${_pathStack.length + 1} 层',
                label: '层级',
              ),
              const SizedBox(width: 10),
              _buildMetricCard(
                value: _searchQuery.isEmpty ? '全部' : '筛选中',
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

class _PathChip extends StatelessWidget {
  final String label;
  final bool isCurrent;
  final IconData? icon;
  final VoidCallback? onTap;

  const _PathChip({
    required this.label,
    this.isCurrent = false,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background =
        isCurrent ? HomePalette.accentSoft : HomePalette.mutedCard(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent
                  ? HomePalette.accent.withValues(alpha: 0.24)
                  : HomePalette.lineColor(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isCurrent
                      ? HomePalette.accent
                      : HomePalette.secondaryText(context),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent
                      ? HomePalette.accent
                      : HomePalette.primaryText(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileItemCard extends StatelessWidget {
  final FileInfo fileInfo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FileItemCard({
    required this.fileInfo,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final fileService = FileManageService.instance;
    final style = _styleFor(fileInfo, fileService);
    final isParent = fileInfo.name == '..';
    final title = isParent ? '返回上一级' : fileInfo.name;
    final subtitle = isParent
        ? '回到上一层目录'
        : fileInfo.isDirectory
            ? '目录 • ${_formatDate(fileInfo.lastModified)}'
            : '${fileService.formatFileSize(fileInfo.size)} • ${_formatDate(fileInfo.lastModified)}';

    return HomeSectionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(style.icon, color: style.iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: HomePalette.primaryText(context),
                        ),
                      ),
                    ),
                    if (!fileInfo.isDirectory &&
                        fileService.isBookFile(fileInfo.name)) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: HomePalette.accentSoft,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          '书籍',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: HomePalette.accentStrong,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
          if (isParent)
            Icon(
              Icons.chevron_left_rounded,
              color: HomePalette.tertiaryText(context),
            )
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onLongPress,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: HomePalette.tertiaryText(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _FileVisualStyle _styleFor(FileInfo fileInfo, FileManageService service) {
    if (fileInfo.name == '..') {
      return const _FileVisualStyle(
        icon: Icons.arrow_upward_rounded,
        backgroundColor: Color(0xFFE2E8F0),
        iconColor: Color(0xFF475569),
      );
    }

    if (fileInfo.isDirectory) {
      return const _FileVisualStyle(
        icon: Icons.folder_rounded,
        backgroundColor: Color(0xFFE6F7FF),
        iconColor: Color(0xFF1677FF),
      );
    }

    final icon = service.getFileIcon(fileInfo.name, false);
    switch (icon) {
      case Icons.menu_book_rounded:
      case Icons.book:
        return const _FileVisualStyle(
          icon: Icons.menu_book_rounded,
          backgroundColor: Color(0xFFF6FFED),
          iconColor: Color(0xFF52C41A),
        );
      case Icons.description:
        return const _FileVisualStyle(
          icon: Icons.description_rounded,
          backgroundColor: Color(0xFFFFF7E6),
          iconColor: Color(0xFFFA8C16),
        );
      case Icons.image:
        return const _FileVisualStyle(
          icon: Icons.image_rounded,
          backgroundColor: Color(0xFFFFF0F6),
          iconColor: Color(0xFFEB2F96),
        );
      case Icons.archive:
        return const _FileVisualStyle(
          icon: Icons.archive_rounded,
          backgroundColor: Color(0xFFF5F3FF),
          iconColor: Color(0xFF7C3AED),
        );
      case Icons.video_library:
        return const _FileVisualStyle(
          icon: Icons.play_circle_outline_rounded,
          backgroundColor: Color(0xFFECFEFF),
          iconColor: Color(0xFF0891B2),
        );
      default:
        return const _FileVisualStyle(
          icon: Icons.insert_drive_file_rounded,
          backgroundColor: Color(0xFFF3F4F6),
          iconColor: Color(0xFF6B7280),
        );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (difference.inDays == 1) {
      return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _FileVisualStyle {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _FileVisualStyle({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}
