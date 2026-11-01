# book_service_update.dart 逐行注释

> 源文件：`lib/services/book/book_service_update.dart`（共 279 行）
>
> 本文件由 `scripts/gen_line_annotations.py` 自动生成，对源文件每一行给出独立说明。
> 说明优先采用源码自带的中文注释；无注释的行依据 Dart 语法特征自动生成解释。

| 行号 | 源代码 | 说明 |
| ---: | --- | --- |
| 1 | `part of 'book_service.dart';` | 声明本文件是 书籍 服务.dart 库的一部分(分部文件(part))，与其共享同一命名空间 |
| 2 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 4 | `// BookService 职责：书架目录更新、按 URL/书名添加书籍、导入书单。` | 注释说明：书籍 服务 职责：书架目录更新、按 统一资源链接(URL)/书名添加书籍、导入书单。 |
| 5 | `// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）` | 注释说明：（分部文件(part) 文件，与主文件 书籍 服务.dart 共享同一 Dart 库，可访问私有符号） |
| 6 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 7 | `&nbsp;` | 空行，分隔逻辑段落 |
| 8 | `  Future<bool> updateChapterList(Book book) async {` | 定义方法 更新 章节 列表：返回 异步结果(Future)<布尔(bool)>；位置参数 1 个；含命名参数；参数名: 书籍（异步）。语义：更新 章节 列表 |
| 9 | `    if (book.isLocal \|\| !book.canUpdate) {` | 条件判断 如果(if)：书籍.isLocal 或 !书籍.canUpdate |
| 10 | `      return false;` | 返回 假(false)（布尔值 假(false)） |
| 11 | `    }` | 闭合大括号，结束当前代码块 |
| 12 | `&nbsp;` | 空行，分隔逻辑段落 |
| 13 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 14 | `      final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 15 | `      if (db == null) return false;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 假(false); |
| 16 | `&nbsp;` | 空行，分隔逻辑段落 |
| 17 | `      // 先获取书籍信息（如果需要）` | 注释说明：先获取书籍信息（如果需要） |
| 18 | `      final updatedBook = await getBookInfo(book);` | 声明不可重新赋值的变量 已更新 书籍：等待(await) 调用 getBookInfo(...) → 获取 书籍 Info |
| 19 | `      if (updatedBook == null) return false;` | 条件判断 如果(if)：已更新 书籍 等于 空值(null)) 返回(return) 假(false); |
| 20 | `&nbsp;` | 空行，分隔逻辑段落 |
| 21 | `      // 使用 getChapterList 方法获取所有章节（支持分页）` | 注释说明：使用 获取 章节 列表 方法获取所有章节（支持分页） |
| 22 | `      final chapters = await getChapterList(updatedBook);` | 声明不可重新赋值的变量 章节列表：等待(await) 调用 获取 章节 列表(...) → 获取 章节 列表 |
| 23 | `&nbsp;` | 空行，分隔逻辑段落 |
| 24 | `      if (chapters.isEmpty) {` | 条件判断 如果(if)：章节列表.是否为空 |
| 25 | `        return false;` | 返回 假(false)（布尔值 假(false)） |
| 26 | `      }` | 闭合大括号，结束当前代码块 |
| 27 | `&nbsp;` | 空行，分隔逻辑段落 |
| 28 | `      // 更新书籍信息` | 注释说明：更新书籍信息 |
| 29 | `      await saveBook(updatedBook.copyWith(` | 调用 保存 书籍(...)（等待异步完成） → 保存 书籍 |
| 30 | `        totalChapterNum: chapters.length,` | 命名实参 totalChapterNum: 章节列表.长度(length)（total 章节 编号） |
| 31 | `        lastCheckTime: DateTime.now().millisecondsSinceEpoch,` | 命名实参 lastCheckTime: DateTime.now().millisecondsSinceEpoch（最后 检查 Time） |
| 32 | `        latestChapterTitle: chapters.isNotEmpty ? chapters.last.title : null,` | 命名实参 latestChapterTitle: 章节列表.是否非空 ? 章节列表.last.标题 : 空值(null)（latest 章节 标题） |
| 33 | `      ));` | 闭合语句结尾，结束当前调用/字面量/块 |
| 34 | `&nbsp;` | 空行，分隔逻辑段落 |
| 35 | `      return true;` | 返回 真(true)（布尔值 真(true)） |
| 36 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 37 | `      AppLog.instance.put('更新目录失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('更新目录失败', error: e); |
| 38 | `      return false;` | 返回 假(false)（布尔值 假(false)） |
| 39 | `    }` | 闭合大括号，结束当前代码块 |
| 40 | `  }` | 闭合大括号，结束当前代码块 |
| 41 | `&nbsp;` | 空行，分隔逻辑段落 |
| 42 | `  /// 批量更新目录` | 文档注释：说明其后代码的用途 |
| 43 | `  Future<Map<String, bool>> updateChapterLists(List<Book> books) async {` | 【承接上方文档】批量更新目录 → 定义方法 更新 章节 列表集合：返回 异步结果(Future)<映射(Map)<字符串(String), 布尔(bool)>>；位置参数 1 个；含命名参数；参数名: 书籍列表（异步）。语义：更新 章节 列表集合 |
| 44 | `    final results = <String, bool>{};` | 声明不可重新赋值的变量 结果 |
| 45 | `&nbsp;` | 空行，分隔逻辑段落 |
| 46 | `    // 过滤出可以更新的网络书籍` | 注释说明：过滤出可以更新的网络书籍 |
| 47 | `    final booksToUpdate =` | 上一表达式的续行：不可重新赋值(final) booksToUpdate = |
| 48 | `        books.where((book) => !book.isLocal && book.canUpdate).toList();` | 链式调用起始于 书籍列表（书籍列表），后续行继续该表达式：书籍列表.筛选(where)((书籍) => !书籍.isLocal && 书籍.canUpdate).转为列表(); |
| 49 | `&nbsp;` | 空行，分隔逻辑段落 |
| 50 | `    for (final book in booksToUpdate) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 书籍 属于(in) booksToUpdate |
| 51 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 52 | `        final success = await updateChapterList(book);` | 声明不可重新赋值的变量 成功：等待(await) 调用 更新 章节 列表(...) → 更新 章节 列表 |
| 53 | `        results[book.bookUrl] = success;` | 结果[书籍.书籍链接] = 成功 |
| 54 | `      } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 55 | `        results[book.bookUrl] = false;` | 结果[书籍.书籍链接] = 假(false) |
| 56 | `      }` | 闭合大括号，结束当前代码块 |
| 57 | `    }` | 闭合大括号，结束当前代码块 |
| 58 | `&nbsp;` | 空行，分隔逻辑段落 |
| 59 | `    return results;` | 返回 结果 |
| 60 | `  }` | 闭合大括号，结束当前代码块 |
| 61 | `&nbsp;` | 空行，分隔逻辑段落 |
| 62 | `  /// 通过URL添加书籍` | 文档注释：说明其后代码的用途 |
| 63 | `  Future<int> addBookByUrl(String bookUrls, {int? groupId}) async {` | 【承接上方文档】通过统一资源链接(URL)添加书籍 → 定义方法 addBookByUrl：返回 异步结果(Future)<整数(int)>；位置参数 1 个；含命名参数；参数名: bookUrls, 捕获组 编号(id)（异步）。语义：添加 书籍 By 统一资源链接(URL) |
| 64 | `    int successCount = 0;` | 整数(int) 成功 数量 = 0 |
| 65 | `    final urls = bookUrls.split('\n');` | 声明不可重新赋值的变量 urls：调用 bookUrls.切分(...) → 切分 |
| 66 | `&nbsp;` | 空行，分隔逻辑段落 |
| 67 | `    for (final url in urls) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 链接 属于(in) urls |
| 68 | `      final bookUrl = url.trim();` | 声明不可重新赋值的变量 书籍链接：调用 链接.去除首尾空白(...) → 修剪 |
| 69 | `      if (bookUrl.isEmpty) continue;` | 条件判断 如果(if)：书籍链接.是否为空) 继续(continue); |
| 70 | `&nbsp;` | 空行，分隔逻辑段落 |
| 71 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 72 | `        // 检查书籍是否已存在` | 注释说明：检查书籍是否已存在 |
| 73 | `        final existingBook = await getBookByUrl(bookUrl);` | 声明不可重新赋值的变量 existingBook：等待(await) 调用 getBookByUrl(...) → 获取 书籍 By 统一资源链接(URL) |
| 74 | `        if (existingBook != null) {` | 条件判断 如果(if)：existingBook 不等于 空值(null) |
| 75 | `          successCount++;` | 成功 数量++ |
| 76 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 77 | `        }` | 闭合大括号，结束当前代码块 |
| 78 | `&nbsp;` | 空行，分隔逻辑段落 |
| 79 | `        // 获取baseUrl` | 注释说明：获取基础链接 |
| 80 | `        final uri = Uri.tryParse(bookUrl);` | 声明不可重新赋值的变量 uri：调用 统一资源标识(URI).tryParse(...) → 尝试(try) 解析 |
| 81 | `        if (uri == null) continue;` | 条件判断 如果(if)：uri 等于 空值(null)) 继续(continue); |
| 82 | `        final baseUrl = '${uri.scheme}://${uri.host}';` | 声明不可重新赋值的变量 基础链接：字符串字面量 '${uri.scheme}://${uri.主机}'; |
| 83 | `&nbsp;` | 空行，分隔逻辑段落 |
| 84 | `        // 查找匹配的书源` | 注释说明：查找匹配的书源 |
| 85 | `        BookSource? source =` | 上一表达式的续行：书源(BookSource)? 书源 = |
| 86 | `            await _bookSourceService.getBookSourceByUrl(baseUrl);` | 调用 _书籍 书源 服务.getBookSourceByUrl(...)（等待异步完成） → 获取 书籍 书源 By 统一资源链接(URL) |
| 87 | `&nbsp;` | 空行，分隔逻辑段落 |
| 88 | `        // 如果没找到，尝试通过bookUrlPattern匹配` | 注释说明：如果没找到，尝试通过书籍 URL 模式匹配 |
| 89 | `        if (source == null) {` | 条件判断 如果(if)：书源 等于 空值(null) |
| 90 | `          final allSources =` | 上一表达式的续行：不可重新赋值(final) 全部 书源列表 = |
| 91 | `              await _bookSourceService.getAllBookSources(enabledOnly: true);` | 调用 _书籍 书源 服务.获取 全部 书籍 书源列表(...)（等待异步完成） → 获取 全部 书籍 书源列表 |
| 92 | `          for (final s in allSources) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) s 属于(in) 全部 书源列表 |
| 93 | `            if (s.bookUrlPattern != null && s.bookUrlPattern!.isNotEmpty) {` | 条件判断 如果(if)：s.书籍 URL 模式 不等于 空值(null) 且 s.书籍 URL 模式!.是否非空 |
| 94 | `              try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 95 | `                final pattern = RegExp(s.bookUrlPattern!);` | 声明不可重新赋值的变量 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 96 | `                if (pattern.hasMatch(bookUrl)) {` | 条件判断 如果(if)：模式.是否匹配(书籍链接) |
| 97 | `                  source = s;` | 将 s 赋值给 书源 |
| 98 | `                  break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 99 | `                }` | 闭合大括号，结束当前代码块 |
| 100 | `              } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 101 | `                // 正则表达式错误，跳过` | 注释说明：正则表达式错误，跳过 |
| 102 | `                continue;` | 继续(continue)：进入下一次循环迭代 |
| 103 | `              }` | 闭合大括号，结束当前代码块 |
| 104 | `            }` | 闭合大括号，结束当前代码块 |
| 105 | `          }` | 闭合大括号，结束当前代码块 |
| 106 | `        }` | 闭合大括号，结束当前代码块 |
| 107 | `&nbsp;` | 空行，分隔逻辑段落 |
| 108 | `        if (source == null) continue;` | 条件判断 如果(if)：书源 等于 空值(null)) 继续(continue); |
| 109 | `&nbsp;` | 空行，分隔逻辑段落 |
| 110 | `        // 创建书籍对象` | 注释说明：创建书籍对象 |
| 111 | `        final book = Book(` | 声明不可重新赋值的变量 书籍：调用 书籍(Book)(...) → 书籍 |
| 112 | `          bookUrl: bookUrl,` | 命名实参 书籍链接: 书籍链接（书籍 统一资源链接(URL)） |
| 113 | `          origin: source.bookSourceUrl,` | 命名实参 来源: 书源.书源链接（来源） |
| 114 | `          originName: source.bookSourceName,` | 命名实参 来源 名称: 书源.书籍 书源 名称（来源 名称） |
| 115 | `          canUpdate: true,` | 命名实参 canUpdate: 真(true)（can 更新） |
| 116 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 117 | `&nbsp;` | 空行，分隔逻辑段落 |
| 118 | `        // 获取书籍信息` | 注释说明：获取书籍信息 |
| 119 | `        final bookInfo = await getBookInfo(book);` | 声明不可重新赋值的变量 bookInfo：等待(await) 调用 getBookInfo(...) → 获取 书籍 Info |
| 120 | `        if (bookInfo == null) continue;` | 条件判断 如果(if)：bookInfo 等于 空值(null)) 继续(continue); |
| 121 | `&nbsp;` | 空行，分隔逻辑段落 |
| 122 | `        // 检查是否已存在同名同作者的书籍` | 注释说明：检查是否已存在同名同作者的书籍 |
| 123 | `        final existingBookByName =` | 上一表达式的续行：不可重新赋值(final) existingBookByName = |
| 124 | `            await getBookByNameAndAuthor(bookInfo.name, bookInfo.author);` | 调用 getBookByNameAndAuthor(...)（等待异步完成） → 获取 书籍 By 名称 And 作者 |
| 125 | `        if (existingBookByName != null) {` | 条件判断 如果(if)：existingBookByName 不等于 空值(null) |
| 126 | `          // 如果已存在，更新章节列表` | 注释说明：如果已存在，更新章节列表 |
| 127 | `          final chapters = await getChapterList(bookInfo);` | 声明不可重新赋值的变量 章节列表：等待(await) 调用 获取 章节 列表(...) → 获取 章节 列表 |
| 128 | `          if (chapters.isNotEmpty) {` | 条件判断 如果(if)：章节列表.是否非空 |
| 129 | `            // 删除旧章节` | 注释说明：删除旧章节 |
| 130 | `            final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 131 | `            if (db != null) {` | 条件判断 如果(if)：数据库 不等于 空值(null) |
| 132 | `              await db.delete(` | 调用 数据库.delete(...)（等待异步完成） → 删除 |
| 133 | `                'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 134 | `                where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 135 | `                whereArgs: [existingBookByName.bookUrl],` | 命名实参 筛选(where) 实参列表: [existingBookByName.书籍链接]（筛选(筛选(where)) 实参列表） |
| 136 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 137 | `              // 保存新章节` | 注释说明：保存新章节 |
| 138 | `              await saveChapters(chapters` | 调用 保存 章节列表(...)（等待异步完成） → 保存 章节列表 |
| 139 | `                  .map((c) => c.copyWith(bookUrl: existingBookByName.bookUrl))` | 链式调用延续：.映射(map)((c) => c.copyWith(书籍链接: existingBookByName.书籍链接)) |
| 140 | `                  .toList());` | 链式调用延续：.转为列表()); |
| 141 | `            }` | 闭合大括号，结束当前代码块 |
| 142 | `          }` | 闭合大括号，结束当前代码块 |
| 143 | `          successCount++;` | 成功 数量++ |
| 144 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 145 | `        }` | 闭合大括号，结束当前代码块 |
| 146 | `&nbsp;` | 空行，分隔逻辑段落 |
| 147 | `        // 获取章节列表` | 注释说明：获取章节列表 |
| 148 | `        final chapters = await getChapterList(bookInfo);` | 声明不可重新赋值的变量 章节列表：等待(await) 调用 获取 章节 列表(...) → 获取 章节 列表 |
| 149 | `        if (chapters.isEmpty) continue;` | 条件判断 如果(if)：章节列表.是否为空) 继续(continue); |
| 150 | `&nbsp;` | 空行，分隔逻辑段落 |
| 151 | `        // 设置分组` | 注释说明：设置分组 |
| 152 | `        final finalBook =` | 上一表达式的续行：不可重新赋值(final) finalBook = |
| 153 | `            groupId != null ? bookInfo.copyWith(group: groupId) : bookInfo;` | 调用 copyWith(...)：捕获组 编号(id) != 空值(null) ? bookInfo.copyWith(捕获组: 捕获组 编号(id)) : bookInfo（复制 With） |
| 154 | `&nbsp;` | 空行，分隔逻辑段落 |
| 155 | `        // 保存书籍` | 注释说明：保存书籍 |
| 156 | `        await createBook(finalBook);` | 调用 createBook(...)（等待异步完成） → create 书籍 |
| 157 | `&nbsp;` | 空行，分隔逻辑段落 |
| 158 | `        successCount++;` | 成功 数量++ |
| 159 | `      } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 160 | `        // 添加失败，继续下一个` | 注释说明：添加失败，继续下一个 |
| 161 | `        continue;` | 继续(continue)：进入下一次循环迭代 |
| 162 | `      }` | 闭合大括号，结束当前代码块 |
| 163 | `    }` | 闭合大括号，结束当前代码块 |
| 164 | `&nbsp;` | 空行，分隔逻辑段落 |
| 165 | `    return successCount;` | 返回 成功 数量 |
| 166 | `  }` | 闭合大括号，结束当前代码块 |
| 167 | `&nbsp;` | 空行，分隔逻辑段落 |
| 168 | `  /// 根据URL获取书籍` | 文档注释：说明其后代码的用途 |
| 169 | `  Future<Book?> getBookByUrl(String bookUrl) async {` | 【承接上方文档】根据统一资源链接(URL)获取书籍 → 定义方法 getBookByUrl：返回 异步结果(Future)<书籍(Book)?>；位置参数 1 个；含命名参数；参数名: 书籍链接（异步）。语义：获取 书籍 By 统一资源链接(URL) |
| 170 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 171 | `    if (db == null) return null;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 空值(null); |
| 172 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 173 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 174 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 175 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 176 | `      limit: 1,` | 命名实参 limit: 1（限制） |
| 177 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 178 | `    if (result.isEmpty) return null;` | 条件判断 如果(if)：结果.是否为空) 返回(return) 空值(null); |
| 179 | `    return _bookFromDbMap(result.first);` | 返回调用 _bookFromDbMap(...) 的结果（语义：书籍 From 数据库 映射） |
| 180 | `  }` | 闭合大括号，结束当前代码块 |
| 181 | `&nbsp;` | 空行，分隔逻辑段落 |
| 182 | `  /// 根据书名和作者获取书籍` | 文档注释：说明其后代码的用途 |
| 183 | `  Future<Book?> getBookByNameAndAuthor(String name, String author) async {` | 【承接上方文档】根据书名和作者获取书籍 → 定义方法 getBookByNameAndAuthor：返回 异步结果(Future)<书籍(Book)?>；位置参数 2 个；含命名参数；参数名: 名称, 作者（异步）。语义：获取 书籍 By 名称 And 作者 |
| 184 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 185 | `    if (db == null) return null;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 空值(null); |
| 186 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 187 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 188 | `      where: 'name = ? AND author = ?',` | 命名实参 筛选(where): '名称 = ? AND 作者 = ?'（筛选(筛选(where))） |
| 189 | `      whereArgs: [name, author],` | 命名实参 筛选(where) 实参列表: [名称, 作者]（筛选(筛选(where)) 实参列表） |
| 190 | `      limit: 1,` | 命名实参 limit: 1（限制） |
| 191 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 192 | `    if (result.isEmpty) return null;` | 条件判断 如果(if)：结果.是否为空) 返回(return) 空值(null); |
| 193 | `    return _bookFromDbMap(result.first);` | 返回调用 _bookFromDbMap(...) 的结果（语义：书籍 From 数据库 映射） |
| 194 | `  }` | 闭合大括号，结束当前代码块 |
| 195 | `&nbsp;` | 空行，分隔逻辑段落 |
| 196 | `  /// 通过书名和作者搜索并添加书籍（用于导入书单）` | 文档注释：说明其后代码的用途 |
| 197 | `  Future<int> addBookByNameAndAuthor(String name, String author,` | 【承接上方文档】通过书名和作者搜索并添加书籍（用于导入书单） → 定义方法 addBookByNameAndAuthor：返回 异步结果(Future)<整数(int)>；位置参数 2 个；参数名: 名称, 作者（异步）。语义：添加 书籍 By 名称 And 作者 |
| 198 | `      {int? groupId}) async {` | {整数(int)? 捕获组 编号(id)}) 异步(async) { |
| 199 | `    if (name.isEmpty) return 0;` | 条件判断 如果(if)：名称.是否为空) 返回(return) 0; |
| 200 | `&nbsp;` | 空行，分隔逻辑段落 |
| 201 | `    // 检查是否已存在` | 注释说明：检查是否已存在 |
| 202 | `    final existingBook = await getBookByNameAndAuthor(name, author);` | 声明不可重新赋值的变量 existingBook：等待(await) 调用 getBookByNameAndAuthor(...) → 获取 书籍 By 名称 And 作者 |
| 203 | `    if (existingBook != null) {` | 条件判断 如果(if)：existingBook 不等于 空值(null) |
| 204 | `      return 0; // 已存在，不重复添加` | 返回 0（数值 0）；行尾注释：已存在，不重复添加 |
| 205 | `    }` | 闭合大括号，结束当前代码块 |
| 206 | `&nbsp;` | 空行，分隔逻辑段落 |
| 207 | `    // 搜索书籍` | 注释说明：搜索书籍 |
| 208 | `    final searchResults = await searchBooks(name);` | 声明不可重新赋值的变量 搜索 结果：等待(await) 调用 搜索 书籍列表(...) → 搜索 书籍列表 |
| 209 | `&nbsp;` | 空行，分隔逻辑段落 |
| 210 | `    // 精确匹配书名和作者` | 注释说明：精确匹配书名和作者 |
| 211 | `    Book? matchedBook;` | 书籍(Book)? matchedBook |
| 212 | `    for (final book in searchResults) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 书籍 属于(in) 搜索 结果 |
| 213 | `      if (book.name == name && book.author == author) {` | 条件判断 如果(if)：书籍.名称 等于 名称 且 书籍.作者 等于 作者 |
| 214 | `        matchedBook = book;` | 将 书籍 赋值给 matchedBook |
| 215 | `        break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 216 | `      }` | 闭合大括号，结束当前代码块 |
| 217 | `    }` | 闭合大括号，结束当前代码块 |
| 218 | `&nbsp;` | 空行，分隔逻辑段落 |
| 219 | `    if (matchedBook == null) {` | 条件判断 如果(if)：matchedBook 等于 空值(null) |
| 220 | `      return 0; // 未找到匹配的书籍` | 返回 0（数值 0）；行尾注释：未找到匹配的书籍 |
| 221 | `    }` | 闭合大括号，结束当前代码块 |
| 222 | `&nbsp;` | 空行，分隔逻辑段落 |
| 223 | `    // 获取书籍详情` | 注释说明：获取书籍详情 |
| 224 | `    final bookInfo = await getBookInfo(matchedBook);` | 声明不可重新赋值的变量 bookInfo：等待(await) 调用 getBookInfo(...) → 获取 书籍 Info |
| 225 | `    if (bookInfo == null) return 0;` | 条件判断 如果(if)：bookInfo 等于 空值(null)) 返回(return) 0; |
| 226 | `&nbsp;` | 空行，分隔逻辑段落 |
| 227 | `    // 获取章节列表` | 注释说明：获取章节列表 |
| 228 | `    final chapters = await getChapterList(bookInfo);` | 声明不可重新赋值的变量 章节列表：等待(await) 调用 获取 章节 列表(...) → 获取 章节 列表 |
| 229 | `    if (chapters.isEmpty) return 0;` | 条件判断 如果(if)：章节列表.是否为空) 返回(return) 0; |
| 230 | `&nbsp;` | 空行，分隔逻辑段落 |
| 231 | `    // 设置分组` | 注释说明：设置分组 |
| 232 | `    final finalBook =` | 上一表达式的续行：不可重新赋值(final) finalBook = |
| 233 | `        groupId != null ? bookInfo.copyWith(group: groupId) : bookInfo;` | 调用 copyWith(...)：捕获组 编号(id) != 空值(null) ? bookInfo.copyWith(捕获组: 捕获组 编号(id)) : bookInfo（复制 With） |
| 234 | `&nbsp;` | 空行，分隔逻辑段落 |
| 235 | `    // 保存书籍` | 注释说明：保存书籍 |
| 236 | `    await createBook(finalBook);` | 调用 createBook(...)（等待异步完成） → create 书籍 |
| 237 | `&nbsp;` | 空行，分隔逻辑段落 |
| 238 | `    return 1;` | 返回 1（数值 1） |
| 239 | `  }` | 闭合大括号，结束当前代码块 |
| 240 | `&nbsp;` | 空行，分隔逻辑段落 |
| 241 | `  /// 导入书单（从JSON）` | 文档注释：说明其后代码的用途 |
| 242 | `  Future<int> importBooklist(String jsonText, {int? groupId}) async {` | 【承接上方文档】导入书单（从JSON数据） → 定义方法 importBooklist：返回 异步结果(Future)<整数(int)>；位置参数 1 个；含命名参数；参数名: JSON 文本, 捕获组 编号(id)（异步）。语义：导入(import) Booklist |
| 243 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 244 | `      // 解析JSON` | 注释说明：解析JSON数据 |
| 245 | `      final jsonData = jsonDecode(jsonText);` | 声明不可重新赋值的变量 jsonData：调用 JSON 解码(...) → JSON数据 解码 |
| 246 | `      if (jsonData is! List) {` | 条件判断 如果(if)：jsonData 是(is)! 列表(List) |
| 247 | `        throw Exception('书单格式错误：应为数组格式');` | 定义方法 异常：返回 抛出(throw)；位置参数 1 个。语义：异常 |
| 248 | `      }` | 闭合大括号，结束当前代码块 |
| 249 | `&nbsp;` | 空行，分隔逻辑段落 |
| 250 | `      int successCount = 0;` | 整数(int) 成功 数量 = 0 |
| 251 | `&nbsp;` | 空行，分隔逻辑段落 |
| 252 | `      // 遍历书单` | 注释说明：遍历书单 |
| 253 | `      for (final item in jsonData) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 条目 属于(in) jsonData |
| 254 | `        if (item is! Map) continue;` | 条件判断 如果(if)：条目 是(is)! 映射(Map)) 继续(continue); |
| 255 | `&nbsp;` | 空行，分隔逻辑段落 |
| 256 | `        final name = item['name']?.toString() ?? '';` | 声明不可重新赋值的变量 名称 |
| 257 | `        final author = item['author']?.toString() ?? '';` | 声明不可重新赋值的变量 作者 |
| 258 | `&nbsp;` | 空行，分隔逻辑段落 |
| 259 | `        if (name.isEmpty) continue;` | 条件判断 如果(if)：名称.是否为空) 继续(continue); |
| 260 | `&nbsp;` | 空行，分隔逻辑段落 |
| 261 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 262 | `          final count =` | 上一表达式的续行：不可重新赋值(final) 数量 = |
| 263 | `              await addBookByNameAndAuthor(name, author, groupId: groupId);` | 调用 addBookByNameAndAuthor(...)（等待异步完成） → 添加 书籍 By 名称 And 作者 |
| 264 | `          successCount += count;` | 成功 数量 += 数量 |
| 265 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 266 | `          // 单个书籍添加失败，继续下一个` | 注释说明：单个书籍添加失败，继续下一个 |
| 267 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 268 | `        }` | 闭合大括号，结束当前代码块 |
| 269 | `      }` | 闭合大括号，结束当前代码块 |
| 270 | `&nbsp;` | 空行，分隔逻辑段落 |
| 271 | `      return successCount;` | 返回 成功 数量 |
| 272 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 273 | `      throw Exception('导入书单失败: $e');` | 定义方法 异常：返回 抛出(throw)；位置参数 1 个；参数名: 导入书单失败。语义：异常 |
| 274 | `    }` | 闭合大括号，结束当前代码块 |
| 275 | `  }` | 闭合大括号，结束当前代码块 |
| 276 | `&nbsp;` | 空行，分隔逻辑段落 |
| 277 | `  /// 获取章节正文` | 文档注释：说明其后代码的用途 |
| 278 | `  /// 参考项目：支持分页获取（nextContentUrl），循环获取所有页面的内容` | 文档注释：说明其后代码的用途 |
| 279 | `  /// [book] 可选参数，传入后会自动检查和保存文件缓存，避免重复网络请求` | 文档注释：说明其后代码的用途 |
