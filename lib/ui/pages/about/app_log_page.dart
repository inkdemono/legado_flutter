import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legado_flutter/providers/app_log_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../utils/app_log.dart';
import 'app_log_item.dart';
import 'app_log_filter_widget.dart';

/// 应用日志查看页面
class AppLogPage extends ConsumerStatefulWidget {
  const AppLogPage({
    super.key,
    this.initialTag = AppLogTag.all,
  });

  final String initialTag;

  @override
  ConsumerState<AppLogPage> createState() => _AppLogPageState();
}

class _AppLogPageState extends ConsumerState<AppLogPage> {
  String _searchQuery = '';
  late String _filterTag;
  LogLevel _filterLevel = LogLevel.all;
  LogCategory _filterCategory = LogCategory.all;
  bool _showErrorsOnly = false;

  @override
  void initState() {
    super.initState();
    _filterTag = widget.initialTag;
  }

  List<LogEntry> _getFilteredLogs(List<LogEntry> sourceLogs) {
    var logs = List<LogEntry>.from(sourceLogs);

    // 按错误筛选
    if (_showErrorsOnly) {
      logs = logs
          .where((log) => log.level == LogLevel.error || log.error != null)
          .toList();
    }

    // 按级别筛选
    if (_filterLevel != LogLevel.all) {
      logs = logs.where((log) => log.level == _filterLevel).toList();
    }

    if (_filterCategory != LogCategory.all) {
      logs = logs.where((log) => log.category == _filterCategory).toList();
    }

    if (_filterTag != AppLogTag.all) {
      logs = logs.where((log) => log.tag == _filterTag).toList();
    }

    // 按搜索关键词筛选
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      logs = logs.where((log) {
        return log.message.toLowerCase().contains(query) ||
            (log.error != null && log.error!.toLowerCase().contains(query));
      }).toList();
    }

    return logs;
  }

  List<String> _getAvailableTags(List<LogEntry> logs) {
    final tags = logs.map((log) => log.tag).toSet().toList()..sort();
    return [
      AppLogTag.all,
      ...tags,
    ];
  }

  Future<void> _exportLogs() async {
    final filteredLogs = _getFilteredLogs(ref.read(appLogProvider).logs);
    if (filteredLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有日志可导出')),
      );
      return;
    }

    try {
      final buffer = StringBuffer();
      buffer.writeln('应用日志导出');
      buffer.writeln('导出时间: ${DateTime.now().toString()}');
      buffer.writeln('日志数量: ${filteredLogs.length}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (final log in filteredLogs) {
        buffer.writeln('[${log.formattedTime}] [${log.tag}] ${log.message}');
        if (log.error != null) {
          buffer.writeln('错误: ${log.error}');
        }
        if (log.stackTrace != null) {
          buffer.writeln('堆栈: ${log.stackTrace}');
        }
        buffer.writeln('-' * 50);
      }

      await Share.share(
        buffer.toString(),
        subject: '应用日志',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _copyLogs() async {
    final filteredLogs = _getFilteredLogs(ref.read(appLogProvider).logs);
    if (filteredLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有日志可复制')),
      );
      return;
    }

    try {
      final buffer = StringBuffer();
      for (final log in filteredLogs) {
        buffer.writeln('[${log.formattedTime}] [${log.tag}] ${log.message}');
        if (log.error != null) {
          buffer.writeln('错误: ${log.error}');
        }
        if (log.stackTrace != null) {
          buffer.writeln('堆栈: ${log.stackTrace}');
        }
        buffer.writeln();
      }

      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志已复制到剪贴板')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('复制失败: $e')),
        );
      }
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有日志吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AppLog.instance.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日志已清除')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(appLogEntriesProvider).asData?.value ??
        ref.watch(appLogProvider).logs;
    final summary = ref.watch(appLogSummaryProvider);
    final availableTags = _getAvailableTags(logs);
    final filteredLogs = _getFilteredLogs(logs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('应用日志'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyLogs,
            tooltip: '复制日志',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportLogs,
            tooltip: '导出日志',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearLogs();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text('清除日志'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选和搜索栏
          AppLogFilterWidget(
            searchQuery: _searchQuery,
            filterTag: _filterTag,
            availableTags: availableTags,
            filterLevel: _filterLevel,
            filterCategory: _filterCategory,
            showErrorsOnly: _showErrorsOnly,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onFilterTagChanged: (tag) {
              setState(() {
                _filterTag = tag;
              });
            },
            onFilterLevelChanged: (level) {
              setState(() {
                _filterLevel = level;
              });
            },
            onFilterCategoryChanged: (category) {
              setState(() {
                _filterCategory = category;
              });
            },
            onShowErrorsOnlyChanged: (value) {
              setState(() {
                _showErrorsOnly = value;
              });
            },
          ),
          if (summary.totalLogs > 0) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSummaryChip(
                      label: '总数 ${summary.totalLogs}',
                    ),
                    for (final entry in summary.tagCounts.entries.take(3))
                      _buildSummaryChip(
                        label: '${entry.key} ${entry.value}',
                      ),
                    for (final entry in summary.categoryCounts.entries.take(5))
                      _buildSummaryChip(
                        label: '${entry.key.label} ${entry.value}',
                      ),
                  ],
                ),
              ),
            ),
            if (summary.repeatedEntries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: summary.repeatedEntries
                      .map(
                        (entry) => Text(
                          '${entry.category.label}/${entry.tag} ×${entry.count} · ${entry.message}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
          const Divider(height: 1),
          // 日志列表
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ||
                                  _filterLevel != LogLevel.all ||
                                  _filterCategory != LogCategory.all ||
                                  _filterTag != AppLogTag.all ||
                                  _showErrorsOnly
                              ? '没有匹配的日志'
                              : '暂无日志',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return AppLogItem(
                        log: log,
                        onTap: () {
                          _showLogDetail(log);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showLogDetail(LogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('日志详情'),
        content: SingleChildScrollView(
          child: SelectableText(
            log.fullMessage,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: log.fullMessage));
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              }
            },
            child: const Text('复制'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
