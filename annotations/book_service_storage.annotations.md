# book_service_storage.dart 逐行注释

> 源文件：`lib/services/book/book_service_storage.dart`（共 454 行）
>
> 本文件由 `scripts/gen_line_annotations.py` 自动生成，对源文件每一行给出独立说明。
> 说明优先采用源码自带的中文注释；无注释的行依据 Dart 语法特征自动生成解释。

| 行号 | 源代码 | 说明 |
| ---: | --- | --- |
| 1 | `part of 'book_service.dart';` | 声明本文件是 书籍 服务.dart 库的一部分(分部文件(part))，与其共享同一命名空间 |
| 2 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 4 | `// BookService 职责：书籍/章节数据库读写、模型与 DB 行双向映射、字数统计与本地路径维护。` | 注释说明：书籍 服务 职责：书籍/章节数据库读写、模型与 数据库(DB) 行双向映射、字数统计与本地路径维护。 |
| 5 | `// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）` | 注释说明：（分部文件(part) 文件，与主文件 书籍 服务.dart 共享同一 Dart 库，可访问私有符号） |
| 6 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 7 | `&nbsp;` | 空行，分隔逻辑段落 |
| 8 | `  Future<void> saveBook(Book book) async {` | 定义方法 保存 书籍：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 书籍（异步）。语义：保存 书籍 |
| 9 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 10 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 11 | `    await db.insert(` | 调用 数据库.插入(...)（等待异步完成） → 插入 |
| 12 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 13 | `      _bookToDbMap(book),` | 调用 _bookToDbMap(...)：_bookToDbMap(书籍),（书籍 To 数据库 映射） |
| 14 | `      conflictAlgorithm: ConflictAlgorithm.replace,` | 命名实参 conflictAlgorithm: ConflictAlgorithm.replace（conflict Algorithm） |
| 15 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 16 | `  }` | 闭合大括号，结束当前代码块 |
| 17 | `&nbsp;` | 空行，分隔逻辑段落 |
| 18 | `  /// 创建书籍（保存书籍和章节）` | 文档注释：说明其后代码的用途 |
| 19 | `  Future<Book> createBook(Book book) async {` | 【承接上方文档】创建书籍（保存书籍和章节） → 定义方法 createBook：返回 异步结果(Future)<书籍(Book)>；位置参数 1 个；含命名参数；参数名: 书籍（异步）。语义：create 书籍 |
| 20 | `    await saveBook(book);` | 调用 保存 书籍(...)（等待异步完成） → 保存 书籍 |
| 21 | `    return book;` | 返回 书籍 |
| 22 | `  }` | 闭合大括号，结束当前代码块 |
| 23 | `&nbsp;` | 空行，分隔逻辑段落 |
| 24 | `  /// 创建章节` | 文档注释：说明其后代码的用途 |
| 25 | `  Future<void> createChapter(BookChapter chapter) async {` | 【承接上方文档】创建章节 → 定义方法 createChapter：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 章节（异步）。语义：create 章节 |
| 26 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 27 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 28 | `    await db.insert(` | 调用 数据库.插入(...)（等待异步完成） → 插入 |
| 29 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 30 | `      _chapterToDbMap(chapter),` | 调用 _chapterToDbMap(...)：_chapterToDbMap(章节),（章节 To 数据库 映射） |
| 31 | `      conflictAlgorithm: ConflictAlgorithm.replace,` | 命名实参 conflictAlgorithm: ConflictAlgorithm.replace（conflict Algorithm） |
| 32 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 33 | `  }` | 闭合大括号，结束当前代码块 |
| 34 | `&nbsp;` | 空行，分隔逻辑段落 |
| 35 | `  /// 从书架删除书籍` | 文档注释：说明其后代码的用途 |
| 36 | `  Future<void> deleteBook(String bookUrl) async {` | 【承接上方文档】从书架删除书籍 → 定义方法 删除 书籍：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 书籍链接（异步）。语义：删除 书籍 |
| 37 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 38 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 39 | `    await db.delete(` | 调用 数据库.delete(...)（等待异步完成） → 删除 |
| 40 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 41 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 42 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 43 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 44 | `    // 章节会通过外键级联删除` | 注释说明：章节会通过外键级联删除 |
| 45 | `  }` | 闭合大括号，结束当前代码块 |
| 46 | `&nbsp;` | 空行，分隔逻辑段落 |
| 47 | `  /// 获取书架所有书籍` | 文档注释：说明其后代码的用途 |
| 48 | `  Future<List<Book>> getBookshelfBooks() async {` | 【承接上方文档】获取书架所有书籍 → 定义方法 getBookshelfBooks：返回 异步结果(Future)<列表(List)<书籍(Book)>>；位置参数 1 个；含命名参数（异步）。语义：获取 Bookshelf 书籍列表 |
| 49 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 50 | `    if (db == null) return [];` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) []; |
| 51 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 52 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 53 | `      orderBy: '"order" ASC, durChapterTime DESC',` | 命名实参 orderBy: '"顺序" ASC, durChapterTime DESC'（顺序 By） |
| 54 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 55 | `    return result.map((json) => _bookFromDbMap(json)).toList();` | 返回调用 结果.映射(map)(...) 的结果（语义：映射） |
| 56 | `  }` | 闭合大括号，结束当前代码块 |
| 57 | `&nbsp;` | 空行，分隔逻辑段落 |
| 58 | `  /// 获取最后阅读的书籍` | 文档注释：说明其后代码的用途 |
| 59 | `  /// 参考项目：appDb.bookDao.lastReadBook` | 文档注释：说明其后代码的用途 |
| 60 | `  Future<Book?> getLastReadBook() async {` | 【承接上方文档】获取最后阅读的书籍 参考项目：appDb.bookDao.最后 读取 书籍 → 定义方法 获取 最后 读取 书籍：返回 异步结果(Future)<书籍(Book)?>；位置参数 1 个；含命名参数（异步）。语义：获取 最后 读取 书籍 |
| 61 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 62 | `    if (db == null) return null;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 空值(null); |
| 63 | `&nbsp;` | 空行，分隔逻辑段落 |
| 64 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 65 | `      // 按最后阅读时间排序，获取最近阅读的书籍` | 注释说明：按最后阅读时间排序，获取最近阅读的书籍 |
| 66 | `      final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 67 | `        'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 68 | `        orderBy: 'durChapterTime DESC',` | 命名实参 orderBy: 'durChapterTime DESC'（顺序 By） |
| 69 | `        limit: 1,` | 命名实参 limit: 1（限制） |
| 70 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 71 | `&nbsp;` | 空行，分隔逻辑段落 |
| 72 | `      if (result.isEmpty) return null;` | 条件判断 如果(if)：结果.是否为空) 返回(return) 空值(null); |
| 73 | `      return _bookFromDbMap(result.first);` | 返回调用 _bookFromDbMap(...) 的结果（语义：书籍 From 数据库 映射） |
| 74 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 75 | `      AppLog.instance.put('获取最后阅读书籍失败: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取最后阅读书籍失败: $e', error: e); |
| 76 | `      return null;` | 返回 空值(null)（初始为 空值(null)） |
| 77 | `    }` | 闭合大括号，结束当前代码块 |
| 78 | `  }` | 闭合大括号，结束当前代码块 |
| 79 | `&nbsp;` | 空行，分隔逻辑段落 |
| 80 | `  /// 根据分组获取书籍` | 文档注释：说明其后代码的用途 |
| 81 | `  Future<List<Book>> getBooksByGroup(int groupId) async {` | 【承接上方文档】根据分组获取书籍 → 定义方法 getBooksByGroup：返回 异步结果(Future)<列表(List)<书籍(Book)>>；位置参数 1 个；含命名参数；参数名: 捕获组 编号(id)（异步）。语义：获取 书籍列表 By 捕获组 |
| 82 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 83 | `    if (db == null) return [];` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) []; |
| 84 | `&nbsp;` | 空行，分隔逻辑段落 |
| 85 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 86 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 87 | `      where: '"group" = ?',` | 命名实参 筛选(where): '"捕获组" = ?'（筛选(筛选(where))） |
| 88 | `      whereArgs: [groupId],` | 命名实参 筛选(where) 实参列表: [捕获组 编号(id)]（筛选(筛选(where)) 实参列表） |
| 89 | `      orderBy: '"order" ASC, durChapterTime DESC',` | 命名实参 orderBy: '"顺序" ASC, durChapterTime DESC'（顺序 By） |
| 90 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 91 | `    return result.map((json) => _bookFromDbMap(json)).toList();` | 返回调用 结果.映射(map)(...) 的结果（语义：映射） |
| 92 | `  }` | 闭合大括号，结束当前代码块 |
| 93 | `&nbsp;` | 空行，分隔逻辑段落 |
| 94 | `  /// 更新书籍分组` | 文档注释：说明其后代码的用途 |
| 95 | `  Future<void> updateBookGroup(String bookUrl, int groupId) async {` | 【承接上方文档】更新书籍分组 → 定义方法 更新 书籍 捕获组：返回 异步结果(Future)<无返回值(void)>；位置参数 2 个；含命名参数；参数名: 书籍链接, 捕获组 编号(id)（异步）。语义：更新 书籍 捕获组 |
| 96 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 97 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 98 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 99 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 100 | `      {'group': groupId},` | {'捕获组': 捕获组 编号(id)}, |
| 101 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 102 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 103 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 104 | `  }` | 闭合大括号，结束当前代码块 |
| 105 | `&nbsp;` | 空行，分隔逻辑段落 |
| 106 | `  /// 更新书籍阅读进度` | 文档注释：说明其后代码的用途 |
| 107 | `  Future<void> updateReadingProgress(` | 【承接上方文档】更新书籍阅读进度 → 定义方法 updateReadingProgress：返回 异步结果(Future)<无返回值(void)>；无参数（异步）。语义：更新 Reading 进度 |
| 108 | `    String bookUrl,` | 字符串(String) 类型参数 书籍链接（书籍 统一资源链接(URL)） |
| 109 | `    int chapterIndex,` | 整数(int) 类型参数 章节 索引（章节 索引） |
| 110 | `    int chapterPos,` | 整数(int) 类型参数 章节 位置（章节 位置） |
| 111 | `    String? chapterTitle,` | 字符串(String)? 类型参数 章节 标题（章节 标题） |
| 112 | `  ) async {` | ) 异步(async) { |
| 113 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 114 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 115 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 116 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 117 | `      {` | 代码块开始 { |
| 118 | `        'durChapterIndex': chapterIndex,` | 映射(Map) 条目 'durChapterIndex': 章节 索引, |
| 119 | `        'durChapterPos': chapterPos,` | 映射(Map) 条目 'durChapterPos': 章节 位置, |
| 120 | `        'durChapterTitle': chapterTitle,` | 映射(Map) 条目 'durChapterTitle': 章节 标题, |
| 121 | `        'durChapterTime': DateTime.now().millisecondsSinceEpoch,` | 映射(Map) 条目 'durChapterTime': DateTime.now().millisecondsSinceEpoch, |
| 122 | `      },` | 结束上一个列表/参数项 |
| 123 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 124 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 125 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 126 | `  }` | 闭合大括号，结束当前代码块 |
| 127 | `&nbsp;` | 空行，分隔逻辑段落 |
| 128 | `  /// 构建搜索URL` | 文档注释：说明其后代码的用途 |
| 129 | `  String _buildSearchUrl(String searchUrl, String keyword) {` | 【承接上方文档】构建搜索统一资源链接(URL) → 定义方法 _构建 搜索 URL：返回 字符串(String)；位置参数 2 个；参数名: 搜索链接。语义：构建 搜索 统一资源链接(URL) |
| 130 | `    return searchUrl.replaceAll('{{key}}', Uri.encodeComponent(keyword));` | 返回调用 搜索链接.全部替换(...) 的结果（语义：替换 全部） |
| 131 | `  }` | 闭合大括号，结束当前代码块 |
| 132 | `&nbsp;` | 空行，分隔逻辑段落 |
| 133 | `  /// 保存章节列表` | 文档注释：说明其后代码的用途 |
| 134 | `  Future<void> saveChapters(List<BookChapter> chapters) async {` | 【承接上方文档】保存章节列表 → 定义方法 保存 章节列表：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 章节列表（异步）。语义：保存 章节列表 |
| 135 | `    if (chapters.isEmpty) return;` | 条件判断 如果(if)：章节列表.是否为空) 返回(return); |
| 136 | `&nbsp;` | 空行，分隔逻辑段落 |
| 137 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 138 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 139 | `&nbsp;` | 空行，分隔逻辑段落 |
| 140 | `    // 先删除该书籍的所有章节，然后重新插入` | 注释说明：先删除该书籍的所有章节，然后重新插入 |
| 141 | `    // 这样可以避免由于 index 不同导致的重复记录` | 注释说明：这样可以避免由于 索引 不同导致的重复记录 |
| 142 | `    final bookUrl = chapters.first.bookUrl;` | 声明不可重新赋值的变量 书籍链接 |
| 143 | `    await db.delete(` | 调用 数据库.delete(...)（等待异步完成） → 删除 |
| 144 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 145 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 146 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 147 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 148 | `&nbsp;` | 空行，分隔逻辑段落 |
| 149 | `    final batch = db.batch();` | 声明不可重新赋值的变量 batch：调用 数据库.batch(...) → 批量 |
| 150 | `&nbsp;` | 空行，分隔逻辑段落 |
| 151 | `    for (final chapter in chapters) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 章节 属于(in) 章节列表 |
| 152 | `      batch.insert(` | 链式调用起始于 batch（批量），后续行继续该表达式：batch.插入( |
| 153 | `        'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 154 | `        _chapterToDbMap(chapter),` | 调用 _chapterToDbMap(...)：_chapterToDbMap(章节),（章节 To 数据库 映射） |
| 155 | `        conflictAlgorithm: ConflictAlgorithm.replace,` | 命名实参 conflictAlgorithm: ConflictAlgorithm.replace（conflict Algorithm） |
| 156 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 157 | `    }` | 闭合大括号，结束当前代码块 |
| 158 | `&nbsp;` | 空行，分隔逻辑段落 |
| 159 | `    await batch.commit(noResult: true);` | 调用 batch.提交(...)（等待异步完成） → 提交 |
| 160 | `  }` | 闭合大括号，结束当前代码块 |
| 161 | `&nbsp;` | 空行，分隔逻辑段落 |
| 162 | `  /// 获取本地章节列表` | 文档注释：说明其后代码的用途 |
| 163 | `  Future<List<BookChapter>> _getLocalChapters(String bookUrl) async {` | 【承接上方文档】获取本地章节列表 → 定义方法 _获取 本地 章节列表：返回 异步结果(Future)<列表(List)<章节(BookChapter)>>；位置参数 1 个；含命名参数；参数名: 书籍链接（异步）。语义：获取 本地 章节列表 |
| 164 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 165 | `    if (db == null) return [];` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) []; |
| 166 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 167 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 168 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 169 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 170 | `      orderBy: '"index" ASC',` | 命名实参 orderBy: '"索引" ASC'（顺序 By） |
| 171 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 172 | `    return result.map((json) => _chapterFromDbMap(json)).toList();` | 返回调用 结果.映射(map)(...) 的结果（语义：映射） |
| 173 | `  }` | 闭合大括号，结束当前代码块 |
| 174 | `&nbsp;` | 空行，分隔逻辑段落 |
| 175 | `  /// 从数据库获取指定索引的章节（参考项目：bookChapterDao.getChapter）` | 文档注释：说明其后代码的用途 |
| 176 | `  /// 确保返回的章节的 index 字段与请求的索引一致` | 文档注释：说明其后代码的用途 |
| 177 | `  Future<BookChapter?> getChapterByIndex(String bookUrl, int index) async {` | 【承接上方文档】从数据库获取指定索引的章节（参考项目：bookChapterDao.获取 章节） 确保返回的章节的 索引 字段与请求的索引一致 → 定义方法 getChapterByIndex：返回 异步结果(Future)<章节(BookChapter)?>；位置参数 2 个；含命名参数；参数名: 书籍链接, 索引（异步）。语义：获取 章节 By 索引 |
| 178 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 179 | `    if (db == null) return null;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 空值(null); |
| 180 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 181 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 182 | `      where: 'bookUrl = ? AND "index" = ?',` | 命名实参 筛选(where): '书籍链接 = ? AND "索引" = ?'（筛选(筛选(where))） |
| 183 | `      whereArgs: [bookUrl, index],` | 命名实参 筛选(where) 实参列表: [书籍链接, 索引]（筛选(筛选(where)) 实参列表） |
| 184 | `      limit: 1,` | 命名实参 limit: 1（限制） |
| 185 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 186 | `    if (result.isEmpty) return null;` | 条件判断 如果(if)：结果.是否为空) 返回(return) 空值(null); |
| 187 | `    return _chapterFromDbMap(result.first);` | 返回调用 _chapterFromDbMap(...) 的结果（语义：章节 From 数据库 映射） |
| 188 | `  }` | 闭合大括号，结束当前代码块 |
| 189 | `&nbsp;` | 空行，分隔逻辑段落 |
| 190 | `  /// Book转数据库Map` | 文档注释：说明其后代码的用途 |
| 191 | `  Map<String, dynamic> _bookToDbMap(Book book) {` | 【承接上方文档】书籍(Book)转数据库映射(Map) → 定义方法 _bookToDbMap：返回 映射(Map)<字符串(String), dynamic>；位置参数 1 个。语义：书籍 To 数据库 映射 |
| 192 | `    return {` | 返回 {（映射(Map)/集合字面量） |
| 193 | `      'bookUrl': book.bookUrl,` | 映射(Map) 条目 '书籍链接': 书籍.书籍链接, |
| 194 | `      'tocUrl': book.tocUrl,` | 映射(Map) 条目 '目录(TOC) URL': 书籍.目录(TOC) URL, |
| 195 | `      'origin': book.origin,` | 映射(Map) 条目 '来源': 书籍.来源, |
| 196 | `      'originName': book.originName,` | 映射(Map) 条目 '来源 名称': 书籍.来源 名称, |
| 197 | `      'name': book.name,` | 映射(Map) 条目 '名称': 书籍.名称, |
| 198 | `      'author': book.author,` | 映射(Map) 条目 '作者': 书籍.作者, |
| 199 | `      'kind': book.kind,` | 映射(Map) 条目 '类别': 书籍.类别, |
| 200 | `      'customTag': book.customTag,` | 映射(Map) 条目 'customTag': 书籍.customTag, |
| 201 | `      'coverUrl': book.coverUrl,` | 映射(Map) 条目 '封面链接': 书籍.封面链接, |
| 202 | `      'customCoverUrl': book.customCoverUrl,` | 映射(Map) 条目 '自定义 封面 URL': 书籍.自定义 封面 URL, |
| 203 | `      'intro': book.intro,` | 映射(Map) 条目 '简介': 书籍.简介, |
| 204 | `      'customIntro': book.customIntro,` | 映射(Map) 条目 '自定义 简介': 书籍.自定义 简介, |
| 205 | `      'charset': book.charset,` | 映射(Map) 条目 '字符集': 书籍.字符集, |
| 206 | `      'type': book.type,` | 映射(Map) 条目 '类型': 书籍.类型, |
| 207 | `      'group': book.group,` | 映射(Map) 条目 '捕获组': 书籍.捕获组, |
| 208 | `      'latestChapterTitle': book.latestChapterTitle,` | 映射(Map) 条目 'latestChapterTitle': 书籍.latestChapterTitle, |
| 209 | `      'latestChapterTime': book.latestChapterTime,` | 映射(Map) 条目 'latestChapterTime': 书籍.latestChapterTime, |
| 210 | `      'lastCheckTime': book.lastCheckTime,` | 映射(Map) 条目 'lastCheckTime': 书籍.lastCheckTime, |
| 211 | `      'lastCheckCount': book.lastCheckCount,` | 映射(Map) 条目 '最后 检查 数量': 书籍.最后 检查 数量, |
| 212 | `      'totalChapterNum': book.totalChapterNum,` | 映射(Map) 条目 'totalChapterNum': 书籍.totalChapterNum, |
| 213 | `      'durChapterTitle': book.durChapterTitle,` | 映射(Map) 条目 'durChapterTitle': 书籍.durChapterTitle, |
| 214 | `      'durChapterIndex': book.durChapterIndex,` | 映射(Map) 条目 'durChapterIndex': 书籍.durChapterIndex, |
| 215 | `      'durChapterPos': book.durChapterPos,` | 映射(Map) 条目 'durChapterPos': 书籍.durChapterPos, |
| 216 | `      'durChapterTime': book.durChapterTime,` | 映射(Map) 条目 'durChapterTime': 书籍.durChapterTime, |
| 217 | `      'wordCount': book.wordCount,` | 映射(Map) 条目 '字数': 书籍.字数, |
| 218 | `      'canUpdate': book.canUpdate ? 1 : 0,` | 映射(Map) 条目 'canUpdate': 书籍.canUpdate ? 1 : 0, |
| 219 | `      'order': book.order,` | 映射(Map) 条目 '顺序': 书籍.顺序, |
| 220 | `      'originOrder': book.originOrder,` | 映射(Map) 条目 '来源 顺序': 书籍.来源 顺序, |
| 221 | `      'variable': book.variable,` | 映射(Map) 条目 'variable': 书籍.variable, |
| 222 | `      'readConfig': book.readConfig != null` | 上一表达式的续行：'读取 配置': 书籍.读取 配置 != 空值(null) |
| 223 | `          ? jsonEncode(book.readConfig!.toJson())` | 三元表达式为真时取值：JSON 编码(书籍.读取 配置!.toJson()) |
| 224 | `          : null,` | 三元表达式为假时取值：空值(null), |
| 225 | `      'syncTime': book.syncTime,` | 映射(Map) 条目 'syncTime': 书籍.syncTime, |
| 226 | `    };` | 闭合代码块并衔接后续语句：; |
| 227 | `  }` | 闭合大括号，结束当前代码块 |
| 228 | `&nbsp;` | 空行，分隔逻辑段落 |
| 229 | `  /// 数据库Map转Book` | 文档注释：说明其后代码的用途 |
| 230 | `  Book _bookFromDbMap(Map<String, dynamic> map) {` | 【承接上方文档】数据库映射(Map)转书籍(Book) → 定义方法 _bookFromDbMap：返回 书籍(Book)；位置参数 2 个；参数名: 字符串(String)。语义：书籍 From 数据库 映射 |
| 231 | `    return Book(` | 返回调用 书籍(Book)(...) 的结果（语义：书籍） |
| 232 | `      bookUrl: map['bookUrl'] ?? '',` | 命名实参 书籍链接: 映射(map)['书籍链接'] ?? ''（书籍 统一资源链接(URL)） |
| 233 | `      tocUrl: map['tocUrl'] ?? '',` | 命名实参 目录(TOC) URL: 映射(map)['目录(TOC) URL'] ?? ''（目录(目录(TOC)) 统一资源链接(URL)） |
| 234 | `      origin: map['origin'] ?? BookType.localTag,` | 命名实参 来源: 映射(map)['来源'] ?? 书籍 类型.localTag（来源） |
| 235 | `      originName: map['originName'] ?? '',` | 命名实参 来源 名称: 映射(map)['来源 名称'] ?? ''（来源 名称） |
| 236 | `      name: map['name'] ?? '',` | 命名实参 名称: 映射(map)['名称'] ?? ''（名称） |
| 237 | `      author: map['author'] ?? '',` | 命名实参 作者: 映射(map)['作者'] ?? ''（作者） |
| 238 | `      kind: map['kind'],` | 命名实参 类别: 映射(map)['类别']（类别） |
| 239 | `      customTag: map['customTag'],` | 命名实参 customTag: 映射(map)['customTag']（自定义 Tag） |
| 240 | `      coverUrl: map['coverUrl'],` | 命名实参 封面链接: 映射(map)['封面链接']（封面 统一资源链接(URL)） |
| 241 | `      customCoverUrl: map['customCoverUrl'],` | 命名实参 自定义 封面 URL: 映射(map)['自定义 封面 URL']（自定义 封面 统一资源链接(URL)） |
| 242 | `      intro: map['intro'],` | 命名实参 简介: 映射(map)['简介']（简介） |
| 243 | `      customIntro: map['customIntro'],` | 命名实参 自定义 简介: 映射(map)['自定义 简介']（自定义 简介） |
| 244 | `      charset: map['charset'],` | 命名实参 字符集: 映射(map)['字符集']（字符集） |
| 245 | `      type: map['type'] ?? BookType.text,` | 命名实参 类型: 映射(map)['类型'] ?? 书籍 类型.文本（类型） |
| 246 | `      group: map['group'] ?? 0,` | 命名实参 捕获组: 映射(map)['捕获组'] ?? 0（捕获组） |
| 247 | `      latestChapterTitle: map['latestChapterTitle'],` | 命名实参 latestChapterTitle: 映射(map)['latestChapterTitle']（latest 章节 标题） |
| 248 | `      latestChapterTime: map['latestChapterTime'] ?? 0,` | 命名实参 latestChapterTime: 映射(map)['latestChapterTime'] ?? 0（latest 章节 Time） |
| 249 | `      lastCheckTime: map['lastCheckTime'] ?? 0,` | 命名实参 lastCheckTime: 映射(map)['lastCheckTime'] ?? 0（最后 检查 Time） |
| 250 | `      lastCheckCount: map['lastCheckCount'] ?? 0,` | 命名实参 最后 检查 数量: 映射(map)['最后 检查 数量'] ?? 0（最后 检查 数量） |
| 251 | `      totalChapterNum: map['totalChapterNum'] ?? 0,` | 命名实参 totalChapterNum: 映射(map)['totalChapterNum'] ?? 0（total 章节 编号） |
| 252 | `      durChapterTitle: map['durChapterTitle'],` | 命名实参 durChapterTitle: 映射(map)['durChapterTitle']（dur 章节 标题） |
| 253 | `      durChapterIndex: map['durChapterIndex'] ?? 0,` | 命名实参 durChapterIndex: 映射(map)['durChapterIndex'] ?? 0（dur 章节 索引） |
| 254 | `      durChapterPos: map['durChapterPos'] ?? 0,` | 命名实参 durChapterPos: 映射(map)['durChapterPos'] ?? 0（dur 章节 位置） |
| 255 | `      durChapterTime: map['durChapterTime'] ?? 0,` | 命名实参 durChapterTime: 映射(map)['durChapterTime'] ?? 0（dur 章节 Time） |
| 256 | `      wordCount: map['wordCount'],` | 命名实参 字数: 映射(map)['字数']（单词 数量） |
| 257 | `      canUpdate: map['canUpdate'] == 1,` | 命名实参 canUpdate: 映射(map)['canUpdate'] == 1（can 更新） |
| 258 | `      order: map['order'] ?? 0,` | 命名实参 顺序: 映射(map)['顺序'] ?? 0（顺序） |
| 259 | `      originOrder: map['originOrder'] ?? 0,` | 命名实参 来源 顺序: 映射(map)['来源 顺序'] ?? 0（来源 顺序） |
| 260 | `      variable: map['variable'],` | 命名实参 variable: 映射(map)['variable']（变量） |
| 261 | `      readConfig: map['readConfig'] != null` | 上一表达式的续行：读取 配置: 映射(map)['读取 配置'] != 空值(null) |
| 262 | `          ? ReadConfig.fromJson(jsonDecode(map['readConfig']))` | 三元表达式为真时取值：读取 配置.fromJson(JSON 解码(映射(map)['读取 配置'])) |
| 263 | `          : null,` | 三元表达式为假时取值：空值(null), |
| 264 | `      syncTime: map['syncTime'] ?? 0,` | 命名实参 syncTime: 映射(map)['syncTime'] ?? 0（同步 Time） |
| 265 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 266 | `  }` | 闭合大括号，结束当前代码块 |
| 267 | `&nbsp;` | 空行，分隔逻辑段落 |
| 268 | `  /// BookChapter转数据库Map` | 文档注释：说明其后代码的用途 |
| 269 | `  Map<String, dynamic> _chapterToDbMap(BookChapter chapter) {` | 【承接上方文档】章节(BookChapter)转数据库映射(Map) → 定义方法 _chapterToDbMap：返回 映射(Map)<字符串(String), dynamic>；位置参数 1 个。语义：章节 To 数据库 映射 |
| 270 | `    return {` | 返回 {（映射(Map)/集合字面量） |
| 271 | `      'url': chapter.url,` | 映射(Map) 条目 '链接': 章节.链接, |
| 272 | `      'bookUrl': chapter.bookUrl,` | 映射(Map) 条目 '书籍链接': 章节.书籍链接, |
| 273 | `      'title': chapter.title,` | 映射(Map) 条目 '标题': 章节.标题, |
| 274 | `      'isVolume': chapter.isVolume ? 1 : 0,` | 映射(Map) 条目 'isVolume': 章节.isVolume ? 1 : 0, |
| 275 | `      'baseUrl': chapter.baseUrl,` | 映射(Map) 条目 '基础链接': 章节.基础链接, |
| 276 | `      'index': chapter.index,` | 映射(Map) 条目 '索引': 章节.索引, |
| 277 | `      'isVip': chapter.isVip ? 1 : 0,` | 映射(Map) 条目 'isVip': 章节.isVip ? 1 : 0, |
| 278 | `      'isPay': chapter.isPay ? 1 : 0,` | 映射(Map) 条目 'isPay': 章节.isPay ? 1 : 0, |
| 279 | `      'resourceUrl': chapter.resourceUrl,` | 映射(Map) 条目 'resourceUrl': 章节.resourceUrl, |
| 280 | `      'tag': chapter.tag,` | 映射(Map) 条目 'tag': 章节.tag, |
| 281 | `      'wordCount': chapter.wordCount,` | 映射(Map) 条目 '字数': 章节.字数, |
| 282 | `      'start': chapter.start,` | 映射(Map) 条目 '起始': 章节.起始, |
| 283 | `      'end': chapter.end,` | 映射(Map) 条目 'end': 章节.end, |
| 284 | `      'startFragmentId': chapter.startFragmentId,` | 映射(Map) 条目 'startFragmentId': 章节.startFragmentId, |
| 285 | `      'endFragmentId': chapter.endFragmentId,` | 映射(Map) 条目 'endFragmentId': 章节.endFragmentId, |
| 286 | `      'variable': chapter.variable,` | 映射(Map) 条目 'variable': 章节.variable, |
| 287 | `    };` | 闭合代码块并衔接后续语句：; |
| 288 | `  }` | 闭合大括号，结束当前代码块 |
| 289 | `&nbsp;` | 空行，分隔逻辑段落 |
| 290 | `  /// 数据库Map转BookChapter` | 文档注释：说明其后代码的用途 |
| 291 | `  BookChapter _chapterFromDbMap(Map<String, dynamic> map) {` | 【承接上方文档】数据库映射(Map)转章节(BookChapter) → 定义方法 _chapterFromDbMap：返回 章节(BookChapter)；位置参数 2 个；参数名: 字符串(String)。语义：章节 From 数据库 映射 |
| 292 | `    return BookChapter(` | 返回调用 章节(BookChapter)(...) 的结果（语义：书籍 章节） |
| 293 | `      url: map['url'] ?? '',` | 命名实参 链接: 映射(map)['链接'] ?? ''（统一资源链接(URL)） |
| 294 | `      title: map['title'] ?? '',` | 命名实参 标题: 映射(map)['标题'] ?? ''（标题） |
| 295 | `      isVolume: map['isVolume'] == 1,` | 命名实参 isVolume: 映射(map)['isVolume'] == 1（是(is) 体积） |
| 296 | `      baseUrl: map['baseUrl'] ?? '',` | 命名实参 基础链接: 映射(map)['基础链接'] ?? ''（base 统一资源链接(URL)） |
| 297 | `      bookUrl: map['bookUrl'] ?? '',` | 命名实参 书籍链接: 映射(map)['书籍链接'] ?? ''（书籍 统一资源链接(URL)） |
| 298 | `      index: map['index'] ?? 0,` | 命名实参 索引: 映射(map)['索引'] ?? 0（索引） |
| 299 | `      isVip: map['isVip'] == 1,` | 命名实参 isVip: 映射(map)['isVip'] == 1（是(is) Vip） |
| 300 | `      isPay: map['isPay'] == 1,` | 命名实参 isPay: 映射(map)['isPay'] == 1（是(is) Pay） |
| 301 | `      resourceUrl: map['resourceUrl'],` | 命名实参 resourceUrl: 映射(map)['resourceUrl']（resource 统一资源链接(URL)） |
| 302 | `      tag: map['tag'],` | 命名实参 tag: 映射(map)['tag'] |
| 303 | `      wordCount: map['wordCount'],` | 命名实参 字数: 映射(map)['字数']（单词 数量） |
| 304 | `      start: map['start'],` | 命名实参 起始: 映射(map)['起始']（起始） |
| 305 | `      end: map['end'],` | 命名实参 end: 映射(map)['end'] |
| 306 | `      startFragmentId: map['startFragmentId'],` | 命名实参 startFragmentId: 映射(map)['startFragmentId']（起始 Fragment 编号(编号(id))） |
| 307 | `      endFragmentId: map['endFragmentId'],` | 命名实参 endFragmentId: 映射(map)['endFragmentId']（end Fragment 编号(编号(id))） |
| 308 | `      variable: map['variable'],` | 命名实参 variable: 映射(map)['variable']（变量） |
| 309 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 310 | `  }` | 闭合大括号，结束当前代码块 |
| 311 | `&nbsp;` | 空行，分隔逻辑段落 |
| 312 | `  /// 更新书籍排序` | 文档注释：说明其后代码的用途 |
| 313 | `  Future<void> updateBookOrder(String bookUrl, int order) async {` | 【承接上方文档】更新书籍排序 → 定义方法 更新 书籍 顺序：返回 异步结果(Future)<无返回值(void)>；位置参数 2 个；含命名参数；参数名: 书籍链接, 顺序（异步）。语义：更新 书籍 顺序 |
| 314 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 315 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 316 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 317 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 318 | `      {'order': order},` | {'顺序': 顺序}, |
| 319 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 320 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 321 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 322 | `  }` | 闭合大括号，结束当前代码块 |
| 323 | `&nbsp;` | 空行，分隔逻辑段落 |
| 324 | `  /// 更新书籍信息` | 文档注释：说明其后代码的用途 |
| 325 | `  Future<void> updateBook(Book book) async {` | 【承接上方文档】更新书籍信息 → 定义方法 更新 书籍：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 书籍（异步）。语义：更新 书籍 |
| 326 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 327 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 328 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 329 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 330 | `      _bookToDbMap(book),` | 调用 _bookToDbMap(...)：_bookToDbMap(书籍),（书籍 To 数据库 映射） |
| 331 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 332 | `      whereArgs: [book.bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍.书籍链接]（筛选(筛选(where)) 实参列表） |
| 333 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 334 | `  }` | 闭合大括号，结束当前代码块 |
| 335 | `&nbsp;` | 空行，分隔逻辑段落 |
| 336 | `  /// 更新章节字数` | 文档注释：说明其后代码的用途 |
| 337 | `  /// 参考项目：BookService.updateChapterWordCount` | 文档注释：说明其后代码的用途 |
| 338 | `  Future<void> updateChapterWordCount(BookChapter chapter) async {` | 【承接上方文档】更新章节字数 参考项目：书籍 服务.更新 章节 单词 数量 → 定义方法 更新 章节 单词 数量：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 章节（异步）。语义：更新 章节 单词 数量 |
| 339 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 340 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 341 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 342 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 343 | `      {'wordCount': chapter.wordCount},` | {'字数': 章节.字数}, |
| 344 | `      where: 'url = ? AND bookUrl = ?',` | 命名实参 筛选(where): '链接 = ? AND 书籍链接 = ?'（筛选(筛选(where))） |
| 345 | `      whereArgs: [chapter.url, chapter.bookUrl],` | 命名实参 筛选(where) 实参列表: [章节.链接, 章节.书籍链接]（筛选(筛选(where)) 实参列表） |
| 346 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 347 | `  }` | 闭合大括号，结束当前代码块 |
| 348 | `&nbsp;` | 空行，分隔逻辑段落 |
| 349 | `  /// 从数据库获取已存在的章节字数` | 文档注释：说明其后代码的用途 |
| 350 | `  /// 参考项目：BookChapterList.getWordCount（第272-286行）` | 文档注释：说明其后代码的用途 |
| 351 | `  Future<void> getWordCount(List<BookChapter> chapters, Book book) async {` | 【承接上方文档】从数据库获取已存在的章节字数 参考项目：书籍 章节 列表.获取 单词 数量（第272-286行） → 定义方法 获取 单词 数量：返回 异步结果(Future)<无返回值(void)>；位置参数 2 个；含命名参数；参数名: 章节列表, 书籍（异步）。语义：获取 单词 数量 |
| 352 | `    // 参考项目：如果 AppConfig.tocCountWords 为 false，不处理` | 注释说明：参考项目：如果 AppConfig.tocCountWords 为 假(false)，不处理 |
| 353 | `    // 这里暂时总是处理，如果需要可以从配置中读取` | 注释说明：这里暂时总是处理，如果需要可以从配置中读取 |
| 354 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 355 | `      final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 356 | `      if (db == null) return;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return); |
| 357 | `&nbsp;` | 空行，分隔逻辑段落 |
| 358 | `      // 从数据库获取已存在的章节列表` | 注释说明：从数据库获取已存在的章节列表 |
| 359 | `      final existingChapters = await _getLocalChapters(book.bookUrl);` | 声明不可重新赋值的变量 existingChapters：等待(await) 调用 _获取 本地 章节列表(...) → 获取 本地 章节列表 |
| 360 | `      if (existingChapters.isEmpty) return;` | 条件判断 如果(if)：existingChapters.是否为空) 返回(return); |
| 361 | `&nbsp;` | 空行，分隔逻辑段落 |
| 362 | `      // 创建章节文件名的映射（参考项目：associateBy）` | 注释说明：创建章节文件名的映射（参考项目：associateBy） |
| 363 | `      final wordCountMap = <String, String>{};` | 声明不可重新赋值的变量 单词 数量 映射 |
| 364 | `      for (final existingChapter in existingChapters) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) existingChapter 属于(in) existingChapters |
| 365 | `        final fileName = _getChapterFileName(existingChapter);` | 声明不可重新赋值的变量 文件(file) 名称：调用 _获取 章节 文件(file) 名称(...) → 获取 章节 文件(文件(file)) 名称 |
| 366 | `        if (existingChapter.wordCount != null &&` | 条件判断 如果(if)：existingChapter.字数 不等于 空值(null) 且 |
| 367 | `            existingChapter.wordCount!.isNotEmpty) {` | existingChapter.字数!.是否非空) { |
| 368 | `          wordCountMap[fileName] = existingChapter.wordCount!;` | 单词 数量 映射[文件(file) 名称] = existingChapter.字数! |
| 369 | `        }` | 闭合大括号，结束当前代码块 |
| 370 | `      }` | 闭合大括号，结束当前代码块 |
| 371 | `&nbsp;` | 空行，分隔逻辑段落 |
| 372 | `      // 更新章节字数` | 注释说明：更新章节字数 |
| 373 | `      for (final chapter in chapters) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 章节 属于(in) 章节列表 |
| 374 | `        final fileName = _getChapterFileName(chapter);` | 声明不可重新赋值的变量 文件(file) 名称：调用 _获取 章节 文件(file) 名称(...) → 获取 章节 文件(文件(file)) 名称 |
| 375 | `        final wordCount = wordCountMap[fileName];` | 声明不可重新赋值的变量 字数 |
| 376 | `        if (wordCount != null) {` | 条件判断 如果(if)：字数 不等于 空值(null) |
| 377 | `          chapter.wordCount = wordCount;` | 将 字数 赋值给 章节.字数 |
| 378 | `        }` | 闭合大括号，结束当前代码块 |
| 379 | `      }` | 闭合大括号，结束当前代码块 |
| 380 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 381 | `      AppLog.instance.put('获取章节字数失败: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节字数失败: $e', error: e); |
| 382 | `    }` | 闭合大括号，结束当前代码块 |
| 383 | `  }` | 闭合大括号，结束当前代码块 |
| 384 | `&nbsp;` | 空行，分隔逻辑段落 |
| 385 | `  /// 获取章节文件名（用于字数匹配）` | 文档注释：说明其后代码的用途 |
| 386 | `  /// 参考项目：BookChapter.getFileName` | 文档注释：说明其后代码的用途 |
| 387 | `  String _getChapterFileName(BookChapter chapter) {` | 【承接上方文档】获取章节文件名（用于字数匹配） 参考项目：章节(BookChapter).获取 文件(file) 名称 → 定义方法 _获取 章节 文件(file) 名称：返回 字符串(String)；位置参数 1 个。语义：获取 章节 文件(文件(file)) 名称 |
| 388 | `    // 参考项目：使用章节URL的MD5作为文件名` | 注释说明：参考项目：使用章节统一资源链接(URL)的MD5摘要作为文件名 |
| 389 | `    // 这里简化处理，使用章节索引和URL的组合` | 注释说明：这里简化处理，使用章节索引和统一资源链接(URL)的组合 |
| 390 | `    return '${chapter.index}_${chapter.url}';` | 返回 '${章节.索引}_${章节.链接}'（字符串字面量 '${章节.索引}_${章节.链接}'） |
| 391 | `  }` | 闭合大括号，结束当前代码块 |
| 392 | `&nbsp;` | 空行，分隔逻辑段落 |
| 393 | `  /// 更新章节的localPath字段` | 文档注释：说明其后代码的用途 |
| 394 | `  ///` | 文档注释：说明其后代码的用途 |
| 395 | `  /// 将章节内容文件路径更新到数据库` | 文档注释：说明其后代码的用途 |
| 396 | `  Future<void> _updateChapterLocalPath(` | 【承接上方文档】更新章节的本地存储路径字段  将章节内容文件路径更新到数据库 → 定义方法 _更新 章节 本地 路径：返回 异步结果(Future)<无返回值(void)>；无参数（异步）。语义：更新 章节 本地 路径 |
| 397 | `    String bookUrl,` | 字符串(String) 类型参数 书籍链接（书籍 统一资源链接(URL)） |
| 398 | `    String chapterUrl,` | 字符串(String) 类型参数 章节链接（章节 统一资源链接(URL)） |
| 399 | `    String localPath,` | 字符串(String) 类型参数 本地存储路径（本地 路径） |
| 400 | `  ) async {` | ) 异步(async) { |
| 401 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 402 | `      final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 403 | `      if (db == null) return;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return); |
| 404 | `&nbsp;` | 空行，分隔逻辑段落 |
| 405 | `      await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 406 | `        'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 407 | `        {'localPath': localPath},` | {'本地存储路径': 本地存储路径}, |
| 408 | `        where: 'bookUrl = ? AND url = ?',` | 命名实参 筛选(where): '书籍链接 = ? AND 链接 = ?'（筛选(筛选(where))） |
| 409 | `        whereArgs: [bookUrl, chapterUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接, 章节链接]（筛选(筛选(where)) 实参列表） |
| 410 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 411 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 412 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 413 | `        '更新章节localPath失败: bookUrl=$bookUrl, url=$chapterUrl',` | 以字符串 '更新章节本地存储路径失败: 书籍链接=$书籍链接, 链接=… 起始的表达式：, |
| 414 | `        error: e,` | 命名实参 错误: 异常对象 e（错误） |
| 415 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 416 | `    }` | 闭合大括号，结束当前代码块 |
| 417 | `  }` | 闭合大括号，结束当前代码块 |
| 418 | `&nbsp;` | 空行，分隔逻辑段落 |
| 419 | `  // ── Phase 3：辅助工具方法 ────────────────────────────────────────────────` | 注释说明：── 相位 3：辅助工具方法 ──────────────────────────────────────────────── |
| 420 | `&nbsp;` | 空行，分隔逻辑段落 |
| 421 | `  /// 将时长字符串解析为秒数（int）` | 文档注释：说明其后代码的用途 |
| 422 | `  ///` | 文档注释：说明其后代码的用途 |
| 423 | `  /// 支持三种格式：` | 文档注释：说明其后代码的用途 |
| 424 | `  ///   - 纯秒数字符串：`"1800"` → 1800` | 文档注释：说明其后代码的用途 |
| 425 | `  ///   - MM:SS 格式：`"30:00"` → 1800` | 文档注释：说明其后代码的用途 |
| 426 | `  ///   - HH:MM:SS 格式：`"00:30:00"` → 1800` | 文档注释：说明其后代码的用途 |
| 427 | `  ///` | 文档注释：说明其后代码的用途 |
| 428 | `  /// 解析失败或输入为空时返回 null。` | 文档注释：说明其后代码的用途 |
| 429 | `  static int? _parseDurationString(String? raw) {` | 【承接上方文档】将时长字符串解析为秒数（整数(int)）  支持三种格式： - 纯秒数字符串：`"1800"` → 1800 - MM:SS 格式：`"30:00"` → 1800 - → 定义静态方法 _解析 时长 字符串(String)：返回 整数(int)?；位置参数 1 个。语义：解析 时长 字符串(字符串(String)) |
| 430 | `    if (raw == null \|\| raw.trim().isEmpty) return null;` | 条件判断 如果(if)：原始 等于 空值(null) 或 原始.去除首尾空白().是否为空) 返回(return) 空值(null); |
| 431 | `    final trimmed = raw.trim();` | 声明不可重新赋值的变量 trimmed：调用 原始.去除首尾空白(...) → 修剪 |
| 432 | `&nbsp;` | 空行，分隔逻辑段落 |
| 433 | `    // 尝试 HH:MM:SS 或 MM:SS 格式` | 注释说明：尝试 HH:MM:SS 或 MM:SS 格式 |
| 434 | `    final parts = trimmed.split(':');` | 声明不可重新赋值的变量 parts：调用 trimmed.切分(...) → 切分 |
| 435 | `    if (parts.length == 2) {` | 条件判断 如果(if)：parts.长度(length) 等于 2 |
| 436 | `      // MM:SS` | 注释说明：MM:SS |
| 437 | `      final minutes = int.tryParse(parts[0]);` | 声明不可重新赋值的变量 minutes：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 438 | `      final seconds = int.tryParse(parts[1]);` | 声明不可重新赋值的变量 seconds：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 439 | `      if (minutes != null && seconds != null) {` | 条件判断 如果(if)：minutes 不等于 空值(null) 且 seconds 不等于 空值(null) |
| 440 | `        return minutes * 60 + seconds;` | 返回 minutes * 60 + seconds |
| 441 | `      }` | 闭合大括号，结束当前代码块 |
| 442 | `    } else if (parts.length == 3) {` | 闭合上一代码块并开始 否则(else) 如果(if) (parts.长度(length) == 3) { |
| 443 | `      // HH:MM:SS` | 注释说明：HH:MM:SS |
| 444 | `      final hours = int.tryParse(parts[0]);` | 声明不可重新赋值的变量 hours：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 445 | `      final minutes = int.tryParse(parts[1]);` | 声明不可重新赋值的变量 minutes：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 446 | `      final seconds = int.tryParse(parts[2]);` | 声明不可重新赋值的变量 seconds：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 447 | `      if (hours != null && minutes != null && seconds != null) {` | 条件判断 如果(if)：hours 不等于 空值(null) 且 minutes 不等于 空值(null) 且 seconds 不等于 空值(null) |
| 448 | `        return hours * 3600 + minutes * 60 + seconds;` | 返回 hours * 3600 + minutes * 60 + seconds |
| 449 | `      }` | 闭合大括号，结束当前代码块 |
| 450 | `    }` | 闭合大括号，结束当前代码块 |
| 451 | `&nbsp;` | 空行，分隔逻辑段落 |
| 452 | `    // 尝试纯数字（秒数）` | 注释说明：尝试纯数字（秒数） |
| 453 | `    return int.tryParse(trimmed);` | 返回调用 整数(int).tryParse(...) 的结果（语义：尝试(try) 解析） |
| 454 | `  }` | 闭合大括号，结束当前代码块 |
