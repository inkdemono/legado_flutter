part of 'book_service.dart';

// =============================================================================
// BookService 职责：书籍/章节数据库读写、模型与 DB 行双向映射、字数统计与本地路径维护。
// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）
// =============================================================================

  Future<void> saveBook(Book book) async {
    final db = await _db.database;
    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');
    await db.insert(
      'books',
      _bookToDbMap(book),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 创建书籍（保存书籍和章节）
  Future<Book> createBook(Book book) async {
    await saveBook(book);
    return book;
  }

  /// 创建章节
  Future<void> createChapter(BookChapter chapter) async {
    final db = await _db.database;
    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');
    await db.insert(
      'chapters',
      _chapterToDbMap(chapter),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 从书架删除书籍
  Future<void> deleteBook(String bookUrl) async {
    final db = await _db.database;
    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');
    await db.delete(
      'books',
      where: 'bookUrl = ?',
      whereArgs: [bookUrl],
    );
    // 章节会通过外键级联删除
  }

  /// 获取书架所有书籍
  Future<List<Book>> getBookshelfBooks() async {
    final db = await _db.database;
    if (db == null) return [];
    final result = await db.query(
      'books',
      orderBy: '"order" ASC, durChapterTime DESC',
    );
    return result.map((json) => _bookFromDbMap(json)).toList();
  }

  /// 获取最后阅读的书籍
  /// 参考项目：appDb.bookDao.lastReadBook
  Future<Book?> getLastReadBook() async {
    final db = await _db.database;
    if (db == null) return null;

    try {
      // 按最后阅读时间排序，获取最近阅读的书籍
      final result = await db.query(
        'books',
        orderBy: 'durChapterTime DESC',
        limit: 1,
      );

      if (result.isEmpty) return null;
      return _bookFromDbMap(result.first);
    } catch (e) {
      AppLog.instance.put('获取最后阅读书籍失败: $e', error: e);
      return null;
    }
  }

  /// 根据分组获取书籍
  Future<List<Book>> getBooksByGroup(int groupId) async {
    final db = await _db.database;
    if (db == null) return [];

    final result = await db.query(
      'books',
      where: '"group" = ?',
      whereArgs: [groupId],
      orderBy: '"order" ASC, durChapterTime DESC',
    );
    return result.map((json) => _bookFromDbMap(json)).toList();
  }

  /// 更新书籍分组
  Future<void> updateBookGroup(String bookUrl, int groupId) async {
    final db = await _db.database;
    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');
    await db.update(
      'books',
      {'group': groupId},
      where: 'bookUrl = ?',
      whereArgs: [bookUrl],
    );
  }

  /// 更新书籍阅读进度
  Future<void> updateReadingProgress(
    String bookUrl,
    int chapterIndex,
    int chapterPos,
    String? chapterTitle,
  ) async {
    final db = await _db.database;
    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');
    await db.update(
      'books',
      {
        'durChapterIndex': chapterIndex,
        'durChapterPos': chapterPos,
        'durChapterTitle': chapterTitle,
        'durChapterTime': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'bookUrl = ?',
      whereArgs: [bookUrl],
    );
  }

  /// 构建搜索URL
  String _buildSearchUrl(String searchUrl, String keyword) {
    return searchUrl.replaceAll('{{key}}', Uri.encodeComponent(keyword));
  }

  /// 保存章节列表
  Future<void> saveChapters(List<BookChapter> chapters) async {
    if (chapters.isEmpty) return;

    final db = await _db.database;
    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');

    // 先删除该书籍的所有章节，然后重新插入
    // 这样可以避免由于 index 不同导致的重复记录
    final bookUrl = chapters.first.bookUrl;
    await db.delete(
      'chapters',
      where: 'bookUrl = ?',
      whereArgs: [bookUrl],
    );

    final batch = db.batch();

    for (final chapter in chapters) {
      batch.insert(
        'chapters',
        _chapterToDbMap(chapter),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// 获取本地章节列表
  Future<List<BookChapter>> _getLocalChapters(String bookUrl) async {
    final db = await _db.database;
    if (db == null) return [];
    final result = await db.query(
      'chapters',
      where: 'bookUrl = ?',
      whereArgs: [bookUrl],
      orderBy: '"index" ASC',
    );
    return result.map((json) => _chapterFromDbMap(json)).toList();
  }

  /// 从数据库获取指定索引的章节（参考项目：bookChapterDao.getChapter）
  /// 确保返回的章节的 index 字段与请求的索引一致
  Future<BookChapter?> getChapterByIndex(String bookUrl, int index) async {
    final db = await _db.database;
    if (db == null) return null;
    final result = await db.query(
      'chapters',
      where: 'bookUrl = ? AND "index" = ?',
      whereArgs: [bookUrl, index],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return _chapterFromDbMap(result.first);
  }

  /// Book转数据库Map
  Map<String, dynamic> _bookToDbMap(Book book) {
    return {
      'bookUrl': book.bookUrl,
      'tocUrl': book.tocUrl,
      'origin': book.origin,
      'originName': book.originName,
      'name': book.name,
      'author': book.author,
      'kind': book.kind,
      'customTag': book.customTag,
      'coverUrl': book.coverUrl,
      'customCoverUrl': book.customCoverUrl,
      'intro': book.intro,
      'customIntro': book.customIntro,
      'charset': book.charset,
      'type': book.type,
      'group': book.group,
      'latestChapterTitle': book.latestChapterTitle,
      'latestChapterTime': book.latestChapterTime,
      'lastCheckTime': book.lastCheckTime,
      'lastCheckCount': book.lastCheckCount,
      'totalChapterNum': book.totalChapterNum,
      'durChapterTitle': book.durChapterTitle,
      'durChapterIndex': book.durChapterIndex,
      'durChapterPos': book.durChapterPos,
      'durChapterTime': book.durChapterTime,
      'wordCount': book.wordCount,
      'canUpdate': book.canUpdate ? 1 : 0,
      'order': book.order,
      'originOrder': book.originOrder,
      'variable': book.variable,
      'readConfig': book.readConfig != null
          ? jsonEncode(book.readConfig!.toJson())
          : null,
      'syncTime': book.syncTime,
    };
  }

  /// 数据库Map转Book
  Book _bookFromDbMap(Map<String, dynamic> map) {
    return Book(
      bookUrl: map['bookUrl'] ?? '',
      tocUrl: map['tocUrl'] ?? '',
      origin: map['origin'] ?? BookType.localTag,
      originName: map['originName'] ?? '',
      name: map['name'] ?? '',
      author: map['author'] ?? '',
      kind: map['kind'],
      customTag: map['customTag'],
      coverUrl: map['coverUrl'],
      customCoverUrl: map['customCoverUrl'],
      intro: map['intro'],
      customIntro: map['customIntro'],
      charset: map['charset'],
      type: map['type'] ?? BookType.text,
      group: map['group'] ?? 0,
      latestChapterTitle: map['latestChapterTitle'],
      latestChapterTime: map['latestChapterTime'] ?? 0,
      lastCheckTime: map['lastCheckTime'] ?? 0,
      lastCheckCount: map['lastCheckCount'] ?? 0,
      totalChapterNum: map['totalChapterNum'] ?? 0,
      durChapterTitle: map['durChapterTitle'],
      durChapterIndex: map['durChapterIndex'] ?? 0,
      durChapterPos: map['durChapterPos'] ?? 0,
      durChapterTime: map['durChapterTime'] ?? 0,
      wordCount: map['wordCount'],
      canUpdate: map['canUpdate'] == 1,
      order: map['order'] ?? 0,
      originOrder: map['originOrder'] ?? 0,
      variable: map['variable'],
      readConfig: map['readConfig'] != null
          ? ReadConfig.fromJson(jsonDecode(map['readConfig']))
          : null,
      syncTime: map['syncTime'] ?? 0,
    );
  }

  /// BookChapter转数据库Map
  Map<String, dynamic> _chapterToDbMap(BookChapter chapter) {
    return {
      'url': chapter.url,
      'bookUrl': chapter.bookUrl,
      'title': chapter.title,
      'isVolume': chapter.isVolume ? 1 : 0,
      'baseUrl': chapter.baseUrl,
      'index': chapter.index,
      'isVip': chapter.isVip ? 1 : 0,
      'isPay': chapter.isPay ? 1 : 0,
      'resourceUrl': chapter.resourceUrl,
      'tag': chapter.tag,
      'wordCount': chapter.wordCount,
      'start': chapter.start,
      'end': chapter.end,
      'startFragmentId': chapter.startFragmentId,
      'endFragmentId': chapter.endFragmentId,
      'variable': chapter.variable,
    };
  }

  /// 数据库Map转BookChapter
  BookChapter _chapterFromDbMap(Map<String, dynamic> map) {
    return BookChapter(
      url: map['url'] ?? '',
      title: map['title'] ?? '',
      isVolume: map['isVolume'] == 1,
      baseUrl: map['baseUrl'] ?? '',
      bookUrl: map['bookUrl'] ?? '',
      index: map['index'] ?? 0,
      isVip: map['isVip'] == 1,
      isPay: map['isPay'] == 1,
      resourceUrl: map['resourceUrl'],
      tag: map['tag'],
      wordCount: map['wordCount'],
      start: map['start'],
      end: map['end'],
      startFragmentId: map['startFragmentId'],
      endFragmentId: map['endFragmentId'],
      variable: map['variable'],
    );
  }

  /// 更新书籍排序
  Future<void> updateBookOrder(String bookUrl, int order) async {
    final db = await _db.database;
    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');
    await db.update(
      'books',
      {'order': order},
      where: 'bookUrl = ?',
      whereArgs: [bookUrl],
    );
  }

  /// 更新书籍信息
  Future<void> updateBook(Book book) async {
    final db = await _db.database;
    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');
    await db.update(
      'books',
      _bookToDbMap(book),
      where: 'bookUrl = ?',
      whereArgs: [book.bookUrl],
    );
  }

  /// 更新章节字数
  /// 参考项目：BookService.updateChapterWordCount
  Future<void> updateChapterWordCount(BookChapter chapter) async {
    final db = await _db.database;
    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');
    await db.update(
      'chapters',
      {'wordCount': chapter.wordCount},
      where: 'url = ? AND bookUrl = ?',
      whereArgs: [chapter.url, chapter.bookUrl],
    );
  }

  /// 从数据库获取已存在的章节字数
  /// 参考项目：BookChapterList.getWordCount（第272-286行）
  Future<void> getWordCount(List<BookChapter> chapters, Book book) async {
    // 参考项目：如果 AppConfig.tocCountWords 为 false，不处理
    // 这里暂时总是处理，如果需要可以从配置中读取
    try {
      final db = await _db.database;
      if (db == null) return;

      // 从数据库获取已存在的章节列表
      final existingChapters = await _getLocalChapters(book.bookUrl);
      if (existingChapters.isEmpty) return;

      // 创建章节文件名的映射（参考项目：associateBy）
      final wordCountMap = <String, String>{};
      for (final existingChapter in existingChapters) {
        final fileName = _getChapterFileName(existingChapter);
        if (existingChapter.wordCount != null &&
            existingChapter.wordCount!.isNotEmpty) {
          wordCountMap[fileName] = existingChapter.wordCount!;
        }
      }

      // 更新章节字数
      for (final chapter in chapters) {
        final fileName = _getChapterFileName(chapter);
        final wordCount = wordCountMap[fileName];
        if (wordCount != null) {
          chapter.wordCount = wordCount;
        }
      }
    } catch (e) {
      AppLog.instance.put('获取章节字数失败: $e', error: e);
    }
  }

  /// 获取章节文件名（用于字数匹配）
  /// 参考项目：BookChapter.getFileName
  String _getChapterFileName(BookChapter chapter) {
    // 参考项目：使用章节URL的MD5作为文件名
    // 这里简化处理，使用章节索引和URL的组合
    return '${chapter.index}_${chapter.url}';
  }

  /// 更新章节的localPath字段
  ///
  /// 将章节内容文件路径更新到数据库
  Future<void> _updateChapterLocalPath(
    String bookUrl,
    String chapterUrl,
    String localPath,
  ) async {
    try {
      final db = await _db.database;
      if (db == null) return;

      await db.update(
        'chapters',
        {'localPath': localPath},
        where: 'bookUrl = ? AND url = ?',
        whereArgs: [bookUrl, chapterUrl],
      );
    } catch (e) {
      AppLog.instance.put(
        '更新章节localPath失败: bookUrl=$bookUrl, url=$chapterUrl',
        error: e,
      );
    }
  }

  // ── Phase 3：辅助工具方法 ────────────────────────────────────────────────

  /// 将时长字符串解析为秒数（int）
  ///
  /// 支持三种格式：
  ///   - 纯秒数字符串：`"1800"` → 1800
  ///   - MM:SS 格式：`"30:00"` → 1800
  ///   - HH:MM:SS 格式：`"00:30:00"` → 1800
  ///
  /// 解析失败或输入为空时返回 null。
  static int? _parseDurationString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();

    // 尝试 HH:MM:SS 或 MM:SS 格式
    final parts = trimmed.split(':');
    if (parts.length == 2) {
      // MM:SS
      final minutes = int.tryParse(parts[0]);
      final seconds = int.tryParse(parts[1]);
      if (minutes != null && seconds != null) {
        return minutes * 60 + seconds;
      }
    } else if (parts.length == 3) {
      // HH:MM:SS
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      final seconds = int.tryParse(parts[2]);
      if (hours != null && minutes != null && seconds != null) {
        return hours * 3600 + minutes * 60 + seconds;
      }
    }

    // 尝试纯数字（秒数）
    return int.tryParse(trimmed);
  }
