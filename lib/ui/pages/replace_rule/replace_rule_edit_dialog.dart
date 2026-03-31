import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/replace_rule.dart';
import '../../widgets/common/custom_switch_list_tile.dart';
import '../../widgets/home/home_shell.dart';

/// 替换规则编辑对话框
class ReplaceRuleEditDialog extends StatefulWidget {
  final ReplaceRule? rule;
  final FutureOr<void> Function(ReplaceRule) onSave;

  const ReplaceRuleEditDialog({
    super.key,
    this.rule,
    required this.onSave,
  });

  @override
  State<ReplaceRuleEditDialog> createState() => _ReplaceRuleEditDialogState();
}

class _ReplaceRuleEditDialogState extends State<ReplaceRuleEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _patternController;
  late final TextEditingController _replacementController;
  late final TextEditingController _groupController;
  late final TextEditingController _scopeController;
  late final TextEditingController _excludeScopeController;
  late final TextEditingController _timeoutController;

  bool _isRegex = true;
  bool _scopeTitle = false;
  bool _scopeContent = true;
  int _timeoutMillisecond = 3000;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.name ?? '');
    _patternController =
        TextEditingController(text: widget.rule?.pattern ?? '');
    _replacementController =
        TextEditingController(text: widget.rule?.replacement ?? '');
    _groupController = TextEditingController(text: widget.rule?.group ?? '');
    _scopeController = TextEditingController(text: widget.rule?.scope ?? '');
    _excludeScopeController =
        TextEditingController(text: widget.rule?.excludeScope ?? '');
    _isRegex = widget.rule?.isRegex ?? true;
    _scopeTitle = widget.rule?.scopeTitle ?? false;
    _scopeContent = widget.rule?.scopeContent ?? true;
    _timeoutMillisecond = widget.rule?.timeoutMillisecond ?? 3000;
    _timeoutController =
        TextEditingController(text: _timeoutMillisecond.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _patternController.dispose();
    _replacementController.dispose();
    _groupController.dispose();
    _scopeController.dispose();
    _excludeScopeController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hintText,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      hintStyle: TextStyle(
        color: HomePalette.tertiaryText(context),
        fontSize: 14,
      ),
      filled: true,
      fillColor: HomePalette.mutedCard(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: HomePalette.lineColor(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: HomePalette.lineColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: HomePalette.secondaryText(context),
        ),
      ),
    );
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

  Widget _buildHintCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String body,
    Color accent = const Color(0xFF14B8A6),
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('名称不能为空');
      return;
    }

    final pattern = _patternController.text.trim();
    if (pattern.isEmpty) {
      _showMessage('替换模式不能为空');
      return;
    }

    if (_isRegex) {
      try {
        RegExp(pattern);
        if (pattern.endsWith('|') && !pattern.endsWith('\\|')) {
          _showMessage('替换模式不能以未转义的 | 结尾');
          return;
        }
      } catch (e) {
        _showMessage('正则表达式格式错误: $e');
        return;
      }
    }

    final replacement = _replacementController.text;
    final group = _groupController.text.trim();
    final scope = _scopeController.text.trim();
    final excludeScope = _excludeScopeController.text.trim();
    final timeout = int.tryParse(_timeoutController.text.trim());
    if (timeout != null && timeout > 0) {
      _timeoutMillisecond = timeout;
    }

    final replaceRule = widget.rule?.copyWith(
          name: name,
          pattern: pattern,
          replacement: replacement,
          group: group.isEmpty ? null : group,
          scope: scope.isEmpty ? null : scope,
          excludeScope: excludeScope.isEmpty ? null : excludeScope,
          isRegex: _isRegex,
          scopeTitle: _scopeTitle,
          scopeContent: _scopeContent,
          timeoutMillisecond: _timeoutMillisecond,
        ) ??
        ReplaceRule(
          name: name,
          pattern: pattern,
          replacement: replacement,
          group: group.isEmpty ? null : group,
          scope: scope.isEmpty ? null : scope,
          excludeScope: excludeScope.isEmpty ? null : excludeScope,
          isRegex: _isRegex,
          scopeTitle: _scopeTitle,
          scopeContent: _scopeContent,
          timeoutMillisecond: _timeoutMillisecond,
        );

    setState(() {
      _isSaving = true;
    });

    try {
      await Future.sync(() => widget.onSave(replaceRule));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      _showMessage('保存失败: $e');
    }
  }

  Future<void> _copyRule() async {
    final rule = widget.rule;
    if (rule == null) return;

    await Clipboard.setData(ClipboardData(text: jsonEncode(rule.toJson())));
    if (!mounted) return;
    _showMessage('已复制到剪贴板');
  }

  Future<void> _pasteRule() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final rawText = clipboardData?.text?.trim();
    if (rawText == null || rawText.isEmpty) {
      _showMessage('剪贴板为空');
      return;
    }

    try {
      final json = jsonDecode(rawText) as Map<String, dynamic>;
      final rule = ReplaceRule.fromJson(json);

      setState(() {
        _nameController.text = rule.name;
        _patternController.text = rule.pattern;
        _replacementController.text = rule.replacement;
        _groupController.text = rule.group ?? '';
        _scopeController.text = rule.scope ?? '';
        _excludeScopeController.text = rule.excludeScope ?? '';
        _isRegex = rule.isRegex;
        _scopeTitle = rule.scopeTitle;
        _scopeContent = rule.scopeContent;
        _timeoutMillisecond = rule.timeoutMillisecond;
        _timeoutController.text = rule.timeoutMillisecond.toString();
      });

      _showMessage('已粘贴规则');
    } catch (e) {
      _showMessage('粘贴失败: $e');
    }
  }

  void _testPattern() {
    final pattern = _patternController.text.trim();
    final replacement = _replacementController.text;
    const testText = '测试文本：这是一段测试文本，用于验证替换规则是否正确。';

    if (pattern.isEmpty) {
      _showMessage('请先输入替换模式');
      return;
    }

    try {
      String result;
      if (_isRegex) {
        final regex = RegExp(pattern, multiLine: true);
        result = testText.replaceAll(regex, replacement);
      } else {
        result = testText.replaceAll(pattern, replacement);
      }

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('测试结果'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('原始文本', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                testText,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              const Text('替换后', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                result,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showMessage('规则测试失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: media.size.height * 0.88,
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
                          colors: [Color(0xFF34D399), Color(0xFF14B8A6)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.find_replace_rounded,
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
                              widget.rule == null ? '新增规则' : '编辑规则',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: HomePalette.primaryText(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '配置文本替换模式、作用范围和替换方式',
                              style: TextStyle(
                                fontSize: 13,
                                color: HomePalette.secondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildHeaderAction(
                      context: context,
                      icon: Icons.play_arrow_rounded,
                      tooltip: '测试规则',
                      onPressed: _isSaving ? null : _testPattern,
                    ),
                    _buildHeaderAction(
                      context: context,
                      icon: Icons.content_paste_rounded,
                      tooltip: '粘贴规则',
                      onPressed: _isSaving ? null : _pasteRule,
                    ),
                    if (widget.rule != null)
                      _buildHeaderAction(
                        context: context,
                        icon: Icons.content_copy_rounded,
                        tooltip: '复制规则',
                        onPressed: _isSaving ? null : _copyRule,
                      ),
                    _buildHeaderAction(
                      context: context,
                      icon: Icons.close_rounded,
                      tooltip: '关闭',
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: HomePalette.lineColor(context)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, '基础信息'),
                      TextField(
                        controller: _nameController,
                        enabled: !_isSaving,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '请输入规则名称',
                        ),
                        style: TextStyle(
                          color: HomePalette.primaryText(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _groupController,
                        enabled: !_isSaving,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '分组名称，可选',
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, '替换规则'),
                      TextField(
                        controller: _patternController,
                        enabled: !_isSaving,
                        maxLines: 4,
                        minLines: 3,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: _isRegex ? '请输入正则表达式' : '请输入要匹配的普通文本',
                        ),
                        style: TextStyle(
                          color: HomePalette.primaryText(context),
                          fontSize: 13,
                          height: 1.4,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildHintCard(
                        context: context,
                        icon: _isRegex
                            ? Icons.code_rounded
                            : Icons.text_fields_rounded,
                        title: _isRegex ? '正则模式' : '普通文本模式',
                        body: _isRegex
                            ? '支持正则表达式匹配。常见用途包括去除空行、HTML标签、广告文案等。'
                            : '关闭正则后将按普通文本直接替换，适合简单固定内容清理。',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _replacementController,
                        enabled: !_isSaving,
                        maxLines: 3,
                        minLines: 2,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '替换后的内容，留空表示删除匹配内容',
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, '作用范围'),
                      TextField(
                        controller: _scopeController,
                        enabled: !_isSaving,
                        maxLines: 2,
                        minLines: 1,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '书籍名称或来源，用逗号分隔，留空表示全部',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _excludeScopeController,
                        enabled: !_isSaving,
                        maxLines: 2,
                        minLines: 1,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '排除范围，可选',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildHintCard(
                        context: context,
                        icon: Icons.my_location_rounded,
                        title: '范围说明',
                        body: '指定后规则只对目标书籍或来源生效；排除范围中的目标将跳过该规则。',
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, '作用类型'),
                      Container(
                        decoration: BoxDecoration(
                          color: HomePalette.mutedCard(context),
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: HomePalette.lineColor(context)),
                        ),
                        child: Column(
                          children: [
                            CustomSwitchListTile(
                              title: const Text('作用于标题'),
                              subtitle: const Text('对章节标题应用此规则'),
                              value: _scopeTitle,
                              onChanged: _isSaving
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _scopeTitle = value;
                                      });
                                    },
                            ),
                            Divider(
                              height: 1,
                              color: HomePalette.lineColor(context),
                            ),
                            CustomSwitchListTile(
                              title: const Text('作用于正文'),
                              subtitle: const Text('对正文内容应用此规则'),
                              value: _scopeContent,
                              onChanged: _isSaving
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _scopeContent = value;
                                      });
                                    },
                            ),
                            Divider(
                              height: 1,
                              color: HomePalette.lineColor(context),
                            ),
                            CustomSwitchListTile(
                              title: const Text('使用正则表达式'),
                              subtitle: const Text('关闭后按普通文本替换'),
                              value: _isRegex,
                              onChanged: _isSaving
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _isRegex = value;
                                      });
                                    },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, '执行限制'),
                      TextField(
                        controller: _timeoutController,
                        enabled: !_isSaving,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '默认 3000',
                          suffixText: 'ms',
                        ),
                        onChanged: (value) {
                          final timeout = int.tryParse(value);
                          if (timeout != null && timeout > 0) {
                            _timeoutMillisecond = timeout;
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildHintCard(
                        context: context,
                        icon: Icons.timer_outlined,
                        title: '超时说明',
                        body: '用于防止复杂正则执行时间过长导致页面卡顿，建议保持在 3000ms 左右。',
                        accent: const Color(0xFF1677FF),
                      ),
                    ],
                  ),
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
                        onPressed: _isSaving
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
                        onPressed: _isSaving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(widget.rule == null ? '创建规则' : '保存修改'),
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
