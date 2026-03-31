import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../../data/models/media/music_track.dart';

/// 音乐音频处理器
/// 用于实现后台播放和通知栏媒体控制
class MusicAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player;

  // 播放列表
  final List<MediaItem> _playlist = [];
  int _currentIndex = -1;

  // 播放模式
  AudioRepeatMode _repeatMode = AudioRepeatMode.off;
  bool _shuffleMode = false;

  MusicAudioHandler(this._player) {
    // 监听播放状态
    _player.playbackEventStream.listen(_broadcastState);

    // 监听当前播放索引变化
    _player.currentIndexStream.listen((index) {
      if (index != null && index != _currentIndex) {
        _currentIndex = index;
        if (_playlist.isNotEmpty && index < _playlist.length) {
          mediaItem.add(_playlist[index]);
        }
      }
    });

    // 监听播放完成
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  /// 设置播放列表
  Future<void> setPlaylist(List<MusicTrack> tracks, {int initialIndex = 0}) async {
    _playlist.clear();
    _playlist.addAll(tracks.map(_trackToMediaItem));

    final audioSource = tracks.map((track) {
      if (track.filePath != null) {
        return AudioSource.file(track.filePath!);
      } else if (track.url != null) {
        return AudioSource.uri(Uri.parse(track.url!));
      }
      return null;
    }).whereType<AudioSource>().toList();

    if (audioSource.isEmpty) return;

    final playlist = ConcatenatingAudioSource(children: audioSource);
    await _player.setAudioSource(playlist, initialIndex: initialIndex);

    if (_shuffleMode) {
      await _player.setShuffleModeEnabled(true);
      await _player.shuffle();
    }

    _currentIndex = initialIndex;
    if (_playlist.isNotEmpty && initialIndex < _playlist.length) {
      mediaItem.add(_playlist[initialIndex]);
    }

    queue.add(_playlist);
  }

  /// 添加到播放列表
  Future<void> addToPlaylist(List<MusicTrack> tracks) async {
    final newItems = tracks.map(_trackToMediaItem).toList();
    _playlist.addAll(newItems);
    queue.add(_playlist);

    // 添加到播放器
    final audioSource = _player.audioSource;
    if (audioSource is ConcatenatingAudioSource) {
      for (final track in tracks) {
        if (track.filePath != null) {
          await audioSource.add(AudioSource.file(track.filePath!));
        } else if (track.url != null) {
          await audioSource.add(AudioSource.uri(Uri.parse(track.url!)));
        }
      }
    }
  }

  /// 播放指定曲目
  Future<void> playTrack(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _player.seek(Duration.zero, index: index);
      mediaItem.add(_playlist[index]);
      await play();
    }
  }

  /// 曲目播放完成
  void _onTrackCompleted() {
    switch (_repeatMode) {
      case AudioRepeatMode.one:
        // 单曲循环，重新播放
        _player.seek(Duration.zero);
        _player.play();
        break;
      case AudioRepeatMode.all:
        // 列表循环，自动播放下一曲
        if (_currentIndex < _playlist.length - 1) {
          skipToNext();
        } else {
          skipToQueueItem(0);
        }
        break;
      case AudioRepeatMode.off:
        // 不循环，播放下一曲
        if (_currentIndex < _playlist.length - 1) {
          skipToNext();
        }
        break;
    }
  }

  /// 将 MusicTrack 转换为 MediaItem
  MediaItem _trackToMediaItem(MusicTrack track) {
    return MediaItem(
      id: track.id,
      title: track.title,
      artist: track.artist,
      album: track.album,
      duration: track.duration != null
          ? Duration(milliseconds: track.duration!)
          : null,
      artUri: track.coverUrl != null ? Uri.parse(track.coverUrl!) : null,
      extras: {
        'filePath': track.filePath,
        'url': track.url,
        'isLocal': track.isLocal,
      },
    );
  }

  // ========== BaseAudioHandler 实现 ==========

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _player.seek(Duration.zero, index: index);
      mediaItem.add(_playlist[index]);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _playlist.length - 1) {
      await skipToQueueItem(_currentIndex + 1);
    } else if (_repeatMode == AudioRepeatMode.all) {
      await skipToQueueItem(0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      await skipToQueueItem(_currentIndex - 1);
    } else if (_repeatMode == AudioRepeatMode.all) {
      await skipToQueueItem(_playlist.length - 1);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _repeatMode = AudioRepeatMode.off;
        break;
      case AudioServiceRepeatMode.one:
        _repeatMode = AudioRepeatMode.one;
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        _repeatMode = AudioRepeatMode.all;
        break;
    }
    _broadcastState(null);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _shuffleMode = shuffleMode == AudioServiceShuffleMode.all;
    if (_shuffleMode) {
      await _player.setShuffleModeEnabled(true);
      await _player.shuffle();
    } else {
      await _player.setShuffleModeEnabled(false);
    }
    _broadcastState(null);
  }

  @override
  Future<void> fastForward() async {
    await _player.seek(_player.position + const Duration(seconds: 10));
  }

  @override
  Future<void> rewind() async {
    await _player.seek(_player.position - const Duration(seconds: 10));
  }

  /// 广播当前状态
  void _broadcastState(PlaybackEvent? event) {
    final controls = _getControls();

    playbackState.add(PlaybackState(
      controls: controls,
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.setRepeatMode,
        MediaAction.setShuffleMode,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _getProcessingState(),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
      repeatMode: _getRepeatMode(),
      shuffleMode: _shuffleMode
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    ));
  }

  /// 获取处理状态
  AudioProcessingState _getProcessingState() {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  /// 获取通知栏控制按钮
  List<MediaControl> _getControls() {
    return [
      MediaControl.skipToPrevious,
      if (_player.playing)
        MediaControl.pause
      else
        MediaControl.play,
      MediaControl.skipToNext,
    ];
  }

  /// 获取重复模式
  AudioServiceRepeatMode _getRepeatMode() {
    switch (_repeatMode) {
      case AudioRepeatMode.off:
        return AudioServiceRepeatMode.none;
      case AudioRepeatMode.one:
        return AudioServiceRepeatMode.one;
      case AudioRepeatMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  /// 获取当前播放索引
  int get currentIndex => _currentIndex;

  /// 获取当前播放模式
  AudioRepeatMode get repeatMode => _repeatMode;

  /// 获取是否随机播放
  bool get shuffleMode => _shuffleMode;

  /// 切换播放模式
  Future<void> toggleRepeatMode() async {
    switch (_repeatMode) {
      case AudioRepeatMode.off:
        await setRepeatMode(AudioServiceRepeatMode.all);
        break;
      case AudioRepeatMode.all:
        await setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case AudioRepeatMode.one:
        await setRepeatMode(AudioServiceRepeatMode.none);
        break;
    }
  }

  /// 切换随机模式
  Future<void> toggleShuffleMode() async {
    await setShuffleMode(
      _shuffleMode ? AudioServiceShuffleMode.none : AudioServiceShuffleMode.all,
    );
  }
}

/// 播放模式枚举
enum AudioRepeatMode {
  off,   // 不循环
  all,   // 列表循环
  one,   // 单曲循环
}
