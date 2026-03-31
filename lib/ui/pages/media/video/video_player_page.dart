import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/models/media/video_item.dart';
import '../../../../providers/media/video_player_provider.dart';
import '../../../../services/media/video/video_player_service.dart';
import 'widgets/video_gesture_detector.dart';

/// 视频播放器页面
class VideoPlayerPage extends ConsumerStatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  ConsumerState<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends ConsumerState<VideoPlayerPage> {
  Timer? _hideControlsTimer;
  bool _showControls = true;
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    _scheduleAutoHide();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(videoPlayerServiceProvider).controller;
    final currentVideo = ref.watch(currentVideoProvider);
    final progress = ref.watch(videoProgressProvider);
    final status = ref.watch(videoPlayStatusProvider);
    final speed = ref.watch(videoSpeedProvider);
    final isLocked = ref.watch(videoControlLockProvider);
    final isFullscreen = ref.watch(videoFullscreenProvider);
    final isBuffering = ref.watch(videoBufferingProvider);
    final control = ref.read(videoControlProvider.notifier);

    final showCenterButton =
        !isLocked && (_showControls || status != VideoPlayStatus.playing);
    final progressValue = _resolveProgress(progress);

    return Scaffold(
      backgroundColor: Colors.black,
      body: VideoGestureDetector(
        currentPosition: progress.position,
        totalDuration: progress.duration,
        enabled: !isLocked,
        onSeek: control.seek,
        onTap: () {
          if (isLocked) {
            _showTemporarily();
            return;
          }
          _toggleControls();
        },
        onDoubleTap: () {
          if (isLocked) return;
          control.togglePlayPause();
          _scheduleAutoHide();
        },
        child: Stack(
          children: [
            Positioned.fill(child: _buildVideoScene(controller)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.48),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.70),
                    ],
                    stops: const [0.0, 0.22, 0.70, 1.0],
                  ),
                ),
              ),
            ),
            if ((_showControls && !isLocked) || isLocked)
              SafeArea(
                child: _buildTopOverlay(
                  context,
                  currentVideo: currentVideo,
                  speed: speed,
                  onBack: () => Navigator.of(context).pop(),
                  onShare: currentVideo == null
                      ? null
                      : () => _shareVideo(currentVideo),
                  onMore: () => _showActionsSheet(
                    context,
                    currentVideo: currentVideo,
                    speed: speed,
                    isFullscreen: isFullscreen,
                  ),
                ),
              ),
            if (showCenterButton)
              Center(
                child: _buildCenterPlayButton(
                  context,
                  status: status,
                  isBuffering: isBuffering,
                  onTap: currentVideo == null
                      ? null
                      : () {
                          control.togglePlayPause();
                          _scheduleAutoHide();
                        },
                ),
              ),
            if (isLocked)
              Positioned(
                left: 18,
                top: MediaQuery.of(context).size.height / 2 - 22,
                child: _buildLockButton(
                  icon: Icons.lock_rounded,
                  onTap: () {
                    control.toggleControlLock();
                    _showTemporarily();
                  },
                ),
              )
            else if (_showControls)
              Positioned(
                left: 18,
                top: MediaQuery.of(context).size.height / 2 - 22,
                child: _buildLockButton(
                  icon: Icons.lock_open_rounded,
                  onTap: () {
                    control.toggleControlLock();
                    _showTemporarily();
                  },
                ),
              ),
            if (_showControls && !isLocked)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _buildBottomOverlay(
                      context,
                      progress: progress,
                      progressValue: progressValue,
                      speed: speed,
                      ratioLabel: _buildRatioLabel(currentVideo),
                      isFullscreen: isFullscreen,
                      status: status,
                      onSeekStart: () {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                      onSeekChanged: (value) {
                        setState(() {
                          _dragValue = value;
                        });
                      },
                      onSeekEnd: (value) {
                        setState(() {
                          _isDragging = false;
                        });
                        final position = Duration(
                          milliseconds:
                              (value * progress.duration.inMilliseconds)
                                  .toInt(),
                        );
                        control.seek(position);
                        _scheduleAutoHide();
                      },
                      onRewind: () {
                        control.rewind(const Duration(seconds: 10));
                        _scheduleAutoHide();
                      },
                      onTogglePlayPause: currentVideo == null
                          ? null
                          : () {
                              control.togglePlayPause();
                              _scheduleAutoHide();
                            },
                      onForward: () {
                        control.forward(const Duration(seconds: 10));
                        _scheduleAutoHide();
                      },
                      onCycleSpeed: () async {
                        await ref
                            .read(videoSpeedProvider.notifier)
                            .cycleSpeed();
                        _scheduleAutoHide();
                      },
                      onToggleFullscreen: () {
                        control.toggleFullscreen();
                        _showTemporarily();
                      },
                      onShowRatio: () => _showRatioHint(currentVideo),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoScene(VideoController? controller) {
    if (controller == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF121318), Color(0xFF1F2B3B), Color(0xFF0D1016)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121318), Color(0xFF1F2B3B), Color(0xFF0D1016)],
        ),
      ),
      child: Center(
        child: Video(
          controller: controller,
          controls: null,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTopOverlay(
    BuildContext context, {
    required VideoItem? currentVideo,
    required double speed,
    required VoidCallback onBack,
    required VoidCallback? onShare,
    required VoidCallback onMore,
  }) {
    final subtitle = <String>[
      currentVideo?.isLocal == true ? '本地视频' : '在线视频',
      if ((currentVideo?.width ?? 0) > 0 && (currentVideo?.height ?? 0) > 0)
        '${currentVideo!.width}×${currentVideo.height}',
      if ((currentVideo?.formattedFileSize ?? '').isNotEmpty)
        currentVideo!.formattedFileSize,
      '${speed.toStringAsFixed(2)}x',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          _buildGlassCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentVideo?.title ?? '视频播放',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildGlassCircleButton(
            icon: Icons.share_outlined,
            onTap: onShare,
          ),
          const SizedBox(width: 8),
          _buildGlassCircleButton(
            icon: Icons.more_horiz_rounded,
            onTap: onMore,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPlayButton(
    BuildContext context, {
    required VideoPlayStatus status,
    required bool isBuffering,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: isBuffering
            ? const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                ),
              )
            : Icon(
                status == VideoPlayStatus.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 42,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildLockButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(
    BuildContext context, {
    required VideoProgress progress,
    required double progressValue,
    required double speed,
    required String ratioLabel,
    required bool isFullscreen,
    required VideoPlayStatus status,
    required VoidCallback onSeekStart,
    required ValueChanged<double> onSeekChanged,
    required ValueChanged<double> onSeekEnd,
    required VoidCallback onRewind,
    required VoidCallback? onTogglePlayPause,
    required VoidCallback onForward,
    required VoidCallback onCycleSpeed,
    required VoidCallback onToggleFullscreen,
    required VoidCallback onShowRatio,
  }) {
    final shownPosition = _isDragging
        ? Duration(
            milliseconds:
                (progressValue * progress.duration.inMilliseconds).toInt(),
          )
        : progress.position;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0A0C12).withValues(alpha: 0.52),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: const Color(0xFF38BDF8),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
              thumbColor: const Color(0xFF818CF8),
            ),
            child: Slider(
              value: progressValue.clamp(0.0, 1.0),
              onChangeStart: (_) => onSeekStart(),
              onChanged:
                  progress.duration.inMilliseconds > 0 ? onSeekChanged : null,
              onChangeEnd:
                  progress.duration.inMilliseconds > 0 ? onSeekEnd : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(shownPosition),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.76),
                ),
              ),
              Text(
                _formatDuration(progress.duration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.76),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: [
                  _buildGlassCircleButton(
                    icon: Icons.replay_10_rounded,
                    onTap: onRewind,
                    size: 42,
                  ),
                  const SizedBox(width: 10),
                  _buildGlassCircleButton(
                    icon: status == VideoPlayStatus.playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onTap: onTogglePlayPause,
                    size: 42,
                  ),
                  const SizedBox(width: 10),
                  _buildGlassCircleButton(
                    icon: Icons.forward_10_rounded,
                    onTap: onForward,
                    size: 42,
                  ),
                ],
              ),
              const Spacer(),
              _buildTextChip(
                label:
                    '${speed.toStringAsFixed(speed == speed.roundToDouble() ? 0 : 2)}x',
                onTap: onCycleSpeed,
              ),
              const SizedBox(width: 10),
              _buildTextChip(
                label: ratioLabel,
                onTap: onShowRatio,
              ),
              const SizedBox(width: 10),
              _buildGlassCircleButton(
                icon: isFullscreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                onTap: onToggleFullscreen,
                size: 42,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCircleButton({
    required IconData icon,
    required VoidCallback? onTap,
    double size = 40,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: size * 0.48,
          color: Colors.white.withValues(alpha: onTap == null ? 0.36 : 1.0),
        ),
      ),
    );
  }

  Widget _buildTextChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withValues(alpha: 0.10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showActionsSheet(
    BuildContext context, {
    required VideoItem? currentVideo,
    required double speed,
    required bool isFullscreen,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF141821),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                _buildSheetAction(
                  icon: Icons.speed_rounded,
                  title: '播放速度',
                  subtitle: '${speed.toStringAsFixed(2)}x',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showSpeedSheet(context);
                  },
                ),
                _buildSheetAction(
                  icon: Icons.aspect_ratio_rounded,
                  title: '画面比例',
                  subtitle: _buildRatioLabel(currentVideo),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showRatioHint(currentVideo);
                  },
                ),
                _buildSheetAction(
                  icon: isFullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  title: isFullscreen ? '退出全屏' : '进入全屏',
                  subtitle: '切换当前播放器显示模式',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ref.read(videoControlProvider.notifier).toggleFullscreen();
                    _showTemporarily();
                  },
                ),
                _buildSheetAction(
                  icon: Icons.share_outlined,
                  title: '分享视频',
                  subtitle: currentVideo == null ? '当前没有可分享视频' : '分享标题和来源信息',
                  onTap: currentVideo == null
                      ? null
                      : () {
                          Navigator.of(sheetContext).pop();
                          _shareVideo(currentVideo);
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSpeedSheet(BuildContext context) {
    final currentSpeed = ref.read(videoSpeedProvider);
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF141821),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '播放速度',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '调整视频播放速度，保持当前播放进度不变',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: speeds.map((speed) {
                    final isSelected = (currentSpeed - speed).abs() < 0.01;
                    return InkWell(
                      onTap: () async {
                        final navigator = Navigator.of(sheetContext);
                        await ref
                            .read(videoSpeedProvider.notifier)
                            .setSpeed(speed);
                        if (!mounted) return;
                        navigator.pop();
                        _showTemporarily();
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1D4ED8)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${speed.toStringAsFixed(speed == speed.roundToDouble() ? 0 : 2)}x',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(
                              alpha: isSelected ? 1.0 : 0.88,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: onTap == null ? 0.32 : 0.88),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: onTap == null ? 0.42 : 0.92),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.white.withValues(alpha: 0.42),
      ),
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _scheduleAutoHide();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  void _showTemporarily() {
    if (!mounted) return;
    setState(() {
      _showControls = true;
    });
    _scheduleAutoHide();
  }

  void _scheduleAutoHide() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _isDragging) return;
      final status = ref.read(videoPlayStatusProvider);
      final isLocked = ref.read(videoControlLockProvider);
      if (status == VideoPlayStatus.playing && !isLocked) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  double _resolveProgress(VideoProgress progress) {
    if (_isDragging) {
      return _dragValue;
    }
    if (progress.duration.inMilliseconds <= 0) {
      return 0.0;
    }
    return progress.position.inMilliseconds / progress.duration.inMilliseconds;
  }

  String _buildRatioLabel(VideoItem? video) {
    final ratio = video?.aspectRatio;
    if (ratio == null || ratio <= 0) {
      return '自动';
    }
    if ((ratio - 16 / 9).abs() < 0.05) return '16:9';
    if ((ratio - 4 / 3).abs() < 0.05) return '4:3';
    if ((ratio - 1.0).abs() < 0.05) return '1:1';
    return '${video?.width ?? '-'}:${video?.height ?? '-'}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _shareVideo(VideoItem? video) async {
    if (video == null) return;

    final lines = <String>[
      '正在播放：${video.title}',
      if ((video.description ?? '').trim().isNotEmpty)
        '说明：${video.description!.trim()}',
      if ((video.url ?? '').trim().isNotEmpty) '链接：${video.url!.trim()}',
      if (video.duration != null) '时长：${video.formattedDuration}',
    ];

    await SharePlus.instance.share(
      ShareParams(text: lines.join('\n')),
    );
  }

  void _showRatioHint(VideoItem? video) {
    final ratio = _buildRatioLabel(video);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('当前画面比例：$ratio')),
    );
  }
}
