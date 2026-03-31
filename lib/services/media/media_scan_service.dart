import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/base/base_service.dart';
import '../../data/models/media/music_track.dart';
import '../../data/models/media/video_item.dart';
import '../../data/repositories/media/music_repository.dart';
import '../../data/repositories/media/video_repository.dart';

/// 扫描进度信息
class ScanProgress {
  final int filesScanned;
  final int musicFound;
  final int videoFound;
  final String currentPath;
  final double progress;

  ScanProgress({
    required this.filesScanned,
    required this.musicFound,
    required this.videoFound,
    required this.currentPath,
    required this.progress,
  });

  ScanProgress copyWith({
    int? filesScanned,
    int? musicFound,
    int? videoFound,
    String? currentPath,
    double? progress,
  }) {
    return ScanProgress(
      filesScanned: filesScanned ?? this.filesScanned,
      musicFound: musicFound ?? this.musicFound,
      videoFound: videoFound ?? this.videoFound,
      currentPath: currentPath ?? this.currentPath,
      progress: progress ?? this.progress,
    );
  }
}

/// 媒体扫描结果
class MediaScanResult {
  final List<MusicTrack> musicTracks;
  final List<VideoItem> videos;
  final int filesScanned;
  final int failedCount;

  MediaScanResult({
    required this.musicTracks,
    required this.videos,
    this.filesScanned = 0,
    this.failedCount = 0,
  });

  int get totalFound => musicTracks.length + videos.length;
}

/// 媒体扫描服务
class MediaScanService extends BaseService {
  static final MediaScanService instance = MediaScanService._init();

  MediaScanService._init();

  // 支持的音频格式
  static const Set<String> audioExtensions = {
    '.mp3', '.m4a', '.aac', '.flac', '.wav', '.ogg', '.wma', '.ape'
  };

  // 支持的视频格式
  static const Set<String> videoExtensions = {
    '.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.3gp'
  };

  // 批处理大小
  static const int batchSize = 50;

  // 扫描状态
  final ValueNotifier<bool> isScanningNotifier = ValueNotifier(false);
  final ValueNotifier<ScanProgress> progressNotifier = ValueNotifier(
    ScanProgress(filesScanned: 0, musicFound: 0, videoFound: 0, currentPath: '', progress: 0),
  );

  // 取消标志
  bool _cancelRequested = false;
  Completer<void>? _scanCompleter;

  bool get isScanning => isScanningNotifier.value;

  /// 检查并请求存储权限
  Future<bool> requestStoragePermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      }
      final result = await Permission.storage.request();
      return result.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      }
      final result = await Permission.storage.request();
      return result.isGranted;
    }

    // 桌面平台不需要权限
    return true;
  }

  /// 扫描本地媒体文件
  Future<MediaScanResult> scanLocalMedia({
    bool scanMusic = true,
    bool scanVideo = true,
    List<String>? customPaths,
    bool parseMetadata = false,
    void Function(ScanProgress)? onProgress,
  }) async {
    if (isScanning) {
      throw Exception('正在扫描中，请稍候');
    }

    _cancelRequested = false;
    _scanCompleter = Completer<void>();
    isScanningNotifier.value = true;

    final musicTracks = <MusicTrack>[];
    final videos = <VideoItem>[];
    int filesScanned = 0;
    int failedCount = 0;

    try {
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('没有存储权限');
      }

      // 获取扫描路径
      final scanPaths = customPaths ?? await _getDefaultScanPaths();

      // 收集所有文件
      final allFiles = <File>[];
      for (final path in scanPaths) {
        if (_cancelRequested) break;

        try {
          final dir = Directory(path);
          if (await dir.exists()) {
            await _collectFiles(dir, allFiles);
          }
        } catch (e) {
          debugPrint('扫描目录失败: $path, 错误: $e');
        }
      }

      final totalFiles = allFiles.length;

      // 处理文件
      for (int i = 0; i < allFiles.length; i++) {
        if (_cancelRequested) break;

        final file = allFiles[i];
        final path = file.path;

        _updateProgress(
          progressNotifier.value.copyWith(
            filesScanned: filesScanned,
            musicFound: musicTracks.length,
            videoFound: videos.length,
            currentPath: path,
            progress: totalFiles > 0 ? i / totalFiles : 0,
          ),
        );
        onProgress?.call(progressNotifier.value);

        try {
          final extension = path.substring(path.lastIndexOf('.')).toLowerCase();

          // 处理音频文件
          if (scanMusic && audioExtensions.contains(extension)) {
            final track = _createMusicTrack(file);
            if (track != null) {
              musicTracks.add(track);
            }
          }

          // 处理视频文件
          if (scanVideo && videoExtensions.contains(extension)) {
            final video = _createVideoItem(file);
            if (video != null) {
              videos.add(video);
            }
          }

          filesScanned++;

          // 批量保存到数据库
          if (musicTracks.length >= batchSize) {
            await MusicRepository.instance.insertTracks(List.from(musicTracks));
            musicTracks.clear();
          }
          if (videos.length >= batchSize) {
            await VideoRepository.instance.insertVideos(List.from(videos));
            videos.clear();
          }
        } catch (e) {
          failedCount++;
          debugPrint('处理文件失败: $path, 错误: $e');
        }
      }

      // 保存剩余的数据
      if (musicTracks.isNotEmpty) {
        await MusicRepository.instance.insertTracks(musicTracks);
      }
      if (videos.isNotEmpty) {
        await VideoRepository.instance.insertVideos(videos);
      }

      _updateProgress(
        progressNotifier.value.copyWith(
          filesScanned: filesScanned,
          musicFound: musicTracks.length,
          videoFound: videos.length,
          currentPath: '',
          progress: 1.0,
        ),
      );

      return MediaScanResult(
        musicTracks: musicTracks,
        videos: videos,
        filesScanned: filesScanned,
        failedCount: failedCount,
      );
    } finally {
      isScanningNotifier.value = false;
      _scanCompleter?.complete();
    }
  }

  /// 收集目录中的所有文件
  Future<void> _collectFiles(Directory directory, List<File> files, {int depth = 0}) async {
    if (_cancelRequested || depth > 10) return;

    try {
      final entities = directory.listSync(recursive: false);

      for (final entity in entities) {
        if (_cancelRequested) break;

        if (entity is Directory) {
          // 跳过隐藏目录
          if (!entity.path.split('/').last.startsWith('.')) {
            await _collectFiles(entity, files, depth: depth + 1);
          }
        } else if (entity is File) {
          files.add(entity);
        }
      }
    } catch (e) {
      debugPrint('访问目录失败: ${directory.path}, 错误: $e');
    }
  }

  /// 更新进度
  void _updateProgress(ScanProgress progress) {
    progressNotifier.value = progress;
  }

  /// 创建音乐曲目对象
  MusicTrack? _createMusicTrack(File file) {
    try {
      final path = file.path;
      final fileName = path.split('/').last;
      final title = fileName.substring(0, fileName.lastIndexOf('.'));

      return MusicTrack(
        id: 'local_${path.hashCode}',
        title: title,
        filePath: path,
        isLocal: true,
        addedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('创建音乐曲目失败: ${file.path}, 错误: $e');
      return null;
    }
  }

  /// 创建视频项对象
  VideoItem? _createVideoItem(File file) {
    try {
      final path = file.path;
      final fileName = path.split('/').last;
      final title = fileName.substring(0, fileName.lastIndexOf('.'));

      return VideoItem(
        id: 'local_${path.hashCode}',
        title: title,
        filePath: path,
        isLocal: true,
        addedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('创建视频项失败: ${file.path}, 错误: $e');
      return null;
    }
  }

  /// 获取默认扫描路径
  Future<List<String>> _getDefaultScanPaths() async {
    final paths = <String>[];

    if (defaultTargetPlatform == TargetPlatform.android) {
      paths.addAll([
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Video',
      ]);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS 使用应用文档目录
    } else if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows) {
      final home = Platform.environment['HOME'] ??
                   Platform.environment['USERPROFILE'] ?? '';
      if (home.isNotEmpty) {
        paths.addAll([
          '$home/Music',
          '$home/Downloads',
          '$home/Movies',
          '$home/Videos',
        ]);
      }
    }

    return paths.where((p) => Directory(p).existsSync()).toList();
  }

  /// 停止扫描
  void stopScan() {
    _cancelRequested = true;
    isScanningNotifier.value = false;
  }

  /// 等待扫描完成
  Future<void> waitForScanComplete() async {
    if (_scanCompleter != null && !_scanCompleter!.isCompleted) {
      await _scanCompleter!.future;
    }
  }

  @override
  Future<void> dispose() async {
    stopScan();
    isScanningNotifier.dispose();
    progressNotifier.dispose();
    await super.dispose();
  }
}
