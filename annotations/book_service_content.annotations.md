# book_service_content.dart 逐行注释

> 源文件：`lib/services/book/book_service_content.dart`（共 547 行）
>
> 本文件由 `scripts/gen_line_annotations.py` 自动生成，对源文件每一行给出独立说明。
> 说明优先采用源码自带的中文注释；无注释的行依据 Dart 语法特征自动生成解释。

| 行号 | 源代码 | 说明 |
| ---: | --- | --- |
| 1 | `part of 'book_service.dart';` | 声明本文件是 book_service.dart 库的一部分(part)，与其共享同一命名空间 |
| 2 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 4 | `// BookService 职责：章节正文获取（规则解析、分页拼接、本地缓存与并发去重）。` | 注释说明：BookService 职责：章节正文获取（规则解析、分页拼接、本地缓存与并发去重）。 |
| 5 | `// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）` | 注释说明：（part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号） |
| 6 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 7 | `&nbsp;` | 空行，分隔逻辑段落 |
| 8 | `  Future<String?> getChapterContent(` | 定义方法 getChapterContent：返回 Future<String?>；无参数（异步）。语义：获取 章节 正文内容 |
| 9 | `    BookChapter chapter,` | BookChapter 类型参数 chapter（章节） |
| 10 | `    BookSource source, {` | BookSource 类型参数 source，其后 { 开启命名参数块（书源） |
| 11 | `    String? bookName,` | String? 类型参数 bookName（书籍 Name） |
| 12 | `    String? bookOrigin,` | String? 类型参数 bookOrigin（书籍 来源） |
| 13 | `    Book? book, // 新增：用于缓存检查和保存` | Book? 类型参数 book（书籍） |
| 14 | `  }) async {` | 签名结束，进入异步方法体 }) async { |
| 15 | `    if (source.ruleContent == null) {` | 条件判断 if：source.ruleContent 等于 null |
| 16 | `      AppLog.instance.put('获取章节内容失败: 内容规则为空 (章节: ${chapter.title})');` | 输出日志(put)：“获取章节内容失败: 内容规则为空 (章节: ${chapter.title})” |
| 17 | `      return null;` | 返回 null（初始为 null） |
| 18 | `    }` | 闭合大括号，结束当前代码块 |
| 19 | `&nbsp;` | 空行，分隔逻辑段落 |
| 20 | `    // ✅ 新策略: 优先从文件存储读取` | 注释说明：✅ 新策略: 优先从文件存储读取 |
| 21 | `    if (book != null && !book.isLocal) {` | 条件判断 if：book 不等于 null 且 !book.isLocal |
| 22 | `      // 1. 如果chapter有localPath,从文件读取` | 注释说明：1. 如果chapter有localPath,从文件读取 |
| 23 | `      if (chapter.localPath != null && chapter.localPath!.isNotEmpty) {` | 条件判断 if：chapter.localPath 不等于 null 且 chapter.localPath!.isNotEmpty |
| 24 | `        final fileContent = await readService(AppServices.chapterContentService)` | 声明不可重新赋值的(final)变量 fileContent：await 调用 readService(...) → 读取 Service |
| 25 | `            .getChapterContent(book, chapter);` | 链式调用延续：.getChapterContent(book, chapter); |
| 26 | `        if (fileContent != null && fileContent.isNotEmpty) {` | 条件判断 if：fileContent 不等于 null 且 fileContent.isNotEmpty |
| 27 | `          AppLog.instance` | 上一表达式的续行：AppLog.instance |
| 28 | `              .put('从文件存储读取: ${chapter.title} (${fileContent.length}字)');` | 链式调用延续：.put('从文件存储读取: ${chapter.title} (${fileContent.length}字)'); |
| 29 | `          return fileContent;` | 返回 fileContent |
| 30 | `        }` | 闭合大括号，结束当前代码块 |
| 31 | `        // localPath存在但文件不存在,继续从网络获取` | 注释说明：localPath存在但文件不存在,继续从网络获取 |
| 32 | `        AppLog.instance.put('警告: localPath存在但文件不存在: ${chapter.title}');` | 输出日志(put)：“警告: localPath存在但文件不存在: ${chapter.title}” |
| 33 | `      }` | 闭合大括号，结束当前代码块 |
| 34 | `&nbsp;` | 空行，分隔逻辑段落 |
| 35 | `      // 2. 尝试从文件系统读取(向后兼容旧缓存)` | 注释说明：2. 尝试从文件系统读取(向后兼容旧缓存) |
| 36 | `      final fileContent = await readService(AppServices.chapterContentService)` | 声明不可重新赋值的(final)变量 fileContent：await 调用 readService(...) → 读取 Service |
| 37 | `          .getChapterContent(book, chapter);` | 链式调用延续：.getChapterContent(book, chapter); |
| 38 | `      if (fileContent != null && fileContent.isNotEmpty) {` | 条件判断 if：fileContent 不等于 null 且 fileContent.isNotEmpty |
| 39 | `        AppLog.instance.put(` | 输出应用日志 AppLog |
| 40 | `            '从文件系统读取(无localPath): ${chapter.title} (${fileContent.length}字)');` | 以字符串 '从文件系统读取(无localPath): ${chapter.title} (… 起始的表达式：); |
| 41 | `        // 更新localPath` | 注释说明：更新localPath |
| 42 | `        final localPath = readService(AppServices.chapterContentService)` | 声明不可重新赋值的(final)变量 localPath：调用 readService(...) → 读取 Service |
| 43 | `            .getChapterLocalPath(book, chapter);` | 链式调用延续：.getChapterLocalPath(book, chapter); |
| 44 | `        chapter.localPath = localPath;` | 将 localPath 赋值给 chapter.localPath |
| 45 | `        // 异步更新数据库,不阻塞返回` | 注释说明：异步更新数据库,不阻塞返回 |
| 46 | `        _updateChapterLocalPath(chapter.bookUrl, chapter.url, localPath)` | 调用 _updateChapterLocalPath(...)：_updateChapterLocalPath(chapter.bookUrl, chapter.url, localPath)（更新 章节 本地 Path） |
| 47 | `            .catchError((e) => AppLog.instance.put('更新localPath失败', error: e));` | 链式调用延续：.catchError((e) => AppLog.instance.put('更新localPath失败', error: e)); |
| 48 | `        return fileContent;` | 返回 fileContent |
| 49 | `      }` | 闭合大括号，结束当前代码块 |
| 50 | `&nbsp;` | 空行，分隔逻辑段落 |
| 51 | `      // 3. 回退: 从旧的CacheService读取` | 注释说明：3. 回退: 从旧的CacheService读取 |
| 52 | `      final cachedContent = await readService(AppServices.cacheService)` | 声明不可重新赋值的(final)变量 cachedContent：await 调用 readService(...) → 读取 Service |
| 53 | `          .getCachedChapterContent(book, chapter);` | 链式调用延续：.getCachedChapterContent(book, chapter); |
| 54 | `      if (cachedContent != null && cachedContent.isNotEmpty) {` | 条件判断 if：cachedContent 不等于 null 且 cachedContent.isNotEmpty |
| 55 | `        AppLog.instance` | 上一表达式的续行：AppLog.instance |
| 56 | `            .put('从旧缓存读取: ${chapter.title} (${cachedContent.length}字)');` | 链式调用延续：.put('从旧缓存读取: ${chapter.title} (${cachedContent.length}字)'); |
| 57 | `        return cachedContent;` | 返回 cachedContent |
| 58 | `      }` | 闭合大括号，结束当前代码块 |
| 59 | `    }` | 闭合大括号，结束当前代码块 |
| 60 | `&nbsp;` | 空行，分隔逻辑段落 |
| 61 | `    final chapterKey = chapter.primaryStr();` | 声明不可重新赋值的(final)变量 chapterKey |
| 62 | `    return _loadingChapters.putIfAbsent(chapterKey, () async {` | 返回调用 _loadingChapters.putIfAbsent(...) 的结果 |
| 63 | `      try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 64 | `        return await _getChapterContentInternal(` | 返回异步调用 _getChapterContentInternal(...) 的结果（语义：获取 章节 正文内容 Internal） |
| 65 | `          chapter,` | 签名/调用续行参数：chapter |
| 66 | `          source,` | 签名/调用续行参数：source |
| 67 | `          bookName: bookName,` | 命名实参 bookName: bookName（书籍 Name） |
| 68 | `          bookOrigin: bookOrigin,` | 命名实参 bookOrigin: bookOrigin（书籍 来源） |
| 69 | `          book: book,` | 命名实参 book: book（书籍） |
| 70 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 71 | `      } finally {` | 闭合代码块并衔接后续语句：finally { |
| 72 | `        _loadingChapters.remove(chapterKey);` | 调用 remove(...)：_loadingChapters.remove(chapterKey)（移除） |
| 73 | `      }` | 闭合大括号，结束当前代码块 |
| 74 | `    });` | 闭合代码块并衔接后续语句：); |
| 75 | `  }` | 闭合大括号，结束当前代码块 |
| 76 | `&nbsp;` | 空行，分隔逻辑段落 |
| 77 | `  /// 获取章节正文的内部实现` | 文档注释：说明其后代码的用途 |
| 78 | `  /// 参考项目：支持分页获取（nextContentUrl），循环获取所有页面的内容` | 文档注释：说明其后代码的用途 |
| 79 | `  Future<String?> _getChapterContentInternal(` | 【承接上方文档】获取章节正文的内部实现 参考项目：支持分页获取（nextContentUrl），循环获取所有页面的内容 → 定义方法 _getChapterContentInternal：返回 Future<String?>；无参数（异步）。语义：获取 章节 正文内容 Internal |
| 80 | `    BookChapter chapter,` | BookChapter 类型参数 chapter（章节） |
| 81 | `    BookSource source, {` | BookSource 类型参数 source，其后 { 开启命名参数块（书源） |
| 82 | `    String? bookName,` | String? 类型参数 bookName（书籍 Name） |
| 83 | `    String? bookOrigin,` | String? 类型参数 bookOrigin（书籍 来源） |
| 84 | `    Book? book, // 新增：用于缓存保存` | Book? 类型参数 book（书籍） |
| 85 | `  }) async {` | 签名结束，进入异步方法体 }) async { |
| 86 | `    try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 87 | `      final contentVariables =` | 上一表达式的续行：final contentVariables = |
| 88 | `          book != null ? _buildRuleVariables(book) : <String, String>{};` | 调用 _buildRuleVariables(...)：book != null ? _buildRuleVariables(book) : <String, String>{}（构建 规则 变量表） |
| 89 | `      // 参考项目：使用章节URL作为baseUrl，支持分页获取` | 注释说明：参考项目：使用章节URL作为baseUrl，支持分页获取 |
| 90 | `      // 参考项目：BookContent.analyzeContent` | 注释说明：参考项目：BookContent.analyzeContent |
| 91 | `      var currentUrl = chapter.url;` | 声明自动类型推断(var)变量 currentUrl |
| 92 | `      currentUrl = _repairChapterUrlWithBookVariables(currentUrl, book);` | 将 _repairChapterUrlWithBookVariables(currentUrl, book) 赋值给 currentUrl（调用 _repairChapterUrlWithBookVariables → repair 章节 URL With 书籍 变量表） |
| 93 | `      var redirectUrl = currentUrl; // 重定向后的URL` | 声明自动类型推断(var)变量 redirectUrl；行尾注释：重定向后的URL |
| 94 | `      var visitedUrls = <String>{currentUrl};` | 声明自动类型推断(var)变量 visitedUrls |
| 95 | `      var contentList = <String>[];` | 声明自动类型推断(var)变量 contentList |
| 96 | `&nbsp;` | 空行，分隔逻辑段落 |
| 97 | `      // 参考项目：获取下一章的URL（用于判断是否到达下一章）` | 注释说明：参考项目：获取下一章的URL（用于判断是否到达下一章） |
| 98 | `      final localChapters = await _getLocalChapters(chapter.bookUrl);` | 声明不可重新赋值的(final)变量 localChapters：await 调用 _getLocalChapters(...) → 获取 本地 章节列表 |
| 99 | `      BookChapter? nextChapter;` | BookChapter? nextChapter |
| 100 | `      if (chapter.index + 1 < localChapters.length) {` | 条件判断 if：chapter.index + 1 < localChapters.length |
| 101 | `        nextChapter = localChapters[chapter.index + 1];` | 将 localChapters[chapter.index + 1] 赋值给 nextChapter |
| 102 | `      } else if (localChapters.isNotEmpty) {` | 闭合上一代码块并开始 else if (localChapters.isNotEmpty) { |
| 103 | `        // 参考项目：如果下一章不存在，使用第一章（循环）` | 注释说明：参考项目：如果下一章不存在，使用第一章（循环） |
| 104 | `        nextChapter = localChapters[0];` | 将 localChapters[0] 赋值给 nextChapter |
| 105 | `      }` | 闭合大括号，结束当前代码块 |
| 106 | `      final nextChapterUrl = nextChapter?.url;` | 声明不可重新赋值的(final)变量 nextChapterUrl |
| 107 | `&nbsp;` | 空行，分隔逻辑段落 |
| 108 | `      // ── Phase 3：payAction 预执行（付费章节自动解锁）──────────────────────` | 注释说明：── Phase 3：payAction 预执行（付费章节自动解锁）────────────────────── |
| 109 | `      // 当章节是 VIP 且未购买，且书源配置了 payAction 时，先执行解锁动作，` | 注释说明：当章节是 VIP 且未购买，且书源配置了 payAction 时，先执行解锁动作， |
| 110 | `      // 成功后重新请求章节页面以获取解锁内容。` | 注释说明：成功后重新请求章节页面以获取解锁内容。 |
| 111 | `      bool didPayAction = false;` | bool didPayAction = false |
| 112 | `      if (chapter.isVip &&` | 条件判断 if：chapter.isVip 且 |
| 113 | `          !chapter.isPay &&` | 上一表达式的续行：!chapter.isPay && |
| 114 | `          source.ruleContent?.payAction != null &&` | 上一表达式的续行：source.ruleContent?.payAction != null && |
| 115 | `          source.ruleContent!.payAction!.isNotEmpty) {` | source.ruleContent!.payAction!.isNotEmpty) { |
| 116 | `        AppLog.instance.put('payAction: 检测到付费章节，尝试执行解锁 (章节: ${chapter.title})');` | 输出日志(put)：“payAction: 检测到付费章节，尝试执行解锁 (章节: ${chapter.title})” |
| 117 | `        // 先请求一次页面（payAction 可能需要当前页的 HTML 上下文，如 cookie/token）` | 注释说明：先请求一次页面（payAction 可能需要当前页的 HTML 上下文，如 cookie/token） |
| 118 | `        try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 119 | `          final preResponse = await _networkService.get(` | 声明不可重新赋值的(final)变量 preResponse：await 调用 _networkService.get(...) → 获取 |
| 120 | `            currentUrl,` | 签名/调用续行参数：currentUrl |
| 121 | `            headers: NetworkService.parseHeaders(source.header),` | 命名实参 headers: NetworkService.parseHeaders(source.header)（请求头） |
| 122 | `            retryCount: 1,` | 命名实参 retryCount: 1（重试 数量） |
| 123 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 124 | `          final preHtml = await NetworkService.getResponseText(preResponse);` | 声明不可重新赋值的(final)变量 preHtml：await 调用 NetworkService.getResponseText(...) → 获取 响应 文本 |
| 125 | `          didPayAction = await RuleParser.executePayAction(` | 将 等待异步结果：await RuleParser.executePayAction( 赋值给 didPayAction（调用 executePayAction → execute Pay Action） |
| 126 | `            preHtml,` | 签名/调用续行参数：preHtml |
| 127 | `            source.ruleContent!.payAction!,` | source.ruleContent!.payAction!, |
| 128 | `            variables: contentVariables,` | 命名实参 variables: contentVariables（变量表） |
| 129 | `            source: source,` | 命名实参 source: source（书源） |
| 130 | `            book: book,` | 命名实参 book: book（书籍） |
| 131 | `            baseUrl: currentUrl,` | 命名实参 baseUrl: currentUrl（base URL） |
| 132 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 133 | `          if (didPayAction) {` | 条件判断 if：didPayAction |
| 134 | `            AppLog.instance.put('payAction: 解锁请求已发送，将重新请求章节页面');` | 输出日志(put)：“payAction: 解锁请求已发送，将重新请求章节页面” |
| 135 | `          }` | 闭合大括号，结束当前代码块 |
| 136 | `        } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 137 | `          AppLog.instance.put('payAction: 预请求失败，跳过解锁', error: e);` | 输出日志(put)：“payAction: 预请求失败，跳过解锁” |
| 138 | `        }` | 闭合大括号，结束当前代码块 |
| 139 | `      }` | 闭合大括号，结束当前代码块 |
| 140 | `&nbsp;` | 空行，分隔逻辑段落 |
| 141 | `      final response = await _networkService.get(` | 声明不可重新赋值的(final)变量 response：await 调用 _networkService.get(...) → 获取 |
| 142 | `        currentUrl,` | 签名/调用续行参数：currentUrl |
| 143 | `        headers: NetworkService.parseHeaders(source.header),` | 命名实参 headers: NetworkService.parseHeaders(source.header)（请求头） |
| 144 | `        retryCount: 1,` | 命名实参 retryCount: 1（重试 数量） |
| 145 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 146 | `&nbsp;` | 空行，分隔逻辑段落 |
| 147 | `      var html = await NetworkService.getResponseText(response);` | 声明自动类型推断(var)变量 html：await 调用 NetworkService.getResponseText(...) → 获取 响应 文本 |
| 148 | `      // 参考项目：获取重定向后的URL（如果有）` | 注释说明：参考项目：获取重定向后的URL（如果有） |
| 149 | `      // 注意：Dio的Response可能没有redirectRecord，使用实际请求的URL` | 注释说明：注意：Dio的Response可能没有redirectRecord，使用实际请求的URL |
| 150 | `      redirectUrl = response.realUri.toString();` | 将 response.realUri.toString() 赋值给 redirectUrl（调用 toString → to String） |
| 151 | `&nbsp;` | 空行，分隔逻辑段落 |
| 152 | `      AppLog.instance` | 上一表达式的续行：AppLog.instance |
| 153 | `          .put('获取章节内容响应: 状态码=${response.statusCode}, 内容长度=${html.length}');` | 链式调用延续：.put('获取章节内容响应: 状态码=${response.statusCode}, 内容长度=${html.length}'); |
| 154 | `&nbsp;` | 空行，分隔逻辑段落 |
| 155 | `      if (html.isEmpty) {` | 条件判断 if：html.isEmpty |
| 156 | `        AppLog.instance.put('章节内容响应为空');` | 输出日志(put)：“章节内容响应为空” |
| 157 | `        throw ContentEmptyException('章节内容为空: ${chapter.title}');` | 定义方法 ContentEmptyException：返回 throw；位置参数 1 个；含命名参数；参数名: 章节内容为空, title。语义：正文内容 空 Exception |
| 158 | `      }` | 闭合大括号，结束当前代码块 |
| 159 | `&nbsp;` | 空行，分隔逻辑段落 |
| 160 | `      final pageContent = await RuleParser.parseContentRule(` | 声明不可重新赋值的(final)变量 pageContent：await 调用 RuleParser.parseContentRule(...) → 解析 正文内容 规则 |
| 161 | `        html,` | 签名/调用续行参数：html |
| 162 | `        source.ruleContent,` | 签名/调用续行参数：source.ruleContent |
| 163 | `        variables: contentVariables,` | 命名实参 variables: contentVariables（变量表） |
| 164 | `        baseUrl: currentUrl, // 使用当前请求的URL作为baseUrl` | 命名实参 baseUrl: currentUrl（base URL）；行尾注释：使用当前请求的URL作为baseUrl |
| 165 | `        bookName: bookName,` | 命名实参 bookName: bookName（书籍 Name） |
| 166 | `        bookOrigin: bookOrigin,` | 命名实参 bookOrigin: bookOrigin（书籍 来源） |
| 167 | `        applyReplaceRegex: false, // 不在每页应用，而是在合并后统一应用` | 命名实参 applyReplaceRegex: false（apply 替换 正则）；行尾注释：不在每页应用，而是在合并后统一应用 |
| 168 | `        bookSourceType: source.bookSourceType, // 传入书源类型，启用音视频分发路径` | 命名实参 bookSourceType: source.bookSourceType（书籍 书源 Type）；行尾注释：传入书源类型，启用音视频分发路径 |
| 169 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 170 | `&nbsp;` | 空行，分隔逻辑段落 |
| 171 | `      if (pageContent == null \|\| pageContent.isEmpty) {` | 条件判断 if：pageContent 等于 null 或 pageContent.isEmpty |
| 172 | `        AppLog.instance.put('章节内容解析失败: 内容为空 (章节: ${chapter.title})');` | 输出日志(put)：“章节内容解析失败: 内容为空 (章节: ${chapter.title})” |
| 173 | `        throw ContentEmptyException('章节内容为空: ${chapter.title}');` | 定义方法 ContentEmptyException：返回 throw；位置参数 1 个；含命名参数；参数名: 章节内容为空, title。语义：正文内容 空 Exception |
| 174 | `      }` | 闭合大括号，结束当前代码块 |
| 175 | `&nbsp;` | 空行，分隔逻辑段落 |
| 176 | `      // 音频源（bookSourceType == 1）：parseContentRule 返回的是通过` | 注释说明：音频源（bookSourceType == 1）：parseContentRule 返回的是通过 |
| 177 | `      // audioUrl 规则或 sourceRegex 嗅探提取的媒体 URL，将其写入` | 注释说明：audioUrl 规则或 sourceRegex 嗅探提取的媒体 URL，将其写入 |
| 178 | `      // chapter.resourceUrl 供播放器直接使用。` | 注释说明：chapter.resourceUrl 供播放器直接使用。 |
| 179 | `      if (source.bookSourceType == 1) {` | 条件判断 if：source.bookSourceType 等于 1 |
| 180 | `        chapter.resourceUrl = pageContent;` | 将 pageContent 赋值给 chapter.resourceUrl |
| 181 | `        AppLog.instance.put(` | 输出应用日志 AppLog |
| 182 | `            '音频源: 已提取资源URL → ${chapter.resourceUrl} (章节: ${chapter.title})');` | 以字符串 '音频源: 已提取资源URL → ${chapter.resourceUrl} … 起始的表达式：); |
| 183 | `      }` | 闭合大括号，结束当前代码块 |
| 184 | `&nbsp;` | 空行，分隔逻辑段落 |
| 185 | `      // ── Phase 3：解析音视频辅助字段（lyricsUrl/subtitleUrl/qualityOptions）` | 注释说明：── Phase 3：解析音视频辅助字段（lyricsUrl/subtitleUrl/qualityOptions） |
| 186 | `      if (source.bookSourceType == 1 \|\| source.bookSourceType == 2) {` | 条件判断 if：source.bookSourceType 等于 1 或 source.bookSourceType 等于 2 |
| 187 | `        try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 188 | `          final extras = await RuleParser.parseAudioExtras(` | 声明不可重新赋值的(final)变量 extras：await 调用 RuleParser.parseAudioExtras(...) → 解析 Audio Extras |
| 189 | `            html,` | 签名/调用续行参数：html |
| 190 | `            source.ruleContent,` | 签名/调用续行参数：source.ruleContent |
| 191 | `            variables: contentVariables,` | 命名实参 variables: contentVariables（变量表） |
| 192 | `            baseUrl: currentUrl,` | 命名实参 baseUrl: currentUrl（base URL） |
| 193 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 194 | `          if (extras['lyricsUrl'] != null) {` | 条件判断 if：extras['lyricsUrl'] 不等于 null |
| 195 | `            chapter.lyricsUrl = extras['lyricsUrl'];` | 将 extras['lyricsUrl'] 赋值给 chapter.lyricsUrl |
| 196 | `          }` | 闭合大括号，结束当前代码块 |
| 197 | `          if (extras['subtitleUrl'] != null) {` | 条件判断 if：extras['subtitleUrl'] 不等于 null |
| 198 | `            chapter.subtitleUrl = extras['subtitleUrl'];` | 将 extras['subtitleUrl'] 赋值给 chapter.subtitleUrl |
| 199 | `          }` | 闭合大括号，结束当前代码块 |
| 200 | `          if (extras['qualityOptions'] != null) {` | 条件判断 if：extras['qualityOptions'] 不等于 null |
| 201 | `            chapter.qualityOptions = extras['qualityOptions'];` | 将 extras['qualityOptions'] 赋值给 chapter.qualityOptions |
| 202 | `          }` | 闭合大括号，结束当前代码块 |
| 203 | `        } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 204 | `          AppLog.instance.put('parseAudioExtras: 解析辅助字段失败', error: e);` | 输出日志(put)：“parseAudioExtras: 解析辅助字段失败” |
| 205 | `        }` | 闭合大括号，结束当前代码块 |
| 206 | `      }` | 闭合大括号，结束当前代码块 |
| 207 | `&nbsp;` | 空行，分隔逻辑段落 |
| 208 | `      contentList.add(pageContent);` | 调用 add(...)：contentList.add(pageContent)（添加） |
| 209 | `&nbsp;` | 空行，分隔逻辑段落 |
| 210 | `      // 参考项目：获取下一页URL列表（可能返回多个URL）` | 注释说明：参考项目：获取下一页URL列表（可能返回多个URL） |
| 211 | `      // 参考项目：analyzeRule.getStringList(nextUrlRule, isUrl = true)` | 注释说明：参考项目：analyzeRule.getStringList(nextUrlRule, isUrl = true) |
| 212 | `      List<String> nextUrlList = [];` | List<String> nextUrlList = [] |
| 213 | `&nbsp;` | 空行，分隔逻辑段落 |
| 214 | `      if (source.ruleContent?.nextContentUrl != null &&` | 条件判断 if：source.ruleContent?.nextContentUrl 不等于 null 且 |
| 215 | `          source.ruleContent!.nextContentUrl!.isNotEmpty) {` | source.ruleContent!.nextContentUrl!.isNotEmpty) { |
| 216 | `        AppLog.instance` | 上一表达式的续行：AppLog.instance |
| 217 | `            .put('获取章节内容下一页URL: 规则=${source.ruleContent!.nextContentUrl}');` | 链式调用延续：.put('获取章节内容下一页URL: 规则=${source.ruleContent!.nextContentUrl}'); |
| 218 | `&nbsp;` | 空行，分隔逻辑段落 |
| 219 | `        // 参考项目：使用parseListRule获取URL列表（isUrl=true）` | 注释说明：参考项目：使用parseListRule获取URL列表（isUrl=true） |
| 220 | `        final rawNextUrlList = await RuleParser.parseUrlListRuleAsync(` | 声明不可重新赋值的(final)变量 rawNextUrlList：await 调用 RuleParser.parseUrlListRuleAsync(...) → 解析 URL 列表 规则 Async |
| 221 | `          html,` | 签名/调用续行参数：html |
| 222 | `          source.ruleContent!.nextContentUrl!,` | source.ruleContent!.nextContentUrl!, |
| 223 | `          variables: contentVariables,` | 命名实参 variables: contentVariables（变量表） |
| 224 | `          baseUrl: redirectUrl,` | 命名实参 baseUrl: redirectUrl（base URL） |
| 225 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 226 | `&nbsp;` | 空行，分隔逻辑段落 |
| 227 | `        // 将相对URL转换为绝对URL，并过滤` | 注释说明：将相对URL转换为绝对URL，并过滤 |
| 228 | `        for (final url in rawNextUrlList) {` | for-in 遍历：final url in rawNextUrlList |
| 229 | `          if (url.isNotEmpty) {` | 条件判断 if：url.isNotEmpty |
| 230 | `            final absoluteUrl = url.startsWith('http')` | 声明不可重新赋值的(final)变量 absoluteUrl |
| 231 | `                ? url` | 上一表达式的续行：? url |
| 232 | `                : NetworkService.joinUrl(redirectUrl, url);` | 三元表达式为假时取值：NetworkService.joinUrl(redirectUrl, url); |
| 233 | `            // 参考项目：过滤掉与redirectUrl相同的URL` | 注释说明：参考项目：过滤掉与redirectUrl相同的URL |
| 234 | `            if (absoluteUrl != redirectUrl &&` | 条件判断 if：absoluteUrl 不等于 redirectUrl 且 |
| 235 | `                !visitedUrls.contains(absoluteUrl)) {` | 调用 contains(...)：!visitedUrls.contains(absoluteUrl)) { |
| 236 | `              nextUrlList.add(absoluteUrl);` | 调用 add(...)：nextUrlList.add(absoluteUrl)（添加） |
| 237 | `            }` | 闭合大括号，结束当前代码块 |
| 238 | `          }` | 闭合大括号，结束当前代码块 |
| 239 | `        }` | 闭合大括号，结束当前代码块 |
| 240 | `&nbsp;` | 空行，分隔逻辑段落 |
| 241 | `        AppLog.instance.put('获取章节内容下一页URL: 找到 ${nextUrlList.length} 个URL');` | 输出日志(put)：“获取章节内容下一页URL: 找到 ${nextUrlList.length} 个URL” |
| 242 | `        for (int i = 0; i < nextUrlList.length; i++) {` | for-in 遍历：int i = 0; i < nextUrlList.length; i++ |
| 243 | `          AppLog.instance.put('  下一页URL ${i + 1}: ${nextUrlList[i]}');` | 输出日志(put)：“  下一页URL ${i + 1}: ${nextUrlList[i]}” |
| 244 | `        }` | 闭合大括号，结束当前代码块 |
| 245 | `      }` | 闭合大括号，结束当前代码块 |
| 246 | `&nbsp;` | 空行，分隔逻辑段落 |
| 247 | `      // 参考项目逻辑：` | 注释说明：参考项目逻辑： |
| 248 | `      // 如果 nextUrlList.size == 0，没有下一页，直接返回` | 注释说明：如果 nextUrlList.size == 0，没有下一页，直接返回 |
| 249 | `      // 如果 nextUrlList.size == 1，循环获取所有页面` | 注释说明：如果 nextUrlList.size == 1，循环获取所有页面 |
| 250 | `      // 如果 nextUrlList.size > 1，并发获取所有页面` | 注释说明：如果 nextUrlList.size > 1，并发获取所有页面 |
| 251 | `      if (nextUrlList.isEmpty) {` | 条件判断 if：nextUrlList.isEmpty |
| 252 | `        // 没有下一页，直接返回` | 注释说明：没有下一页，直接返回 |
| 253 | `        AppLog.instance.put('没有找到下一页URL');` | 输出日志(put)：“没有找到下一页URL” |
| 254 | `      } else if (nextUrlList.length == 1) {` | 闭合上一代码块并开始 else if (nextUrlList.length == 1) { |
| 255 | `        // 参考项目：循环获取所有页面` | 注释说明：参考项目：循环获取所有页面 |
| 256 | `        var nextUrl = nextUrlList[0];` | 声明自动类型推断(var)变量 nextUrl |
| 257 | `        var pageCount = 1;` | 声明自动类型推断(var)变量 pageCount |
| 258 | `&nbsp;` | 空行，分隔逻辑段落 |
| 259 | `        while (nextUrl.isNotEmpty && !visitedUrls.contains(nextUrl)) {` | while 循环，条件：nextUrl.isNotEmpty && !visitedUrls.contains(nextUrl) |
| 260 | `          // 参考项目：检查是否到达下一章` | 注释说明：参考项目：检查是否到达下一章 |
| 261 | `          // 参考项目逻辑：NetworkUtils.getAbsoluteURL(redirectUrl, nextUrl) == NetworkUtils.getAbsoluteURL(redirectUrl, mNextChapterUrl)` | 注释说明：参考项目逻辑：NetworkUtils.getAbsoluteURL(redirectUrl, nextUrl) == NetworkUtils.getAbsoluteURL(redirectUrl, mNextChapterUrl) |
| 262 | `          if (nextChapterUrl != null) {` | 条件判断 if：nextChapterUrl 不等于 null |
| 263 | `            // 将两个 URL 都通过 getAbsoluteURL 规范化后再比较` | 注释说明：将两个 URL 都通过 getAbsoluteURL 规范化后再比较 |
| 264 | `            final normalizedNextUrl =` | 上一表达式的续行：final normalizedNextUrl = |
| 265 | `                NetworkUtils.getAbsoluteURL(redirectUrl, nextUrl);` | 调用 getAbsoluteURL(...)：NetworkUtils.getAbsoluteURL(redirectUrl, nextUrl)（获取 Absolute URL） |
| 266 | `            final normalizedNextChapterUrl =` | 上一表达式的续行：final normalizedNextChapterUrl = |
| 267 | `                NetworkUtils.getAbsoluteURL(redirectUrl, nextChapterUrl);` | 调用 getAbsoluteURL(...)：NetworkUtils.getAbsoluteURL(redirectUrl, nextChapterUrl)（获取 Absolute URL） |
| 268 | `&nbsp;` | 空行，分隔逻辑段落 |
| 269 | `            if (_urlEquals(normalizedNextUrl, normalizedNextChapterUrl)) {` | 条件判断 if：_urlEquals(normalizedNextUrl, normalizedNextChapterUrl) |
| 270 | `              AppLog.instance.put('下一页URL等于下一章URL，停止获取');` | 输出日志(put)：“下一页URL等于下一章URL，停止获取” |
| 271 | `              break;` | break：跳出当前循环/switch |
| 272 | `            }` | 闭合大括号，结束当前代码块 |
| 273 | `          }` | 闭合大括号，结束当前代码块 |
| 274 | `&nbsp;` | 空行，分隔逻辑段落 |
| 275 | `          pageCount++;` | pageCount++ |
| 276 | `          visitedUrls.add(nextUrl);` | 调用 add(...)：visitedUrls.add(nextUrl)（添加） |
| 277 | `          AppLog.instance.put('获取章节内容第 $pageCount 页: $nextUrl');` | 输出日志(put)：“获取章节内容第 $pageCount 页: $nextUrl” |
| 278 | `&nbsp;` | 空行，分隔逻辑段落 |
| 279 | `          try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 280 | `            final nextResponse = await _networkService.get(` | 声明不可重新赋值的(final)变量 nextResponse：await 调用 _networkService.get(...) → 获取 |
| 281 | `              nextUrl,` | 签名/调用续行参数：nextUrl |
| 282 | `              headers: NetworkService.parseHeaders(source.header),` | 命名实参 headers: NetworkService.parseHeaders(source.header)（请求头） |
| 283 | `              retryCount: 1,` | 命名实参 retryCount: 1（重试 数量） |
| 284 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 285 | `&nbsp;` | 空行，分隔逻辑段落 |
| 286 | `            final nextHtml = await NetworkService.getResponseText(nextResponse);` | 声明不可重新赋值的(final)变量 nextHtml：await 调用 NetworkService.getResponseText(...) → 获取 响应 文本 |
| 287 | `            final nextRedirectUrl = nextResponse.realUri.toString();` | 声明不可重新赋值的(final)变量 nextRedirectUrl |
| 288 | `&nbsp;` | 空行，分隔逻辑段落 |
| 289 | `            if (nextHtml.isEmpty) {` | 条件判断 if：nextHtml.isEmpty |
| 290 | `              AppLog.instance.put('章节内容响应为空，停止获取');` | 输出日志(put)：“章节内容响应为空，停止获取” |
| 291 | `              break;` | break：跳出当前循环/switch |
| 292 | `            }` | 闭合大括号，结束当前代码块 |
| 293 | `&nbsp;` | 空行，分隔逻辑段落 |
| 294 | `            final nextPageContent = await RuleParser.parseContentRule(` | 声明不可重新赋值的(final)变量 nextPageContent：await 调用 RuleParser.parseContentRule(...) → 解析 正文内容 规则 |
| 295 | `              nextHtml,` | 签名/调用续行参数：nextHtml |
| 296 | `              source.ruleContent,` | 签名/调用续行参数：source.ruleContent |
| 297 | `              baseUrl: nextUrl,` | 命名实参 baseUrl: nextUrl（base URL） |
| 298 | `              bookName: bookName,` | 命名实参 bookName: bookName（书籍 Name） |
| 299 | `              bookOrigin: bookOrigin,` | 命名实参 bookOrigin: bookOrigin（书籍 来源） |
| 300 | `              applyReplaceRegex: false,` | 命名实参 applyReplaceRegex: false（apply 替换 正则） |
| 301 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 302 | `&nbsp;` | 空行，分隔逻辑段落 |
| 303 | `            if (nextPageContent != null && nextPageContent.isNotEmpty) {` | 条件判断 if：nextPageContent 不等于 null 且 nextPageContent.isNotEmpty |
| 304 | `              contentList.add(nextPageContent);` | 调用 add(...)：contentList.add(nextPageContent)（添加） |
| 305 | `              AppLog.instance.put('第${contentList.length}页完成');` | 输出日志(put)：“第${contentList.length}页完成” |
| 306 | `            }` | 闭合大括号，结束当前代码块 |
| 307 | `&nbsp;` | 空行，分隔逻辑段落 |
| 308 | `            // 获取下一页URL` | 注释说明：获取下一页URL |
| 309 | `            if (source.ruleContent?.nextContentUrl != null &&` | 条件判断 if：source.ruleContent?.nextContentUrl 不等于 null 且 |
| 310 | `                source.ruleContent!.nextContentUrl!.isNotEmpty) {` | source.ruleContent!.nextContentUrl!.isNotEmpty) { |
| 311 | `              final nextNextUrlList = RuleParser.parseListRule(` | 声明不可重新赋值的(final)变量 nextNextUrlList：调用 RuleParser.parseListRule(...) → 解析 列表 规则 |
| 312 | `                nextHtml,` | 签名/调用续行参数：nextHtml |
| 313 | `                source.ruleContent!.nextContentUrl!,` | source.ruleContent!.nextContentUrl!, |
| 314 | `                variables: null,` | 命名实参 variables: null（变量表） |
| 315 | `                baseUrl: nextRedirectUrl,` | 命名实参 baseUrl: nextRedirectUrl（base URL） |
| 316 | `                returnHtml: false,` | 命名实参 returnHtml: false（return HTML） |
| 317 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 318 | `&nbsp;` | 空行，分隔逻辑段落 |
| 319 | `              // 转换为绝对URL并过滤` | 注释说明：转换为绝对URL并过滤 |
| 320 | `              final filteredNextUrls = <String>[];` | 声明不可重新赋值的(final)变量 filteredNextUrls |
| 321 | `              for (final url in nextNextUrlList) {` | for-in 遍历：final url in nextNextUrlList |
| 322 | `                if (url.isNotEmpty) {` | 条件判断 if：url.isNotEmpty |
| 323 | `                  final absoluteUrl = url.startsWith('http')` | 声明不可重新赋值的(final)变量 absoluteUrl |
| 324 | `                      ? url` | 上一表达式的续行：? url |
| 325 | `                      : NetworkService.joinUrl(nextRedirectUrl, url);` | 三元表达式为假时取值：NetworkService.joinUrl(nextRedirectUrl, url); |
| 326 | `                  if (absoluteUrl != nextRedirectUrl &&` | 条件判断 if：absoluteUrl 不等于 nextRedirectUrl 且 |
| 327 | `                      !visitedUrls.contains(absoluteUrl)) {` | 调用 contains(...)：!visitedUrls.contains(absoluteUrl)) { |
| 328 | `                    // 检查是否到达下一章（参考项目：使用 getAbsoluteURL 规范化后比较）` | 注释说明：检查是否到达下一章（参考项目：使用 getAbsoluteURL 规范化后比较） |
| 329 | `                    if (nextChapterUrl != null) {` | 条件判断 if：nextChapterUrl 不等于 null |
| 330 | `                      final normalizedAbsoluteUrl = NetworkUtils.getAbsoluteURL(` | 声明不可重新赋值的(final)变量 normalizedAbsoluteUrl：调用 NetworkUtils.getAbsoluteURL(...) → 获取 Absolute URL |
| 331 | `                          nextRedirectUrl, absoluteUrl);` | nextRedirectUrl, absoluteUrl) |
| 332 | `                      final normalizedNextChapterUrl =` | 上一表达式的续行：final normalizedNextChapterUrl = |
| 333 | `                          NetworkUtils.getAbsoluteURL(` | 调用 getAbsoluteURL(...)：NetworkUtils.getAbsoluteURL(（获取 Absolute URL） |
| 334 | `                              nextRedirectUrl, nextChapterUrl);` | nextRedirectUrl, nextChapterUrl) |
| 335 | `                      if (_urlEquals(` | 条件判断 if：_urlEquals( |
| 336 | `                          normalizedAbsoluteUrl, normalizedNextChapterUrl)) {` | normalizedAbsoluteUrl, normalizedNextChapterUrl)) { |
| 337 | `                        AppLog.instance.put('检测到下一页URL等于下一章URL，停止获取');` | 输出日志(put)：“检测到下一页URL等于下一章URL，停止获取” |
| 338 | `&nbsp;` | 空行，分隔逻辑段落 |
| 339 | `                        filteredNextUrls.clear();` | 调用 clear(...)：filteredNextUrls.clear() |
| 340 | `                        break;` | break：跳出当前循环/switch |
| 341 | `                      }` | 闭合大括号，结束当前代码块 |
| 342 | `                    }` | 闭合大括号，结束当前代码块 |
| 343 | `                    filteredNextUrls.add(absoluteUrl);` | 调用 add(...)：filteredNextUrls.add(absoluteUrl)（添加） |
| 344 | `                  }` | 闭合大括号，结束当前代码块 |
| 345 | `                }` | 闭合大括号，结束当前代码块 |
| 346 | `              }` | 闭合大括号，结束当前代码块 |
| 347 | `&nbsp;` | 空行，分隔逻辑段落 |
| 348 | `              if (filteredNextUrls.isEmpty) {` | 条件判断 if：filteredNextUrls.isEmpty |
| 349 | `                break;` | break：跳出当前循环/switch |
| 350 | `              }` | 闭合大括号，结束当前代码块 |
| 351 | `              nextUrl = filteredNextUrls[0];` | 将 filteredNextUrls[0] 赋值给 nextUrl |
| 352 | `            } else {` | 闭合上一分支并开始 else 分支 |
| 353 | `              break;` | break：跳出当前循环/switch |
| 354 | `            }` | 闭合大括号，结束当前代码块 |
| 355 | `          } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 356 | `            AppLog.instance.put('获取第 $pageCount 页失败: $e', error: e);` | 输出日志(put)：“获取第 $pageCount 页失败: $e” |
| 357 | `            break;` | break：跳出当前循环/switch |
| 358 | `          }` | 闭合大括号，结束当前代码块 |
| 359 | `        }` | 闭合大括号，结束当前代码块 |
| 360 | `&nbsp;` | 空行，分隔逻辑段落 |
| 361 | `        AppLog.instance.put('本章总页数: ${visitedUrls.length}');` | 输出日志(put)：“本章总页数: ${visitedUrls.length}” |
| 362 | `      } else {` | 闭合上一分支并开始 else 分支 |
| 363 | `        // 参考项目：并发获取所有页面` | 注释说明：参考项目：并发获取所有页面 |
| 364 | `        // 注意：并发模式下也需要过滤掉下一章的URL` | 注释说明：注意：并发模式下也需要过滤掉下一章的URL |
| 365 | `        final filteredNextUrlList = <String>[];` | 声明不可重新赋值的(final)变量 filteredNextUrlList |
| 366 | `        if (nextChapterUrl != null) {` | 条件判断 if：nextChapterUrl 不等于 null |
| 367 | `          // 参考项目：使用 getAbsoluteURL 规范化后比较` | 注释说明：参考项目：使用 getAbsoluteURL 规范化后比较 |
| 368 | `          final normalizedNextChapterUrl =` | 上一表达式的续行：final normalizedNextChapterUrl = |
| 369 | `              NetworkUtils.getAbsoluteURL(redirectUrl, nextChapterUrl);` | 调用 getAbsoluteURL(...)：NetworkUtils.getAbsoluteURL(redirectUrl, nextChapterUrl)（获取 Absolute URL） |
| 370 | `          for (final url in nextUrlList) {` | for-in 遍历：final url in nextUrlList |
| 371 | `            final normalizedUrl = NetworkUtils.getAbsoluteURL(redirectUrl, url);` | 声明不可重新赋值的(final)变量 normalizedUrl：调用 NetworkUtils.getAbsoluteURL(...) → 获取 Absolute URL |
| 372 | `            if (!_urlEquals(normalizedUrl, normalizedNextChapterUrl)) {` | 条件判断 if：!_urlEquals(normalizedUrl, normalizedNextChapterUrl) |
| 373 | `              filteredNextUrlList.add(url);` | 调用 add(...)：filteredNextUrlList.add(url)（添加） |
| 374 | `            } else {` | 闭合上一分支并开始 else 分支 |
| 375 | `              AppLog.instance.put('并发模式：过滤掉下一章URL: $url');` | 输出日志(put)：“并发模式：过滤掉下一章URL: $url” |
| 376 | `            }` | 闭合大括号，结束当前代码块 |
| 377 | `          }` | 闭合大括号，结束当前代码块 |
| 378 | `        } else {` | 闭合上一分支并开始 else 分支 |
| 379 | `          filteredNextUrlList.addAll(nextUrlList);` | 调用 addAll(...)：filteredNextUrlList.addAll(nextUrlList)（添加 全部） |
| 380 | `        }` | 闭合大括号，结束当前代码块 |
| 381 | `&nbsp;` | 空行，分隔逻辑段落 |
| 382 | `        AppLog.instance.put(` | 输出应用日志 AppLog |
| 383 | `            '并发解析正文，总页数: ${filteredNextUrlList.length} (原始: ${nextUrlList.length})');` | 以字符串 '并发解析正文，总页数: ${filteredNextUrlList.lengt… 起始的表达式：); |
| 384 | `&nbsp;` | 空行，分隔逻辑段落 |
| 385 | `        final futures = filteredNextUrlList.asMap().entries.map((entry) async {` | 声明不可重新赋值的(final)变量 futures：调用 filteredNextUrlList.asMap(...) → as 映射 |
| 386 | `          final url = entry.value;` | 声明不可重新赋值的(final)变量 url |
| 387 | `          try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 388 | `            final response = await _networkService.get(` | 声明不可重新赋值的(final)变量 response：await 调用 _networkService.get(...) → 获取 |
| 389 | `              url,` | 签名/调用续行参数：url |
| 390 | `              headers: NetworkService.parseHeaders(source.header),` | 命名实参 headers: NetworkService.parseHeaders(source.header)（请求头） |
| 391 | `              retryCount: 1,` | 命名实参 retryCount: 1（重试 数量） |
| 392 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 393 | `            final pageHtml = await NetworkService.getResponseText(response);` | 声明不可重新赋值的(final)变量 pageHtml：await 调用 NetworkService.getResponseText(...) → 获取 响应 文本 |
| 394 | `            return {'url': url, 'html': pageHtml, 'success': true};` | 返回 {'url': url, 'html': pageHtml, 'success': true}（Map/集合字面量） |
| 395 | `          } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 396 | `            return {'url': url, 'html': '', 'success': false};` | 返回 {'url': url, 'html': '', 'success': false}（Map/集合字面量） |
| 397 | `          }` | 闭合大括号，结束当前代码块 |
| 398 | `        }).toList();` | 闭合代码块并衔接后续语句：).toList(); |
| 399 | `&nbsp;` | 空行，分隔逻辑段落 |
| 400 | `        final results = await Future.wait(futures);` | 声明不可重新赋值的(final)变量 results：await 调用 Future.wait(...) |
| 401 | `&nbsp;` | 空行，分隔逻辑段落 |
| 402 | `        for (final result in results) {` | for-in 遍历：final result in results |
| 403 | `          if (result['success'] == true &&` | 条件判断 if：result['success'] 等于 true 且 |
| 404 | `              (result['html'] as String).isNotEmpty) {` | (result['html'] as String).isNotEmpty) { |
| 405 | `            final pageHtml = result['html'] as String;` | 声明不可重新赋值的(final)变量 pageHtml |
| 406 | `            final pageUrl = result['url'] as String;` | 声明不可重新赋值的(final)变量 pageUrl |
| 407 | `&nbsp;` | 空行，分隔逻辑段落 |
| 408 | `            final pageContent = await RuleParser.parseContentRule(` | 声明不可重新赋值的(final)变量 pageContent：await 调用 RuleParser.parseContentRule(...) → 解析 正文内容 规则 |
| 409 | `              pageHtml,` | 签名/调用续行参数：pageHtml |
| 410 | `              source.ruleContent,` | 签名/调用续行参数：source.ruleContent |
| 411 | `              baseUrl: pageUrl,` | 命名实参 baseUrl: pageUrl（base URL） |
| 412 | `              bookName: bookName,` | 命名实参 bookName: bookName（书籍 Name） |
| 413 | `              bookOrigin: bookOrigin,` | 命名实参 bookOrigin: bookOrigin（书籍 来源） |
| 414 | `              applyReplaceRegex: false,` | 命名实参 applyReplaceRegex: false（apply 替换 正则） |
| 415 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 416 | `&nbsp;` | 空行，分隔逻辑段落 |
| 417 | `            if (pageContent != null && pageContent.isNotEmpty) {` | 条件判断 if：pageContent 不等于 null 且 pageContent.isNotEmpty |
| 418 | `              contentList.add(pageContent);` | 调用 add(...)：contentList.add(pageContent)（添加） |
| 419 | `            }` | 闭合大括号，结束当前代码块 |
| 420 | `          }` | 闭合大括号，结束当前代码块 |
| 421 | `        }` | 闭合大括号，结束当前代码块 |
| 422 | `      }` | 闭合大括号，结束当前代码块 |
| 423 | `&nbsp;` | 空行，分隔逻辑段落 |
| 424 | `      // 合并所有页面的内容` | 注释说明：合并所有页面的内容 |
| 425 | `      if (contentList.isEmpty) {` | 条件判断 if：contentList.isEmpty |
| 426 | `        AppLog.instance.put('章节内容获取失败: 所有页面内容都为空 (章节: ${chapter.title})');` | 输出日志(put)：“章节内容获取失败: 所有页面内容都为空 (章节: ${chapter.title})” |
| 427 | `        throw ContentEmptyException('章节内容为空: ${chapter.title}');` | 定义方法 ContentEmptyException：返回 throw；位置参数 1 个；含命名参数；参数名: 章节内容为空, title。语义：正文内容 空 Exception |
| 428 | `      }` | 闭合大括号，结束当前代码块 |
| 429 | `&nbsp;` | 空行，分隔逻辑段落 |
| 430 | `      // 参考项目：将多页内容拼接在一起` | 注释说明：参考项目：将多页内容拼接在一起 |
| 431 | `      var content = contentList.join('\n');` | 声明自动类型推断(var)变量 content |
| 432 | `      final totalPages = contentList.length;` | 声明不可重新赋值的(final)变量 totalPages |
| 433 | `      AppLog.instance.put(` | 输出应用日志 AppLog |
| 434 | `          '章节内容获取成功: 共 $totalPages 页，合并前总长度=${content.length} (章节: ${chapter.title})');` | 以字符串 '章节内容获取成功: 共 $totalPages 页，合并前总长度=${cont… 起始的表达式：); |
| 435 | `&nbsp;` | 空行，分隔逻辑段落 |
| 436 | `      // 参考项目：在所有页面内容合并后，统一应用replaceRegex规则` | 注释说明：参考项目：在所有页面内容合并后，统一应用replaceRegex规则 |
| 437 | `      // 参考项目逻辑：先将内容按行分割并trim，应用替换规则，然后在每行前添加全角空格` | 注释说明：参考项目逻辑：先将内容按行分割并trim，应用替换规则，然后在每行前添加全角空格 |
| 438 | `      if (source.ruleContent?.replaceRegex != null &&` | 条件判断 if：source.ruleContent?.replaceRegex 不等于 null 且 |
| 439 | `          source.ruleContent!.replaceRegex!.isNotEmpty) {` | source.ruleContent!.replaceRegex!.isNotEmpty) { |
| 440 | `        // #region agent log` | 注释说明：#region agent log |
| 441 | `        try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 442 | `          final f = File(` | 声明不可重新赋值的(final)变量 f |
| 443 | `              '/Users/zhangmingxun/Desktop/legado_flutter/.cursor/debug.log');` | 以字符串 '/Users/zhangmingxun/Desktop/legado_flut… 起始的表达式：); |
| 444 | `          f.writeAsStringSync(` | 调用 writeAsStringSync(...)：f.writeAsStringSync(（写入 As String Sync） |
| 445 | `              '${jsonEncode({` | 调用 jsonEncode(...)：'${jsonEncode({（JSON 编码） |
| 446 | `                    "location": "book_service.dart:2449",` | Map 条目 "location": "book_service.dart:2449", |
| 447 | `                    "message": "book_service应用replaceRegex前",` | Map 条目 "message": "book_service应用replaceRegex前", |
| 448 | `                    "data": {` | Map 条目 "data": { |
| 449 | `                      "replaceRegex": source.ruleContent!.replaceRegex,` | Map 条目 "replaceRegex": source.ruleContent!.replaceRegex, |
| 450 | `                      "contentLength": content.length,` | Map 条目 "contentLength": content.length, |
| 451 | `                      "totalPages": totalPages` | 上一表达式的续行："totalPages": totalPages |
| 452 | `                    },` | 结束上一个列表/参数项 |
| 453 | `                    "timestamp": DateTime.now().millisecondsSinceEpoch,` | Map 条目 "timestamp": DateTime.now().millisecondsSinceEpoch, |
| 454 | `                    "sessionId": "debug-session",` | Map 条目 "sessionId": "debug-session", |
| 455 | `                    "hypothesisId": "D"` | 上一表达式的续行："hypothesisId": "D" |
| 456 | `                  })}\n',` | 闭合代码块并衔接后续语句：)}\n', |
| 457 | `              mode: FileMode.append);` | 命名实参 mode: FileMode.append); |
| 458 | `        } catch (_) {` | 闭合 try 块并捕获异常（忽略异常对象） |
| 459 | `          // 忽略调试日志写入失败，不影响正文处理流程。` | 注释说明：忽略调试日志写入失败，不影响正文处理流程。 |
| 460 | `        }` | 闭合大括号，结束当前代码块 |
| 461 | `        // #endregion` | 注释说明：#endregion |
| 462 | `&nbsp;` | 空行，分隔逻辑段落 |
| 463 | `        AppLog.instance` | 上一表达式的续行：AppLog.instance |
| 464 | `            .put('应用replaceRegex规则: ${source.ruleContent!.replaceRegex}');` | 链式调用延续：.put('应用replaceRegex规则: ${source.ruleContent!.replaceRegex}'); |
| 465 | `&nbsp;` | 空行，分隔逻辑段落 |
| 466 | `        // 参考项目逻辑：按行分割并trim每行` | 注释说明：参考项目逻辑：按行分割并trim每行 |
| 467 | `        final lines = content.split('\n');` | 声明不可重新赋值的(final)变量 lines |
| 468 | `        content = lines.map((line) => line.trim()).join('\n');` | 将 lines.map((line) => line.trim()).join('\n') 赋值给 content（调用 map/trim/join → join） |
| 469 | `&nbsp;` | 空行，分隔逻辑段落 |
| 470 | `        // 应用replaceRegex规则` | 注释说明：应用replaceRegex规则 |
| 471 | `        final beforeReplace = content;` | 声明不可重新赋值的(final)变量 beforeReplace |
| 472 | `        content = RuleParser.applyReplaceRegex(` | 将 RuleParser.applyReplaceRegex( 赋值给 content（调用 applyReplaceRegex → apply 替换 正则） |
| 473 | `            content, source.ruleContent!.replaceRegex!);` | content, source.ruleContent!.replaceRegex!) |
| 474 | `&nbsp;` | 空行，分隔逻辑段落 |
| 475 | `        // 参考项目逻辑：按行分割并在每行前添加全角空格（段落缩进）` | 注释说明：参考项目逻辑：按行分割并在每行前添加全角空格（段落缩进） |
| 476 | `        final processedLines = content.split('\n');` | 声明不可重新赋值的(final)变量 processedLines |
| 477 | `        content = processedLines.map((line) => '　　$line').join('\n');` | 将 processedLines.map((line) => ' $line').join('\n') 赋值给 content（调用 map/join → join） |
| 478 | `&nbsp;` | 空行，分隔逻辑段落 |
| 479 | `        // #region agent log` | 注释说明：#region agent log |
| 480 | `        try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 481 | `          final f = File(` | 声明不可重新赋值的(final)变量 f |
| 482 | `              '/Users/zhangmingxun/Desktop/legado_flutter/.cursor/debug.log');` | 以字符串 '/Users/zhangmingxun/Desktop/legado_flut… 起始的表达式：); |
| 483 | `          f.writeAsStringSync(` | 调用 writeAsStringSync(...)：f.writeAsStringSync(（写入 As String Sync） |
| 484 | `              '${jsonEncode({` | 调用 jsonEncode(...)：'${jsonEncode({（JSON 编码） |
| 485 | `                    "location": "book_service.dart:2469",` | Map 条目 "location": "book_service.dart:2469", |
| 486 | `                    "message": "book_service应用replaceRegex后",` | Map 条目 "message": "book_service应用replaceRegex后", |
| 487 | `                    "data": {` | Map 条目 "data": { |
| 488 | `                      "contentLengthBefore": beforeReplace.length,` | Map 条目 "contentLengthBefore": beforeReplace.length, |
| 489 | `                      "contentLengthAfter": content.length` | 上一表达式的续行："contentLengthAfter": content.length |
| 490 | `                    },` | 结束上一个列表/参数项 |
| 491 | `                    "timestamp": DateTime.now().millisecondsSinceEpoch,` | Map 条目 "timestamp": DateTime.now().millisecondsSinceEpoch, |
| 492 | `                    "sessionId": "debug-session",` | Map 条目 "sessionId": "debug-session", |
| 493 | `                    "hypothesisId": "D"` | 上一表达式的续行："hypothesisId": "D" |
| 494 | `                  })}\n',` | 闭合代码块并衔接后续语句：)}\n', |
| 495 | `              mode: FileMode.append);` | 命名实参 mode: FileMode.append); |
| 496 | `        } catch (_) {` | 闭合 try 块并捕获异常（忽略异常对象） |
| 497 | `          // 忽略调试日志写入失败，不影响正文处理流程。` | 注释说明：忽略调试日志写入失败，不影响正文处理流程。 |
| 498 | `        }` | 闭合大括号，结束当前代码块 |
| 499 | `        // #endregion` | 注释说明：#endregion |
| 500 | `&nbsp;` | 空行，分隔逻辑段落 |
| 501 | `        AppLog.instance.put('应用replaceRegex后，内容长度=${content.length}');` | 输出日志(put)：“应用replaceRegex后，内容长度=${content.length}” |
| 502 | `      }` | 闭合大括号，结束当前代码块 |
| 503 | `&nbsp;` | 空行，分隔逻辑段落 |
| 504 | `      // 输出章节内容 前500 字符` | 注释说明：输出章节内容 前500 字符 |
| 505 | `      // 输出章节内容 后500 字符` | 注释说明：输出章节内容 后500 字符 |
| 506 | `      // 参考项目：在返回内容前立即保存到缓存（BookHelp.saveText）` | 注释说明：参考项目：在返回内容前立即保存到缓存（BookHelp.saveText） |
| 507 | `      // 这样可以避免 _loadingChapters 移除后、缓存写入前的竞态条件` | 注释说明：这样可以避免 _loadingChapters 移除后、缓存写入前的竞态条件 |
| 508 | `      if (book != null && !book.isLocal) {` | 条件判断 if：book 不等于 null 且 !book.isLocal |
| 509 | `        // ✅ 新策略: 保存到文件存储` | 注释说明：✅ 新策略: 保存到文件存储 |
| 510 | `        final localPath = await readService(AppServices.chapterContentService)` | 声明不可重新赋值的(final)变量 localPath：await 调用 readService(...) → 读取 Service |
| 511 | `            .saveChapterContent(book, chapter, content);` | 链式调用延续：.saveChapterContent(book, chapter, content); |
| 512 | `&nbsp;` | 空行，分隔逻辑段落 |
| 513 | `        if (localPath != null) {` | 条件判断 if：localPath 不等于 null |
| 514 | `          // 更新内存中的chapter对象` | 注释说明：更新内存中的chapter对象 |
| 515 | `          chapter.localPath = localPath;` | 将 localPath 赋值给 chapter.localPath |
| 516 | `          // 异步更新数据库,不阻塞返回` | 注释说明：异步更新数据库,不阻塞返回 |
| 517 | `          _updateChapterLocalPath(chapter.bookUrl, chapter.url, localPath)` | 调用 _updateChapterLocalPath(...)：_updateChapterLocalPath(chapter.bookUrl, chapter.url, localPath)（更新 章节 本地 Path） |
| 518 | `              .catchError(` | 链式调用延续：.catchError( |
| 519 | `                  (e) => AppLog.instance.put('更新localPath失败', error: e));` | 输出日志(put)：“更新localPath失败” |
| 520 | `        }` | 闭合大括号，结束当前代码块 |
| 521 | `&nbsp;` | 空行，分隔逻辑段落 |
| 522 | `        // 同时保存到旧缓存(向后兼容)` | 注释说明：同时保存到旧缓存(向后兼容) |
| 523 | `        await readService(AppServices.cacheService)` | 调用 readService(...)（等待异步完成） → 读取 Service |
| 524 | `            .saveChapterContent(book, chapter, content);` | 链式调用延续：.saveChapterContent(book, chapter, content); |
| 525 | `      } else if (book == null) {` | 闭合上一代码块并开始 else if (book == null) { |
| 526 | `        // 未传入 book 参数，尝试从数据库查询（向后兼容）` | 注释说明：未传入 book 参数，尝试从数据库查询（向后兼容） |
| 527 | `        try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 528 | `          final dbBook = await getBookByUrl(chapter.bookUrl);` | 声明不可重新赋值的(final)变量 dbBook：await 调用 getBookByUrl(...) → 获取 书籍 By URL |
| 529 | `          if (dbBook != null && !dbBook.isLocal) {` | 条件判断 if：dbBook 不等于 null 且 !dbBook.isLocal |
| 530 | `            await readService(AppServices.cacheService)` | 调用 readService(...)（等待异步完成） → 读取 Service |
| 531 | `                .saveChapterContent(dbBook, chapter, content);` | 链式调用延续：.saveChapterContent(dbBook, chapter, content); |
| 532 | `          }` | 闭合大括号，结束当前代码块 |
| 533 | `        } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 534 | `          // 缓存失败不影响返回内容` | 注释说明：缓存失败不影响返回内容 |
| 535 | `        }` | 闭合大括号，结束当前代码块 |
| 536 | `      }` | 闭合大括号，结束当前代码块 |
| 537 | `&nbsp;` | 空行，分隔逻辑段落 |
| 538 | `      return content;` | 返回 content |
| 539 | `    } catch (e, stackTrace) {` | 闭合 try 块并捕获异常，异常变量：e, stackTrace |
| 540 | `      AppLog.instance.put('获取章节内容失败', error: e);` | 输出日志(put)：“获取章节内容失败” |
| 541 | `      AppLog.instance.put('错误堆栈: $stackTrace');` | 输出日志(put)：“错误堆栈: $stackTrace” |
| 542 | `      AppLog.instance.put('章节URL: ${chapter.url}, 章节标题: ${chapter.title}');` | 输出日志(put)：“章节URL: ${chapter.url}, 章节标题: ${chapter.title}” |
| 543 | `      return null;` | 返回 null（初始为 null） |
| 544 | `    }` | 闭合大括号，结束当前代码块 |
| 545 | `  }` | 闭合大括号，结束当前代码块 |
| 546 | `&nbsp;` | 空行，分隔逻辑段落 |
| 547 | `  /// 保存书籍到书架` | 文档注释：说明其后代码的用途 |
