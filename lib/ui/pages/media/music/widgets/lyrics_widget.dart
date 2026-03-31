import 'package:flutter/material.dart';

/// 歌词行模型
class LyricsLine {
  final Duration time;
  final String text;

  const LyricsLine({
    required this.time,
    required this.text,
  });
}

/// 歌词显示组件
class LyricsWidget extends StatefulWidget {
  /// 解析后的歌词行列表
  final List<LyricsLine> lyrics;

  /// 当前播放位置
  final Duration position;

  /// 点击歌词行回调
  final ValueChanged<Duration>? onTap;

  const LyricsWidget({
    super.key,
    required this.lyrics,
    this.position = Duration.zero,
    this.onTap,
  });

  @override
  State<LyricsWidget> createState() => _LyricsWidgetState();

  /// 解析 LRC 格式歌词
  static List<LyricsLine> parseLrc(String lrcContent) {
    final lines = <LyricsLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (final line in lrcContent.split('\n')) {
      final match = regex.firstMatch(line.trim());
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!.padRight(3, '0'));
        final text = match.group(4)?.trim() ?? '';

        if (text.isNotEmpty) {
          lines.add(LyricsLine(
            time: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            ),
            text: text,
          ));
        }
      }
    }

    return lines;
  }
}

class _LyricsWidgetState extends State<LyricsWidget> {
  final ScrollController _scrollController = ScrollController();
  int _currentLineIndex = -1;

  @override
  void didUpdateWidget(LyricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCurrentLine();
  }

  void _updateCurrentLine() {
    if (widget.lyrics.isEmpty) return;

    int newIndex = -1;
    for (int i = 0; i < widget.lyrics.length; i++) {
      if (widget.lyrics[i].time <= widget.position) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex != _currentLineIndex && newIndex >= 0) {
      _currentLineIndex = newIndex;
      _scrollToLine(newIndex);
    }
  }

  void _scrollToLine(int index) {
    if (!_scrollController.hasClients) return;

    // 计算目标位置，使当前行居中
    const itemHeight = 50.0;
    final targetOffset = index * itemHeight -
        (_scrollController.position.maxScrollExtent / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lyrics.isEmpty) {
      return Center(
        child: Text(
          '暂无歌词',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 100),
      itemCount: widget.lyrics.length,
      itemBuilder: (context, index) {
        final line = widget.lyrics[index];
        final isCurrentLine = index == _currentLineIndex;

        return GestureDetector(
          onTap: () => widget.onTap?.call(line.time),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: isCurrentLine
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
                  ),
              child: Text(
                line.text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}
