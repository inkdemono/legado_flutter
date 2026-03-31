import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media/video_item.dart';
import '../../services/media/video/video_player_service.dart';

/// 视频播放服务 Provider
final videoPlayerServiceProvider = Provider<VideoPlayerService>((ref) {
  return VideoPlayerService.instance;
});

/// 当前播放状态 Provider
final videoPlayStatusProvider =
    NotifierProvider<VideoPlayStatusNotifier, VideoPlayStatus>(() {
  return VideoPlayStatusNotifier();
});

class VideoPlayStatusNotifier extends Notifier<VideoPlayStatus> {
  @override
  VideoPlayStatus build() {
    final service = ref.watch(videoPlayerServiceProvider);
    service.statusNotifier.addListener(_onStatusChanged);
    ref.onDispose(() {
      service.statusNotifier.removeListener(_onStatusChanged);
    });
    return service.status;
  }

  void _onStatusChanged() {
    final service = ref.read(videoPlayerServiceProvider);
    state = service.status;
  }
}

/// 当前播放视频 Provider
final currentVideoProvider =
    NotifierProvider<CurrentVideoNotifier, VideoItem?>(() {
  return CurrentVideoNotifier();
});

class CurrentVideoNotifier extends Notifier<VideoItem?> {
  @override
  VideoItem? build() {
    final service = ref.watch(videoPlayerServiceProvider);
    service.currentVideoNotifier.addListener(_onVideoChanged);
    ref.onDispose(() {
      service.currentVideoNotifier.removeListener(_onVideoChanged);
    });
    return service.currentVideo;
  }

  void _onVideoChanged() {
    final service = ref.read(videoPlayerServiceProvider);
    state = service.currentVideo;
  }
}

/// 播放进度 Provider
final videoProgressProvider =
    NotifierProvider<VideoProgressNotifier, VideoProgress>(() {
  return VideoProgressNotifier();
});

class VideoProgressNotifier extends Notifier<VideoProgress> {
  @override
  VideoProgress build() {
    final service = ref.watch(videoPlayerServiceProvider);
    service.positionNotifier.addListener(_updateProgress);
    service.durationNotifier.addListener(_updateProgress);
    ref.onDispose(() {
      service.positionNotifier.removeListener(_updateProgress);
      service.durationNotifier.removeListener(_updateProgress);
    });
    return VideoProgress(
      position: service.positionNotifier.value,
      duration: service.durationNotifier.value,
    );
  }

  void _updateProgress() {
    final service = ref.read(videoPlayerServiceProvider);
    state = VideoProgress(
      position: service.positionNotifier.value,
      duration: service.durationNotifier.value,
    );
  }

  /// 跳转
  Future<void> seek(Duration position) async {
    final service = ref.read(videoPlayerServiceProvider);
    await service.seek(position);
  }
}

/// 播放进度数据类
class VideoProgress {
  final Duration position;
  final Duration duration;

  VideoProgress({required this.position, required this.duration});

  factory VideoProgress.zero() =>
      VideoProgress(position: Duration.zero, duration: Duration.zero);

  /// 进度百分比 (0.0 - 1.0)
  double get progress => duration.inMilliseconds > 0
      ? position.inMilliseconds / duration.inMilliseconds
      : 0.0;

  /// 格式化当前位置
  String get formattedPosition => _formatDuration(position);

  /// 格式化总时长
  String get formattedDuration => _formatDuration(duration);

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 播放速度 Provider
final videoSpeedProvider = NotifierProvider<VideoSpeedNotifier, double>(() {
  return VideoSpeedNotifier();
});

class VideoSpeedNotifier extends Notifier<double> {
  @override
  double build() {
    final service = ref.watch(videoPlayerServiceProvider);
    service.speedNotifier.addListener(_onSpeedChanged);
    ref.onDispose(() {
      service.speedNotifier.removeListener(_onSpeedChanged);
    });
    return service.speed;
  }

  void _onSpeedChanged() {
    final service = ref.read(videoPlayerServiceProvider);
    state = service.speed;
  }

  /// 设置播放速度
  Future<void> setSpeed(double speed) async {
    final service = ref.read(videoPlayerServiceProvider);
    await service.setSpeed(speed);
  }

  /// 循环切换播放速度
  Future<void> cycleSpeed() async {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    final currentIndex = speeds.indexOf(state);
    final nextIndex = (currentIndex + 1) % speeds.length;
    await setSpeed(speeds[nextIndex]);
  }
}

/// 音量 Provider
final videoVolumeProvider = NotifierProvider<VideoVolumeNotifier, double>(() {
  return VideoVolumeNotifier();
});

class VideoVolumeNotifier extends Notifier<double> {
  @override
  double build() {
    final service = ref.watch(videoPlayerServiceProvider);
    service.volumeNotifier.addListener(_onVolumeChanged);
    ref.onDispose(() {
      service.volumeNotifier.removeListener(_onVolumeChanged);
    });
    return service.volume;
  }

  void _onVolumeChanged() {
    final service = ref.read(videoPlayerServiceProvider);
    state = service.volume;
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    final service = ref.read(videoPlayerServiceProvider);
    await service.setVolume(volume.clamp(0.0, 1.0));
  }
}

/// 全屏状态 Provider
final videoFullscreenProvider = NotifierProvider<VideoFullscreenNotifier, bool>(() {
  return VideoFullscreenNotifier();
});

class VideoFullscreenNotifier extends Notifier<bool> {
  @override
  bool build() {
    final service = ref.watch(videoPlayerServiceProvider);
    service.fullscreenNotifier.addListener(_onFullscreenChanged);
    ref.onDispose(() {
      service.fullscreenNotifier.removeListener(_onFullscreenChanged);
    });
    return service.isFullscreen;
  }

  void _onFullscreenChanged() {
    final service = ref.read(videoPlayerServiceProvider);
    state = service.isFullscreen;
  }

  /// 切换全屏
  void toggle() {
    final service = ref.read(videoPlayerServiceProvider);
    service.toggleFullscreen();
  }

  /// 设置全屏
  void setFullscreen(bool fullscreen) {
    final service = ref.read(videoPlayerServiceProvider);
    service.setFullscreen(fullscreen);
  }
}

/// 缓冲状态 Provider
final videoBufferingProvider = Provider<bool>((ref) {
  final service = ref.watch(videoPlayerServiceProvider);
  return service.bufferingNotifier.value;
});

/// 控制层锁定状态 Provider
final videoControlLockProvider = NotifierProvider<VideoControlLockNotifier, bool>(() {
  return VideoControlLockNotifier();
});

class VideoControlLockNotifier extends Notifier<bool> {
  @override
  bool build() {
    final service = ref.watch(videoPlayerServiceProvider);
    service.controlLockNotifier.addListener(_onLockChanged);
    ref.onDispose(() {
      service.controlLockNotifier.removeListener(_onLockChanged);
    });
    return service.isControlLocked;
  }

  void _onLockChanged() {
    final service = ref.read(videoPlayerServiceProvider);
    state = service.isControlLocked;
  }

  void toggle() {
    final service = ref.read(videoPlayerServiceProvider);
    service.toggleControlLock();
  }
}

/// 播放控制 Provider
final videoControlProvider =
    NotifierProvider<VideoControlNotifier, void>(() {
  return VideoControlNotifier();
});

class VideoControlNotifier extends Notifier<void> {
  @override
  void build() {}

  VideoPlayerService get _service => ref.read(videoPlayerServiceProvider);

  /// 加载视频
  Future<void> loadVideo(VideoItem video) async {
    await _service.loadVideo(video);
  }

  /// 播放
  Future<void> play() async {
    await _service.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _service.pause();
  }

  /// 停止
  Future<void> stop() async {
    await _service.stop();
  }

  /// 切换播放/暂停
  Future<void> togglePlayPause() async {
    await _service.togglePlayPause();
  }

  /// 跳转
  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  /// 快进
  Future<void> forward([Duration duration = const Duration(seconds: 10)]) async {
    await _service.forward(duration);
  }

  /// 快退
  Future<void> rewind([Duration duration = const Duration(seconds: 10)]) async {
    await _service.rewind(duration);
  }

  /// 设置播放速度
  Future<void> setSpeed(double speed) async {
    await _service.setSpeed(speed);
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
  }

  /// 切换全屏
  void toggleFullscreen() {
    _service.toggleFullscreen();
  }

  /// 切换控制层锁定
  void toggleControlLock() {
    _service.toggleControlLock();
  }
}
