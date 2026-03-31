import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/dict_rule.dart';
import '../../widgets/home/home_shell.dart';

/// 字典规则编辑对话框
class DictRuleEditDialog extends StatefulWidget {
  final DictRule? rule;
  final FutureOr<void> Function(DictRule) onSave;

  const DictRuleEditDialog({
    super.key,
    this.rule,
    required this.onSave,
  });

  @override
  State<DictRuleEditDialog> createState() => _DictRuleEditDialogState();
}

class _DictRuleEditDialogState extends State<DictRuleEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _urlRuleController;
  late final TextEditingController _showRuleController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.name ?? '');
    _urlRuleController =
        TextEditingController(text: widget.rule?.urlRule ?? '');
    _showRuleController =
        TextEditingController(text: widget.rule?.showRule ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlRuleController.dispose();
    _showRuleController.dispose();
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
  }) {
    return InputDecoration(
      hintText: hintText,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF14B8A6).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF14B8A6)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF14B8A6),
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

    final urlRule = _urlRuleController.text.trim();
    if (urlRule.isEmpty) {
      _showMessage('URL规则不能为空');
      return;
    }

    final showRule = _showRuleController.text.trim();
    final dictRule = widget.rule?.copyWith(
          name: name,
          urlRule: urlRule,
          showRule: showRule,
        ) ??
        DictRule(
          name: name,
          urlRule: urlRule,
          showRule: showRule,
        );

    setState(() {
      _isSaving = true;
    });

    try {
      await Future.sync(() => widget.onSave(dictRule));
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
      final rule = DictRule.fromJson(json);

      setState(() {
        _nameController.text = rule.name;
        _urlRuleController.text = rule.urlRule;
        _showRuleController.text = rule.showRule;
      });

      _showMessage('已粘贴规则');
    } catch (e) {
      _showMessage('粘贴失败: $e');
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
          maxWidth: 560,
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
                          colors: [Color(0xFF34D399), Color(0xFF14B8A6)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.menu_book_rounded,
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
                              '配置词典查询地址和显示规则',
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
                      _buildSectionTitle(context, '规则名称'),
                      TextField(
                        controller: _nameController,
                        enabled: !_isSaving,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '例如：百度词典',
                        ),
                        style: TextStyle(
                          color: HomePalette.primaryText(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, 'URL规则'),
                      TextField(
                        controller: _urlRuleController,
                        enabled: !_isSaving,
                        maxLines: 4,
                        minLines: 3,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '请输入 URL 规则，使用 {{key}} 作为关键词占位符',
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
                        icon: Icons.link_rounded,
                        title: 'URL规则说明',
                        body:
                            '用于构建请求地址，{{key}} 会在查询时替换成用户输入的词语。例如：https://example.com?q={{key}}',
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, '显示规则'),
                      TextField(
                        controller: _showRuleController,
                        enabled: !_isSaving,
                        maxLines: 4,
                        minLines: 3,
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '可选，留空则显示原始响应内容',
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
                        icon: Icons.visibility_outlined,
                        title: '显示规则说明',
                        body: '用于从响应中提取展示文本，支持 CSS 选择器或 XPath。留空时将直接显示原始响应。',
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
