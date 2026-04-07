import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:intl/intl.dart';

import '../../../services/file_manage_service.dart';

/// 文件详情对话框
class FileDetailDialog extends StatelessWidget {
  final FileInfo fileInfo;
  final VoidCallback? onOpen;
  final VoidCallback? onImportBook;
  final VoidCallback? onDelete;

  const FileDetailDialog({
    super.key,
    required this.fileInfo,
    this.onOpen,
    this.onImportBook,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fileService = readService(AppServices.fileManageService);
    final icon = fileService.getFileIcon(fileInfo.name, fileInfo.isDirectory);
    final isBookFile =
        !fileInfo.isDirectory && fileService.isBookFile(fileInfo.name);
    final subtitle = fileInfo.isDirectory
        ? '目录信息'
        : isBookFile
            ? '书籍文件 · 支持直接导入'
            : '普通文件';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white.withValues(alpha: 0.94),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF050A12).withValues(alpha: 0.28),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D7E2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: fileInfo.isDirectory
                            ? const [Color(0xFF2BA471), Color(0xFF57D9A3)]
                            : const [Color(0xFF1677FF), Color(0xFF69B1FF)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileInfo.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2329),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF86909C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF86909C),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailCard(label: '路径', value: fileInfo.path),
              const SizedBox(height: 10),
              _DetailCard(
                label: '修改时间',
                value: DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format(fileInfo.lastModified),
              ),
              const SizedBox(height: 10),
              _DetailCard(
                label: fileInfo.isDirectory ? '类型' : '大小',
                value: fileInfo.isDirectory
                    ? '目录'
                    : fileService.formatFileSize(fileInfo.size),
              ),
              if (onOpen != null ||
                  onImportBook != null ||
                  onDelete != null) ...[
                const SizedBox(height: 16),
                if (onOpen != null)
                  _ActionTile(
                    icon: Icons.open_in_new_rounded,
                    title: fileInfo.isDirectory ? '打开目录' : '打开文件',
                    description: fileInfo.isDirectory
                        ? '进入当前目录继续浏览文件内容'
                        : '使用系统默认应用查看或预览内容',
                    gradientColors: const [
                      Color(0xFF1677FF),
                      Color(0xFF69B1FF)
                    ],
                    onTap: () {
                      Navigator.of(context).pop();
                      onOpen?.call();
                    },
                  ),
                if (onImportBook != null) ...[
                  const SizedBox(height: 8),
                  _ActionTile(
                    icon: Icons.menu_book_rounded,
                    title: '导入为书籍',
                    description: '进入书架并自动识别元数据',
                    gradientColors: const [
                      Color(0xFF2BA471),
                      Color(0xFF57D9A3)
                    ],
                    onTap: () {
                      Navigator.of(context).pop();
                      onImportBook?.call();
                    },
                  ),
                ],
                if (onDelete != null) ...[
                  const SizedBox(height: 8),
                  _ActionTile(
                    icon: Icons.delete_outline_rounded,
                    title: fileInfo.isDirectory ? '删除目录' : '删除文件',
                    description: '危险操作单独高亮，避免误触',
                    gradientColors: const [
                      Color(0xFFE34D59),
                      Color(0xFFFF9B8F)
                    ],
                    onTap: () {
                      Navigator.of(context).pop();
                      onDelete?.call();
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String label;
  final String value;

  const _DetailCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF0F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF86909C),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2329),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEDF0F4)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2329),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF86909C),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB8C1CC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
