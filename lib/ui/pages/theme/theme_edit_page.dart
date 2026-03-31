import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../data/models/theme_config.dart';
import '../../../services/theme_service.dart';
import '../../widgets/home/home_shell.dart';

/// 主题编辑页面
class ThemeEditPage extends StatefulWidget {
  final ThemeConfig? config;

  const ThemeEditPage({super.key, this.config});

  @override
  State<ThemeEditPage> createState() => _ThemeEditPageState();
}

class _ThemeEditPageState extends State<ThemeEditPage> {
  late final TextEditingController _nameController;
  late bool _isNightTheme;
  late Color _primaryColor;
  late Color _accentColor;
  late Color _backgroundColor;
  late Color _bottomBackgroundColor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.config != null) {
      _nameController = TextEditingController(text: widget.config!.themeName);
      _isNightTheme = widget.config!.isNightTheme;
      _primaryColor = _parseColor(widget.config!.primaryColor);
      _accentColor = _parseColor(widget.config!.accentColor);
      _backgroundColor = _parseColor(widget.config!.backgroundColor);
      _bottomBackgroundColor = _parseColor(widget.config!.bottomBackground);
    } else {
      _nameController = TextEditingController();
      _isNightTheme = false;
      _applyModeDefaults(false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  String _colorToString(Color color) {
    final hex = color.toARGB32().toRadixString(16).toUpperCase();
    return '#${hex.substring(2)}';
  }

  void _applyModeDefaults(bool isNight) {
    _isNightTheme = isNight;
    if (isNight) {
      _primaryColor = const Color(0xFF546E7A);
      _accentColor = const Color(0xFFBF360C);
      _backgroundColor = const Color(0xFF212121);
      _bottomBackgroundColor = const Color(0xFF303030);
    } else {
      _primaryColor = const Color(0xFF7D5C43);
      _accentColor = const Color(0xFFC96D3A);
      _backgroundColor = const Color(0xFFF7F1EA);
      _bottomBackgroundColor = const Color(0xFFE9DDCF);
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('请输入主题名称');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final config = ThemeConfig(
        themeName: _nameController.text.trim(),
        isNightTheme: _isNightTheme,
        primaryColor: _colorToString(_primaryColor),
        accentColor: _colorToString(_accentColor),
        backgroundColor: _colorToString(_backgroundColor),
        bottomBackground: _colorToString(_bottomBackgroundColor),
      );

      final configs = await ThemeService.instance.loadConfigs();
      if (widget.config != null &&
          widget.config!.themeName != config.themeName) {
        final oldIndex = configs.indexWhere((item) => item == widget.config);
        if (oldIndex >= 0) {
          await ThemeService.instance.deleteConfig(oldIndex);
        }
      }

      await ThemeService.instance.addConfig(config);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      _showMessage('保存失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showColorPicker(
    String title,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hslWithSaturation,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.config == null ? '新建主题' : '编辑主题';
    final description = widget.config == null
        ? '定义一套新的阅读配色，用于书架、阅读页和底栏。'
        : '调整已有主题的关键色和昼夜模式，预览会同步展示整体方向。';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFFC96D3A), Color(0xFF7D5C43)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context, title),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    _buildTitleCard(context, title, description),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '主题模式',
                      subtitle: '昼夜模式会影响默认配色方向',
                    ),
                    const SizedBox(height: 10),
                    HomeSectionCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModeToggle(context),
                          const SizedBox(height: 14),
                          Text(
                            _isNightTheme
                                ? '当前为深色主题，适合低光阅读。'
                                : '当前为浅色主题，适合纸页和日间阅读。',
                            style: TextStyle(
                              fontSize: 12,
                              color: HomePalette.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '关键颜色',
                      subtitle: '点击条目即可调整主题主色和背景层次',
                    ),
                    const SizedBox(height: 10),
                    HomeSectionCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _ColorTile(
                            title: '主色',
                            description: '书架标题、导航重点',
                            color: _primaryColor,
                            onTap: () =>
                                _showColorPicker('选择主色', _primaryColor, (
                              color,
                            ) {
                              setState(() {
                                _primaryColor = color;
                              });
                            }),
                          ),
                          const SizedBox(height: 10),
                          _ColorTile(
                            title: '强调色',
                            description: '高亮按钮、阅读进度',
                            color: _accentColor,
                            onTap: () =>
                                _showColorPicker('选择强调色', _accentColor, (
                              color,
                            ) {
                              setState(() {
                                _accentColor = color;
                              });
                            }),
                          ),
                          const SizedBox(height: 10),
                          _ColorTile(
                            title: '背景色',
                            description: '页面底色、阅读基底',
                            color: _backgroundColor,
                            onTap: () =>
                                _showColorPicker('选择背景色', _backgroundColor, (
                              color,
                            ) {
                              setState(() {
                                _backgroundColor = color;
                              });
                            }),
                          ),
                          const SizedBox(height: 10),
                          _ColorTile(
                            title: '底栏背景',
                            description: '底部工具栏和浮层',
                            color: _bottomBackgroundColor,
                            onTap: () => _showColorPicker(
                              '选择底部背景色',
                              _bottomBackgroundColor,
                              (color) {
                                setState(() {
                                  _bottomBackgroundColor = color;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionLabel(
                      context,
                      title: '即时预览',
                      subtitle: '预览会同步顶部主色、卡片背景和按钮强调色',
                    ),
                    const SizedBox(height: 10),
                    _buildPreviewCard(context),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
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
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: HomePalette.primaryText(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildHeaderButton(
            context,
            icon: _isSaving ? Icons.sync_rounded : Icons.check_rounded,
            onTap: _isSaving ? () {} : _save,
            highlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard(
    BuildContext context,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFFFFFAF5).withValues(alpha: 0.86),
        border:
            Border.all(color: const Color(0xFF7D5C43).withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F3A2D).withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _nameController.text.trim().isEmpty
                ? title
                : _nameController.text.trim(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: HomePalette.primaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: HomePalette.secondaryText(context),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: HomePalette.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: '主题名称',
              hintText: '请输入主题名称',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: HomePalette.lineColor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: HomePalette.lineColor(context)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Color(0xFFC96D3A), width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE4D7),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          _buildModeButton(
            context,
            label: '浅色',
            selected: !_isNightTheme,
            onTap: () => setState(() {
              _applyModeDefaults(false);
            }),
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            context,
            label: '深色',
            selected: _isNightTheme,
            onTap: () => setState(() {
              _applyModeDefaults(true);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF4F3A2D).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : const [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected
                  ? const Color(0xFF7D5C43)
                  : HomePalette.secondaryText(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final tagBackground = _isNightTheme
        ? _accentColor.withValues(alpha: 0.18)
        : const Color(0xFFEFE2D3);

    return HomeSectionCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      color: _backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _primaryColor.withValues(alpha: 0.16),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryColor, _accentColor],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '书架',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '主题预览会同步到顶部渐变、书卡阴影与按钮强调色',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildPreviewBook(
                          const [Color(0xFFB08054), Color(0xFF6B4A38)],
                        ),
                        const SizedBox(width: 10),
                        _buildPreviewBook(
                          const [Color(0xFFCF7F44), Color(0xFF924C2D)],
                        ),
                        const SizedBox(width: 10),
                        _buildPreviewBook(
                          const [Color(0xFF6A7A4F), Color(0xFF425C36)],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildPreviewTag(
                          '纸张模式',
                          background: tagBackground,
                          textColor: _primaryTextForBackground(tagBackground),
                        ),
                        const SizedBox(width: 8),
                        _buildPreviewTag(
                          _isNightTheme ? '深色' : '低饱和',
                          background: tagBackground,
                          textColor: _primaryTextForBackground(tagBackground),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '应用主题',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _primaryTextForBackground(_accentColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _bottomBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '底栏背景示意',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color:
                              _primaryTextForBackground(_bottomBackgroundColor),
                        ),
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

  Widget _buildPreviewBook(List<Color> colors) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.16),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTag(
    String text, {
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(
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
    bool highlighted = false,
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
            color: highlighted
                ? const Color(0xFF7D5C43).withValues(alpha: 0.12)
                : HomePalette.card(context).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlighted
                  ? const Color(0xFF7D5C43).withValues(alpha: 0.16)
                  : HomePalette.lineColor(context),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: highlighted
                ? const Color(0xFF7D5C43)
                : HomePalette.primaryText(context),
          ),
        ),
      ),
    );
  }

  Color _primaryTextForBackground(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : const Color(0xFF2C241F);
  }
}

class _ColorTile extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ColorTile({
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.45)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_colorToHex(color)} $description',
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.secondaryText(context),
                      ),
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
        ),
      ),
    );
  }

  String _colorToHex(Color color) {
    final hex = color.toARGB32().toRadixString(16).toUpperCase();
    return '#${hex.substring(2)}';
  }
}
