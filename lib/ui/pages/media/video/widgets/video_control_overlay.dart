import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../providers/media/video_player_provider.dart';
import '../../../../../services/media/video/video_player_service.dart';

/// 视频控制层覆盖组件
class VideoControlOverlay extends ConsumerWidget {
  final VoidCallback? onToggleControls;
  final bool isFullscreen;

  const VideoControlOverlay({
    super.key,
    this.onToggleControls,
    this.isFullscreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(videoPlayStatusProvider);
    final progress = ref.watch(videoProgressProvider);
    final speed = ref.watch(videoSpeedProvider);
    final isBuffering = ref.watch(videoBufferingProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: Column(
        children: [
          // 顶部控制栏
          if (!isFullscreen) _buildTopBar(context),

          // 中间播放控制
          Expanded(
            child: Center(
              child: _buildPlayControls(context, ref, status, isBuffering),
            ),
          ),

          // 底部控制栏
          _buildBottomBar(context, ref, progress, speed),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                '视频播放',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.cast, color: Colors.white),
              onPressed: () {
                // TODO: 投屏
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayControls(
    BuildContext context,
    WidgetRef ref,
    VideoPlayStatus status,
    bool isBuffering,
  ) {
    if (isBuffering) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    final control = ref.read(videoControlProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 快退 10 秒
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.replay_10, color: Colors.white),
          onPressed: () => control.rewind(const Duration(seconds: 10)),
        ),

        const SizedBox(width: 32),

        // 播放/暂停
        GestureDetector(
          onTap: () => control.togglePlayPause(),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == VideoPlayStatus.playing
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: 32),

        // 快进 10 秒
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.forward_10, color: Colors.white),
          onPressed: () => control.forward(const Duration(seconds: 10)),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    VideoProgress progress,
    double speed,
  ) {
    final control = ref.read(videoControlProvider.notifier);

    return SafeArea(
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // 进度条
            _buildProgressBar(context, ref, progress),

            const SizedBox(height: 8),

            // 底部按钮
            Row(
              children: [
                // 播放/暂停
                IconButton(
                  icon: Icon(
                    progress.position > Duration.zero
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () => control.togglePlayPause(),
                ),

                // 时间显示
                Text(
                  '${progress.formattedPosition} / ${progress.formattedDuration}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),

                const Spacer(),

                // 倍速
                TextButton(
                  onPressed: () {
                    ref.read(videoSpeedProvider.notifier).cycleSpeed();
                  },
                  child: Text(
                    '${speed}x',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),

                // 全屏
                IconButton(
                  icon: Icon(
                    isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: () => control.toggleFullscreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    WidgetRef ref,
    VideoProgress progress,
  ) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
        thumbColor: Theme.of(context).colorScheme.primary,
      ),
      child: Slider(
        value: progress.progress.clamp(0.0, 1.0),
        onChanged: (value) {
          final duration = progress.duration;
          final position = Duration(
            milliseconds: (value * duration.inMilliseconds).toInt(),
          );
          ref.read(videoProgressProvider.notifier).seek(position);
        },
      ),
    );
  }
}
