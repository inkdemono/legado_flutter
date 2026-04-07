import 'dart:async';
import 'package:legado_flutter/providers/service_registry.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/base/base_service.dart';
import '../../data/models/book.dart';
import '../../data/models/book_chapter.dart';
import '../../utils/app_log.dart';
import '../notification_service.dart';

/// 播放模式
enum PlayMode {
  listEndStop, // 列表结束停止
  singleLoop, // 单曲循环
  random, // 随机播放
  listLoop, // 列表循环
}

/// 播放状态
enum PlayStatus {
  stopped,
  playing,
  paused,
  loading,
}

/// 音频播放服务
class AudioPlayService extends BaseService {
  static final AudioPlayService instance = AudioPlayService._init();
  AudioPlayService._init();

  final AudioPlayer _player = AudioPlayer();
  Book? _currentBook;
  List<BookChapter> _chapters = [];
  int _currentChapterIndex = 0;
  PlayMode _playMode = PlayMode.listEndStop;
  PlayStatus _status = PlayStatus.stopped;
  int _timerMinute = 0;
  Timer? _timer;
  static const int _notificationId = 109; // 音频播放通知ID

  // 回调
  final ValueNotifier<PlayStatus> statusNotifier =
      ValueNotifier(PlayStatus.stopped);
  final ValueNotifier<int> progressNotifier = ValueNotifier(0);
  final ValueNotifier<int> durationNotifier = ValueNotifier(0);
  final ValueNotifier<int> chapterIndexNotifier = ValueNotifier(0);
  final ValueNotifier<String?> chapterTitleNotifier = ValueNotifier(null);
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
  final ValueNotifier<PlayMode> playModeNotifier =
      ValueNotifier(PlayMode.listEndStop);

  Book? get currentBook => _currentBook;
  int get currentChapterIndex => _currentChapterIndex;
  PlayMode get playMode => _playMode;
  PlayStatus get status => _status;
  int get timerMinute => _timerMinute;
  List<BookChapter> get chapters => List.unmodifiable(_chapters);

  /// 初始化
  @override
  Future<void> init() async {
    // 监听播放状态
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.loading) {
        _updateStatus(PlayStatus.loading);
      } else if (state.playing) {
        _updateStatus(PlayStatus.playing);
      } else {
        _updateStatus(PlayStatus.paused);
      }
    });

    // 监听播放位置
    _player.positionStream.listen((position) {
      progressNotifier.value = position.inSeconds;
    });

    // 监听播放时长
    _player.durationStream.listen((duration) {
      if (duration != null) {
        durationNotifier.value = duration.inSeconds;
      }
    });

    // 监听播放完成
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onPlayCompleted();
      }
    });
  }

  /// 设置书籍
  Future<void> setBook(Book book) async {
    _currentBook = book;
    _currentChapterIndex = book.durChapterIndex;

    // 加载章节列表
    _chapters = await readService(AppServices.bookService).getChapterList(book);
    chapterIndexNotifier.value = _currentChapterIndex;

    if (_chapters.isNotEmpty && _currentChapterIndex < _chapters.length) {
      chapterTitleNotifier.value = _chapters[_currentChapterIndex].title;
    }
  }

  /// 播放
  Future<void> play() async {
    if (_currentBook == null || _chapters.isEmpty) {
      return;
    }

    if (_status == PlayStatus.playing) {
      return;
    }

    if (_status == PlayStatus.paused) {
      await _player.play();
      // 更新通知为播放状态
      await _updatePlayNotification();
      return;
    }

    await _loadAndPlayChapter(_currentChapterIndex);
  }

  /// 暂停
  Future<void> pause() async {
    await _player.pause();
    // 更新通知为暂停状态
    await _updatePauseNotification();
  }

  /// 停止
  Future<void> stop() async {
    await _player.stop();
    _updateStatus(PlayStatus.stopped);
    _cancelTimer();
    // 取消播放通知
    await readService(AppServices.notificationService)
        .cancelNotification(_notificationId);
  }

  /// 上一章
  Future<void> prevChapter() async {
    if (_currentChapterIndex > 0) {
      _currentChapterIndex--;
      await _loadAndPlayChapter(_currentChapterIndex);
    }
  }

  /// 下一章
  Future<void> nextChapter() async {
    switch (_playMode) {
      case PlayMode.listEndStop:
        if (_currentChapterIndex + 1 < _chapters.length) {
          _currentChapterIndex++;
          await _loadAndPlayChapter(_currentChapterIndex);
        } else {
          await stop();
        }
        break;
      case PlayMode.singleLoop:
        _currentChapterIndex = _currentChapterIndex; // 重新播放当前章节
        await _loadAndPlayChapter(_currentChapterIndex);
        break;
      case PlayMode.random:
        _currentChapterIndex =
            (DateTime.now().millisecondsSinceEpoch % _chapters.length);
        await _loadAndPlayChapter(_currentChapterIndex);
        break;
      case PlayMode.listLoop:
        _currentChapterIndex = (_currentChapterIndex + 1) % _chapters.length;
        await _loadAndPlayChapter(_currentChapterIndex);
        break;
    }
  }

  /// 跳转到指定章节
  Future<void> skipToChapter(int index) async {
    if (index >= 0 && index < _chapters.length) {
      _currentChapterIndex = index;
      await _loadAndPlayChapter(_currentChapterIndex);
    }
  }

  /// 设置播放位置
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /// 设置播放速度
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// 切换播放模式
  void changePlayMode() {
    switch (_playMode) {
      case PlayMode.listEndStop:
        _playMode = PlayMode.singleLoop;
        break;
      case PlayMode.singleLoop:
        _playMode = PlayMode.random;
        break;
      case PlayMode.random:
        _playMode = PlayMode.listLoop;
        break;
      case PlayMode.listLoop:
        _playMode = PlayMode.listEndStop;
        break;
    }
    playModeNotifier.value = _playMode;
  }

  /// 设置定时停止（分钟）
  void setTimer(int minute) {
    _timerMinute = minute;
    _cancelTimer();

    if (minute > 0) {
      _timer = Timer(Duration(minutes: minute), () {
        pause();
        _timerMinute = 0;
      });
    }
  }

  /// 取消定时器
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _timerMinute = 0;
  }

  /// 加载并播放章节
  Future<void> _loadAndPlayChapter(int index) async {
    if (index < 0 || index >= _chapters.length) {
      return;
    }

    _currentChapterIndex = index;
    chapterIndexNotifier.value = index;
    chapterTitleNotifier.value = _chapters[index].title;

    loadingNotifier.value = true;

    try {
      // 获取章节内容（这里需要从章节内容中提取音频URL）
      // 注意：实际实现中需要根据书源规则解析章节内容，提取音频URL
      final chapter = _chapters[index];
      final audioUrl = await _getAudioUrl(chapter);

      if (audioUrl != null && audioUrl.isNotEmpty) {
        // 创建音频源（支持自定义请求头）
        final audioSource = await _createAudioSource(audioUrl);
        await _player.setAudioSource(audioSource);
        await _player.play();
        // 更新播放通知
        await _updatePlayNotification();
      } else {
        loadingNotifier.value = false;
      }
    } catch (e) {
      AppLog.instance
          .put('AudioPlayService._loadAndPlayChapter error: $e', error: e);
      loadingNotifier.value = false;
    }
  }

  /// 创建音频源（支持自定义请求头）
  /// 参考项目：ExoPlayerHelper.createMediaItem
  ///
  /// 注意：just_audio 的 AudioSource.uri 不支持直接设置自定义请求头
  /// 如果需要自定义请求头，可能需要：
  /// 1. 使用平台通道调用原生代码
  /// 2. 或者先下载音频文件到本地，然后播放本地文件
  /// 当前实现：使用简单的 URL（如果书源需要自定义请求头，可能需要其他方案）
  /// TODO: 实现自定义请求头支持（可能需要使用平台通道或下载后播放）
  Future<AudioSource> _createAudioSource(String url) async {
    try {
      // 获取书源的请求头（用于日志记录）
      Map<String, String> headers = {};

      if (_currentBook != null) {
        final bookSourceService = readService(AppServices.bookSourceService);
        final source =
            await bookSourceService.getBookSourceByUrl(_currentBook!.origin);

        if (source != null && source.header != null) {
          // 解析 header JSON
          try {
            final headerStr = source.header!;
            if (headerStr.isNotEmpty) {
              final decoded = jsonDecode(headerStr) as Map<String, dynamic>;
              headers =
                  decoded.map((key, value) => MapEntry(key, value.toString()));
              if (headers.isNotEmpty) {
                AppLog.instance.put(
                    'AudioPlayService: 检测到自定义请求头，但 just_audio 暂不支持，URL: $url');
              }
            }
          } catch (e) {
            AppLog.instance
                .put('AudioPlayService._createAudioSource: 解析 header 失败: $e');
          }
        }
      }

      // 使用简单的 URL（just_audio 暂不支持自定义请求头）
      return AudioSource.uri(Uri.parse(url));
    } catch (e) {
      AppLog.instance
          .put('AudioPlayService._createAudioSource error: $e', error: e);
      // 如果创建失败，回退到简单的 URL
      return AudioSource.uri(Uri.parse(url));
    }
  }

  /// 获取音频URL（从章节内容中提取）
  ///
  /// 优先级顺序：
  ///   1. chapter.resourceUrl —— 书源规则解析 / sniffing 已缓存的结果
  ///   2. chapter.url 本身是音频直链（以常见音频扩展名结尾）
  ///   3. 调用 getChapterContent → RuleParser._parseAudioContent 解析书源规则：
  ///        3a. [ContentRule.audioUrl] 规则（Phase 2 新增，书源作者明确指定）
  ///        3b. [ContentRule.content] + [ContentRule.sourceRegex] 嗅探（兼容旧书源）
  ///      解析结果由 book_service._getChapterContentInternal 写入 chapter.resourceUrl
  ///   4. content 本身是 http(s) URL（直接返回型书源）
  ///   5. 从 content 文本中正则兜底提取 http(s) 音频 URL
  Future<String?> _getAudioUrl(BookChapter chapter) async {
    if (_currentBook == null) return null;

    // ── 优先级 1：已有嗅探/解析结果，直接使用 ──────────────────────────────
    if (chapter.resourceUrl != null && chapter.resourceUrl!.isNotEmpty) {
      AppLog.instance.put('音频URL: 使用已缓存的 resourceUrl → ${chapter.resourceUrl}');
      return chapter.resourceUrl;
    }

    // ── 优先级 2：章节URL本身是音频直链 ────────────────────────────────────
    if (_isDirectAudioUrl(chapter.url)) {
      AppLog.instance.put('音频URL: 章节URL为直链 → ${chapter.url}');
      return chapter.url;
    }

    // ── 优先级 3/4：通过书源规则解析获取 ───────────────────────────────────
    try {
      final source = await readService(AppServices.bookSourceService)
          .getBookSourceByUrl(_currentBook!.origin);
      if (source == null) return null;

      final content =
          await readService(AppServices.bookService).getChapterContent(
        chapter,
        source,
        bookName: _currentBook!.name,
        bookOrigin: _currentBook!.origin,
        book: _currentBook,
      );

      // 优先级 3：getChapterContent 对 bookSourceType=1 的书源已将
      // sourceRegex 嗅探结果写入 chapter.resourceUrl。
      if (chapter.resourceUrl != null && chapter.resourceUrl!.isNotEmpty) {
        AppLog.instance
            .put('音频URL: 规则解析后从 resourceUrl 获取 → ${chapter.resourceUrl}');
        return chapter.resourceUrl;
      }

      // 优先级 3b：content 本身就是以 http(s) 开头的 URL（部分书源直接
      // 在 content 规则里返回音频地址，不走 sourceRegex 嗅探）。
      if (content != null &&
          content.isNotEmpty &&
          (content.startsWith('http://') || content.startsWith('https://')) &&
          !content.contains('\n')) {
        AppLog.instance.put('音频URL: content 即为URL → $content');
        chapter.resourceUrl = content;
        return content;
      }

      // 优先级 4：从 content 中用正则兜底提取第一个音频/流媒体 URL
      if (content != null && content.isNotEmpty) {
        final match = RegExp(
          r"""https?://[^\s<>"']+\.(mp3|m4a|wav|ogg|aac|flac|opus|m3u8|mpd)(\?[^\s<>"']*)?""",
          caseSensitive: false,
        ).firstMatch(content);
        if (match != null) {
          final url = match.group(0)!;
          AppLog.instance.put('音频URL: 从内容中正则提取 → $url');
          chapter.resourceUrl = url;
          return url;
        }
      }
    } catch (e) {
      AppLog.instance.put('提取音频URL失败: ${chapter.title}', error: e);
    }

    AppLog.instance.put('音频URL: 未能提取到有效URL (章节: ${chapter.title})');
    return null;
  }

  /// 判断 URL 是否为可直接播放的音频/流媒体链接
  ///
  /// 支持的格式：
  ///   - 常规音频文件：.mp3 .m4a .wav .ogg .aac .flac .opus
  ///   - HLS 流媒体：.m3u8（just_audio 原生支持 HLS，无需额外处理）
  ///   - DASH 流媒体：.mpd（media_kit 支持，just_audio 不支持，仅供识别）
  bool _isDirectAudioUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }
    // 去掉查询参数后检查扩展名
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    const audioExts = [
      // 常规音频文件
      '.mp3',
      '.m4a',
      '.wav',
      '.ogg',
      '.aac',
      '.flac',
      '.opus',
      // HLS 流媒体（just_audio 原生支持）
      '.m3u8',
      // DASH 流媒体（media_kit 支持）
      '.mpd',
    ];
    // 部分 HLS 流的 URL path 不含扩展名，但 query 中含 .m3u8 标识
    if (path.endsWith('.m3u8') ||
        url.toLowerCase().contains('.m3u8') ||
        url.toLowerCase().contains('playlist.m3u8') ||
        url.toLowerCase().contains('index.m3u8')) {
      return true;
    }
    return audioExts.any((ext) => path.endsWith(ext));
  }

  /// 播放完成回调
  void _onPlayCompleted() {
    // 根据播放模式决定下一步操作
    if (_playMode == PlayMode.singleLoop) {
      // 单曲循环：重新播放当前章节
      _loadAndPlayChapter(_currentChapterIndex);
    } else {
      // 其他模式：播放下一章
      nextChapter();
    }
  }

  /// 更新状态
  void _updateStatus(PlayStatus status) {
    _status = status;
    statusNotifier.value = status;
  }

  /// 更新播放通知
  Future<void> _updatePlayNotification() async {
    if (_currentBook == null) return;

    final chapterTitle =
        _chapters.isNotEmpty && _currentChapterIndex < _chapters.length
            ? _chapters[_currentChapterIndex].title
            : '未知章节';

    await readService(AppServices.notificationService).showNotification(
      id: _notificationId,
      title: _currentBook!.name,
      content: chapterTitle,
      isOngoing: true,
      channelId: NotificationService.channelIdAudioPlay,
      payload: 'audio_play:',
    );
  }

  /// 更新暂停通知
  Future<void> _updatePauseNotification() async {
    if (_currentBook == null) return;

    final chapterTitle =
        _chapters.isNotEmpty && _currentChapterIndex < _chapters.length
            ? _chapters[_currentChapterIndex].title
            : '未知章节';

    await readService(AppServices.notificationService).showNotification(
      id: _notificationId,
      title: _currentBook!.name,
      content: '$chapterTitle (已暂停)',
      isOngoing: true,
      channelId: NotificationService.channelIdAudioPlay,
      payload: 'audio_play:',
    );
  }

  /// 释放资源
  @override
  Future<void> dispose() async {
    _cancelTimer();
    await readService(AppServices.notificationService)
        .cancelNotification(_notificationId);
    await _player.dispose();
  }
}
