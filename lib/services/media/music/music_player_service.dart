import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../../core/base/base_service.dart';
import '../../../data/models/media/music_track.dart';
import '../../../utils/app_log.dart';

/// 播放模式
enum MusicPlayMode {
  sequence, // 顺序播放
  loop, // 列表循环
  singleLoop, // 单曲循环
  shuffle, // 随机播放
}

/// 播放状态
enum MusicPlayStatus {
  stopped,
  playing,
  paused,
  loading,
  error,
}

/// 音乐播放服务
/// 使用独立的 AudioPlayer 实例，与书籍朗读分离
class MusicPlayerService extends BaseService {
  static final MusicPlayerService instance = MusicPlayerService._init();
  MusicPlayerService._init();

  // 独立的音频播放器（与 AudioPlayService 分离）
  final AudioPlayer _player = AudioPlayer();

  // 当前播放列表
  List<MusicTrack> _playlist = [];

  // 当前播放索引
  int _currentIndex = -1;

  // 播放模式
  MusicPlayMode _playMode = MusicPlayMode.sequence;

  // 播放状态
  MusicPlayStatus _status = MusicPlayStatus.stopped;

  // 随机播放索引列表
  List<int> _shuffleIndices = [];

  // 定时器
  Timer? _sleepTimer;
  int _sleepMinutes = 0;

  // 随机数生成器
  final Random _random = Random();

  // ========== 状态通知器 ==========
  final ValueNotifier<MusicPlayStatus> statusNotifier =
      ValueNotifier(MusicPlayStatus.stopped);
  final ValueNotifier<int> currentIndexNotifier = ValueNotifier(-1);
  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<MusicPlayMode> playModeNotifier =
      ValueNotifier(MusicPlayMode.sequence);
  final ValueNotifier<List<MusicTrack>> playlistNotifier = ValueNotifier([]);
  final ValueNotifier<MusicTrack?> currentTrackNotifier = ValueNotifier(null);

  // ========== Getters ==========
  MusicPlayStatus get status => _status;
  MusicPlayMode get playMode => _playMode;
  int get currentIndex => _currentIndex;
  List<MusicTrack> get playlist => List.unmodifiable(_playlist);
  MusicTrack? get currentTrack => _currentIndex >= 0 &&
          _currentIndex < _playlist.length
      ? _playlist[_currentIndex]
      : null;
  int get sleepMinutes => _sleepMinutes;
  AudioPlayer get player => _player;

  /// 初始化
  @override
  Future<void> onInit() async {
    // 初始化音频会话
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: false,
    ));

    // 监听播放器状态
    _player.playerStateStream.listen(_onPlayerStateChanged);
    _player.positionStream.listen((pos) => positionNotifier.value = pos);
    _player.durationStream.listen((dur) {
      if (dur != null) durationNotifier.value = dur;
    });

    // 监听播放完成
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  /// 设置播放列表
  Future<void> setPlaylist(List<MusicTrack> tracks, {int startIndex = 0}) async {
    _playlist = List.from(tracks);
    _currentIndex = startIndex;
    _generateShuffleIndices();
    playlistNotifier.value = List.from(_playlist);

    if (_playlist.isNotEmpty &&
        startIndex >= 0 &&
        startIndex < _playlist.length) {
      await _loadTrack(startIndex);
    }
  }

  /// 添加到播放列表
  Future<void> addToPlaylist(MusicTrack track) async {
    _playlist.add(track);
    _generateShuffleIndices();
    playlistNotifier.value = List.from(_playlist);
  }

  /// 从播放列表移除
  Future<void> removeFromPlaylist(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    final wasPlayingCurrent = index == _currentIndex;
    _playlist.removeAt(index);
    _generateShuffleIndices();
    playlistNotifier.value = List.from(_playlist);

    if (wasPlayingCurrent) {
      if (_playlist.isEmpty) {
        await stop();
      } else if (_currentIndex < _playlist.length) {
        await _loadTrack(_currentIndex);
      } else {
        _currentIndex = _playlist.length - 1;
        await _loadTrack(_currentIndex);
      }
    } else if (index < _currentIndex) {
      _currentIndex--;
      currentIndexNotifier.value = _currentIndex;
    }
  }

  /// 播放指定曲目
  Future<void> playTrack(MusicTrack track) async {
    final index = _playlist.indexWhere((t) => t.id == track.id);
    if (index >= 0) {
      await _loadTrack(index);
      await play();
    } else {
      // 如果不在列表中，添加并播放
      _playlist.add(track);
      _currentIndex = _playlist.length - 1;
      _generateShuffleIndices();
      playlistNotifier.value = List.from(_playlist);
      await _loadTrack(_currentIndex);
      await play();
    }
  }

  /// 播放
  Future<void> play() async {
    if (currentTrack == null) return;

    if (_status == MusicPlayStatus.paused) {
      await _player.play();
      return;
    }

    if (_currentIndex >= 0) {
      await _loadTrack(_currentIndex);
      await _player.play();
    }
  }

  /// 暂停
  Future<void> pause() async {
    await _player.pause();
  }

  /// 停止
  Future<void> stop() async {
    await _player.stop();
    _currentIndex = -1;
    currentIndexNotifier.value = -1;
    currentTrackNotifier.value = null;
    _updateStatus(MusicPlayStatus.stopped);
    _cancelSleepTimer();
  }

  /// 切换播放/暂停
  Future<void> togglePlayPause() async {
    if (_status == MusicPlayStatus.playing) {
      await pause();
    } else {
      await play();
    }
  }

  /// 下一曲
  Future<void> next() async {
    if (_playlist.isEmpty) return;

    int nextIndex;
    switch (_playMode) {
      case MusicPlayMode.singleLoop:
        nextIndex = _currentIndex;
        break;
      case MusicPlayMode.shuffle:
        final currentShuffleIndex = _shuffleIndices.indexOf(_currentIndex);
        final nextShuffleIndex =
            (currentShuffleIndex + 1) % _shuffleIndices.length;
        nextIndex = _shuffleIndices[nextShuffleIndex];
        break;
      case MusicPlayMode.loop:
        nextIndex = (_currentIndex + 1) % _playlist.length;
        break;
      case MusicPlayMode.sequence:
        nextIndex = _currentIndex + 1;
        if (nextIndex >= _playlist.length) {
          await stop();
          return;
        }
        break;
    }

    await _loadTrack(nextIndex);
    if (_status == MusicPlayStatus.playing) {
      await _player.play();
    }
  }

  /// 上一曲
  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    // 如果播放超过3秒，重新播放当前曲目
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    int prevIndex;
    switch (_playMode) {
      case MusicPlayMode.singleLoop:
        prevIndex = _currentIndex;
        break;
      case MusicPlayMode.shuffle:
        final currentShuffleIndex = _shuffleIndices.indexOf(_currentIndex);
        final prevShuffleIndex = currentShuffleIndex > 0
            ? currentShuffleIndex - 1
            : _shuffleIndices.length - 1;
        prevIndex = _shuffleIndices[prevShuffleIndex];
        break;
      default:
        prevIndex = _currentIndex > 0 ? _currentIndex - 1 : 0;
    }

    await _loadTrack(prevIndex);
    if (_status == MusicPlayStatus.playing) {
      await _player.play();
    }
  }

  /// 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// 跳转到指定曲目
  Future<void> skipToIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      await _loadTrack(index);
      if (_status == MusicPlayStatus.playing) {
        await _player.play();
      }
    }
  }

  /// 设置播放速度
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// 切换播放模式
  void togglePlayMode() {
    switch (_playMode) {
      case MusicPlayMode.sequence:
        _playMode = MusicPlayMode.loop;
        break;
      case MusicPlayMode.loop:
        _playMode = MusicPlayMode.singleLoop;
        break;
      case MusicPlayMode.singleLoop:
        _playMode = MusicPlayMode.shuffle;
        break;
      case MusicPlayMode.shuffle:
        _playMode = MusicPlayMode.sequence;
        break;
    }
    playModeNotifier.value = _playMode;
  }

  /// 设置睡眠定时器
  void setSleepTimer(int minutes) {
    _sleepMinutes = minutes;
    _cancelSleepTimer();

    if (minutes > 0) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        pause();
        _sleepMinutes = 0;
      });
    }
  }

  /// 取消睡眠定时器
  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  /// 加载曲目
  Future<void> _loadTrack(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;
    currentIndexNotifier.value = index;
    currentTrackNotifier.value = _playlist[index];

    _updateStatus(MusicPlayStatus.loading);

    try {
      final track = _playlist[index];
      final source = track.isLocal
          ? AudioSource.file(track.filePath!)
          : AudioSource.uri(Uri.parse(track.url!));

      await _player.setAudioSource(source);
      _updateStatus(MusicPlayStatus.paused);
    } catch (e) {
      AppLog.instance.put('加载音乐失败: $e', error: e);
      _updateStatus(MusicPlayStatus.error);
    }
  }

  /// 生成随机索引
  void _generateShuffleIndices() {
    _shuffleIndices = List.generate(_playlist.length, (i) => i);
    _shuffleIndices.shuffle(_random);
  }

  /// 播放完成回调
  void _onTrackCompleted() {
    // 更新播放次数
    if (currentTrack != null) {
      currentTrack!.playCount++;
      currentTrack!.lastPlayedAt = DateTime.now();
    }

    // 根据播放模式处理
    if (_playMode == MusicPlayMode.singleLoop) {
      _loadTrack(_currentIndex).then((_) => play());
    } else {
      next();
    }
  }

  /// 播放器状态变化
  void _onPlayerStateChanged(PlayerState state) {
    if (state.playing) {
      _updateStatus(MusicPlayStatus.playing);
    } else if (state.processingState == ProcessingState.idle) {
      _updateStatus(MusicPlayStatus.stopped);
    } else {
      _updateStatus(MusicPlayStatus.paused);
    }
  }

  /// 更新状态
  void _updateStatus(MusicPlayStatus status) {
    _status = status;
    statusNotifier.value = status;
  }

  /// 释放资源
  @override
  Future<void> onDispose() async {
    _cancelSleepTimer();
    await _player.dispose();
  }
}
