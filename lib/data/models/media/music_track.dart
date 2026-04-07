import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'music_track.g.dart';

/// 音乐曲目模型
@JsonSerializable()
// ignore: must_be_immutable
class MusicTrack with EquatableMixin {
  /// 唯一标识符
  final String id;

  /// 标题
  final String title;

  /// 艺术家
  final String? artist;

  /// 专辑
  final String? album;

  /// 时长（毫秒）
  final int? duration;

  /// 文件路径（本地）
  final String? filePath;

  /// 网络 URL
  final String? url;

  /// 封面路径
  final String? coverPath;

  /// 封面 URL
  final String? coverUrl;

  /// 歌词路径
  final String? lyricsPath;

  /// 歌词内容
  final String? lyrics;

  /// 是否为本地文件
  final bool isLocal;

  /// 文件大小（字节）
  final int? fileSize;

  /// 添加时间
  final DateTime addedAt;

  /// 播放次数
  int playCount;

  /// 最后播放时间
  DateTime? lastPlayedAt;

  /// 扩展信息 (JSON)
  Map<String, dynamic>? metadata;

  MusicTrack({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.duration,
    this.filePath,
    this.url,
    this.coverPath,
    this.coverUrl,
    this.lyricsPath,
    this.lyrics,
    this.isLocal = false,
    this.fileSize,
    required this.addedAt,
    this.playCount = 0,
    this.lastPlayedAt,
    this.metadata,
  });

  factory MusicTrack.fromJson(Map<String, dynamic> json) =>
      _$MusicTrackFromJson(json);

  Map<String, dynamic> toJson() => _$MusicTrackToJson(this);

  /// 获取显示用的封面
  String? get displayCover => coverUrl ?? coverPath;

  /// 获取播放源
  String get playSource => filePath ?? url ?? '';

  /// 创建副本
  MusicTrack copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? duration,
    String? filePath,
    String? url,
    String? coverPath,
    String? coverUrl,
    String? lyricsPath,
    String? lyrics,
    bool? isLocal,
    int? fileSize,
    DateTime? addedAt,
    int? playCount,
    DateTime? lastPlayedAt,
    Map<String, dynamic>? metadata,
  }) {
    return MusicTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      url: url ?? this.url,
      coverPath: coverPath ?? this.coverPath,
      coverUrl: coverUrl ?? this.coverUrl,
      lyricsPath: lyricsPath ?? this.lyricsPath,
      lyrics: lyrics ?? this.lyrics,
      isLocal: isLocal ?? this.isLocal,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt ?? this.addedAt,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 格式化时长显示
  String get formattedDuration {
    if (duration == null) return '--:--';
    final d = Duration(milliseconds: duration!);
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'MusicTrack(id: $id, title: $title, artist: $artist)';
  }

  @override
  List<Object?> get props => [id];
}
