import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'music_playlist.g.dart';

/// 播放列表模型
@JsonSerializable()
// ignore: must_be_immutable
class MusicPlaylist with EquatableMixin {
  /// 播放列表 ID
  final String id;

  /// 播放列表名称
  String name;

  /// 描述
  String? description;

  /// 封面路径
  String? coverPath;

  /// 曲目 ID 列表
  List<String> trackIds;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  DateTime updatedAt;

  /// 是否为系统默认（如"我喜欢"）
  final bool isSystem;

  MusicPlaylist({
    required this.id,
    required this.name,
    this.description,
    this.coverPath,
    List<String>? trackIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSystem = false,
  })  : trackIds = trackIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory MusicPlaylist.fromJson(Map<String, dynamic> json) =>
      _$MusicPlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$MusicPlaylistToJson(this);

  /// 曲目数量
  int get trackCount => trackIds.length;

  /// 添加曲目
  void addTrack(String trackId) {
    if (!trackIds.contains(trackId)) {
      trackIds.add(trackId);
      updatedAt = DateTime.now();
    }
  }

  /// 移除曲目
  void removeTrack(String trackId) {
    if (trackIds.remove(trackId)) {
      updatedAt = DateTime.now();
    }
  }

  /// 检查是否包含曲目
  bool containsTrack(String trackId) => trackIds.contains(trackId);

  /// 创建副本
  MusicPlaylist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverPath,
    List<String>? trackIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSystem,
  }) {
    return MusicPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      trackIds: trackIds ?? List.from(this.trackIds),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  String toString() {
    return 'MusicPlaylist(id: $id, name: $name, trackCount: $trackCount)';
  }

  @override
  List<Object?> get props => [id];
}

/// 预定义的系统播放列表
class SystemPlaylists {
  static const String favoritesId = 'favorites';
  static const String recentId = 'recent';
  static const String allTracksId = 'all_tracks';

  /// 创建"我喜欢"播放列表
  static MusicPlaylist createFavorites() => MusicPlaylist(
        id: favoritesId,
        name: '我喜欢',
        description: '收藏的歌曲',
        isSystem: true,
      );

  /// 创建"最近播放"播放列表
  static MusicPlaylist createRecent() => MusicPlaylist(
        id: recentId,
        name: '最近播放',
        description: '最近播放的歌曲',
        isSystem: true,
      );

  /// 创建"全部歌曲"播放列表
  static MusicPlaylist createAllTracks() => MusicPlaylist(
        id: allTracksId,
        name: '全部歌曲',
        description: '所有本地歌曲',
        isSystem: true,
      );
}
