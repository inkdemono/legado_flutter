# book_service_chapter_list.dart 逐行注释

> 源文件：`lib/services/book/book_service_chapter_list.dart`（共 1507 行）
>
> 本文件由 `scripts/gen_line_annotations.py` 自动生成，对源文件每一行给出独立说明。
> 说明优先采用源码自带的中文注释；无注释的行依据 Dart 语法特征自动生成解释。

| 行号 | 源代码 | 说明 |
| ---: | --- | --- |
| 1 | `part of 'book_service.dart';` | 声明本文件是 书籍 服务.dart 库的一部分(分部文件(part))，与其共享同一命名空间 |
| 2 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 4 | `// BookService 职责：章节列表获取（分页加载、智能降级解析、持久化）。` | 注释说明：书籍 服务 职责：章节列表获取（分页加载、智能降级解析、持久化）。 |
| 5 | `// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）` | 注释说明：（分部文件(part) 文件，与主文件 书籍 服务.dart 共享同一 Dart 库，可访问私有符号） |
| 6 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 7 | `&nbsp;` | 空行，分隔逻辑段落 |
| 8 | `  Future<List<BookChapter>> getChapterList(` | 定义方法 获取 章节 列表：返回 异步结果(Future)<列表(List)<章节(BookChapter)>>；无参数（异步）。语义：获取 章节 列表 |
| 9 | `    Book book, {` | 书籍(Book) 类型参数 书籍，其后 { 开启命名参数块（书籍） |
| 10 | `    bool loadAllPages = true,` | 布尔(bool) 类型参数 加载 全部 分页，默认值 真(true)（加载 全部 分页） |
| 11 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 12 | `    if (book.isLocal) {` | 条件判断 如果(if)：书籍.isLocal |
| 13 | `      // 本地书籍从数据库读取章节` | 注释说明：本地书籍从数据库读取章节 |
| 14 | `      return await _getLocalChapters(book.bookUrl);` | 返回异步调用 _获取 本地 章节列表(...) 的结果（语义：获取 本地 章节列表） |
| 15 | `    }` | 闭合大括号，结束当前代码块 |
| 16 | `&nbsp;` | 空行，分隔逻辑段落 |
| 17 | `    final source = await _bookSourceService.getBookSourceByUrl(book.origin);` | 声明不可重新赋值的变量 书源：等待(await) 调用 _书籍 书源 服务.getBookSourceByUrl(...) → 获取 书籍 书源 By 统一资源链接(URL) |
| 18 | `    if (source == null \|\| source.ruleToc == null) {` | 条件判断 如果(if)：书源 等于 空值(null) 或 书源.目录规则 等于 空值(null) |
| 19 | `      return [];` | 返回 []（列表字面量） |
| 20 | `    }` | 闭合大括号，结束当前代码块 |
| 21 | `&nbsp;` | 空行，分隔逻辑段落 |
| 22 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 23 | `      final chapterVariables = _buildRuleVariables(book);` | 声明不可重新赋值的变量 章节 变量表：调用 _构建 规则 变量表(...) → 构建 规则 变量表 |
| 24 | `      // 使用tocUrl或bookUrl` | 注释说明：使用目录(TOC) URL或书籍链接 |
| 25 | `      final tocUrl = book.tocUrl.isNotEmpty ? book.tocUrl : book.bookUrl;` | 声明不可重新赋值的变量 目录(TOC) URL |
| 26 | `      AppLog.instance.put('开始获取章节列表: tocUrl=$tocUrl, bookUrl=${book.bookUrl}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('开始获取章节列表: 目录(TOC) URL=$目录(TOC) URL, 书籍链接=${书籍.书籍链接}… |
| 27 | `&nbsp;` | 空行，分隔逻辑段落 |
| 28 | `      // 发送请求` | 注释说明：发送请求 |
| 29 | `      final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 30 | `        tocUrl,` | 签名/调用续行参数：目录(TOC) URL |
| 31 | `        headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 32 | `        retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 33 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 34 | `&nbsp;` | 空行，分隔逻辑段落 |
| 35 | `      var html = await NetworkService.getResponseText(response);` | 声明自动类型推断的变量 网页内容：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 36 | `&nbsp;` | 空行，分隔逻辑段落 |
| 37 | `      AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 38 | `          .put('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}');` | 链式调用延续：.写入数据库(put)('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}'); |
| 39 | `&nbsp;` | 空行，分隔逻辑段落 |
| 40 | `      if (html.isEmpty) {` | 条件判断 如果(if)：网页内容.是否为空 |
| 41 | `        AppLog.instance.put('获取章节列表失败: 响应内容为空');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败: 响应内容为空'); |
| 42 | `        // 如果获取失败，尝试从数据库读取` | 注释说明：如果获取失败，尝试从数据库读取 |
| 43 | `        final localChapters = await _getLocalChapters(book.bookUrl);` | 声明不可重新赋值的变量 本地 章节列表：等待(await) 调用 _获取 本地 章节列表(...) → 获取 本地 章节列表 |
| 44 | `        if (localChapters.isEmpty) {` | 条件判断 如果(if)：本地 章节列表.是否为空 |
| 45 | `          throw TocEmptyException('获取章节列表失败: 响应内容为空，且本地无章节数据');` | 定义方法 目录(TOC) 空 异常：返回 抛出(throw)；位置参数 1 个；参数名: 获取章节列表失败。语义：目录(目录(TOC)) 空 异常 |
| 46 | `        }` | 闭合大括号，结束当前代码块 |
| 47 | `        return localChapters;` | 返回 本地 章节列表 |
| 48 | `      }` | 闭合大括号，结束当前代码块 |
| 49 | `&nbsp;` | 空行，分隔逻辑段落 |
| 50 | `      // 确定有效的baseUrl：如果tocUrl不是有效的绝对URL，使用source.bookSourceUrl` | 注释说明：确定有效的基础链接：如果目录(TOC) URL不是有效的绝对统一资源链接(URL)，使用书源.书源链接 |
| 51 | `      String? effectiveBaseUrl = tocUrl;` | 字符串(String)? effectiveBaseUrl = 目录(TOC) URL |
| 52 | `      if (!tocUrl.isAbsUrl()) {` | 条件判断 如果(if)：!目录(TOC) URL.isAbsUrl() |
| 53 | `        // 如果source.bookSourceUrl也是有效的绝对URL，使用它；否则尝试从tocUrl构建` | 注释说明：如果书源.书源链接也是有效的绝对统一资源链接(URL)，使用它；否则尝试从目录(TOC) URL构建 |
| 54 | `        if (source.bookSourceUrl.isAbsUrl()) {` | 条件判断 如果(if)：书源.书源链接.isAbsUrl() |
| 55 | `          effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 56 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 57 | `              'tocUrl不是绝对URL，使用source.bookSourceUrl作为baseUrl: $effectiveBaseUrl');` | 以字符串 '目录(TOC) URL不是绝对统一资源链接(URL)，使用书源.书源链接作为b… 起始的表达式：); |
| 58 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 59 | `          // 如果两者都不是绝对URL，尝试从tocUrl构建完整的URL` | 注释说明：如果两者都不是绝对统一资源链接(URL)，尝试从目录(TOC) URL构建完整的统一资源链接(URL) |
| 60 | `          // 如果tocUrl是相对路径，使用source.bookSourceUrl作为基础` | 注释说明：如果目录(TOC) URL是相对路径，使用书源.书源链接作为基础 |
| 61 | `          try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 62 | `            effectiveBaseUrl =` | 上一表达式的续行：effectiveBaseUrl = |
| 63 | `                NetworkService.joinUrl(source.bookSourceUrl, tocUrl);` | 链式调用起始于 网络服务(NetworkService)（Network 服务），后续行继续该表达式：网络服务(NetworkService).拼接 URL(书源.书源链接, 目录(TOC) URL); |
| 64 | `            if (!effectiveBaseUrl.isAbsUrl()) {` | 条件判断 如果(if)：!effectiveBaseUrl.isAbsUrl() |
| 65 | `              // 如果仍然无效，使用source.bookSourceUrl` | 注释说明：如果仍然无效，使用书源.书源链接 |
| 66 | `              effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 67 | `            }` | 闭合大括号，结束当前代码块 |
| 68 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 69 | `                'tocUrl和source.bookSourceUrl都不是绝对URL，尝试拼接后: $effectiveBaseUrl');` | 以字符串 '目录(TOC) URL和书源.书源链接都不是绝对统一资源链接(URL)，尝试拼… 起始的表达式：); |
| 70 | `          } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 71 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 72 | `                '构建baseUrl失败: $e，使用source.bookSourceUrl: ${source.bookSourceUrl}');` | 以字符串 '构建基础链接失败: $异常对象 e，使用书源.书源链接:… 起始的表达式：); |
| 73 | `            effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 74 | `          }` | 闭合大括号，结束当前代码块 |
| 75 | `        }` | 闭合大括号，结束当前代码块 |
| 76 | `      }` | 闭合大括号，结束当前代码块 |
| 77 | `&nbsp;` | 空行，分隔逻辑段落 |
| 78 | `      // 最终验证：确保effectiveBaseUrl是有效的绝对URL` | 注释说明：最终验证：确保effectiveBaseUrl是有效的绝对统一资源链接(URL) |
| 79 | `      if (!effectiveBaseUrl.isAbsUrl()) {` | 条件判断 如果(if)：!effectiveBaseUrl.isAbsUrl() |
| 80 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 81 | `            .put('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败');` | 链式调用延续：.写入数据库(put)('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败'); |
| 82 | `      }` | 闭合大括号，结束当前代码块 |
| 83 | `&nbsp;` | 空行，分隔逻辑段落 |
| 84 | `      // 参考项目：执行 preUpdateJs（如果存在）` | 注释说明：参考项目：执行 preUpdateJs（如果存在） |
| 85 | `      // 参考项目的 TocRule 有 preUpdateJs 字段，用于在解析目录前预处理HTML` | 注释说明：参考项目的 目录(TOC) 规则 有 preUpdateJs 字段，用于在解析目录前预处理网页标记文本(HTML) |
| 86 | `      if (source.ruleToc?.preUpdateJs != null &&` | 条件判断 如果(if)：书源.目录规则?.preUpdateJs 不等于 空值(null) 且 |
| 87 | `          source.ruleToc!.preUpdateJs!.isNotEmpty) {` | 书源.目录规则!.preUpdateJs!.是否非空) { |
| 88 | `        AppLog.instance.put('执行 preUpdateJs 预处理HTML');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('执行 preUpdateJs 预处理HTML'); |
| 89 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 90 | `          final preUpdateResult = await RuleParser.executeJs(` | 声明不可重新赋值的变量 preUpdateResult：等待(await) 调用 规则解析器(RuleParser).执行 JS脚本(...) → 执行 JavaScript脚本(JS)脚本 |
| 91 | `            html,` | 签名/调用续行参数：网页内容 |
| 92 | `            source.ruleToc!.preUpdateJs!,` | 书源.目录规则!.preUpdateJs!, |
| 93 | `            source: source,` | 命名实参 书源: 书源（书源） |
| 94 | `            book: book,` | 命名实参 书籍: 书籍（书籍） |
| 95 | `            baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 96 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 97 | `          if (preUpdateResult != null && preUpdateResult.isNotEmpty) {` | 条件判断 如果(if)：preUpdateResult 不等于 空值(null) 且 preUpdateResult.是否非空 |
| 98 | `            html = preUpdateResult;` | 将 preUpdateResult 赋值给 网页内容 |
| 99 | `            AppLog.instance.put('preUpdateJs 执行成功，HTML长度=${html.length}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('preUpdateJs 执行成功，HTML长度=${html.length}'); |
| 100 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 101 | `            AppLog.instance.put('preUpdateJs 执行返回空，使用原始HTML');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('preUpdateJs 执行返回空，使用原始HTML'); |
| 102 | `          }` | 闭合大括号，结束当前代码块 |
| 103 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 104 | `          AppLog.instance.put('preUpdateJs 执行失败: $e，使用原始HTML', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('preUpdateJs 执行失败: $e，使用原始HTML', error: e); |
| 105 | `        }` | 闭合大括号，结束当前代码块 |
| 106 | `      }` | 闭合大括号，结束当前代码块 |
| 107 | `&nbsp;` | 空行，分隔逻辑段落 |
| 108 | `      // 首先尝试使用原始规则获取第一页，如果失败则使用降级规则` | 注释说明：首先尝试使用原始规则获取第一页，如果失败则使用降级规则 |
| 109 | `      TocRule? effectiveTocRule = source.ruleToc;` | 目录(TOC) 规则? effectiveTocRule = 书源.目录规则 |
| 110 | `      String? fallbackChapterListRule;` | 字符串(String)? 回退/降级 章节 列表 规则 |
| 111 | `&nbsp;` | 空行，分隔逻辑段落 |
| 112 | `      // 检查原始规则是否能匹配到章节` | 注释说明：检查原始规则是否能匹配到章节 |
| 113 | `      var testChapterList = RuleParser.parseTocRule(` | 声明自动类型推断的变量 testChapterList：调用 规则解析器(RuleParser).解析 目录(TOC) 规则(...) → 解析 目录(目录(TOC)) 规则 |
| 114 | `        html,` | 签名/调用续行参数：网页内容 |
| 115 | `        source.ruleToc,` | 签名/调用续行参数：书源.目录规则 |
| 116 | `        baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 117 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 118 | `&nbsp;` | 空行，分隔逻辑段落 |
| 119 | `      if (testChapterList.isEmpty && source.ruleToc?.chapterList != null) {` | 条件判断 如果(if)：testChapterList.是否为空 且 书源.目录规则?.章节 列表 不等于 空值(null) |
| 120 | `        AppLog.instance.put('原始规则未匹配到章节，尝试智能降级处理');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('原始规则未匹配到章节，尝试智能降级处理'); |
| 121 | `&nbsp;` | 空行，分隔逻辑段落 |
| 122 | `        // 查找降级规则` | 注释说明：查找降级规则 |
| 123 | `        final chapterLinkPattern = RegExp(` | 声明不可重新赋值的变量 chapterLinkPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 124 | `            '<a[^>]*href=["\']/[^"\']*\\.html["\'][^>]*>.*?</a>',` | 以字符串 '<a[^>]*href=["\']/[^"\']*\\.网页内容["\'][^… 起始的表达式：, |
| 125 | `            caseSensitive: false,` | 区分大小写开关: 假(false), |
| 126 | `            dotAll: true);` | 命名实参 点号 全部: 真(true));（点号 全部） |
| 127 | `        final chapterLinkMatches = chapterLinkPattern.allMatches(html).toList();` | 声明不可重新赋值的变量 chapterLinkMatches：调用 chapterLinkPattern.allMatches(...) → 全部 Matches |
| 128 | `&nbsp;` | 空行，分隔逻辑段落 |
| 129 | `        if (chapterLinkMatches.isNotEmpty) {` | 条件判断 如果(if)：chapterLinkMatches.是否非空 |
| 130 | `          AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 131 | `              .put('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器');` | 链式调用延续：.写入数据库(put)('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器'); |
| 132 | `&nbsp;` | 空行，分隔逻辑段落 |
| 133 | `          html_dom.Element? directoryContainer;` | html_dom.Element? directoryContainer |
| 134 | `          String? containerClass;` | 字符串(String)? containerClass |
| 135 | `          String? containerId;` | 字符串(String)? containerId |
| 136 | `&nbsp;` | 空行，分隔逻辑段落 |
| 137 | `          // 首先尝试查找directoryArea容器` | 注释说明：首先尝试查找directoryArea容器 |
| 138 | `          final doc = html_parser.parse(html);` | 声明不可重新赋值的变量 文档：调用 HTML 解析器.parse(...) → 解析 |
| 139 | `          final directoryPattern = RegExp(` | 声明不可重新赋值的变量 目录(directory) 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 140 | `              'class\\s*=\\s*["\'][^"\']*directory[^"\']*["\']',` | 以字符串 '类(class)\\s*=\\s*["\'][^"\']*目录(directory)[^"\… 起始的表达式：, |
| 141 | `              caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 142 | `          final directoryMatches = directoryPattern.allMatches(html);` | 声明不可重新赋值的变量 directoryMatches：调用 目录(directory) 模式.allMatches(...) → 全部 Matches |
| 143 | `          if (directoryMatches.isNotEmpty) {` | 条件判断 如果(if)：directoryMatches.是否非空 |
| 144 | `            final match = directoryMatches.first;` | 声明不可重新赋值的变量 match |
| 145 | `            final matchHtml = html.substring(match.start, match.end);` | 声明不可重新赋值的变量 matchHtml |
| 146 | `            final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 147 | `                caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 148 | `            final classMatch = classPattern.firstMatch(matchHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 149 | `            if (classMatch != null) {` | 条件判断 如果(if)：classMatch 不等于 空值(null) |
| 150 | `              final allClasses =` | 上一表达式的续行：不可重新赋值(final) allClasses = |
| 151 | `                  classMatch.group(1)?.split(RegExp(r'\s+')) ?? [];` | 链式调用起始于 classMatch，后续行继续该表达式：classMatch.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')) ?? []; |
| 152 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 153 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 154 | `                orElse: () => '',` | 命名实参 orElse: () => ''（or Else） |
| 155 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 156 | `              if (dirClass.isNotEmpty) {` | 条件判断 如果(if)：dirClass.是否非空 |
| 157 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 158 | `                    HtmlParser.selectElement(doc, 'div.$dirClass');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div.$dirClass'); |
| 159 | `                containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 160 | `                AppLog.instance.put('找到directory容器: class=$containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到directory容器: class=$containerClass'); |
| 161 | `              }` | 闭合大括号，结束当前代码块 |
| 162 | `            }` | 闭合大括号，结束当前代码块 |
| 163 | `          }` | 闭合大括号，结束当前代码块 |
| 164 | `&nbsp;` | 空行，分隔逻辑段落 |
| 165 | `          // 如果找到了directory容器，提取其class或id用于生成降级规则` | 注释说明：如果找到了目录(directory)容器，提取其类(class)或编号(id)用于生成降级规则 |
| 166 | `          if (directoryContainer != null) {` | 条件判断 如果(if)：directoryContainer 不等于 空值(null) |
| 167 | `            final dirClassAttr = directoryContainer.attributes['class'];` | 声明不可重新赋值的变量 dirClassAttr |
| 168 | `            final dirIdAttr = directoryContainer.attributes['id'];` | 声明不可重新赋值的变量 dirIdAttr |
| 169 | `            if (dirClassAttr != null && dirClassAttr.contains('directory')) {` | 条件判断 如果(if)：dirClassAttr 不等于 空值(null) 且 dirClassAttr.是否包含('目录(directory)') |
| 170 | `              final allClasses = dirClassAttr.split(RegExp(r'\s+'));` | 声明不可重新赋值的变量 allClasses：调用 dirClassAttr.切分(...) → 切分 |
| 171 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 172 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 173 | `                orElse: () => allClasses.first,` | 命名实参 orElse: () => allClasses.first（or Else） |
| 174 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 175 | `              containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 176 | `              AppLog.instance.put('从directory容器提取class: $containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取class: $containerClass'); |
| 177 | `            }` | 闭合大括号，结束当前代码块 |
| 178 | `            if (dirIdAttr != null) {` | 条件判断 如果(if)：dirIdAttr 不等于 空值(null) |
| 179 | `              containerId = dirIdAttr;` | 将 dirIdAttr 赋值给 containerId |
| 180 | `              AppLog.instance.put('从directory容器提取id: $containerId');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取id: $containerId'); |
| 181 | `            }` | 闭合大括号，结束当前代码块 |
| 182 | `          }` | 闭合大括号，结束当前代码块 |
| 183 | `&nbsp;` | 空行，分隔逻辑段落 |
| 184 | `          // 生成降级规则` | 注释说明：生成降级规则 |
| 185 | `          if (containerClass != null) {` | 条件判断 如果(if)：containerClass 不等于 空值(null) |
| 186 | `            fallbackChapterListRule = 'class.$containerClass@tag.a';` | 回退/降级 章节 列表 规则 = '类(class).$containerClass@tag.a' |
| 187 | `            AppLog.instance.put('使用降级规则: $fallbackChapterListRule');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('使用降级规则: $fallbackChapterListRule'); |
| 188 | `          }` | 闭合大括号，结束当前代码块 |
| 189 | `        }` | 闭合大括号，结束当前代码块 |
| 190 | `&nbsp;` | 空行，分隔逻辑段落 |
| 191 | `        // 如果找到了降级规则，创建临时规则对象` | 注释说明：如果找到了降级规则，创建临时规则对象 |
| 192 | `        if (fallbackChapterListRule != null) {` | 条件判断 如果(if)：回退/降级 章节 列表 规则 不等于 空值(null) |
| 193 | `          effectiveTocRule = TocRule(` | 将 目录(TOC) 规则( 赋值给 effectiveTocRule（调用 目录(TOC) 规则 → 目录(目录(TOC)) 规则） |
| 194 | `            chapterList: fallbackChapterListRule,` | 命名实参 章节 列表: 回退/降级 章节 列表 规则（章节 列表） |
| 195 | `            chapterName: source.ruleToc?.chapterName ?? 'tag.a@text',` | 命名实参 章节 名称: 书源.目录规则?.章节 名称 ?? 'tag.a@文本'（章节 名称） |
| 196 | `            chapterUrl: source.ruleToc?.chapterUrl ?? 'tag.a@href',` | 命名实参 章节链接: 书源.目录规则?.章节链接 ?? 'tag.a@href'（章节 统一资源链接(URL)） |
| 197 | `            isVip: source.ruleToc?.isVip,` | 命名实参 isVip: 书源.目录规则?.isVip（是(is) Vip） |
| 198 | `            isVolume: source.ruleToc?.isVolume, // 保留卷名规则` | 命名实参 isVolume: 书源.目录规则?.isVolume（是(is) 体积）；行尾注释：保留卷名规则 |
| 199 | `            updateTime: source.ruleToc?.updateTime,` | 命名实参 updateTime: 书源.目录规则?.updateTime（更新 Time） |
| 200 | `            nextTocUrl: source.ruleToc?.nextTocUrl,` | 命名实参 下一页目录链接: 书源.目录规则?.下一页目录链接（下一章 目录(目录(TOC)) 统一资源链接(URL)） |
| 201 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 202 | `        }` | 闭合大括号，结束当前代码块 |
| 203 | `      }` | 闭合大括号，结束当前代码块 |
| 204 | `&nbsp;` | 空行，分隔逻辑段落 |
| 205 | `      // 参考项目：BookChapterList.analyzeChapterList` | 注释说明：参考项目：书籍 章节 列表.分析 章节 列表 |
| 206 | `      // 处理 chapterList 规则的前缀（参考项目第51-58行）` | 注释说明：处理 章节 列表 规则的前缀（参考项目第51-58行） |
| 207 | `      var reverse = false;` | 声明自动类型推断的变量 reverse |
| 208 | `      var listRule = effectiveTocRule?.chapterList ?? '';` | 声明自动类型推断的变量 列表 规则 |
| 209 | `      if (listRule.startsWith('-')) {` | 条件判断 如果(if)：列表 规则.startsWith('-') |
| 210 | `        reverse = true;` | 将 真(true) 赋值给 reverse |
| 211 | `        listRule = listRule.substring(1);` | 将 列表 规则.substring(1) 赋值给 列表 规则 |
| 212 | `        AppLog.instance.put('检测到 - 前缀，将反转章节列表');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('检测到 - 前缀，将反转章节列表'); |
| 213 | `      }` | 闭合大括号，结束当前代码块 |
| 214 | `      if (listRule.startsWith('+')) {` | 条件判断 如果(if)：列表 规则.startsWith('+') |
| 215 | `        listRule = listRule.substring(1);` | 将 列表 规则.substring(1) 赋值给 列表 规则 |
| 216 | `        AppLog.instance.put('检测到 + 前缀，已移除');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('检测到 + 前缀，已移除'); |
| 217 | `      }` | 闭合大括号，结束当前代码块 |
| 218 | `&nbsp;` | 空行，分隔逻辑段落 |
| 219 | `      // 如果规则被修改，更新 effectiveTocRule` | 注释说明：如果规则被修改，更新 effectiveTocRule |
| 220 | `      if (listRule != effectiveTocRule?.chapterList) {` | 条件判断 如果(if)：列表 规则 不等于 effectiveTocRule?.章节 列表 |
| 221 | `        effectiveTocRule = TocRule(` | 将 目录(TOC) 规则( 赋值给 effectiveTocRule（调用 目录(TOC) 规则 → 目录(目录(TOC)) 规则） |
| 222 | `          chapterList: listRule,` | 命名实参 章节 列表: 列表 规则（章节 列表） |
| 223 | `          chapterName: effectiveTocRule?.chapterName,` | 命名实参 章节 名称: effectiveTocRule?.章节 名称（章节 名称） |
| 224 | `          chapterUrl: effectiveTocRule?.chapterUrl,` | 命名实参 章节链接: effectiveTocRule?.章节链接（章节 统一资源链接(URL)） |
| 225 | `          isVip: effectiveTocRule?.isVip,` | 命名实参 isVip: effectiveTocRule?.isVip（是(is) Vip） |
| 226 | `          isVolume: effectiveTocRule?.isVolume,` | 命名实参 isVolume: effectiveTocRule?.isVolume（是(is) 体积） |
| 227 | `          updateTime: effectiveTocRule?.updateTime,` | 命名实参 updateTime: effectiveTocRule?.updateTime（更新 Time） |
| 228 | `          nextTocUrl: effectiveTocRule?.nextTocUrl,` | 命名实参 下一页目录链接: effectiveTocRule?.下一页目录链接（下一章 目录(目录(TOC)) 统一资源链接(URL)） |
| 229 | `          formatJs: effectiveTocRule?.formatJs,` | 命名实参 格式化 JS脚本: effectiveTocRule?.格式化 JS脚本（格式化 JavaScript脚本(JS)脚本） |
| 230 | `          preUpdateJs: effectiveTocRule?.preUpdateJs,` | 命名实参 preUpdateJs: effectiveTocRule?.preUpdateJs（pre 更新 JavaScript脚本(JS)脚本） |
| 231 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 232 | `      }` | 闭合大括号，结束当前代码块 |
| 233 | `&nbsp;` | 空行，分隔逻辑段落 |
| 234 | `      // 参考项目：第一次调用 analyzeChapterList，返回章节列表和下一页URL列表` | 注释说明：参考项目：第一次调用 分析 章节 列表，返回章节列表和下一页统一资源链接(URL)列表 |
| 235 | `      final firstPageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 首个 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 236 | `        html,` | 签名/调用续行参数：网页内容 |
| 237 | `        effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 238 | `        variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 239 | `        baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 240 | `        getNextUrl: true,` | 命名实参 获取 下一章 URL: 真(true)（获取 下一章 统一资源链接(URL)） |
| 241 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 242 | `&nbsp;` | 空行，分隔逻辑段落 |
| 243 | `      var allChapterList = <Map<String, String?>>[];` | 声明自动类型推断的变量 全部 章节 列表 |
| 244 | `      allChapterList` | 上一表达式的续行：全部 章节 列表 |
| 245 | `          .addAll(firstPageResult['chapterList'] as List<Map<String, String?>>);` | 链式调用延续：.批量添加(首个 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>>); |
| 246 | `      var nextUrlList =` | 上一表达式的续行：自动类型推断(var) 下一章 URL 列表 = |
| 247 | `          List<String>.from(firstPageResult['nextUrlList'] as List);` | 调用 from(...)：列表(List)<字符串(String)>.from(首个 页 结果['下一章 URL 列表'] 作为(as) 列表(List)) |
| 248 | `&nbsp;` | 空行，分隔逻辑段落 |
| 249 | `      // 过滤掉与当前URL相同的URL` | 注释说明：过滤掉与当前统一资源链接(URL)相同的统一资源链接(URL) |
| 250 | `      nextUrlList =` | 上一表达式的续行：下一章 URL 列表 = |
| 251 | `          nextUrlList.where((url) => url.isNotEmpty && url != tocUrl).toList();` | 链式调用起始于 下一章 URL 列表（下一章 统一资源链接(URL) 列表），后续行继续该表达式：下一章 URL 列表.筛选(where)((链接) => 链接.是否非空 && 链接 != 目录(TOC) URL).转为列表(); |
| 252 | `&nbsp;` | 空行，分隔逻辑段落 |
| 253 | `      // 参考项目：根据 nextUrlList.size 决定处理方式` | 注释说明：参考项目：根据 下一章 URL 列表.大小 决定处理方式 |
| 254 | `      // size == 0: 不处理分页` | 注释说明：大小 == 0: 不处理分页 |
| 255 | `      // size == 1: 循环获取下一页` | 注释说明：大小 == 1: 循环获取下一页 |
| 256 | `      // size > 1: 并发处理所有URL` | 注释说明：大小 > 1: 并发处理所有统一资源链接(URL) |
| 257 | `      if (loadAllPages && nextUrlList.isEmpty) {` | 条件判断 如果(if)：加载 全部 分页 且 下一章 URL 列表.是否为空 |
| 258 | `        final ajaxChapters = await _loadAjaxTocPages(` | 声明不可重新赋值的变量 ajaxChapters：等待(await) 调用 _loadAjaxTocPages(...) → 加载 Ajax 目录(目录(TOC)) 分页 |
| 259 | `          tocUrl: tocUrl,` | 命名实参 目录(TOC) URL: 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 260 | `          firstPageHtml: html,` | 命名实参 首个 页 HTML: 网页内容（首个 页 网页标记文本(HTML)） |
| 261 | `          source: source,` | 命名实参 书源: 书源（书源） |
| 262 | `          seedChapters: allChapterList,` | 命名实参 seedChapters: 全部 章节 列表（seed 章节列表） |
| 263 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 264 | `        if (ajaxChapters.isNotEmpty) {` | 条件判断 如果(if)：ajaxChapters.是否非空 |
| 265 | `          allChapterList.addAll(ajaxChapters);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(ajaxChapters); |
| 266 | `        }` | 闭合大括号，结束当前代码块 |
| 267 | `&nbsp;` | 空行，分隔逻辑段落 |
| 268 | `        final implicitChapters = await _loadImplicitTocPages(` | 声明不可重新赋值的变量 implicitChapters：等待(await) 调用 _loadImplicitTocPages(...) → 加载 Implicit 目录(目录(TOC)) 分页 |
| 269 | `          tocUrl: tocUrl,` | 命名实参 目录(TOC) URL: 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 270 | `          source: source,` | 命名实参 书源: 书源（书源） |
| 271 | `          tocRule: effectiveTocRule!,` | 命名实参 目录(TOC) 规则: effectiveTocRule!（目录(目录(TOC)) 规则） |
| 272 | `          seedChapters: allChapterList,` | 命名实参 seedChapters: 全部 章节 列表（seed 章节列表） |
| 273 | `          variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 274 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 275 | `        if (implicitChapters.isNotEmpty) {` | 条件判断 如果(if)：implicitChapters.是否非空 |
| 276 | `          allChapterList.addAll(implicitChapters);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(implicitChapters); |
| 277 | `        }` | 闭合大括号，结束当前代码块 |
| 278 | `      } else if (loadAllPages && nextUrlList.length == 1) {` | 闭合上一代码块并开始 否则(else) 如果(if) (加载 全部 分页 && 下一章 URL 列表.长度 |
| 279 | `        // 参考项目：循环获取下一页，直到没有下一页或已访问过` | 注释说明：参考项目：循环获取下一页，直到没有下一页或已访问过 |
| 280 | `        var currentUrl = nextUrlList[0];` | 声明自动类型推断的变量 当前 URL |
| 281 | `        var visitedUrls = <String>{tocUrl, currentUrl};` | 声明自动类型推断的变量 visitedUrls |
| 282 | `        var pageCount = 1;` | 声明自动类型推断的变量 页 数量 |
| 283 | `        const maxPages = 100; // 防止无限循环` | 声明编译期常量变量 maxPages；行尾注释：防止无限循环 |
| 284 | `&nbsp;` | 空行，分隔逻辑段落 |
| 285 | `        while (pageCount < maxPages) {` | 当型循环(while) 循环，条件：页 数量 < maxPages |
| 286 | `          pageCount++;` | 页 数量++ |
| 287 | `&nbsp;` | 空行，分隔逻辑段落 |
| 288 | `          try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 289 | `            final pageResponse = await _networkService.get(` | 声明不可重新赋值的变量 页 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 290 | `              currentUrl,` | 签名/调用续行参数：当前 URL |
| 291 | `              headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 292 | `              retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 293 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 294 | `            final pageHtml = await NetworkService.getResponseText(pageResponse);` | 声明不可重新赋值的变量 页 HTML：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 295 | `&nbsp;` | 空行，分隔逻辑段落 |
| 296 | `            if (pageHtml.isEmpty) {` | 条件判断 如果(if)：页 HTML.是否为空 |
| 297 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 298 | `            }` | 闭合大括号，结束当前代码块 |
| 299 | `&nbsp;` | 空行，分隔逻辑段落 |
| 300 | `            // 解析当前页的章节列表和下一页URL` | 注释说明：解析当前页的章节列表和下一页统一资源链接(URL) |
| 301 | `            final pageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 302 | `              pageHtml,` | 签名/调用续行参数：页 HTML |
| 303 | `              effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 304 | `              variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 305 | `              baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 306 | `              getNextUrl: true,` | 命名实参 获取 下一章 URL: 真(true)（获取 下一章 统一资源链接(URL)） |
| 307 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 308 | `&nbsp;` | 空行，分隔逻辑段落 |
| 309 | `            final pageChapterList =` | 上一表达式的续行：不可重新赋值(final) 页 章节 列表 = |
| 310 | `                pageResult['chapterList'] as List<Map<String, String?>>;` | 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 311 | `            final pageNextUrlList =` | 上一表达式的续行：不可重新赋值(final) 页 下一章 URL 列表 = |
| 312 | `                List<String>.from(pageResult['nextUrlList'] as List);` | 调用 from(...)：列表(List)<字符串(String)>.from(页 结果['下一章 URL 列表'] 作为(as) 列表(List)) |
| 313 | `&nbsp;` | 空行，分隔逻辑段落 |
| 314 | `            allChapterList.addAll(pageChapterList);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(页 章节 列表); |
| 315 | `&nbsp;` | 空行，分隔逻辑段落 |
| 316 | `            // 获取下一页URL（过滤掉已访问的URL）` | 注释说明：获取下一页统一资源链接(URL)（过滤掉已访问的统一资源链接(URL)） |
| 317 | `            final filteredNextUrls = pageNextUrlList` | 上一表达式的续行：不可重新赋值(final) filteredNextUrls = 页 下一章 URL 列表 |
| 318 | `                .where((url) =>` | 链式调用延续：.筛选(where)((链接) => |
| 319 | `                    url.isNotEmpty &&` | 上一表达式的续行：链接.是否非空 && |
| 320 | `                    url != currentUrl &&` | 上一表达式的续行：链接 != 当前 URL && |
| 321 | `                    !visitedUrls.contains(url))` | 调用 是否包含(...)：!visitedUrls.是否包含(链接))（是否包含） |
| 322 | `                .toList();` | 链式调用延续：.转为列表(); |
| 323 | `&nbsp;` | 空行，分隔逻辑段落 |
| 324 | `            if (filteredNextUrls.isEmpty) {` | 条件判断 如果(if)：filteredNextUrls.是否为空 |
| 325 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 326 | `            }` | 闭合大括号，结束当前代码块 |
| 327 | `&nbsp;` | 空行，分隔逻辑段落 |
| 328 | `            currentUrl = filteredNextUrls[0];` | 将 filteredNextUrls[0] 赋值给 当前 URL |
| 329 | `            visitedUrls.add(currentUrl);` | 链式调用起始于 visitedUrls，后续行继续该表达式：visitedUrls.添加(当前 URL); |
| 330 | `          } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 331 | `            AppLog.instance.put('获取第 $pageCount 页失败: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取第 $pageCount 页失败: $e', error: e); |
| 332 | `            break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 333 | `          }` | 闭合大括号，结束当前代码块 |
| 334 | `        }` | 闭合大括号，结束当前代码块 |
| 335 | `      } else if (loadAllPages) {` | 闭合上一代码块并开始 否则(else) 如果(if) (加载 全部 分页) { |
| 336 | `        // 参考项目：并发处理所有URL` | 注释说明：参考项目：并发处理所有统一资源链接(URL) |
| 337 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 338 | `          // 并发处理所有URL` | 注释说明：并发处理所有统一资源链接(URL) |
| 339 | `          final futures = nextUrlList.map((url) async {` | 声明不可重新赋值的变量 futures：调用 下一章 URL 列表.映射(map)(...) → 映射 |
| 340 | `            try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 341 | `              final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 342 | `                url,` | 签名/调用续行参数：链接 |
| 343 | `                headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 344 | `                retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 345 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 346 | `              final pageHtml = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 页 HTML：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 347 | `              return {'url': url, 'html': pageHtml, 'success': true};` | 返回 {'链接': 链接, '网页内容': 页 HTML, '成功': 真(true)}（映射(Map)/集合字面量） |
| 348 | `            } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 349 | `              return {'url': url, 'html': '', 'success': false};` | 返回 {'链接': 链接, '网页内容': '', '成功': 假(false)}（映射(Map)/集合字面量） |
| 350 | `            }` | 闭合大括号，结束当前代码块 |
| 351 | `          }).toList();` | 闭合代码块并衔接后续语句：).转为列表(); |
| 352 | `&nbsp;` | 空行，分隔逻辑段落 |
| 353 | `          final results = await Future.wait(futures);` | 声明不可重新赋值的变量 结果：等待(await) 调用 异步结果(Future).wait(...) |
| 354 | `&nbsp;` | 空行，分隔逻辑段落 |
| 355 | `          // 分别解析每个URL的章节列表，然后合并` | 注释说明：分别解析每个统一资源链接(URL)的章节列表，然后合并 |
| 356 | `          for (final result in results) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 结果 属于(in) 结果 |
| 357 | `            if (result['success'] == true &&` | 条件判断 如果(if)：结果['成功'] 等于 真(true) 且 |
| 358 | `                (result['html'] as String).isNotEmpty) {` | (结果['网页内容'] 作为(as) 字符串(String)).是否非空) { |
| 359 | `              final pageHtml = result['html'] as String;` | 声明不可重新赋值的变量 页 HTML |
| 360 | `              final pageUrl = result['url'] as String;` | 声明不可重新赋值的变量 页 URL |
| 361 | `&nbsp;` | 空行，分隔逻辑段落 |
| 362 | `              final pageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 363 | `                pageHtml,` | 签名/调用续行参数：页 HTML |
| 364 | `                effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 365 | `                variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 366 | `                baseUrl: pageUrl,` | 命名实参 基础链接: 页 URL（base 统一资源链接(URL)） |
| 367 | `                getNextUrl: false, // 并发处理时不需要获取下一页URL` | 命名实参 获取 下一章 URL: 假(false)（获取 下一章 统一资源链接(URL)）；行尾注释：并发处理时不需要获取下一页统一资源链接(URL) |
| 368 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 369 | `&nbsp;` | 空行，分隔逻辑段落 |
| 370 | `              final pageChapterList =` | 上一表达式的续行：不可重新赋值(final) 页 章节 列表 = |
| 371 | `                  pageResult['chapterList'] as List<Map<String, String?>>;` | 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 372 | `              allChapterList.addAll(pageChapterList);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(页 章节 列表); |
| 373 | `            }` | 闭合大括号，结束当前代码块 |
| 374 | `          }` | 闭合大括号，结束当前代码块 |
| 375 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 376 | `          AppLog.instance.put('并发处理异常: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('并发处理异常: $e', error: e); |
| 377 | `        }` | 闭合大括号，结束当前代码块 |
| 378 | `      }` | 闭合大括号，结束当前代码块 |
| 379 | `&nbsp;` | 空行，分隔逻辑段落 |
| 380 | `      var chapterList = allChapterList;` | 声明自动类型推断的变量 章节 列表 |
| 381 | `&nbsp;` | 空行，分隔逻辑段落 |
| 382 | `      // 参考项目：转换为BookChapter对象（参考项目第217-256行）` | 注释说明：参考项目：转换为章节(BookChapter)对象（参考项目第217-256行） |
| 383 | `      // 参考项目不过滤"最新章节"，保留所有解析到的章节` | 注释说明：参考项目不过滤"最新章节"，保留所有解析到的章节 |
| 384 | `      var chapters = <BookChapter>[];` | 声明自动类型推断的变量 章节列表 |
| 385 | `      for (int i = 0; i < chapterList.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节 列表.长度(length); 循环变量 i++ |
| 386 | `        final chapterData = chapterList[i];` | 声明不可重新赋值的变量 chapterData |
| 387 | `        final chapterName = chapterData['chapterName'] ?? '';` | 声明不可重新赋值的变量 章节 名称 |
| 388 | `        final isVolumeStr = chapterData['isVolume'] ?? '0';` | 声明不可重新赋值的变量 isVolumeStr |
| 389 | `        final isVolume =` | 上一表达式的续行：不可重新赋值(final) isVolume = |
| 390 | `            isVolumeStr == '1' \|\| isVolumeStr.toLowerCase() == 'true';` | 续行赋值：将 = '1' \|\| isVolumeStr.toLowerCase() == '真(true)'; 赋给 isVolumeStr |
| 391 | `        final chapterUrl = chapterData['chapterUrl'];` | 声明不可重新赋值的变量 章节链接 |
| 392 | `&nbsp;` | 空行，分隔逻辑段落 |
| 393 | `        // 参考项目逻辑：` | 注释说明：参考项目逻辑： |
| 394 | `        // 1. 卷名（isVolume）不需要URL，即使URL为空也会添加` | 注释说明：1. 卷名（isVolume）不需要统一资源链接(URL)，即使统一资源链接(URL)为空也会添加 |
| 395 | `        // 2. 非卷名章节必须有URL` | 注释说明：2. 非卷名章节必须有统一资源链接(URL) |
| 396 | `        if (!isVolume && (chapterUrl == null \|\| chapterUrl.isEmpty)) {` | 条件判断 如果(if)：!isVolume 且 (chapterUrl 等于 null 或 chapterUrl.isEmpty) |
| 397 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 398 | `        }` | 闭合大括号，结束当前代码块 |
| 399 | `&nbsp;` | 空行，分隔逻辑段落 |
| 400 | `        // 过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接）` | 注释说明：过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接） |
| 401 | `        final trimmedName = chapterName.trim().replaceAll(RegExp(r'\s+'), '');` | 声明不可重新赋值的变量 trimmedName：调用 章节 名称.去除首尾空白(...) → 修剪 |
| 402 | `        if (chapterName.contains('上一页') \|\|` | 条件判断 如果(if)：章节 名称.是否包含('上一页') 或 |
| 403 | `            chapterName.contains('下一页') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('下一页') \|\| |
| 404 | `            chapterName.contains('上一章') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('上一章') \|\| |
| 405 | `            chapterName.contains('下一章') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('下一章') \|\| |
| 406 | `            trimmedName.isEmpty) {` | trimmedName.是否为空) { |
| 407 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 408 | `        }` | 闭合大括号，结束当前代码块 |
| 409 | `&nbsp;` | 空行，分隔逻辑段落 |
| 410 | `        // 参考项目：构建章节URL（参考项目第222-243行）` | 注释说明：参考项目：构建章节统一资源链接(URL)（参考项目第222-243行） |
| 411 | `        // 参考项目保存的是解析出来的原始URL，在getAbsoluteURL()中转换` | 注释说明：参考项目保存的是解析出来的原始统一资源链接(URL)，在getAbsoluteURL()中转换 |
| 412 | `        // 为了兼容性，我们这里仍然拼接为绝对URL，但不做额外规范化` | 注释说明：为了兼容性，我们这里仍然拼接为绝对统一资源链接(URL)，但不做额外规范化 |
| 413 | `        String finalUrl = '';` | 字符串(String) finalUrl = '' |
| 414 | `        if (chapterUrl != null && chapterUrl.isNotEmpty) {` | 条件判断 如果(if)：章节链接 不等于 空值(null) 且 章节链接.是否非空 |
| 415 | `          // 参考项目：bookChapter.url = analyzeRule.getString(urlRule)` | 注释说明：参考项目：书籍 章节.链接 = 分析 规则.获取 字符串(String)(URL 规则) |
| 416 | `          // 拼接为绝对URL，但不做额外规范化处理` | 注释说明：拼接为绝对统一资源链接(URL)，但不做额外规范化处理 |
| 417 | `          finalUrl = _repairChapterUrlWithBookVariables(` | 将 _repairChapterUrlWithBookVariables( 赋值给 finalUrl（调用 _repairChapterUrlWithBookVariables → 修复 章节 统一资源链接(URL) With 书籍 变量表） |
| 418 | `            NetworkService.joinUrl(effectiveBaseUrl, chapterUrl),` | 链式调用起始于 网络服务(NetworkService)（Network 服务），后续行继续该表达式：网络服务(NetworkService).拼接 URL(effectiveBaseUrl, 章节链接), |
| 419 | `            book,` | 签名/调用续行参数：书籍 |
| 420 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 421 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 422 | `          // 参考项目：如果 URL 为空，根据是否是卷名来设置` | 注释说明：参考项目：如果 统一资源链接(URL) 为空，根据是否是卷名来设置 |
| 423 | `          if (isVolume) {` | 条件判断 如果(if)：isVolume |
| 424 | `            // 参考项目：如果是卷名且URL为空，使用标题+索引作为URL` | 注释说明：参考项目：如果是卷名且统一资源链接(URL)为空，使用标题+索引作为统一资源链接(URL) |
| 425 | `            finalUrl = '$chapterName$i';` | finalUrl = '$章节 名称$循环变量 i' |
| 426 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 427 | `            // 参考项目：非卷名但URL为空，使用baseUrl替代` | 注释说明：参考项目：非卷名但统一资源链接(URL)为空，使用基础链接替代 |
| 428 | `            finalUrl = effectiveBaseUrl;` | 将 effectiveBaseUrl 赋值给 finalUrl |
| 429 | `          }` | 闭合大括号，结束当前代码块 |
| 430 | `        }` | 闭合大括号，结束当前代码块 |
| 431 | `&nbsp;` | 空行，分隔逻辑段落 |
| 432 | `        // 参考项目：章节标题直接使用原始标题` | 注释说明：参考项目：章节标题直接使用原始标题 |
| 433 | `        final chapterTitle =` | 上一表达式的续行：不可重新赋值(final) 章节 标题 = |
| 434 | `            chapterName.isNotEmpty ? chapterName : '第${i + 1}章';` | 章节 名称.是否非空 ? 章节 名称 : '第${循环变量 i + 1}章' |
| 435 | `&nbsp;` | 空行，分隔逻辑段落 |
| 436 | `        final chapter = BookChapter(` | 声明不可重新赋值的变量 章节：调用 章节(BookChapter)(...) → 书籍 章节 |
| 437 | `          url: finalUrl,` | 命名实参 链接: finalUrl（统一资源链接(URL)） |
| 438 | `          title: chapterTitle,` | 命名实参 标题: 章节 标题（标题） |
| 439 | `          bookUrl: book.bookUrl,` | 命名实参 书籍链接: 书籍.书籍链接（书籍 统一资源链接(URL)） |
| 440 | `          baseUrl: source.bookSourceUrl,` | 命名实参 基础链接: 书源.书源链接（base 统一资源链接(URL)） |
| 441 | `          index: chapters.length, // 使用过滤后的索引` | 命名实参 索引: 章节列表.长度(length)（索引）；行尾注释：使用过滤后的索引 |
| 442 | `          isVolume: isVolume, // 设置卷名标志` | 命名实参 isVolume: isVolume（是(is) 体积）；行尾注释：设置卷名标志 |
| 443 | `          isVip: chapterData['isVip'] == 'true' \|\| chapterData['isVip'] == '1',` | 命名实参 isVip: chapterData['isVip'] == '真(true)' \|\| chapterData['isVip'] == '1'（是(is) Vip） |
| 444 | `          tag: chapterData['updateTime'],` | 命名实参 tag: chapterData['updateTime'] |
| 445 | `          duration:` | 时长: |
| 446 | `              _parseDurationString(chapterData['duration']), // Phase 3：音视频时长` | 调用 _解析 时长 字符串(String)(...)：_解析 时长 字符串(String)(chapterData['时长']),（解析 时长 字符串(字符串(String))）；行尾注释：相位 3：音视频时长 |
| 447 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 448 | `&nbsp;` | 空行，分隔逻辑段落 |
| 449 | `        chapters.add(chapter);` | 链式调用起始于 章节列表（章节列表），后续行继续该表达式：章节列表.添加(章节); |
| 450 | `      }` | 闭合大括号，结束当前代码块 |
| 451 | `&nbsp;` | 空行，分隔逻辑段落 |
| 452 | `      final previewCount = chapters.length < 5 ? chapters.length : 5;` | 声明不可重新赋值的变量 previewCount |
| 453 | `      for (int i = 0; i < previewCount; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < previewCount; 循环变量 i++ |
| 454 | `        final chapter = chapters[i];` | 声明不可重新赋值的变量 章节 |
| 455 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 456 | `          '目录预览 ${i + 1}: title=${chapter.title}, url=${chapter.url}',` | 以字符串 '目录预览 ${循环变量 i + 1}: 标题=${章节.标题}, … 起始的表达式：, |
| 457 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 458 | `      }` | 闭合大括号，结束当前代码块 |
| 459 | `&nbsp;` | 空行，分隔逻辑段落 |
| 460 | `      // 参考项目：如果章节列表为空，抛出异常` | 注释说明：参考项目：如果章节列表为空，抛出异常 |
| 461 | `      if (chapters.isEmpty) {` | 条件判断 如果(if)：章节列表.是否为空 |
| 462 | `        throw TocEmptyException('章节列表为空');` | 定义方法 目录(TOC) 空 异常：返回 抛出(throw)；位置参数 1 个。语义：目录(目录(TOC)) 空 异常 |
| 463 | `      }` | 闭合大括号，结束当前代码块 |
| 464 | `&nbsp;` | 空行，分隔逻辑段落 |
| 465 | `      // 参考项目：反转逻辑（参考项目第119-120行）` | 注释说明：参考项目：反转逻辑（参考项目第119-120行） |
| 466 | `      // 如果 !reverse，反转章节列表` | 注释说明：如果 !reverse，反转章节列表 |
| 467 | `      if (!reverse) {` | 条件判断 如果(if)：!reverse |
| 468 | `        chapters = chapters.reversed.toList();` | 将 章节列表.reversed.转为列表() 赋值给 章节列表（调用 转为列表 → to 列表） |
| 469 | `      }` | 闭合大括号，结束当前代码块 |
| 470 | `&nbsp;` | 空行，分隔逻辑段落 |
| 471 | `      // 去重：保留第一个发现的章节` | 注释说明：去重：保留第一个发现的章节 |
| 472 | `      // LinkedHashSet 保留第一次出现的元素` | 注释说明：LinkedHashSet 保留第一次出现的元素 |
| 473 | `      final originalCount = chapters.length;` | 声明不可重新赋值的变量 originalCount |
| 474 | `      chapters = LinkedHashSet<BookChapter>.from(chapters).toList();` | 将 LinkedHashSet<章节(BookChapter)>.from(章节列表).转为列表() 赋值给 章节列表（调用 from/转为列表 → to 列表） |
| 475 | `      if (chapters.length < originalCount) {` | 条件判断 如果(if)：章节列表.长度(length) < originalCount |
| 476 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 477 | `            .put('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）');` | 链式调用延续：.写入数据库(put)('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）'); |
| 478 | `        final urlCounts = <String, int>{};` | 声明不可重新赋值的变量 urlCounts |
| 479 | `        for (final chapter in chapters.length == originalCount` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 章节 属于(in) 章节列表.长度(length) == originalCount |
| 480 | `            ? chapters` | 上一表达式的续行：? 章节列表 |
| 481 | `            : chapterList.map((item) {` | 三元表达式为假时取值：章节 列表.映射(map)((条目) { |
| 482 | `                final title = item['chapterName'] ?? '';` | 声明不可重新赋值的变量 标题 |
| 483 | `                final url = item['chapterUrl'] ?? '';` | 声明不可重新赋值的变量 链接 |
| 484 | `                return BookChapter(` | 返回调用 章节(BookChapter)(...) 的结果（语义：书籍 章节） |
| 485 | `                    url: url, title: title, bookUrl: book.bookUrl);` | 命名实参 链接: 链接, 标题: 标题, 书籍链接: 书籍.书籍链接);（统一资源链接(URL)） |
| 486 | `              })) {` | 闭合代码块并衔接后续语句：)) { |
| 487 | `          urlCounts[chapter.url] = (urlCounts[chapter.url] ?? 0) + 1;` | urlCounts[章节.链接] = (urlCounts[章节.链接] ?? 0) + 1 |
| 488 | `        }` | 闭合大括号，结束当前代码块 |
| 489 | `        final duplicates =` | 上一表达式的续行：不可重新赋值(final) duplicates = |
| 490 | `            urlCounts.entries.where((entry) => entry.value > 1).take(5);` | 链式调用起始于 urlCounts.条目集合（条目集合），后续行继续该表达式：urlCounts.条目集合.筛选(where)((条目) => 条目.值 > 1).截取(5); |
| 491 | `        for (final entry in duplicates) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 条目 属于(in) duplicates |
| 492 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 493 | `            '重复章节URL: url=${entry.key}, count=${entry.value}',` | 以字符串 '重复章节统一资源链接(URL): 链接=${条目.键}, 数量=${entr… 起始的表达式：, |
| 494 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 495 | `        }` | 闭合大括号，结束当前代码块 |
| 496 | `      }` | 闭合大括号，结束当前代码块 |
| 497 | `&nbsp;` | 空行，分隔逻辑段落 |
| 498 | `      // 参考项目：如果 !book.getReverseToc()，再次反转列表（参考项目第126-128行）` | 注释说明：参考项目：如果 !书籍.getReverseToc()，再次反转列表（参考项目第126-128行） |
| 499 | `      if (!book.getReverseToc()) {` | 条件判断 如果(if)：!书籍.getReverseToc() |
| 500 | `        chapters = chapters.reversed.toList();` | 将 章节列表.reversed.转为列表() 赋值给 章节列表（调用 转为列表 → to 列表） |
| 501 | `        AppLog.instance.put('反转章节列表（!book.getReverseToc()）');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('反转章节列表（!书籍.getReverseToc()）'); |
| 502 | `      }` | 闭合大括号，结束当前代码块 |
| 503 | `&nbsp;` | 空行，分隔逻辑段落 |
| 504 | `      // 重新设置索引` | 注释说明：重新设置索引 |
| 505 | `      for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 506 | `        chapters[i] = chapters[i].copyWith(index: i);` | 调用 copyWith(...)：章节列表[循环变量 i] = 章节列表[循环变量 i].copyWith(索引: 循环变量 i)（复制 With） |
| 507 | `      }` | 闭合大括号，结束当前代码块 |
| 508 | `&nbsp;` | 空行，分隔逻辑段落 |
| 509 | `      // 参考项目：formatJs 格式化章节标题` | 注释说明：参考项目：格式化 JS脚本 格式化章节标题 |
| 510 | `      final formatJs = effectiveTocRule?.formatJs;` | 声明不可重新赋值的变量 格式化 JS脚本 |
| 511 | `      if (formatJs != null && formatJs.isNotEmpty) {` | 条件判断 如果(if)：格式化 JS脚本 不等于 空值(null) 且 格式化 JS脚本.是否非空 |
| 512 | `        AppLog.instance.put('使用 formatJs 格式化章节标题');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('使用 formatJs 格式化章节标题'); |
| 513 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 514 | `          for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 515 | `            final chapter = chapters[i];` | 声明不可重新赋值的变量 章节 |
| 516 | `            final bindings = <String, dynamic>{` | 声明不可重新赋值的变量 bindings |
| 517 | `              'gInt': 0,` | 映射(Map) 条目 'gInt': 0, |
| 518 | `              'index': i + 1, // 参考项目：index 从 1 开始` | 映射(Map) 条目 '索引': 循环变量 i + 1,；行尾注释：参考项目：索引 从 1 开始 |
| 519 | `              'chapter': {` | 映射(Map) 条目 '章节': { |
| 520 | `                'title': chapter.title,` | 映射(Map) 条目 '标题': 章节.标题, |
| 521 | `                'url': chapter.url,` | 映射(Map) 条目 '链接': 章节.链接, |
| 522 | `                'index': chapter.index,` | 映射(Map) 条目 '索引': 章节.索引, |
| 523 | `              },` | 结束上一个列表/参数项 |
| 524 | `              'title': chapter.title,` | 映射(Map) 条目 '标题': 章节.标题, |
| 525 | `            };` | 闭合代码块并衔接后续语句：; |
| 526 | `            final result = await JSEngine.evalJS(formatJs, bindings: bindings);` | 声明不可重新赋值的变量 结果：等待(await) 调用 JS脚本 引擎.evalJS(...) → eval JavaScript脚本(JS)脚本 |
| 527 | `            if (result != null && result.toString().isNotEmpty) {` | 条件判断 如果(if)：结果 不等于 空值(null) 且 结果.转为字符串().是否非空 |
| 528 | `              chapters[i] = chapter.copyWith(title: result.toString());` | 调用 copyWith/转为字符串(...)：章节列表[循环变量 i] = 章节.copyWith(标题: 结果.转为字符串())（复制 With to 字符串(字符串(String))） |
| 529 | `              AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 530 | `                  '格式化章节 ${i + 1}: ${chapter.title} -> ${result.toString()}');` | 以字符串 '格式化章节 ${循环变量 i + 1}: ${章节.标题} -> ${r… 起始的表达式：); |
| 531 | `            }` | 闭合大括号，结束当前代码块 |
| 532 | `          }` | 闭合大括号，结束当前代码块 |
| 533 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 534 | `          AppLog.instance.put('格式化标题出错: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('格式化标题出错: $e', error: e); |
| 535 | `        }` | 闭合大括号，结束当前代码块 |
| 536 | `      }` | 闭合大括号，结束当前代码块 |
| 537 | `&nbsp;` | 空行，分隔逻辑段落 |
| 538 | `      // 参考项目：更新书籍信息（参考项目第154-164行）` | 注释说明：参考项目：更新书籍信息（参考项目第154-164行） |
| 539 | `      // 获取替换规则处理器` | 注释说明：获取替换规则处理器 |
| 540 | `      final contentProcessor = ContentProcessor.get(book);` | 声明不可重新赋值的变量 contentProcessor：调用 ContentProcessor.读取(getter)(...) → 获取 |
| 541 | `&nbsp;` | 空行，分隔逻辑段落 |
| 542 | `      // 更新 durChapterTitle（参考项目第154行）` | 注释说明：更新 durChapterTitle（参考项目第154行） |
| 543 | `      if (chapters.isNotEmpty) {` | 条件判断 如果(if)：章节列表.是否非空 |
| 544 | `        final currentChapterIndex = book.durChapterIndex;` | 声明不可重新赋值的变量 当前 章节 索引 |
| 545 | `        if (currentChapterIndex >= 0 && currentChapterIndex < chapters.length) {` | 条件判断 如果(if)：当前 章节 索引 > = 0 且 当前 章节 索引 < 章节列表.长度(length) |
| 546 | `          final currentChapter = chapters[currentChapterIndex];` | 声明不可重新赋值的变量 当前 章节 |
| 547 | `          final displayTitle = await contentProcessor.getDisplayTitle(` | 声明不可重新赋值的变量 显示 标题：等待(await) 调用 contentProcessor.获取 显示 标题(...) → 获取 显示 标题 |
| 548 | `            currentChapter,` | 签名/调用续行参数：当前 章节 |
| 549 | `            useReplace: book.getUseReplaceRule(),` | 命名实参 useReplace: 书籍.getUseReplaceRule()（use 替换） |
| 550 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 551 | `          book.durChapterTitle = displayTitle;` | 将 显示 标题 赋值给 书籍.durChapterTitle |
| 552 | `        } else if (chapters.isNotEmpty) {` | 闭合上一代码块并开始 否则(else) 如果(if) (章节列表.是否非空) { |
| 553 | `          // 如果索引超出范围，使用最后一个章节` | 注释说明：如果索引超出范围，使用最后一个章节 |
| 554 | `          final lastChapter = chapters.last;` | 声明不可重新赋值的变量 最后 章节 |
| 555 | `          final displayTitle = await contentProcessor.getDisplayTitle(` | 声明不可重新赋值的变量 显示 标题：等待(await) 调用 contentProcessor.获取 显示 标题(...) → 获取 显示 标题 |
| 556 | `            lastChapter,` | 签名/调用续行参数：最后 章节 |
| 557 | `            useReplace: book.getUseReplaceRule(),` | 命名实参 useReplace: 书籍.getUseReplaceRule()（use 替换） |
| 558 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 559 | `          book.durChapterTitle = displayTitle;` | 将 显示 标题 赋值给 书籍.durChapterTitle |
| 560 | `        }` | 闭合大括号，结束当前代码块 |
| 561 | `      }` | 闭合大括号，结束当前代码块 |
| 562 | `&nbsp;` | 空行，分隔逻辑段落 |
| 563 | `      // 更新 lastCheckCount 和 latestChapterTime（参考项目第156-158行）` | 注释说明：更新 最后 检查 数量 和 latestChapterTime（参考项目第156-158行） |
| 564 | `      if (book.totalChapterNum < chapters.length) {` | 条件判断 如果(if)：书籍.totalChapterNum < 章节列表.长度(length) |
| 565 | `        book.lastCheckCount = chapters.length - book.totalChapterNum;` | 将 章节列表.长度(length) - 书籍.totalChapterNum 赋值给 书籍.最后 检查 数量 |
| 566 | `        book.latestChapterTime = DateTime.now().millisecondsSinceEpoch;` | 将 DateTime.now().millisecondsSinceEpoch 赋值给 书籍.latestChapterTime |
| 567 | `      }` | 闭合大括号，结束当前代码块 |
| 568 | `&nbsp;` | 空行，分隔逻辑段落 |
| 569 | `      // 更新 lastCheckTime 和 totalChapterNum（参考项目第160-161行）` | 注释说明：更新 lastCheckTime 和 totalChapterNum（参考项目第160-161行） |
| 570 | `      book.lastCheckTime = DateTime.now().millisecondsSinceEpoch;` | 将 DateTime.now().millisecondsSinceEpoch 赋值给 书籍.lastCheckTime |
| 571 | `      book.totalChapterNum = chapters.length;` | 将 章节列表.长度(length) 赋值给 书籍.totalChapterNum |
| 572 | `&nbsp;` | 空行，分隔逻辑段落 |
| 573 | `      // 更新 latestChapterTitle（参考项目第162-164行）` | 注释说明：更新 latestChapterTitle（参考项目第162-164行） |
| 574 | `      if (chapters.isNotEmpty) {` | 条件判断 如果(if)：章节列表.是否非空 |
| 575 | `        final simulatedIndex = book.simulatedTotalChapterNum() - 1;` | 声明不可重新赋值的变量 simulatedIndex：调用 书籍.simulatedTotalChapterNum(...) → simulated Total 章节 编号 |
| 576 | `        final latestChapterIndex =` | 上一表达式的续行：不可重新赋值(final) latestChapterIndex = |
| 577 | `            simulatedIndex >= 0 && simulatedIndex < chapters.length` | 上一表达式的续行：simulatedIndex >= 0 && simulatedIndex < 章节列表.长度(length) |
| 578 | `                ? simulatedIndex` | 上一表达式的续行：? simulatedIndex |
| 579 | `                : chapters.length - 1;` | 三元表达式为假时取值：章节列表.长度(length) - 1; |
| 580 | `        final latestChapter = chapters[latestChapterIndex];` | 声明不可重新赋值的变量 latestChapter |
| 581 | `        final displayTitle = await contentProcessor.getDisplayTitle(` | 声明不可重新赋值的变量 显示 标题：等待(await) 调用 contentProcessor.获取 显示 标题(...) → 获取 显示 标题 |
| 582 | `          latestChapter,` | 签名/调用续行参数：latestChapter |
| 583 | `          useReplace: book.getUseReplaceRule(),` | 命名实参 useReplace: 书籍.getUseReplaceRule()（use 替换） |
| 584 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 585 | `        book.latestChapterTitle = displayTitle;` | 将 显示 标题 赋值给 书籍.latestChapterTitle |
| 586 | `      }` | 闭合大括号，结束当前代码块 |
| 587 | `&nbsp;` | 空行，分隔逻辑段落 |
| 588 | `      // 参考项目：getWordCount（参考项目第272-286行）` | 注释说明：参考项目：获取 单词 数量（参考项目第272-286行） |
| 589 | `      // 从数据库获取已存在的章节字数` | 注释说明：从数据库获取已存在的章节字数 |
| 590 | `      await getWordCount(chapters, book);` | 调用 获取 单词 数量(...)（等待异步完成） → 获取 单词 数量 |
| 591 | `&nbsp;` | 空行，分隔逻辑段落 |
| 592 | `      AppLog.instance.put('获取章节列表成功: 共 ${chapters.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表成功: 共 ${chapters.length} 个章节'); |
| 593 | `&nbsp;` | 空行，分隔逻辑段落 |
| 594 | `      // 保存章节列表到数据库` | 注释说明：保存章节列表到数据库 |
| 595 | `      await saveChapters(chapters);` | 调用 保存 章节列表(...)（等待异步完成） → 保存 章节列表 |
| 596 | `&nbsp;` | 空行，分隔逻辑段落 |
| 597 | `      // 更新书籍信息到数据库` | 注释说明：更新书籍信息到数据库 |
| 598 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 599 | `        await updateBook(book);` | 调用 更新 书籍(...)（等待异步完成） → 更新 书籍 |
| 600 | `      } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 601 | `        AppLog.instance.put('更新书籍信息失败: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('更新书籍信息失败: $e', error: e); |
| 602 | `      }` | 闭合大括号，结束当前代码块 |
| 603 | `&nbsp;` | 空行，分隔逻辑段落 |
| 604 | `      return chapters;` | 返回 章节列表 |
| 605 | `    } catch (e, stackTrace) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e, stackTrace |
| 606 | `      AppLog.instance.put('获取章节列表失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败', error: e); |
| 607 | `      AppLog.instance.put('错误堆栈: $stackTrace');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('错误堆栈: $stackTrace'); |
| 608 | `      // 如果获取失败，尝试从数据库读取` | 注释说明：如果获取失败，尝试从数据库读取 |
| 609 | `      return await _getLocalChapters(book.bookUrl);` | 返回异步调用 _获取 本地 章节列表(...) 的结果（语义：获取 本地 章节列表） |
| 610 | `    }` | 闭合大括号，结束当前代码块 |
| 611 | `  }` | 闭合大括号，结束当前代码块 |
| 612 | `&nbsp;` | 空行，分隔逻辑段落 |
| 613 | `  /// 获取章节列表但不保存到数据库（用于探索页面）` | 文档注释：说明其后代码的用途 |
| 614 | `  Future<List<BookChapter>> getChapterListWithoutSave(` | 【承接上方文档】获取章节列表但不保存到数据库（用于探索页面） → 定义方法 getChapterListWithoutSave：返回 异步结果(Future)<列表(List)<章节(BookChapter)>>；无参数（异步）。语义：获取 章节 列表 Without 保存 |
| 615 | `    Book book, {` | 书籍(Book) 类型参数 书籍，其后 { 开启命名参数块（书籍） |
| 616 | `    bool loadAllPages = true,` | 布尔(bool) 类型参数 加载 全部 分页，默认值 真(true)（加载 全部 分页） |
| 617 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 618 | `    if (book.isLocal) {` | 条件判断 如果(if)：书籍.isLocal |
| 619 | `      // 本地书籍从数据库读取章节` | 注释说明：本地书籍从数据库读取章节 |
| 620 | `      return await _getLocalChapters(book.bookUrl);` | 返回异步调用 _获取 本地 章节列表(...) 的结果（语义：获取 本地 章节列表） |
| 621 | `    }` | 闭合大括号，结束当前代码块 |
| 622 | `&nbsp;` | 空行，分隔逻辑段落 |
| 623 | `    final source = await _bookSourceService.getBookSourceByUrl(book.origin);` | 声明不可重新赋值的变量 书源：等待(await) 调用 _书籍 书源 服务.getBookSourceByUrl(...) → 获取 书籍 书源 By 统一资源链接(URL) |
| 624 | `    if (source == null) {` | 条件判断 如果(if)：书源 等于 空值(null) |
| 625 | `      AppLog.instance.put('获取章节列表失败: 书源不存在 (origin: ${book.origin})');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败: 书源不存在 (来源: ${书籍.来源})'); |
| 626 | `      return [];` | 返回 []（列表字面量） |
| 627 | `    }` | 闭合大括号，结束当前代码块 |
| 628 | `&nbsp;` | 空行，分隔逻辑段落 |
| 629 | `    if (source.ruleToc == null) {` | 条件判断 如果(if)：书源.目录规则 等于 空值(null) |
| 630 | `      AppLog.instance.put('获取章节列表失败: 目录规则为空 (书源: ${source.bookSourceName})');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败: 目录规则为空 (书源: ${source.bookSourceName})')… |
| 631 | `      return [];` | 返回 []（列表字面量） |
| 632 | `    }` | 闭合大括号，结束当前代码块 |
| 633 | `&nbsp;` | 空行，分隔逻辑段落 |
| 634 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 635 | `      final chapterVariables = _buildRuleVariables(book);` | 声明不可重新赋值的变量 章节 变量表：调用 _构建 规则 变量表(...) → 构建 规则 变量表 |
| 636 | `      // 使用tocUrl或bookUrl` | 注释说明：使用目录(TOC) URL或书籍链接 |
| 637 | `      final tocUrl = book.tocUrl.isNotEmpty ? book.tocUrl : book.bookUrl;` | 声明不可重新赋值的变量 目录(TOC) URL |
| 638 | `      AppLog.instance.put('开始获取章节列表: tocUrl=$tocUrl, bookUrl=${book.bookUrl}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('开始获取章节列表: 目录(TOC) URL=$目录(TOC) URL, 书籍链接=${书籍.书籍链接}… |
| 639 | `&nbsp;` | 空行，分隔逻辑段落 |
| 640 | `      // 发送请求` | 注释说明：发送请求 |
| 641 | `      final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 642 | `        tocUrl,` | 签名/调用续行参数：目录(TOC) URL |
| 643 | `        headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 644 | `        retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 645 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 646 | `&nbsp;` | 空行，分隔逻辑段落 |
| 647 | `      final html = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 网页内容：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 648 | `      AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 649 | `          .put('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}');` | 链式调用延续：.写入数据库(put)('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}'); |
| 650 | `&nbsp;` | 空行，分隔逻辑段落 |
| 651 | `      if (html.isEmpty) {` | 条件判断 如果(if)：网页内容.是否为空 |
| 652 | `        AppLog.instance.put('获取章节列表失败: 响应内容为空');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败: 响应内容为空'); |
| 653 | `        throw TocEmptyException('获取章节列表失败: 响应内容为空');` | 定义方法 目录(TOC) 空 异常：返回 抛出(throw)；位置参数 1 个；参数名: 获取章节列表失败。语义：目录(目录(TOC)) 空 异常 |
| 654 | `      }` | 闭合大括号，结束当前代码块 |
| 655 | `&nbsp;` | 空行，分隔逻辑段落 |
| 656 | `      // 检查HTML中是否包含可能的目录容器` | 注释说明：检查网页标记文本(HTML)中是否包含可能的目录容器 |
| 657 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 658 | `          '检查HTML结构: 是否包含id="list": ${html.contains('id="list"') \|\| html.contains("id='list'")}');` | 以字符串 '检查网页标记文本(HTML)结构: 是否包含编号(id)="list": ${网页内容.contain… 起始的表达式：编号(id)="list"') \|\| 网页内容.是否包含("编号(id)='list'")}'); |
| 659 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 660 | `          '检查HTML结构: 是否包含class="list": ${html.contains('class="list"') \|\| html.contains("class='list'")}');` | 以字符串 '检查网页标记文本(HTML)结构: 是否包含类(class)="list": ${网页内容.cont… 起始的表达式：类(class)="list"') \|\| 网页内容.是否包含("类(class)='list'")}'); |
| 661 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 662 | `          '检查HTML结构: 是否包含<dd>标签: ${html.contains('<dd>') \|\| html.contains('<DD>')}');` | 以字符串 '检查网页标记文本(HTML)结构: 是否包含<dd>标签: ${网页内容.是否包含(' 起始的表达式：<dd>') \|\| 网页内容.是否包含('<DD>')}'); |
| 663 | `&nbsp;` | 空行，分隔逻辑段落 |
| 664 | `      // 查找所有可能的目录相关元素` | 注释说明：查找所有可能的目录相关元素 |
| 665 | `      final listIdPattern = RegExp('id\\s*=\\s*["\']([^"\']*list[^"\']*)["\']',` | 不可重新赋值(final) 类型参数 列表 编号(id) 模式，默认值 正则表达式(RegExp)('编号(id)\\s*=\\s*["\']([^"\']*list[^"\…（列表 编号(编号(id)) 模式） |
| 666 | `          caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 667 | `      final listIds = listIdPattern` | 上一表达式的续行：不可重新赋值(final) listIds = 列表 编号(id) 模式 |
| 668 | `          .allMatches(html)` | 链式调用延续：.allMatches(网页内容) |
| 669 | `          .map((m) => m.group(1))` | 链式调用延续：.映射(map)((m) => m.捕获组(1)) |
| 670 | `          .whereType<String>()` | 链式调用延续：.筛选(where) 类型<字符串(String)>() |
| 671 | `          .take(5)` | 链式调用延续：.截取(5) |
| 672 | `          .toList();` | 链式调用延续：.转为列表(); |
| 673 | `      if (listIds.isNotEmpty) {` | 条件判断 如果(if)：listIds.是否非空 |
| 674 | `        AppLog.instance.put('HTML中找到包含"list"的id: ${listIds.join(", ")}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('网页标记文本(HTML)中找到包含"list"的编号(id): ${listIds.拼接(", ")}'); |
| 675 | `      }` | 闭合大括号，结束当前代码块 |
| 676 | `&nbsp;` | 空行，分隔逻辑段落 |
| 677 | `      final listClassPattern = RegExp(` | 声明不可重新赋值的变量 listClassPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 678 | `          'class\\s*=\\s*["\']([^"\']*list[^"\']*)["\']',` | 以字符串 '类(class)\\s*=\\s*["\']([^"\']*list[^"\']*)… 起始的表达式：, |
| 679 | `          caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 680 | `      final listClasses = listClassPattern` | 上一表达式的续行：不可重新赋值(final) listClasses = listClassPattern |
| 681 | `          .allMatches(html)` | 链式调用延续：.allMatches(网页内容) |
| 682 | `          .map((m) => m.group(1))` | 链式调用延续：.映射(map)((m) => m.捕获组(1)) |
| 683 | `          .whereType<String>()` | 链式调用延续：.筛选(where) 类型<字符串(String)>() |
| 684 | `          .take(5)` | 链式调用延续：.截取(5) |
| 685 | `          .toList();` | 链式调用延续：.转为列表(); |
| 686 | `      if (listClasses.isNotEmpty) {` | 条件判断 如果(if)：listClasses.是否非空 |
| 687 | `        AppLog.instance.put('HTML中找到包含"list"的class: ${listClasses.join(", ")}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('网页标记文本(HTML)中找到包含"list"的类(class): ${listClasses.拼接(", ")}'… |
| 688 | `      }` | 闭合大括号，结束当前代码块 |
| 689 | `&nbsp;` | 空行，分隔逻辑段落 |
| 690 | `      // 解析章节列表` | 注释说明：解析章节列表 |
| 691 | `      // 参考项目：baseUrl使用tocUrl（实际请求的URL），而不是书源的基础URL` | 注释说明：参考项目：基础链接使用目录(TOC) URL（实际请求的统一资源链接(URL)），而不是书源的基础统一资源链接(URL) |
| 692 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 693 | `          '开始解析章节列表: ruleToc=${source.ruleToc?.toJson()}, chapterList规则=${source.ruleToc?.chapterList}');` | 以字符串 '开始解析章节列表: 目录规则=${书源.目录规则?.toJ… 起始的表达式：); |
| 694 | `&nbsp;` | 空行，分隔逻辑段落 |
| 695 | `      // 确定有效的baseUrl：如果tocUrl不是有效的绝对URL，使用source.bookSourceUrl` | 注释说明：确定有效的基础链接：如果目录(TOC) URL不是有效的绝对统一资源链接(URL)，使用书源.书源链接 |
| 696 | `      String? effectiveBaseUrl = tocUrl;` | 字符串(String)? effectiveBaseUrl = 目录(TOC) URL |
| 697 | `      if (!tocUrl.isAbsUrl()) {` | 条件判断 如果(if)：!目录(TOC) URL.isAbsUrl() |
| 698 | `        // 如果source.bookSourceUrl也是有效的绝对URL，使用它；否则尝试从tocUrl构建` | 注释说明：如果书源.书源链接也是有效的绝对统一资源链接(URL)，使用它；否则尝试从目录(TOC) URL构建 |
| 699 | `        if (source.bookSourceUrl.isAbsUrl()) {` | 条件判断 如果(if)：书源.书源链接.isAbsUrl() |
| 700 | `          effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 701 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 702 | `              'tocUrl不是绝对URL，使用source.bookSourceUrl作为baseUrl: $effectiveBaseUrl');` | 以字符串 '目录(TOC) URL不是绝对统一资源链接(URL)，使用书源.书源链接作为b… 起始的表达式：); |
| 703 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 704 | `          // 如果两者都不是绝对URL，尝试从tocUrl构建完整的URL` | 注释说明：如果两者都不是绝对统一资源链接(URL)，尝试从目录(TOC) URL构建完整的统一资源链接(URL) |
| 705 | `          // 如果tocUrl是相对路径，使用source.bookSourceUrl作为基础` | 注释说明：如果目录(TOC) URL是相对路径，使用书源.书源链接作为基础 |
| 706 | `          try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 707 | `            effectiveBaseUrl =` | 上一表达式的续行：effectiveBaseUrl = |
| 708 | `                NetworkService.joinUrl(source.bookSourceUrl, tocUrl);` | 链式调用起始于 网络服务(NetworkService)（Network 服务），后续行继续该表达式：网络服务(NetworkService).拼接 URL(书源.书源链接, 目录(TOC) URL); |
| 709 | `            if (!effectiveBaseUrl.isAbsUrl()) {` | 条件判断 如果(if)：!effectiveBaseUrl.isAbsUrl() |
| 710 | `              // 如果仍然无效，使用source.bookSourceUrl` | 注释说明：如果仍然无效，使用书源.书源链接 |
| 711 | `              effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 712 | `            }` | 闭合大括号，结束当前代码块 |
| 713 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 714 | `                'tocUrl和source.bookSourceUrl都不是绝对URL，尝试拼接后: $effectiveBaseUrl');` | 以字符串 '目录(TOC) URL和书源.书源链接都不是绝对统一资源链接(URL)，尝试拼… 起始的表达式：); |
| 715 | `          } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 716 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 717 | `                '构建baseUrl失败: $e，使用source.bookSourceUrl: ${source.bookSourceUrl}');` | 以字符串 '构建基础链接失败: $异常对象 e，使用书源.书源链接:… 起始的表达式：); |
| 718 | `            effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 719 | `          }` | 闭合大括号，结束当前代码块 |
| 720 | `        }` | 闭合大括号，结束当前代码块 |
| 721 | `      }` | 闭合大括号，结束当前代码块 |
| 722 | `&nbsp;` | 空行，分隔逻辑段落 |
| 723 | `      // 最终验证：确保effectiveBaseUrl是有效的绝对URL` | 注释说明：最终验证：确保effectiveBaseUrl是有效的绝对统一资源链接(URL) |
| 724 | `      if (!effectiveBaseUrl.isAbsUrl()) {` | 条件判断 如果(if)：!effectiveBaseUrl.isAbsUrl() |
| 725 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 726 | `            .put('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败');` | 链式调用延续：.写入数据库(put)('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败'); |
| 727 | `      }` | 闭合大括号，结束当前代码块 |
| 728 | `&nbsp;` | 空行，分隔逻辑段落 |
| 729 | `      // 首先尝试使用原始规则获取第一页，如果失败则使用降级规则` | 注释说明：首先尝试使用原始规则获取第一页，如果失败则使用降级规则 |
| 730 | `      TocRule? effectiveTocRule = source.ruleToc;` | 目录(TOC) 规则? effectiveTocRule = 书源.目录规则 |
| 731 | `      String? fallbackChapterListRule;` | 字符串(String)? 回退/降级 章节 列表 规则 |
| 732 | `&nbsp;` | 空行，分隔逻辑段落 |
| 733 | `      // 检查原始规则是否能匹配到章节` | 注释说明：检查原始规则是否能匹配到章节 |
| 734 | `      var testChapterList = RuleParser.parseTocRule(` | 声明自动类型推断的变量 testChapterList：调用 规则解析器(RuleParser).解析 目录(TOC) 规则(...) → 解析 目录(目录(TOC)) 规则 |
| 735 | `        html,` | 签名/调用续行参数：网页内容 |
| 736 | `        source.ruleToc,` | 签名/调用续行参数：书源.目录规则 |
| 737 | `        baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 738 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 739 | `&nbsp;` | 空行，分隔逻辑段落 |
| 740 | `      if (testChapterList.isEmpty && source.ruleToc?.chapterList != null) {` | 条件判断 如果(if)：testChapterList.是否为空 且 书源.目录规则?.章节 列表 不等于 空值(null) |
| 741 | `        AppLog.instance.put('原始规则未匹配到章节，尝试智能降级处理');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('原始规则未匹配到章节，尝试智能降级处理'); |
| 742 | `&nbsp;` | 空行，分隔逻辑段落 |
| 743 | `        // 查找降级规则` | 注释说明：查找降级规则 |
| 744 | `        final chapterLinkPattern = RegExp(` | 声明不可重新赋值的变量 chapterLinkPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 745 | `            '<a[^>]*href=["\']/[^"\']*\\.html["\'][^>]*>.*?</a>',` | 以字符串 '<a[^>]*href=["\']/[^"\']*\\.网页内容["\'][^… 起始的表达式：, |
| 746 | `            caseSensitive: false,` | 区分大小写开关: 假(false), |
| 747 | `            dotAll: true);` | 命名实参 点号 全部: 真(true));（点号 全部） |
| 748 | `        final chapterLinkMatches = chapterLinkPattern.allMatches(html).toList();` | 声明不可重新赋值的变量 chapterLinkMatches：调用 chapterLinkPattern.allMatches(...) → 全部 Matches |
| 749 | `&nbsp;` | 空行，分隔逻辑段落 |
| 750 | `        if (chapterLinkMatches.isNotEmpty) {` | 条件判断 如果(if)：chapterLinkMatches.是否非空 |
| 751 | `          AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 752 | `              .put('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器');` | 链式调用延续：.写入数据库(put)('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器'); |
| 753 | `&nbsp;` | 空行，分隔逻辑段落 |
| 754 | `          html_dom.Element? directoryContainer;` | html_dom.Element? directoryContainer |
| 755 | `          String? containerClass;` | 字符串(String)? containerClass |
| 756 | `          String? containerId;` | 字符串(String)? containerId |
| 757 | `&nbsp;` | 空行，分隔逻辑段落 |
| 758 | `          // 首先尝试查找directoryArea容器` | 注释说明：首先尝试查找directoryArea容器 |
| 759 | `          final doc = html_parser.parse(html);` | 声明不可重新赋值的变量 文档：调用 HTML 解析器.parse(...) → 解析 |
| 760 | `          final directoryPattern = RegExp(` | 声明不可重新赋值的变量 目录(directory) 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 761 | `              'class\\s*=\\s*["\'][^"\']*directory[^"\']*["\']',` | 以字符串 '类(class)\\s*=\\s*["\'][^"\']*目录(directory)[^"\… 起始的表达式：, |
| 762 | `              caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 763 | `          final directoryMatches = directoryPattern.allMatches(html);` | 声明不可重新赋值的变量 directoryMatches：调用 目录(directory) 模式.allMatches(...) → 全部 Matches |
| 764 | `          if (directoryMatches.isNotEmpty) {` | 条件判断 如果(if)：directoryMatches.是否非空 |
| 765 | `            final match = directoryMatches.first;` | 声明不可重新赋值的变量 match |
| 766 | `            final matchHtml = html.substring(match.start, match.end);` | 声明不可重新赋值的变量 matchHtml |
| 767 | `            final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 768 | `                caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 769 | `            final classMatch = classPattern.firstMatch(matchHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 770 | `            if (classMatch != null) {` | 条件判断 如果(if)：classMatch 不等于 空值(null) |
| 771 | `              final allClasses =` | 上一表达式的续行：不可重新赋值(final) allClasses = |
| 772 | `                  classMatch.group(1)?.split(RegExp(r'\s+')) ?? [];` | 链式调用起始于 classMatch，后续行继续该表达式：classMatch.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')) ?? []; |
| 773 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 774 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 775 | `                orElse: () => '',` | 命名实参 orElse: () => ''（or Else） |
| 776 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 777 | `              if (dirClass.isNotEmpty) {` | 条件判断 如果(if)：dirClass.是否非空 |
| 778 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 779 | `                    HtmlParser.selectElement(doc, 'div.$dirClass');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div.$dirClass'); |
| 780 | `                containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 781 | `                AppLog.instance.put('找到directory容器: class=$containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到directory容器: class=$containerClass'); |
| 782 | `              }` | 闭合大括号，结束当前代码块 |
| 783 | `            }` | 闭合大括号，结束当前代码块 |
| 784 | `          }` | 闭合大括号，结束当前代码块 |
| 785 | `&nbsp;` | 空行，分隔逻辑段落 |
| 786 | `          // 如果找到了directory容器，提取其class或id用于生成降级规则` | 注释说明：如果找到了目录(directory)容器，提取其类(class)或编号(id)用于生成降级规则 |
| 787 | `          if (directoryContainer != null) {` | 条件判断 如果(if)：directoryContainer 不等于 空值(null) |
| 788 | `            final dirClassAttr = directoryContainer.attributes['class'];` | 声明不可重新赋值的变量 dirClassAttr |
| 789 | `            final dirIdAttr = directoryContainer.attributes['id'];` | 声明不可重新赋值的变量 dirIdAttr |
| 790 | `            if (dirClassAttr != null && dirClassAttr.contains('directory')) {` | 条件判断 如果(if)：dirClassAttr 不等于 空值(null) 且 dirClassAttr.是否包含('目录(directory)') |
| 791 | `              final allClasses = dirClassAttr.split(RegExp(r'\s+'));` | 声明不可重新赋值的变量 allClasses：调用 dirClassAttr.切分(...) → 切分 |
| 792 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 793 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 794 | `                orElse: () => allClasses.first,` | 命名实参 orElse: () => allClasses.first（or Else） |
| 795 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 796 | `              containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 797 | `              AppLog.instance.put('从directory容器提取class: $containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取class: $containerClass'); |
| 798 | `            }` | 闭合大括号，结束当前代码块 |
| 799 | `            if (dirIdAttr != null) {` | 条件判断 如果(if)：dirIdAttr 不等于 空值(null) |
| 800 | `              containerId = dirIdAttr;` | 将 dirIdAttr 赋值给 containerId |
| 801 | `              AppLog.instance.put('从directory容器提取id: $containerId');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取id: $containerId'); |
| 802 | `            }` | 闭合大括号，结束当前代码块 |
| 803 | `          }` | 闭合大括号，结束当前代码块 |
| 804 | `&nbsp;` | 空行，分隔逻辑段落 |
| 805 | `          // 生成降级规则` | 注释说明：生成降级规则 |
| 806 | `          if (containerClass != null) {` | 条件判断 如果(if)：containerClass 不等于 空值(null) |
| 807 | `            fallbackChapterListRule = 'class.$containerClass@tag.a';` | 回退/降级 章节 列表 规则 = '类(class).$containerClass@tag.a' |
| 808 | `            AppLog.instance.put('使用降级规则: $fallbackChapterListRule');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('使用降级规则: $fallbackChapterListRule'); |
| 809 | `          }` | 闭合大括号，结束当前代码块 |
| 810 | `        }` | 闭合大括号，结束当前代码块 |
| 811 | `&nbsp;` | 空行，分隔逻辑段落 |
| 812 | `        // 如果找到了降级规则，创建临时规则对象` | 注释说明：如果找到了降级规则，创建临时规则对象 |
| 813 | `        if (fallbackChapterListRule != null) {` | 条件判断 如果(if)：回退/降级 章节 列表 规则 不等于 空值(null) |
| 814 | `          effectiveTocRule = TocRule(` | 将 目录(TOC) 规则( 赋值给 effectiveTocRule（调用 目录(TOC) 规则 → 目录(目录(TOC)) 规则） |
| 815 | `            chapterList: fallbackChapterListRule,` | 命名实参 章节 列表: 回退/降级 章节 列表 规则（章节 列表） |
| 816 | `            chapterName: source.ruleToc?.chapterName ?? 'tag.a@text',` | 命名实参 章节 名称: 书源.目录规则?.章节 名称 ?? 'tag.a@文本'（章节 名称） |
| 817 | `            chapterUrl: source.ruleToc?.chapterUrl ?? 'tag.a@href',` | 命名实参 章节链接: 书源.目录规则?.章节链接 ?? 'tag.a@href'（章节 统一资源链接(URL)） |
| 818 | `            isVip: source.ruleToc?.isVip,` | 命名实参 isVip: 书源.目录规则?.isVip（是(is) Vip） |
| 819 | `            isVolume: source.ruleToc?.isVolume, // 保留卷名规则` | 命名实参 isVolume: 书源.目录规则?.isVolume（是(is) 体积）；行尾注释：保留卷名规则 |
| 820 | `            updateTime: source.ruleToc?.updateTime,` | 命名实参 updateTime: 书源.目录规则?.updateTime（更新 Time） |
| 821 | `            nextTocUrl: source.ruleToc?.nextTocUrl,` | 命名实参 下一页目录链接: 书源.目录规则?.下一页目录链接（下一章 目录(目录(TOC)) 统一资源链接(URL)） |
| 822 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 823 | `        }` | 闭合大括号，结束当前代码块 |
| 824 | `      }` | 闭合大括号，结束当前代码块 |
| 825 | `&nbsp;` | 空行，分隔逻辑段落 |
| 826 | `      var allChapterList = <Map<String, String?>>[];` | 声明自动类型推断的变量 全部 章节 列表 |
| 827 | `      var pageCount = 1;` | 声明自动类型推断的变量 页 数量 |
| 828 | `      if (effectiveTocRule != null) {` | 条件判断 如果(if)：effectiveTocRule 不等于 空值(null) |
| 829 | `        final firstPageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 首个 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 830 | `          html,` | 签名/调用续行参数：网页内容 |
| 831 | `          effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 832 | `          variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 833 | `          baseUrl: tocUrl,` | 命名实参 基础链接: 目录(TOC) URL（base 统一资源链接(URL)） |
| 834 | `          getNextUrl: true,` | 命名实参 获取 下一章 URL: 真(true)（获取 下一章 统一资源链接(URL)） |
| 835 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 836 | `        final firstPageChapterList =` | 上一表达式的续行：不可重新赋值(final) 首个 页 章节 列表 = |
| 837 | `            firstPageResult['chapterList'] as List<Map<String, String?>>;` | 首个 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 838 | `        AppLog.instance.put('第 1 页解析结果: 找到 ${firstPageChapterList.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('第 1 页解析结果: 找到 ${首个 页 章节 列表.长度(length)} 个章节'… |
| 839 | `        allChapterList.addAll(firstPageChapterList);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(首个 页 章节 列表); |
| 840 | `      }` | 闭合大括号，结束当前代码块 |
| 841 | `&nbsp;` | 空行，分隔逻辑段落 |
| 842 | `      if (loadAllPages) {` | 条件判断 如果(if)：加载 全部 分页 |
| 843 | `        var currentUrl = tocUrl;` | 声明自动类型推断的变量 当前 URL |
| 844 | `        var visitedUrls = <String>{currentUrl};` | 声明自动类型推断的变量 visitedUrls |
| 845 | `        const maxPages = 100; // 防止无限循环` | 声明编译期常量变量 maxPages；行尾注释：防止无限循环 |
| 846 | `&nbsp;` | 空行，分隔逻辑段落 |
| 847 | `        while (pageCount < maxPages && effectiveTocRule != null) {` | 当型循环(while) 循环，条件：页 数量 < maxPages && effectiveTocRule != 空值(null) |
| 848 | `          String pageHtml = html;` | 字符串(String) 页 HTML = 网页内容 |
| 849 | `          if (pageCount > 1) {` | 条件判断 如果(if)：页 数量 > 1 |
| 850 | `            final pageResponse = await _networkService.get(` | 声明不可重新赋值的变量 页 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 851 | `              currentUrl,` | 签名/调用续行参数：当前 URL |
| 852 | `              headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 853 | `              retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 854 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 855 | `            pageHtml = await NetworkService.getResponseText(pageResponse);` | 将 等待异步结果：等待(await) 网络服务(NetworkService).获取 响应 文本(页 响应) 赋值给 页 HTML（调用 获取 响应 文本 → 获取 响应 文本） |
| 856 | `            if (pageHtml.isEmpty) {` | 条件判断 如果(if)：页 HTML.是否为空 |
| 857 | `              AppLog.instance.put('第 $pageCount 页内容为空，停止获取');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('第 $pageCount 页内容为空，停止获取'); |
| 858 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 859 | `            }` | 闭合大括号，结束当前代码块 |
| 860 | `          }` | 闭合大括号，结束当前代码块 |
| 861 | `&nbsp;` | 空行，分隔逻辑段落 |
| 862 | `          List<Map<String, String?>> pageChapterList;` | 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> 页 章节 列表 |
| 863 | `          if (pageCount == 1) {` | 条件判断 如果(if)：页 数量 等于 1 |
| 864 | `            pageChapterList = allChapterList;` | 将 全部 章节 列表 赋值给 页 章节 列表 |
| 865 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 866 | `            final pageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 867 | `              pageHtml,` | 签名/调用续行参数：页 HTML |
| 868 | `              effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 869 | `              variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 870 | `              baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 871 | `              getNextUrl: true,` | 命名实参 获取 下一章 URL: 真(true)（获取 下一章 统一资源链接(URL)） |
| 872 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 873 | `            pageChapterList =` | 上一表达式的续行：页 章节 列表 = |
| 874 | `                pageResult['chapterList'] as List<Map<String, String?>>;` | 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 875 | `            AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 876 | `                .put('第 $pageCount 页解析结果: 找到 ${pageChapterList.length} 个章节');` | 链式调用延续：.写入数据库(put)('第 $pageCount 页解析结果: 找到 ${pageChapterList.length} 个章节'); |
| 877 | `            allChapterList.addAll(pageChapterList);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(页 章节 列表); |
| 878 | `          }` | 闭合大括号，结束当前代码块 |
| 879 | `&nbsp;` | 空行，分隔逻辑段落 |
| 880 | `          String? nextUrl;` | 字符串(String)? 下一章 URL |
| 881 | `          if (effectiveTocRule.nextTocUrl != null &&` | 条件判断 如果(if)：effectiveTocRule.下一页目录链接 不等于 空值(null) 且 |
| 882 | `              effectiveTocRule.nextTocUrl!.isNotEmpty) {` | effectiveTocRule.下一页目录链接!.是否非空) { |
| 883 | `            AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 884 | `                .put('尝试使用nextTocUrl规则获取下一页: ${effectiveTocRule.nextTocUrl}');` | 链式调用延续：.写入数据库(put)('尝试使用nextTocUrl规则获取下一页: ${effectiveTocRule.nextTocUrl}'); |
| 885 | `&nbsp;` | 空行，分隔逻辑段落 |
| 886 | `            List<String> nextUrlList;` | 列表(List)<字符串(String)> 下一章 URL 列表 |
| 887 | `            if (effectiveTocRule.nextTocUrl!.contains('@')) {` | 条件判断 如果(if)：effectiveTocRule.下一页目录链接!.是否包含('@') |
| 888 | `              nextUrlList = RuleParser.parseListRule(` | 将 规则解析器(RuleParser).解析 列表 规则( 赋值给 下一章 URL 列表（调用 解析 列表 规则 → 解析 列表 规则） |
| 889 | `                pageHtml,` | 签名/调用续行参数：页 HTML |
| 890 | `                effectiveTocRule.nextTocUrl!,` | effectiveTocRule.下一页目录链接!, |
| 891 | `                variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 892 | `                baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 893 | `                returnHtml: false,` | 命名实参 returnHtml: 假(false)（返回(return) 网页标记文本(HTML)） |
| 894 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 895 | `            } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 896 | `              final linkHtmlList = RuleParser.parseListRule(` | 声明不可重新赋值的变量 linkHtmlList：调用 规则解析器(RuleParser).解析 列表 规则(...) → 解析 列表 规则 |
| 897 | `                pageHtml,` | 签名/调用续行参数：页 HTML |
| 898 | `                effectiveTocRule.nextTocUrl!,` | effectiveTocRule.下一页目录链接!, |
| 899 | `                variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 900 | `                baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 901 | `                returnHtml: true,` | 命名实参 returnHtml: 真(true)（返回(return) 网页标记文本(HTML)） |
| 902 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 903 | `&nbsp;` | 空行，分隔逻辑段落 |
| 904 | `              nextUrlList = [];` | 下一章 URL 列表 = [] |
| 905 | `              for (final linkHtml in linkHtmlList) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) linkHtml 属于(in) linkHtmlList |
| 906 | `                final hrefPattern = RegExp(` | 声明不可重新赋值的变量 hrefPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 907 | `                  'href\\s*=\\s*["\']([^"\']+)["\']',` | 以字符串 'href\\s*=\\s*["\']([^"\']+)["\']' 起始的表达式：, |
| 908 | `                  caseSensitive: false,` | 区分大小写开关: 假(false), |
| 909 | `                );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 910 | `                final match = hrefPattern.firstMatch(linkHtml);` | 声明不可重新赋值的变量 match：调用 hrefPattern.首个匹配(...) → 首个 Match |
| 911 | `                if (match != null) {` | 条件判断 如果(if)：match 不等于 空值(null) |
| 912 | `                  final href = match.group(1);` | 声明不可重新赋值的变量 href：调用 match.捕获组(...) → 捕获组 |
| 913 | `                  if (href != null && href.isNotEmpty) {` | 条件判断 如果(if)：href 不等于 空值(null) 且 href.是否非空 |
| 914 | `                    nextUrlList.add(href);` | 链式调用起始于 下一章 URL 列表（下一章 统一资源链接(URL) 列表），后续行继续该表达式：下一章 URL 列表.添加(href); |
| 915 | `                  }` | 闭合大括号，结束当前代码块 |
| 916 | `                }` | 闭合大括号，结束当前代码块 |
| 917 | `              }` | 闭合大括号，结束当前代码块 |
| 918 | `            }` | 闭合大括号，结束当前代码块 |
| 919 | `&nbsp;` | 空行，分隔逻辑段落 |
| 920 | `            final filteredUrls = nextUrlList` | 上一表达式的续行：不可重新赋值(final) filteredUrls = 下一章 URL 列表 |
| 921 | `                .where((url) => url.isNotEmpty && url != currentUrl)` | 链式调用延续：.筛选(where)((链接) => 链接.是否非空 && 链接 != 当前 URL) |
| 922 | `                .map((url) => NetworkService.joinUrl(currentUrl, url))` | 链式调用延续：.映射(map)((链接) => 网络服务(NetworkService).拼接 URL(当前 URL, 链接)) |
| 923 | `                .where((url) => url != currentUrl && !visitedUrls.contains(url))` | 链式调用延续：.筛选(where)((链接) => 链接 != 当前 URL && !visitedUrls.是否包含(链接)) |
| 924 | `                .toList();` | 链式调用延续：.转为列表(); |
| 925 | `&nbsp;` | 空行，分隔逻辑段落 |
| 926 | `            AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 927 | `                .put('nextTocUrl规则解析结果: 找到 ${filteredUrls.length} 个URL');` | 链式调用延续：.写入数据库(put)('nextTocUrl规则解析结果: 找到 ${filteredUrls.length} 个URL'); |
| 928 | `&nbsp;` | 空行，分隔逻辑段落 |
| 929 | `            if (filteredUrls.isNotEmpty) {` | 条件判断 如果(if)：filteredUrls.是否非空 |
| 930 | `              if (filteredUrls.length == 1) {` | 条件判断 如果(if)：filteredUrls.长度(length) 等于 1 |
| 931 | `                nextUrl = filteredUrls[0];` | 将 filteredUrls[0] 赋值给 下一章 URL |
| 932 | `              } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 933 | `                try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 934 | `                  final futures = filteredUrls.map((url) async {` | 声明不可重新赋值的变量 futures：调用 filteredUrls.映射(map)(...) → 映射 |
| 935 | `                    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 936 | `                      final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 937 | `                        url,` | 签名/调用续行参数：链接 |
| 938 | `                        headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 939 | `                        retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 940 | `                      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 941 | `                      final html =` | 上一表达式的续行：不可重新赋值(final) 网页内容 = |
| 942 | `                          await NetworkService.getResponseText(response);` | 调用 网络服务(NetworkService).获取 响应 文本(...)（等待异步完成） → 获取 响应 文本 |
| 943 | `                      return {'url': url, 'html': html, 'success': true};` | 返回 {'链接': 链接, '网页内容': 网页内容, '成功': 真(true)}（映射(Map)/集合字面量） |
| 944 | `                    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 945 | `                      return {'url': url, 'html': '', 'success': false};` | 返回 {'链接': 链接, '网页内容': '', '成功': 假(false)}（映射(Map)/集合字面量） |
| 946 | `                    }` | 闭合大括号，结束当前代码块 |
| 947 | `                  }).toList();` | 闭合代码块并衔接后续语句：).转为列表(); |
| 948 | `&nbsp;` | 空行，分隔逻辑段落 |
| 949 | `                  final results = await Future.wait(futures);` | 声明不可重新赋值的变量 结果：等待(await) 调用 异步结果(Future).wait(...) |
| 950 | `                  final allHtml = results` | 上一表达式的续行：不可重新赋值(final) 全部 HTML = 结果 |
| 951 | `                      .where((r) =>` | 链式调用延续：.筛选(where)((r) => |
| 952 | `                          r['success'] == true &&` | 上一表达式的续行：r['成功'] == 真(true) && |
| 953 | `                          (r['html'] as String).isNotEmpty)` | (r['网页内容'] 作为(as) 字符串(String)).是否非空) |
| 954 | `                      .map((r) => r['html'] as String)` | 链式调用延续：.映射(map)((r) => r['网页内容'] 作为(as) 字符串(String)) |
| 955 | `                      .join('\n');` | 链式调用延续：.拼接('\n'); |
| 956 | `&nbsp;` | 空行，分隔逻辑段落 |
| 957 | `                  if (allHtml.isNotEmpty) {` | 条件判断 如果(if)：全部 HTML.是否非空 |
| 958 | `                    pageHtml = allHtml;` | 将 全部 HTML 赋值给 页 HTML |
| 959 | `                    nextUrl = null;` | 将 空值(null) 赋值给 下一章 URL |
| 960 | `                  } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 961 | `                    nextUrl = filteredUrls[0];` | 将 filteredUrls[0] 赋值给 下一章 URL |
| 962 | `                  }` | 闭合大括号，结束当前代码块 |
| 963 | `                } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 964 | `                  nextUrl = filteredUrls[0];` | 将 filteredUrls[0] 赋值给 下一章 URL |
| 965 | `                }` | 闭合大括号，结束当前代码块 |
| 966 | `              }` | 闭合大括号，结束当前代码块 |
| 967 | `            }` | 闭合大括号，结束当前代码块 |
| 968 | `          }` | 闭合大括号，结束当前代码块 |
| 969 | `&nbsp;` | 空行，分隔逻辑段落 |
| 970 | `          if (nextUrl == null \|\| nextUrl.isEmpty) {` | 条件判断 如果(if)：下一章 URL 等于 空值(null) 或 下一章 URL.是否为空 |
| 971 | `            for (int i = 0; i < pageChapterList.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 页 章节 列表.长度(length); 循环变量 i++ |
| 972 | `              final chapterData = pageChapterList[i];` | 声明不可重新赋值的变量 chapterData |
| 973 | `              final chapterNextUrl = chapterData['nextTocUrl'];` | 声明不可重新赋值的变量 章节 下一章 URL |
| 974 | `              if (chapterNextUrl != null && chapterNextUrl.isNotEmpty) {` | 条件判断 如果(if)：章节 下一章 URL 不等于 空值(null) 且 章节 下一章 URL.是否非空 |
| 975 | `                nextUrl = NetworkService.joinUrl(currentUrl, chapterNextUrl);` | 将 网络服务(NetworkService).拼接 URL(当前 URL, 章节 下一章 URL) 赋值给 下一章 URL（调用 拼接 URL → 拼接 统一资源链接(URL)） |
| 976 | `                break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 977 | `              }` | 闭合大括号，结束当前代码块 |
| 978 | `            }` | 闭合大括号，结束当前代码块 |
| 979 | `          }` | 闭合大括号，结束当前代码块 |
| 980 | `&nbsp;` | 空行，分隔逻辑段落 |
| 981 | `          if (nextUrl == null \|\| nextUrl.isEmpty) {` | 条件判断 如果(if)：下一章 URL 等于 空值(null) 或 下一章 URL.是否为空 |
| 982 | `            try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 983 | `              final nextPagePattern = RegExp(` | 声明不可重新赋值的变量 下一章 页 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 984 | `                '<a[^>]*href=["\']([^"\']+)["\'][^>]*>.*?(?:下一页\|下页\|next\|Next\|NEXT)[^<]*</a>',` | 以字符串 '<a[^>]*href=["\']([^"\']+)["\'][^>]*>.*… 起始的表达式：, |
| 985 | `                caseSensitive: false,` | 区分大小写开关: 假(false), |
| 986 | `                dotAll: true,` | 命名实参 点号 全部: 真(true)（点号 全部） |
| 987 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 988 | `              final match = nextPagePattern.firstMatch(pageHtml);` | 声明不可重新赋值的变量 match：调用 下一章 页 模式.首个匹配(...) → 首个 Match |
| 989 | `              if (match != null) {` | 条件判断 如果(if)：match 不等于 空值(null) |
| 990 | `                final href = match.group(1);` | 声明不可重新赋值的变量 href：调用 match.捕获组(...) → 捕获组 |
| 991 | `                if (href != null && href.isNotEmpty) {` | 条件判断 如果(if)：href 不等于 空值(null) 且 href.是否非空 |
| 992 | `                  nextUrl = NetworkService.joinUrl(currentUrl, href);` | 将 网络服务(NetworkService).拼接 URL(当前 URL, href) 赋值给 下一章 URL（调用 拼接 URL → 拼接 统一资源链接(URL)） |
| 993 | `                }` | 闭合大括号，结束当前代码块 |
| 994 | `              }` | 闭合大括号，结束当前代码块 |
| 995 | `            } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 996 | `              AppLog.instance.put('自动查找"下一页"链接失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('自动查找"下一页"链接失败', error: e); |
| 997 | `            }` | 闭合大括号，结束当前代码块 |
| 998 | `          }` | 闭合大括号，结束当前代码块 |
| 999 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1000 | `          if (nextUrl == null \|\|` | 条件判断 如果(if)：下一章 URL 等于 空值(null) 或 |
| 1001 | `              nextUrl.isEmpty \|\|` | 上一表达式的续行：下一章 URL.是否为空 \|\| |
| 1002 | `              visitedUrls.contains(nextUrl)) {` | 链式调用起始于 visitedUrls，后续行继续该表达式：visitedUrls.是否包含(下一章 URL)) { |
| 1003 | `            break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1004 | `          }` | 闭合大括号，结束当前代码块 |
| 1005 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1006 | `          visitedUrls.add(nextUrl);` | 链式调用起始于 visitedUrls，后续行继续该表达式：visitedUrls.添加(下一章 URL); |
| 1007 | `          currentUrl = nextUrl;` | 将 下一章 URL 赋值给 当前 URL |
| 1008 | `          pageCount++;` | 页 数量++ |
| 1009 | `          AppLog.instance.put('找到下一页URL: $nextUrl，继续获取第 $pageCount 页');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到下一页URL: $nextUrl，继续获取第 $pageCount 页'); |
| 1010 | `        }` | 闭合大括号，结束当前代码块 |
| 1011 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1012 | `        if (pageCount == 1 && effectiveTocRule != null) {` | 条件判断 如果(if)：页 数量 等于 1 且 effectiveTocRule 不等于 空值(null) |
| 1013 | `          final ajaxChapters = await _loadAjaxTocPages(` | 声明不可重新赋值的变量 ajaxChapters：等待(await) 调用 _loadAjaxTocPages(...) → 加载 Ajax 目录(目录(TOC)) 分页 |
| 1014 | `            tocUrl: tocUrl,` | 命名实参 目录(TOC) URL: 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 1015 | `            firstPageHtml: html,` | 命名实参 首个 页 HTML: 网页内容（首个 页 网页标记文本(HTML)） |
| 1016 | `            source: source,` | 命名实参 书源: 书源（书源） |
| 1017 | `            seedChapters: allChapterList,` | 命名实参 seedChapters: 全部 章节 列表（seed 章节列表） |
| 1018 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1019 | `          if (ajaxChapters.isNotEmpty) {` | 条件判断 如果(if)：ajaxChapters.是否非空 |
| 1020 | `            allChapterList.addAll(ajaxChapters);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(ajaxChapters); |
| 1021 | `          }` | 闭合大括号，结束当前代码块 |
| 1022 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1023 | `          final implicitChapters = await _loadImplicitTocPages(` | 声明不可重新赋值的变量 implicitChapters：等待(await) 调用 _loadImplicitTocPages(...) → 加载 Implicit 目录(目录(TOC)) 分页 |
| 1024 | `            tocUrl: tocUrl,` | 命名实参 目录(TOC) URL: 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 1025 | `            source: source,` | 命名实参 书源: 书源（书源） |
| 1026 | `            tocRule: effectiveTocRule,` | 命名实参 目录(TOC) 规则: effectiveTocRule（目录(目录(TOC)) 规则） |
| 1027 | `            seedChapters: allChapterList,` | 命名实参 seedChapters: 全部 章节 列表（seed 章节列表） |
| 1028 | `            variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1029 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1030 | `          if (implicitChapters.isNotEmpty) {` | 条件判断 如果(if)：implicitChapters.是否非空 |
| 1031 | `            allChapterList.addAll(implicitChapters);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(implicitChapters); |
| 1032 | `          }` | 闭合大括号，结束当前代码块 |
| 1033 | `        }` | 闭合大括号，结束当前代码块 |
| 1034 | `      }` | 闭合大括号，结束当前代码块 |
| 1035 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1036 | `      AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1037 | `          .put('目录获取完成: 共 $pageCount 页，总计 ${allChapterList.length} 个章节');` | 链式调用延续：.写入数据库(put)('目录获取完成: 共 $pageCount 页，总计 ${allChapterList.length} 个章节'); |
| 1038 | `      var chapterList = allChapterList;` | 声明自动类型推断的变量 章节 列表 |
| 1039 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1040 | `      // 如果仍然没有章节，尝试其他降级规则（保留原有逻辑作为最后手段）` | 注释说明：如果仍然没有章节，尝试其他降级规则（保留原有逻辑作为最后手段） |
| 1041 | `      if (chapterList.isEmpty && source.ruleToc?.chapterList != null) {` | 条件判断 如果(if)：章节 列表.是否为空 且 书源.目录规则?.章节 列表 不等于 空值(null) |
| 1042 | `        AppLog.instance.put('原始规则未匹配到章节，尝试智能降级处理');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('原始规则未匹配到章节，尝试智能降级处理'); |
| 1043 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1044 | `        // 尝试查找包含章节链接的容器` | 注释说明：尝试查找包含章节链接的容器 |
| 1045 | `        // 使用普通字符串而不是原始字符串，以便正确处理字符类中的引号` | 注释说明：使用普通字符串而不是原始字符串，以便正确处理字符类中的引号 |
| 1046 | `        final chapterLinkPattern = RegExp(` | 声明不可重新赋值的变量 chapterLinkPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 1047 | `            '<a[^>]*href=["\']/[^"\']*\\.html["\'][^>]*>.*?</a>',` | 以字符串 '<a[^>]*href=["\']/[^"\']*\\.网页内容["\'][^… 起始的表达式：, |
| 1048 | `            caseSensitive: false,` | 区分大小写开关: 假(false), |
| 1049 | `            dotAll: true);` | 命名实参 点号 全部: 真(true));（点号 全部） |
| 1050 | `        final chapterLinkMatches = chapterLinkPattern.allMatches(html).toList();` | 声明不可重新赋值的变量 chapterLinkMatches：调用 chapterLinkPattern.allMatches(...) → 全部 Matches |
| 1051 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1052 | `        if (chapterLinkMatches.isNotEmpty) {` | 条件判断 如果(if)：chapterLinkMatches.是否非空 |
| 1053 | `          AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1054 | `              .put('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器');` | 链式调用延续：.写入数据库(put)('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器'); |
| 1055 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1056 | `          // 查找真正的目录开始位置（跳过前几个可能是最新章节的链接）` | 注释说明：查找真正的目录开始位置（跳过前几个可能是最新章节的链接） |
| 1057 | `          // 从第7个链接开始查找，这些应该是真正的目录章节` | 注释说明：从第7个链接开始查找，这些应该是真正的目录章节 |
| 1058 | `          html_dom.Element? directoryContainer;` | html_dom.Element? directoryContainer |
| 1059 | `          String? containerClass;` | 字符串(String)? containerClass |
| 1060 | `          String? containerId;` | 字符串(String)? containerId |
| 1061 | `          String? containerTag;` | 字符串(String)? containerTag |
| 1062 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1063 | `          // 首先尝试查找directoryArea容器` | 注释说明：首先尝试查找directoryArea容器 |
| 1064 | `          final doc = html_parser.parse(html);` | 声明不可重新赋值的变量 文档：调用 HTML 解析器.parse(...) → 解析 |
| 1065 | `          final directoryPattern = RegExp(` | 声明不可重新赋值的变量 目录(directory) 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 1066 | `              'class\\s*=\\s*["\'][^"\']*directory[^"\']*["\']',` | 以字符串 '类(class)\\s*=\\s*["\'][^"\']*目录(directory)[^"\… 起始的表达式：, |
| 1067 | `              caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1068 | `          final directoryMatches = directoryPattern.allMatches(html);` | 声明不可重新赋值的变量 directoryMatches：调用 目录(directory) 模式.allMatches(...) → 全部 Matches |
| 1069 | `          if (directoryMatches.isNotEmpty) {` | 条件判断 如果(if)：directoryMatches.是否非空 |
| 1070 | `            final match = directoryMatches.first;` | 声明不可重新赋值的变量 match |
| 1071 | `            final matchHtml = html.substring(match.start, match.end);` | 声明不可重新赋值的变量 matchHtml |
| 1072 | `            final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 1073 | `                caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1074 | `            final classMatch = classPattern.firstMatch(matchHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 1075 | `            if (classMatch != null) {` | 条件判断 如果(if)：classMatch 不等于 空值(null) |
| 1076 | `              final allClasses =` | 上一表达式的续行：不可重新赋值(final) allClasses = |
| 1077 | `                  classMatch.group(1)?.split(RegExp(r'\s+')) ?? [];` | 链式调用起始于 classMatch，后续行继续该表达式：classMatch.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')) ?? []; |
| 1078 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 1079 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 1080 | `                orElse: () => '',` | 命名实参 orElse: () => ''（or Else） |
| 1081 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1082 | `              if (dirClass.isNotEmpty) {` | 条件判断 如果(if)：dirClass.是否非空 |
| 1083 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 1084 | `                    HtmlParser.selectElement(doc, 'div.$dirClass');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div.$dirClass'); |
| 1085 | `                containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 1086 | `                containerTag = 'div';` | containerTag = 'div' |
| 1087 | `                AppLog.instance.put('找到directory容器: class=$containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到directory容器: class=$containerClass'); |
| 1088 | `              }` | 闭合大括号，结束当前代码块 |
| 1089 | `            }` | 闭合大括号，结束当前代码块 |
| 1090 | `          }` | 闭合大括号，结束当前代码块 |
| 1091 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1092 | `          // 如果没有找到directory容器，从第7个链接开始查找容器` | 注释说明：如果没有找到目录(directory)容器，从第7个链接开始查找容器 |
| 1093 | `          if (directoryContainer == null && chapterLinkMatches.length >= 7) {` | 条件判断 如果(if)：directoryContainer 等于 空值(null) 且 chapterLinkMatches.长度(length) > = 7 |
| 1094 | `            // 从第7个链接开始查找容器` | 注释说明：从第7个链接开始查找容器 |
| 1095 | `            final chapterStartMatch = chapterLinkMatches[6]; // 第7个链接（索引6）` | 声明不可重新赋值的变量 chapterStartMatch；行尾注释：第7个链接（索引6） |
| 1096 | `            final beforeHtml = html.substring(0, chapterStartMatch.start);` | 声明不可重新赋值的变量 beforeHtml |
| 1097 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1098 | `            // 查找最近的容器开始标签（div, ul, ol, dl, section等）` | 注释说明：查找最近的容器开始标签（div, ul, ol, dl, 节等） |
| 1099 | `            final containerStartPattern =` | 上一表达式的续行：不可重新赋值(final) containerStartPattern = |
| 1100 | `                RegExp(r'<(div\|ul\|ol\|dl\|section)[^>]*>', caseSensitive: false);` | 构造函数 正则表达式(RegExp)位置参数 2 个；参数名: 节, 区分大小写开关, 假(false) |
| 1101 | `            final containerStarts =` | 上一表达式的续行：不可重新赋值(final) containerStarts = |
| 1102 | `                containerStartPattern.allMatches(beforeHtml).toList();` | 链式调用起始于 containerStartPattern（container 起始 模式），后续行继续该表达式：containerStartPattern.allMatches(beforeHtml).转为列表(); |
| 1103 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1104 | `            if (containerStarts.isNotEmpty) {` | 条件判断 如果(if)：containerStarts.是否非空 |
| 1105 | `              final lastContainerStart = containerStarts.last;` | 声明不可重新赋值的变量 lastContainerStart |
| 1106 | `              containerTag = lastContainerStart.group(1);` | 将 lastContainerStart.捕获组(1) 赋值给 containerTag（调用 捕获组 → 捕获组） |
| 1107 | `              final containerStartPos = lastContainerStart.start;` | 声明不可重新赋值的变量 containerStartPos |
| 1108 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1109 | `              // 提取容器的class或id属性` | 注释说明：提取容器的类(class)或编号(id)属性 |
| 1110 | `              final containerHtml =` | 上一表达式的续行：不可重新赋值(final) containerHtml = |
| 1111 | `                  html.substring(containerStartPos, lastContainerStart.end);` | 链式调用起始于 网页内容（网页标记文本(HTML)），后续行继续该表达式：网页内容.substring(containerStartPos, lastContainerStart.end); |
| 1112 | `              final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 1113 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1114 | `              final idPattern = RegExp('id\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 编号(id) 模式，默认值 正则表达式(RegExp)('编号(id)\\s*=\\s*["\']([^"\']+)["\']'（编号(编号(id)) 模式） |
| 1115 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1116 | `              final classMatch = classPattern.firstMatch(containerHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 1117 | `              final idMatch = idPattern.firstMatch(containerHtml);` | 声明不可重新赋值的变量 idMatch：调用 编号(id) 模式.首个匹配(...) → 首个 Match |
| 1118 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1119 | `              containerClass =` | 上一表达式的续行：containerClass = |
| 1120 | `                  classMatch?.group(1)?.split(RegExp(r'\s+')).first;` | 调用 捕获组/切分/正则表达式(RegExp)(...)：classMatch?.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')).first（捕获组 切分 Reg 表达式） |
| 1121 | `              containerId = idMatch?.group(1);` | 将 idMatch?.捕获组(1) 赋值给 containerId（调用 捕获组 → 捕获组） |
| 1122 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1123 | `              // 如果容器class包含directory，尝试查找该容器` | 注释说明：如果容器类(class)包含目录(directory)，尝试查找该容器 |
| 1124 | `              if (containerClass != null &&` | 条件判断 如果(if)：containerClass 不等于 空值(null) 且 |
| 1125 | `                  containerClass.contains('directory')) {` | 链式调用起始于 containerClass，后续行继续该表达式：containerClass.是否包含('目录(directory)')) { |
| 1126 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 1127 | `                    HtmlParser.selectElement(doc, 'div.$containerClass');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div.$containerClass'); |
| 1128 | `                AppLog.instance.put('找到directory容器: class=$containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到directory容器: class=$containerClass'); |
| 1129 | `              } else if (containerId != null) {` | 闭合上一代码块并开始 否则(else) 如果(if) (containerId != 空值(null)) { |
| 1130 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 1131 | `                    HtmlParser.selectElement(doc, 'div#$containerId');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div#$containerId'); |
| 1132 | `                AppLog.instance.put('找到容器: id=$containerId');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到容器: id=$containerId'); |
| 1133 | `              }` | 闭合大括号，结束当前代码块 |
| 1134 | `            }` | 闭合大括号，结束当前代码块 |
| 1135 | `          }` | 闭合大括号，结束当前代码块 |
| 1136 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1137 | `          // 如果找到了directory容器，提取其class或id用于生成降级规则` | 注释说明：如果找到了目录(directory)容器，提取其类(class)或编号(id)用于生成降级规则 |
| 1138 | `          if (directoryContainer != null) {` | 条件判断 如果(if)：directoryContainer 不等于 空值(null) |
| 1139 | `            final dirClassAttr = directoryContainer.attributes['class'];` | 声明不可重新赋值的变量 dirClassAttr |
| 1140 | `            final dirIdAttr = directoryContainer.attributes['id'];` | 声明不可重新赋值的变量 dirIdAttr |
| 1141 | `            if (dirClassAttr != null && dirClassAttr.contains('directory')) {` | 条件判断 如果(if)：dirClassAttr 不等于 空值(null) 且 dirClassAttr.是否包含('目录(directory)') |
| 1142 | `              final allClasses = dirClassAttr.split(RegExp(r'\s+'));` | 声明不可重新赋值的变量 allClasses：调用 dirClassAttr.切分(...) → 切分 |
| 1143 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 1144 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 1145 | `                orElse: () => allClasses.first,` | 命名实参 orElse: () => allClasses.first（or Else） |
| 1146 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1147 | `              containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 1148 | `              containerTag = 'div';` | containerTag = 'div' |
| 1149 | `              AppLog.instance.put('从directory容器提取class: $containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取class: $containerClass'); |
| 1150 | `            }` | 闭合大括号，结束当前代码块 |
| 1151 | `            if (dirIdAttr != null) {` | 条件判断 如果(if)：dirIdAttr 不等于 空值(null) |
| 1152 | `              containerId = dirIdAttr;` | 将 dirIdAttr 赋值给 containerId |
| 1153 | `              AppLog.instance.put('从directory容器提取id: $containerId');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取id: $containerId'); |
| 1154 | `            }` | 闭合大括号，结束当前代码块 |
| 1155 | `          }` | 闭合大括号，结束当前代码块 |
| 1156 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1157 | `          // 如果还没有找到容器，使用第一个章节链接的容器` | 注释说明：如果还没有找到容器，使用第一个章节链接的容器 |
| 1158 | `          if (containerClass == null && containerId == null) {` | 条件判断 如果(if)：containerClass 等于 空值(null) 且 containerId 等于 空值(null) |
| 1159 | `            final firstChapterLink = chapterLinkMatches.first;` | 声明不可重新赋值的变量 firstChapterLink |
| 1160 | `            final beforeHtml = html.substring(0, firstChapterLink.start);` | 声明不可重新赋值的变量 beforeHtml |
| 1161 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1162 | `            // 查找最近的容器开始标签（div, ul, ol, dl, section等）` | 注释说明：查找最近的容器开始标签（div, ul, ol, dl, 节等） |
| 1163 | `            final containerStartPattern =` | 上一表达式的续行：不可重新赋值(final) containerStartPattern = |
| 1164 | `                RegExp(r'<(div\|ul\|ol\|dl\|section)[^>]*>', caseSensitive: false);` | 构造函数 正则表达式(RegExp)位置参数 2 个；参数名: 节, 区分大小写开关, 假(false) |
| 1165 | `            final containerStarts =` | 上一表达式的续行：不可重新赋值(final) containerStarts = |
| 1166 | `                containerStartPattern.allMatches(beforeHtml).toList();` | 链式调用起始于 containerStartPattern（container 起始 模式），后续行继续该表达式：containerStartPattern.allMatches(beforeHtml).转为列表(); |
| 1167 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1168 | `            if (containerStarts.isNotEmpty) {` | 条件判断 如果(if)：containerStarts.是否非空 |
| 1169 | `              final lastContainerStart = containerStarts.last;` | 声明不可重新赋值的变量 lastContainerStart |
| 1170 | `              containerTag = lastContainerStart.group(1);` | 将 lastContainerStart.捕获组(1) 赋值给 containerTag（调用 捕获组 → 捕获组） |
| 1171 | `              final containerStartPos = lastContainerStart.start;` | 声明不可重新赋值的变量 containerStartPos |
| 1172 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1173 | `              // 提取容器的class或id属性` | 注释说明：提取容器的类(class)或编号(id)属性 |
| 1174 | `              final containerHtml =` | 上一表达式的续行：不可重新赋值(final) containerHtml = |
| 1175 | `                  html.substring(containerStartPos, lastContainerStart.end);` | 链式调用起始于 网页内容（网页标记文本(HTML)），后续行继续该表达式：网页内容.substring(containerStartPos, lastContainerStart.end); |
| 1176 | `              final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 1177 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1178 | `              final idPattern = RegExp('id\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 编号(id) 模式，默认值 正则表达式(RegExp)('编号(id)\\s*=\\s*["\']([^"\']+)["\']'（编号(编号(id)) 模式） |
| 1179 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1180 | `              final classMatch = classPattern.firstMatch(containerHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 1181 | `              final idMatch = idPattern.firstMatch(containerHtml);` | 声明不可重新赋值的变量 idMatch：调用 编号(id) 模式.首个匹配(...) → 首个 Match |
| 1182 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1183 | `              containerClass =` | 上一表达式的续行：containerClass = |
| 1184 | `                  classMatch?.group(1)?.split(RegExp(r'\s+')).first;` | 调用 捕获组/切分/正则表达式(RegExp)(...)：classMatch?.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')).first（捕获组 切分 Reg 表达式） |
| 1185 | `              containerId = idMatch?.group(1);` | 将 idMatch?.捕获组(1) 赋值给 containerId（调用 捕获组 → 捕获组） |
| 1186 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1187 | `              AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1188 | `                  '找到容器: <$containerTag>${containerClass != null ? ' class="$containerClass"' : ''}${containerId != null ? ' id="$containerId"' : ''}');` | 以字符串 '找到容器: <$containerTag>${containerClass !… 起始的表达式：类(class)="$containerClass"' : ''}${containerId != 空值(null) ? ' 编号(id)="… |
| 1189 | `            }` | 闭合大括号，结束当前代码块 |
| 1190 | `          }` | 闭合大括号，结束当前代码块 |
| 1191 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1192 | `          // 使用找到的容器信息生成降级规则` | 注释说明：使用找到的容器信息生成降级规则 |
| 1193 | `          String? finalContainerClass = containerClass;` | 字符串(String)? finalContainerClass = containerClass |
| 1194 | `          String? finalContainerId = containerId;` | 字符串(String)? finalContainerId = containerId |
| 1195 | `          String? finalContainerTag = containerTag;` | 字符串(String)? finalContainerTag = containerTag |
| 1196 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1197 | `          if (directoryContainer == null) {` | 条件判断 如果(if)：directoryContainer 等于 空值(null) |
| 1198 | `            // 如果没有找到directory容器，尝试从第一个章节链接查找容器` | 注释说明：如果没有找到目录(directory)容器，尝试从第一个章节链接查找容器 |
| 1199 | `            final firstChapterLink = chapterLinkMatches.first;` | 声明不可重新赋值的变量 firstChapterLink |
| 1200 | `            final beforeHtml = html.substring(0, firstChapterLink.start);` | 声明不可重新赋值的变量 beforeHtml |
| 1201 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1202 | `            // 查找最近的容器开始标签（div, ul, ol, dl, section等）` | 注释说明：查找最近的容器开始标签（div, ul, ol, dl, 节等） |
| 1203 | `            final containerStartPattern =` | 上一表达式的续行：不可重新赋值(final) containerStartPattern = |
| 1204 | `                RegExp(r'<(div\|ul\|ol\|dl\|section)[^>]*>', caseSensitive: false);` | 构造函数 正则表达式(RegExp)位置参数 2 个；参数名: 节, 区分大小写开关, 假(false) |
| 1205 | `            final containerStarts =` | 上一表达式的续行：不可重新赋值(final) containerStarts = |
| 1206 | `                containerStartPattern.allMatches(beforeHtml).toList();` | 链式调用起始于 containerStartPattern（container 起始 模式），后续行继续该表达式：containerStartPattern.allMatches(beforeHtml).转为列表(); |
| 1207 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1208 | `            if (containerStarts.isNotEmpty) {` | 条件判断 如果(if)：containerStarts.是否非空 |
| 1209 | `              final lastContainerStart = containerStarts.last;` | 声明不可重新赋值的变量 lastContainerStart |
| 1210 | `              finalContainerTag = lastContainerStart.group(1);` | 将 lastContainerStart.捕获组(1) 赋值给 finalContainerTag（调用 捕获组 → 捕获组） |
| 1211 | `              final containerStartPos = lastContainerStart.start;` | 声明不可重新赋值的变量 containerStartPos |
| 1212 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1213 | `              // 提取容器的class或id属性` | 注释说明：提取容器的类(class)或编号(id)属性 |
| 1214 | `              final containerHtml =` | 上一表达式的续行：不可重新赋值(final) containerHtml = |
| 1215 | `                  html.substring(containerStartPos, lastContainerStart.end);` | 链式调用起始于 网页内容（网页标记文本(HTML)），后续行继续该表达式：网页内容.substring(containerStartPos, lastContainerStart.end); |
| 1216 | `              // 使用普通字符串而不是原始字符串，以便正确处理字符类中的引号` | 注释说明：使用普通字符串而不是原始字符串，以便正确处理字符类中的引号 |
| 1217 | `              final classPattern2 = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern2，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) Pattern2） |
| 1218 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1219 | `              final idPattern2 = RegExp('id\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 idPattern2，默认值 正则表达式(RegExp)('编号(id)\\s*=\\s*["\']([^"\']+)["\']'（编号(编号(id)) Pattern2） |
| 1220 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1221 | `              final classMatch2 = classPattern2.firstMatch(containerHtml);` | 声明不可重新赋值的变量 classMatch2：调用 classPattern2.首个匹配(...) → 首个 Match |
| 1222 | `              final idMatch2 = idPattern2.firstMatch(containerHtml);` | 声明不可重新赋值的变量 idMatch2：调用 idPattern2.首个匹配(...) → 首个 Match |
| 1223 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1224 | `              finalContainerClass =` | 上一表达式的续行：finalContainerClass = |
| 1225 | `                  classMatch2?.group(1)?.split(RegExp(r'\s+')).first;` | 调用 捕获组/切分/正则表达式(RegExp)(...)：classMatch2?.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')).first（捕获组 切分 Reg 表达式） |
| 1226 | `              finalContainerId = idMatch2?.group(1);` | 将 idMatch2?.捕获组(1) 赋值给 finalContainerId（调用 捕获组 → 捕获组） |
| 1227 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1228 | `              AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1229 | `                  '找到容器: <$finalContainerTag>${finalContainerClass != null ? ' class="$finalContainerClass"' : ''}${finalContainerId != null ? ' id="$finalContainerId"' : ''}');` | 以字符串 '找到容器: <$finalContainerTag>${finalContai… 起始的表达式：类(class)="$finalContainerClass"' : ''}${finalContainerId != nul… |
| 1230 | `            }` | 闭合大括号，结束当前代码块 |
| 1231 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1232 | `            // 如果找到了directory容器，使用它的信息` | 注释说明：如果找到了目录(directory)容器，使用它的信息 |
| 1233 | `            finalContainerTag = 'div';` | finalContainerTag = 'div' |
| 1234 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1235 | `                '使用directory容器: class=$finalContainerClass, id=$finalContainerId');` | 以字符串 '使用目录(directory)容器: 类(class)=$finalContainerCla… 起始的表达式：); |
| 1236 | `          }` | 闭合大括号，结束当前代码块 |
| 1237 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1238 | `          // 生成降级规则并尝试` | 注释说明：生成降级规则并尝试 |
| 1239 | `          if (finalContainerClass != null \|\|` | 条件判断 如果(if)：finalContainerClass 不等于 空值(null) 或 |
| 1240 | `              finalContainerId != null \|\|` | 上一表达式的续行：finalContainerId != 空值(null) \|\| |
| 1241 | `              finalContainerTag != null) {` | finalContainerTag != 空值(null)) { |
| 1242 | `            final fallbackRules = <String>[];` | 声明不可重新赋值的变量 fallbackRules |
| 1243 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1244 | `            if (finalContainerId != null) {` | 条件判断 如果(if)：finalContainerId 不等于 空值(null) |
| 1245 | `              // 如果容器有id，尝试使用id选择器` | 注释说明：如果容器有编号(id)，尝试使用编号(id)选择器 |
| 1246 | `              fallbackRules.add('id.$finalContainerId@tag.a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('编号(id).$finalContainerId@tag.a'); |
| 1247 | `              fallbackRules.add('id.$finalContainerId@tag.p');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('编号(id).$finalContainerId@tag.p'); |
| 1248 | `              fallbackRules.add('id.$finalContainerId@tag.li');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('编号(id).$finalContainerId@tag.li'); |
| 1249 | `              fallbackRules.add('id.$finalContainerId@tag.dd');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('编号(id).$finalContainerId@tag.dd'); |
| 1250 | `            }` | 闭合大括号，结束当前代码块 |
| 1251 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1252 | `            if (finalContainerClass != null) {` | 条件判断 如果(if)：finalContainerClass 不等于 空值(null) |
| 1253 | `              // 如果容器有class，尝试使用class选择器` | 注释说明：如果容器有类(class)，尝试使用类(class)选择器 |
| 1254 | `              fallbackRules.add('class.$finalContainerClass@tag.a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('类(class).$finalContainerClass@tag.a'); |
| 1255 | `              fallbackRules.add('class.$finalContainerClass@tag.p');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('类(class).$finalContainerClass@tag.p'); |
| 1256 | `              fallbackRules.add('class.$finalContainerClass@tag.li');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('类(class).$finalContainerClass@tag.li'); |
| 1257 | `              fallbackRules.add('class.$finalContainerClass@tag.dd');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('类(class).$finalContainerClass@tag.dd'); |
| 1258 | `            }` | 闭合大括号，结束当前代码块 |
| 1259 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1260 | `            // 尝试直接选择容器内的链接（使用CSS选择器格式）` | 注释说明：尝试直接选择容器内的链接（使用CSS选择器格式） |
| 1261 | `            if (finalContainerTag != null) {` | 条件判断 如果(if)：finalContainerTag 不等于 空值(null) |
| 1262 | `              if (finalContainerClass != null) {` | 条件判断 如果(if)：finalContainerClass 不等于 空值(null) |
| 1263 | `                fallbackRules.add('$finalContainerTag.$finalContainerClass a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('$finalContainerTag.$finalContainerClass a'); |
| 1264 | `              }` | 闭合大括号，结束当前代码块 |
| 1265 | `              if (finalContainerId != null) {` | 条件判断 如果(if)：finalContainerId 不等于 空值(null) |
| 1266 | `                fallbackRules.add('$finalContainerTag#$finalContainerId a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('$finalContainerTag#$finalContainerId a'); |
| 1267 | `              }` | 闭合大括号，结束当前代码块 |
| 1268 | `              fallbackRules.add('$finalContainerTag a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('$finalContainerTag a'); |
| 1269 | `            }` | 闭合大括号，结束当前代码块 |
| 1270 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1271 | `            // 尝试每个降级规则` | 注释说明：尝试每个降级规则 |
| 1272 | `            for (final fallbackRule in fallbackRules) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 回退/降级 规则 属于(in) fallbackRules |
| 1273 | `              AppLog.instance.put('尝试降级规则: $fallbackRule');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('尝试降级规则: $fallbackRule'); |
| 1274 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1275 | `              // 创建临时规则对象` | 注释说明：创建临时规则对象 |
| 1276 | `              final fallbackTocRule = TocRule(` | 声明不可重新赋值的变量 回退/降级 目录(TOC) 规则：调用 目录(TOC) 规则(...) → 目录(目录(TOC)) 规则 |
| 1277 | `                chapterList: fallbackRule,` | 命名实参 章节 列表: 回退/降级 规则（章节 列表） |
| 1278 | `                chapterName: source.ruleToc?.chapterName ?? 'tag.a@text',` | 命名实参 章节 名称: 书源.目录规则?.章节 名称 ?? 'tag.a@文本'（章节 名称） |
| 1279 | `                chapterUrl: source.ruleToc?.chapterUrl ?? 'tag.a@href',` | 命名实参 章节链接: 书源.目录规则?.章节链接 ?? 'tag.a@href'（章节 统一资源链接(URL)） |
| 1280 | `                isVip: source.ruleToc?.isVip,` | 命名实参 isVip: 书源.目录规则?.isVip（是(is) Vip） |
| 1281 | `                updateTime: source.ruleToc?.updateTime,` | 命名实参 updateTime: 书源.目录规则?.updateTime（更新 Time） |
| 1282 | `                nextTocUrl: source.ruleToc?.nextTocUrl,` | 命名实参 下一页目录链接: 书源.目录规则?.下一页目录链接（下一章 目录(目录(TOC)) 统一资源链接(URL)） |
| 1283 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1284 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1285 | `              final fallbackChapterList = RuleParser.parseTocRule(` | 声明不可重新赋值的变量 回退/降级 章节 列表：调用 规则解析器(RuleParser).解析 目录(TOC) 规则(...) → 解析 目录(目录(TOC)) 规则 |
| 1286 | `                html,` | 签名/调用续行参数：网页内容 |
| 1287 | `                fallbackTocRule,` | 签名/调用续行参数：回退/降级 目录(TOC) 规则 |
| 1288 | `                baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 1289 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1290 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1291 | `              AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1292 | `                  '降级规则 $fallbackRule 匹配结果: ${fallbackChapterList.length} 个章节');` | 以字符串 '降级规则 $回退/降级 规则 匹配结果: ${fallbackChap… 起始的表达式：); |
| 1293 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1294 | `              // 如果匹配到的章节数量大于当前结果，使用这个规则` | 注释说明：如果匹配到的章节数量大于当前结果，使用这个规则 |
| 1295 | `              // 这样可以确保选择匹配到最多章节的规则` | 注释说明：这样可以确保选择匹配到最多章节的规则 |
| 1296 | `              if (fallbackChapterList.length > chapterList.length) {` | 条件判断 如果(if)：回退/降级 章节 列表.长度(length) > 章节 列表.长度(length) |
| 1297 | `                AppLog.instance.put('降级规则 $fallbackRule 匹配到更多章节，使用此规则');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('降级规则 $fallbackRule 匹配到更多章节，使用此规则'); |
| 1298 | `                chapterList = fallbackChapterList;` | 将 回退/降级 章节 列表 赋值给 章节 列表 |
| 1299 | `                // 如果匹配到的章节数量足够多（比如超过10个），可以认为这是正确的规则` | 注释说明：如果匹配到的章节数量足够多（比如超过10个），可以认为这是正确的规则 |
| 1300 | `                if (fallbackChapterList.length >= 10) {` | 条件判断 如果(if)：回退/降级 章节 列表.长度(length) > = 10 |
| 1301 | `                  AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1302 | `                      '降级规则 $fallbackRule 匹配到足够多的章节（${fallbackChapterList.length}个），停止尝试其他规则');` | 以字符串 '降级规则 $回退/降级 规则 匹配到足够多的章节（${回退… 起始的表达式：); |
| 1303 | `                  break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1304 | `                }` | 闭合大括号，结束当前代码块 |
| 1305 | `              }` | 闭合大括号，结束当前代码块 |
| 1306 | `            }` | 闭合大括号，结束当前代码块 |
| 1307 | `          }` | 闭合大括号，结束当前代码块 |
| 1308 | `        }` | 闭合大括号，结束当前代码块 |
| 1309 | `      }` | 闭合大括号，结束当前代码块 |
| 1310 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1311 | `      if (chapterList.isEmpty && source.ruleToc?.chapterList != null) {` | 条件判断 如果(if)：章节 列表.是否为空 且 书源.目录规则?.章节 列表 不等于 空值(null) |
| 1312 | `        AppLog.instance.put('警告: 章节列表为空，但规则不为空。可能是规则不匹配HTML结构。');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('警告: 章节列表为空，但规则不为空。可能是规则不匹配HTML结构。'); |
| 1313 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1314 | `            'HTML前2000字符: ${html.substring(0, html.length > 2000 ? 2000 : html.length)}');` | 以字符串 '网页标记文本(HTML)前2000字符: ${网页内容.substring(0, html.l… 起始的表达式：); |
| 1315 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1316 | `        // 尝试查找可能的目录相关元素（用于调试）` | 注释说明：尝试查找可能的目录相关元素（用于调试） |
| 1317 | `        final dlPattern =` | 上一表达式的续行：不可重新赋值(final) dlPattern = |
| 1318 | `            RegExp('<dl[^>]*>.*?</dl>', caseSensitive: false, dotAll: true);` | 构造函数 正则表达式(RegExp)位置参数 3 个；参数名: 区分大小写开关, 假(false), 点号 全部, 真(true) |
| 1319 | `        final dlMatches = dlPattern.allMatches(html);` | 声明不可重新赋值的变量 dlMatches：调用 dlPattern.allMatches(...) → 全部 Matches |
| 1320 | `        AppLog.instance.put('HTML中找到 ${dlMatches.length} 个 <dl> 标签');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('HTML中找到 ${dlMatches.length} 个 <dl> 标签'); |
| 1321 | `        if (dlMatches.isNotEmpty) {` | 条件判断 如果(if)：dlMatches.是否非空 |
| 1322 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1323 | `              '第一个<dl>标签内容（前500字符）: ${dlMatches.first.group(0)?.substring(0, dlMatches.first.group(0)!.length > 500 ? 500 : dlMatches.first.group(0)!.length)}');` | 以字符串 '第一个<dl>标签内容（前500字符）: ${dlMatches.first.… 起始的表达式：); |
| 1324 | `        }` | 闭合大括号，结束当前代码块 |
| 1325 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1326 | `        final ulPattern =` | 上一表达式的续行：不可重新赋值(final) ulPattern = |
| 1327 | `            RegExp('<ul[^>]*>.*?</ul>', caseSensitive: false, dotAll: true);` | 构造函数 正则表达式(RegExp)位置参数 3 个；参数名: 区分大小写开关, 假(false), 点号 全部, 真(true) |
| 1328 | `        final ulMatches = ulPattern.allMatches(html);` | 声明不可重新赋值的变量 ulMatches：调用 ulPattern.allMatches(...) → 全部 Matches |
| 1329 | `        AppLog.instance.put('HTML中找到 ${ulMatches.length} 个 <ul> 标签');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('HTML中找到 ${ulMatches.length} 个 <ul> 标签'); |
| 1330 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1331 | `        final olPattern =` | 上一表达式的续行：不可重新赋值(final) olPattern = |
| 1332 | `            RegExp('<ol[^>]*>.*?</ol>', caseSensitive: false, dotAll: true);` | 构造函数 正则表达式(RegExp)位置参数 3 个；参数名: 区分大小写开关, 假(false), 点号 全部, 真(true) |
| 1333 | `        final olMatches = olPattern.allMatches(html);` | 声明不可重新赋值的变量 olMatches：调用 olPattern.allMatches(...) → 全部 Matches |
| 1334 | `        AppLog.instance.put('HTML中找到 ${olMatches.length} 个 <ol> 标签');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('HTML中找到 ${olMatches.length} 个 <ol> 标签'); |
| 1335 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1336 | `        // 查找所有包含链接的元素（可能是章节链接）` | 注释说明：查找所有包含链接的元素（可能是章节链接） |
| 1337 | `        final linkPattern = RegExp('<a[^>]*href[^>]*>.*?</a>',` | 不可重新赋值(final) 类型参数 linkPattern，默认值 正则表达式(RegExp)('<a[^>]*href[^>]*>.*?</a>'（link 模式） |
| 1338 | `            caseSensitive: false, dotAll: true);` | 区分大小写开关: 假(false), 点号 全部: 真(true)) |
| 1339 | `        final linkMatches = linkPattern.allMatches(html);` | 声明不可重新赋值的变量 linkMatches：调用 linkPattern.allMatches(...) → 全部 Matches |
| 1340 | `        AppLog.instance.put('HTML中找到 ${linkMatches.length} 个链接');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('HTML中找到 ${linkMatches.length} 个链接'); |
| 1341 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1342 | `        // 记录调试信息后，抛出异常` | 注释说明：记录调试信息后，抛出异常 |
| 1343 | `        throw TocEmptyException(` | 定义方法 目录(TOC) 空 异常：返回 抛出(throw)；无参数。语义：目录(目录(TOC)) 空 异常 |
| 1344 | `            '章节列表为空: 规则不匹配HTML结构 (书源: ${source.bookSourceName})');` | 以字符串 '章节列表为空: 规则不匹配网页标记文本(HTML)结构 (书源: ${source.bookS… 起始的表达式：); |
| 1345 | `      }` | 闭合大括号，结束当前代码块 |
| 1346 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1347 | `      // 转换为BookChapter对象` | 注释说明：转换为章节(BookChapter)对象 |
| 1348 | `      var chapters = <BookChapter>[];` | 声明自动类型推断的变量 章节列表 |
| 1349 | `      for (int i = 0; i < chapterList.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节 列表.长度(length); 循环变量 i++ |
| 1350 | `        final chapterData = chapterList[i];` | 声明不可重新赋值的变量 chapterData |
| 1351 | `        final chapterName = chapterData['chapterName'] ?? '';` | 声明不可重新赋值的变量 章节 名称 |
| 1352 | `        final isVolumeStr = chapterData['isVolume'] ?? '0';` | 声明不可重新赋值的变量 isVolumeStr |
| 1353 | `        final isVolume =` | 上一表达式的续行：不可重新赋值(final) isVolume = |
| 1354 | `            isVolumeStr == '1' \|\| isVolumeStr.toLowerCase() == 'true';` | 续行赋值：将 = '1' \|\| isVolumeStr.toLowerCase() == '真(true)'; 赋给 isVolumeStr |
| 1355 | `        final chapterUrl = chapterData['chapterUrl'];` | 声明不可重新赋值的变量 章节链接 |
| 1356 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1357 | `        // 参考项目逻辑：` | 注释说明：参考项目逻辑： |
| 1358 | `        // 1. 卷名（isVolume）不需要URL，即使URL为空也会添加` | 注释说明：1. 卷名（isVolume）不需要统一资源链接(URL)，即使统一资源链接(URL)为空也会添加 |
| 1359 | `        // 2. 非卷名章节必须有URL` | 注释说明：2. 非卷名章节必须有统一资源链接(URL) |
| 1360 | `        if (!isVolume && (chapterUrl == null \|\| chapterUrl.isEmpty)) {` | 条件判断 如果(if)：!isVolume 且 (chapterUrl 等于 null 或 chapterUrl.isEmpty) |
| 1361 | `          AppLog.instance.put('章节 ${i + 1} 缺少URL且不是卷名，跳过');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('章节 ${i + 1} 缺少URL且不是卷名，跳过'); |
| 1362 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 1363 | `        }` | 闭合大括号，结束当前代码块 |
| 1364 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1365 | `        // 过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接）` | 注释说明：过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接） |
| 1366 | `        // 过滤包含"上一页"、"下一页"等分页文本的章节` | 注释说明：过滤包含"上一页"、"下一页"等分页文本的章节 |
| 1367 | `        // 使用更严格的空白检查：去除所有空白字符后检查是否为空` | 注释说明：使用更严格的空白检查：去除所有空白字符后检查是否为空 |
| 1368 | `        final trimmedName = chapterName.trim().replaceAll(RegExp(r'\s+'), '');` | 声明不可重新赋值的变量 trimmedName：调用 章节 名称.去除首尾空白(...) → 修剪 |
| 1369 | `        if (chapterName.contains('上一页') \|\|` | 条件判断 如果(if)：章节 名称.是否包含('上一页') 或 |
| 1370 | `            chapterName.contains('下一页') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('下一页') \|\| |
| 1371 | `            chapterName.contains('上一章') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('上一章') \|\| |
| 1372 | `            chapterName.contains('下一章') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('下一章') \|\| |
| 1373 | `            trimmedName.isEmpty) {` | trimmedName.是否为空) { |
| 1374 | `          AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1375 | `              .put('过滤分页链接或空标题章节: 原始="$chapterName", 处理后="$trimmedName"');` | 链式调用延续：.写入数据库(put)('过滤分页链接或空标题章节: 原始="$chapterName", 处理后="$trimmedName"'); |
| 1376 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 1377 | `        }` | 闭合大括号，结束当前代码块 |
| 1378 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1379 | `        // 构建章节URL（卷名可能没有URL）` | 注释说明：构建章节统一资源链接(URL)（卷名可能没有统一资源链接(URL)） |
| 1380 | `        String finalUrl;` | 字符串(String) finalUrl |
| 1381 | `        if (isVolume) {` | 条件判断 如果(if)：isVolume |
| 1382 | `          // 卷名不需要URL，使用空字符串` | 注释说明：卷名不需要统一资源链接(URL)，使用空字符串 |
| 1383 | `          finalUrl = '';` | finalUrl = '' |
| 1384 | `        } else if (chapterUrl != null && chapterUrl.isNotEmpty) {` | 闭合上一代码块并开始 否则(else) 如果(if) (章节链接 != 空值(null) && chapterUr |
| 1385 | `          // 使用effectiveBaseUrl而不是tocUrl，确保baseUrl是有效的绝对URL` | 注释说明：使用effectiveBaseUrl而不是目录(TOC) URL，确保基础链接是有效的绝对统一资源链接(URL) |
| 1386 | `          finalUrl = NetworkService.joinUrl(effectiveBaseUrl, chapterUrl);` | 将 网络服务(NetworkService).拼接 URL(effectiveBaseUrl, 章节链接) 赋值给 finalUrl（调用 拼接 URL → 拼接 统一资源链接(URL)） |
| 1387 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1388 | `          // 非卷名但没有URL，跳过（已在上面检查）` | 注释说明：非卷名但没有统一资源链接(URL)，跳过（已在上面检查） |
| 1389 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 1390 | `        }` | 闭合大括号，结束当前代码块 |
| 1391 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1392 | `        final chapter = BookChapter(` | 声明不可重新赋值的变量 章节：调用 章节(BookChapter)(...) → 书籍 章节 |
| 1393 | `          url: finalUrl,` | 命名实参 链接: finalUrl（统一资源链接(URL)） |
| 1394 | `          title: chapterName.isNotEmpty ? chapterName : '第${i + 1}章',` | 命名实参 标题: 章节 名称.是否非空 ? 章节 名称 : '第${循环变量 i + 1}章'（标题） |
| 1395 | `          bookUrl: book.bookUrl,` | 命名实参 书籍链接: 书籍.书籍链接（书籍 统一资源链接(URL)） |
| 1396 | `          baseUrl: source.bookSourceUrl,` | 命名实参 基础链接: 书源.书源链接（base 统一资源链接(URL)） |
| 1397 | `          index: chapters.length, // 使用过滤后的索引` | 命名实参 索引: 章节列表.长度(length)（索引）；行尾注释：使用过滤后的索引 |
| 1398 | `          isVolume: isVolume, // 设置卷名标志` | 命名实参 isVolume: isVolume（是(is) 体积）；行尾注释：设置卷名标志 |
| 1399 | `          isVip: chapterData['isVip'] == 'true' \|\| chapterData['isVip'] == '1',` | 命名实参 isVip: chapterData['isVip'] == '真(true)' \|\| chapterData['isVip'] == '1'（是(is) Vip） |
| 1400 | `          tag: chapterData['updateTime'],` | 命名实参 tag: chapterData['updateTime'] |
| 1401 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1402 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1403 | `        chapters.add(chapter);` | 链式调用起始于 章节列表（章节列表），后续行继续该表达式：章节列表.添加(章节); |
| 1404 | `      }` | 闭合大括号，结束当前代码块 |
| 1405 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1406 | `      final previewCount = chapters.length < 5 ? chapters.length : 5;` | 声明不可重新赋值的变量 previewCount |
| 1407 | `      for (int i = 0; i < previewCount; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < previewCount; 循环变量 i++ |
| 1408 | `        final chapter = chapters[i];` | 声明不可重新赋值的变量 章节 |
| 1409 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1410 | `          '目录预览 ${i + 1}: title=${chapter.title}, url=${chapter.url}',` | 以字符串 '目录预览 ${循环变量 i + 1}: 标题=${章节.标题}, … 起始的表达式：, |
| 1411 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1412 | `      }` | 闭合大括号，结束当前代码块 |
| 1413 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1414 | `      // 过滤最新章节：找到第一个包含数字编号的章节（如"1、"、"2、"等），这应该是真正的目录开始` | 注释说明：过滤最新章节：找到第一个包含数字编号的章节（如"1、"、"2、"等），这应该是真正的目录开始 |
| 1415 | `      // 参考项目：只添加标题不为空的章节，不添加分页链接` | 注释说明：参考项目：只添加标题不为空的章节，不添加分页链接 |
| 1416 | `      if (chapters.isNotEmpty) {` | 条件判断 如果(if)：章节列表.是否非空 |
| 1417 | `        int startIndex = 0;` | 整数(int) 起始 索引 = 0 |
| 1418 | `        // 查找第一个包含数字编号的章节（如"1、"、"2、"、"第一章"等）` | 注释说明：查找第一个包含数字编号的章节（如"1、"、"2、"、"第一章"等） |
| 1419 | `        // 或者查找第一个标题看起来像章节标题的（包含"章"、"节"等）` | 注释说明：或者查找第一个标题看起来像章节标题的（包含"章"、"节"等） |
| 1420 | `        for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 1421 | `          final title = chapters[i].title;` | 声明不可重新赋值的变量 标题 |
| 1422 | `          // 检查是否包含数字编号模式（如"1、"、"2、"、"第一章"、"第1章"等）` | 注释说明：检查是否包含数字编号模式（如"1、"、"2、"、"第一章"、"第1章"等） |
| 1423 | `          // 或者包含"章"、"节"等关键词，且不是"最新章节"、"最新章"等` | 注释说明：或者包含"章"、"节"等关键词，且不是"最新章节"、"最新章"等 |
| 1424 | `          final hasNumberPattern =` | 上一表达式的续行：不可重新赋值(final) hasNumberPattern = |
| 1425 | `              RegExp(r'^\d+[、.]\|^第\d+章\|^第[一二三四五六七八九十]+章').hasMatch(title);` | 构造函数 正则表达式(RegExp)位置参数 1 个；参数名: 标题 |
| 1426 | `          final hasChapterKeyword = title.contains('章') \|\| title.contains('节');` | 声明不可重新赋值的变量 hasChapterKeyword：调用 标题.是否包含(...) → 是否包含 |
| 1427 | `          final isNotLatestChapter =` | 上一表达式的续行：不可重新赋值(final) isNotLatestChapter = |
| 1428 | `              !title.contains('最新') && !title.contains('最近');` | 调用 是否包含(...)：!标题.是否包含('最新') && !标题.是否包含('最近')（是否包含） |
| 1429 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1430 | `          if (hasNumberPattern \|\|` | 条件判断 如果(if)：hasNumberPattern 或 |
| 1431 | `              (hasChapterKeyword && isNotLatestChapter && i >= 6)) {` | (hasChapterKeyword && isNotLatestChapter && 循环变量 i >= 6)) { |
| 1432 | `            // 如果找到了数字编号模式，或者找到了包含"章"的标题且不是"最新"相关，且索引>=6（跳过前几个）` | 注释说明：如果找到了数字编号模式，或者找到了包含"章"的标题且不是"最新"相关，且索引>=6（跳过前几个） |
| 1433 | `            startIndex = i;` | 将 循环变量 i 赋值给 起始 索引 |
| 1434 | `            break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1435 | `          }` | 闭合大括号，结束当前代码块 |
| 1436 | `        }` | 闭合大括号，结束当前代码块 |
| 1437 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1438 | `        // 如果找到了真正的目录开始位置，移除前面的最新章节` | 注释说明：如果找到了真正的目录开始位置，移除前面的最新章节 |
| 1439 | `        // 但至少要保留一个章节，避免全部删除` | 注释说明：但至少要保留一个章节，避免全部删除 |
| 1440 | `        if (startIndex > 0 && startIndex < chapters.length) {` | 条件判断 如果(if)：起始 索引 > 0 且 起始 索引 < 章节列表.长度(length) |
| 1441 | `          chapters.removeRange(0, startIndex);` | 链式调用起始于 章节列表（章节列表），后续行继续该表达式：章节列表.removeRange(0, 起始 索引); |
| 1442 | `          // 重新设置索引` | 注释说明：重新设置索引 |
| 1443 | `          for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 1444 | `            chapters[i] = chapters[i].copyWith(index: i);` | 调用 copyWith(...)：章节列表[循环变量 i] = 章节列表[循环变量 i].copyWith(索引: 循环变量 i)（复制 With） |
| 1445 | `          }` | 闭合大括号，结束当前代码块 |
| 1446 | `        }` | 闭合大括号，结束当前代码块 |
| 1447 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1448 | `        // 如果第一条章节的标题为空或只包含空白字符，移除它` | 注释说明：如果第一条章节的标题为空或只包含空白字符，移除它 |
| 1449 | `        // 但需要确保不会把所有章节都删除` | 注释说明：但需要确保不会把所有章节都删除 |
| 1450 | `        while (chapters.isNotEmpty) {` | 当型循环(while) 循环，条件：章节列表.是否非空 |
| 1451 | `          final firstTitle =` | 上一表达式的续行：不可重新赋值(final) 首个 标题 = |
| 1452 | `              chapters[0].title.trim().replaceAll(RegExp(r'\s+'), '');` | 调用 去除首尾空白/全部替换/正则表达式(RegExp)(...)：章节列表[0].标题.去除首尾空白().全部替换(正则表达式(RegExp)(r'\s+'), '')（修剪 替换 全部 Reg 表达式） |
| 1453 | `          if (firstTitle.isEmpty) {` | 条件判断 如果(if)：首个 标题.是否为空 |
| 1454 | `            chapters.removeAt(0);` | 链式调用起始于 章节列表（章节列表），后续行继续该表达式：章节列表.removeAt(0); |
| 1455 | `            // 重新设置索引` | 注释说明：重新设置索引 |
| 1456 | `            for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 1457 | `              chapters[i] = chapters[i].copyWith(index: i);` | 调用 copyWith(...)：章节列表[循环变量 i] = 章节列表[循环变量 i].copyWith(索引: 循环变量 i)（复制 With） |
| 1458 | `            }` | 闭合大括号，结束当前代码块 |
| 1459 | `            // 如果删除后列表为空，停止循环` | 注释说明：如果删除后列表为空，停止循环 |
| 1460 | `            if (chapters.isEmpty) {` | 条件判断 如果(if)：章节列表.是否为空 |
| 1461 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1462 | `            }` | 闭合大括号，结束当前代码块 |
| 1463 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1464 | `            break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1465 | `          }` | 闭合大括号，结束当前代码块 |
| 1466 | `        }` | 闭合大括号，结束当前代码块 |
| 1467 | `      }` | 闭合大括号，结束当前代码块 |
| 1468 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1469 | `      // 去重：保留第一个发现的章节` | 注释说明：去重：保留第一个发现的章节 |
| 1470 | `      // LinkedHashSet 保留第一次出现的元素` | 注释说明：LinkedHashSet 保留第一次出现的元素 |
| 1471 | `      final originalCount = chapters.length;` | 声明不可重新赋值的变量 originalCount |
| 1472 | `      final originalChapters = List<BookChapter>.from(chapters);` | 声明不可重新赋值的变量 originalChapters |
| 1473 | `      chapters = LinkedHashSet<BookChapter>.from(chapters).toList();` | 将 LinkedHashSet<章节(BookChapter)>.from(章节列表).转为列表() 赋值给 章节列表（调用 from/转为列表 → to 列表） |
| 1474 | `      if (chapters.length < originalCount) {` | 条件判断 如果(if)：章节列表.长度(length) < originalCount |
| 1475 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1476 | `            .put('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）');` | 链式调用延续：.写入数据库(put)('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）'); |
| 1477 | `        final urlCounts = <String, int>{};` | 声明不可重新赋值的变量 urlCounts |
| 1478 | `        for (final chapter in originalChapters) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 章节 属于(in) originalChapters |
| 1479 | `          urlCounts[chapter.url] = (urlCounts[chapter.url] ?? 0) + 1;` | urlCounts[章节.链接] = (urlCounts[章节.链接] ?? 0) + 1 |
| 1480 | `        }` | 闭合大括号，结束当前代码块 |
| 1481 | `        final duplicates =` | 上一表达式的续行：不可重新赋值(final) duplicates = |
| 1482 | `            urlCounts.entries.where((entry) => entry.value > 1).take(5);` | 链式调用起始于 urlCounts.条目集合（条目集合），后续行继续该表达式：urlCounts.条目集合.筛选(where)((条目) => 条目.值 > 1).截取(5); |
| 1483 | `        for (final entry in duplicates) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 条目 属于(in) duplicates |
| 1484 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1485 | `            '重复章节URL: url=${entry.key}, count=${entry.value}',` | 以字符串 '重复章节统一资源链接(URL): 链接=${条目.键}, 数量=${entr… 起始的表达式：, |
| 1486 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1487 | `        }` | 闭合大括号，结束当前代码块 |
| 1488 | `      }` | 闭合大括号，结束当前代码块 |
| 1489 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1490 | `      // 重新设置索引` | 注释说明：重新设置索引 |
| 1491 | `      for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 1492 | `        chapters[i] = chapters[i].copyWith(index: i);` | 调用 copyWith(...)：章节列表[循环变量 i] = 章节列表[循环变量 i].copyWith(索引: 循环变量 i)（复制 With） |
| 1493 | `      }` | 闭合大括号，结束当前代码块 |
| 1494 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1495 | `      AppLog.instance.put('获取章节列表成功: 共 ${chapters.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表成功: 共 ${chapters.length} 个章节'); |
| 1496 | `      // 不保存到数据库，直接返回` | 注释说明：不保存到数据库，直接返回 |
| 1497 | `      return chapters;` | 返回 章节列表 |
| 1498 | `    } catch (e, stackTrace) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e, stackTrace |
| 1499 | `      AppLog.instance.put('获取章节列表失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败', error: e); |
| 1500 | `      AppLog.instance.put('错误堆栈: $stackTrace');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('错误堆栈: $stackTrace'); |
| 1501 | `      // 重新抛出异常，让调用者能够处理错误` | 注释说明：重新抛出异常，让调用者能够处理错误 |
| 1502 | `      // 如果调用者希望静默处理，可以在调用处捕获异常` | 注释说明：如果调用者希望静默处理，可以在调用处捕获异常 |
| 1503 | `      rethrow;` | rethrow |
| 1504 | `    }` | 闭合大括号，结束当前代码块 |
| 1505 | `  }` | 闭合大括号，结束当前代码块 |
| 1506 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1507 | `  /// 更新书籍目录（用于更新目录功能，支持分页获取）` | 文档注释：说明其后代码的用途 |
