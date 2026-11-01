part of 'book_service.dart';

// =============================================================================
// BookService 职责：书架目录更新、按 URL/书名添加书籍、导入书单。
// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）
// =============================================================================

  Future<bool> updateChapterList(Book book) async {
    if (book.isLocal || !book.canUpdate) {
      return false;
    }

    try {
      final db = await _db.database;
      if (db == null) return false;

      // 先获取书籍信息（如果需要）
      final updatedBook = await getBookInfo(book);
      if (updatedBook == null) return false;

      // 使用 getChapterList 方法获取所有章节（支持分页）
      final chapters = await getChapterList(updatedBook);

      if (chapters.isEmpty) {
        return false;
      }

      // 更新书籍信息
      await saveBook(updatedBook.copyWith(
        totalChapterNum: chapters.length,
        lastCheckTime: DateTime.now().millisecondsSinceEpoch,
        latestChapterTitle: chapters.isNotEmpty ? chapters.last.title : null,
      ));

      return true;
    } catch (e) {
      AppLog.instance.put('更新目录失败', error: e);
      return false;
    }
  }

  /// 批量更新目录
  Future<Map<String, bool>> updateChapterLists(List<Book> books) async {
    final results = <String, bool>{};

    // 过滤出可以更新的网络书籍
    final booksToUpdate =
        books.where((book) => !book.isLocal && book.canUpdate).toList();

    for (final book in booksToUpdate) {
      try {
        final success = await updateChapterList(book);
        results[book.bookUrl] = success;
      } catch (e) {
        results[book.bookUrl] = false;
      }
    }

    return results;
  }

  /// 通过URL添加书籍
  Future<int> addBookByUrl(String bookUrls, {int? groupId}) async {
    int successCount = 0;
    final urls = bookUrls.split('\n');

    for (final url in urls) {
      final bookUrl = url.trim();
      if (bookUrl.isEmpty) continue;

      try {
        // 检查书籍是否已存在
        final existingBook = await getBookByUrl(bookUrl);
        if (existingBook != null) {
          successCount++;
          continue;
        }

        // 获取baseUrl
        final uri = Uri.tryParse(bookUrl);
        if (uri == null) continue;
        final baseUrl = '${uri.scheme}://${uri.host}';

        // 查找匹配的书源
        BookSource? source =
            await _bookSourceService.getBookSourceByUrl(baseUrl);

        // 如果没找到，尝试通过bookUrlPattern匹配
        if (source == null) {
          final allSources =
              await _bookSourceService.getAllBookSources(enabledOnly: true);
          for (final s in allSources) {
            if (s.bookUrlPattern != null && s.bookUrlPattern!.isNotEmpty) {
              try {
                final pattern = RegExp(s.bookUrlPattern!);
                if (pattern.hasMatch(bookUrl)) {
                  source = s;
                  break;
                }
              } catch (e) {
                // 正则表达式错误，跳过
                continue;
              }
            }
          }
        }

        if (source == null) continue;

        // 创建书籍对象
        final book = Book(
          bookUrl: bookUrl,
          origin: source.bookSourceUrl,
          originName: source.bookSourceName,
          canUpdate: true,
        );

        // 获取书籍信息
        final bookInfo = await getBookInfo(book);
        if (bookInfo == null) continue;

        // 检查是否已存在同名同作者的书籍
        final existingBookByName =
            await getBookByNameAndAuthor(bookInfo.name, bookInfo.author);
        if (existingBookByName != null) {
          // 如果已存在，更新章节列表
          final chapters = await getChapterList(bookInfo);
          if (chapters.isNotEmpty) {
            // 删除旧章节
            final db = await _db.database;
            if (db != null) {
              await db.delete(
                'chapters',
                where: 'bookUrl = ?',
                whereArgs: [existingBookByName.bookUrl],
              );
              // 保存新章节
              await saveChapters(chapters
                  .map((c) => c.copyWith(bookUrl: existingBookByName.bookUrl))
                  .toList());
            }
          }
          successCount++;
          continue;
        }

        // 获取章节列表
        final chapters = await getChapterList(bookInfo);
        if (chapters.isEmpty) continue;

        // 设置分组
        final finalBook =
            groupId != null ? bookInfo.copyWith(group: groupId) : bookInfo;

        // 保存书籍
        await createBook(finalBook);

        successCount++;
      } catch (e) {
        // 添加失败，继续下一个
        continue;
      }
    }

    return successCount;
  }

  /// 根据URL获取书籍
  Future<Book?> getBookByUrl(String bookUrl) async {
    final db = await _db.database;
    if (db == null) return null;
    final result = await db.query(
      'books',
      where: 'bookUrl = ?',
      whereArgs: [bookUrl],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return _bookFromDbMap(result.first);
  }

  /// 根据书名和作者获取书籍
  Future<Book?> getBookByNameAndAuthor(String name, String author) async {
    final db = await _db.database;
    if (db == null) return null;
    final result = await db.query(
      'books',
      where: 'name = ? AND author = ?',
      whereArgs: [name, author],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return _bookFromDbMap(result.first);
  }

  /// 通过书名和作者搜索并添加书籍（用于导入书单）
  Future<int> addBookByNameAndAuthor(String name, String author,
      {int? groupId}) async {
    if (name.isEmpty) return 0;

    // 检查是否已存在
    final existingBook = await getBookByNameAndAuthor(name, author);
    if (existingBook != null) {
      return 0; // 已存在，不重复添加
    }

    // 搜索书籍
    final searchResults = await searchBooks(name);

    // 精确匹配书名和作者
    Book? matchedBook;
    for (final book in searchResults) {
      if (book.name == name && book.author == author) {
        matchedBook = book;
        break;
      }
    }

    if (matchedBook == null) {
      return 0; // 未找到匹配的书籍
    }

    // 获取书籍详情
    final bookInfo = await getBookInfo(matchedBook);
    if (bookInfo == null) return 0;

    // 获取章节列表
    final chapters = await getChapterList(bookInfo);
    if (chapters.isEmpty) return 0;

    // 设置分组
    final finalBook =
        groupId != null ? bookInfo.copyWith(group: groupId) : bookInfo;

    // 保存书籍
    await createBook(finalBook);

    return 1;
  }

  /// 导入书单（从JSON）
  Future<int> importBooklist(String jsonText, {int? groupId}) async {
    try {
      // 解析JSON
      final jsonData = jsonDecode(jsonText);
      if (jsonData is! List) {
        throw Exception('书单格式错误：应为数组格式');
      }

      int successCount = 0;

      // 遍历书单
      for (final item in jsonData) {
        if (item is! Map) continue;

        final name = item['name']?.toString() ?? '';
        final author = item['author']?.toString() ?? '';

        if (name.isEmpty) continue;

        try {
          final count =
              await addBookByNameAndAuthor(name, author, groupId: groupId);
          successCount += count;
        } catch (e) {
          // 单个书籍添加失败，继续下一个
          continue;
        }
      }

      return successCount;
    } catch (e) {
      throw Exception('导入书单失败: $e');
    }
  }

  /// 获取章节正文
  /// 参考项目：支持分页获取（nextContentUrl），循环获取所有页面的内容
  /// [book] 可选参数，传入后会自动检查和保存文件缓存，避免重复网络请求
