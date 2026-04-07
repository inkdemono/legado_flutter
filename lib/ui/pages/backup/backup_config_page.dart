import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';

import '../../../config/app_config.dart';
import '../../../services/storage/webdav_service.dart';
import '../../widgets/home/home_shell.dart';

/// 备份恢复配置页面 - WebDAV设置
class BackupConfigPage extends StatefulWidget {
  const BackupConfigPage({super.key});

  @override
  State<BackupConfigPage> createState() => _BackupConfigPageState();
}

class _BackupConfigPageState extends State<BackupConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dirController = TextEditingController();
  final _deviceNameController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _dirController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadConfig() async {
    setState(() {
      _urlController.text = AppConfig.getString(
        'webdav_url',
        defaultValue: WebDavService.defaultWebDavUrl,
      );
      _accountController.text = AppConfig.getString(
        'webdav_account',
        defaultValue: '',
      );
      _passwordController.text = AppConfig.getString(
        'webdav_password',
        defaultValue: '',
      );
      _dirController.text = AppConfig.getString(
        'webdav_dir',
        defaultValue: 'legado',
      );
      _deviceNameController.text = AppConfig.getString(
        'webdav_device_name',
        defaultValue: 'device',
      );
    });
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _connectionStatus = null;
    });

    try {
      await readService(AppServices.webDavService).configure(
        url: _urlController.text.trim(),
        username: _accountController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final isOk = await readService(AppServices.webDavService).check();
      if (!mounted) return;
      setState(() {
        _connectionStatus = isOk ? '连接成功' : '连接失败';
      });
      _showMessage(isOk ? 'WebDAV连接成功' : 'WebDAV连接失败，请检查配置');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _connectionStatus = '连接错误: $e';
      });
      _showMessage('连接错误: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AppConfig.setString('webdav_url', _urlController.text.trim());
      await AppConfig.setString(
        'webdav_account',
        _accountController.text.trim(),
      );
      await AppConfig.setString(
        'webdav_password',
        _passwordController.text.trim(),
      );
      await AppConfig.setString('webdav_dir', _dirController.text.trim());
      await AppConfig.setString(
        'webdav_device_name',
        _deviceNameController.text.trim(),
      );

      await readService(AppServices.webDavService).configure(
        url: _urlController.text.trim(),
        username: _accountController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      _showMessage('配置已保存');
      Navigator.of(context).pop();
    } catch (e) {
      _showMessage('保存失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusState = _statusState;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HomePageBackground(
        glowColors: const [Color(0xFF1677FF), Color(0xFF4F7CFF)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      _buildHeroCard(context),
                      if (_connectionStatus != null) ...[
                        const SizedBox(height: 16),
                        _buildStatusCard(context, statusState),
                      ],
                      const SizedBox(height: 18),
                      _buildSectionLabel(
                        context,
                        title: '服务器配置',
                        subtitle: '连接所需的地址、账号和密码',
                      ),
                      const SizedBox(height: 10),
                      HomeSectionCard(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildTextField(
                              context,
                              controller: _urlController,
                              label: 'WebDAV 服务器地址',
                              hint: 'https://dav.jianguoyun.com/dav/',
                              helper: '支持坚果云、Nextcloud 等 WebDAV 服务',
                              keyboardType: TextInputType.url,
                              tail: 'HTTPS',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '请输入WebDAV服务器地址';
                                }
                                final uri = Uri.tryParse(value.trim());
                                if (uri == null || !uri.hasScheme) {
                                  return '请输入有效的URL';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              context,
                              controller: _accountController,
                              label: '用户名',
                              hint: '请输入 WebDAV 用户名',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '请输入用户名';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              context,
                              controller: _passwordController,
                              label: '密码',
                              hint: '请输入 WebDAV 密码',
                              obscureText: !_passwordVisible,
                              tailWidget: InkWell(
                                onTap: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                borderRadius: BorderRadius.circular(99),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: HomePalette.accentSoft,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    _passwordVisible ? '隐藏' : '显示',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: HomePalette.accentStrong,
                                    ),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '请输入密码';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionLabel(
                        context,
                        title: '目录与设备',
                        subtitle: '用于组织备份目录和设备标识',
                      ),
                      const SizedBox(height: 10),
                      HomeSectionCard(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildTextField(
                              context,
                              controller: _dirController,
                              label: '备份目录',
                              hint: 'legado',
                              helper: '留空则使用根目录',
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              context,
                              controller: _deviceNameController,
                              label: '设备名称',
                              hint: 'device',
                              helper: '用于备份文件名标识',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionLabel(
                        context,
                        title: '使用提示',
                        subtitle: '先测试连接，再保存配置更稳妥',
                      ),
                      const SizedBox(height: 10),
                      HomeSectionCard(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: const [
                            _HintItem(
                              index: '1',
                              title: '先测试，再保存',
                              description: '建议先验证服务端连通性和账号权限，避免保存后才发现目录不可写。',
                            ),
                            SizedBox(height: 12),
                            _HintItem(
                              index: '2',
                              title: '目录可复用',
                              description: '备份目录建议保持稳定，设备名称则用于区分不同终端生成的备份文件。',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              context,
                              label: '测试连接',
                              onTap: _isLoading ? null : _testConnection,
                              isPrimary: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildActionButton(
                              context,
                              label: '保存配置',
                              onTap: _isLoading ? null : _saveConfig,
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusState get _statusState {
    final status = _connectionStatus;
    if (status == null) return _StatusState.idle;
    if (status.contains('成功')) return _StatusState.success;
    if (status.contains('失败')) return _StatusState.failure;
    return _StatusState.error;
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
                  '备份恢复设置',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '配置 WebDAV 同步地址和设备标识',
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
            icon: _isLoading ? Icons.sync_rounded : Icons.save_outlined,
            onTap: _isLoading ? () {} : _saveConfig,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final hasConfig = _urlController.text.trim().isNotEmpty &&
        _accountController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F62FE), Color(0xFF3F8CFF), Color(0xFF89B6FF)],
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
            '跨设备同步中心',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '统一管理 WebDAV 地址、设备标识和备份目录。建议先测试连接，再保存配置。',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard(value: 'WebDAV', label: '同步方式'),
              const SizedBox(width: 10),
              _buildMetricCard(
                value: hasConfig
                    ? _deviceNameController.text.trim().ifEmpty('未命名')
                    : '未配置',
                label: '设备标识',
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
          color: Colors.white.withValues(alpha: 0.16),
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

  Widget _buildStatusCard(BuildContext context, _StatusState state) {
    final config = switch (state) {
      _StatusState.success => (
          background: const Color(0xFFF0FBF5),
          border: const Color(0xFFCBECD9),
          iconBackground: const Color(0xFF2BA471),
          icon: Icons.check_rounded,
          title: '连接校验通过',
        ),
      _StatusState.failure || _StatusState.error => (
          background: const Color(0xFFFFF4F4),
          border: const Color(0xFFF3D1D6),
          iconBackground: const Color(0xFFE34D59),
          icon: Icons.close_rounded,
          title: '连接校验失败',
        ),
      _StatusState.idle => (
          background: const Color(0xFFF5F8FC),
          border: const Color(0xFFE5EAF1),
          iconBackground: const Color(0xFF1677FF),
          icon: Icons.info_outline_rounded,
          title: '等待测试连接',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: config.iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(config.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _connectionStatus!,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    String? helper,
    String? tail,
    Widget? tailWidget,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: HomePalette.secondaryText(context),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: HomePalette.primaryText(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: HomePalette.tertiaryText(context)),
            helperText: helper,
            helperMaxLines: 2,
            suffixIcon: tailWidget ??
                (tail == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Center(
                          widthFactor: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: HomePalette.accentSoft,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              tail,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: HomePalette.accentStrong,
                              ),
                            ),
                          ),
                        ),
                      )),
            filled: true,
            fillColor: HomePalette.mutedCard(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: HomePalette.lineColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: HomePalette.lineColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  const BorderSide(color: HomePalette.accent, width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE34D59)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE34D59)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    final color = isPrimary ? HomePalette.accent : HomePalette.card(context);
    final textColor =
        isPrimary ? Colors.white : HomePalette.primaryText(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: onTap == null ? color.withValues(alpha: 0.5) : color,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPrimary
                  ? HomePalette.accent.withValues(alpha: 0.5)
                  : HomePalette.lineColor(context),
            ),
            boxShadow: isPrimary ? HomePalette.cardShadow(context) : const [],
          ),
          alignment: Alignment.center,
          child: _isLoading && isPrimary
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
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

class _HintItem extends StatelessWidget {
  final String index;
  final String title;
  final String description;

  const _HintItem({
    required this.index,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF3E8),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            index,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFA8C16),
            ),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: HomePalette.primaryText(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
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
    );
  }
}

enum _StatusState {
  idle,
  success,
  failure,
  error,
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
