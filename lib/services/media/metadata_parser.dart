import 'dart:io';
import 'package:id3/id3.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/media/music_track.dart';
import '../../utils/app_log.dart';

/// 媒体元数据
class MediaMetadata {
  final String? title;
  final String? artist;
  final String? album;
  final int? duration;
  final int? trackNumber;
  final String? genre;
  final int? year;
  final List<int>? coverArt;

  MediaMetadata({
    this.title,
    this.artist,
    this.album,
    this.duration,
    this.trackNumber,
    this.genre,
    this.year,
    this.coverArt,
  });

  bool get hasCoverArt => coverArt != null && coverArt!.isNotEmpty;
}

/// MP3 元数据解析器
class Mp3MetadataParser {
  /// 解析 MP3 文件元数据
  static Future<MediaMetadata?> parse(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();
      return parseBytes(bytes);
    } catch (e) {
      debugPrint('解析 MP3 元数据失败: $filePath, 错误: $e');
      return null;
    }
  }

  /// 解析字节数据
  static MediaMetadata? parseBytes(List<int> bytes) {
    try {
      final mp3Instance = MP3Instance(bytes);
      final success = mp3Instance.parseTagsSync();

      if (!success) return null;

      final metadata = mp3Instance.getMetaTags();
      if (metadata == null) return null;

      // 处理封面图片
      List<int>? coverArt;
      final apic = metadata['APIC'];
      if (apic is Map && apic['base64'] != null) {
        try {
          // base64 解码已经在 APIC 中完成
          coverArt = metadata['APIC']['base64'];
        } catch (e) {
          AppLog.instance.putDebug('解析媒体封面失败', error: e);
        }
      }

      return MediaMetadata(
        title: _getStringValue(metadata['Title']),
        artist: _getStringValue(metadata['Artist']),
        album: _getStringValue(metadata['Album']),
        trackNumber: _parseTrackNumber(metadata['Track']),
        genre: _getStringValue(metadata['Genre']),
        year: _parseYear(metadata['Year']),
        coverArt: coverArt,
      );
    } catch (e) {
      debugPrint('解析 MP3 字节失败: $e');
      return null;
    }
  }

  /// 获取字符串值
  static String? _getStringValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isNotEmpty ? value : null;
    return value.toString();
  }

  /// 解析音轨号
  static int? _parseTrackNumber(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parts = value.split('/');
      return int.tryParse(parts.first);
    }
    return null;
  }

  /// 解析年份
  static int? _parseYear(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

/// 媒体元数据服务
class MediaMetadataService {
  static final MediaMetadataService instance = MediaMetadataService._init();

  MediaMetadataService._init();

  /// 解析音频文件元数据
  Future<MediaMetadata?> parseAudioMetadata(String filePath) async {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'mp3':
        return await Mp3MetadataParser.parse(filePath);
      case 'm4a':
      case 'aac':
      case 'flac':
      case 'wav':
      case 'ogg':
        // TODO: 支持更多格式的元数据解析
        return null;
      default:
        return null;
    }
  }

  /// 创建带元数据的音乐曲目
  Future<MusicTrack> createTrackWithMetadata({
    required String filePath,
    required String id,
  }) async {
    final fileName = filePath.split('/').last;
    final title = fileName.substring(0, fileName.lastIndexOf('.'));

    // 解析元数据
    final metadata = await parseAudioMetadata(filePath);

    return MusicTrack(
      id: id,
      title: metadata?.title ?? title,
      artist: metadata?.artist,
      album: metadata?.album,
      duration: metadata?.duration,
      filePath: filePath,
      isLocal: true,
      addedAt: DateTime.now(),
    );
  }

  /// 批量解析元数据
  Future<List<MusicTrack>> createTracksWithMetadata(
    List<String> filePaths,
  ) async {
    final tracks = <MusicTrack>[];

    for (int i = 0; i < filePaths.length; i++) {
      final filePath = filePaths[i];
      final id = 'local_${filePath.hashCode}_$i';

      try {
        final track = await createTrackWithMetadata(
          filePath: filePath,
          id: id,
        );
        tracks.add(track);
      } catch (e) {
        debugPrint('创建曲目失败: $filePath, 错误: $e');
      }
    }

    return tracks;
  }
}
