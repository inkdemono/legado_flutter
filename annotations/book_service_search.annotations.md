# book_service_search.dart 逐行注释

> 源文件：`lib/services/book/book_service_search.dart`（共 415 行）
>
> 本文件由 `scripts/gen_line_annotations.py` 自动生成，对源文件每一行给出独立说明。
> 说明优先采用源码自带的中文注释；无注释的行依据 Dart 语法特征自动生成解释。

| 行号 | 源代码 | 说明 |
| ---: | --- | --- |
| 1 | `part of 'book_service.dart';` | 声明本文件是 book_service.dart 库的一部分(part)，与其共享同一命名空间 |
| 2 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 4 | `// BookService 职责：书源搜索（单源/多源聚合）与书籍详情解析。` | 注释说明：BookService 职责：书源搜索（单源/多源聚合）与书籍详情解析。 |
| 5 | `// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）` | 注释说明：（part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号） |
| 6 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 7 | `&nbsp;` | 空行，分隔逻辑段落 |
| 8 | `  /// 从单个书源搜索书籍` | 文档注释：说明其后代码的用途 |
| 9 | `  /// 供SearchModel使用` | 文档注释：说明其后代码的用途 |
| 10 | `  Future<List<Book>> searchBooksFromSource(` | 【承接上方文档】从单个书源搜索书籍 供SearchModel使用 → 定义方法 searchBooksFromSource：返回 Future<List<Book>>；无参数（异步）。语义：搜索 Books From 书源 |
| 11 | `    BookSource source,` | BookSource 类型参数 source（书源） |
| 12 | `    String keyword,` | String 类型参数 keyword |
| 13 | `    bool precisionSearch,` | bool 类型参数 precisionSearch（precision 搜索） |
| 14 | `  ) async {` | ) async { |
| 15 | `    final results = <Book>[];` | 声明不可重新赋值的(final)变量 results |
| 16 | `&nbsp;` | 空行，分隔逻辑段落 |
| 17 | `    try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 18 | `      await ConcurrentRateLimiter(source).withLimit(() async {` | 调用 ConcurrentRateLimiter(...)（等待异步完成） → 并发 速率 Limiter |
| 19 | `        final searchUrl = _buildSearchUrl(source.searchUrl!, keyword);` | 声明不可重新赋值的(final)变量 searchUrl：调用 _buildSearchUrl(...) → 构建 搜索 URL |
| 20 | `        final fullUrl = NetworkService.joinUrl(source.bookSourceUrl, searchUrl);` | 声明不可重新赋值的(final)变量 fullUrl：调用 NetworkService.joinUrl(...) → join URL |
| 21 | `&nbsp;` | 空行，分隔逻辑段落 |
| 22 | `        final response = await _networkService.get(` | 声明不可重新赋值的(final)变量 response：await 调用 _networkService.get(...) → 获取 |
| 23 | `          fullUrl,` | 签名/调用续行参数：fullUrl |
| 24 | `          headers: NetworkService.parseHeaders(source.header),` | 命名实参 headers: NetworkService.parseHeaders(source.header)（请求头） |
| 25 | `          retryCount: 1,` | 命名实参 retryCount: 1（重试 数量） |
| 26 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 27 | `&nbsp;` | 空行，分隔逻辑段落 |
| 28 | `        final html = await NetworkService.getResponseText(response);` | 声明不可重新赋值的(final)变量 html：await 调用 NetworkService.getResponseText(...) → 获取 响应 文本 |
| 29 | `        final searchResults = await RuleParser.parseSearchRule(` | 声明不可重新赋值的(final)变量 searchResults：await 调用 RuleParser.parseSearchRule(...) → 解析 搜索 规则 |
| 30 | `          html,` | 签名/调用续行参数：html |
| 31 | `          source.ruleSearch,` | 签名/调用续行参数：source.ruleSearch |
| 32 | `          variables: {'keyword': keyword},` | 命名实参 variables: {'keyword': keyword}（变量表） |
| 33 | `          baseUrl: fullUrl,` | 命名实参 baseUrl: fullUrl（base URL） |
| 34 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 35 | `&nbsp;` | 空行，分隔逻辑段落 |
| 36 | `        for (final result in searchResults) {` | for-in 遍历：final result in searchResults |
| 37 | `          final bookUrl = result['bookUrl'];` | 声明不可重新赋值的(final)变量 bookUrl |
| 38 | `          if (bookUrl == null \|\| bookUrl.isEmpty) continue;` | 条件判断 if：bookUrl 等于 null 或 bookUrl.isEmpty) continue; |
| 39 | `&nbsp;` | 空行，分隔逻辑段落 |
| 40 | `          if (source.ruleSearch?.checkKeyWord != null &&` | 条件判断 if：source.ruleSearch?.checkKeyWord 不等于 null 且 |
| 41 | `              source.ruleSearch!.checkKeyWord!.isNotEmpty) {` | source.ruleSearch!.checkKeyWord!.isNotEmpty) { |
| 42 | `            final checkKeyWordValue = result['checkKeyWord'];` | 声明不可重新赋值的(final)变量 checkKeyWordValue |
| 43 | `            if (checkKeyWordValue == null \|\| checkKeyWordValue.isEmpty) {` | 条件判断 if：checkKeyWordValue 等于 null 或 checkKeyWordValue.isEmpty |
| 44 | `              continue;` | continue：进入下一次循环迭代 |
| 45 | `            }` | 闭合大括号，结束当前代码块 |
| 46 | `          }` | 闭合大括号，结束当前代码块 |
| 47 | `&nbsp;` | 空行，分隔逻辑段落 |
| 48 | `          final finalBookUrl =` | 上一表达式的续行：final finalBookUrl = |
| 49 | `              bookUrl.startsWith('http://') \|\| bookUrl.startsWith('https://')` | 调用 startsWith(...)：bookUrl.startsWith('http://') \|\| bookUrl.startsWith('https://') |
| 50 | `                  ? bookUrl` | 上一表达式的续行：? bookUrl |
| 51 | `                  : NetworkService.joinUrl(source.bookSourceUrl, bookUrl);` | 三元表达式为假时取值：NetworkService.joinUrl(source.bookSourceUrl, bookUrl); |
| 52 | `&nbsp;` | 空行，分隔逻辑段落 |
| 53 | `          final book = Book(` | 声明不可重新赋值的(final)变量 book：调用 Book(...) → 书籍 |
| 54 | `            bookUrl: finalBookUrl,` | 命名实参 bookUrl: finalBookUrl（书籍 URL） |
| 55 | `            origin: source.bookSourceUrl,` | 命名实参 origin: source.bookSourceUrl（来源） |
| 56 | `            originName: source.bookSourceName,` | 命名实参 originName: source.bookSourceName（来源 Name） |
| 57 | `            name: result['name'] ?? '',` | 命名实参 name: result['name'] ?? '' |
| 58 | `            author: result['author'] ?? '',` | 命名实参 author: result['author'] ?? ''（作者） |
| 59 | `            kind: result['kind'],` | 命名实参 kind: result['kind']（类别） |
| 60 | `            coverUrl: result['coverUrl'],` | 命名实参 coverUrl: result['coverUrl']（封面 URL） |
| 61 | `            intro: result['intro'],` | 命名实参 intro: result['intro']（简介） |
| 62 | `            wordCount: result['wordCount'],` | 命名实参 wordCount: result['wordCount']（word 数量） |
| 63 | `            latestChapterTitle: result['lastChapter'],` | 命名实参 latestChapterTitle: result['lastChapter']（latest 章节 标题） |
| 64 | `            canUpdate: true,` | 命名实参 canUpdate: true（can 更新） |
| 65 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 66 | `&nbsp;` | 空行，分隔逻辑段落 |
| 67 | `          if (precisionSearch) {` | 条件判断 if：precisionSearch |
| 68 | `            final keywordLower = keyword.toLowerCase();` | 声明不可重新赋值的(final)变量 keywordLower |
| 69 | `            final nameLower = book.name.toLowerCase();` | 声明不可重新赋值的(final)变量 nameLower |
| 70 | `            final authorLower = book.author.toLowerCase();` | 声明不可重新赋值的(final)变量 authorLower |
| 71 | `&nbsp;` | 空行，分隔逻辑段落 |
| 72 | `            if (nameLower != keywordLower &&` | 条件判断 if：nameLower 不等于 keywordLower 且 |
| 73 | `                authorLower != keywordLower &&` | 上一表达式的续行：authorLower != keywordLower && |
| 74 | `                !(nameLower.contains(keywordLower) &&` | 调用 contains(...)：!(nameLower.contains(keywordLower) && |
| 75 | `                    authorLower.contains(keywordLower))) {` | 调用 contains(...)：authorLower.contains(keywordLower))) { |
| 76 | `              continue;` | continue：进入下一次循环迭代 |
| 77 | `            }` | 闭合大括号，结束当前代码块 |
| 78 | `          }` | 闭合大括号，结束当前代码块 |
| 79 | `&nbsp;` | 空行，分隔逻辑段落 |
| 80 | `          results.add(book);` | 调用 add(...)：results.add(book)（添加） |
| 81 | `        }` | 闭合大括号，结束当前代码块 |
| 82 | `      });` | 闭合代码块并衔接后续语句：); |
| 83 | `    } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 84 | `      AppLog.instance.put('书源搜索失败: ${source.bookSourceName}', error: e);` | 输出日志(put)：“书源搜索失败: ${source.bookSourceName}” |
| 85 | `    }` | 闭合大括号，结束当前代码块 |
| 86 | `&nbsp;` | 空行，分隔逻辑段落 |
| 87 | `    return results;` | 返回 results |
| 88 | `  }` | 闭合大括号，结束当前代码块 |
| 89 | `&nbsp;` | 空行，分隔逻辑段落 |
| 90 | `  /// 搜索书籍` | 文档注释：说明其后代码的用途 |
| 91 | `  Future<List<Book>> searchBooks(` | 【承接上方文档】搜索书籍 → 定义方法 searchBooks：返回 Future<List<Book>>；无参数（异步）。语义：搜索 Books |
| 92 | `    String keyword, {` | String 类型参数 keyword，其后 { 开启命名参数块 |
| 93 | `    List<BookSource>? sources,` | List<BookSource>? 类型参数 sources |
| 94 | `    bool precisionSearch = false,` | bool 类型参数 precisionSearch，默认值 false（precision 搜索） |
| 95 | `    Function(int current, int total)? onProgress,` | 构造函数 Function位置参数 2 个；参数名: current, total, onProgress |
| 96 | `    Function(Book book)? onResult, // 新增：找到结果时的回调` | 构造函数 Function位置参数 1 个；参数名: book, onResult；行尾注释：新增：找到结果时的回调 |
| 97 | `  }) async {` | 签名结束，进入异步方法体 }) async { |
| 98 | `    if (keyword.isEmpty) return [];` | 条件判断 if：keyword.isEmpty) return []; |
| 99 | `&nbsp;` | 空行，分隔逻辑段落 |
| 100 | `    // 如果没有指定书源，获取所有启用的书源` | 注释说明：如果没有指定书源，获取所有启用的书源 |
| 101 | `    sources ??= await _bookSourceService.getAllBookSources(enabledOnly: true);` | 调用 getAllBookSources(...)：sources ??= await _bookSourceService.getAllBookSources(enabledOnly: true)（获取 全部 书籍 Sources） |
| 102 | `&nbsp;` | 空行，分隔逻辑段落 |
| 103 | `    // 过滤出有效的书源（启用且有搜索规则）` | 注释说明：过滤出有效的书源（启用且有搜索规则） |
| 104 | `    final validSources = sources.where((source) {` | 声明不可重新赋值的(final)变量 validSources |
| 105 | `      return source.enabled &&` | 上一表达式的续行：return source.enabled && |
| 106 | `          source.searchUrl != null &&` | 上一表达式的续行：source.searchUrl != null && |
| 107 | `          source.ruleSearch != null;` | source.ruleSearch != null |
| 108 | `    }).toList();` | 闭合代码块并衔接后续语句：).toList(); |
| 109 | `&nbsp;` | 空行，分隔逻辑段落 |
| 110 | `    final totalSources = validSources.length;` | 声明不可重新赋值的(final)变量 totalSources |
| 111 | `    final results = <Book>[];` | 声明不可重新赋值的(final)变量 results |
| 112 | `    int currentIndex = 0;` | int currentIndex = 0 |
| 113 | `&nbsp;` | 空行，分隔逻辑段落 |
| 114 | `    for (final source in validSources) {` | for-in 遍历：final source in validSources |
| 115 | `      currentIndex++;` | currentIndex++ |
| 116 | `&nbsp;` | 空行，分隔逻辑段落 |
| 117 | `      // 报告进度` | 注释说明：报告进度 |
| 118 | `      if (onProgress != null) {` | 条件判断 if：onProgress 不等于 null |
| 119 | `        onProgress(currentIndex, totalSources);` | 调用 onProgress(...)：onProgress(currentIndex, totalSources)（on 进度） |
| 120 | `      }` | 闭合大括号，结束当前代码块 |
| 121 | `&nbsp;` | 空行，分隔逻辑段落 |
| 122 | `      try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 123 | `        // 使用并发限流器（参考项目：ConcurrentRateLimiter）` | 注释说明：使用并发限流器（参考项目：ConcurrentRateLimiter） |
| 124 | `        await ConcurrentRateLimiter(source).withLimit(() async {` | 调用 ConcurrentRateLimiter(...)（等待异步完成） → 并发 速率 Limiter |
| 125 | `          // 构建搜索URL（替换关键字）` | 注释说明：构建搜索URL（替换关键字） |
| 126 | `          final searchUrl = _buildSearchUrl(source.searchUrl!, keyword);` | 声明不可重新赋值的(final)变量 searchUrl：调用 _buildSearchUrl(...) → 构建 搜索 URL |
| 127 | `          // 构建完整URL（处理相对路径）` | 注释说明：构建完整URL（处理相对路径） |
| 128 | `          final fullUrl =` | 上一表达式的续行：final fullUrl = |
| 129 | `              NetworkService.joinUrl(source.bookSourceUrl, searchUrl);` | 调用 joinUrl(...)：NetworkService.joinUrl(source.bookSourceUrl, searchUrl)（join URL） |
| 130 | `&nbsp;` | 空行，分隔逻辑段落 |
| 131 | `          // 使用协议处理器发送请求（支持HTTP/JSON/WebView）` | 注释说明：使用协议处理器发送请求（支持HTTP/JSON/WebView） |
| 132 | `          final responseText = await _request(` | 声明不可重新赋值的(final)变量 responseText：await 调用 _request(...) → 请求 |
| 133 | `            fullUrl,` | 签名/调用续行参数：fullUrl |
| 134 | `            source,` | 签名/调用续行参数：source |
| 135 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 136 | `&nbsp;` | 空行，分隔逻辑段落 |
| 137 | `          final html = responseText;` | 声明不可重新赋值的(final)变量 html |
| 138 | `          AppLog.instance.put('搜索响应: 内容长度=${html.length}, URL=$fullUrl');` | 输出日志(put)：“搜索响应: 内容长度=${html.length}, URL=$fullUrl” |
| 139 | `&nbsp;` | 空行，分隔逻辑段落 |
| 140 | `          // 输出响应内容的前500个字符用于调试` | 注释说明：输出响应内容的前500个字符用于调试 |
| 141 | `          if (html.isNotEmpty) {` | 条件判断 if：html.isNotEmpty |
| 142 | `            final preview =` | 上一表达式的续行：final preview = |
| 143 | `                html.length > 500 ? '${html.substring(0, 500)}...' : html;` | 调用 substring(...)：html.length > 500 ? '${html.substring(0, 500)}...' : html |
| 144 | `            AppLog.instance.put(` | 输出应用日志 AppLog |
| 145 | `                '搜索响应内容预览 (前${html.length > 500 ? 500 : html.length}字符):\n$preview');` | 以字符串 '搜索响应内容预览 (前${html.length > 500 ? 500 : … 起始的表达式：); |
| 146 | `          }` | 闭合大括号，结束当前代码块 |
| 147 | `&nbsp;` | 空行，分隔逻辑段落 |
| 148 | `          // 解析搜索结果` | 注释说明：解析搜索结果 |
| 149 | `          // 使用实际请求的URL作为baseUrl（参考项目中的做法）` | 注释说明：使用实际请求的URL作为baseUrl（参考项目中的做法） |
| 150 | `          final searchResults = await RuleParser.parseSearchRule(` | 声明不可重新赋值的(final)变量 searchResults：await 调用 RuleParser.parseSearchRule(...) → 解析 搜索 规则 |
| 151 | `            html,` | 签名/调用续行参数：html |
| 152 | `            source.ruleSearch,` | 签名/调用续行参数：source.ruleSearch |
| 153 | `            variables: {'keyword': keyword},` | 命名实参 variables: {'keyword': keyword}（变量表） |
| 154 | `            baseUrl: fullUrl, // 使用实际请求的URL，而不是书源的基础URL` | 命名实参 baseUrl: fullUrl（base URL）；行尾注释：使用实际请求的URL，而不是书源的基础URL |
| 155 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 156 | `&nbsp;` | 空行，分隔逻辑段落 |
| 157 | `          // 转换为Book对象` | 注释说明：转换为Book对象 |
| 158 | `          for (final result in searchResults) {` | for-in 遍历：final result in searchResults |
| 159 | `            final bookUrl = result['bookUrl'];` | 声明不可重新赋值的(final)变量 bookUrl |
| 160 | `            if (bookUrl == null \|\| bookUrl.isEmpty) continue;` | 条件判断 if：bookUrl 等于 null 或 bookUrl.isEmpty) continue; |
| 161 | `&nbsp;` | 空行，分隔逻辑段落 |
| 162 | `            // 检查 checkKeyWord 规则（如果存在）` | 注释说明：检查 checkKeyWord 规则（如果存在） |
| 163 | `            // 参考项目：checkKeyWord 用于验证搜索结果是否包含关键词` | 注释说明：参考项目：checkKeyWord 用于验证搜索结果是否包含关键词 |
| 164 | `            // 如果规则存在且解析结果为空，说明搜索结果无效，跳过` | 注释说明：如果规则存在且解析结果为空，说明搜索结果无效，跳过 |
| 165 | `            if (source.ruleSearch?.checkKeyWord != null &&` | 条件判断 if：source.ruleSearch?.checkKeyWord 不等于 null 且 |
| 166 | `                source.ruleSearch!.checkKeyWord!.isNotEmpty) {` | source.ruleSearch!.checkKeyWord!.isNotEmpty) { |
| 167 | `              final checkKeyWordValue = result['checkKeyWord'];` | 声明不可重新赋值的(final)变量 checkKeyWordValue |
| 168 | `              // 如果 checkKeyWord 规则存在但解析结果为空，说明搜索结果不匹配，跳过` | 注释说明：如果 checkKeyWord 规则存在但解析结果为空，说明搜索结果不匹配，跳过 |
| 169 | `              if (checkKeyWordValue == null \|\| checkKeyWordValue.isEmpty) {` | 条件判断 if：checkKeyWordValue 等于 null 或 checkKeyWordValue.isEmpty |
| 170 | `                AppLog.instance.put('搜索结果未通过checkKeyWord验证，跳过');` | 输出日志(put)：“搜索结果未通过checkKeyWord验证，跳过” |
| 171 | `                continue;` | continue：进入下一次循环迭代 |
| 172 | `              }` | 闭合大括号，结束当前代码块 |
| 173 | `            }` | 闭合大括号，结束当前代码块 |
| 174 | `&nbsp;` | 空行，分隔逻辑段落 |
| 175 | `            // 如果bookUrl已经是绝对URL，直接使用；否则相对于书源URL处理` | 注释说明：如果bookUrl已经是绝对URL，直接使用；否则相对于书源URL处理 |
| 176 | `            final finalBookUrl =` | 上一表达式的续行：final finalBookUrl = |
| 177 | `                bookUrl.startsWith('http://') \|\| bookUrl.startsWith('https://')` | 调用 startsWith(...)：bookUrl.startsWith('http://') \|\| bookUrl.startsWith('https://') |
| 178 | `                    ? bookUrl` | 上一表达式的续行：? bookUrl |
| 179 | `                    : NetworkService.joinUrl(source.bookSourceUrl, bookUrl);` | 三元表达式为假时取值：NetworkService.joinUrl(source.bookSourceUrl, bookUrl); |
| 180 | `&nbsp;` | 空行，分隔逻辑段落 |
| 181 | `            final kindValue = result['kind'];` | 声明不可重新赋值的(final)变量 kindValue |
| 182 | `            // 添加调试日志（仅前3个结果）` | 注释说明：添加调试日志（仅前3个结果） |
| 183 | `            if (results.length < 3) {` | 条件判断 if：results.length < 3 |
| 184 | `              AppLog.instance.put(` | 输出应用日志 AppLog |
| 185 | `                  'searchBooks: 创建Book对象 - name=${result['name']}, author=${result['author']}, kind=$kindValue, kind规则=${source.ruleSearch?.kind}');` | 以字符串 'searchBooks: 创建Book对象 - name=${result[' 起始的表达式：name']}, author=${result['author']}, kind=$kindValue, kind规则… |
| 186 | `            }` | 闭合大括号，结束当前代码块 |
| 187 | `&nbsp;` | 空行，分隔逻辑段落 |
| 188 | `            final book = Book(` | 声明不可重新赋值的(final)变量 book：调用 Book(...) → 书籍 |
| 189 | `              bookUrl: finalBookUrl,` | 命名实参 bookUrl: finalBookUrl（书籍 URL） |
| 190 | `              origin: source.bookSourceUrl,` | 命名实参 origin: source.bookSourceUrl（来源） |
| 191 | `              originName: source.bookSourceName,` | 命名实参 originName: source.bookSourceName（来源 Name） |
| 192 | `              name: result['name'] ?? '',` | 命名实参 name: result['name'] ?? '' |
| 193 | `              author: result['author'] ?? '',` | 命名实参 author: result['author'] ?? ''（作者） |
| 194 | `              kind: kindValue,` | 命名实参 kind: kindValue（类别） |
| 195 | `              // coverUrl已经在parseRule中使用实际请求的URL（fullUrl）作为baseUrl处理过了` | 注释说明：coverUrl已经在parseRule中使用实际请求的URL（fullUrl）作为baseUrl处理过了 |
| 196 | `              // 参考项目中，封面URL使用当前页面URL作为baseUrl，parseRule已经处理` | 注释说明：参考项目中，封面URL使用当前页面URL作为baseUrl，parseRule已经处理 |
| 197 | `              coverUrl: result['coverUrl'],` | 命名实参 coverUrl: result['coverUrl']（封面 URL） |
| 198 | `              intro: result['intro'],` | 命名实参 intro: result['intro']（简介） |
| 199 | `              wordCount: result['wordCount'],` | 命名实参 wordCount: result['wordCount']（word 数量） |
| 200 | `              latestChapterTitle: result['lastChapter'],` | 命名实参 latestChapterTitle: result['lastChapter']（latest 章节 标题） |
| 201 | `              canUpdate: true,` | 命名实参 canUpdate: true（can 更新） |
| 202 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 203 | `&nbsp;` | 空行，分隔逻辑段落 |
| 204 | `            // 精确搜索模式：只保留书名或作者完全匹配的结果` | 注释说明：精确搜索模式：只保留书名或作者完全匹配的结果 |
| 205 | `            if (precisionSearch) {` | 条件判断 if：precisionSearch |
| 206 | `              final keywordLower = keyword.toLowerCase();` | 声明不可重新赋值的(final)变量 keywordLower |
| 207 | `              final nameLower = book.name.toLowerCase();` | 声明不可重新赋值的(final)变量 nameLower |
| 208 | `              final authorLower = book.author.toLowerCase();` | 声明不可重新赋值的(final)变量 authorLower |
| 209 | `&nbsp;` | 空行，分隔逻辑段落 |
| 210 | `              if (nameLower != keywordLower &&` | 条件判断 if：nameLower 不等于 keywordLower 且 |
| 211 | `                  authorLower != keywordLower &&` | 上一表达式的续行：authorLower != keywordLower && |
| 212 | `                  !(nameLower.contains(keywordLower) &&` | 调用 contains(...)：!(nameLower.contains(keywordLower) && |
| 213 | `                      authorLower.contains(keywordLower))) {` | 调用 contains(...)：authorLower.contains(keywordLower))) { |
| 214 | `                continue; // 跳过不匹配的结果` | continue：进入下一次循环迭代；行尾注释：跳过不匹配的结果 |
| 215 | `              }` | 闭合大括号，结束当前代码块 |
| 216 | `            }` | 闭合大括号，结束当前代码块 |
| 217 | `&nbsp;` | 空行，分隔逻辑段落 |
| 218 | `            results.add(book);` | 调用 add(...)：results.add(book)（添加） |
| 219 | `&nbsp;` | 空行，分隔逻辑段落 |
| 220 | `            // 立即回调新结果` | 注释说明：立即回调新结果 |
| 221 | `            if (onResult != null) {` | 条件判断 if：onResult 不等于 null |
| 222 | `              onResult(book);` | 调用 onResult(...)：onResult(book) |
| 223 | `            }` | 闭合大括号，结束当前代码块 |
| 224 | `          }` | 闭合大括号，结束当前代码块 |
| 225 | `        });` | 闭合代码块并衔接后续语句：); |
| 226 | `      } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 227 | `        // 搜索失败，记录日志并继续下一个书源` | 注释说明：搜索失败，记录日志并继续下一个书源 |
| 228 | `        AppLog.instance.put('书源搜索失败: ${source.bookSourceName}', error: e);` | 输出日志(put)：“书源搜索失败: ${source.bookSourceName}” |
| 229 | `        continue;` | continue：进入下一次循环迭代 |
| 230 | `      }` | 闭合大括号，结束当前代码块 |
| 231 | `    }` | 闭合大括号，结束当前代码块 |
| 232 | `&nbsp;` | 空行，分隔逻辑段落 |
| 233 | `    return results;` | 返回 results |
| 234 | `  }` | 闭合大括号，结束当前代码块 |
| 235 | `&nbsp;` | 空行，分隔逻辑段落 |
| 236 | `  /// 获取书籍详情` | 文档注释：说明其后代码的用途 |
| 237 | `  Future<Book?> getBookInfo(Book book) async {` | 【承接上方文档】获取书籍详情 → 定义方法 getBookInfo：返回 Future<Book?>；位置参数 1 个；含命名参数；参数名: book（异步）。语义：获取 书籍 Info |
| 238 | `    if (book.isLocal) {` | 条件判断 if：book.isLocal |
| 239 | `      // 本地书籍不需要获取详情` | 注释说明：本地书籍不需要获取详情 |
| 240 | `      return book;` | 返回 book |
| 241 | `    }` | 闭合大括号，结束当前代码块 |
| 242 | `&nbsp;` | 空行，分隔逻辑段落 |
| 243 | `    final source = await _bookSourceService.getBookSourceByUrl(book.origin);` | 声明不可重新赋值的(final)变量 source：await 调用 _bookSourceService.getBookSourceByUrl(...) → 获取 书籍 书源 By URL |
| 244 | `    if (source == null \|\| source.ruleBookInfo == null) {` | 条件判断 if：source 等于 null 或 source.ruleBookInfo 等于 null |
| 245 | `      AppLog.instance.put('getBookInfo: 书源不存在或详情规则为空');` | 输出日志(put)：“getBookInfo: 书源不存在或详情规则为空” |
| 246 | `      return book;` | 返回 book |
| 247 | `    }` | 闭合大括号，结束当前代码块 |
| 248 | `&nbsp;` | 空行，分隔逻辑段落 |
| 249 | `    try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 250 | `      AppLog.instance.put('getBookInfo: 开始获取书籍详情，bookUrl=${book.bookUrl}');` | 输出日志(put)：“getBookInfo: 开始获取书籍详情，bookUrl=${book.bookUrl}” |
| 251 | `&nbsp;` | 空行，分隔逻辑段落 |
| 252 | `      // 使用并发限流器（参考项目：ConcurrentRateLimiter）` | 注释说明：使用并发限流器（参考项目：ConcurrentRateLimiter） |
| 253 | `      final updatedBook =` | 上一表达式的续行：final updatedBook = |
| 254 | `          await ConcurrentRateLimiter(source).withLimit(() async {` | 调用 ConcurrentRateLimiter(...)（等待异步完成） → 并发 速率 Limiter |
| 255 | `        String html = '';` | String html = '' |
| 256 | `        bool usedCachedInfoHtml = false;` | bool usedCachedInfoHtml = false |
| 257 | `&nbsp;` | 空行，分隔逻辑段落 |
| 258 | `        if (book.infoHtml != null && book.infoHtml!.isNotEmpty) {` | 条件判断 if：book.infoHtml 不等于 null 且 book.infoHtml!.isNotEmpty |
| 259 | `          html = book.infoHtml!;` | 将 book.infoHtml! 赋值给 html |
| 260 | `          usedCachedInfoHtml = true;` | 将 true 赋值给 usedCachedInfoHtml |
| 261 | `          AppLog.instance.put(` | 输出应用日志 AppLog |
| 262 | `            'getBookInfo: 使用列表页透传HTML，内容长度=${html.length}, URL=${book.bookUrl}',` | 以字符串 'getBookInfo: 使用列表页透传HTML，内容长度=${html.le… 起始的表达式：, |
| 263 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 264 | `        } else {` | 闭合上一分支并开始 else 分支 |
| 265 | `          html = await _fetchBookInfoHtml(book, source);` | 将 等待异步结果：await _fetchBookInfoHtml(book, source) 赋值给 html（调用 _fetchBookInfoHtml → 拉取 书籍 Info HTML） |
| 266 | `        }` | 闭合大括号，结束当前代码块 |
| 267 | `&nbsp;` | 空行，分隔逻辑段落 |
| 268 | `        var bookInfo = await RuleParser.parseBookInfoRule(` | 声明自动类型推断(var)变量 bookInfo：await 调用 RuleParser.parseBookInfoRule(...) → 解析 书籍 Info 规则 |
| 269 | `          html,` | 签名/调用续行参数：html |
| 270 | `          source.ruleBookInfo,` | 签名/调用续行参数：source.ruleBookInfo |
| 271 | `          baseUrl: book.bookUrl,` | 命名实参 baseUrl: book.bookUrl（base URL） |
| 272 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 273 | `&nbsp;` | 空行，分隔逻辑段落 |
| 274 | `        if (usedCachedInfoHtml && !_hasMeaningfulBookInfo(bookInfo)) {` | 条件判断 if：usedCachedInfoHtml 且 !_hasMeaningfulBookInfo(bookInfo) |
| 275 | `          AppLog.instance.put('getBookInfo: 透传HTML未命中详情规则，回退网络请求');` | 输出日志(put)：“getBookInfo: 透传HTML未命中详情规则，回退网络请求” |
| 276 | `          html = await _fetchBookInfoHtml(book, source);` | 将 等待异步结果：await _fetchBookInfoHtml(book, source) 赋值给 html（调用 _fetchBookInfoHtml → 拉取 书籍 Info HTML） |
| 277 | `          bookInfo = await RuleParser.parseBookInfoRule(` | 将 等待异步结果：await RuleParser.parseBookInfoRule( 赋值给 bookInfo（调用 parseBookInfoRule → 解析 书籍 Info 规则） |
| 278 | `            html,` | 签名/调用续行参数：html |
| 279 | `            source.ruleBookInfo,` | 签名/调用续行参数：source.ruleBookInfo |
| 280 | `            baseUrl: book.bookUrl,` | 命名实参 baseUrl: book.bookUrl（base URL） |
| 281 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 282 | `        }` | 闭合大括号，结束当前代码块 |
| 283 | `&nbsp;` | 空行，分隔逻辑段落 |
| 284 | `        // 更新书籍信息` | 注释说明：更新书籍信息 |
| 285 | `        final newTocUrl = bookInfo['tocUrl'] != null` | 上一表达式的续行：final newTocUrl = bookInfo['tocUrl'] != null |
| 286 | `            ? NetworkService.joinUrl(source.bookSourceUrl, bookInfo['tocUrl']!)` | 三元表达式为真时取值：NetworkService.joinUrl(source.bookSourceUrl, bookInfo['tocUrl']!) |
| 287 | `            : book.tocUrl;` | 三元表达式为假时取值：book.tocUrl; |
| 288 | `&nbsp;` | 空行，分隔逻辑段落 |
| 289 | `        AppLog.instance.put(` | 输出应用日志 AppLog |
| 290 | `            'getBookInfo: 解析结果 - name=${bookInfo['name']}, author=${bookInfo['author']}, kind=${bookInfo['kind']}, tocUrl=${bookInfo['tocUrl']}, 最终tocUrl=$newTocUrl');` | 以字符串 'getBookInfo: 解析结果 - name=${bookInfo[' 起始的表达式：name']}, author=${bookInfo['author']}, kind=${bookInfo['kind… |
| 291 | `&nbsp;` | 空行，分隔逻辑段落 |
| 292 | `        // 处理 canReName（如果可以重命名，存储到 variable 中）` | 注释说明：处理 canReName（如果可以重命名，存储到 variable 中） |
| 293 | `        String? updatedVariable = book.variable;` | String? updatedVariable = book.variable |
| 294 | `        final canReNameValue = bookInfo['canReName'];` | 声明不可重新赋值的(final)变量 canReNameValue |
| 295 | `        if (canReNameValue != null && canReNameValue.isNotEmpty) {` | 条件判断 if：canReNameValue 不等于 null 且 canReNameValue.isNotEmpty |
| 296 | `          // 将 canReName 存储到 variable JSON 中` | 注释说明：将 canReName 存储到 variable JSON 中 |
| 297 | `          try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 298 | `            final variableMap = <String, dynamic>{};` | 声明不可重新赋值的(final)变量 variableMap |
| 299 | `            if (updatedVariable != null && updatedVariable.isNotEmpty) {` | 条件判断 if：updatedVariable 不等于 null 且 updatedVariable.isNotEmpty |
| 300 | `              final decoded =` | 上一表达式的续行：final decoded = |
| 301 | `                  jsonDecode(updatedVariable) as Map<String, dynamic>?;` | 调用 jsonDecode(...)：jsonDecode(updatedVariable) as Map<String, dynamic>?（JSON 解码） |
| 302 | `              if (decoded != null) {` | 条件判断 if：decoded 不等于 null |
| 303 | `                variableMap.addAll(decoded);` | 调用 addAll(...)：variableMap.addAll(decoded)（添加 全部） |
| 304 | `              }` | 闭合大括号，结束当前代码块 |
| 305 | `            }` | 闭合大括号，结束当前代码块 |
| 306 | `            // canReName 通常是一个布尔值或字符串，存储为字符串` | 注释说明：canReName 通常是一个布尔值或字符串，存储为字符串 |
| 307 | `            variableMap['canReName'] = canReNameValue;` | variableMap['canReName'] = canReNameValue |
| 308 | `            updatedVariable = jsonEncode(variableMap);` | 将 jsonEncode(variableMap) 赋值给 updatedVariable（调用 jsonEncode → JSON 编码） |
| 309 | `          } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 310 | `            AppLog.instance` | 上一表达式的续行：AppLog.instance |
| 311 | `                .put('getBookInfo: 更新canReName到variable失败', error: e);` | 链式调用延续：.put('getBookInfo: 更新canReName到variable失败', error: e); |
| 312 | `          }` | 闭合大括号，结束当前代码块 |
| 313 | `        }` | 闭合大括号，结束当前代码块 |
| 314 | `&nbsp;` | 空行，分隔逻辑段落 |
| 315 | `        String? pickNonBlank(String? primary, String? fallback) {` | 定义方法 pickNonBlank：返回 String?；位置参数 2 个；参数名: primary。语义：pick Non Blank |
| 316 | `          if (primary != null && primary.trim().isNotEmpty) {` | 条件判断 if：primary 不等于 null 且 primary.trim().isNotEmpty |
| 317 | `            return primary;` | 返回 primary |
| 318 | `          }` | 闭合大括号，结束当前代码块 |
| 319 | `          return fallback;` | 返回 fallback |
| 320 | `        }` | 闭合大括号，结束当前代码块 |
| 321 | `&nbsp;` | 空行，分隔逻辑段落 |
| 322 | `        // 更新书籍信息` | 注释说明：更新书籍信息 |
| 323 | `        return book.copyWith(` | 返回调用 book.copyWith(...) 的结果 |
| 324 | `          name: pickNonBlank(bookInfo['name'], book.name) ?? book.name,` | 命名实参 name: pickNonBlank(bookInfo['name'], book.name) ?? book.name |
| 325 | `          author: pickNonBlank(bookInfo['author'], book.author) ?? book.author,` | 命名实参 author: pickNonBlank(bookInfo['author'], book.author) ?? book.author（作者） |
| 326 | `          kind: pickNonBlank(bookInfo['kind'], book.kind),` | 命名实参 kind: pickNonBlank(bookInfo['kind'], book.kind)（类别） |
| 327 | `          // coverUrl已经在parseRule中使用书籍详情页URL（book.bookUrl）作为baseUrl处理过了` | 注释说明：coverUrl已经在parseRule中使用书籍详情页URL（book.bookUrl）作为baseUrl处理过了 |
| 328 | `          // 参考项目：封面URL使用当前页面URL作为baseUrl，parseRule已经处理` | 注释说明：参考项目：封面URL使用当前页面URL作为baseUrl，parseRule已经处理 |
| 329 | `          coverUrl: pickNonBlank(bookInfo['coverUrl'], book.coverUrl),` | 命名实参 coverUrl: pickNonBlank(bookInfo['coverUrl'], book.coverUrl)（封面 URL） |
| 330 | `          intro: pickNonBlank(bookInfo['intro'], book.intro),` | 命名实参 intro: pickNonBlank(bookInfo['intro'], book.intro)（简介） |
| 331 | `          wordCount: pickNonBlank(bookInfo['wordCount'], book.wordCount),` | 命名实参 wordCount: pickNonBlank(bookInfo['wordCount'], book.wordCount)（word 数量） |
| 332 | `          latestChapterTitle:` | latestChapterTitle: |
| 333 | `              pickNonBlank(bookInfo['lastChapter'], book.latestChapterTitle),` | 调用 pickNonBlank(...)：pickNonBlank(bookInfo['lastChapter'], book.latestChapterTitle), |
| 334 | `          tocUrl: newTocUrl,` | 命名实参 tocUrl: newTocUrl（目录(TOC) URL） |
| 335 | `          variable: updatedVariable,` | 命名实参 variable: updatedVariable（变量） |
| 336 | `          infoHtml: html,` | 命名实参 infoHtml: html（info HTML） |
| 337 | `          lastCheckTime: DateTime.now().millisecondsSinceEpoch,` | 命名实参 lastCheckTime: DateTime.now().millisecondsSinceEpoch（最后 检查 Time） |
| 338 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 339 | `      });` | 闭合代码块并衔接后续语句：); |
| 340 | `&nbsp;` | 空行，分隔逻辑段落 |
| 341 | `      // 参考项目：如果书籍在书架中，自动保存到数据库` | 注释说明：参考项目：如果书籍在书架中，自动保存到数据库 |
| 342 | `      try {` | try 块开始：包裹可能抛出异常的逻辑 |
| 343 | `        final existingBook = await getBookByUrl(book.bookUrl);` | 声明不可重新赋值的(final)变量 existingBook：await 调用 getBookByUrl(...) → 获取 书籍 By URL |
| 344 | `        if (existingBook != null) {` | 条件判断 if：existingBook 不等于 null |
| 345 | `          // 书籍在书架中，自动更新数据库` | 注释说明：书籍在书架中，自动更新数据库 |
| 346 | `          await updateBook(updatedBook);` | 调用 updateBook(...)（等待异步完成） → 更新 书籍 |
| 347 | `          AppLog.instance.put('getBookInfo: 书籍在书架中，已自动更新数据库');` | 输出日志(put)：“getBookInfo: 书籍在书架中，已自动更新数据库” |
| 348 | `        } else {` | 闭合上一分支并开始 else 分支 |
| 349 | `          // 尝试通过书名和作者查找（因为bookUrl可能不同）` | 注释说明：尝试通过书名和作者查找（因为bookUrl可能不同） |
| 350 | `          final existingByName = await getBookByNameAndAuthor(` | 声明不可重新赋值的(final)变量 existingByName：await 调用 getBookByNameAndAuthor(...) → 获取 书籍 By Name And 作者 |
| 351 | `              updatedBook.name, updatedBook.author);` | updatedBook.name, updatedBook.author) |
| 352 | `          if (existingByName != null) {` | 条件判断 if：existingByName 不等于 null |
| 353 | `            // 找到同名同作者的书籍，更新它` | 注释说明：找到同名同作者的书籍，更新它 |
| 354 | `            final finalBook =` | 上一表达式的续行：final finalBook = |
| 355 | `                updatedBook.copyWith(bookUrl: existingByName.bookUrl);` | 调用 copyWith(...)：updatedBook.copyWith(bookUrl: existingByName.bookUrl) |
| 356 | `            await updateBook(finalBook);` | 调用 updateBook(...)（等待异步完成） → 更新 书籍 |
| 357 | `            AppLog.instance.put('getBookInfo: 通过书名和作者找到书籍，已自动更新数据库');` | 输出日志(put)：“getBookInfo: 通过书名和作者找到书籍，已自动更新数据库” |
| 358 | `          }` | 闭合大括号，结束当前代码块 |
| 359 | `        }` | 闭合大括号，结束当前代码块 |
| 360 | `      } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 361 | `        // 保存失败不影响返回结果` | 注释说明：保存失败不影响返回结果 |
| 362 | `        AppLog.instance.put('getBookInfo: 自动保存书籍详情失败', error: e);` | 输出日志(put)：“getBookInfo: 自动保存书籍详情失败” |
| 363 | `      }` | 闭合大括号，结束当前代码块 |
| 364 | `&nbsp;` | 空行，分隔逻辑段落 |
| 365 | `      return updatedBook;` | 返回 updatedBook |
| 366 | `    } catch (e) {` | 闭合 try 块并捕获异常，异常变量：e |
| 367 | `      AppLog.instance.put('getBookInfo: 获取书籍详情失败', error: e);` | 输出日志(put)：“getBookInfo: 获取书籍详情失败” |
| 368 | `      return book;` | 返回 book |
| 369 | `    }` | 闭合大括号，结束当前代码块 |
| 370 | `  }` | 闭合大括号，结束当前代码块 |
| 371 | `&nbsp;` | 空行，分隔逻辑段落 |
| 372 | `  Future<String> _fetchBookInfoHtml(Book book, BookSource source) async {` | 定义方法 _fetchBookInfoHtml：返回 Future<String>；位置参数 2 个；含命名参数；参数名: book, source（异步）。语义：拉取 书籍 Info HTML |
| 373 | `    final headers = NetworkService.parseHeaders(source.header);` | 声明不可重新赋值的(final)变量 headers：调用 NetworkService.parseHeaders(...) → 解析 请求头 |
| 374 | `    headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';` | headers['Cache-Control'] = 'no-cache, no-store, must-revalidate' |
| 375 | `    headers['Pragma'] = 'no-cache';` | headers['Pragma'] = 'no-cache' |
| 376 | `    headers['Expires'] = '0';` | headers['Expires'] = '0' |
| 377 | `&nbsp;` | 空行，分隔逻辑段落 |
| 378 | `    AppLog.instance.put(` | 输出应用日志 AppLog |
| 379 | `      'getBookInfo: 请求URL=${book.bookUrl}, 请求头数量=${headers.length}',` | 以字符串 'getBookInfo: 请求URL=${book.bookUrl}, 请求头… 起始的表达式：, |
| 380 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 381 | `&nbsp;` | 空行，分隔逻辑段落 |
| 382 | `    final html = await _request(` | 声明不可重新赋值的(final)变量 html：await 调用 _request(...) → 请求 |
| 383 | `      book.bookUrl,` | 签名/调用续行参数：book.bookUrl |
| 384 | `      source,` | 签名/调用续行参数：source |
| 385 | `      headers: headers,` | 命名实参 headers: headers（请求头） |
| 386 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 387 | `&nbsp;` | 空行，分隔逻辑段落 |
| 388 | `    AppLog.instance.put(` | 输出应用日志 AppLog |
| 389 | `      'getBookInfo: 内容长度=${html.length}, URL=${book.bookUrl}',` | 以字符串 'getBookInfo: 内容长度=${html.length}, URL=$… 起始的表达式：, |
| 390 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 391 | `&nbsp;` | 空行，分隔逻辑段落 |
| 392 | `    return html;` | 返回 html |
| 393 | `  }` | 闭合大括号，结束当前代码块 |
| 394 | `&nbsp;` | 空行，分隔逻辑段落 |
| 395 | `  bool _hasMeaningfulBookInfo(Map<String, String?> bookInfo) {` | 定义方法 _hasMeaningfulBookInfo：返回 bool；位置参数 2 个；参数名: String。语义：has Meaningful 书籍 Info |
| 396 | `    const keys = [` | 声明编译期常量(const)变量 keys：列表字面量 |
| 397 | `      'name',` | 以字符串 'name' 起始的表达式：, |
| 398 | `      'author',` | 以字符串 'author' 起始的表达式：, |
| 399 | `      'kind',` | 以字符串 'kind' 起始的表达式：, |
| 400 | `      'wordCount',` | 以字符串 'wordCount' 起始的表达式：, |
| 401 | `      'lastChapter',` | 以字符串 'lastChapter' 起始的表达式：, |
| 402 | `      'intro',` | 以字符串 'intro' 起始的表达式：, |
| 403 | `      'coverUrl',` | 以字符串 'coverUrl' 起始的表达式：, |
| 404 | `      'tocUrl'` | 上一表达式的续行：'tocUrl' |
| 405 | `    ];` | 结束上一调用/字面量：]; |
| 406 | `    for (final key in keys) {` | for-in 遍历：final key in keys |
| 407 | `      final value = bookInfo[key];` | 声明不可重新赋值的(final)变量 value |
| 408 | `      if (value != null && value.trim().isNotEmpty) {` | 条件判断 if：value 不等于 null 且 value.trim().isNotEmpty |
| 409 | `        return true;` | 返回 true（布尔值 true） |
| 410 | `      }` | 闭合大括号，结束当前代码块 |
| 411 | `    }` | 闭合大括号，结束当前代码块 |
| 412 | `    return false;` | 返回 false（布尔值 false） |
| 413 | `  }` | 闭合大括号，结束当前代码块 |
| 414 | `&nbsp;` | 空行，分隔逻辑段落 |
| 415 | `  /// 获取章节列表（支持分页获取所有章节）` | 文档注释：说明其后代码的用途 |
