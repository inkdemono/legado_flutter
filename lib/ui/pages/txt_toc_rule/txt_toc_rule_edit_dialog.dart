import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/txt_toc_rule.dart';
import '../../widgets/home/home_shell.dart';
import 'txt_toc_rule_feedback.dart';

/// TXT目录规则编辑对话框
class TxtTocRuleEditDialog extends StatefulWidget {
  final TxtTocRule? rule;
  final FutureOr<void> Function(TxtTocRule) onSave;

  const TxtTocRuleEditDialog({
    super.key,
    this.rule,
    required this.onSave,
  });

  @override
  State<TxtTocRuleEditDialog> createState() => _TxtTocRuleEditDialogState();
}

class _TxtTocRuleEditDialogState extends State<TxtTocRuleEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _ruleController;
  late final TextEditingController _exampleController;

  bool _isValid = true;
  bool _hasValidated = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rule?.name ?? '');
    _ruleController = TextEditingController(text: widget.rule?.rule ?? '');
    _exampleController =
        TextEditingController(text: widget.rule?.example ?? '');

    if (_ruleController.text.trim().isNotEmpty) {
      _validateRule(_ruleController.text.trim(), markTouched: false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ruleController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  bool _validateRule(String rule, {bool markTouched = true}) {
    if (markTouched) {
      _hasValidated = true;
    }

    if (rule.isEmpty) {
      setState(() {
        _isValid = false;
        _errorMessage = '规则不能为空';
      });
      return false;
    }

    try {
      RegExp(rule, multiLine: true);
      setState(() {
        _isValid = true;
        _errorMessage = null;
      });
      return true;
    } catch (e) {
      setState(() {
        _isValid = false;
        _errorMessage = '正则表达式语法错误';
      });
      return false;
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      TxtTocRuleFeedback.show(
        context,
        '名称不能为空',
        type: TxtTocRuleFeedbackType.warning,
      );
      return;
    }

    final rule = _ruleController.text.trim();
    if (!_validateRule(rule)) {
      TxtTocRuleFeedback.show(
        context,
        _errorMessage ?? '规则验证失败',
        type: TxtTocRuleFeedbackType.error,
      );
      return;
    }

    final example = _exampleController.text.trim();
    final txtTocRule = widget.rule?.copyWith(
          name: name,
          rule: rule,
          example: example.isEmpty ? null : example,
        ) ??
        TxtTocRule(
          id: DateTime.now().millisecondsSinceEpoch,
          name: name,
          rule: rule,
          example: example.isEmpty ? null : example,
        );

    setState(() {
      _isSaving = true;
    });

    try {
      await Future.sync(() => widget.onSave(txtTocRule));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      TxtTocRuleFeedback.show(
        context,
        '保存失败: $e',
        type: TxtTocRuleFeedbackType.error,
      );
    }
  }

  Future<void> _copyRule() async {
    final rule = widget.rule;
    if (rule == null) return;

    final jsonString = jsonEncode(rule.toJson());
    await Clipboard.setData(ClipboardData(text: jsonString));
    if (!mounted) return;
    TxtTocRuleFeedback.show(
      context,
      '已复制到剪贴板',
      type: TxtTocRuleFeedbackType.success,
    );
  }

  Future<void> _pasteRule() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final rawText = clipboardData?.text?.trim();
    if (rawText == null || rawText.isEmpty) {
      TxtTocRuleFeedback.show(
        context,
        '剪贴板为空',
        type: TxtTocRuleFeedbackType.warning,
      );
      return;
    }

    try {
      var cleanedText = rawText;
      if (cleanedText.startsWith('"') && cleanedText.endsWith('"')) {
        cleanedText = cleanedText.substring(1, cleanedText.length - 1);
        cleanedText = cleanedText.replaceAll('\\"', '"');
      }

      final json = jsonDecode(cleanedText) as Map<String, dynamic>;
      final rule = TxtTocRule.fromJson(json);

      setState(() {
        _nameController.text = rule.name;
        _ruleController.text = rule.rule;
        _exampleController.text = rule.example ?? '';
      });
      _validateRule(rule.rule);
      TxtTocRuleFeedback.show(
        context,
        '粘贴成功',
        type: TxtTocRuleFeedbackType.success,
      );
    } catch (e) {
      TxtTocRuleFeedback.show(
        context,
        '粘贴失败: 无法解析 JSON',
        type: TxtTocRuleFeedbackType.error,
      );
    }
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hintText,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: HomePalette.tertiaryText(context),
        fontSize: 14,
      ),
      errorText: errorText,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
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
    );
  }

  Widget _buildRuleHintCard(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _hasValidated && !_isValid
        ? theme.colorScheme.error
        : const Color(0xFF14B8A6);
    final icon = _hasValidated && !_isValid
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;
    final title = _hasValidated && !_isValid ? '规则校验未通过' : '规则校验通过';
    final body = _hasValidated && !_isValid
        ? (_errorMessage ?? '请检查正则表达式语法')
        : '使用正则表达式匹配章节标题，例如：第[0-9一二三四五六七八九十百千万]+[章节回]';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.rule == null ? '新增规则' : '编辑规则';
    final subtitle =
        widget.rule == null ? '创建新的 TXT 目录解析规则' : '调整当前规则的名称、正则和示例';
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
                        Icons.description_rounded,
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
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: HomePalette.primaryText(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
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
                        textInputAction: TextInputAction.next,
                        enabled: !_isSaving,
                        style: TextStyle(
                          color: HomePalette.primaryText(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '例如：默认章节规则',
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, '正则表达式'),
                      TextField(
                        controller: _ruleController,
                        maxLines: 4,
                        minLines: 3,
                        enabled: !_isSaving,
                        onChanged: (value) => _validateRule(value.trim()),
                        style: TextStyle(
                          color: HomePalette.primaryText(context),
                          fontSize: 13,
                          height: 1.4,
                          fontFamily: 'monospace',
                        ),
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '请输入章节标题匹配规则',
                          errorText:
                              _hasValidated && !_isValid ? _errorMessage : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildRuleHintCard(context),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, '示例文本'),
                      TextField(
                        controller: _exampleController,
                        maxLines: 3,
                        minLines: 2,
                        enabled: !_isSaving,
                        style: TextStyle(
                          color: HomePalette.primaryText(context),
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration(
                          context: context,
                          hintText: '可填写一段示例章节标题，便于后续识别和排查',
                        ),
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
