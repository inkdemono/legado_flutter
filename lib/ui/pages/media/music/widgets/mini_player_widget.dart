import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../providers/media/music_player_provider.dart';
import '../../../../../services/media/music/music_player_service.dart';
import '../music_player_page.dart';

/// 迷你播放器组件
/// 显示在页面底部，展示当前播放曲目和简单控制
class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = ref.watch(currentTrackProvider);
    final status = ref.watch(musicPlayStatusProvider);
    final progress = ref.watch(musicProgressProvider);

    if (currentTrack == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        // 打开完整播放器页面
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MusicPlayerPage(),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 进度条
            LinearProgressIndicator(
              value: progress.progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 2,
            ),

            // 内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // 封面
                    _buildCover(context, currentTrack),

                    const SizedBox(width: 12),

                    // 曲目信息
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.title,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (currentTrack.artist != null)
                            Text(
                              currentTrack.artist!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),

                    // 控制按钮
                    _buildControls(context, ref, status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context, dynamic track) {
    final coverUrl = track.displayCover;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: coverUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildCoverImage(coverUrl, context),
            )
          : _buildDefaultIcon(context),
    );
  }

  Widget _buildCoverImage(String coverUrl, BuildContext context) {
    if (coverUrl.startsWith('/') || coverUrl.startsWith('file://')) {
      final localPath = coverUrl.startsWith('file://')
          ? Uri.parse(coverUrl).toFilePath()
          : coverUrl;
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildDefaultIcon(context),
      );
    }

    return Image.network(
      coverUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(context),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Icon(
      Icons.music_note,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  Widget _buildControls(
      BuildContext context, WidgetRef ref, MusicPlayStatus status) {
    final control = ref.read(musicControlProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 播放/暂停
        IconButton(
          icon: Icon(
            status == MusicPlayStatus.playing ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: () => control.togglePlayPause(),
        ),

        // 下一曲
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: () => control.next(),
        ),
      ],
    );
  }
}
