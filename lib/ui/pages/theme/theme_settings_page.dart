import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme_config.dart';
import '../../../data/models/theme_config.dart';
import '../../../services/theme_service.dart';
import '../../widgets/home/home_shell.dart';
import 'theme_edit_page.dart';

/// 主题设置页面
class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  List<ThemeConfig> _configs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadConfigs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final configs = await ThemeService.instance.loadConfigs();
      if (!mounted) return;
      setState(() {
        _configs = configs;
      });
    } catch (e) {
      _showMessage('加载主题配置失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openCreateTheme() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ThemeEditPage()),
    );
    if (result == true) {
      await _loadConfigs();
    }
  }

  Future<void> _openEditTheme(ThemeConfig config) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ThemeEditPage(config: config)),
    );
    if (result == true) {
      await _loadConfigs();
    }
  }

  Future<void> _applyTheme(ThemeConfig config) async {
    try {
      await ThemeService.instance.applyConfig(config);
      ref.invalidate(themeModeProvider);
      _showMessage('已应用主题: ${config.themeName}');
    } catch (e) {
      _showMessage('应用主题失败: $e');
    }
  }

  Future<void> _deleteTheme(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除主题 "${_configs[index].themeName}" 吗？'),
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
      await ThemeService.instance.deleteConfig(index);
      await _loadConfigs();
      _showMessage('删除成功');
    } catch (e) {
      _showMessage('删除失败: $e');
    }
  }

  Future<void> _shareTheme(ThemeConfig config) async {
    try {
      final jsonString = jsonEncode(config.toJson());
      await Clipboard.setData(ClipboardData(text: jsonString));
      _showMessage('主题配置已复制到剪贴板');
    } catch (e) {
      _showMessage('复制失败: $e');
    }
  }

  Future<void> _importTheme() async {
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    if (text?.text == null || text!.text!.isEmpty) {
      _showMessage('剪贴板为空');
      return;
    }

    try {
      final success = await ThemeService.instance.addConfigFromJson(text.text!);
      if (success) {
        await _loadConfigs();
        _showMessage('导入成功');
      } else {
        _showMessage('导入失败：格式不正确');
      }
    } catch (e) {
      _showMessage('导入失败: $e');
    }
  }

  Future<void> _saveCurrentTheme() async {
    final nameController = TextEditingController();
    final isNightTheme = ref.read(themeModeProvider) == ThemeMode.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存当前主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '主题名称',
                hintText: '请输入主题名称',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              '主题类型: ${isNightTheme ? '深色' : '浅色'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (confirmed != true || nameController.text.trim().isEmpty) return;

    try {
      await ThemeService.instance.saveCurrentTheme(
        nameController.text.trim(),
        isNightTheme,
      );
      await _loadConfigs();
      _showMessage('保存成功');
    } catch (e) {
      _showMessage('保存失败: $e');
    }
  }

  Color _parseColor(String colorString) {
    try {
      var hex = colorString.replaceFirst('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nightCount = _configs.where((config) => config.isNightTheme).length;
    final lightCount = _configs.length - nightCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F7CFF).withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openCreateTheme,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add_rounded, size: 30),
        ),
      ),
      body: HomePageBackground(
        glowColors: const [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadConfigs,
                  child: _buildBody(
                    context,
                    totalCount: _configs.length,
                    nightCount: nightCount,
                    lightCount: lightCount,
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
      child: Row(
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
                  '主题设置',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '管理保存的阅读主题与配色方案',
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                Icons.more_horiz_rounded,
                color: HomePalette.primaryText(context),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 'import':
                  _importTheme();
                  break;
                case 'save_current':
                  _saveCurrentTheme();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.paste_rounded),
                    SizedBox(width: 8),
                    Text('从剪贴板导入'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'save_current',
                child: Row(
                  children: [
                    Icon(Icons.save_outlined),
                    SizedBox(width: 8),
                    Text('保存当前主题'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required int totalCount,
    required int nightCount,
    required int lightCount,
  }) {
    if (_isLoading) {
      return ListView(
        padding: EdgeInsets.all(24),
        children: [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final children = <Widget>[
      _buildSummaryCard(
        context,
        totalCount: totalCount,
        nightCount: nightCount,
        lightCount: lightCount,
      ),
      const SizedBox(height: 16),
      HomeSectionTitle(
        title: '主题库',
        subtitle: _configs.isEmpty ? '还没有自定义主题' : '点击卡片即可应用当前主题',
      ),
      const SizedBox(height: 10),
    ];

    if (_configs.isEmpty) {
      children.add(
        HomeSectionCard(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: HomePalette.mutedCard(context),
                    shape: BoxShape.circle,
                    border: Border.all(color: HomePalette.lineColor(context)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.palette_outlined,
                    size: 38,
                    color: HomePalette.tertiaryText(context),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无主题配置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '可以新建主题，或直接从剪贴板导入别人分享的主题 JSON。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: HomePalette.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _openCreateTheme,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('新建主题'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _importTheme,
                      icon: const Icon(Icons.paste_rounded),
                      label: const Text('导入主题'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      children.addAll(
        _configs.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ThemeItemCard(
              config: entry.value,
              parseColor: _parseColor,
              onApply: () => _applyTheme(entry.value),
              onEdit: () => _openEditTheme(entry.value),
              onDelete: () => _deleteTheme(entry.key),
              onShare: () => _shareTheme(entry.value),
            ),
          );
        }),
      );
    }

    children.add(const SizedBox(height: 96));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: children,
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required int totalCount,
    required int nightCount,
    required int lightCount,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F7CFF), Color(0xFF7C5CFF)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F7CFF).withValues(alpha: 0.26),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '主题工作台',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.98),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '保存你常用的浅色和深色组合，也可以从当前阅读效果快速沉淀出新主题。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildSummaryMetric(value: '$totalCount', label: '全部主题'),
              const SizedBox(width: 10),
              _buildSummaryMetric(value: '$lightCount', label: '浅色'),
              const SizedBox(width: 10),
              _buildSummaryMetric(value: '$nightCount', label: '深色'),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSummaryAction(
                label: '保存当前主题',
                icon: Icons.save_outlined,
                onTap: _saveCurrentTheme,
              ),
              _buildSummaryAction(
                label: '导入主题',
                icon: Icons.paste_rounded,
                onTap: _importTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
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

  Widget _buildSummaryAction({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
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

class _ThemeItemCard extends StatelessWidget {
  final ThemeConfig config;
  final Color Function(String) parseColor;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _ThemeItemCard({
    required this.config,
    required this.parseColor,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final previewColors = [
      parseColor(config.primaryColor),
      parseColor(config.accentColor),
      parseColor(config.backgroundColor),
      parseColor(config.bottomBackground),
    ];

    return HomeSectionCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      onTap: onApply,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [previewColors[0], previewColors[1]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  config.isNightTheme
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.themeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.isNightTheme ? '深色主题' : '浅色主题',
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: '更多操作',
                onSelected: (value) {
                  switch (value) {
                    case 'apply':
                      onApply();
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'share':
                      onShare();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'apply',
                    child: Text('应用'),
                  ),
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('编辑'),
                  ),
                  PopupMenuItem<String>(
                    value: 'share',
                    child: Text('分享'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('删除'),
                  ),
                ],
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: HomePalette.tertiaryText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: previewColors
                .map(
                  (color) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HomePalette.lineColor(context),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
