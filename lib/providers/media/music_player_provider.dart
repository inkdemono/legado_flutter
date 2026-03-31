import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/media/music_track.dart';
import '../../services/media/music/music_player_service.dart';

/// 音乐播放服务 Provider
final musicPlayerServiceProvider = Provider<MusicPlayerService>((ref) {
  return MusicPlayerService.instance;
});

/// 当前播放状态 Provider
final musicPlayStatusProvider = NotifierProvider<MusicPlayStatusNotifier, MusicPlayStatus>(() {
  return MusicPlayStatusNotifier();
});

class MusicPlayStatusNotifier extends Notifier<MusicPlayStatus> {
  @override
  MusicPlayStatus build() {
    // 监听服务状态变化
    final service = ref.watch(musicPlayerServiceProvider);
    service.statusNotifier.addListener(_onStatusChanged);
    ref.onDispose(() {
      service.statusNotifier.removeListener(_onStatusChanged);
    });
    return service.status;
  }

  void _onStatusChanged() {
    final service = ref.read(musicPlayerServiceProvider);
    state = service.status;
  }
}

/// 当前播放曲目 Provider
final currentTrackProvider = NotifierProvider<CurrentTrackNotifier, MusicTrack?>(() {
  return CurrentTrackNotifier();
});

class CurrentTrackNotifier extends Notifier<MusicTrack?> {
  @override
  MusicTrack? build() {
    final service = ref.watch(musicPlayerServiceProvider);
    service.currentTrackNotifier.addListener(_onTrackChanged);
    ref.onDispose(() {
      service.currentTrackNotifier.removeListener(_onTrackChanged);
    });
    return service.currentTrack;
  }

  void _onTrackChanged() {
    final service = ref.read(musicPlayerServiceProvider);
    state = service.currentTrack;
  }
}

/// 播放列表 Provider
final musicPlaylistProvider = NotifierProvider<MusicPlaylistNotifier, List<MusicTrack>>(() {
  return MusicPlaylistNotifier();
});

class MusicPlaylistNotifier extends Notifier<List<MusicTrack>> {
  @override
  List<MusicTrack> build() {
    final service = ref.watch(musicPlayerServiceProvider);
    service.playlistNotifier.addListener(_onPlaylistChanged);
    ref.onDispose(() {
      service.playlistNotifier.removeListener(_onPlaylistChanged);
    });
    return service.playlist;
  }

  void _onPlaylistChanged() {
    final service = ref.read(musicPlayerServiceProvider);
    state = List.from(service.playlist);
  }

  /// 设置播放列表
  Future<void> setPlaylist(List<MusicTrack> tracks, {int startIndex = 0}) async {
    final service = ref.read(musicPlayerServiceProvider);
    await service.setPlaylist(tracks, startIndex: startIndex);
  }

  /// 添加曲目
  Future<void> addTrack(MusicTrack track) async {
    final service = ref.read(musicPlayerServiceProvider);
    await service.addToPlaylist(track);
  }

  /// 移除曲目
  Future<void> removeTrack(int index) async {
    final service = ref.read(musicPlayerServiceProvider);
    await service.removeFromPlaylist(index);
  }
}

/// 播放进度 Provider
final musicProgressProvider = NotifierProvider<MusicProgressNotifier, MusicProgress>(() {
  return MusicProgressNotifier();
});

class MusicProgressNotifier extends Notifier<MusicProgress> {
  @override
  MusicProgress build() {
    final service = ref.watch(musicPlayerServiceProvider);
    service.positionNotifier.addListener(_updateProgress);
    service.durationNotifier.addListener(_updateProgress);
    ref.onDispose(() {
      service.positionNotifier.removeListener(_updateProgress);
      service.durationNotifier.removeListener(_updateProgress);
    });
    return MusicProgress(
      position: service.positionNotifier.value,
      duration: service.durationNotifier.value,
    );
  }

  void _updateProgress() {
    final service = ref.read(musicPlayerServiceProvider);
    state = MusicProgress(
      position: service.positionNotifier.value,
      duration: service.durationNotifier.value,
    );
  }

  /// 跳转
  Future<void> seek(Duration position) async {
    final service = ref.read(musicPlayerServiceProvider);
    await service.seek(position);
  }
}

/// 播放进度数据类
class MusicProgress {
  final Duration position;
  final Duration duration;

  MusicProgress({required this.position, required this.duration});

  /// 进度百分比 (0.0 - 1.0)
  double get progress => duration.inMilliseconds > 0
      ? position.inMilliseconds / duration.inMilliseconds
      : 0.0;

  /// 格式化当前位置
  String get formattedPosition => _formatDuration(position);

  /// 格式化总时长
  String get formattedDuration => _formatDuration(duration);

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 播放模式 Provider
final musicPlayModeProvider = NotifierProvider<MusicPlayModeNotifier, MusicPlayMode>(() {
  return MusicPlayModeNotifier();
});

class MusicPlayModeNotifier extends Notifier<MusicPlayMode> {
  @override
  MusicPlayMode build() {
    final service = ref.watch(musicPlayerServiceProvider);
    service.playModeNotifier.addListener(_onModeChanged);
    ref.onDispose(() {
      service.playModeNotifier.removeListener(_onModeChanged);
    });
    return service.playMode;
  }

  void _onModeChanged() {
    final service = ref.read(musicPlayerServiceProvider);
    state = service.playMode;
  }

  /// 切换播放模式
  void toggle() {
    final service = ref.read(musicPlayerServiceProvider);
    service.togglePlayMode();
  }
}

/// 播放控制 Provider
final musicControlProvider = NotifierProvider<MusicControlNotifier, void>(() {
  return MusicControlNotifier();
});

class MusicControlNotifier extends Notifier<void> {
  @override
  void build() {}

  MusicPlayerService get _service => ref.read(musicPlayerServiceProvider);

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

  /// 下一曲
  Future<void> next() async {
    await _service.next();
  }

  /// 上一曲
  Future<void> previous() async {
    await _service.previous();
  }

  /// 跳转到指定曲目
  Future<void> skipToIndex(int index) async {
    await _service.skipToIndex(index);
  }

  /// 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  /// 设置播放速度
  Future<void> setSpeed(double speed) async {
    await _service.setSpeed(speed);
  }

  /// 设置睡眠定时器
  void setSleepTimer(int minutes) {
    _service.setSleepTimer(minutes);
  }
}

/// 当前播放索引 Provider
final currentTrackIndexProvider = Provider<int>((ref) {
  final service = ref.watch(musicPlayerServiceProvider);
  return service.currentIndex;
});
