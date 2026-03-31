import 'package:flutter/material.dart';
import '../../../../../services/media/music/music_player_service.dart';

/// 播放控制栏组件
class MusicControlBar extends StatelessWidget {
  final MusicPlayStatus status;
  final MusicPlayMode playMode;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlayMode;

  const MusicControlBar({
    super.key,
    required this.status,
    required this.playMode,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onTogglePlayMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 播放模式按钮
        IconButton(
          icon: _getPlayModeIcon(),
          iconSize: 28,
          onPressed: onTogglePlayMode,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),

        // 上一曲
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 36,
          onPressed: status != MusicPlayStatus.loading ? onPrevious : null,
          color: Theme.of(context).colorScheme.onSurface,
        ),

        // 播放/暂停
        _buildPlayButton(context),

        // 下一曲
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 36,
          onPressed: status != MusicPlayStatus.loading ? onNext : null,
          color: Theme.of(context).colorScheme.onSurface,
        ),

        // 播放列表
        IconButton(
          icon: const Icon(Icons.queue_music),
          iconSize: 28,
          onPressed: () {
            // TODO: 打开播放列表
          },
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    final isLoading = status == MusicPlayStatus.loading;
    final isPlaying = status == MusicPlayStatus.playing;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          : IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 32,
              ),
              onPressed: onPlayPause,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
    );
  }

  Icon _getPlayModeIcon() {
    switch (playMode) {
      case MusicPlayMode.sequence:
        return const Icon(Icons.repeat);
      case MusicPlayMode.loop:
        return const Icon(Icons.repeat_on);
      case MusicPlayMode.singleLoop:
        return const Icon(Icons.repeat_one_on);
      case MusicPlayMode.shuffle:
        return const Icon(Icons.shuffle);
    }
  }
}

/// 播放模式图标辅助函数
Icon getPlayModeIcon(MusicPlayMode mode) {
  switch (mode) {
    case MusicPlayMode.sequence:
      return const Icon(Icons.repeat);
    case MusicPlayMode.loop:
      return const Icon(Icons.repeat_on);
    case MusicPlayMode.singleLoop:
      return const Icon(Icons.repeat_one_on);
    case MusicPlayMode.shuffle:
      return const Icon(Icons.shuffle);
  }
}

/// 播放模式名称
String getPlayModeName(MusicPlayMode mode) {
  switch (mode) {
    case MusicPlayMode.sequence:
      return '顺序播放';
    case MusicPlayMode.loop:
      return '列表循环';
    case MusicPlayMode.singleLoop:
      return '单曲循环';
    case MusicPlayMode.shuffle:
      return '随机播放';
  }
}
