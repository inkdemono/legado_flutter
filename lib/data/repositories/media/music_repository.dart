import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../database/app_database.dart';
import '../../models/media/music_track.dart';
import '../../models/media/music_playlist.dart';

/// 音乐仓库
/// 提供音乐数据的增删改查操作
class MusicRepository {
  static final MusicRepository instance = MusicRepository._init();
  MusicRepository._init();

  // ==================== 曲目操作 ====================

  /// 获取所有音乐曲目
  Future<List<MusicTrack>> getAllTracks({
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    String orderClause = orderBy ?? 'added_at';
    String direction = ascending ? 'ASC' : 'DESC';
    String limitClause = limit != null ? 'LIMIT $limit' : '';
    String offsetClause = offset != null ? 'OFFSET $offset' : '';

    final List<Map<String, dynamic>> maps = await db.query(
      'music_tracks',
      orderBy: '$orderClause $direction $limitClause $offsetClause',
    );

    return maps.map((map) => MusicTrack.fromJson(map)).toList();
  }

  /// 根据 ID 获取曲目
  Future<MusicTrack?> getTrackById(String id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'music_tracks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return MusicTrack.fromJson(maps.first);
  }

  /// 搜索曲目
  Future<List<MusicTrack>> searchTracks(String query) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'music_tracks',
      where: 'title LIKE ? OR artist LIKE ? OR album LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );

    return maps.map((map) => MusicTrack.fromJson(map)).toList();
  }

  /// 插入曲目
  Future<void> insertTrack(MusicTrack track) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.insert(
      'music_tracks',
      track.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入曲目
  Future<void> insertTracks(List<MusicTrack> tracks) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    final batch = db.batch();
    for (final track in tracks) {
      batch.insert(
        'music_tracks',
        track.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 更新曲目
  Future<void> updateTrack(MusicTrack track) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.update(
      'music_tracks',
      track.toJson(),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  /// 删除曲目
  Future<void> deleteTrack(String id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.delete(
      'music_tracks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 更新播放次数
  Future<void> incrementPlayCount(String id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.rawUpdate('''
      UPDATE music_tracks
      SET play_count = play_count + 1,
          last_played_at = ?
      WHERE id = ?
    ''', [DateTime.now().millisecondsSinceEpoch, id]);
  }

  /// 获取最近播放
  Future<List<MusicTrack>> getRecentTracks({int limit = 50}) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'music_tracks',
      where: 'last_played_at IS NOT NULL',
      orderBy: 'last_played_at DESC',
      limit: limit,
    );

    return maps.map((map) => MusicTrack.fromJson(map)).toList();
  }

  /// 获取最常播放
  Future<List<MusicTrack>> getMostPlayedTracks({int limit = 50}) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'music_tracks',
      where: 'play_count > 0',
      orderBy: 'play_count DESC',
      limit: limit,
    );

    return maps.map((map) => MusicTrack.fromJson(map)).toList();
  }

  // ==================== 播放列表操作 ====================

  /// 获取所有播放列表
  Future<List<MusicPlaylist>> getAllPlaylists() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'music_playlists',
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) {
      // 解析 track_ids JSON
      final trackIdsJson = map['track_ids'] as String?;
      final trackIds = trackIdsJson != null
          ? List<String>.from(jsonDecode(trackIdsJson))
          : <String>[];
      return MusicPlaylist.fromJson({...map, 'trackIds': trackIds});
    }).toList();
  }

  /// 根据 ID 获取播放列表
  Future<MusicPlaylist?> getPlaylistById(String id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'music_playlists',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final trackIdsJson = map['track_ids'] as String?;
    final trackIds = trackIdsJson != null
        ? List<String>.from(jsonDecode(trackIdsJson))
        : <String>[];
    return MusicPlaylist.fromJson({...map, 'trackIds': trackIds});
  }

  /// 创建播放列表
  Future<void> createPlaylist(MusicPlaylist playlist) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.insert(
      'music_playlists',
      {
        ...playlist.toJson(),
        'track_ids': jsonEncode(playlist.trackIds),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新播放列表
  Future<void> updatePlaylist(MusicPlaylist playlist) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.update(
      'music_playlists',
      {
        ...playlist.toJson(),
        'track_ids': jsonEncode(playlist.trackIds),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  /// 删除播放列表
  Future<void> deletePlaylist(String id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    // 不允许删除系统播放列表
    final playlist = await getPlaylistById(id);
    if (playlist?.isSystem == true) return;

    await db.delete(
      'music_playlists',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 添加曲目到播放列表
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final playlist = await getPlaylistById(playlistId);
    if (playlist == null) return;

    if (!playlist.trackIds.contains(trackId)) {
      playlist.trackIds.add(trackId);
      await updatePlaylist(playlist);
    }
  }

  /// 从播放列表移除曲目
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    final playlist = await getPlaylistById(playlistId);
    if (playlist == null) return;

    playlist.trackIds.remove(trackId);
    await updatePlaylist(playlist);
  }

  /// 获取播放列表中的曲目
  Future<List<MusicTrack>> getPlaylistTracks(String playlistId) async {
    final playlist = await getPlaylistById(playlistId);
    if (playlist == null) return [];

    final tracks = <MusicTrack>[];
    for (final trackId in playlist.trackIds) {
      final track = await getTrackById(trackId);
      if (track != null) {
        tracks.add(track);
      }
    }
    return tracks;
  }

  // ==================== 统计操作 ====================

  /// 获取曲目总数
  Future<int> getTrackCount() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return 0;

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM music_tracks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取播放列表总数
  Future<int> getPlaylistCount() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return 0;

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM music_playlists');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取艺术家列表
  Future<List<String>> getArtists() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    final result = await db.rawQuery('''
      SELECT DISTINCT artist FROM music_tracks
      WHERE artist IS NOT NULL AND artist != ''
      ORDER BY artist
    ''');

    return result.map((row) => row['artist'] as String).toList();
  }

  /// 获取专辑列表
  Future<List<String>> getAlbums() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    final result = await db.rawQuery('''
      SELECT DISTINCT album FROM music_tracks
      WHERE album IS NOT NULL AND album != ''
      ORDER BY album
    ''');

    return result.map((row) => row['album'] as String).toList();
  }
}
