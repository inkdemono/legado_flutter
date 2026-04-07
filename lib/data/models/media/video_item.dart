import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video_item.g.dart';

/// 视频项模型
@JsonSerializable()
// ignore: must_be_immutable
class VideoItem with EquatableMixin {
  /// 唯一标识符
  final String id;

  /// 标题
  final String title;

  /// 描述
  final String? description;

  /// 时长（毫秒）
  final int? duration;

  /// 文件路径（本地）
  final String? filePath;

  /// 网络 URL
  final String? url;

  /// 缩略图路径
  final String? thumbnailPath;

  /// 缩略图 URL
  final String? thumbnailUrl;

  /// 是否为本地文件
  final bool isLocal;

  /// 文件大小（字节）
  final int? fileSize;

  /// 视频宽度
  final int? width;

  /// 视频高度
  final int? height;

  /// 添加时间
  final DateTime addedAt;

  /// 观看进度（毫秒）
  int watchProgress;

  /// 最后观看时间
  DateTime? lastWatchedAt;

  /// 倍速设置
  double playbackSpeed;

  VideoItem({
    required this.id,
    required this.title,
    this.description,
    this.duration,
    this.filePath,
    this.url,
    this.thumbnailPath,
    this.thumbnailUrl,
    this.isLocal = false,
    this.fileSize,
    this.width,
    this.height,
    required this.addedAt,
    this.watchProgress = 0,
    this.lastWatchedAt,
    this.playbackSpeed = 1.0,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) =>
      _$VideoItemFromJson(json);

  Map<String, dynamic> toJson() => _$VideoItemToJson(this);

  /// 获取缩略图
  String? get thumbnail => thumbnailUrl ?? thumbnailPath;

  /// 获取播放源
  String get playSource => filePath ?? url ?? '';

  /// 获取宽高比
  double? get aspectRatio => (width != null && height != null && height != 0)
      ? width! / height!
      : null;

  /// 观看进度百分比 (0.0 - 1.0)
  double get watchProgressPercent {
    if (duration == null || duration == 0) return 0.0;
    return watchProgress / duration!;
  }

  /// 是否已观看
  bool get hasWatched => watchProgress > 0;

  /// 创建副本
  VideoItem copyWith({
    String? id,
    String? title,
    String? description,
    int? duration,
    String? filePath,
    String? url,
    String? thumbnailPath,
    String? thumbnailUrl,
    bool? isLocal,
    int? fileSize,
    int? width,
    int? height,
    DateTime? addedAt,
    int? watchProgress,
    DateTime? lastWatchedAt,
    double? playbackSpeed,
  }) {
    return VideoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      url: url ?? this.url,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isLocal: isLocal ?? this.isLocal,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      addedAt: addedAt ?? this.addedAt,
      watchProgress: watchProgress ?? this.watchProgress,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }

  /// 格式化时长显示
  String get formattedDuration {
    if (duration == null) return '--:--';
    final d = Duration(milliseconds: duration!);
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 格式化文件大小
  String get formattedFileSize {
    if (fileSize == null) return '';
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = fileSize!.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  @override
  String toString() {
    return 'VideoItem(id: $id, title: $title, duration: $duration)';
  }

  @override
  List<Object?> get props => [id];
}
