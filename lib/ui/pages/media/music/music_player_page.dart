import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/models/media/music_track.dart';
import '../../../../providers/media/music_player_provider.dart';
import '../../../../services/media/music/music_player_service.dart';
import 'widgets/album_cover_widget.dart';
import 'widgets/lyrics_widget.dart';

/// 音乐播放器页面
class MusicPlayerPage extends ConsumerStatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  ConsumerState<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends ConsumerState<MusicPlayerPage> {
  bool _showLyrics = false;
  bool _isDragging = false;
  double _dragValue = 0.0;
  double _playbackSpeed = 1.0;
  int _sleepMinutes = 0;

  @override
  void initState() {
    super.initState();
    final service = ref.read(musicPlayerServiceProvider);
    _playbackSpeed = service.player.speed;
    _sleepMinutes = service.sleepMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(musicPlayStatusProvider);
    final currentTrack = ref.watch(currentTrackProvider);
    final progress = ref.watch(musicProgressProvider);
    final playMode = ref.watch(musicPlayModeProvider);
    final playlist = ref.watch(musicPlaylistProvider);
    final currentIndex = ref.watch(currentTrackIndexProvider);
    final control = ref.read(musicControlProvider.notifier);

    final lyrics = _parseLyrics(currentTrack);
    final progressValue = _resolveProgress(progress);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1130),
              Color(0xFF6D50D8),
              Color(0xFF171B38),
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -60,
              child: _GlowBubble(
                color: const Color(0xFFFF7AA5).withValues(alpha: 0.32),
                size: 260,
              ),
            ),
            Positioned(
              top: 48,
              right: -72,
              child: _GlowBubble(
                color: const Color(0xFF7DD3FC).withValues(alpha: 0.24),
                size: 220,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(
                    context,
                    currentIndex: currentIndex,
                    playlistLength: playlist.length,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                      child: Column(
                        children: [
                          _buildArtworkSection(
                            context,
                            track: currentTrack,
                            isPlaying: status == MusicPlayStatus.playing,
                          ),
                          const SizedBox(height: 28),
                          _buildTrackInfo(currentTrack),
                          const SizedBox(height: 20),
                          _buildLyricsPanel(
                            context,
                            lyrics: lyrics,
                            position: progress.position,
                            onSeek: control.seek,
                          ),
                          const SizedBox(height: 22),
                          _buildProgressSection(
                            context,
                            progressValue: progressValue,
                            position: progress.position,
                            duration: progress.duration,
                            onChanged: (value) {
                              setState(() {
                                _isDragging = true;
                                _dragValue = value;
                              });
                            },
                            onChangeEnd: (value) {
                              final position = Duration(
                                milliseconds:
                                    (value * progress.duration.inMilliseconds)
                                        .toInt(),
                              );
                              setState(() {
                                _isDragging = false;
                              });
                              control.seek(position);
                            },
                          ),
                          const SizedBox(height: 26),
                          _buildControlRow(
                            context,
                            status: status,
                            playMode: playMode,
                            onTogglePlayMode: () {
                              ref.read(musicPlayModeProvider.notifier).toggle();
                            },
                            onPrevious: status != MusicPlayStatus.loading
                                ? control.previous
                                : null,
                            onPlayPause: currentTrack != null
                                ? control.togglePlayPause
                                : null,
                            onNext: status != MusicPlayStatus.loading
                                ? control.next
                                : null,
                            onQueue: playlist.isNotEmpty
                                ? () => _showQueueSheet(
                                      context,
                                      playlist: playlist,
                                      currentIndex: currentIndex,
                                      onSelect: (index) async {
                                        Navigator.of(context).pop();
                                        await control.skipToIndex(index);
                                        if (status != MusicPlayStatus.playing) {
                                          await control.play();
                                        }
                                      },
                                    )
                                : null,
                          ),
                          const SizedBox(height: 30),
                          _buildBottomTools(
                            context,
                            currentTrack: currentTrack,
                            hasLyrics: lyrics.isNotEmpty,
                            onTimerTap: () => _showSleepTimerSheet(context),
                            onSpeedTap: () => _showSpeedSheet(context),
                            onLyricsTap: () {
                              setState(() {
                                _showLyrics = !_showLyrics;
                              });
                            },
                            onShareTap: () => _shareTrack(currentTrack),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required int currentIndex,
    required int playlistLength,
  }) {
    final trackNumber = currentIndex >= 0 && playlistLength > 0
        ? '${currentIndex + 1}/$playlistLength'
        : '未开始';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _buildTopButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  '正在播放',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '播放队列 $trackNumber',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          _buildTopButton(
            icon: Icons.more_horiz_rounded,
            onTap: () => _showActionsSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkSection(
    BuildContext context, {
    required MusicTrack? track,
    required bool isPlaying,
  }) {
    final size = MediaQuery.of(context).size.width.clamp(320.0, 480.0) * 0.72;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFF262636),
              Color(0xFF15151C),
              Color(0xFF0E1018),
            ],
            stops: [0.0, 0.54, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.56,
            height: size * 0.56,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: AlbumCoverWidget(
              track: track,
              isPlaying: isPlaying,
              size: size * 0.46,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(MusicTrack? track) {
    return Column(
      children: [
        Text(
          track?.title ?? '未知曲目',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 28,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _buildSubtitle(track),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.74),
          ),
        ),
      ],
    );
  }

  Widget _buildLyricsPanel(
    BuildContext context, {
    required List<LyricsLine> lyrics,
    required Duration position,
    required ValueChanged<Duration> onSeek,
  }) {
    final hasLyrics = lyrics.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      height: _showLyrics ? 220 : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: _showLyrics
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasLyrics ? '歌词' : '歌词不可用',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: hasLyrics
                      ? Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: const Color(0xFFFFD36F),
                                  onSurfaceVariant:
                                      Colors.white.withValues(alpha: 0.56),
                                ),
                          ),
                          child: LyricsWidget(
                            lyrics: lyrics,
                            position: position,
                            onTap: onSeek,
                          ),
                        )
                      : Center(
                          child: Text(
                            '当前曲目没有可解析的歌词内容',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          ),
                        ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  hasLyrics ? Icons.lyrics_outlined : Icons.lyrics_outlined,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasLyrics ? '歌词区已收起，点下方“歌词”可展开同步滚动。' : '当前没有歌词，默认态不打断播放操作。',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context, {
    required double progressValue,
    required Duration position,
    required Duration duration,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    final shownPosition = _isDragging
        ? Duration(
            milliseconds: (progressValue * duration.inMilliseconds).toInt(),
          )
        : position;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: const Color(0xFFFFD36F),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.16),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: progressValue.clamp(0.0, 1.0),
            onChanged: duration.inMilliseconds > 0 ? onChanged : null,
            onChangeEnd: duration.inMilliseconds > 0 ? onChangeEnd : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(shownPosition),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlRow(
    BuildContext context, {
    required MusicPlayStatus status,
    required MusicPlayMode playMode,
    required VoidCallback onTogglePlayMode,
    required VoidCallback? onPrevious,
    required VoidCallback? onPlayPause,
    required VoidCallback? onNext,
    required VoidCallback? onQueue,
  }) {
    final isPlaying = status == MusicPlayStatus.playing;
    final isLoading = status == MusicPlayStatus.loading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMiniControlButton(
          icon: _getPlayModeIcon(playMode),
          onTap: onTogglePlayMode,
        ),
        const SizedBox(width: 18),
        _buildMiniControlButton(
          icon: Icons.skip_previous_rounded,
          onTap: onPrevious,
        ),
        const SizedBox(width: 18),
        _buildPlayButton(
          context,
          isPlaying: isPlaying,
          isLoading: isLoading,
          onTap: onPlayPause,
        ),
        const SizedBox(width: 18),
        _buildMiniControlButton(
          icon: Icons.skip_next_rounded,
          onTap: onNext,
        ),
        const SizedBox(width: 18),
        _buildMiniControlButton(
          icon: Icons.queue_music_rounded,
          onTap: onQueue,
        ),
      ],
    );
  }

  Widget _buildBottomTools(
    BuildContext context, {
    required MusicTrack? currentTrack,
    required bool hasLyrics,
    required VoidCallback onTimerTap,
    required VoidCallback onSpeedTap,
    required VoidCallback onLyricsTap,
    required VoidCallback onShareTap,
  }) {
    final timerLabel = _sleepMinutes > 0 ? '$_sleepMinutes分' : '定时';
    final speedLabel = '${_playbackSpeed.toStringAsFixed(1)}x';

    return Row(
      children: [
        Expanded(
          child: _buildToolButton(
            label: timerLabel,
            subtitle: '定时',
            icon: Icons.timer_outlined,
            onTap: onTimerTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildToolButton(
            label: speedLabel,
            subtitle: '倍速',
            icon: Icons.speed_rounded,
            onTap: onSpeedTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildToolButton(
            label: _showLyrics ? '已展开' : (hasLyrics ? '可展开' : '暂无'),
            subtitle: '歌词',
            icon: Icons.lyrics_outlined,
            onTap: onLyricsTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildToolButton(
            label: currentTrack == null ? '不可用' : '分享',
            subtitle: '分享',
            icon: Icons.share_outlined,
            onTap: currentTrack == null ? null : onShareTap,
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    Colors.white.withValues(alpha: onTap == null ? 0.32 : 0.88),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white
                      .withValues(alpha: onTap == null ? 0.42 : 0.88),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniControlButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 24,
            color: Colors.white.withValues(alpha: onTap == null ? 0.36 : 0.92),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton(
    BuildContext context, {
    required bool isPlaying,
    required bool isLoading,
    required VoidCallback? onTap,
  }) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFD6E6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Color(0xFF6B3CE9),
                ),
              ),
            )
          : IconButton(
              onPressed: onTap,
              icon: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 38,
                color: const Color(0xFF6B3CE9),
              ),
            ),
    );
  }

  void _showActionsSheet(BuildContext context) {
    final currentTrack = ref.read(currentTrackProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF14182F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
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
                const SizedBox(height: 20),
                _buildSheetAction(
                  icon: Icons.timer_outlined,
                  title: '定时关闭',
                  subtitle: _sleepMinutes > 0 ? '$_sleepMinutes 分钟后暂停' : '未设置',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showSleepTimerSheet(this.context);
                  },
                ),
                _buildSheetAction(
                  icon: Icons.speed_rounded,
                  title: '播放速度',
                  subtitle: '${_playbackSpeed.toStringAsFixed(1)}x',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showSpeedSheet(this.context);
                  },
                ),
                _buildSheetAction(
                  icon: Icons.lyrics_outlined,
                  title: '歌词区域',
                  subtitle: _showLyrics ? '当前展开' : '当前收起',
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _showLyrics = !_showLyrics;
                    });
                  },
                ),
                _buildSheetAction(
                  icon: Icons.share_outlined,
                  title: '分享曲目信息',
                  subtitle: currentTrack == null ? '当前没有可分享曲目' : '分享标题和来源信息',
                  onTap: currentTrack == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _shareTrack(currentTrack);
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSleepTimerSheet(BuildContext context) {
    final control = ref.read(musicControlProvider.notifier);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF14182F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final options = [0, 15, 30, 45, 60, 90];

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
                const SizedBox(height: 20),
                const Text(
                  '定时关闭',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '设置播放时长后自动暂停',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: options.map((minutes) {
                    final isActive = _sleepMinutes == minutes;
                    final label = minutes == 0 ? '关闭' : '$minutes 分钟';

                    return InkWell(
                      onTap: () {
                        control.setSleepTimer(minutes);
                        setState(() {
                          _sleepMinutes = minutes;
                        });
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFFFEDD5)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? const Color(0xFFEA580C)
                                : Colors.white.withValues(alpha: 0.88),
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

  void _showSpeedSheet(BuildContext context) {
    final control = ref.read(musicControlProvider.notifier);
    var speed = _playbackSpeed;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF14182F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    const SizedBox(height: 20),
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
                      '调整音乐播放速度，不改变当前曲目队列',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.68),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${speed.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        activeTrackColor: const Color(0xFFFFD36F),
                        inactiveTrackColor:
                            Colors.white.withValues(alpha: 0.14),
                        thumbColor: Colors.white,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: speed,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        onChanged: (value) {
                          setModalState(() {
                            speed = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          await control.setSpeed(speed);
                          if (!mounted) return;
                          setState(() {
                            _playbackSpeed = speed;
                          });
                          navigator.pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD36F),
                          foregroundColor: const Color(0xFF6B3CE9),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('应用速度'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showQueueSheet(
    BuildContext context, {
    required List<MusicTrack> playlist,
    required int currentIndex,
    required ValueChanged<int> onSelect,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF14182F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                const SizedBox(height: 16),
                const Text(
                  '播放队列',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: playlist.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (context, index) {
                      final track = playlist[index];
                      final isCurrent = index == currentIndex;

                      return ListTile(
                        onTap: () => onSelect(index),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        leading: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0x33FFD36F)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? const Color(0xFFFFD36F)
                                  : Colors.white.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                        title: Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isCurrent
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                        subtitle: Text(
                          _buildSubtitle(track),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.56),
                          ),
                        ),
                        trailing: isCurrent
                            ? const Icon(
                                Icons.graphic_eq_rounded,
                                color: Color(0xFFFFD36F),
                              )
                            : null,
                      );
                    },
                  ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
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
          color: Colors.white.withValues(alpha: onTap == null ? 0.40 : 0.92),
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

  List<LyricsLine> _parseLyrics(MusicTrack? track) {
    final rawLyrics = track?.lyrics?.trim() ?? '';
    if (rawLyrics.isEmpty) {
      return const [];
    }
    return LyricsWidget.parseLrc(rawLyrics);
  }

  double _resolveProgress(MusicProgress progress) {
    if (_isDragging) {
      return _dragValue;
    }
    if (progress.duration.inMilliseconds <= 0) {
      return 0.0;
    }
    return progress.position.inMilliseconds / progress.duration.inMilliseconds;
  }

  String _buildSubtitle(MusicTrack? track) {
    if (track == null) return '暂无曲目信息';

    final parts = <String>[];
    if ((track.artist ?? '').trim().isNotEmpty) {
      parts.add(track.artist!.trim());
    }
    if ((track.album ?? '').trim().isNotEmpty) {
      parts.add(track.album!.trim());
    }

    return parts.isEmpty ? '未知艺术家 · 未知专辑' : parts.join(' · ');
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _shareTrack(MusicTrack? track) async {
    if (track == null) return;

    final parts = <String>[
      '正在播放：${track.title}',
      if ((track.artist ?? '').trim().isNotEmpty) '艺术家：${track.artist!.trim()}',
      if ((track.album ?? '').trim().isNotEmpty) '专辑：${track.album!.trim()}',
      if ((track.url ?? '').trim().isNotEmpty) '链接：${track.url!.trim()}',
    ];

    await SharePlus.instance.share(ShareParams(text: parts.join('\n')));
  }

  IconData _getPlayModeIcon(MusicPlayMode mode) {
    switch (mode) {
      case MusicPlayMode.sequence:
        return Icons.repeat_rounded;
      case MusicPlayMode.loop:
        return Icons.repeat_on_rounded;
      case MusicPlayMode.singleLoop:
        return Icons.repeat_one_on_rounded;
      case MusicPlayMode.shuffle:
        return Icons.shuffle_rounded;
    }
  }
}

class _GlowBubble extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBubble({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
