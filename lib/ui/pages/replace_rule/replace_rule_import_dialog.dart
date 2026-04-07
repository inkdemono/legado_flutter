import 'dart:async';
import 'package:legado_flutter/providers/service_registry.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../data/models/replace_rule.dart';
import '../../../services/replace_rule_service.dart';
import '../../widgets/home/home_shell.dart';

/// 替换规则导入对话框
class ReplaceRuleImportDialog extends StatefulWidget {
  final String content;
  final VoidCallback onImportComplete;

  const ReplaceRuleImportDialog({
    super.key,
    required this.content,
    required this.onImportComplete,
  });

  @override
  State<ReplaceRuleImportDialog> createState() =>
      _ReplaceRuleImportDialogState();
}

class _ReplaceRuleImportDialogState extends State<ReplaceRuleImportDialog> {
  static const List<List<Color>> _iconGradients = [
    [Color(0xFF34D399), Color(0xFF14B8A6)],
    [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
    [Color(0xFFFB7185), Color(0xFFFF7AA5)],
    [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
  ];

  List<ReplaceRule> _parsedRules = [];
  Set<String> _selectedNames = {};
  bool _isLoading = true;
  bool _isImporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _parseContent();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _parseContent() {
    try {
      final content = widget.content.trim();
      final dynamic jsonData = jsonDecode(content);

      final rules = <ReplaceRule>[];
      final selectedNames = <String>{};

      if (jsonData is List) {
        for (final item in jsonData) {
          if (item is! Map) continue;
          try {
            final rule = ReplaceRule.fromJson(Map<String, dynamic>.from(item));
            rules.add(rule);
            selectedNames.add(rule.name);
          } catch (_) {}
        }
      } else if (jsonData is Map) {
        final rule = ReplaceRule.fromJson(Map<String, dynamic>.from(jsonData));
        rules.add(rule);
        selectedNames.add(rule.name);
      }

      setState(() {
        _parsedRules = rules;
        _selectedNames = selectedNames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '解析失败，请检查导入内容是否为合法 JSON';
        _isLoading = false;
      });
    }
  }

  void _toggleSelection(String name) {
    setState(() {
      if (_selectedNames.contains(name)) {
        _selectedNames.remove(name);
      } else {
        _selectedNames.add(name);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedNames = _parsedRules.map((rule) => rule.name).toSet();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedNames.clear();
    });
  }

  Future<void> _import() async {
    if (_selectedNames.isEmpty) {
      _showMessage('请至少选择一个规则');
      return;
    }

    setState(() {
      _isImporting = true;
    });

    final rulesToImport = _parsedRules
        .where((rule) => _selectedNames.contains(rule.name))
        .toList();
    final importCount = rulesToImport.length;
    final navigator = Navigator.of(context);

    try {
      await Future.sync(
          () => readService(AppServices.replaceRuleService).importRules(rulesToImport));
      widget.onImportComplete();
      if (!mounted) return;
      navigator.pop();
      _showMessage('成功导入 $importCount 个规则');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isImporting = false;
      });
      _showMessage('导入失败: $e');
    }
  }

  Widget _buildHeaderAction({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Ink(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HomePalette.mutedCard(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HomePalette.lineColor(context)),
              ),
              child: Icon(
                icon,
                size: 20,
                color: HomePalette.primaryText(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    Color? color,
  }) {
    final resolvedColor = color ?? HomePalette.tertiaryText(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: HomePalette.mutedCard(context),
                shape: BoxShape.circle,
                border: Border.all(color: HomePalette.lineColor(context)),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 38, color: resolvedColor),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HomePalette.primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: HomePalette.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, {Color? color}) {
    final chipColor = color ?? HomePalette.secondaryText(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, ReplaceRule rule, int index) {
    final isSelected = _selectedNames.contains(rule.name);
    final colors = _iconGradients[index % _iconGradients.length];
    final borderColor = isSelected
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.22)
        : HomePalette.lineColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _isImporting ? null : () => _toggleSelection(rule.name),
          child: Ink(
            decoration: BoxDecoration(
              color: HomePalette.card(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: HomePalette.cardShadow(context),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 8),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: _isImporting
                          ? null
                          : (_) => _toggleSelection(rule.name),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: colors),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.find_replace_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                rule.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: HomePalette.primaryText(context),
                                ),
                              ),
                            ),
                            if (rule.group != null &&
                                rule.group!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              _buildChip(
                                context,
                                rule.group!,
                                color: const Color(0xFF1677FF),
                              ),
                            ],
                            if (!rule.enabled) ...[
                              const SizedBox(width: 8),
                              _buildChip(
                                context,
                                '导入后禁用',
                                color: HomePalette.tertiaryText(context),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: HomePalette.mutedCard(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            rule.pattern,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              fontFamily: 'monospace',
                              color: HomePalette.secondaryText(context),
                            ),
                          ),
                        ),
                        if (rule.replacement.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '替换为: ${rule.replacement}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: HomePalette.secondaryText(context),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (rule.scopeTitle) _buildChip(context, '标题'),
                            if (rule.scopeContent) _buildChip(context, '正文'),
                            if (!rule.isRegex) _buildChip(context, '普通文本'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 620,
          maxHeight: media.size.height * 0.84,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: HomePalette.card(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: HomePalette.lineColor(context)),
            boxShadow: HomePalette.cardShadow(context),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1677FF).withValues(alpha: 0.12),
                      const Color(0xFF14B8A6).withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1677FF), Color(0xFF14B8A6)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.file_download_done_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '导入规则',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: HomePalette.primaryText(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoading
                                  ? '正在解析导入内容'
                                  : _error != null
                                      ? '导入内容无法解析，请检查格式'
                                      : '共解析到 ${_parsedRules.length} 条规则，可选择后批量导入',
                              style: TextStyle(
                                fontSize: 13,
                                color: HomePalette.secondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!_isLoading && _error == null) ...[
                      _buildHeaderAction(
                        context: context,
                        icon: Icons.done_all_rounded,
                        tooltip: '全选',
                        onPressed: _isImporting ? null : _selectAll,
                      ),
                      _buildHeaderAction(
                        context: context,
                        icon: Icons.remove_done_rounded,
                        tooltip: '取消全选',
                        onPressed: _isImporting ? null : _deselectAll,
                      ),
                    ],
                    _buildHeaderAction(
                      context: context,
                      icon: Icons.close_rounded,
                      tooltip: '关闭',
                      onPressed: _isImporting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: HomePalette.lineColor(context)),
              if (!_isLoading && _error == null)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '已选择 ${_selectedNames.length}/${_parsedRules.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: HomePalette.primaryText(context),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _selectedNames.length == _parsedRules.length
                            ? '全部导入'
                            : '可按需勾选',
                        style: TextStyle(
                          fontSize: 12,
                          color: HomePalette.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildStatusState(
                            context: context,
                            icon: Icons.error_outline_rounded,
                            title: '解析失败',
                            message: _error!,
                            color: theme.colorScheme.error,
                          )
                        : _parsedRules.isEmpty
                            ? _buildStatusState(
                                context: context,
                                icon: Icons.inbox_outlined,
                                title: '未找到可导入规则',
                                message: '当前内容中没有识别到有效的替换规则',
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 16, 12, 20),
                                itemCount: _parsedRules.length,
                                itemBuilder: (context, index) {
                                  return _buildRuleCard(
                                    context,
                                    _parsedRules[index],
                                    index,
                                  );
                                },
                              ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: BoxDecoration(
                  color: HomePalette.card(context),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                  border: Border(
                    top: BorderSide(color: HomePalette.lineColor(context)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isImporting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HomePalette.secondaryText(context),
                          side:
                              BorderSide(color: HomePalette.lineColor(context)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: (_isLoading ||
                                _error != null ||
                                _selectedNames.isEmpty ||
                                _isImporting)
                            ? null
                            : _import,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isImporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('导入 (${_selectedNames.length})'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
