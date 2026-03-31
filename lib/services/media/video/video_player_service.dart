import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../core/base/base_service.dart';
import '../../../data/models/media/video_item.dart';
import '../../../utils/app_log.dart';

/// 视频播放状态
enum VideoPlayStatus {
  stopped,
  playing,
  paused,
  buffering,
  error,
}

/// 视频播放服务
/// 使用 media_kit 作为底层播放器
class VideoPlayerService extends BaseService {
  static final VideoPlayerService instance = VideoPlayerService._init();
  VideoPlayerService._init();

  // 播放器实例
  Player? _player;
  VideoController? _controller;

  // 当前视频
  VideoItem? _currentVideo;

  // 播放状态
  VideoPlayStatus _status = VideoPlayStatus.stopped;

  // 播放速度
  double _speed = 1.0;

  // 音量 (0.0 - 1.0)
  double _volume = 1.0;

  // 是否全屏
  bool _isFullscreen = false;

  // 是否锁定控制层
  bool _isControlLocked = false;

  // ========== 状态通知器 ==========
  final ValueNotifier<VideoPlayStatus> statusNotifier =
      ValueNotifier(VideoPlayStatus.stopped);
  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<double> speedNotifier = ValueNotifier(1.0);
  final ValueNotifier<double> volumeNotifier = ValueNotifier(1.0);
  final ValueNotifier<VideoItem?> currentVideoNotifier = ValueNotifier(null);
  final ValueNotifier<bool> fullscreenNotifier = ValueNotifier(false);
  final ValueNotifier<bool> bufferingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> controlLockNotifier = ValueNotifier(false);

  // ========== Getters ==========
  VideoPlayStatus get status => _status;
  VideoItem? get currentVideo => _currentVideo;
  double get speed => _speed;
  double get volume => _volume;
  bool get isFullscreen => _isFullscreen;
  bool get isControlLocked => _isControlLocked;
  Player? get player => _player;
  VideoController? get controller => _controller;

  /// 初始化
  @override
  Future<void> onInit() async {
    // 初始化 media_kit
    MediaKit.ensureInitialized();

    // 创建播放器
    _player = Player();
    _controller = VideoController(_player!);

    // 监听播放器状态
    _player!.stream.playing.listen(_onPlayingChanged);
    _player!.stream.position.listen((pos) => positionNotifier.value = pos);
    _player!.stream.duration.listen((dur) => durationNotifier.value = dur);
    _player!.stream.volume.listen((vol) => volumeNotifier.value = vol / 100.0);
    _player!.stream.rate.listen((rate) => speedNotifier.value = rate);
    _player!.stream.buffering.listen(_onBufferingChanged);
    _player!.stream.error.listen(_onError);

    // 监听播放完成
    _player!.stream.completed.listen((completed) {
      if (completed) {
        _onVideoCompleted();
      }
    });
  }

  /// 加载视频
  Future<void> loadVideo(VideoItem video) async {
    _currentVideo = video;
    currentVideoNotifier.value = video;
    _updateStatus(VideoPlayStatus.buffering);

    try {
      final source = video.isLocal
          ? Media(video.filePath!)
          : Media(video.url!);

      await _player!.open(source);

      // 恢复播放进度
      if (video.watchProgress > 0) {
        await seek(Duration(milliseconds: video.watchProgress));
      }

      // 恢复倍速
      if (video.playbackSpeed != 1.0) {
        await setSpeed(video.playbackSpeed);
      }

      _updateStatus(VideoPlayStatus.paused);
    } catch (e) {
      AppLog.instance.put('加载视频失败: $e', error: e);
      _updateStatus(VideoPlayStatus.error);
    }
  }

  /// 播放
  Future<void> play() async {
    await _player?.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _player?.pause();
  }

  /// 停止
  Future<void> stop() async {
    await _player?.stop();
    _currentVideo = null;
    currentVideoNotifier.value = null;
    _updateStatus(VideoPlayStatus.stopped);
  }

  /// 切换播放/暂停
  Future<void> togglePlayPause() async {
    if (_status == VideoPlayStatus.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// 跳转
  Future<void> seek(Duration position) async {
    await _player?.seek(position);
  }

  /// 快进
  Future<void> forward(Duration duration) async {
    final current = positionNotifier.value;
    await seek(current + duration);
  }

  /// 快退
  Future<void> rewind(Duration duration) async {
    final current = positionNotifier.value;
    final target = current - duration;
    await seek(target < Duration.zero ? Duration.zero : target);
  }

  /// 设置倍速
  Future<void> setSpeed(double speed) async {
    await _player?.setRate(speed);
    _speed = speed;
    speedNotifier.value = speed;
  }

  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _player?.setVolume(volume * 100);
    _volume = volume;
    volumeNotifier.value = volume;
  }

  /// 切换全屏
  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    fullscreenNotifier.value = _isFullscreen;
  }

  /// 设置全屏
  void setFullscreen(bool fullscreen) {
    _isFullscreen = fullscreen;
    fullscreenNotifier.value = _isFullscreen;
  }

  /// 切换控制层锁定
  void toggleControlLock() {
    _isControlLocked = !_isControlLocked;
    controlLockNotifier.value = _isControlLocked;
  }

  /// 设置控制层锁定
  void setControlLock(bool locked) {
    _isControlLocked = locked;
    controlLockNotifier.value = _isControlLocked;
  }

  /// 获取当前进度 (0.0 - 1.0)
  double get progress {
    final duration = durationNotifier.value;
    if (duration.inMilliseconds <= 0) return 0.0;
    return positionNotifier.value.inMilliseconds / duration.inMilliseconds;
  }

  /// 播放器状态变化
  void _onPlayingChanged(bool playing) {
    if (playing) {
      _updateStatus(VideoPlayStatus.playing);
    } else if (_status == VideoPlayStatus.playing) {
      _updateStatus(VideoPlayStatus.paused);
    }
  }

  /// 缓冲状态变化
  void _onBufferingChanged(bool buffering) {
    bufferingNotifier.value = buffering;
    if (buffering && _status == VideoPlayStatus.playing) {
      _updateStatus(VideoPlayStatus.buffering);
    } else if (!buffering && _status == VideoPlayStatus.buffering) {
      _updateStatus(_player!.state.playing ? VideoPlayStatus.playing : VideoPlayStatus.paused);
    }
  }

  /// 错误处理
  void _onError(String? error) {
    if (error != null && error.isNotEmpty) {
      AppLog.instance.put('视频播放错误: $error', error: error);
      _updateStatus(VideoPlayStatus.error);
    }
  }

  /// 视频播放完成
  void _onVideoCompleted() {
    _updateStatus(VideoPlayStatus.stopped);
  }

  /// 更新状态
  void _updateStatus(VideoPlayStatus status) {
    _status = status;
    statusNotifier.value = status;
  }

  /// 释放资源
  @override
  Future<void> onDispose() async {
    await _player?.dispose();
    _player = null;
    _controller = null;
  }
}
