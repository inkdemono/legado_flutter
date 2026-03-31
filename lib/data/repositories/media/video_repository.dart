import 'package:sqflite/sqflite.dart';
import '../../database/app_database.dart';
import '../../models/media/video_item.dart';

/// 视频仓库
/// 提供视频数据的增删改查操作
class VideoRepository {
  static final VideoRepository instance = VideoRepository._init();
  VideoRepository._init();

  // ==================== 视频操作 ====================

  /// 获取所有视频
  Future<List<VideoItem>> getAllVideos({
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
      'video_items',
      orderBy: '$orderClause $direction $limitClause $offsetClause',
    );

    return maps.map((map) => VideoItem.fromJson(map)).toList();
  }

  /// 根据 ID 获取视频
  Future<VideoItem?> getVideoById(String id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'video_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return VideoItem.fromJson(maps.first);
  }

  /// 搜索视频
  Future<List<VideoItem>> searchVideos(String query) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'video_items',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return maps.map((map) => VideoItem.fromJson(map)).toList();
  }

  /// 插入视频
  Future<void> insertVideo(VideoItem video) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.insert(
      'video_items',
      video.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入视频
  Future<void> insertVideos(List<VideoItem> videos) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    final batch = db.batch();
    for (final video in videos) {
      batch.insert(
        'video_items',
        video.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 更新视频
  Future<void> updateVideo(VideoItem video) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.update(
      'video_items',
      video.toJson(),
      where: 'id = ?',
      whereArgs: [video.id],
    );
  }

  /// 删除视频
  Future<void> deleteVideo(String id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.delete(
      'video_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 更新观看进度
  Future<void> updateWatchProgress(String id, int progress) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.update(
      'video_items',
      {
        'watch_progress': progress,
        'last_watched_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 更新播放速度
  Future<void> updatePlaybackSpeed(String id, double speed) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.update(
      'video_items',
      {'playback_speed': speed},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取最近观看
  Future<List<VideoItem>> getRecentVideos({int limit = 50}) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'video_items',
      where: 'last_watched_at IS NOT NULL',
      orderBy: 'last_watched_at DESC',
      limit: limit,
    );

    return maps.map((map) => VideoItem.fromJson(map)).toList();
  }

  /// 获取观看历史
  Future<List<VideoItem>> getWatchHistory({int limit = 100}) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'video_items',
      where: 'watch_progress > 0',
      orderBy: 'last_watched_at DESC',
      limit: limit,
    );

    return maps.map((map) => VideoItem.fromJson(map)).toList();
  }

  /// 获取未看完的视频
  Future<List<VideoItem>> getUnfinishedVideos() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return [];

    // 获取观看进度小于 90% 的视频
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM video_items
      WHERE watch_progress > 0
        AND duration IS NOT NULL
        AND watch_progress < duration * 0.9
      ORDER BY last_watched_at DESC
    ''');

    return maps.map((map) => VideoItem.fromJson(map)).toList();
  }

  /// 清除观看进度
  Future<void> clearWatchProgress(String id) async {
    final db = await AppDatabase.instance.database;
    if (db == null) return;

    await db.update(
      'video_items',
      {
        'watch_progress': 0,
        'last_watched_at': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 统计操作 ====================

  /// 获取视频总数
  Future<int> getVideoCount() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return 0;

    final result = await db.rawQuery('SELECT COUNT(*) as count FROM video_items');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取本地视频数量
  Future<int> getLocalVideoCount() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return 0;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM video_items WHERE is_local = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取网络视频数量
  Future<int> getOnlineVideoCount() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return 0;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM video_items WHERE is_local = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取总文件大小
  Future<int> getTotalFileSize() async {
    final db = await AppDatabase.instance.database;
    if (db == null) return 0;

    final result = await db.rawQuery(
      'SELECT SUM(file_size) as total FROM video_items WHERE file_size IS NOT NULL',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
