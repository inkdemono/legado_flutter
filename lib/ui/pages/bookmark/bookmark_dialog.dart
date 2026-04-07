import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';

import '../../../data/models/bookmark.dart';
import '../../../services/bookmark_service.dart';
import '../../widgets/base/base_bottom_sheet_stateful.dart';

/// 书签编辑对话框
class BookmarkDialog extends BaseBottomSheetStateful {
  final Bookmark bookmark;
  final bool isEdit;

  const BookmarkDialog({
    super.key,
    required this.bookmark,
    this.isEdit = false,
  }) : super(
          title: null,
          showTitleBar: false,
          padding: EdgeInsets.zero,
          heightFactor: 0.82,
        );

  @override
  State<BookmarkDialog> createState() => _BookmarkDialogState();
}

class _BookmarkDialogState extends BaseBottomSheetState<BookmarkDialog> {
  late TextEditingController _bookTextController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _bookTextController = TextEditingController(text: widget.bookmark.bookText);
    _contentController = TextEditingController(text: widget.bookmark.content);
  }

  @override
  void dispose() {
    _bookTextController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F1720).withValues(alpha: 0.14),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD8CFC6),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  widget.bookmark.bookName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2329),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '书签编辑',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      widget.bookmark.chapterName,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('书签文本'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _bookTextController,
                    hintText: '输入书签文本',
                    minLines: 3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('摘要'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _contentController,
                    hintText: '输入摘要内容（可选）',
                    minLines: 6,
                    maxLines: 8,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
              ),
            ),
            child: Row(
              children: [
                if (widget.isEdit)
                  Expanded(
                    child: _buildActionButton(
                      label: '删除',
                      backgroundColor: const Color(0xFFFFF2F0),
                      foregroundColor: const Color(0xFFE34D59),
                      borderColor: const Color(0xFFFFD8D2),
                      onTap: _showDeleteDialog,
                    ),
                  ),
                if (widget.isEdit) const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    label: '取消',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4E5969),
                    borderColor: const Color(0xFFEDF0F4),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 12 ~/ 10,
                  child: _buildActionButton(
                    label: '保存',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                    ),
                    foregroundColor: Colors.white,
                    onTap: _saveBookmark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2329),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required int minLines,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
        color: Color(0xFF4E5969),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF86909C)),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEDF0F4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEDF0F4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF59E0B)),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    Color? backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
    LinearGradient? gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: gradient == null ? backgroundColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: borderColor == null ? null : Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBookmark() async {
    final updatedBookmark = Bookmark(
      time: widget.bookmark.time,
      bookName: widget.bookmark.bookName,
      bookAuthor: widget.bookmark.bookAuthor,
      chapterIndex: widget.bookmark.chapterIndex,
      chapterPos: widget.bookmark.chapterPos,
      chapterName: widget.bookmark.chapterName,
      bookText: _bookTextController.text.trim(),
      content: _contentController.text.trim(),
    );

    await readService(AppServices.bookmarkService).addBookmark(updatedBookmark);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除书签'),
        content: const Text('确定要删除这个书签吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await readService(AppServices.bookmarkService)
                  .deleteBookmark(widget.bookmark.time);
              if (!mounted) return;
              Navigator.pop(this.context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
