# book_service_storage.dart 逐行注释

> 源文件：`lib/services/book/book_service_storage.dart`（共 454 行）
>
> 本文件由 `scripts/gen_line_annotations.py` 自动生成，对源文件每一行给出独立说明。
> 说明优先采用源码自带的中文注释；无注释的行依据 Dart 语法特征自动生成解释。

| 行号 | 源代码 | 说明 |
| ---: | --- | --- |
| 1 | `part of 'book_service.dart';` | 声明本文件是 book_service.dart 库的一部分(part)，与其共享同一命名空间 |
| 2 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 4 | `// BookService 职责：书籍/章节数据库读写、模型与 DB 行双向映射、字数统计与本地路径维护。` | 注释说明：BookService 职责：书籍/章节数据库读写、模型与 DB 行双向映射、字数统计与本地路径维护。 |
| 5 | `// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）` | 注释说明：（part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号） |
| 6 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 7 | `&nbsp;` | 空行，分隔逻辑段落 |
| 8 | `  Future<void> saveBook(Book book) async {` | 定义方法 saveBook：返回 Future<void>；位置参数 1 个；含命名参数；参数名: book（异步）。语义：保存 书籍 |
| 9 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 10 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 if：db 等于 null；成立则抛出异常 Exception('数据库不可用（Web平台不支持SQLite）'); |
| 11 | `    await db.insert(` | 调用 db.insert(...)（等待异步完成） → 插入 |
| 12 | `      'books',` | 以字符串 'books' 起始的表达式：, |
| 13 | `      _bookToDbMap(book),` | 调用 _bookToDbMap(...)：_bookToDbMap(book),（书籍 To 数据库 映射） |
| 14 | `      conflictAlgorithm: ConflictAlgorithm.replace,` | 命名实参 conflictAlgorithm: ConflictAlgorithm.replace（conflict Algorithm） |
| 15 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 16 | `  }` | 闭合大括号，结束当前代码块 |
| 17 | `&nbsp;` | 空行，分隔逻辑段落 |
| 18 | `  /// 创建书籍（保存书籍和章节）` | 文档注释：说明其后代码的用途 |
| 19 | `  Future<Book> createBook(Book book) async {` | 【承接上方文档】创建书籍（保存书籍和章节） → 定义方法 createBook：返回 Future<Book>；位置参数 1 个；含命名参数；参数名: book（异步）。语义：create 书籍 |
| 20 | `    await saveBook(book);` | 调用 saveBook(...)（等待异步完成） → 保存 书籍 |
| 21 | `    return book;` | 返回 book |
| 22 | `  }` | 闭合大括号，结束当前代码块 |
| 23 | `&nbsp;` | 空行，分隔逻辑段落 |
| 24 | `  /// 创建章节` | 文档注释：说明其后代码的用途 |
| 25 | `  Future<void> createChapter(BookChapter chapter) async {` | 【承接上方文档】创建章节 → 定义方法 createChapter：返回 Future<void>；位置参数 1 个；含命名参数；参数名: chapter（异步）。语义：create 章节 |
| 26 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 27 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 if：db 等于 null；成立则抛出异常 Exception('数据库不可用（Web平台不支持SQLite）'); |
| 28 | `    await db.insert(` | 调用 db.insert(...)（等待异步完成） → 插入 |
| 29 | `      'chapters',` | 以字符串 'chapters' 起始的表达式：, |
| 30 | `      _chapterToDbMap(chapter),` | 调用 _chapterToDbMap(...)：_chapterToDbMap(chapter),（章节 To 数据库 映射） |
| 31 | `      conflictAlgorithm: ConflictAlgorithm.replace,` | 命名实参 conflictAlgorithm: ConflictAlgorithm.replace（conflict Algorithm） |
| 32 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 33 | `  }` | 闭合大括号，结束当前代码块 |
| 34 | `&nbsp;` | 空行，分隔逻辑段落 |
| 35 | `  /// 从书架删除书籍` | 文档注释：说明其后代码的用途 |
| 36 | `  Future<void> deleteBook(String bookUrl) async {` | 【承接上方文档】从书架删除书籍 → 定义方法 deleteBook：返回 Future<void>；位置参数 1 个；含命名参数；参数名: bookUrl（异步）。语义：删除 书籍 |
| 37 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 38 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 if：db 等于 null；成立则抛出异常 Exception('数据库不可用（Web平台不支持SQLite）'); |
| 39 | `    await db.delete(` | 调用 db.delete(...)（等待异步完成） → 删除 |
| 40 | `      'books',` | 以字符串 'books' 起始的表达式：, |
| 41 | `      where: 'bookUrl = ?',` | 命名实参 where: 'bookUrl = ?' |
| 42 | `      whereArgs: [bookUrl],` | 命名实参 whereArgs: [bookUrl]（where Args） |
| 43 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 44 | `    // 章节会通过外键级联删除` | 注释说明：章节会通过外键级联删除 |
| 45 | `  }` | 闭合大括号，结束当前代码块 |
| 46 | `&nbsp;` | 空行，分隔逻辑段落 |
| 47 | `  /// 获取书架所有书籍` | 文档注释：说明其后代码的用途 |
| 48 | `  Future<List<Book>> getBookshelfBooks() async {` | 【承接上方文档】获取书架所有书籍 → 定义方法 getBookshelfBooks：返回 Future<List<Book>>；位置参数 1 个；含命名参数（异步）。语义：获取 Bookshelf Books |
| 49 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 50 | `    if (db == null) return [];` | 条件判断 if：db 等于 null) return []; |
| 51 | `    final result = await db.query(` | 声明不可重新赋值的(final)变量 result：await 调用 db.query(...) → 查询 |
| 52 | `      'books',` | 以字符串 'books' 起始的表达式：, |
| 53 | `      orderBy: '"order" ASC, durChapterTime DESC',` | 命名实参 orderBy: '"order" ASC, durChapterTime DESC'（order By） |
| 54 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 55 | `    return result.map((json) => _bookFromDbMap(json)).toList();` | 返回调用 result.map(...) 的结果（语义：映射） |
| 56 | `  }` | 闭合大括号，结束当前代码块 |
| 57 | `&nbsp;` | 空行，分隔逻辑段落 |
| 58 | `  /// 获取最后阅读的书籍` | 文档注释：说明其后代码的用途 |
| 59 | `  /// 参考项目：appDb.bookDao.lastReadBook` | 文档注释：说明其后代码的用途 |
| 60 | `  Future<Book?> getLastReadBook() async {` | 【承接上方文档】获取最后阅读的书籍 参考项目：appDb.bookDao.lastReadBook → 定义方法 getLastReadBook：返回 Future<Book?>；位置参数 1 个；含命名参数（异步）。语义：获取 最后 读取 书籍 |
| 61 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 62 | `    if (db == null) return null;` | 条件判断 if：db 等于 null) return null; |
| 63 | `&nbsp;` | 空行，分隔逻辑段落 |
| 64 | `    try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 65 | `      // 按最后阅读时间排序，获取最近阅读的书籍` | 注释说明：按最后阅读时间排序，获取最近阅读的书籍 |
| 66 | `      final result = await db.query(` | 声明不可重新赋值的(final)变量 result：await 调用 db.query(...) → 查询 |
| 67 | `        'books',` | 以字符串 'books' 起始的表达式：, |
| 68 | `        orderBy: 'durChapterTime DESC',` | 命名实参 orderBy: 'durChapterTime DESC'（order By） |
| 69 | `        limit: 1,` | 命名实参 limit: 1（限制） |
| 70 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 71 | `&nbsp;` | 空行，分隔逻辑段落 |
| 72 | `      if (result.isEmpty) return null;` | 条件判断 if：result.isEmpty) return null; |
| 73 | `      return _bookFromDbMap(result.first);` | 返回调用 _bookFromDbMap(...) 的结果（语义：书籍 From 数据库 映射） |
| 74 | `    } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 75 | `      AppLog.instance.put('获取最后阅读书籍失败: $e', error: e);` | 输出日志(put)：“获取最后阅读书籍失败: $e” |
| 76 | `      return null;` | 返回 null（初始为 null） |
| 77 | `    }` | 闭合大括号，结束当前代码块 |
| 78 | `  }` | 闭合大括号，结束当前代码块 |
| 79 | `&nbsp;` | 空行，分隔逻辑段落 |
| 80 | `  /// 根据分组获取书籍` | 文档注释：说明其后代码的用途 |
| 81 | `  Future<List<Book>> getBooksByGroup(int groupId) async {` | 【承接上方文档】根据分组获取书籍 → 定义方法 getBooksByGroup：返回 Future<List<Book>>；位置参数 1 个；含命名参数；参数名: groupId（异步）。语义：获取 Books By Group |
| 82 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 83 | `    if (db == null) return [];` | 条件判断 if：db 等于 null) return []; |
| 84 | `&nbsp;` | 空行，分隔逻辑段落 |
| 85 | `    final result = await db.query(` | 声明不可重新赋值的(final)变量 result：await 调用 db.query(...) → 查询 |
| 86 | `      'books',` | 以字符串 'books' 起始的表达式：, |
| 87 | `      where: '"group" = ?',` | 命名实参 where: '"group" = ?' |
| 88 | `      whereArgs: [groupId],` | 命名实参 whereArgs: [groupId]（where Args） |
| 89 | `      orderBy: '"order" ASC, durChapterTime DESC',` | 命名实参 orderBy: '"order" ASC, durChapterTime DESC'（order By） |
| 90 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 91 | `    return result.map((json) => _bookFromDbMap(json)).toList();` | 返回调用 result.map(...) 的结果（语义：映射） |
| 92 | `  }` | 闭合大括号，结束当前代码块 |
| 93 | `&nbsp;` | 空行，分隔逻辑段落 |
| 94 | `  /// 更新书籍分组` | 文档注释：说明其后代码的用途 |
| 95 | `  Future<void> updateBookGroup(String bookUrl, int groupId) async {` | 【承接上方文档】更新书籍分组 → 定义方法 updateBookGroup：返回 Future<void>；位置参数 2 个；含命名参数；参数名: bookUrl, groupId（异步）。语义：更新 书籍 Group |
| 96 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 97 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 if：db 等于 null；成立则抛出异常 Exception('数据库不可用（Web平台不支持SQLite）'); |
| 98 | `    await db.update(` | 调用 db.update(...)（等待异步完成） → 更新 |
| 99 | `      'books',` | 以字符串 'books' 起始的表达式：, |
| 100 | `      {'group': groupId},` | {'group': groupId}, |
| 101 | `      where: 'bookUrl = ?',` | 命名实参 where: 'bookUrl = ?' |
| 102 | `      whereArgs: [bookUrl],` | 命名实参 whereArgs: [bookUrl]（where Args） |
| 103 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 104 | `  }` | 闭合大括号，结束当前代码块 |
| 105 | `&nbsp;` | 空行，分隔逻辑段落 |
| 106 | `  /// 更新书籍阅读进度` | 文档注释：说明其后代码的用途 |
| 107 | `  Future<void> updateReadingProgress(` | 【承接上方文档】更新书籍阅读进度 → 定义方法 updateReadingProgress：返回 Future<void>；无参数（异步）。语义：更新 Reading 进度 |
| 108 | `    String bookUrl,` | String 类型参数 bookUrl（书籍 URL） |
| 109 | `    int chapterIndex,` | int 类型参数 chapterIndex（章节 索引） |
| 110 | `    int chapterPos,` | int 类型参数 chapterPos（章节 Pos） |
| 111 | `    String? chapterTitle,` | String? 类型参数 chapterTitle（章节 标题） |
| 112 | `  ) async {` | ) async { |
| 113 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 114 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 if：db 等于 null；成立则抛出异常 Exception('数据库不可用（Web平台不支持SQLite）'); |
| 115 | `    await db.update(` | 调用 db.update(...)（等待异步完成） → 更新 |
| 116 | `      'books',` | 以字符串 'books' 起始的表达式：, |
| 117 | `      {` | 代码块开始 { |
| 118 | `        'durChapterIndex': chapterIndex,` | Map 条目 'durChapterIndex': chapterIndex, |
| 119 | `        'durChapterPos': chapterPos,` | Map 条目 'durChapterPos': chapterPos, |
| 120 | `        'durChapterTitle': chapterTitle,` | Map 条目 'durChapterTitle': chapterTitle, |
| 121 | `        'durChapterTime': DateTime.now().millisecondsSinceEpoch,` | Map 条目 'durChapterTime': DateTime.now().millisecondsSinceEpoch, |
| 122 | `      },` | 结束上一个列表/参数项 |
| 123 | `      where: 'bookUrl = ?',` | 命名实参 where: 'bookUrl = ?' |
| 124 | `      whereArgs: [bookUrl],` | 命名实参 whereArgs: [bookUrl]（where Args） |
| 125 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 126 | `  }` | 闭合大括号，结束当前代码块 |
| 127 | `&nbsp;` | 空行，分隔逻辑段落 |
| 128 | `  /// 构建搜索URL` | 文档注释：说明其后代码的用途 |
| 129 | `  String _buildSearchUrl(String searchUrl, String keyword) {` | 【承接上方文档】构建搜索URL → 定义方法 _buildSearchUrl：返回 String；位置参数 2 个；参数名: searchUrl。语义：构建 搜索 URL |
| 130 | `    return searchUrl.replaceAll('{{key}}', Uri.encodeComponent(keyword));` | 返回调用 searchUrl.replaceAll(...) 的结果（语义：替换 全部） |
| 131 | `  }` | 闭合大括号，结束当前代码块 |
| 132 | `&nbsp;` | 空行，分隔逻辑段落 |
| 133 | `  /// 保存章节列表` | 文档注释：说明其后代码的用途 |
| 134 | `  Future<void> saveChapters(List<BookChapter> chapters) async {` | 【承接上方文档】保存章节列表 → 定义方法 saveChapters：返回 Future<void>；位置参数 1 个；含命名参数；参数名: chapters（异步）。语义：保存 章节列表 |
| 135 | `    if (chapters.isEmpty) return;` | 条件判断 if：chapters.isEmpty) return; |
| 136 | `&nbsp;` | 空行，分隔逻辑段落 |
| 137 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 138 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 if：db 等于 null；成立则抛出异常 Exception('数据库不可用（Web平台不支持SQLite）'); |
| 139 | `&nbsp;` | 空行，分隔逻辑段落 |
| 140 | `    // 先删除该书籍的所有章节，然后重新插入` | 注释说明：先删除该书籍的所有章节，然后重新插入 |
| 141 | `    // 这样可以避免由于 index 不同导致的重复记录` | 注释说明：这样可以避免由于 index 不同导致的重复记录 |
| 142 | `    final bookUrl = chapters.first.bookUrl;` | 声明不可重新赋值的(final)变量 bookUrl |
| 143 | `    await db.delete(` | 调用 db.delete(...)（等待异步完成） → 删除 |
| 144 | `      'chapters',` | 以字符串 'chapters' 起始的表达式：, |
| 145 | `      where: 'bookUrl = ?',` | 命名实参 where: 'bookUrl = ?' |
| 146 | `      whereArgs: [bookUrl],` | 命名实参 whereArgs: [bookUrl]（where Args） |
| 147 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 148 | `&nbsp;` | 空行，分隔逻辑段落 |
| 149 | `    final batch = db.batch();` | 声明不可重新赋值的(final)变量 batch：调用 db.batch(...) → 批量 |
| 150 | `&nbsp;` | 空行，分隔逻辑段落 |
| 151 | `    for (final chapter in chapters) {` | for-in 遍历：final chapter in chapters |
| 152 | `      batch.insert(` | 调用 insert(...)：batch.insert(（插入） |
| 153 | `        'chapters',` | 以字符串 'chapters' 起始的表达式：, |
| 154 | `        _chapterToDbMap(chapter),` | 调用 _chapterToDbMap(...)：_chapterToDbMap(chapter),（章节 To 数据库 映射） |
| 155 | `        conflictAlgorithm: ConflictAlgorithm.replace,` | 命名实参 conflictAlgorithm: ConflictAlgorithm.replace（conflict Algorithm） |
| 156 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 157 | `    }` | 闭合大括号，结束当前代码块 |
| 158 | `&nbsp;` | 空行，分隔逻辑段落 |
| 159 | `    await batch.commit(noResult: true);` | 调用 batch.commit(...)（等待异步完成） |
| 160 | `  }` | 闭合大括号，结束当前代码块 |
| 161 | `&nbsp;` | 空行，分隔逻辑段落 |
| 162 | `  /// 获取本地章节列表` | 文档注释：说明其后代码的用途 |
| 163 | `  Future<List<BookChapter>> _getLocalChapters(String bookUrl) async {` | 【承接上方文档】获取本地章节列表 → 定义方法 _getLocalChapters：返回 Future<List<BookChapter>>；位置参数 1 个；含命名参数；参数名: bookUrl（异步）。语义：获取 本地 章节列表 |
| 164 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 165 | `    if (db == null) return [];` | 条件判断 if：db 等于 null) return []; |
| 166 | `    final result = await db.query(` | 声明不可重新赋值的(final)变量 result：await 调用 db.query(...) → 查询 |
| 167 | `      'chapters',` | 以字符串 'chapters' 起始的表达式：, |
| 168 | `      where: 'bookUrl = ?',` | 命名实参 where: 'bookUrl = ?' |
| 169 | `      whereArgs: [bookUrl],` | 命名实参 whereArgs: [bookUrl]（where Args） |
| 170 | `      orderBy: '"index" ASC',` | 命名实参 orderBy: '"index" ASC'（order By） |
| 171 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 172 | `    return result.map((json) => _chapterFromDbMap(json)).toList();` | 返回调用 result.map(...) 的结果（语义：映射） |
| 173 | `  }` | 闭合大括号，结束当前代码块 |
| 174 | `&nbsp;` | 空行，分隔逻辑段落 |
| 175 | `  /// 从数据库获取指定索引的章节（参考项目：bookChapterDao.getChapter）` | 文档注释：说明其后代码的用途 |
| 176 | `  /// 确保返回的章节的 index 字段与请求的索引一致` | 文档注释：说明其后代码的用途 |
| 177 | `  Future<BookChapter?> getChapterByIndex(String bookUrl, int index) async {` | 【承接上方文档】从数据库获取指定索引的章节（参考项目：bookChapterDao.getChapter） 确保返回的章节的 index 字段与请求的索引一致 → 定义方法 getChapterByIndex：返回 Future<BookChapter?>；位置参数 2 个；含命名参数；参数名: bookUrl, index（异步）。语义：获取 章节 By 索引 |
| 178 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 179 | `    if (db == null) return null;` | 条件判断 if：db 等于 null) return null; |
| 180 | `    final result = await db.query(` | 声明不可重新赋值的(final)变量 result：await 调用 db.query(...) → 查询 |
| 181 | `      'chapters',` | 以字符串 'chapters' 起始的表达式：, |
| 182 | `      where: 'bookUrl = ? AND "index" = ?',` | 命名实参 where: 'bookUrl = ? AND "index" = ?' |
| 183 | `      whereArgs: [bookUrl, index],` | 命名实参 whereArgs: [bookUrl, index]（where Args） |
| 184 | `      limit: 1,` | 命名实参 limit: 1（限制） |
| 185 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 186 | `    if (result.isEmpty) return null;` | 条件判断 if：result.isEmpty) return null; |
| 187 | `    return _chapterFromDbMap(result.first);` | 返回调用 _chapterFromDbMap(...) 的结果（语义：章节 From 数据库 映射） |
| 188 | `  }` | 闭合大括号，结束当前代码块 |
| 189 | `&nbsp;` | 空行，分隔逻辑段落 |
| 190 | `  /// Book转数据库Map` | 文档注释：说明其后代码的用途 |
| 191 | `  Map<String, dynamic> _bookToDbMap(Book book) {` | 【承接上方文档】Book转数据库Map → 定义方法 _bookToDbMap：返回 Map<String, dynamic>；位置参数 1 个。语义：书籍 To 数据库 映射 |
| 192 | `    return {` | 返回 {（Map/集合字面量） |
| 193 | `      'bookUrl': book.bookUrl,` | Map 条目 'bookUrl': book.bookUrl, |
| 194 | `      'tocUrl': book.tocUrl,` | Map 条目 'tocUrl': book.tocUrl, |
| 195 | `      'origin': book.origin,` | Map 条目 'origin': book.origin, |
| 196 | `      'originName': book.originName,` | Map 条目 'originName': book.originName, |
| 197 | `      'name': book.name,` | Map 条目 'name': book.name, |
| 198 | `      'author': book.author,` | Map 条目 'author': book.author, |
| 199 | `      'kind': book.kind,` | Map 条目 'kind': book.kind, |
| 200 | `      'customTag': book.customTag,` | Map 条目 'customTag': book.customTag, |
| 201 | `      'coverUrl': book.coverUrl,` | Map 条目 'coverUrl': book.coverUrl, |
| 202 | `      'customCoverUrl': book.customCoverUrl,` | Map 条目 'customCoverUrl': book.customCoverUrl, |
| 203 | `      'intro': book.intro,` | Map 条目 'intro': book.intro, |
| 204 | `      'customIntro': book.customIntro,` | Map 条目 'customIntro': book.customIntro, |
| 205 | `      'charset': book.charset,` | Map 条目 'charset': book.charset, |
| 206 | `      'type': book.type,` | Map 条目 'type': book.type, |
| 207 | `      'group': book.group,` | Map 条目 'group': book.group, |
| 208 | `      'latestChapterTitle': book.latestChapterTitle,` | Map 条目 'latestChapterTitle': book.latestChapterTitle, |
| 209 | `      'latestChapterTime': book.latestChapterTime,` | Map 条目 'latestChapterTime': book.latestChapterTime, |
| 210 | `      'lastCheckTime': book.lastCheckTime,` | Map 条目 'lastCheckTime': book.lastCheckTime, |
| 211 | `      'lastCheckCount': book.lastCheckCount,` | Map 条目 'lastCheckCount': book.lastCheckCount, |
| 212 | `      'totalChapterNum': book.totalChapterNum,` | Map 条目 'totalChapterNum': book.totalChapterNum, |
| 213 | `      'durChapterTitle': book.durChapterTitle,` | Map 条目 'durChapterTitle': book.durChapterTitle, |
| 214 | `      'durChapterIndex': book.durChapterIndex,` | Map 条目 'durChapterIndex': book.durChapterIndex, |
| 215 | `      'durChapterPos': book.durChapterPos,` | Map 条目 'durChapterPos': book.durChapterPos, |
| 216 | `      'durChapterTime': book.durChapterTime,` | Map 条目 'durChapterTime': book.durChapterTime, |
| 217 | `      'wordCount': book.wordCount,` | Map 条目 'wordCount': book.wordCount, |
| 218 | `      'canUpdate': book.canUpdate ? 1 : 0,` | Map 条目 'canUpdate': book.canUpdate ? 1 : 0, |
| 219 | `      'order': book.order,` | Map 条目 'order': book.order, |
| 220 | `      'originOrder': book.originOrder,` | Map 条目 'originOrder': book.originOrder, |
| 221 | `      'variable': book.variable,` | Map 条目 'variable': book.variable, |
| 222 | `      'readConfig': book.readConfig != null` | 上一表达式的续行：'readConfig': book.readConfig != null |
| 223 | `          ? jsonEncode(book.readConfig!.toJson())` | 三元表达式为真时取值：jsonEncode(book.readConfig!.toJson()) |
| 224 | `          : null,` | 三元表达式为假时取值：null, |
| 225 | `      'syncTime': book.syncTime,` | Map 条目 'syncTime': book.syncTime, |
| 226 | `    };` | 闭合代码块并衔接后续语句：; |
| 227 | `  }` | 闭合大括号，结束当前代码块 |
| 228 | `&nbsp;` | 空行，分隔逻辑段落 |
| 229 | `  /// 数据库Map转Book` | 文档注释：说明其后代码的用途 |
| 230 | `  Book _bookFromDbMap(Map<String, dynamic> map) {` | 【承接上方文档】数据库Map转Book → 定义方法 _bookFromDbMap：返回 Book；位置参数 2 个；参数名: String。语义：书籍 From 数据库 映射 |
| 231 | `    return Book(` | 返回调用 Book(...) 的结果（语义：书籍） |
| 232 | `      bookUrl: map['bookUrl'] ?? '',` | 命名实参 bookUrl: map['bookUrl'] ?? ''（书籍 URL） |
| 233 | `      tocUrl: map['tocUrl'] ?? '',` | 命名实参 tocUrl: map['tocUrl'] ?? ''（目录(TOC) URL） |
| 234 | `      origin: map['origin'] ?? BookType.localTag,` | 命名实参 origin: map['origin'] ?? BookType.localTag（来源） |
| 235 | `      originName: map['originName'] ?? '',` | 命名实参 originName: map['originName'] ?? ''（来源 Name） |
| 236 | `      name: map['name'] ?? '',` | 命名实参 name: map['name'] ?? '' |
| 237 | `      author: map['author'] ?? '',` | 命名实参 author: map['author'] ?? ''（作者） |
| 238 | `      kind: map['kind'],` | 命名实参 kind: map['kind']（类别） |
| 239 | `      customTag: map['customTag'],` | 命名实参 customTag: map['customTag']（custom Tag） |
| 240 | `      coverUrl: map['coverUrl'],` | 命名实参 coverUrl: map['coverUrl']（封面 URL） |
| 241 | `      customCoverUrl: map['customCoverUrl'],` | 命名实参 customCoverUrl: map['customCoverUrl']（custom 封面 URL） |
| 242 | `      intro: map['intro'],` | 命名实参 intro: map['intro']（简介） |
| 243 | `      customIntro: map['customIntro'],` | 命名实参 customIntro: map['customIntro']（custom 简介） |
| 244 | `      charset: map['charset'],` | 命名实参 charset: map['charset'] |
| 245 | `      type: map['type'] ?? BookType.text,` | 命名实参 type: map['type'] ?? BookType.text |
| 246 | `      group: map['group'] ?? 0,` | 命名实参 group: map['group'] ?? 0 |
| 247 | `      latestChapterTitle: map['latestChapterTitle'],` | 命名实参 latestChapterTitle: map['latestChapterTitle']（latest 章节 标题） |
| 248 | `      latestChapterTime: map['latestChapterTime'] ?? 0,` | 命名实参 latestChapterTime: map['latestChapterTime'] ?? 0（latest 章节 Time） |
| 249 | `      lastCheckTime: map['lastCheckTime'] ?? 0,` | 命名实参 lastCheckTime: map['lastCheckTime'] ?? 0（最后 检查 Time） |
| 250 | `      lastCheckCount: map['lastCheckCount'] ?? 0,` | 命名实参 lastCheckCount: map['lastCheckCount'] ?? 0（最后 检查 数量） |
| 251 | `      totalChapterNum: map['totalChapterNum'] ?? 0,` | 命名实参 totalChapterNum: map['totalChapterNum'] ?? 0（total 章节 编号） |
| 252 | `      durChapterTitle: map['durChapterTitle'],` | 命名实参 durChapterTitle: map['durChapterTitle']（dur 章节 标题） |
| 253 | `      durChapterIndex: map['durChapterIndex'] ?? 0,` | 命名实参 durChapterIndex: map['durChapterIndex'] ?? 0（dur 章节 索引） |
| 254 | `      durChapterPos: map['durChapterPos'] ?? 0,` | 命名实参 durChapterPos: map['durChapterPos'] ?? 0（dur 章节 Pos） |
| 255 | `      durChapterTime: map['durChapterTime'] ?? 0,` | 命名实参 durChapterTime: map['durChapterTime'] ?? 0（dur 章节 Time） |
| 256 | `      wordCount: map['wordCount'],` | 命名实参 wordCount: map['wordCount']（word 数量） |
| 257 | `      canUpdate: map['canUpdate'] == 1,` | 命名实参 canUpdate: map['canUpdate'] == 1（can 更新） |
| 258 | `      order: map['order'] ?? 0,` | 命名实参 order: map['order'] ?? 0 |
| 259 | `      originOrder: map['originOrder'] ?? 0,` | 命名实参 originOrder: map['originOrder'] ?? 0（来源 Order） |
| 260 | `      variable: map['variable'],` | 命名实参 variable: map['variable']（变量） |
| 261 | `      readConfig: map['readConfig'] != null` | 上一表达式的续行：readConfig: map['readConfig'] != null |
| 262 | `          ? ReadConfig.fromJson(jsonDecode(map['readConfig']))` | 三元表达式为真时取值：ReadConfig.fromJson(jsonDecode(map['readConfig'])) |
| 263 | `          : null,` | 三元表达式为假时取值：null, |
| 264 | `      syncTime: map['syncTime'] ?? 0,` | 命名实参 syncTime: map['syncTime'] ?? 0（sync Time） |
| 265 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 266 | `  }` | 闭合大括号，结束当前代码块 |
| 267 | `&nbsp;` | 空行，分隔逻辑段落 |
| 268 | `  /// BookChapter转数据库Map` | 文档注释：说明其后代码的用途 |
| 269 | `  Map<String, dynamic> _chapterToDbMap(BookChapter chapter) {` | 【承接上方文档】BookChapter转数据库Map → 定义方法 _chapterToDbMap：返回 Map<String, dynamic>；位置参数 1 个。语义：章节 To 数据库 映射 |
| 270 | `    return {` | 返回 {（Map/集合字面量） |
| 271 | `      'url': chapter.url,` | Map 条目 'url': chapter.url, |
| 272 | `      'bookUrl': chapter.bookUrl,` | Map 条目 'bookUrl': chapter.bookUrl, |
| 273 | `      'title': chapter.title,` | Map 条目 'title': chapter.title, |
| 274 | `      'isVolume': chapter.isVolume ? 1 : 0,` | Map 条目 'isVolume': chapter.isVolume ? 1 : 0, |
| 275 | `      'baseUrl': chapter.baseUrl,` | Map 条目 'baseUrl': chapter.baseUrl, |
| 276 | `      'index': chapter.index,` | Map 条目 'index': chapter.index, |
| 277 | `      'isVip': chapter.isVip ? 1 : 0,` | Map 条目 'isVip': chapter.isVip ? 1 : 0, |
| 278 | `      'isPay': chapter.isPay ? 1 : 0,` | Map 条目 'isPay': chapter.isPay ? 1 : 0, |
| 279 | `      'resourceUrl': chapter.resourceUrl,` | Map 条目 'resourceUrl': chapter.resourceUrl, |
| 280 | `      'tag': chapter.tag,` | Map 条目 'tag': chapter.tag, |
| 281 | `      'wordCount': chapter.wordCount,` | Map 条目 'wordCount': chapter.wordCount, |
| 282 | `      'start': chapter.start,` | Map 条目 'start': chapter.start, |
| 283 | `      'end': chapter.end,` | Map 条目 'end': chapter.end, |
| 284 | `      'startFragmentId': chapter.startFragmentId,` | Map 条目 'startFragmentId': chapter.startFragmentId, |
| 285 | `      'endFragmentId': chapter.endFragmentId,` | Map 条目 'endFragmentId': chapter.endFragmentId, |
| 286 | `      'variable': chapter.variable,` | Map 条目 'variable': chapter.variable, |
| 287 | `    };` | 闭合代码块并衔接后续语句：; |
| 288 | `  }` | 闭合大括号，结束当前代码块 |
| 289 | `&nbsp;` | 空行，分隔逻辑段落 |
| 290 | `  /// 数据库Map转BookChapter` | 文档注释：说明其后代码的用途 |
| 291 | `  BookChapter _chapterFromDbMap(Map<String, dynamic> map) {` | 【承接上方文档】数据库Map转BookChapter → 定义方法 _chapterFromDbMap：返回 BookChapter；位置参数 2 个；参数名: String。语义：章节 From 数据库 映射 |
| 292 | `    return BookChapter(` | 返回调用 BookChapter(...) 的结果（语义：书籍 章节） |
| 293 | `      url: map['url'] ?? '',` | 命名实参 url: map['url'] ?? ''（URL） |
| 294 | `      title: map['title'] ?? '',` | 命名实参 title: map['title'] ?? ''（标题） |
| 295 | `      isVolume: map['isVolume'] == 1,` | 命名实参 isVolume: map['isVolume'] == 1（is Volume） |
| 296 | `      baseUrl: map['baseUrl'] ?? '',` | 命名实参 baseUrl: map['baseUrl'] ?? ''（base URL） |
| 297 | `      bookUrl: map['bookUrl'] ?? '',` | 命名实参 bookUrl: map['bookUrl'] ?? ''（书籍 URL） |
| 298 | `      index: map['index'] ?? 0,` | 命名实参 index: map['index'] ?? 0（索引） |
| 299 | `      isVip: map['isVip'] == 1,` | 命名实参 isVip: map['isVip'] == 1（is Vip） |
| 300 | `      isPay: map['isPay'] == 1,` | 命名实参 isPay: map['isPay'] == 1（is Pay） |
| 301 | `      resourceUrl: map['resourceUrl'],` | 命名实参 resourceUrl: map['resourceUrl']（resource URL） |
| 302 | `      tag: map['tag'],` | 命名实参 tag: map['tag'] |
| 303 | `      wordCount: map['wordCount'],` | 命名实参 wordCount: map['wordCount']（word 数量） |
| 304 | `      start: map['start'],` | 命名实参 start: map['start'] |
| 305 | `      end: map['end'],` | 命名实参 end: map['end'] |
| 306 | `      startFragmentId: map['startFragmentId'],` | 命名实参 startFragmentId: map['startFragmentId']（start Fragment Id） |
| 307 | `      endFragmentId: map['endFragmentId'],` | 命名实参 endFragmentId: map['endFragmentId']（end Fragment Id） |
| 308 | `      variable: map['variable'],` | 命名实参 variable: map['variable']（变量） |
| 309 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 310 | `  }` | 闭合大括号，结束当前代码块 |
| 311 | `&nbsp;` | 空行，分隔逻辑段落 |
| 312 | `  /// 更新书籍排序` | 文档注释：说明其后代码的用途 |
| 313 | `  Future<void> updateBookOrder(String bookUrl, int order) async {` | 【承接上方文档】更新书籍排序 → 定义方法 updateBookOrder：返回 Future<void>；位置参数 2 个；含命名参数；参数名: bookUrl, order（异步）。语义：更新 书籍 Order |
| 314 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 315 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 if：db 等于 null；成立则抛出异常 Exception('数据库不可用（Web平台不支持SQLite）'); |
| 316 | `    await db.update(` | 调用 db.update(...)（等待异步完成） → 更新 |
| 317 | `      'books',` | 以字符串 'books' 起始的表达式：, |
| 318 | `      {'order': order},` | {'order': order}, |
| 319 | `      where: 'bookUrl = ?',` | 命名实参 where: 'bookUrl = ?' |
| 320 | `      whereArgs: [bookUrl],` | 命名实参 whereArgs: [bookUrl]（where Args） |
| 321 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 322 | `  }` | 闭合大括号，结束当前代码块 |
| 323 | `&nbsp;` | 空行，分隔逻辑段落 |
| 324 | `  /// 更新书籍信息` | 文档注释：说明其后代码的用途 |
| 325 | `  Future<void> updateBook(Book book) async {` | 【承接上方文档】更新书籍信息 → 定义方法 updateBook：返回 Future<void>；位置参数 1 个；含命名参数；参数名: book（异步）。语义：更新 书籍 |
| 326 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 327 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 if：db 等于 null；成立则抛出异常 Exception('数据库不可用（Web平台不支持SQLite）'); |
| 328 | `    await db.update(` | 调用 db.update(...)（等待异步完成） → 更新 |
| 329 | `      'books',` | 以字符串 'books' 起始的表达式：, |
| 330 | `      _bookToDbMap(book),` | 调用 _bookToDbMap(...)：_bookToDbMap(book),（书籍 To 数据库 映射） |
| 331 | `      where: 'bookUrl = ?',` | 命名实参 where: 'bookUrl = ?' |
| 332 | `      whereArgs: [book.bookUrl],` | 命名实参 whereArgs: [book.bookUrl]（where Args） |
| 333 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 334 | `  }` | 闭合大括号，结束当前代码块 |
| 335 | `&nbsp;` | 空行，分隔逻辑段落 |
| 336 | `  /// 更新章节字数` | 文档注释：说明其后代码的用途 |
| 337 | `  /// 参考项目：BookService.updateChapterWordCount` | 文档注释：说明其后代码的用途 |
| 338 | `  Future<void> updateChapterWordCount(BookChapter chapter) async {` | 【承接上方文档】更新章节字数 参考项目：BookService.updateChapterWordCount → 定义方法 updateChapterWordCount：返回 Future<void>；位置参数 1 个；含命名参数；参数名: chapter（异步）。语义：更新 章节 Word 数量 |
| 339 | `    final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 340 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 if：db 等于 null；成立则抛出异常 Exception('数据库不可用（Web平台不支持SQLite）'); |
| 341 | `    await db.update(` | 调用 db.update(...)（等待异步完成） → 更新 |
| 342 | `      'chapters',` | 以字符串 'chapters' 起始的表达式：, |
| 343 | `      {'wordCount': chapter.wordCount},` | {'wordCount': chapter.wordCount}, |
| 344 | `      where: 'url = ? AND bookUrl = ?',` | 命名实参 where: 'url = ? AND bookUrl = ?' |
| 345 | `      whereArgs: [chapter.url, chapter.bookUrl],` | 命名实参 whereArgs: [chapter.url, chapter.bookUrl]（where Args） |
| 346 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 347 | `  }` | 闭合大括号，结束当前代码块 |
| 348 | `&nbsp;` | 空行，分隔逻辑段落 |
| 349 | `  /// 从数据库获取已存在的章节字数` | 文档注释：说明其后代码的用途 |
| 350 | `  /// 参考项目：BookChapterList.getWordCount（第272-286行）` | 文档注释：说明其后代码的用途 |
| 351 | `  Future<void> getWordCount(List<BookChapter> chapters, Book book) async {` | 【承接上方文档】从数据库获取已存在的章节字数 参考项目：BookChapterList.getWordCount（第272-286行） → 定义方法 getWordCount：返回 Future<void>；位置参数 2 个；含命名参数；参数名: chapters, book（异步）。语义：获取 Word 数量 |
| 352 | `    // 参考项目：如果 AppConfig.tocCountWords 为 false，不处理` | 注释说明：参考项目：如果 AppConfig.tocCountWords 为 false，不处理 |
| 353 | `    // 这里暂时总是处理，如果需要可以从配置中读取` | 注释说明：这里暂时总是处理，如果需要可以从配置中读取 |
| 354 | `    try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 355 | `      final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 356 | `      if (db == null) return;` | 条件判断 if：db 等于 null) return; |
| 357 | `&nbsp;` | 空行，分隔逻辑段落 |
| 358 | `      // 从数据库获取已存在的章节列表` | 注释说明：从数据库获取已存在的章节列表 |
| 359 | `      final existingChapters = await _getLocalChapters(book.bookUrl);` | 声明不可重新赋值的(final)变量 existingChapters：await 调用 _getLocalChapters(...) → 获取 本地 章节列表 |
| 360 | `      if (existingChapters.isEmpty) return;` | 条件判断 if：existingChapters.isEmpty) return; |
| 361 | `&nbsp;` | 空行，分隔逻辑段落 |
| 362 | `      // 创建章节文件名的映射（参考项目：associateBy）` | 注释说明：创建章节文件名的映射（参考项目：associateBy） |
| 363 | `      final wordCountMap = <String, String>{};` | 声明不可重新赋值的(final)变量 wordCountMap |
| 364 | `      for (final existingChapter in existingChapters) {` | for-in 遍历：final existingChapter in existingChapters |
| 365 | `        final fileName = _getChapterFileName(existingChapter);` | 声明不可重新赋值的(final)变量 fileName：调用 _getChapterFileName(...) → 获取 章节 File Name |
| 366 | `        if (existingChapter.wordCount != null &&` | 条件判断 if：existingChapter.wordCount 不等于 null 且 |
| 367 | `            existingChapter.wordCount!.isNotEmpty) {` | existingChapter.wordCount!.isNotEmpty) { |
| 368 | `          wordCountMap[fileName] = existingChapter.wordCount!;` | wordCountMap[fileName] = existingChapter.wordCount! |
| 369 | `        }` | 闭合大括号，结束当前代码块 |
| 370 | `      }` | 闭合大括号，结束当前代码块 |
| 371 | `&nbsp;` | 空行，分隔逻辑段落 |
| 372 | `      // 更新章节字数` | 注释说明：更新章节字数 |
| 373 | `      for (final chapter in chapters) {` | for-in 遍历：final chapter in chapters |
| 374 | `        final fileName = _getChapterFileName(chapter);` | 声明不可重新赋值的(final)变量 fileName：调用 _getChapterFileName(...) → 获取 章节 File Name |
| 375 | `        final wordCount = wordCountMap[fileName];` | 声明不可重新赋值的(final)变量 wordCount |
| 376 | `        if (wordCount != null) {` | 条件判断 if：wordCount 不等于 null |
| 377 | `          chapter.wordCount = wordCount;` | 将 wordCount 赋值给 chapter.wordCount |
| 378 | `        }` | 闭合大括号，结束当前代码块 |
| 379 | `      }` | 闭合大括号，结束当前代码块 |
| 380 | `    } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 381 | `      AppLog.instance.put('获取章节字数失败: $e', error: e);` | 输出日志(put)：“获取章节字数失败: $e” |
| 382 | `    }` | 闭合大括号，结束当前代码块 |
| 383 | `  }` | 闭合大括号，结束当前代码块 |
| 384 | `&nbsp;` | 空行，分隔逻辑段落 |
| 385 | `  /// 获取章节文件名（用于字数匹配）` | 文档注释：说明其后代码的用途 |
| 386 | `  /// 参考项目：BookChapter.getFileName` | 文档注释：说明其后代码的用途 |
| 387 | `  String _getChapterFileName(BookChapter chapter) {` | 【承接上方文档】获取章节文件名（用于字数匹配） 参考项目：BookChapter.getFileName → 定义方法 _getChapterFileName：返回 String；位置参数 1 个。语义：获取 章节 File Name |
| 388 | `    // 参考项目：使用章节URL的MD5作为文件名` | 注释说明：参考项目：使用章节URL的MD5作为文件名 |
| 389 | `    // 这里简化处理，使用章节索引和URL的组合` | 注释说明：这里简化处理，使用章节索引和URL的组合 |
| 390 | `    return '${chapter.index}_${chapter.url}';` | 返回 '${chapter.index}_${chapter.url}'（字符串字面量 '${chapter.index}_${chapter.url}'） |
| 391 | `  }` | 闭合大括号，结束当前代码块 |
| 392 | `&nbsp;` | 空行，分隔逻辑段落 |
| 393 | `  /// 更新章节的localPath字段` | 文档注释：说明其后代码的用途 |
| 394 | `  ///` | 文档注释：说明其后代码的用途 |
| 395 | `  /// 将章节内容文件路径更新到数据库` | 文档注释：说明其后代码的用途 |
| 396 | `  Future<void> _updateChapterLocalPath(` | 【承接上方文档】更新章节的localPath字段  将章节内容文件路径更新到数据库 → 定义方法 _updateChapterLocalPath：返回 Future<void>；无参数（异步）。语义：更新 章节 本地 Path |
| 397 | `    String bookUrl,` | String 类型参数 bookUrl（书籍 URL） |
| 398 | `    String chapterUrl,` | String 类型参数 chapterUrl（章节 URL） |
| 399 | `    String localPath,` | String 类型参数 localPath（本地 Path） |
| 400 | `  ) async {` | ) async { |
| 401 | `    try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 402 | `      final db = await _db.database;` | 声明不可重新赋值的(final)变量 db：await 等待异步调用结果 |
| 403 | `      if (db == null) return;` | 条件判断 if：db 等于 null) return; |
| 404 | `&nbsp;` | 空行，分隔逻辑段落 |
| 405 | `      await db.update(` | 调用 db.update(...)（等待异步完成） → 更新 |
| 406 | `        'chapters',` | 以字符串 'chapters' 起始的表达式：, |
| 407 | `        {'localPath': localPath},` | {'localPath': localPath}, |
| 408 | `        where: 'bookUrl = ? AND url = ?',` | 命名实参 where: 'bookUrl = ? AND url = ?' |
| 409 | `        whereArgs: [bookUrl, chapterUrl],` | 命名实参 whereArgs: [bookUrl, chapterUrl]（where Args） |
| 410 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 411 | `    } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 412 | `      AppLog.instance.put(` | 输出应用日志 AppLog |
| 413 | `        '更新章节localPath失败: bookUrl=$bookUrl, url=$chapterUrl',` | 以字符串 '更新章节localPath失败: bookUrl=$bookUrl, url=… 起始的表达式：, |
| 414 | `        error: e,` | 命名实参 error: e（错误） |
| 415 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 416 | `    }` | 闭合大括号，结束当前代码块 |
| 417 | `  }` | 闭合大括号，结束当前代码块 |
| 418 | `&nbsp;` | 空行，分隔逻辑段落 |
| 419 | `  // ── Phase 3：辅助工具方法 ────────────────────────────────────────────────` | 注释说明：── Phase 3：辅助工具方法 ──────────────────────────────────────────────── |
| 420 | `&nbsp;` | 空行，分隔逻辑段落 |
| 421 | `  /// 将时长字符串解析为秒数（int）` | 文档注释：说明其后代码的用途 |
| 422 | `  ///` | 文档注释：说明其后代码的用途 |
| 423 | `  /// 支持三种格式：` | 文档注释：说明其后代码的用途 |
| 424 | `  ///   - 纯秒数字符串：`"1800"` → 1800` | 文档注释：说明其后代码的用途 |
| 425 | `  ///   - MM:SS 格式：`"30:00"` → 1800` | 文档注释：说明其后代码的用途 |
| 426 | `  ///   - HH:MM:SS 格式：`"00:30:00"` → 1800` | 文档注释：说明其后代码的用途 |
| 427 | `  ///` | 文档注释：说明其后代码的用途 |
| 428 | `  /// 解析失败或输入为空时返回 null。` | 文档注释：说明其后代码的用途 |
| 429 | `  static int? _parseDurationString(String? raw) {` | 【承接上方文档】将时长字符串解析为秒数（int）  支持三种格式： - 纯秒数字符串：`"1800"` → 1800 - MM:SS 格式：`"30:00"` → 1800 - → 定义静态方法 _parseDurationString：返回 int?；位置参数 1 个。语义：解析 Duration String |
| 430 | `    if (raw == null \|\| raw.trim().isEmpty) return null;` | 条件判断 if：raw 等于 null 或 raw.trim().isEmpty) return null; |
| 431 | `    final trimmed = raw.trim();` | 声明不可重新赋值的(final)变量 trimmed：调用 raw.trim(...) → 修剪 |
| 432 | `&nbsp;` | 空行，分隔逻辑段落 |
| 433 | `    // 尝试 HH:MM:SS 或 MM:SS 格式` | 注释说明：尝试 HH:MM:SS 或 MM:SS 格式 |
| 434 | `    final parts = trimmed.split(':');` | 声明不可重新赋值的(final)变量 parts |
| 435 | `    if (parts.length == 2) {` | 条件判断 if：parts.length 等于 2 |
| 436 | `      // MM:SS` | 注释说明：MM:SS |
| 437 | `      final minutes = int.tryParse(parts[0]);` | 声明不可重新赋值的(final)变量 minutes：调用 int.tryParse(...) → try 解析 |
| 438 | `      final seconds = int.tryParse(parts[1]);` | 声明不可重新赋值的(final)变量 seconds：调用 int.tryParse(...) → try 解析 |
| 439 | `      if (minutes != null && seconds != null) {` | 条件判断 if：minutes 不等于 null 且 seconds 不等于 null |
| 440 | `        return minutes * 60 + seconds;` | 返回 minutes * 60 + seconds |
| 441 | `      }` | 闭合大括号，结束当前代码块 |
| 442 | `    } else if (parts.length == 3) {` | 闭合上一代码块并开始 else if (parts.length == 3) { |
| 443 | `      // HH:MM:SS` | 注释说明：HH:MM:SS |
| 444 | `      final hours = int.tryParse(parts[0]);` | 声明不可重新赋值的(final)变量 hours：调用 int.tryParse(...) → try 解析 |
| 445 | `      final minutes = int.tryParse(parts[1]);` | 声明不可重新赋值的(final)变量 minutes：调用 int.tryParse(...) → try 解析 |
| 446 | `      final seconds = int.tryParse(parts[2]);` | 声明不可重新赋值的(final)变量 seconds：调用 int.tryParse(...) → try 解析 |
| 447 | `      if (hours != null && minutes != null && seconds != null) {` | 条件判断 if：hours 不等于 null 且 minutes 不等于 null 且 seconds 不等于 null |
| 448 | `        return hours * 3600 + minutes * 60 + seconds;` | 返回 hours * 3600 + minutes * 60 + seconds |
| 449 | `      }` | 闭合大括号，结束当前代码块 |
| 450 | `    }` | 闭合大括号，结束当前代码块 |
| 451 | `&nbsp;` | 空行，分隔逻辑段落 |
| 452 | `    // 尝试纯数字（秒数）` | 注释说明：尝试纯数字（秒数） |
| 453 | `    return int.tryParse(trimmed);` | 返回调用 int.tryParse(...) 的结果（语义：try 解析） |
| 454 | `  }` | 闭合大括号，结束当前代码块 |
