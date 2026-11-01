# book_service.dart 逐行注释

> 源文件：`lib/services/book/book_service.dart`（共 3592 行）
>
> 本文件由 `scripts/gen_line_annotations.py` 自动生成，对源文件每一行给出独立说明。
> 说明优先采用源码自带的中文注释；无注释的行依据 Dart 语法特征自动生成解释。

| 行号 | 源代码 | 说明 |
| ---: | --- | --- |
| 1 | `import 'dart:collection';` | 导入 dart:集合 模块 |
| 2 | `import 'package:legado_flutter/providers/service_registry.dart';` | 导入 legado_flutter 模块 |
| 3 | `import 'dart:convert';` | 导入 dart:convert 模块 |
| 4 | `import 'dart:io';` | 导入 dart:io 模块 |
| 5 | `import 'package:sqflite/sqflite.dart';` | 导入 sqflite 模块 |
| 6 | `import 'package:html/parser.dart' as html_parser;` | 导入 网页内容 模块，别名 HTML 解析器 |
| 7 | `import 'package:html/dom.dart' as html_dom;` | 导入 网页内容 模块，别名 html_dom |
| 8 | `import '../../core/base/base_service.dart';` | 导入 base_service 模块 |
| 9 | `import '../../core/exceptions/app_exceptions.dart';` | 导入 app_exceptions 模块 |
| 10 | `import '../../data/database/app_database.dart';` | 导入 app_database 模块 |
| 11 | `import '../../data/models/book.dart';` | 导入 书籍 模块 |
| 12 | `import '../../data/models/book_chapter.dart';` | 导入 书籍 章节 模块 |
| 13 | `import '../../data/models/book_source.dart';` | 导入 书籍 书源 模块 |
| 14 | `import '../../data/models/book_source_rule.dart';` | 导入 书籍 书源 规则 模块 |
| 15 | `import '../network/network_service.dart';` | 导入 network_service 模块 |
| 16 | `import '../network/protocol_handler.dart';` | 导入 protocol_handler 模块 |
| 17 | `import '../../utils/parsers/rule_parser.dart';` | 导入 规则 解析器 模块 |
| 18 | `import '../../utils/parsers/html_parser.dart';` | 导入 HTML 解析器 模块 |
| 19 | `import '../../utils/app_log.dart';` | 导入 app_log 模块 |
| 20 | `import '../../utils/concurrent_rate_limiter.dart';` | 导入 concurrent_rate_limiter 模块 |
| 21 | `import '../../utils/js_engine.dart';` | 导入 JS脚本 引擎 模块 |
| 22 | `import '../../utils/helpers/book_extensions.dart';` | 导入 book_extensions 模块 |
| 23 | `import '../../utils/network_utils.dart';` | 导入 network_utils 模块 |
| 24 | `import '../source/book_source_service.dart';` | 导入 书籍 书源 服务 模块 |
| 25 | `import '../reader/content_processor.dart';` | 导入 content_processor 模块 |
| 26 | `&nbsp;` | 空行，分隔逻辑段落 |
| 27 | `abstract class IBookService {` | 定义抽象类 循环变量 i 书籍 服务（接口契约，子类必须实现其抽象方法） |
| 28 | `  Future<Book?> getBookInfo(Book book);` | 定义方法 getBookInfo：返回 异步结果(Future)<书籍(Book)?>；位置参数 1 个；参数名: 书籍（异步）。语义：获取 书籍 Info |
| 29 | `&nbsp;` | 空行，分隔逻辑段落 |
| 30 | `  Future<List<BookChapter>> getChapterList(` | 定义方法 获取 章节 列表：返回 异步结果(Future)<列表(List)<章节(BookChapter)>>；无参数（异步）。语义：获取 章节 列表 |
| 31 | `    Book book, {` | 书籍(Book) 类型参数 书籍，其后 { 开启命名参数块（书籍） |
| 32 | `    bool loadAllPages = true,` | 布尔(bool) 类型参数 加载 全部 分页，默认值 真(true)（加载 全部 分页） |
| 33 | `  });` | 闭合代码块并衔接后续语句：); |
| 34 | `&nbsp;` | 空行，分隔逻辑段落 |
| 35 | `  Future<Map<String, bool>> updateChapterLists(List<Book> books);` | 定义方法 更新 章节 列表集合：返回 异步结果(Future)<映射(Map)<字符串(String), 布尔(bool)>>；位置参数 1 个；参数名: 书籍列表（异步）。语义：更新 章节 列表集合 |
| 36 | `&nbsp;` | 空行，分隔逻辑段落 |
| 37 | `  Future<Book?> getBookByUrl(String bookUrl);` | 定义方法 getBookByUrl：返回 异步结果(Future)<书籍(Book)?>；位置参数 1 个；参数名: 书籍链接（异步）。语义：获取 书籍 By 统一资源链接(URL) |
| 38 | `&nbsp;` | 空行，分隔逻辑段落 |
| 39 | `  Future<String?> getChapterContent(` | 定义方法 获取 章节 正文内容：返回 异步结果(Future)<字符串(String)?>；无参数（异步）。语义：获取 章节 正文内容 |
| 40 | `    BookChapter chapter,` | 章节(BookChapter) 类型参数 章节（章节） |
| 41 | `    BookSource source, {` | 书源(BookSource) 类型参数 书源，其后 { 开启命名参数块（书源） |
| 42 | `    String? bookName,` | 字符串(String)? 类型参数 书籍 名称（书籍 名称） |
| 43 | `    String? bookOrigin,` | 字符串(String)? 类型参数 书籍 来源（书籍 来源） |
| 44 | `    Book? book,` | 书籍(Book)? 类型参数 书籍（书籍） |
| 45 | `  });` | 闭合代码块并衔接后续语句：); |
| 46 | `&nbsp;` | 空行，分隔逻辑段落 |
| 47 | `  Future<void> saveBook(Book book);` | 定义方法 保存 书籍：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；参数名: 书籍（异步）。语义：保存 书籍 |
| 48 | `&nbsp;` | 空行，分隔逻辑段落 |
| 49 | `  Future<Book> createBook(Book book);` | 定义方法 createBook：返回 异步结果(Future)<书籍(Book)>；位置参数 1 个；参数名: 书籍（异步）。语义：create 书籍 |
| 50 | `&nbsp;` | 空行，分隔逻辑段落 |
| 51 | `  Future<void> createChapter(BookChapter chapter);` | 定义方法 createChapter：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；参数名: 章节（异步）。语义：create 章节 |
| 52 | `&nbsp;` | 空行，分隔逻辑段落 |
| 53 | `  Future<void> deleteBook(String bookUrl);` | 定义方法 删除 书籍：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；参数名: 书籍链接（异步）。语义：删除 书籍 |
| 54 | `&nbsp;` | 空行，分隔逻辑段落 |
| 55 | `  Future<List<Book>> getBookshelfBooks();` | 定义方法 getBookshelfBooks：返回 异步结果(Future)<列表(List)<书籍(Book)>>；位置参数 1 个（异步）。语义：获取 Bookshelf 书籍列表 |
| 56 | `&nbsp;` | 空行，分隔逻辑段落 |
| 57 | `  Future<List<Book>> getBooksByGroup(int groupId);` | 定义方法 getBooksByGroup：返回 异步结果(Future)<列表(List)<书籍(Book)>>；位置参数 1 个；参数名: 捕获组 编号(id)（异步）。语义：获取 书籍列表 By 捕获组 |
| 58 | `&nbsp;` | 空行，分隔逻辑段落 |
| 59 | `  Future<void> updateBookGroup(String bookUrl, int groupId);` | 定义方法 更新 书籍 捕获组：返回 异步结果(Future)<无返回值(void)>；位置参数 2 个；参数名: 书籍链接, 捕获组 编号(id)（异步）。语义：更新 书籍 捕获组 |
| 60 | `&nbsp;` | 空行，分隔逻辑段落 |
| 61 | `  Future<void> updateReadingProgress(` | 定义方法 updateReadingProgress：返回 异步结果(Future)<无返回值(void)>；无参数（异步）。语义：更新 Reading 进度 |
| 62 | `    String bookUrl,` | 字符串(String) 类型参数 书籍链接（书籍 统一资源链接(URL)） |
| 63 | `    int chapterIndex,` | 整数(int) 类型参数 章节 索引（章节 索引） |
| 64 | `    int chapterPos,` | 整数(int) 类型参数 章节 位置（章节 位置） |
| 65 | `    String? chapterTitle,` | 字符串(String)? 类型参数 章节 标题（章节 标题） |
| 66 | `  );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 67 | `&nbsp;` | 空行，分隔逻辑段落 |
| 68 | `  Future<void> saveChapters(List<BookChapter> chapters);` | 定义方法 保存 章节列表：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；参数名: 章节列表（异步）。语义：保存 章节列表 |
| 69 | `&nbsp;` | 空行，分隔逻辑段落 |
| 70 | `  Future<void> updateBookOrder(String bookUrl, int order);` | 定义方法 更新 书籍 顺序：返回 异步结果(Future)<无返回值(void)>；位置参数 2 个；参数名: 书籍链接, 顺序（异步）。语义：更新 书籍 顺序 |
| 71 | `&nbsp;` | 空行，分隔逻辑段落 |
| 72 | `  Future<void> updateBook(Book book);` | 定义方法 更新 书籍：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；参数名: 书籍（异步）。语义：更新 书籍 |
| 73 | `}` | 闭合大括号，结束当前代码块 |
| 74 | `&nbsp;` | 空行，分隔逻辑段落 |
| 75 | `/// 书籍服务 - 处理搜索、详情、章节、正文等功能` | 文档注释：说明其后代码的用途 |
| 76 | `class BookService extends BaseService implements IBookService {` | 【承接上方文档】书籍服务 - 处理搜索、详情、章节、正文等功能 → 定义类 书籍 服务，继承 BaseService，实现接口 循环变量 i |
| 77 | `  static final BookService instance = BookService._init();` | 调用 _init(...)：static 不可重新赋值(final) 书籍 服务 实例 = 书籍 服务._init()（初始化） |
| 78 | `  final AppDatabase _db = AppDatabase.instance;` | 声明不可重新赋值的 AppDatabase 类型变量 _数据库（数据库） |
| 79 | `  final INetworkService _networkService =` | 上一表达式的续行：不可重新赋值(final) INetworkService _networkService = |
| 80 | `      readService(AppServices.networkService);` | 调用 读取 服务(...)：读取 服务(AppServices.networkService)（读取 服务） |
| 81 | `  final IBookSourceService _bookSourceService =` | 上一表达式的续行：不可重新赋值(final) 循环变量 i 书籍 书源 服务 _书籍 书源 服务 = |
| 82 | `      readService(AppServices.bookSourceService);` | 调用 读取 服务(...)：读取 服务(AppServices.书籍 书源 服务)（读取 服务） |
| 83 | `  final ProtocolHandler _protocolHandler = ProtocolHandler.instance;` | 声明不可重新赋值的 ProtocolHandler 类型变量 _protocolHandler（protocol Handler） |
| 84 | `&nbsp;` | 空行，分隔逻辑段落 |
| 85 | `  // 正在请求的章节（用于防止重复请求）` | 注释说明：正在请求的章节（用于防止重复请求） |
| 86 | `  // Key: 章节URL，Value: 请求的Future` | 注释说明：键: 章节统一资源链接(URL)，值: 请求的异步结果(Future) |
| 87 | `  final Map<String, Future<String?>> _loadingChapters = {};` | 声明不可重新赋值的 映射<字符串(String), 异步结果<字符串(String)?>> 类型变量 _加载中 章节列表：映射(Map)/集合字面量（加载中 章节列表） |
| 88 | `&nbsp;` | 空行，分隔逻辑段落 |
| 89 | `  BookService._init();` | 链式调用起始于 书籍 服务（书籍 服务），后续行继续该表达式：书籍 服务._init(); |
| 90 | `&nbsp;` | 空行，分隔逻辑段落 |
| 91 | `  /// 统一的网络请求接口 (支持多协议)` | 文档注释：说明其后代码的用途 |
| 92 | `  ///` | 文档注释：说明其后代码的用途 |
| 93 | `  /// 自动检测URL的协议类型,选择合适的处理方式:` | 文档注释：说明其后代码的用途 |
| 94 | `  /// - HTTP/HTTPS: 常规网页解析` | 文档注释：说明其后代码的用途 |
| 95 | `  /// - JSON/API: JSON响应直接解析` | 文档注释：说明其后代码的用途 |
| 96 | `  /// - WebView: 处理严格反爬网站` | 文档注释：说明其后代码的用途 |
| 97 | `  ///` | 文档注释：说明其后代码的用途 |
| 98 | `  /// [url] 请求URL (可包含协议标记 @json, @webview)` | 文档注释：说明其后代码的用途 |
| 99 | `  /// [source] 书源配置` | 文档注释：说明其后代码的用途 |
| 100 | `  /// [method] HTTP方法 (GET/POST)` | 文档注释：说明其后代码的用途 |
| 101 | `  /// [headers] 额外的请求头` | 文档注释：说明其后代码的用途 |
| 102 | `  /// [data] POST数据` | 文档注释：说明其后代码的用途 |
| 103 | `  ///` | 文档注释：说明其后代码的用途 |
| 104 | `  /// 返回: HTTP响应文本` | 文档注释：说明其后代码的用途 |
| 105 | `  Future<String> _request(` | 【承接上方文档】统一的网络请求接口 (支持多协议)  自动检测统一资源链接(URL)的协议类型,选择合适的处理方式: - 超文本传输协议(HTTP)/安全超文本传输协议(HTTPS): 常规网页解析 - JSON数据/应用程序接口(API): JSON数据 → 定义方法 _请求：返回 异步结果(Future)<字符串(String)>；无参数（异步）。语义：请求 |
| 106 | `    String url,` | 字符串(String) 类型参数 链接（统一资源链接(URL)） |
| 107 | `    BookSource source, {` | 书源(BookSource) 类型参数 书源，其后 { 开启命名参数块（书源） |
| 108 | `    String method = 'GET',` | 字符串(String) 类型参数 方法，默认值 'GET'（方法） |
| 109 | `    Map<String, String>? headers,` | 映射(Map)<字符串(String), 字符串(String)>? 类型参数 请求头（请求头） |
| 110 | `    dynamic data,` | dynamic 类型参数 data |
| 111 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 112 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 113 | `      // 使用协议处理器自动处理不同协议类型` | 注释说明：使用协议处理器自动处理不同协议类型 |
| 114 | `      return await _protocolHandler.request(` | 返回异步调用 _protocolHandler.请求(...) 的结果（语义：请求） |
| 115 | `        url: url,` | 命名实参 链接: 链接（统一资源链接(URL)） |
| 116 | `        source: source,` | 命名实参 书源: 书源（书源） |
| 117 | `        method: method,` | 命名实参 方法: 方法（方法） |
| 118 | `        headers: headers,` | 命名实参 请求头: 请求头（请求头） |
| 119 | `        data: data,` | 命名实参 data: data |
| 120 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 121 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 122 | `      AppLog.instance.put('网络请求失败: $url', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('网络请求失败: $url', error: e); |
| 123 | `      rethrow;` | rethrow |
| 124 | `    }` | 闭合大括号，结束当前代码块 |
| 125 | `  }` | 闭合大括号，结束当前代码块 |
| 126 | `&nbsp;` | 空行，分隔逻辑段落 |
| 127 | `  /// 比较两个 URL 是否相等（规范化后比较）` | 文档注释：说明其后代码的用途 |
| 128 | `  /// 参考项目：NetworkUtils.getAbsoluteURL 的比较逻辑` | 文档注释：说明其后代码的用途 |
| 129 | `  /// 处理 URL 末尾的旜杠、大小写等差异` | 文档注释：说明其后代码的用途 |
| 130 | `  bool _urlEquals(String url1, String url2) {` | 【承接上方文档】比较两个 统一资源链接(URL) 是否相等（规范化后比较） 参考项目：NetworkUtils.getAbsoluteURL 的比较逻辑 处理 统一资源链接(URL) 末尾的旜杠、大小写等差异 → 定义方法 _urlEquals：返回 布尔(bool)；位置参数 2 个；参数名: url1。语义：统一资源链接(URL) Equals |
| 131 | `    if (url1 == url2) return true;` | 条件判断 如果(if)：url1 等于 url2) 返回(return) 真(true); |
| 132 | `    if (url1.isEmpty \|\| url2.isEmpty) return false;` | 条件判断 如果(if)：url1.是否为空 或 url2.是否为空) 返回(return) 假(false); |
| 133 | `&nbsp;` | 空行，分隔逻辑段落 |
| 134 | `    // 规范化 URL：移除末尾的 /` | 注释说明：规范化 统一资源链接(URL)：移除末尾的 / |
| 135 | `    String normalize(String url) {` | 定义方法 normalize：返回 字符串(String)；位置参数 1 个。语义：规范化 |
| 136 | `      var normalized = url.trim();` | 声明自动类型推断的变量 normalized：调用 链接.去除首尾空白(...) → 修剪 |
| 137 | `      while (normalized.endsWith('/')) {` | 当型循环(while) 循环，条件：normalized.endsWith('/') |
| 138 | `        normalized = normalized.substring(0, normalized.length - 1);` | 将 normalized.substring(0, normalized.长度(length) - 1) 赋值给 normalized |
| 139 | `      }` | 闭合大括号，结束当前代码块 |
| 140 | `      return normalized;` | 返回 normalized |
| 141 | `    }` | 闭合大括号，结束当前代码块 |
| 142 | `&nbsp;` | 空行，分隔逻辑段落 |
| 143 | `    final normalized1 = normalize(url1);` | 声明不可重新赋值的变量 normalized1：调用 normalize(...) → 规范化 |
| 144 | `    final normalized2 = normalize(url2);` | 声明不可重新赋值的变量 normalized2：调用 normalize(...) → 规范化 |
| 145 | `&nbsp;` | 空行，分隔逻辑段落 |
| 146 | `    // 直接比较` | 注释说明：直接比较 |
| 147 | `    if (normalized1 == normalized2) return true;` | 条件判断 如果(if)：normalized1 等于 normalized2) 返回(return) 真(true); |
| 148 | `&nbsp;` | 空行，分隔逻辑段落 |
| 149 | `    // 尝试解析 URI 后比较` | 注释说明：尝试解析 URI 后比较 |
| 150 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 151 | `      final uri1 = Uri.parse(normalized1);` | 声明不可重新赋值的变量 uri1：调用 统一资源标识(URI).parse(...) → 解析 |
| 152 | `      final uri2 = Uri.parse(normalized2);` | 声明不可重新赋值的变量 uri2：调用 统一资源标识(URI).parse(...) → 解析 |
| 153 | `&nbsp;` | 空行，分隔逻辑段落 |
| 154 | `      // 比较 scheme、host、port 和 path` | 注释说明：比较 scheme、主机、端口 和 路径 |
| 155 | `      return uri1.scheme == uri2.scheme &&` | 上一表达式的续行：返回(return) uri1.scheme == uri2.scheme && |
| 156 | `          uri1.host == uri2.host &&` | 续行赋值：将 = uri2.主机 && 赋给 uri1.主机 |
| 157 | `          uri1.port == uri2.port &&` | 续行赋值：将 = uri2.端口 && 赋给 uri1.端口 |
| 158 | `          uri1.path == uri2.path;` | 续行赋值：将 = uri2.路径; 赋给 uri1.路径 |
| 159 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 160 | `      return false;` | 返回 假(false)（布尔值 假(false)） |
| 161 | `    }` | 闭合大括号，结束当前代码块 |
| 162 | `  }` | 闭合大括号，结束当前代码块 |
| 163 | `&nbsp;` | 空行，分隔逻辑段落 |
| 164 | `  String _chapterIdentity(Map<String, String?> chapterData) {` | 定义方法 _chapterIdentity：返回 字符串(String)；位置参数 2 个；参数名: 字符串(String)。语义：章节 Identity |
| 165 | `    final chapterUrl = chapterData['chapterUrl']?.trim() ?? '';` | 声明不可重新赋值的变量 章节链接 |
| 166 | `    if (chapterUrl.isNotEmpty) return chapterUrl;` | 条件判断 如果(if)：章节链接.是否非空) 返回(return) 章节链接; |
| 167 | `    return chapterData['chapterName']?.trim() ?? '';` | 返回 chapterData['章节 名称']?.去除首尾空白() ?? '' |
| 168 | `  }` | 闭合大括号，结束当前代码块 |
| 169 | `&nbsp;` | 空行，分隔逻辑段落 |
| 170 | `  List<String> _buildImplicitTocPageCandidates(String tocUrl, int pageNumber) {` | 定义方法 _buildImplicitTocPageCandidates：返回 列表(List)<字符串(String)>；位置参数 2 个；参数名: 目录(TOC) URL。语义：构建 Implicit 目录(目录(TOC)) 页 Candidates |
| 171 | `    if (pageNumber < 2 \|\| tocUrl.isEmpty) return const [];` | 条件判断 如果(if)：pageNumber < 2 或 目录(TOC) URL.是否为空) 返回(return) 编译期常量(const) []; |
| 172 | `&nbsp;` | 空行，分隔逻辑段落 |
| 173 | `    final normalizedUrl = tocUrl.trim();` | 声明不可重新赋值的变量 normalizedUrl：调用 目录(TOC) URL.去除首尾空白(...) → 修剪 |
| 174 | `    final candidates = <String>[];` | 声明不可重新赋值的变量 candidates |
| 175 | `&nbsp;` | 空行，分隔逻辑段落 |
| 176 | `    void addCandidate(String value) {` | 定义方法 addCandidate：返回 无返回值(void)；位置参数 1 个。语义：添加 Candidate |
| 177 | `      if (value.isNotEmpty && !candidates.contains(value)) {` | 条件判断 如果(if)：值.是否非空 且 !candidates.是否包含(值) |
| 178 | `        candidates.add(value);` | 链式调用起始于 candidates，后续行继续该表达式：candidates.添加(值); |
| 179 | `      }` | 闭合大括号，结束当前代码块 |
| 180 | `    }` | 闭合大括号，结束当前代码块 |
| 181 | `&nbsp;` | 空行，分隔逻辑段落 |
| 182 | `    if (normalizedUrl.endsWith('/')) {` | 条件判断 如果(if)：normalizedUrl.endsWith('/') |
| 183 | `      addCandidate(` | 调用 addCandidate(...)：addCandidate(（添加 Candidate） |
| 184 | `          NetworkService.joinUrl(normalizedUrl, 'index_$pageNumber.html'));` | 链式调用起始于 网络服务(NetworkService)（Network 服务），后续行继续该表达式：网络服务(NetworkService).拼接 URL(normalizedUrl, 'index_$pageNumber.网页内容')); |
| 185 | `      addCandidate(NetworkService.joinUrl(normalizedUrl, '$pageNumber.html'));` | 调用 addCandidate/拼接 URL(...)：addCandidate(网络服务(NetworkService).拼接 URL(normalizedUrl, '$pageNumber.网页内容'))（添加 Candidate 拼接 统一资源链接(URL)） |
| 186 | `      return candidates;` | 返回 candidates |
| 187 | `    }` | 闭合大括号，结束当前代码块 |
| 188 | `&nbsp;` | 空行，分隔逻辑段落 |
| 189 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 190 | `      final uri = Uri.parse(normalizedUrl);` | 声明不可重新赋值的变量 uri：调用 统一资源标识(URI).parse(...) → 解析 |
| 191 | `      if (uri.path.endsWith('.html')) {` | 条件判断 如果(if)：uri.路径.endsWith('.网页内容') |
| 192 | `        final slashIndex = uri.path.lastIndexOf('/');` | 声明不可重新赋值的变量 斜杠 索引：调用 uri.路径.lastIndexOf(...) → 最后 索引 Of |
| 193 | `        final directoryPath =` | 上一表达式的续行：不可重新赋值(final) 目录(directory) 路径 = |
| 194 | `            slashIndex >= 0 ? uri.path.substring(0, slashIndex + 1) : '/';` | 调用 substring(...)：斜杠 索引 >= 0 ? uri.路径.substring(0, 斜杠 索引 + 1) : '/' |
| 195 | `        final pageUri =` | 上一表达式的续行：不可重新赋值(final) 页 统一资源标识(URI) = |
| 196 | `            uri.replace(path: '${directoryPath}index_$pageNumber.html');` | 链式调用起始于 uri，后续行继续该表达式：uri.replace(路径: '${目录(directory) 路径}index_$pageNumber.网页内容'); |
| 197 | `        addCandidate(pageUri.toString());` | 调用 addCandidate/转为字符串(...)：addCandidate(页 统一资源标识(URI).转为字符串())（添加 Candidate to 字符串(字符串(String))） |
| 198 | `      }` | 闭合大括号，结束当前代码块 |
| 199 | `    } catch (_) {` | 闭合 尝试(try) 块并捕获异常（忽略异常对象） |
| 200 | `      // ignore invalid tocUrl and fall back to the original URL shape below.` | 注释说明：ignore 无效 目录(TOC) URL and fall back to the original 统一资源链接(URL) 形状 below. |
| 201 | `    }` | 闭合大括号，结束当前代码块 |
| 202 | `&nbsp;` | 空行，分隔逻辑段落 |
| 203 | `    addCandidate('$normalizedUrl/index_$pageNumber.html');` | 调用 addCandidate(...)：addCandidate('$normalizedUrl/index_$pageNumber.网页内容')（添加 Candidate） |
| 204 | `    return candidates;` | 返回 candidates |
| 205 | `  }` | 闭合大括号，结束当前代码块 |
| 206 | `&nbsp;` | 空行，分隔逻辑段落 |
| 207 | `  Future<List<Map<String, String?>>> _loadImplicitTocPages({` | 定义方法 _loadImplicitTocPages：返回 异步结果(Future)<列表(List)<映射(Map)<字符串(String), 字符串(String)?>>>；含命名参数（异步）。语义：加载 Implicit 目录(目录(TOC)) 分页 |
| 208 | `    required String tocUrl,` | 必填字符串(String) 类型参数 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 209 | `    required BookSource source,` | 必填书源(BookSource) 类型参数 书源（书源） |
| 210 | `    required TocRule tocRule,` | 必填目录(TOC) 规则 类型参数 目录(TOC) 规则（目录(目录(TOC)) 规则） |
| 211 | `    required Iterable<Map<String, String?>> seedChapters,` | 必填Iterable<映射(Map)<字符串(String), 字符串(String)?>> 类型参数 seedChapters（seed 章节列表） |
| 212 | `    Map<String, String>? variables,` | 映射(Map)<字符串(String), 字符串(String)>? 类型参数 variables（变量表） |
| 213 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 214 | `    if (tocUrl.isEmpty \|\| tocRule.nextTocUrl?.isNotEmpty == true) {` | 条件判断 如果(if)：目录(TOC) URL.是否为空 或 目录(TOC) 规则.下一页目录链接?.是否非空 等于 真(true) |
| 215 | `      return const [];` | 返回 编译期常量(const) [] |
| 216 | `    }` | 闭合大括号，结束当前代码块 |
| 217 | `&nbsp;` | 空行，分隔逻辑段落 |
| 218 | `    final existingIdentities =` | 上一表达式的续行：不可重新赋值(final) existingIdentities = |
| 219 | `        seedChapters.map(_chapterIdentity).where((id) => id.isNotEmpty).toSet();` | 链式调用起始于 seedChapters（seed 章节列表），后续行继续该表达式：seedChapters.映射(map)(_chapterIdentity).筛选(where)((编号(id)) => 编号(id).是否非空).转为集合(… |
| 220 | `    final collected = <Map<String, String?>>[];` | 声明不可重新赋值的变量 collected |
| 221 | `    const maxImplicitPages = 50;` | 声明编译期常量变量 maxImplicitPages |
| 222 | `&nbsp;` | 空行，分隔逻辑段落 |
| 223 | `    for (int pageNumber = 2; pageNumber <= maxImplicitPages; pageNumber++) {` | 循环(for)-属于(in) 遍历：整数(int) pageNumber = 2; pageNumber <= maxImplicitPages; pageNumber++ |
| 224 | `      final candidates = _buildImplicitTocPageCandidates(tocUrl, pageNumber);` | 声明不可重新赋值的变量 candidates：调用 _buildImplicitTocPageCandidates(...) → 构建 Implicit 目录(目录(TOC)) 页 Candidates |
| 225 | `      if (candidates.isEmpty) break;` | 条件判断 如果(if)：candidates.是否为空) 跳出(break); |
| 226 | `&nbsp;` | 空行，分隔逻辑段落 |
| 227 | `      List<Map<String, String?>>? matchedPage;` | 列表(List)<映射(Map)<字符串(String), 字符串(String)?>>? matchedPage |
| 228 | `&nbsp;` | 空行，分隔逻辑段落 |
| 229 | `      for (final candidateUrl in candidates) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) candidateUrl 属于(in) candidates |
| 230 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 231 | `          final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 232 | `            candidateUrl,` | 签名/调用续行参数：candidateUrl |
| 233 | `            headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 234 | `            retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 235 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 236 | `          if (response.statusCode != 200) {` | 条件判断 如果(if)：响应.状态 代码 不等于 200 |
| 237 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 238 | `          }` | 闭合大括号，结束当前代码块 |
| 239 | `&nbsp;` | 空行，分隔逻辑段落 |
| 240 | `          final pageHtml = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 页 HTML：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 241 | `          if (pageHtml.isEmpty) {` | 条件判断 如果(if)：页 HTML.是否为空 |
| 242 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 243 | `          }` | 闭合大括号，结束当前代码块 |
| 244 | `&nbsp;` | 空行，分隔逻辑段落 |
| 245 | `          final pageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 246 | `            pageHtml,` | 签名/调用续行参数：页 HTML |
| 247 | `            tocRule,` | 签名/调用续行参数：目录(TOC) 规则 |
| 248 | `            variables: variables,` | 命名实参 variables: variables（变量表） |
| 249 | `            baseUrl: candidateUrl,` | 命名实参 基础链接: candidateUrl（base 统一资源链接(URL)） |
| 250 | `            getNextUrl: false,` | 命名实参 获取 下一章 URL: 假(false)（获取 下一章 统一资源链接(URL)） |
| 251 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 252 | `          final pageChapters =` | 上一表达式的续行：不可重新赋值(final) 页 章节列表 = |
| 253 | `              pageResult['chapterList'] as List<Map<String, String?>>;` | 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 254 | `          if (pageChapters.isEmpty) {` | 条件判断 如果(if)：页 章节列表.是否为空 |
| 255 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 256 | `          }` | 闭合大括号，结束当前代码块 |
| 257 | `&nbsp;` | 空行，分隔逻辑段落 |
| 258 | `          final newChapters = pageChapters.where((chapter) {` | 声明不可重新赋值的变量 newChapters：调用 页 章节列表.筛选(where)(...) → 筛选(筛选(where)) |
| 259 | `            final identity = _chapterIdentity(chapter);` | 声明不可重新赋值的变量 identity：调用 _chapterIdentity(...) → 章节 Identity |
| 260 | `            return identity.isNotEmpty &&` | 上一表达式的续行：返回(return) identity.是否非空 && |
| 261 | `                !existingIdentities.contains(identity);` | 调用 是否包含(...)：!existingIdentities.是否包含(identity)（是否包含） |
| 262 | `          }).toList();` | 闭合代码块并衔接后续语句：).转为列表(); |
| 263 | `&nbsp;` | 空行，分隔逻辑段落 |
| 264 | `          if (newChapters.isEmpty) {` | 条件判断 如果(if)：newChapters.是否为空 |
| 265 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 266 | `          }` | 闭合大括号，结束当前代码块 |
| 267 | `&nbsp;` | 空行，分隔逻辑段落 |
| 268 | `          matchedPage = newChapters;` | 将 newChapters 赋值给 matchedPage |
| 269 | `          existingIdentities.addAll(` | 链式调用起始于 existingIdentities，后续行继续该表达式：existingIdentities.批量添加( |
| 270 | `            newChapters.map(_chapterIdentity).where((id) => id.isNotEmpty),` | 链式调用起始于 newChapters（新建(new) 章节列表），后续行继续该表达式：newChapters.映射(map)(_chapterIdentity).筛选(where)((编号(id)) => 编号(id).是否非空), |
| 271 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 272 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 273 | `        } catch (_) {` | 闭合 尝试(try) 块并捕获异常（忽略异常对象） |
| 274 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 275 | `        }` | 闭合大括号，结束当前代码块 |
| 276 | `      }` | 闭合大括号，结束当前代码块 |
| 277 | `&nbsp;` | 空行，分隔逻辑段落 |
| 278 | `      if (matchedPage == null \|\| matchedPage.isEmpty) {` | 条件判断 如果(if)：matchedPage 等于 空值(null) 或 matchedPage.是否为空 |
| 279 | `        break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 280 | `      }` | 闭合大括号，结束当前代码块 |
| 281 | `&nbsp;` | 空行，分隔逻辑段落 |
| 282 | `      collected.addAll(matchedPage);` | 链式调用起始于 collected，后续行继续该表达式：collected.批量添加(matchedPage); |
| 283 | `    }` | 闭合大括号，结束当前代码块 |
| 284 | `&nbsp;` | 空行，分隔逻辑段落 |
| 285 | `    if (collected.isNotEmpty) {` | 条件判断 如果(if)：collected.是否非空 |
| 286 | `      AppLog.instance.put('目录隐式分页补全成功: 新增 ${collected.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('目录隐式分页补全成功: 新增 ${collected.length} 个章节'); |
| 287 | `    }` | 闭合大括号，结束当前代码块 |
| 288 | `&nbsp;` | 空行，分隔逻辑段落 |
| 289 | `    return collected;` | 返回 collected |
| 290 | `  }` | 闭合大括号，结束当前代码块 |
| 291 | `&nbsp;` | 空行，分隔逻辑段落 |
| 292 | `  String? _extractAjaxTocBookId(String html) {` | 定义方法 _extractAjaxTocBookId：返回 字符串(String)?；位置参数 1 个。语义：提取 Ajax 目录(目录(TOC)) 书籍 编号(编号(id)) |
| 293 | `    final match = RegExp(` | 声明不可重新赋值的变量 match：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 294 | `      'id\\s*=\\s*["\\\']bookiddata["\\\'][^>]*data-sid\\s*=\\s*["\\\'](\\d+)["\\\']',` | 以字符串 '编号(id)\\s*=\\s*["\\\']bookiddata["\\\'][^>]… 起始的表达式：, |
| 295 | `      caseSensitive: false,` | 区分大小写开关: 假(false), |
| 296 | `    ).firstMatch(html);` | 调用 首个匹配(...)：).首个匹配(网页内容)（首个 Match） |
| 297 | `    return match?.group(1);` | 返回 match?.捕获组(1) |
| 298 | `  }` | 闭合大括号，结束当前代码块 |
| 299 | `&nbsp;` | 空行，分隔逻辑段落 |
| 300 | `  bool _supportsAjaxTocFallback(String tocUrl, String html) {` | 定义方法 _supportsAjaxTocFallback：返回 布尔(bool)；位置参数 2 个；参数名: 目录(TOC) URL。语义：supports Ajax 目录(目录(TOC)) 回退/降级 |
| 301 | `    return tocUrl.contains('guishuji.com') &&` | 返回调用 目录(TOC) URL.是否包含(...) 的结果（语义：是否包含） |
| 302 | `        _extractAjaxTocBookId(html)?.isNotEmpty == true;` | 调用 _extractAjaxTocBookId(...)：_extractAjaxTocBookId(网页内容)?.是否非空 == 真(true)（提取 Ajax 目录(目录(TOC)) 书籍 编号(编号(id))） |
| 303 | `  }` | 闭合大括号，结束当前代码块 |
| 304 | `&nbsp;` | 空行，分隔逻辑段落 |
| 305 | `  Map<String, String> _buildRuleVariables(Book book) {` | 定义方法 _构建 规则 变量表：返回 映射(Map)<字符串(String), 字符串(String)>；位置参数 1 个。语义：构建 规则 变量表 |
| 306 | `    final variables = <String, String>{};` | 声明不可重新赋值的变量 variables |
| 307 | `    book.variableMap.forEach((key, value) {` | 链式调用起始于 书籍.变量 映射（变量 映射），后续行继续该表达式：书籍.变量 映射.forEach((键, 值) { |
| 308 | `      variables[key] = value?.toString() ?? '';` | 调用 转为字符串(...)：variables[键] = 值?.转为字符串() ?? ''（to 字符串(字符串(String))） |
| 309 | `    });` | 闭合代码块并衔接后续语句：); |
| 310 | `    return variables;` | 返回 variables |
| 311 | `  }` | 闭合大括号，结束当前代码块 |
| 312 | `&nbsp;` | 空行，分隔逻辑段落 |
| 313 | `  String _repairChapterUrlWithBookVariables(String url, Book? book) {` | 定义方法 _repairChapterUrlWithBookVariables：返回 字符串(String)；位置参数 2 个；参数名: 链接。语义：修复 章节 统一资源链接(URL) With 书籍 变量表 |
| 314 | `    if (url.isEmpty \|\| book == null) return url;` | 条件判断 如果(if)：链接.是否为空 或 书籍 等于 空值(null)) 返回(return) 链接; |
| 315 | `&nbsp;` | 空行，分隔逻辑段落 |
| 316 | `    final bid = '${book.variableMap['bid'] ?? ''}'.trim();` | 声明不可重新赋值的变量 bid：字符串字面量 '${书籍.变量 映射['bid'] ?? ''}'.去除首尾空白(… |
| 317 | `    if (bid.isEmpty) return url;` | 条件判断 如果(if)：bid.是否为空) 返回(return) 链接; |
| 318 | `&nbsp;` | 空行，分隔逻辑段落 |
| 319 | `    return url.replaceAllMapped(` | 返回调用 链接.replaceAllMapped(...) 的结果（语义：替换 全部 Mapped） |
| 320 | `      RegExp(r'([?&]comic_id=)(?:null)?(?=&\|$)'),` | 构造函数 正则表达式(RegExp)位置参数 1 个；参数名: comic_id, 空值(null) |
| 321 | `      (match) => '${match.group(1)}$bid',` | 调用 捕获组(...)：(match) => '${match.捕获组(1)}$bid',（捕获组） |
| 322 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 323 | `  }` | 闭合大括号，结束当前代码块 |
| 324 | `&nbsp;` | 空行，分隔逻辑段落 |
| 325 | `  Future<List<Map<String, String?>>> _loadAjaxTocPages({` | 定义方法 _loadAjaxTocPages：返回 异步结果(Future)<列表(List)<映射(Map)<字符串(String), 字符串(String)?>>>；含命名参数（异步）。语义：加载 Ajax 目录(目录(TOC)) 分页 |
| 326 | `    required String tocUrl,` | 必填字符串(String) 类型参数 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 327 | `    required String firstPageHtml,` | 必填字符串(String) 类型参数 首个 页 HTML（首个 页 网页标记文本(HTML)） |
| 328 | `    required BookSource source,` | 必填书源(BookSource) 类型参数 书源（书源） |
| 329 | `    required Iterable<Map<String, String?>> seedChapters,` | 必填Iterable<映射(Map)<字符串(String), 字符串(String)?>> 类型参数 seedChapters（seed 章节列表） |
| 330 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 331 | `    if (!_supportsAjaxTocFallback(tocUrl, firstPageHtml)) {` | 条件判断 如果(if)：!_supportsAjaxTocFallback(目录(TOC) URL, 首个 页 HTML) |
| 332 | `      return const [];` | 返回 编译期常量(const) [] |
| 333 | `    }` | 闭合大括号，结束当前代码块 |
| 334 | `&nbsp;` | 空行，分隔逻辑段落 |
| 335 | `    final bookId = _extractAjaxTocBookId(firstPageHtml);` | 声明不可重新赋值的变量 书籍 编号(id)：调用 _extractAjaxTocBookId(...) → 提取 Ajax 目录(目录(TOC)) 书籍 编号(编号(id)) |
| 336 | `    if (bookId == null \|\| bookId.isEmpty) {` | 条件判断 如果(if)：书籍 编号(id) 等于 空值(null) 或 书籍 编号(id).是否为空 |
| 337 | `      return const [];` | 返回 编译期常量(const) [] |
| 338 | `    }` | 闭合大括号，结束当前代码块 |
| 339 | `&nbsp;` | 空行，分隔逻辑段落 |
| 340 | `    final ajaxUrl = NetworkService.joinUrl(` | 声明不可重新赋值的变量 ajaxUrl：调用 网络服务(NetworkService).拼接 URL(...) → 拼接 统一资源链接(URL) |
| 341 | `      tocUrl,` | 签名/调用续行参数：目录(TOC) URL |
| 342 | `      '/e/extend/bookpage/pages.php?id=$bookId',` | 以字符串 '/异常对象 e/extend/bookpage/pages.php?编号(id)=$书籍 编号(id)… 起始的表达式：, |
| 343 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 344 | `    final existingIdentities =` | 上一表达式的续行：不可重新赋值(final) existingIdentities = |
| 345 | `        seedChapters.map(_chapterIdentity).where((id) => id.isNotEmpty).toSet();` | 链式调用起始于 seedChapters（seed 章节列表），后续行继续该表达式：seedChapters.映射(map)(_chapterIdentity).筛选(where)((编号(id)) => 编号(id).是否非空).转为集合(… |
| 346 | `    final collected = <Map<String, String?>>[];` | 声明不可重新赋值的变量 collected |
| 347 | `&nbsp;` | 空行，分隔逻辑段落 |
| 348 | `    int? totalPages;` | 整数(int)? totalPages |
| 349 | `    int pageNum = 1;` | 整数(int) 页 编号 = 1 |
| 350 | `&nbsp;` | 空行，分隔逻辑段落 |
| 351 | `    while (pageNum < 100) {` | 当型循环(while) 循环，条件：页 编号 < 100 |
| 352 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 353 | `        final response = await _networkService.post(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.post(...) |
| 354 | `          ajaxUrl,` | 签名/调用续行参数：ajaxUrl |
| 355 | `          data: {'pageNum': pageNum},` | 命名实参 data: {'页 编号': 页 编号} |
| 356 | `          headers: {` | 命名实参 请求头: {（请求头） |
| 357 | `            ...NetworkService.parseHeaders(source.header),` | 链式调用起始于 ...网络服务(NetworkService)（Network 服务），后续行继续该表达式：...网络服务(NetworkService).解析 请求头(书源.请求头), |
| 358 | `            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',` | 映射(Map) 条目 '正文内容-类型': 'application/x-www-形态-urlencoded; 字符集=UTF-8', |
| 359 | `            'X-Requested-With': 'XMLHttpRequest',` | 映射(Map) 条目 'X-Requested-With': 'XML数据 超文本传输协议(HTTP) 请求', |
| 360 | `            'Referer': tocUrl,` | 映射(Map) 条目 'Referer': 目录(TOC) URL, |
| 361 | `          },` | 结束上一个列表/参数项 |
| 362 | `          retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 363 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 364 | `        final responseText = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 响应 文本：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 365 | `        if (responseText.isEmpty) {` | 条件判断 如果(if)：响应 文本.是否为空 |
| 366 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 367 | `        }` | 闭合大括号，结束当前代码块 |
| 368 | `&nbsp;` | 空行，分隔逻辑段落 |
| 369 | `        final data = jsonDecode(responseText);` | 声明不可重新赋值的变量 data：调用 JSON 解码(...) → JSON数据 解码 |
| 370 | `        if (data is! Map<String, dynamic>) {` | 条件判断 如果(if)：data 是(is)! 映射(Map) < 字符串(String), dynamic > |
| 371 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 372 | `        }` | 闭合大括号，结束当前代码块 |
| 373 | `&nbsp;` | 空行，分隔逻辑段落 |
| 374 | `        totalPages ??= int.tryParse('${data['totalPage'] ?? ''}');` | 调用 tryParse(...)：totalPages ??= 整数(int).tryParse('${data['totalPage'] ?? ''}')（尝试(try) 解析） |
| 375 | `        final list = data['list'];` | 声明不可重新赋值的变量 list |
| 376 | `        if (list is! List \|\| list.isEmpty) {` | 条件判断 如果(if)：list 是(is)! 列表(List) 或 list.是否为空 |
| 377 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 378 | `        }` | 闭合大括号，结束当前代码块 |
| 379 | `&nbsp;` | 空行，分隔逻辑段落 |
| 380 | `        final pageChapters = <Map<String, String?>>[];` | 声明不可重新赋值的变量 页 章节列表 |
| 381 | `        for (final item in list) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 条目 属于(in) list |
| 382 | `          if (item is! Map) continue;` | 条件判断 如果(if)：条目 是(is)! 映射(Map)) 继续(continue); |
| 383 | `          final title = '${item['title'] ?? ''}'.trim();` | 声明不可重新赋值的变量 标题：字符串字面量 '${条目['标题'] ?? ''}'.去除首尾空白(); |
| 384 | `          final rawUrl = '${item['pic'] ?? ''}'.trim();` | 声明不可重新赋值的变量 原始 URL：字符串字面量 '${条目['pic'] ?? ''}'.去除首尾空白(); |
| 385 | `          if (title.isEmpty \|\| rawUrl.isEmpty) continue;` | 条件判断 如果(if)：标题.是否为空 或 原始 URL.是否为空) 继续(continue); |
| 386 | `&nbsp;` | 空行，分隔逻辑段落 |
| 387 | `          final chapter = <String, String?>{` | 声明不可重新赋值的变量 章节 |
| 388 | `            'chapterName': title,` | 映射(Map) 条目 '章节 名称': 标题, |
| 389 | `            'chapterUrl': NetworkService.joinUrl(tocUrl, rawUrl),` | 映射(Map) 条目 '章节链接': 网络服务(NetworkService).拼接 URL(目录(TOC) URL, 原始 URL), |
| 390 | `            'isVip': '0',` | 映射(Map) 条目 'isVip': '0', |
| 391 | `            'isVolume': '0',` | 映射(Map) 条目 'isVolume': '0', |
| 392 | `            'updateTime': '',` | 映射(Map) 条目 'updateTime': '', |
| 393 | `            'nextTocUrl': '',` | 映射(Map) 条目 '下一页目录链接': '', |
| 394 | `          };` | 闭合代码块并衔接后续语句：; |
| 395 | `          final identity = _chapterIdentity(chapter);` | 声明不可重新赋值的变量 identity：调用 _chapterIdentity(...) → 章节 Identity |
| 396 | `          if (identity.isEmpty \|\| existingIdentities.contains(identity)) {` | 条件判断 如果(if)：identity.是否为空 或 existingIdentities.是否包含(identity) |
| 397 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 398 | `          }` | 闭合大括号，结束当前代码块 |
| 399 | `          existingIdentities.add(identity);` | 链式调用起始于 existingIdentities，后续行继续该表达式：existingIdentities.添加(identity); |
| 400 | `          pageChapters.add(chapter);` | 链式调用起始于 页 章节列表（页 章节列表），后续行继续该表达式：页 章节列表.添加(章节); |
| 401 | `        }` | 闭合大括号，结束当前代码块 |
| 402 | `&nbsp;` | 空行，分隔逻辑段落 |
| 403 | `        if (pageChapters.isEmpty) {` | 条件判断 如果(if)：页 章节列表.是否为空 |
| 404 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 405 | `        }` | 闭合大括号，结束当前代码块 |
| 406 | `&nbsp;` | 空行，分隔逻辑段落 |
| 407 | `        collected.addAll(pageChapters);` | 链式调用起始于 collected，后续行继续该表达式：collected.批量添加(页 章节列表); |
| 408 | `        pageNum++;` | 页 编号++ |
| 409 | `&nbsp;` | 空行，分隔逻辑段落 |
| 410 | `        if (totalPages != null && pageNum >= totalPages) {` | 条件判断 如果(if)：totalPages 不等于 空值(null) 且 页 编号 > = totalPages |
| 411 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 412 | `        }` | 闭合大括号，结束当前代码块 |
| 413 | `      } catch (_) {` | 闭合 尝试(try) 块并捕获异常（忽略异常对象） |
| 414 | `        break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 415 | `      }` | 闭合大括号，结束当前代码块 |
| 416 | `    }` | 闭合大括号，结束当前代码块 |
| 417 | `&nbsp;` | 空行，分隔逻辑段落 |
| 418 | `    if (collected.isNotEmpty) {` | 条件判断 如果(if)：collected.是否非空 |
| 419 | `      AppLog.instance.put('目录AJAX分页补全成功: 新增 ${collected.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('目录AJAX分页补全成功: 新增 ${collected.length} 个章节'); |
| 420 | `    }` | 闭合大括号，结束当前代码块 |
| 421 | `&nbsp;` | 空行，分隔逻辑段落 |
| 422 | `    return collected;` | 返回 collected |
| 423 | `  }` | 闭合大括号，结束当前代码块 |
| 424 | `&nbsp;` | 空行，分隔逻辑段落 |
| 425 | `  /// 从单个书源搜索书籍` | 文档注释：说明其后代码的用途 |
| 426 | `  /// 供SearchModel使用` | 文档注释：说明其后代码的用途 |
| 427 | `  Future<List<Book>> searchBooksFromSource(` | 【承接上方文档】从单个书源搜索书籍 供SearchModel使用 → 定义方法 searchBooksFromSource：返回 异步结果(Future)<列表(List)<书籍(Book)>>；无参数（异步）。语义：搜索 书籍列表 From 书源 |
| 428 | `    BookSource source,` | 书源(BookSource) 类型参数 书源（书源） |
| 429 | `    String keyword,` | 字符串(String) 类型参数 关键词（关键词） |
| 430 | `    bool precisionSearch,` | 布尔(bool) 类型参数 精确搜索开关（精确度 搜索） |
| 431 | `  ) async {` | ) 异步(async) { |
| 432 | `    final results = <Book>[];` | 声明不可重新赋值的变量 结果 |
| 433 | `&nbsp;` | 空行，分隔逻辑段落 |
| 434 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 435 | `      await ConcurrentRateLimiter(source).withLimit(() async {` | 调用 ConcurrentRateLimiter(...)（等待异步完成） → 并发 速率 Limiter |
| 436 | `        final searchUrl = _buildSearchUrl(source.searchUrl!, keyword);` | 声明不可重新赋值的变量 搜索链接：调用 _构建 搜索 URL(...) → 构建 搜索 统一资源链接(URL) |
| 437 | `        final fullUrl = NetworkService.joinUrl(source.bookSourceUrl, searchUrl);` | 声明不可重新赋值的变量 fullUrl：调用 网络服务(NetworkService).拼接 URL(...) → 拼接 统一资源链接(URL) |
| 438 | `&nbsp;` | 空行，分隔逻辑段落 |
| 439 | `        final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 440 | `          fullUrl,` | 签名/调用续行参数：fullUrl |
| 441 | `          headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 442 | `          retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 443 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 444 | `&nbsp;` | 空行，分隔逻辑段落 |
| 445 | `        final html = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 网页内容：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 446 | `        final searchResults = await RuleParser.parseSearchRule(` | 声明不可重新赋值的变量 搜索 结果：等待(await) 调用 规则解析器(RuleParser).解析 搜索 规则(...) → 解析 搜索 规则 |
| 447 | `          html,` | 签名/调用续行参数：网页内容 |
| 448 | `          source.ruleSearch,` | 签名/调用续行参数：书源.搜索规则 |
| 449 | `          variables: {'keyword': keyword},` | 命名实参 variables: {'关键词': 关键词}（变量表） |
| 450 | `          baseUrl: fullUrl,` | 命名实参 基础链接: fullUrl（base 统一资源链接(URL)） |
| 451 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 452 | `&nbsp;` | 空行，分隔逻辑段落 |
| 453 | `        for (final result in searchResults) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 结果 属于(in) 搜索 结果 |
| 454 | `          final bookUrl = result['bookUrl'];` | 声明不可重新赋值的变量 书籍链接 |
| 455 | `          if (bookUrl == null \|\| bookUrl.isEmpty) continue;` | 条件判断 如果(if)：书籍链接 等于 空值(null) 或 书籍链接.是否为空) 继续(continue); |
| 456 | `&nbsp;` | 空行，分隔逻辑段落 |
| 457 | `          if (source.ruleSearch?.checkKeyWord != null &&` | 条件判断 如果(if)：书源.搜索规则?.校验关键词 不等于 空值(null) 且 |
| 458 | `              source.ruleSearch!.checkKeyWord!.isNotEmpty) {` | 书源.搜索规则!.校验关键词!.是否非空) { |
| 459 | `            final checkKeyWordValue = result['checkKeyWord'];` | 声明不可重新赋值的变量 检查 键 单词 值 |
| 460 | `            if (checkKeyWordValue == null \|\| checkKeyWordValue.isEmpty) {` | 条件判断 如果(if)：检查 键 单词 值 等于 空值(null) 或 检查 键 单词 值.是否为空 |
| 461 | `              continue;` | 继续(continue)：进入下一次循环迭代 |
| 462 | `            }` | 闭合大括号，结束当前代码块 |
| 463 | `          }` | 闭合大括号，结束当前代码块 |
| 464 | `&nbsp;` | 空行，分隔逻辑段落 |
| 465 | `          final finalBookUrl =` | 上一表达式的续行：不可重新赋值(final) finalBookUrl = |
| 466 | `              bookUrl.startsWith('http://') \|\| bookUrl.startsWith('https://')` | 链式调用起始于 书籍链接（书籍 统一资源链接(URL)），后续行继续该表达式：书籍链接.startsWith('超文本传输协议(HTTP)://') \|\| 书籍链接.startsWith('安全超文本传输协议(HTTPS)://') |
| 467 | `                  ? bookUrl` | 上一表达式的续行：? 书籍链接 |
| 468 | `                  : NetworkService.joinUrl(source.bookSourceUrl, bookUrl);` | 三元表达式为假时取值：网络服务(NetworkService).拼接 URL(书源.书源链接, 书籍链接); |
| 469 | `&nbsp;` | 空行，分隔逻辑段落 |
| 470 | `          final book = Book(` | 声明不可重新赋值的变量 书籍：调用 书籍(Book)(...) → 书籍 |
| 471 | `            bookUrl: finalBookUrl,` | 命名实参 书籍链接: finalBookUrl（书籍 统一资源链接(URL)） |
| 472 | `            origin: source.bookSourceUrl,` | 命名实参 来源: 书源.书源链接（来源） |
| 473 | `            originName: source.bookSourceName,` | 命名实参 来源 名称: 书源.书籍 书源 名称（来源 名称） |
| 474 | `            name: result['name'] ?? '',` | 命名实参 名称: 结果['名称'] ?? ''（名称） |
| 475 | `            author: result['author'] ?? '',` | 命名实参 作者: 结果['作者'] ?? ''（作者） |
| 476 | `            kind: result['kind'],` | 命名实参 类别: 结果['类别']（类别） |
| 477 | `            coverUrl: result['coverUrl'],` | 命名实参 封面链接: 结果['封面链接']（封面 统一资源链接(URL)） |
| 478 | `            intro: result['intro'],` | 命名实参 简介: 结果['简介']（简介） |
| 479 | `            wordCount: result['wordCount'],` | 命名实参 字数: 结果['字数']（单词 数量） |
| 480 | `            latestChapterTitle: result['lastChapter'],` | 命名实参 latestChapterTitle: 结果['最后 章节']（latest 章节 标题） |
| 481 | `            canUpdate: true,` | 命名实参 canUpdate: 真(true)（can 更新） |
| 482 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 483 | `&nbsp;` | 空行，分隔逻辑段落 |
| 484 | `          if (precisionSearch) {` | 条件判断 如果(if)：精确搜索开关 |
| 485 | `            final keywordLower = keyword.toLowerCase();` | 声明不可重新赋值的变量 keywordLower |
| 486 | `            final nameLower = book.name.toLowerCase();` | 声明不可重新赋值的变量 nameLower |
| 487 | `            final authorLower = book.author.toLowerCase();` | 声明不可重新赋值的变量 authorLower |
| 488 | `&nbsp;` | 空行，分隔逻辑段落 |
| 489 | `            if (nameLower != keywordLower &&` | 条件判断 如果(if)：nameLower 不等于 keywordLower 且 |
| 490 | `                authorLower != keywordLower &&` | 上一表达式的续行：authorLower != keywordLower && |
| 491 | `                !(nameLower.contains(keywordLower) &&` | 调用 是否包含(...)：!(nameLower.是否包含(keywordLower) &&（是否包含） |
| 492 | `                    authorLower.contains(keywordLower))) {` | 链式调用起始于 authorLower（作者 Lower），后续行继续该表达式：authorLower.是否包含(keywordLower))) { |
| 493 | `              continue;` | 继续(continue)：进入下一次循环迭代 |
| 494 | `            }` | 闭合大括号，结束当前代码块 |
| 495 | `          }` | 闭合大括号，结束当前代码块 |
| 496 | `&nbsp;` | 空行，分隔逻辑段落 |
| 497 | `          results.add(book);` | 链式调用起始于 结果（结果），后续行继续该表达式：结果.添加(书籍); |
| 498 | `        }` | 闭合大括号，结束当前代码块 |
| 499 | `      });` | 闭合代码块并衔接后续语句：); |
| 500 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 501 | `      AppLog.instance.put('书源搜索失败: ${source.bookSourceName}', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('书源搜索失败: ${source.bookSourceName}', error: e); |
| 502 | `    }` | 闭合大括号，结束当前代码块 |
| 503 | `&nbsp;` | 空行，分隔逻辑段落 |
| 504 | `    return results;` | 返回 结果 |
| 505 | `  }` | 闭合大括号，结束当前代码块 |
| 506 | `&nbsp;` | 空行，分隔逻辑段落 |
| 507 | `  /// 搜索书籍` | 文档注释：说明其后代码的用途 |
| 508 | `  Future<List<Book>> searchBooks(` | 【承接上方文档】搜索书籍 → 定义方法 搜索 书籍列表：返回 异步结果(Future)<列表(List)<书籍(Book)>>；无参数（异步）。语义：搜索 书籍列表 |
| 509 | `    String keyword, {` | 字符串(String) 类型参数 关键词，其后 { 开启命名参数块（关键词） |
| 510 | `    List<BookSource>? sources,` | 列表(List)<书源(BookSource)>? 类型参数 书源列表（书源列表） |
| 511 | `    bool precisionSearch = false,` | 布尔(bool) 类型参数 精确搜索开关，默认值 假(false)（精确度 搜索） |
| 512 | `    Function(int current, int total)? onProgress,` | 构造函数 函数位置参数 2 个；参数名: 当前, total, onProgress |
| 513 | `    Function(Book book)? onResult, // 新增：找到结果时的回调` | 构造函数 函数位置参数 1 个；参数名: 书籍, onResult；行尾注释：新增：找到结果时的回调 |
| 514 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 515 | `    if (keyword.isEmpty) return [];` | 条件判断 如果(if)：关键词.是否为空) 返回(return) []; |
| 516 | `&nbsp;` | 空行，分隔逻辑段落 |
| 517 | `    // 如果没有指定书源，获取所有启用的书源` | 注释说明：如果没有指定书源，获取所有启用的书源 |
| 518 | `    sources ??= await _bookSourceService.getAllBookSources(enabledOnly: true);` | 调用 获取 全部 书籍 书源列表(...)：书源列表 ??= 等待(await) _书籍 书源 服务.获取 全部 书籍 书源列表(enabledOnly: 真(true))（获取 全部 书籍 书源列表） |
| 519 | `&nbsp;` | 空行，分隔逻辑段落 |
| 520 | `    // 过滤出有效的书源（启用且有搜索规则）` | 注释说明：过滤出有效的书源（启用且有搜索规则） |
| 521 | `    final validSources = sources.where((source) {` | 声明不可重新赋值的变量 有效 书源列表：调用 书源列表.筛选(where)(...) → 筛选(筛选(where)) |
| 522 | `      return source.enabled &&` | 上一表达式的续行：返回(return) 书源.已启用 && |
| 523 | `          source.searchUrl != null &&` | 上一表达式的续行：书源.搜索链接 != 空值(null) && |
| 524 | `          source.ruleSearch != null;` | 书源.搜索规则 != 空值(null) |
| 525 | `    }).toList();` | 闭合代码块并衔接后续语句：).转为列表(); |
| 526 | `&nbsp;` | 空行，分隔逻辑段落 |
| 527 | `    final totalSources = validSources.length;` | 声明不可重新赋值的变量 totalSources |
| 528 | `    final results = <Book>[];` | 声明不可重新赋值的变量 结果 |
| 529 | `    int currentIndex = 0;` | 整数(int) 当前 索引 = 0 |
| 530 | `&nbsp;` | 空行，分隔逻辑段落 |
| 531 | `    for (final source in validSources) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 书源 属于(in) 有效 书源列表 |
| 532 | `      currentIndex++;` | 当前 索引++ |
| 533 | `&nbsp;` | 空行，分隔逻辑段落 |
| 534 | `      // 报告进度` | 注释说明：报告进度 |
| 535 | `      if (onProgress != null) {` | 条件判断 如果(if)：onProgress 不等于 空值(null) |
| 536 | `        onProgress(currentIndex, totalSources);` | 调用 onProgress(...)：onProgress(当前 索引, totalSources)（on 进度） |
| 537 | `      }` | 闭合大括号，结束当前代码块 |
| 538 | `&nbsp;` | 空行，分隔逻辑段落 |
| 539 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 540 | `        // 使用并发限流器（参考项目：ConcurrentRateLimiter）` | 注释说明：使用并发限流器（参考项目：ConcurrentRateLimiter） |
| 541 | `        await ConcurrentRateLimiter(source).withLimit(() async {` | 调用 ConcurrentRateLimiter(...)（等待异步完成） → 并发 速率 Limiter |
| 542 | `          // 构建搜索URL（替换关键字）` | 注释说明：构建搜索统一资源链接(URL)（替换关键字） |
| 543 | `          final searchUrl = _buildSearchUrl(source.searchUrl!, keyword);` | 声明不可重新赋值的变量 搜索链接：调用 _构建 搜索 URL(...) → 构建 搜索 统一资源链接(URL) |
| 544 | `          // 构建完整URL（处理相对路径）` | 注释说明：构建完整统一资源链接(URL)（处理相对路径） |
| 545 | `          final fullUrl =` | 上一表达式的续行：不可重新赋值(final) fullUrl = |
| 546 | `              NetworkService.joinUrl(source.bookSourceUrl, searchUrl);` | 链式调用起始于 网络服务(NetworkService)（Network 服务），后续行继续该表达式：网络服务(NetworkService).拼接 URL(书源.书源链接, 搜索链接); |
| 547 | `&nbsp;` | 空行，分隔逻辑段落 |
| 548 | `          // 使用协议处理器发送请求（支持HTTP/JSON/WebView）` | 注释说明：使用协议处理器发送请求（支持超文本传输协议(HTTP)/JSON数据/WebView） |
| 549 | `          final responseText = await _request(` | 声明不可重新赋值的变量 响应 文本：等待(await) 调用 _请求(...) → 请求 |
| 550 | `            fullUrl,` | 签名/调用续行参数：fullUrl |
| 551 | `            source,` | 签名/调用续行参数：书源 |
| 552 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 553 | `&nbsp;` | 空行，分隔逻辑段落 |
| 554 | `          final html = responseText;` | 声明不可重新赋值的变量 网页内容 |
| 555 | `          AppLog.instance.put('搜索响应: 内容长度=${html.length}, URL=$fullUrl');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('搜索响应: 内容长度=${html.length}, URL=$fullUrl'); |
| 556 | `&nbsp;` | 空行，分隔逻辑段落 |
| 557 | `          // 输出响应内容的前500个字符用于调试` | 注释说明：输出响应内容的前500个字符用于调试 |
| 558 | `          if (html.isNotEmpty) {` | 条件判断 如果(if)：网页内容.是否非空 |
| 559 | `            final preview =` | 上一表达式的续行：不可重新赋值(final) preview = |
| 560 | `                html.length > 500 ? '${html.substring(0, 500)}...' : html;` | 调用 substring(...)：网页内容.长度(length) > 500 ? '${网页内容.substring(0, 500)}...' : 网页内容 |
| 561 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 562 | `                '搜索响应内容预览 (前${html.length > 500 ? 500 : html.length}字符):\n$preview');` | 以字符串 '搜索响应内容预览 (前${html.length > 500 ? 500 : … 起始的表达式：); |
| 563 | `          }` | 闭合大括号，结束当前代码块 |
| 564 | `&nbsp;` | 空行，分隔逻辑段落 |
| 565 | `          // 解析搜索结果` | 注释说明：解析搜索结果 |
| 566 | `          // 使用实际请求的URL作为baseUrl（参考项目中的做法）` | 注释说明：使用实际请求的统一资源链接(URL)作为基础链接（参考项目中的做法） |
| 567 | `          final searchResults = await RuleParser.parseSearchRule(` | 声明不可重新赋值的变量 搜索 结果：等待(await) 调用 规则解析器(RuleParser).解析 搜索 规则(...) → 解析 搜索 规则 |
| 568 | `            html,` | 签名/调用续行参数：网页内容 |
| 569 | `            source.ruleSearch,` | 签名/调用续行参数：书源.搜索规则 |
| 570 | `            variables: {'keyword': keyword},` | 命名实参 variables: {'关键词': 关键词}（变量表） |
| 571 | `            baseUrl: fullUrl, // 使用实际请求的URL，而不是书源的基础URL` | 命名实参 基础链接: fullUrl（base 统一资源链接(URL)）；行尾注释：使用实际请求的统一资源链接(URL)，而不是书源的基础统一资源链接(URL) |
| 572 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 573 | `&nbsp;` | 空行，分隔逻辑段落 |
| 574 | `          // 转换为Book对象` | 注释说明：转换为书籍(Book)对象 |
| 575 | `          for (final result in searchResults) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 结果 属于(in) 搜索 结果 |
| 576 | `            final bookUrl = result['bookUrl'];` | 声明不可重新赋值的变量 书籍链接 |
| 577 | `            if (bookUrl == null \|\| bookUrl.isEmpty) continue;` | 条件判断 如果(if)：书籍链接 等于 空值(null) 或 书籍链接.是否为空) 继续(continue); |
| 578 | `&nbsp;` | 空行，分隔逻辑段落 |
| 579 | `            // 检查 checkKeyWord 规则（如果存在）` | 注释说明：检查 校验关键词 规则（如果存在） |
| 580 | `            // 参考项目：checkKeyWord 用于验证搜索结果是否包含关键词` | 注释说明：参考项目：校验关键词 用于验证搜索结果是否包含关键词 |
| 581 | `            // 如果规则存在且解析结果为空，说明搜索结果无效，跳过` | 注释说明：如果规则存在且解析结果为空，说明搜索结果无效，跳过 |
| 582 | `            if (source.ruleSearch?.checkKeyWord != null &&` | 条件判断 如果(if)：书源.搜索规则?.校验关键词 不等于 空值(null) 且 |
| 583 | `                source.ruleSearch!.checkKeyWord!.isNotEmpty) {` | 书源.搜索规则!.校验关键词!.是否非空) { |
| 584 | `              final checkKeyWordValue = result['checkKeyWord'];` | 声明不可重新赋值的变量 检查 键 单词 值 |
| 585 | `              // 如果 checkKeyWord 规则存在但解析结果为空，说明搜索结果不匹配，跳过` | 注释说明：如果 校验关键词 规则存在但解析结果为空，说明搜索结果不匹配，跳过 |
| 586 | `              if (checkKeyWordValue == null \|\| checkKeyWordValue.isEmpty) {` | 条件判断 如果(if)：检查 键 单词 值 等于 空值(null) 或 检查 键 单词 值.是否为空 |
| 587 | `                AppLog.instance.put('搜索结果未通过checkKeyWord验证，跳过');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('搜索结果未通过checkKeyWord验证，跳过'); |
| 588 | `                continue;` | 继续(continue)：进入下一次循环迭代 |
| 589 | `              }` | 闭合大括号，结束当前代码块 |
| 590 | `            }` | 闭合大括号，结束当前代码块 |
| 591 | `&nbsp;` | 空行，分隔逻辑段落 |
| 592 | `            // 如果bookUrl已经是绝对URL，直接使用；否则相对于书源URL处理` | 注释说明：如果书籍链接已经是绝对统一资源链接(URL)，直接使用；否则相对于书源统一资源链接(URL)处理 |
| 593 | `            final finalBookUrl =` | 上一表达式的续行：不可重新赋值(final) finalBookUrl = |
| 594 | `                bookUrl.startsWith('http://') \|\| bookUrl.startsWith('https://')` | 链式调用起始于 书籍链接（书籍 统一资源链接(URL)），后续行继续该表达式：书籍链接.startsWith('超文本传输协议(HTTP)://') \|\| 书籍链接.startsWith('安全超文本传输协议(HTTPS)://') |
| 595 | `                    ? bookUrl` | 上一表达式的续行：? 书籍链接 |
| 596 | `                    : NetworkService.joinUrl(source.bookSourceUrl, bookUrl);` | 三元表达式为假时取值：网络服务(NetworkService).拼接 URL(书源.书源链接, 书籍链接); |
| 597 | `&nbsp;` | 空行，分隔逻辑段落 |
| 598 | `            final kindValue = result['kind'];` | 声明不可重新赋值的变量 类别 值 |
| 599 | `            // 添加调试日志（仅前3个结果）` | 注释说明：添加调试日志（仅前3个结果） |
| 600 | `            if (results.length < 3) {` | 条件判断 如果(if)：结果.长度(length) < 3 |
| 601 | `              AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 602 | `                  'searchBooks: 创建Book对象 - name=${result['name']}, author=${result['author']}, kind=$kindValue, kind规则=${source.ruleSearch?.kind}');` | 以字符串 '搜索 书籍列表: 创建书籍(Book)对象 - 名称=${结果[' 起始的表达式：名称']}, 作者=${结果['作者']}, 类别=$类别 值, 类别规则… |
| 603 | `            }` | 闭合大括号，结束当前代码块 |
| 604 | `&nbsp;` | 空行，分隔逻辑段落 |
| 605 | `            final book = Book(` | 声明不可重新赋值的变量 书籍：调用 书籍(Book)(...) → 书籍 |
| 606 | `              bookUrl: finalBookUrl,` | 命名实参 书籍链接: finalBookUrl（书籍 统一资源链接(URL)） |
| 607 | `              origin: source.bookSourceUrl,` | 命名实参 来源: 书源.书源链接（来源） |
| 608 | `              originName: source.bookSourceName,` | 命名实参 来源 名称: 书源.书籍 书源 名称（来源 名称） |
| 609 | `              name: result['name'] ?? '',` | 命名实参 名称: 结果['名称'] ?? ''（名称） |
| 610 | `              author: result['author'] ?? '',` | 命名实参 作者: 结果['作者'] ?? ''（作者） |
| 611 | `              kind: kindValue,` | 命名实参 类别: 类别 值（类别） |
| 612 | `              // coverUrl已经在parseRule中使用实际请求的URL（fullUrl）作为baseUrl处理过了` | 注释说明：封面链接已经在解析 规则中使用实际请求的统一资源链接(URL)（fullUrl）作为基础链接处理过了 |
| 613 | `              // 参考项目中，封面URL使用当前页面URL作为baseUrl，parseRule已经处理` | 注释说明：参考项目中，封面统一资源链接(URL)使用当前页面统一资源链接(URL)作为基础链接，解析 规则已经处理 |
| 614 | `              coverUrl: result['coverUrl'],` | 命名实参 封面链接: 结果['封面链接']（封面 统一资源链接(URL)） |
| 615 | `              intro: result['intro'],` | 命名实参 简介: 结果['简介']（简介） |
| 616 | `              wordCount: result['wordCount'],` | 命名实参 字数: 结果['字数']（单词 数量） |
| 617 | `              latestChapterTitle: result['lastChapter'],` | 命名实参 latestChapterTitle: 结果['最后 章节']（latest 章节 标题） |
| 618 | `              canUpdate: true,` | 命名实参 canUpdate: 真(true)（can 更新） |
| 619 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 620 | `&nbsp;` | 空行，分隔逻辑段落 |
| 621 | `            // 精确搜索模式：只保留书名或作者完全匹配的结果` | 注释说明：精确搜索模式：只保留书名或作者完全匹配的结果 |
| 622 | `            if (precisionSearch) {` | 条件判断 如果(if)：精确搜索开关 |
| 623 | `              final keywordLower = keyword.toLowerCase();` | 声明不可重新赋值的变量 keywordLower |
| 624 | `              final nameLower = book.name.toLowerCase();` | 声明不可重新赋值的变量 nameLower |
| 625 | `              final authorLower = book.author.toLowerCase();` | 声明不可重新赋值的变量 authorLower |
| 626 | `&nbsp;` | 空行，分隔逻辑段落 |
| 627 | `              if (nameLower != keywordLower &&` | 条件判断 如果(if)：nameLower 不等于 keywordLower 且 |
| 628 | `                  authorLower != keywordLower &&` | 上一表达式的续行：authorLower != keywordLower && |
| 629 | `                  !(nameLower.contains(keywordLower) &&` | 调用 是否包含(...)：!(nameLower.是否包含(keywordLower) &&（是否包含） |
| 630 | `                      authorLower.contains(keywordLower))) {` | 链式调用起始于 authorLower（作者 Lower），后续行继续该表达式：authorLower.是否包含(keywordLower))) { |
| 631 | `                continue; // 跳过不匹配的结果` | 继续(continue)：进入下一次循环迭代；行尾注释：跳过不匹配的结果 |
| 632 | `              }` | 闭合大括号，结束当前代码块 |
| 633 | `            }` | 闭合大括号，结束当前代码块 |
| 634 | `&nbsp;` | 空行，分隔逻辑段落 |
| 635 | `            results.add(book);` | 链式调用起始于 结果（结果），后续行继续该表达式：结果.添加(书籍); |
| 636 | `&nbsp;` | 空行，分隔逻辑段落 |
| 637 | `            // 立即回调新结果` | 注释说明：立即回调新结果 |
| 638 | `            if (onResult != null) {` | 条件判断 如果(if)：onResult 不等于 空值(null) |
| 639 | `              onResult(book);` | 调用 onResult(...)：onResult(书籍)（on 结果） |
| 640 | `            }` | 闭合大括号，结束当前代码块 |
| 641 | `          }` | 闭合大括号，结束当前代码块 |
| 642 | `        });` | 闭合代码块并衔接后续语句：); |
| 643 | `      } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 644 | `        // 搜索失败，记录日志并继续下一个书源` | 注释说明：搜索失败，记录日志并继续下一个书源 |
| 645 | `        AppLog.instance.put('书源搜索失败: ${source.bookSourceName}', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('书源搜索失败: ${source.bookSourceName}', error: e); |
| 646 | `        continue;` | 继续(continue)：进入下一次循环迭代 |
| 647 | `      }` | 闭合大括号，结束当前代码块 |
| 648 | `    }` | 闭合大括号，结束当前代码块 |
| 649 | `&nbsp;` | 空行，分隔逻辑段落 |
| 650 | `    return results;` | 返回 结果 |
| 651 | `  }` | 闭合大括号，结束当前代码块 |
| 652 | `&nbsp;` | 空行，分隔逻辑段落 |
| 653 | `  /// 获取书籍详情` | 文档注释：说明其后代码的用途 |
| 654 | `  Future<Book?> getBookInfo(Book book) async {` | 【承接上方文档】获取书籍详情 → 定义方法 getBookInfo：返回 异步结果(Future)<书籍(Book)?>；位置参数 1 个；含命名参数；参数名: 书籍（异步）。语义：获取 书籍 Info |
| 655 | `    if (book.isLocal) {` | 条件判断 如果(if)：书籍.isLocal |
| 656 | `      // 本地书籍不需要获取详情` | 注释说明：本地书籍不需要获取详情 |
| 657 | `      return book;` | 返回 书籍 |
| 658 | `    }` | 闭合大括号，结束当前代码块 |
| 659 | `&nbsp;` | 空行，分隔逻辑段落 |
| 660 | `    final source = await _bookSourceService.getBookSourceByUrl(book.origin);` | 声明不可重新赋值的变量 书源：等待(await) 调用 _书籍 书源 服务.getBookSourceByUrl(...) → 获取 书籍 书源 By 统一资源链接(URL) |
| 661 | `    if (source == null \|\| source.ruleBookInfo == null) {` | 条件判断 如果(if)：书源 等于 空值(null) 或 书源.书籍详情规则 等于 空值(null) |
| 662 | `      AppLog.instance.put('getBookInfo: 书源不存在或详情规则为空');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('getBookInfo: 书源不存在或详情规则为空'); |
| 663 | `      return book;` | 返回 书籍 |
| 664 | `    }` | 闭合大括号，结束当前代码块 |
| 665 | `&nbsp;` | 空行，分隔逻辑段落 |
| 666 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 667 | `      AppLog.instance.put('getBookInfo: 开始获取书籍详情，bookUrl=${book.bookUrl}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('getBookInfo: 开始获取书籍详情，bookUrl=${book.bookUrl}'); |
| 668 | `&nbsp;` | 空行，分隔逻辑段落 |
| 669 | `      // 使用并发限流器（参考项目：ConcurrentRateLimiter）` | 注释说明：使用并发限流器（参考项目：ConcurrentRateLimiter） |
| 670 | `      final updatedBook =` | 上一表达式的续行：不可重新赋值(final) 已更新 书籍 = |
| 671 | `          await ConcurrentRateLimiter(source).withLimit(() async {` | 调用 ConcurrentRateLimiter(...)（等待异步完成） → 并发 速率 Limiter |
| 672 | `        String html = '';` | 字符串(String) 网页内容 = '' |
| 673 | `        bool usedCachedInfoHtml = false;` | 布尔(bool) usedCachedInfoHtml = 假(false) |
| 674 | `&nbsp;` | 空行，分隔逻辑段落 |
| 675 | `        if (book.infoHtml != null && book.infoHtml!.isNotEmpty) {` | 条件判断 如果(if)：书籍.infoHtml 不等于 空值(null) 且 书籍.infoHtml!.是否非空 |
| 676 | `          html = book.infoHtml!;` | 将 书籍.infoHtml! 赋值给 网页内容 |
| 677 | `          usedCachedInfoHtml = true;` | 将 真(true) 赋值给 usedCachedInfoHtml |
| 678 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 679 | `            'getBookInfo: 使用列表页透传HTML，内容长度=${html.length}, URL=${book.bookUrl}',` | 以字符串 'getBookInfo: 使用列表页透传网页标记文本(HTML)，内容长度=${网页内容.le… 起始的表达式：, |
| 680 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 681 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 682 | `          html = await _fetchBookInfoHtml(book, source);` | 将 等待异步结果：等待(await) _fetchBookInfoHtml(书籍, 书源) 赋值给 网页内容（调用 _fetchBookInfoHtml → 拉取 书籍 Info 网页标记文本(HTML)） |
| 683 | `        }` | 闭合大括号，结束当前代码块 |
| 684 | `&nbsp;` | 空行，分隔逻辑段落 |
| 685 | `        var bookInfo = await RuleParser.parseBookInfoRule(` | 声明自动类型推断的变量 bookInfo：等待(await) 调用 规则解析器(RuleParser).parseBookInfoRule(...) → 解析 书籍 Info 规则 |
| 686 | `          html,` | 签名/调用续行参数：网页内容 |
| 687 | `          source.ruleBookInfo,` | 签名/调用续行参数：书源.书籍详情规则 |
| 688 | `          baseUrl: book.bookUrl,` | 命名实参 基础链接: 书籍.书籍链接（base 统一资源链接(URL)） |
| 689 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 690 | `&nbsp;` | 空行，分隔逻辑段落 |
| 691 | `        if (usedCachedInfoHtml && !_hasMeaningfulBookInfo(bookInfo)) {` | 条件判断 如果(if)：usedCachedInfoHtml 且 !_hasMeaningfulBookInfo(bookInfo) |
| 692 | `          AppLog.instance.put('getBookInfo: 透传HTML未命中详情规则，回退网络请求');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('getBookInfo: 透传HTML未命中详情规则，回退网络请求'); |
| 693 | `          html = await _fetchBookInfoHtml(book, source);` | 将 等待异步结果：等待(await) _fetchBookInfoHtml(书籍, 书源) 赋值给 网页内容（调用 _fetchBookInfoHtml → 拉取 书籍 Info 网页标记文本(HTML)） |
| 694 | `          bookInfo = await RuleParser.parseBookInfoRule(` | 将 等待异步结果：等待(await) 规则解析器(RuleParser).parseBookInfoRule( 赋值给 bookInfo（调用 parseBookInfoRule → 解析 书籍 Info 规则） |
| 695 | `            html,` | 签名/调用续行参数：网页内容 |
| 696 | `            source.ruleBookInfo,` | 签名/调用续行参数：书源.书籍详情规则 |
| 697 | `            baseUrl: book.bookUrl,` | 命名实参 基础链接: 书籍.书籍链接（base 统一资源链接(URL)） |
| 698 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 699 | `        }` | 闭合大括号，结束当前代码块 |
| 700 | `&nbsp;` | 空行，分隔逻辑段落 |
| 701 | `        // 更新书籍信息` | 注释说明：更新书籍信息 |
| 702 | `        final newTocUrl = bookInfo['tocUrl'] != null` | 上一表达式的续行：不可重新赋值(final) newTocUrl = bookInfo['目录(TOC) URL'] != 空值(null) |
| 703 | `            ? NetworkService.joinUrl(source.bookSourceUrl, bookInfo['tocUrl']!)` | 三元表达式为真时取值：网络服务(NetworkService).拼接 URL(书源.书源链接, bookInfo['目录(TOC) URL']!) |
| 704 | `            : book.tocUrl;` | 三元表达式为假时取值：书籍.目录(TOC) URL; |
| 705 | `&nbsp;` | 空行，分隔逻辑段落 |
| 706 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 707 | `            'getBookInfo: 解析结果 - name=${bookInfo['name']}, author=${bookInfo['author']}, kind=${bookInfo['kind']}, tocUrl=${bookInfo['tocUrl']}, 最终tocUrl=$newTocUrl');` | 以字符串 'getBookInfo: 解析结果 - 名称=${bookInfo[' 起始的表达式：名称']}, 作者=${bookInfo['作者']}, 类别=${bookInfo['类别… |
| 708 | `&nbsp;` | 空行，分隔逻辑段落 |
| 709 | `        // 处理 canReName（如果可以重命名，存储到 variable 中）` | 注释说明：处理 canReName（如果可以重命名，存储到 variable 中） |
| 710 | `        String? updatedVariable = book.variable;` | 字符串(String)? 已更新 变量 = 书籍.variable |
| 711 | `        final canReNameValue = bookInfo['canReName'];` | 声明不可重新赋值的变量 canReNameValue |
| 712 | `        if (canReNameValue != null && canReNameValue.isNotEmpty) {` | 条件判断 如果(if)：canReNameValue 不等于 空值(null) 且 canReNameValue.是否非空 |
| 713 | `          // 将 canReName 存储到 variable JSON 中` | 注释说明：将 canReName 存储到 variable JSON数据 中 |
| 714 | `          try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 715 | `            final variableMap = <String, dynamic>{};` | 声明不可重新赋值的变量 变量 映射 |
| 716 | `            if (updatedVariable != null && updatedVariable.isNotEmpty) {` | 条件判断 如果(if)：已更新 变量 不等于 空值(null) 且 已更新 变量.是否非空 |
| 717 | `              final decoded =` | 上一表达式的续行：不可重新赋值(final) decoded = |
| 718 | `                  jsonDecode(updatedVariable) as Map<String, dynamic>?;` | 调用 JSON 解码(...)：JSON 解码(已更新 变量) 作为(as) 映射(Map)<字符串(String), dynamic>?（JSON数据 解码） |
| 719 | `              if (decoded != null) {` | 条件判断 如果(if)：decoded 不等于 空值(null) |
| 720 | `                variableMap.addAll(decoded);` | 链式调用起始于 变量 映射（变量 映射），后续行继续该表达式：变量 映射.批量添加(decoded); |
| 721 | `              }` | 闭合大括号，结束当前代码块 |
| 722 | `            }` | 闭合大括号，结束当前代码块 |
| 723 | `            // canReName 通常是一个布尔值或字符串，存储为字符串` | 注释说明：canReName 通常是一个布尔值或字符串，存储为字符串 |
| 724 | `            variableMap['canReName'] = canReNameValue;` | 变量 映射['canReName'] = canReNameValue |
| 725 | `            updatedVariable = jsonEncode(variableMap);` | 将 JSON 编码(变量 映射) 赋值给 已更新 变量（调用 JSON 编码 → JSON数据 编码） |
| 726 | `          } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 727 | `            AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 728 | `                .put('getBookInfo: 更新canReName到variable失败', error: e);` | 链式调用延续：.写入数据库(put)('getBookInfo: 更新canReName到variable失败', error: e); |
| 729 | `          }` | 闭合大括号，结束当前代码块 |
| 730 | `        }` | 闭合大括号，结束当前代码块 |
| 731 | `&nbsp;` | 空行，分隔逻辑段落 |
| 732 | `        String? pickNonBlank(String? primary, String? fallback) {` | 定义方法 pickNonBlank：返回 字符串(String)?；位置参数 2 个；参数名: primary。语义：pick Non Blank |
| 733 | `          if (primary != null && primary.trim().isNotEmpty) {` | 条件判断 如果(if)：primary 不等于 空值(null) 且 primary.去除首尾空白().是否非空 |
| 734 | `            return primary;` | 返回 primary |
| 735 | `          }` | 闭合大括号，结束当前代码块 |
| 736 | `          return fallback;` | 返回 回退 |
| 737 | `        }` | 闭合大括号，结束当前代码块 |
| 738 | `&nbsp;` | 空行，分隔逻辑段落 |
| 739 | `        // 更新书籍信息` | 注释说明：更新书籍信息 |
| 740 | `        return book.copyWith(` | 返回调用 书籍.copyWith(...) 的结果（语义：复制 With） |
| 741 | `          name: pickNonBlank(bookInfo['name'], book.name) ?? book.name,` | 命名实参 名称: pickNonBlank(bookInfo['名称'], 书籍.名称) ?? 书籍.名称（名称） |
| 742 | `          author: pickNonBlank(bookInfo['author'], book.author) ?? book.author,` | 命名实参 作者: pickNonBlank(bookInfo['作者'], 书籍.作者) ?? 书籍.作者（作者） |
| 743 | `          kind: pickNonBlank(bookInfo['kind'], book.kind),` | 命名实参 类别: pickNonBlank(bookInfo['类别'], 书籍.类别)（类别） |
| 744 | `          // coverUrl已经在parseRule中使用书籍详情页URL（book.bookUrl）作为baseUrl处理过了` | 注释说明：封面链接已经在解析 规则中使用书籍详情页统一资源链接(URL)（书籍.书籍链接）作为基础链接处理过了 |
| 745 | `          // 参考项目：封面URL使用当前页面URL作为baseUrl，parseRule已经处理` | 注释说明：参考项目：封面统一资源链接(URL)使用当前页面统一资源链接(URL)作为基础链接，解析 规则已经处理 |
| 746 | `          coverUrl: pickNonBlank(bookInfo['coverUrl'], book.coverUrl),` | 命名实参 封面链接: pickNonBlank(bookInfo['封面链接'], 书籍.封面链接)（封面 统一资源链接(URL)） |
| 747 | `          intro: pickNonBlank(bookInfo['intro'], book.intro),` | 命名实参 简介: pickNonBlank(bookInfo['简介'], 书籍.简介)（简介） |
| 748 | `          wordCount: pickNonBlank(bookInfo['wordCount'], book.wordCount),` | 命名实参 字数: pickNonBlank(bookInfo['字数'], 书籍.字数)（单词 数量） |
| 749 | `          latestChapterTitle:` | latestChapterTitle: |
| 750 | `              pickNonBlank(bookInfo['lastChapter'], book.latestChapterTitle),` | 调用 pickNonBlank(...)：pickNonBlank(bookInfo['最后 章节'], 书籍.latestChapterTitle), |
| 751 | `          tocUrl: newTocUrl,` | 命名实参 目录(TOC) URL: newTocUrl（目录(目录(TOC)) 统一资源链接(URL)） |
| 752 | `          variable: updatedVariable,` | 命名实参 variable: 已更新 变量（变量） |
| 753 | `          infoHtml: html,` | 命名实参 infoHtml: 网页内容（info 网页标记文本(HTML)） |
| 754 | `          lastCheckTime: DateTime.now().millisecondsSinceEpoch,` | 命名实参 lastCheckTime: DateTime.now().millisecondsSinceEpoch（最后 检查 Time） |
| 755 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 756 | `      });` | 闭合代码块并衔接后续语句：); |
| 757 | `&nbsp;` | 空行，分隔逻辑段落 |
| 758 | `      // 参考项目：如果书籍在书架中，自动保存到数据库` | 注释说明：参考项目：如果书籍在书架中，自动保存到数据库 |
| 759 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 760 | `        final existingBook = await getBookByUrl(book.bookUrl);` | 声明不可重新赋值的变量 existingBook：等待(await) 调用 getBookByUrl(...) → 获取 书籍 By 统一资源链接(URL) |
| 761 | `        if (existingBook != null) {` | 条件判断 如果(if)：existingBook 不等于 空值(null) |
| 762 | `          // 书籍在书架中，自动更新数据库` | 注释说明：书籍在书架中，自动更新数据库 |
| 763 | `          await updateBook(updatedBook);` | 调用 更新 书籍(...)（等待异步完成） → 更新 书籍 |
| 764 | `          AppLog.instance.put('getBookInfo: 书籍在书架中，已自动更新数据库');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('getBookInfo: 书籍在书架中，已自动更新数据库'); |
| 765 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 766 | `          // 尝试通过书名和作者查找（因为bookUrl可能不同）` | 注释说明：尝试通过书名和作者查找（因为书籍链接可能不同） |
| 767 | `          final existingByName = await getBookByNameAndAuthor(` | 声明不可重新赋值的变量 existingByName：等待(await) 调用 getBookByNameAndAuthor(...) → 获取 书籍 By 名称 And 作者 |
| 768 | `              updatedBook.name, updatedBook.author);` | 已更新 书籍.名称, 已更新 书籍.作者) |
| 769 | `          if (existingByName != null) {` | 条件判断 如果(if)：existingByName 不等于 空值(null) |
| 770 | `            // 找到同名同作者的书籍，更新它` | 注释说明：找到同名同作者的书籍，更新它 |
| 771 | `            final finalBook =` | 上一表达式的续行：不可重新赋值(final) finalBook = |
| 772 | `                updatedBook.copyWith(bookUrl: existingByName.bookUrl);` | 链式调用起始于 已更新 书籍（已更新 书籍），后续行继续该表达式：已更新 书籍.copyWith(书籍链接: existingByName.书籍链接); |
| 773 | `            await updateBook(finalBook);` | 调用 更新 书籍(...)（等待异步完成） → 更新 书籍 |
| 774 | `            AppLog.instance.put('getBookInfo: 通过书名和作者找到书籍，已自动更新数据库');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('getBookInfo: 通过书名和作者找到书籍，已自动更新数据库'); |
| 775 | `          }` | 闭合大括号，结束当前代码块 |
| 776 | `        }` | 闭合大括号，结束当前代码块 |
| 777 | `      } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 778 | `        // 保存失败不影响返回结果` | 注释说明：保存失败不影响返回结果 |
| 779 | `        AppLog.instance.put('getBookInfo: 自动保存书籍详情失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('getBookInfo: 自动保存书籍详情失败', error: e); |
| 780 | `      }` | 闭合大括号，结束当前代码块 |
| 781 | `&nbsp;` | 空行，分隔逻辑段落 |
| 782 | `      return updatedBook;` | 返回 已更新 书籍 |
| 783 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 784 | `      AppLog.instance.put('getBookInfo: 获取书籍详情失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('getBookInfo: 获取书籍详情失败', error: e); |
| 785 | `      return book;` | 返回 书籍 |
| 786 | `    }` | 闭合大括号，结束当前代码块 |
| 787 | `  }` | 闭合大括号，结束当前代码块 |
| 788 | `&nbsp;` | 空行，分隔逻辑段落 |
| 789 | `  Future<String> _fetchBookInfoHtml(Book book, BookSource source) async {` | 定义方法 _fetchBookInfoHtml：返回 异步结果(Future)<字符串(String)>；位置参数 2 个；含命名参数；参数名: 书籍, 书源（异步）。语义：拉取 书籍 Info 网页标记文本(HTML) |
| 790 | `    final headers = NetworkService.parseHeaders(source.header);` | 声明不可重新赋值的变量 请求头：调用 网络服务(NetworkService).解析 请求头(...) → 解析 请求头 |
| 791 | `    headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';` | 请求头['Cache-Control'] = 'no-cache, no-store, must-revalidate' |
| 792 | `    headers['Pragma'] = 'no-cache';` | 请求头['Pragma'] = 'no-cache' |
| 793 | `    headers['Expires'] = '0';` | 请求头['Expires'] = '0' |
| 794 | `&nbsp;` | 空行，分隔逻辑段落 |
| 795 | `    AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 796 | `      'getBookInfo: 请求URL=${book.bookUrl}, 请求头数量=${headers.length}',` | 以字符串 'getBookInfo: 请求统一资源链接(URL)=${书籍.书籍链接}, 请求头… 起始的表达式：, |
| 797 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 798 | `&nbsp;` | 空行，分隔逻辑段落 |
| 799 | `    final html = await _request(` | 声明不可重新赋值的变量 网页内容：等待(await) 调用 _请求(...) → 请求 |
| 800 | `      book.bookUrl,` | 签名/调用续行参数：书籍.书籍链接 |
| 801 | `      source,` | 签名/调用续行参数：书源 |
| 802 | `      headers: headers,` | 命名实参 请求头: 请求头（请求头） |
| 803 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 804 | `&nbsp;` | 空行，分隔逻辑段落 |
| 805 | `    AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 806 | `      'getBookInfo: 内容长度=${html.length}, URL=${book.bookUrl}',` | 以字符串 'getBookInfo: 内容长度=${网页内容.长度(length)}, 统一资源链接(URL)=$… 起始的表达式：, |
| 807 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 808 | `&nbsp;` | 空行，分隔逻辑段落 |
| 809 | `    return html;` | 返回 网页内容 |
| 810 | `  }` | 闭合大括号，结束当前代码块 |
| 811 | `&nbsp;` | 空行，分隔逻辑段落 |
| 812 | `  bool _hasMeaningfulBookInfo(Map<String, String?> bookInfo) {` | 定义方法 _hasMeaningfulBookInfo：返回 布尔(bool)；位置参数 2 个；参数名: 字符串(String)。语义：has Meaningful 书籍 Info |
| 813 | `    const keys = [` | 声明编译期常量变量 keys：列表字面量 |
| 814 | `      'name',` | 以字符串 '名称' 起始的表达式：, |
| 815 | `      'author',` | 以字符串 '作者' 起始的表达式：, |
| 816 | `      'kind',` | 以字符串 '类别' 起始的表达式：, |
| 817 | `      'wordCount',` | 以字符串 '字数' 起始的表达式：, |
| 818 | `      'lastChapter',` | 以字符串 '最后 章节' 起始的表达式：, |
| 819 | `      'intro',` | 以字符串 '简介' 起始的表达式：, |
| 820 | `      'coverUrl',` | 以字符串 '封面链接' 起始的表达式：, |
| 821 | `      'tocUrl'` | 上一表达式的续行：'目录(TOC) URL' |
| 822 | `    ];` | 结束上一调用/字面量：]; |
| 823 | `    for (final key in keys) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 键 属于(in) keys |
| 824 | `      final value = bookInfo[key];` | 声明不可重新赋值的变量 值 |
| 825 | `      if (value != null && value.trim().isNotEmpty) {` | 条件判断 如果(if)：值 不等于 空值(null) 且 值.去除首尾空白().是否非空 |
| 826 | `        return true;` | 返回 真(true)（布尔值 真(true)） |
| 827 | `      }` | 闭合大括号，结束当前代码块 |
| 828 | `    }` | 闭合大括号，结束当前代码块 |
| 829 | `    return false;` | 返回 假(false)（布尔值 假(false)） |
| 830 | `  }` | 闭合大括号，结束当前代码块 |
| 831 | `&nbsp;` | 空行，分隔逻辑段落 |
| 832 | `  /// 获取章节列表（支持分页获取所有章节）` | 文档注释：说明其后代码的用途 |
| 833 | `  Future<List<BookChapter>> getChapterList(` | 【承接上方文档】获取章节列表（支持分页获取所有章节） → 定义方法 获取 章节 列表：返回 异步结果(Future)<列表(List)<章节(BookChapter)>>；无参数（异步）。语义：获取 章节 列表 |
| 834 | `    Book book, {` | 书籍(Book) 类型参数 书籍，其后 { 开启命名参数块（书籍） |
| 835 | `    bool loadAllPages = true,` | 布尔(bool) 类型参数 加载 全部 分页，默认值 真(true)（加载 全部 分页） |
| 836 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 837 | `    if (book.isLocal) {` | 条件判断 如果(if)：书籍.isLocal |
| 838 | `      // 本地书籍从数据库读取章节` | 注释说明：本地书籍从数据库读取章节 |
| 839 | `      return await _getLocalChapters(book.bookUrl);` | 返回异步调用 _获取 本地 章节列表(...) 的结果（语义：获取 本地 章节列表） |
| 840 | `    }` | 闭合大括号，结束当前代码块 |
| 841 | `&nbsp;` | 空行，分隔逻辑段落 |
| 842 | `    final source = await _bookSourceService.getBookSourceByUrl(book.origin);` | 声明不可重新赋值的变量 书源：等待(await) 调用 _书籍 书源 服务.getBookSourceByUrl(...) → 获取 书籍 书源 By 统一资源链接(URL) |
| 843 | `    if (source == null \|\| source.ruleToc == null) {` | 条件判断 如果(if)：书源 等于 空值(null) 或 书源.目录规则 等于 空值(null) |
| 844 | `      return [];` | 返回 []（列表字面量） |
| 845 | `    }` | 闭合大括号，结束当前代码块 |
| 846 | `&nbsp;` | 空行，分隔逻辑段落 |
| 847 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 848 | `      final chapterVariables = _buildRuleVariables(book);` | 声明不可重新赋值的变量 章节 变量表：调用 _构建 规则 变量表(...) → 构建 规则 变量表 |
| 849 | `      // 使用tocUrl或bookUrl` | 注释说明：使用目录(TOC) URL或书籍链接 |
| 850 | `      final tocUrl = book.tocUrl.isNotEmpty ? book.tocUrl : book.bookUrl;` | 声明不可重新赋值的变量 目录(TOC) URL |
| 851 | `      AppLog.instance.put('开始获取章节列表: tocUrl=$tocUrl, bookUrl=${book.bookUrl}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('开始获取章节列表: 目录(TOC) URL=$目录(TOC) URL, 书籍链接=${书籍.书籍链接}… |
| 852 | `&nbsp;` | 空行，分隔逻辑段落 |
| 853 | `      // 发送请求` | 注释说明：发送请求 |
| 854 | `      final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 855 | `        tocUrl,` | 签名/调用续行参数：目录(TOC) URL |
| 856 | `        headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 857 | `        retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 858 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 859 | `&nbsp;` | 空行，分隔逻辑段落 |
| 860 | `      var html = await NetworkService.getResponseText(response);` | 声明自动类型推断的变量 网页内容：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 861 | `&nbsp;` | 空行，分隔逻辑段落 |
| 862 | `      AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 863 | `          .put('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}');` | 链式调用延续：.写入数据库(put)('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}'); |
| 864 | `&nbsp;` | 空行，分隔逻辑段落 |
| 865 | `      if (html.isEmpty) {` | 条件判断 如果(if)：网页内容.是否为空 |
| 866 | `        AppLog.instance.put('获取章节列表失败: 响应内容为空');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败: 响应内容为空'); |
| 867 | `        // 如果获取失败，尝试从数据库读取` | 注释说明：如果获取失败，尝试从数据库读取 |
| 868 | `        final localChapters = await _getLocalChapters(book.bookUrl);` | 声明不可重新赋值的变量 本地 章节列表：等待(await) 调用 _获取 本地 章节列表(...) → 获取 本地 章节列表 |
| 869 | `        if (localChapters.isEmpty) {` | 条件判断 如果(if)：本地 章节列表.是否为空 |
| 870 | `          throw TocEmptyException('获取章节列表失败: 响应内容为空，且本地无章节数据');` | 定义方法 目录(TOC) 空 异常：返回 抛出(throw)；位置参数 1 个；参数名: 获取章节列表失败。语义：目录(目录(TOC)) 空 异常 |
| 871 | `        }` | 闭合大括号，结束当前代码块 |
| 872 | `        return localChapters;` | 返回 本地 章节列表 |
| 873 | `      }` | 闭合大括号，结束当前代码块 |
| 874 | `&nbsp;` | 空行，分隔逻辑段落 |
| 875 | `      // 确定有效的baseUrl：如果tocUrl不是有效的绝对URL，使用source.bookSourceUrl` | 注释说明：确定有效的基础链接：如果目录(TOC) URL不是有效的绝对统一资源链接(URL)，使用书源.书源链接 |
| 876 | `      String? effectiveBaseUrl = tocUrl;` | 字符串(String)? effectiveBaseUrl = 目录(TOC) URL |
| 877 | `      if (!tocUrl.isAbsUrl()) {` | 条件判断 如果(if)：!目录(TOC) URL.isAbsUrl() |
| 878 | `        // 如果source.bookSourceUrl也是有效的绝对URL，使用它；否则尝试从tocUrl构建` | 注释说明：如果书源.书源链接也是有效的绝对统一资源链接(URL)，使用它；否则尝试从目录(TOC) URL构建 |
| 879 | `        if (source.bookSourceUrl.isAbsUrl()) {` | 条件判断 如果(if)：书源.书源链接.isAbsUrl() |
| 880 | `          effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 881 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 882 | `              'tocUrl不是绝对URL，使用source.bookSourceUrl作为baseUrl: $effectiveBaseUrl');` | 以字符串 '目录(TOC) URL不是绝对统一资源链接(URL)，使用书源.书源链接作为b… 起始的表达式：); |
| 883 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 884 | `          // 如果两者都不是绝对URL，尝试从tocUrl构建完整的URL` | 注释说明：如果两者都不是绝对统一资源链接(URL)，尝试从目录(TOC) URL构建完整的统一资源链接(URL) |
| 885 | `          // 如果tocUrl是相对路径，使用source.bookSourceUrl作为基础` | 注释说明：如果目录(TOC) URL是相对路径，使用书源.书源链接作为基础 |
| 886 | `          try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 887 | `            effectiveBaseUrl =` | 上一表达式的续行：effectiveBaseUrl = |
| 888 | `                NetworkService.joinUrl(source.bookSourceUrl, tocUrl);` | 链式调用起始于 网络服务(NetworkService)（Network 服务），后续行继续该表达式：网络服务(NetworkService).拼接 URL(书源.书源链接, 目录(TOC) URL); |
| 889 | `            if (!effectiveBaseUrl.isAbsUrl()) {` | 条件判断 如果(if)：!effectiveBaseUrl.isAbsUrl() |
| 890 | `              // 如果仍然无效，使用source.bookSourceUrl` | 注释说明：如果仍然无效，使用书源.书源链接 |
| 891 | `              effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 892 | `            }` | 闭合大括号，结束当前代码块 |
| 893 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 894 | `                'tocUrl和source.bookSourceUrl都不是绝对URL，尝试拼接后: $effectiveBaseUrl');` | 以字符串 '目录(TOC) URL和书源.书源链接都不是绝对统一资源链接(URL)，尝试拼… 起始的表达式：); |
| 895 | `          } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 896 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 897 | `                '构建baseUrl失败: $e，使用source.bookSourceUrl: ${source.bookSourceUrl}');` | 以字符串 '构建基础链接失败: $异常对象 e，使用书源.书源链接:… 起始的表达式：); |
| 898 | `            effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 899 | `          }` | 闭合大括号，结束当前代码块 |
| 900 | `        }` | 闭合大括号，结束当前代码块 |
| 901 | `      }` | 闭合大括号，结束当前代码块 |
| 902 | `&nbsp;` | 空行，分隔逻辑段落 |
| 903 | `      // 最终验证：确保effectiveBaseUrl是有效的绝对URL` | 注释说明：最终验证：确保effectiveBaseUrl是有效的绝对统一资源链接(URL) |
| 904 | `      if (!effectiveBaseUrl.isAbsUrl()) {` | 条件判断 如果(if)：!effectiveBaseUrl.isAbsUrl() |
| 905 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 906 | `            .put('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败');` | 链式调用延续：.写入数据库(put)('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败'); |
| 907 | `      }` | 闭合大括号，结束当前代码块 |
| 908 | `&nbsp;` | 空行，分隔逻辑段落 |
| 909 | `      // 参考项目：执行 preUpdateJs（如果存在）` | 注释说明：参考项目：执行 preUpdateJs（如果存在） |
| 910 | `      // 参考项目的 TocRule 有 preUpdateJs 字段，用于在解析目录前预处理HTML` | 注释说明：参考项目的 目录(TOC) 规则 有 preUpdateJs 字段，用于在解析目录前预处理网页标记文本(HTML) |
| 911 | `      if (source.ruleToc?.preUpdateJs != null &&` | 条件判断 如果(if)：书源.目录规则?.preUpdateJs 不等于 空值(null) 且 |
| 912 | `          source.ruleToc!.preUpdateJs!.isNotEmpty) {` | 书源.目录规则!.preUpdateJs!.是否非空) { |
| 913 | `        AppLog.instance.put('执行 preUpdateJs 预处理HTML');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('执行 preUpdateJs 预处理HTML'); |
| 914 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 915 | `          final preUpdateResult = await RuleParser.executeJs(` | 声明不可重新赋值的变量 preUpdateResult：等待(await) 调用 规则解析器(RuleParser).执行 JS脚本(...) → 执行 JavaScript脚本(JS)脚本 |
| 916 | `            html,` | 签名/调用续行参数：网页内容 |
| 917 | `            source.ruleToc!.preUpdateJs!,` | 书源.目录规则!.preUpdateJs!, |
| 918 | `            source: source,` | 命名实参 书源: 书源（书源） |
| 919 | `            book: book,` | 命名实参 书籍: 书籍（书籍） |
| 920 | `            baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 921 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 922 | `          if (preUpdateResult != null && preUpdateResult.isNotEmpty) {` | 条件判断 如果(if)：preUpdateResult 不等于 空值(null) 且 preUpdateResult.是否非空 |
| 923 | `            html = preUpdateResult;` | 将 preUpdateResult 赋值给 网页内容 |
| 924 | `            AppLog.instance.put('preUpdateJs 执行成功，HTML长度=${html.length}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('preUpdateJs 执行成功，HTML长度=${html.length}'); |
| 925 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 926 | `            AppLog.instance.put('preUpdateJs 执行返回空，使用原始HTML');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('preUpdateJs 执行返回空，使用原始HTML'); |
| 927 | `          }` | 闭合大括号，结束当前代码块 |
| 928 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 929 | `          AppLog.instance.put('preUpdateJs 执行失败: $e，使用原始HTML', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('preUpdateJs 执行失败: $e，使用原始HTML', error: e); |
| 930 | `        }` | 闭合大括号，结束当前代码块 |
| 931 | `      }` | 闭合大括号，结束当前代码块 |
| 932 | `&nbsp;` | 空行，分隔逻辑段落 |
| 933 | `      // 首先尝试使用原始规则获取第一页，如果失败则使用降级规则` | 注释说明：首先尝试使用原始规则获取第一页，如果失败则使用降级规则 |
| 934 | `      TocRule? effectiveTocRule = source.ruleToc;` | 目录(TOC) 规则? effectiveTocRule = 书源.目录规则 |
| 935 | `      String? fallbackChapterListRule;` | 字符串(String)? 回退/降级 章节 列表 规则 |
| 936 | `&nbsp;` | 空行，分隔逻辑段落 |
| 937 | `      // 检查原始规则是否能匹配到章节` | 注释说明：检查原始规则是否能匹配到章节 |
| 938 | `      var testChapterList = RuleParser.parseTocRule(` | 声明自动类型推断的变量 testChapterList：调用 规则解析器(RuleParser).解析 目录(TOC) 规则(...) → 解析 目录(目录(TOC)) 规则 |
| 939 | `        html,` | 签名/调用续行参数：网页内容 |
| 940 | `        source.ruleToc,` | 签名/调用续行参数：书源.目录规则 |
| 941 | `        baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 942 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 943 | `&nbsp;` | 空行，分隔逻辑段落 |
| 944 | `      if (testChapterList.isEmpty && source.ruleToc?.chapterList != null) {` | 条件判断 如果(if)：testChapterList.是否为空 且 书源.目录规则?.章节 列表 不等于 空值(null) |
| 945 | `        AppLog.instance.put('原始规则未匹配到章节，尝试智能降级处理');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('原始规则未匹配到章节，尝试智能降级处理'); |
| 946 | `&nbsp;` | 空行，分隔逻辑段落 |
| 947 | `        // 查找降级规则` | 注释说明：查找降级规则 |
| 948 | `        final chapterLinkPattern = RegExp(` | 声明不可重新赋值的变量 chapterLinkPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 949 | `            '<a[^>]*href=["\']/[^"\']*\\.html["\'][^>]*>.*?</a>',` | 以字符串 '<a[^>]*href=["\']/[^"\']*\\.网页内容["\'][^… 起始的表达式：, |
| 950 | `            caseSensitive: false,` | 区分大小写开关: 假(false), |
| 951 | `            dotAll: true);` | 命名实参 点号 全部: 真(true));（点号 全部） |
| 952 | `        final chapterLinkMatches = chapterLinkPattern.allMatches(html).toList();` | 声明不可重新赋值的变量 chapterLinkMatches：调用 chapterLinkPattern.allMatches(...) → 全部 Matches |
| 953 | `&nbsp;` | 空行，分隔逻辑段落 |
| 954 | `        if (chapterLinkMatches.isNotEmpty) {` | 条件判断 如果(if)：chapterLinkMatches.是否非空 |
| 955 | `          AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 956 | `              .put('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器');` | 链式调用延续：.写入数据库(put)('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器'); |
| 957 | `&nbsp;` | 空行，分隔逻辑段落 |
| 958 | `          html_dom.Element? directoryContainer;` | html_dom.Element? directoryContainer |
| 959 | `          String? containerClass;` | 字符串(String)? containerClass |
| 960 | `          String? containerId;` | 字符串(String)? containerId |
| 961 | `&nbsp;` | 空行，分隔逻辑段落 |
| 962 | `          // 首先尝试查找directoryArea容器` | 注释说明：首先尝试查找directoryArea容器 |
| 963 | `          final doc = html_parser.parse(html);` | 声明不可重新赋值的变量 文档：调用 HTML 解析器.parse(...) → 解析 |
| 964 | `          final directoryPattern = RegExp(` | 声明不可重新赋值的变量 目录(directory) 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 965 | `              'class\\s*=\\s*["\'][^"\']*directory[^"\']*["\']',` | 以字符串 '类(class)\\s*=\\s*["\'][^"\']*目录(directory)[^"\… 起始的表达式：, |
| 966 | `              caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 967 | `          final directoryMatches = directoryPattern.allMatches(html);` | 声明不可重新赋值的变量 directoryMatches：调用 目录(directory) 模式.allMatches(...) → 全部 Matches |
| 968 | `          if (directoryMatches.isNotEmpty) {` | 条件判断 如果(if)：directoryMatches.是否非空 |
| 969 | `            final match = directoryMatches.first;` | 声明不可重新赋值的变量 match |
| 970 | `            final matchHtml = html.substring(match.start, match.end);` | 声明不可重新赋值的变量 matchHtml |
| 971 | `            final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 972 | `                caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 973 | `            final classMatch = classPattern.firstMatch(matchHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 974 | `            if (classMatch != null) {` | 条件判断 如果(if)：classMatch 不等于 空值(null) |
| 975 | `              final allClasses =` | 上一表达式的续行：不可重新赋值(final) allClasses = |
| 976 | `                  classMatch.group(1)?.split(RegExp(r'\s+')) ?? [];` | 链式调用起始于 classMatch，后续行继续该表达式：classMatch.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')) ?? []; |
| 977 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 978 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 979 | `                orElse: () => '',` | 命名实参 orElse: () => ''（or Else） |
| 980 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 981 | `              if (dirClass.isNotEmpty) {` | 条件判断 如果(if)：dirClass.是否非空 |
| 982 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 983 | `                    HtmlParser.selectElement(doc, 'div.$dirClass');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div.$dirClass'); |
| 984 | `                containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 985 | `                AppLog.instance.put('找到directory容器: class=$containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到directory容器: class=$containerClass'); |
| 986 | `              }` | 闭合大括号，结束当前代码块 |
| 987 | `            }` | 闭合大括号，结束当前代码块 |
| 988 | `          }` | 闭合大括号，结束当前代码块 |
| 989 | `&nbsp;` | 空行，分隔逻辑段落 |
| 990 | `          // 如果找到了directory容器，提取其class或id用于生成降级规则` | 注释说明：如果找到了目录(directory)容器，提取其类(class)或编号(id)用于生成降级规则 |
| 991 | `          if (directoryContainer != null) {` | 条件判断 如果(if)：directoryContainer 不等于 空值(null) |
| 992 | `            final dirClassAttr = directoryContainer.attributes['class'];` | 声明不可重新赋值的变量 dirClassAttr |
| 993 | `            final dirIdAttr = directoryContainer.attributes['id'];` | 声明不可重新赋值的变量 dirIdAttr |
| 994 | `            if (dirClassAttr != null && dirClassAttr.contains('directory')) {` | 条件判断 如果(if)：dirClassAttr 不等于 空值(null) 且 dirClassAttr.是否包含('目录(directory)') |
| 995 | `              final allClasses = dirClassAttr.split(RegExp(r'\s+'));` | 声明不可重新赋值的变量 allClasses：调用 dirClassAttr.切分(...) → 切分 |
| 996 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 997 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 998 | `                orElse: () => allClasses.first,` | 命名实参 orElse: () => allClasses.first（or Else） |
| 999 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1000 | `              containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 1001 | `              AppLog.instance.put('从directory容器提取class: $containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取class: $containerClass'); |
| 1002 | `            }` | 闭合大括号，结束当前代码块 |
| 1003 | `            if (dirIdAttr != null) {` | 条件判断 如果(if)：dirIdAttr 不等于 空值(null) |
| 1004 | `              containerId = dirIdAttr;` | 将 dirIdAttr 赋值给 containerId |
| 1005 | `              AppLog.instance.put('从directory容器提取id: $containerId');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取id: $containerId'); |
| 1006 | `            }` | 闭合大括号，结束当前代码块 |
| 1007 | `          }` | 闭合大括号，结束当前代码块 |
| 1008 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1009 | `          // 生成降级规则` | 注释说明：生成降级规则 |
| 1010 | `          if (containerClass != null) {` | 条件判断 如果(if)：containerClass 不等于 空值(null) |
| 1011 | `            fallbackChapterListRule = 'class.$containerClass@tag.a';` | 回退/降级 章节 列表 规则 = '类(class).$containerClass@tag.a' |
| 1012 | `            AppLog.instance.put('使用降级规则: $fallbackChapterListRule');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('使用降级规则: $fallbackChapterListRule'); |
| 1013 | `          }` | 闭合大括号，结束当前代码块 |
| 1014 | `        }` | 闭合大括号，结束当前代码块 |
| 1015 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1016 | `        // 如果找到了降级规则，创建临时规则对象` | 注释说明：如果找到了降级规则，创建临时规则对象 |
| 1017 | `        if (fallbackChapterListRule != null) {` | 条件判断 如果(if)：回退/降级 章节 列表 规则 不等于 空值(null) |
| 1018 | `          effectiveTocRule = TocRule(` | 将 目录(TOC) 规则( 赋值给 effectiveTocRule（调用 目录(TOC) 规则 → 目录(目录(TOC)) 规则） |
| 1019 | `            chapterList: fallbackChapterListRule,` | 命名实参 章节 列表: 回退/降级 章节 列表 规则（章节 列表） |
| 1020 | `            chapterName: source.ruleToc?.chapterName ?? 'tag.a@text',` | 命名实参 章节 名称: 书源.目录规则?.章节 名称 ?? 'tag.a@文本'（章节 名称） |
| 1021 | `            chapterUrl: source.ruleToc?.chapterUrl ?? 'tag.a@href',` | 命名实参 章节链接: 书源.目录规则?.章节链接 ?? 'tag.a@href'（章节 统一资源链接(URL)） |
| 1022 | `            isVip: source.ruleToc?.isVip,` | 命名实参 isVip: 书源.目录规则?.isVip（是(is) Vip） |
| 1023 | `            isVolume: source.ruleToc?.isVolume, // 保留卷名规则` | 命名实参 isVolume: 书源.目录规则?.isVolume（是(is) 体积）；行尾注释：保留卷名规则 |
| 1024 | `            updateTime: source.ruleToc?.updateTime,` | 命名实参 updateTime: 书源.目录规则?.updateTime（更新 Time） |
| 1025 | `            nextTocUrl: source.ruleToc?.nextTocUrl,` | 命名实参 下一页目录链接: 书源.目录规则?.下一页目录链接（下一章 目录(目录(TOC)) 统一资源链接(URL)） |
| 1026 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1027 | `        }` | 闭合大括号，结束当前代码块 |
| 1028 | `      }` | 闭合大括号，结束当前代码块 |
| 1029 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1030 | `      // 参考项目：BookChapterList.analyzeChapterList` | 注释说明：参考项目：书籍 章节 列表.分析 章节 列表 |
| 1031 | `      // 处理 chapterList 规则的前缀（参考项目第51-58行）` | 注释说明：处理 章节 列表 规则的前缀（参考项目第51-58行） |
| 1032 | `      var reverse = false;` | 声明自动类型推断的变量 reverse |
| 1033 | `      var listRule = effectiveTocRule?.chapterList ?? '';` | 声明自动类型推断的变量 列表 规则 |
| 1034 | `      if (listRule.startsWith('-')) {` | 条件判断 如果(if)：列表 规则.startsWith('-') |
| 1035 | `        reverse = true;` | 将 真(true) 赋值给 reverse |
| 1036 | `        listRule = listRule.substring(1);` | 将 列表 规则.substring(1) 赋值给 列表 规则 |
| 1037 | `        AppLog.instance.put('检测到 - 前缀，将反转章节列表');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('检测到 - 前缀，将反转章节列表'); |
| 1038 | `      }` | 闭合大括号，结束当前代码块 |
| 1039 | `      if (listRule.startsWith('+')) {` | 条件判断 如果(if)：列表 规则.startsWith('+') |
| 1040 | `        listRule = listRule.substring(1);` | 将 列表 规则.substring(1) 赋值给 列表 规则 |
| 1041 | `        AppLog.instance.put('检测到 + 前缀，已移除');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('检测到 + 前缀，已移除'); |
| 1042 | `      }` | 闭合大括号，结束当前代码块 |
| 1043 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1044 | `      // 如果规则被修改，更新 effectiveTocRule` | 注释说明：如果规则被修改，更新 effectiveTocRule |
| 1045 | `      if (listRule != effectiveTocRule?.chapterList) {` | 条件判断 如果(if)：列表 规则 不等于 effectiveTocRule?.章节 列表 |
| 1046 | `        effectiveTocRule = TocRule(` | 将 目录(TOC) 规则( 赋值给 effectiveTocRule（调用 目录(TOC) 规则 → 目录(目录(TOC)) 规则） |
| 1047 | `          chapterList: listRule,` | 命名实参 章节 列表: 列表 规则（章节 列表） |
| 1048 | `          chapterName: effectiveTocRule?.chapterName,` | 命名实参 章节 名称: effectiveTocRule?.章节 名称（章节 名称） |
| 1049 | `          chapterUrl: effectiveTocRule?.chapterUrl,` | 命名实参 章节链接: effectiveTocRule?.章节链接（章节 统一资源链接(URL)） |
| 1050 | `          isVip: effectiveTocRule?.isVip,` | 命名实参 isVip: effectiveTocRule?.isVip（是(is) Vip） |
| 1051 | `          isVolume: effectiveTocRule?.isVolume,` | 命名实参 isVolume: effectiveTocRule?.isVolume（是(is) 体积） |
| 1052 | `          updateTime: effectiveTocRule?.updateTime,` | 命名实参 updateTime: effectiveTocRule?.updateTime（更新 Time） |
| 1053 | `          nextTocUrl: effectiveTocRule?.nextTocUrl,` | 命名实参 下一页目录链接: effectiveTocRule?.下一页目录链接（下一章 目录(目录(TOC)) 统一资源链接(URL)） |
| 1054 | `          formatJs: effectiveTocRule?.formatJs,` | 命名实参 格式化 JS脚本: effectiveTocRule?.格式化 JS脚本（格式化 JavaScript脚本(JS)脚本） |
| 1055 | `          preUpdateJs: effectiveTocRule?.preUpdateJs,` | 命名实参 preUpdateJs: effectiveTocRule?.preUpdateJs（pre 更新 JavaScript脚本(JS)脚本） |
| 1056 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1057 | `      }` | 闭合大括号，结束当前代码块 |
| 1058 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1059 | `      // 参考项目：第一次调用 analyzeChapterList，返回章节列表和下一页URL列表` | 注释说明：参考项目：第一次调用 分析 章节 列表，返回章节列表和下一页统一资源链接(URL)列表 |
| 1060 | `      final firstPageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 首个 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 1061 | `        html,` | 签名/调用续行参数：网页内容 |
| 1062 | `        effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 1063 | `        variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1064 | `        baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 1065 | `        getNextUrl: true,` | 命名实参 获取 下一章 URL: 真(true)（获取 下一章 统一资源链接(URL)） |
| 1066 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1067 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1068 | `      var allChapterList = <Map<String, String?>>[];` | 声明自动类型推断的变量 全部 章节 列表 |
| 1069 | `      allChapterList` | 上一表达式的续行：全部 章节 列表 |
| 1070 | `          .addAll(firstPageResult['chapterList'] as List<Map<String, String?>>);` | 链式调用延续：.批量添加(首个 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>>); |
| 1071 | `      var nextUrlList =` | 上一表达式的续行：自动类型推断(var) 下一章 URL 列表 = |
| 1072 | `          List<String>.from(firstPageResult['nextUrlList'] as List);` | 调用 from(...)：列表(List)<字符串(String)>.from(首个 页 结果['下一章 URL 列表'] 作为(as) 列表(List)) |
| 1073 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1074 | `      // 过滤掉与当前URL相同的URL` | 注释说明：过滤掉与当前统一资源链接(URL)相同的统一资源链接(URL) |
| 1075 | `      nextUrlList =` | 上一表达式的续行：下一章 URL 列表 = |
| 1076 | `          nextUrlList.where((url) => url.isNotEmpty && url != tocUrl).toList();` | 链式调用起始于 下一章 URL 列表（下一章 统一资源链接(URL) 列表），后续行继续该表达式：下一章 URL 列表.筛选(where)((链接) => 链接.是否非空 && 链接 != 目录(TOC) URL).转为列表(); |
| 1077 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1078 | `      // 参考项目：根据 nextUrlList.size 决定处理方式` | 注释说明：参考项目：根据 下一章 URL 列表.大小 决定处理方式 |
| 1079 | `      // size == 0: 不处理分页` | 注释说明：大小 == 0: 不处理分页 |
| 1080 | `      // size == 1: 循环获取下一页` | 注释说明：大小 == 1: 循环获取下一页 |
| 1081 | `      // size > 1: 并发处理所有URL` | 注释说明：大小 > 1: 并发处理所有统一资源链接(URL) |
| 1082 | `      if (loadAllPages && nextUrlList.isEmpty) {` | 条件判断 如果(if)：加载 全部 分页 且 下一章 URL 列表.是否为空 |
| 1083 | `        final ajaxChapters = await _loadAjaxTocPages(` | 声明不可重新赋值的变量 ajaxChapters：等待(await) 调用 _loadAjaxTocPages(...) → 加载 Ajax 目录(目录(TOC)) 分页 |
| 1084 | `          tocUrl: tocUrl,` | 命名实参 目录(TOC) URL: 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 1085 | `          firstPageHtml: html,` | 命名实参 首个 页 HTML: 网页内容（首个 页 网页标记文本(HTML)） |
| 1086 | `          source: source,` | 命名实参 书源: 书源（书源） |
| 1087 | `          seedChapters: allChapterList,` | 命名实参 seedChapters: 全部 章节 列表（seed 章节列表） |
| 1088 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1089 | `        if (ajaxChapters.isNotEmpty) {` | 条件判断 如果(if)：ajaxChapters.是否非空 |
| 1090 | `          allChapterList.addAll(ajaxChapters);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(ajaxChapters); |
| 1091 | `        }` | 闭合大括号，结束当前代码块 |
| 1092 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1093 | `        final implicitChapters = await _loadImplicitTocPages(` | 声明不可重新赋值的变量 implicitChapters：等待(await) 调用 _loadImplicitTocPages(...) → 加载 Implicit 目录(目录(TOC)) 分页 |
| 1094 | `          tocUrl: tocUrl,` | 命名实参 目录(TOC) URL: 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 1095 | `          source: source,` | 命名实参 书源: 书源（书源） |
| 1096 | `          tocRule: effectiveTocRule!,` | 命名实参 目录(TOC) 规则: effectiveTocRule!（目录(目录(TOC)) 规则） |
| 1097 | `          seedChapters: allChapterList,` | 命名实参 seedChapters: 全部 章节 列表（seed 章节列表） |
| 1098 | `          variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1099 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1100 | `        if (implicitChapters.isNotEmpty) {` | 条件判断 如果(if)：implicitChapters.是否非空 |
| 1101 | `          allChapterList.addAll(implicitChapters);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(implicitChapters); |
| 1102 | `        }` | 闭合大括号，结束当前代码块 |
| 1103 | `      } else if (loadAllPages && nextUrlList.length == 1) {` | 闭合上一代码块并开始 否则(else) 如果(if) (加载 全部 分页 && 下一章 URL 列表.长度 |
| 1104 | `        // 参考项目：循环获取下一页，直到没有下一页或已访问过` | 注释说明：参考项目：循环获取下一页，直到没有下一页或已访问过 |
| 1105 | `        var currentUrl = nextUrlList[0];` | 声明自动类型推断的变量 当前 URL |
| 1106 | `        var visitedUrls = <String>{tocUrl, currentUrl};` | 声明自动类型推断的变量 visitedUrls |
| 1107 | `        var pageCount = 1;` | 声明自动类型推断的变量 页 数量 |
| 1108 | `        const maxPages = 100; // 防止无限循环` | 声明编译期常量变量 maxPages；行尾注释：防止无限循环 |
| 1109 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1110 | `        while (pageCount < maxPages) {` | 当型循环(while) 循环，条件：页 数量 < maxPages |
| 1111 | `          pageCount++;` | 页 数量++ |
| 1112 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1113 | `          try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1114 | `            final pageResponse = await _networkService.get(` | 声明不可重新赋值的变量 页 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 1115 | `              currentUrl,` | 签名/调用续行参数：当前 URL |
| 1116 | `              headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 1117 | `              retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 1118 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1119 | `            final pageHtml = await NetworkService.getResponseText(pageResponse);` | 声明不可重新赋值的变量 页 HTML：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 1120 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1121 | `            if (pageHtml.isEmpty) {` | 条件判断 如果(if)：页 HTML.是否为空 |
| 1122 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1123 | `            }` | 闭合大括号，结束当前代码块 |
| 1124 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1125 | `            // 解析当前页的章节列表和下一页URL` | 注释说明：解析当前页的章节列表和下一页统一资源链接(URL) |
| 1126 | `            final pageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 1127 | `              pageHtml,` | 签名/调用续行参数：页 HTML |
| 1128 | `              effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 1129 | `              variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1130 | `              baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 1131 | `              getNextUrl: true,` | 命名实参 获取 下一章 URL: 真(true)（获取 下一章 统一资源链接(URL)） |
| 1132 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1133 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1134 | `            final pageChapterList =` | 上一表达式的续行：不可重新赋值(final) 页 章节 列表 = |
| 1135 | `                pageResult['chapterList'] as List<Map<String, String?>>;` | 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 1136 | `            final pageNextUrlList =` | 上一表达式的续行：不可重新赋值(final) 页 下一章 URL 列表 = |
| 1137 | `                List<String>.from(pageResult['nextUrlList'] as List);` | 调用 from(...)：列表(List)<字符串(String)>.from(页 结果['下一章 URL 列表'] 作为(as) 列表(List)) |
| 1138 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1139 | `            allChapterList.addAll(pageChapterList);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(页 章节 列表); |
| 1140 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1141 | `            // 获取下一页URL（过滤掉已访问的URL）` | 注释说明：获取下一页统一资源链接(URL)（过滤掉已访问的统一资源链接(URL)） |
| 1142 | `            final filteredNextUrls = pageNextUrlList` | 上一表达式的续行：不可重新赋值(final) filteredNextUrls = 页 下一章 URL 列表 |
| 1143 | `                .where((url) =>` | 链式调用延续：.筛选(where)((链接) => |
| 1144 | `                    url.isNotEmpty &&` | 上一表达式的续行：链接.是否非空 && |
| 1145 | `                    url != currentUrl &&` | 上一表达式的续行：链接 != 当前 URL && |
| 1146 | `                    !visitedUrls.contains(url))` | 调用 是否包含(...)：!visitedUrls.是否包含(链接))（是否包含） |
| 1147 | `                .toList();` | 链式调用延续：.转为列表(); |
| 1148 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1149 | `            if (filteredNextUrls.isEmpty) {` | 条件判断 如果(if)：filteredNextUrls.是否为空 |
| 1150 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1151 | `            }` | 闭合大括号，结束当前代码块 |
| 1152 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1153 | `            currentUrl = filteredNextUrls[0];` | 将 filteredNextUrls[0] 赋值给 当前 URL |
| 1154 | `            visitedUrls.add(currentUrl);` | 链式调用起始于 visitedUrls，后续行继续该表达式：visitedUrls.添加(当前 URL); |
| 1155 | `          } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 1156 | `            AppLog.instance.put('获取第 $pageCount 页失败: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取第 $pageCount 页失败: $e', error: e); |
| 1157 | `            break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1158 | `          }` | 闭合大括号，结束当前代码块 |
| 1159 | `        }` | 闭合大括号，结束当前代码块 |
| 1160 | `      } else if (loadAllPages) {` | 闭合上一代码块并开始 否则(else) 如果(if) (加载 全部 分页) { |
| 1161 | `        // 参考项目：并发处理所有URL` | 注释说明：参考项目：并发处理所有统一资源链接(URL) |
| 1162 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1163 | `          // 并发处理所有URL` | 注释说明：并发处理所有统一资源链接(URL) |
| 1164 | `          final futures = nextUrlList.map((url) async {` | 声明不可重新赋值的变量 futures：调用 下一章 URL 列表.映射(map)(...) → 映射 |
| 1165 | `            try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1166 | `              final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 1167 | `                url,` | 签名/调用续行参数：链接 |
| 1168 | `                headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 1169 | `                retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 1170 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1171 | `              final pageHtml = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 页 HTML：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 1172 | `              return {'url': url, 'html': pageHtml, 'success': true};` | 返回 {'链接': 链接, '网页内容': 页 HTML, '成功': 真(true)}（映射(Map)/集合字面量） |
| 1173 | `            } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 1174 | `              return {'url': url, 'html': '', 'success': false};` | 返回 {'链接': 链接, '网页内容': '', '成功': 假(false)}（映射(Map)/集合字面量） |
| 1175 | `            }` | 闭合大括号，结束当前代码块 |
| 1176 | `          }).toList();` | 闭合代码块并衔接后续语句：).转为列表(); |
| 1177 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1178 | `          final results = await Future.wait(futures);` | 声明不可重新赋值的变量 结果：等待(await) 调用 异步结果(Future).wait(...) |
| 1179 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1180 | `          // 分别解析每个URL的章节列表，然后合并` | 注释说明：分别解析每个统一资源链接(URL)的章节列表，然后合并 |
| 1181 | `          for (final result in results) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 结果 属于(in) 结果 |
| 1182 | `            if (result['success'] == true &&` | 条件判断 如果(if)：结果['成功'] 等于 真(true) 且 |
| 1183 | `                (result['html'] as String).isNotEmpty) {` | (结果['网页内容'] 作为(as) 字符串(String)).是否非空) { |
| 1184 | `              final pageHtml = result['html'] as String;` | 声明不可重新赋值的变量 页 HTML |
| 1185 | `              final pageUrl = result['url'] as String;` | 声明不可重新赋值的变量 页 URL |
| 1186 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1187 | `              final pageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 1188 | `                pageHtml,` | 签名/调用续行参数：页 HTML |
| 1189 | `                effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 1190 | `                variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1191 | `                baseUrl: pageUrl,` | 命名实参 基础链接: 页 URL（base 统一资源链接(URL)） |
| 1192 | `                getNextUrl: false, // 并发处理时不需要获取下一页URL` | 命名实参 获取 下一章 URL: 假(false)（获取 下一章 统一资源链接(URL)）；行尾注释：并发处理时不需要获取下一页统一资源链接(URL) |
| 1193 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1194 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1195 | `              final pageChapterList =` | 上一表达式的续行：不可重新赋值(final) 页 章节 列表 = |
| 1196 | `                  pageResult['chapterList'] as List<Map<String, String?>>;` | 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 1197 | `              allChapterList.addAll(pageChapterList);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(页 章节 列表); |
| 1198 | `            }` | 闭合大括号，结束当前代码块 |
| 1199 | `          }` | 闭合大括号，结束当前代码块 |
| 1200 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 1201 | `          AppLog.instance.put('并发处理异常: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('并发处理异常: $e', error: e); |
| 1202 | `        }` | 闭合大括号，结束当前代码块 |
| 1203 | `      }` | 闭合大括号，结束当前代码块 |
| 1204 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1205 | `      var chapterList = allChapterList;` | 声明自动类型推断的变量 章节 列表 |
| 1206 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1207 | `      // 参考项目：转换为BookChapter对象（参考项目第217-256行）` | 注释说明：参考项目：转换为章节(BookChapter)对象（参考项目第217-256行） |
| 1208 | `      // 参考项目不过滤"最新章节"，保留所有解析到的章节` | 注释说明：参考项目不过滤"最新章节"，保留所有解析到的章节 |
| 1209 | `      var chapters = <BookChapter>[];` | 声明自动类型推断的变量 章节列表 |
| 1210 | `      for (int i = 0; i < chapterList.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节 列表.长度(length); 循环变量 i++ |
| 1211 | `        final chapterData = chapterList[i];` | 声明不可重新赋值的变量 chapterData |
| 1212 | `        final chapterName = chapterData['chapterName'] ?? '';` | 声明不可重新赋值的变量 章节 名称 |
| 1213 | `        final isVolumeStr = chapterData['isVolume'] ?? '0';` | 声明不可重新赋值的变量 isVolumeStr |
| 1214 | `        final isVolume =` | 上一表达式的续行：不可重新赋值(final) isVolume = |
| 1215 | `            isVolumeStr == '1' \|\| isVolumeStr.toLowerCase() == 'true';` | 续行赋值：将 = '1' \|\| isVolumeStr.toLowerCase() == '真(true)'; 赋给 isVolumeStr |
| 1216 | `        final chapterUrl = chapterData['chapterUrl'];` | 声明不可重新赋值的变量 章节链接 |
| 1217 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1218 | `        // 参考项目逻辑：` | 注释说明：参考项目逻辑： |
| 1219 | `        // 1. 卷名（isVolume）不需要URL，即使URL为空也会添加` | 注释说明：1. 卷名（isVolume）不需要统一资源链接(URL)，即使统一资源链接(URL)为空也会添加 |
| 1220 | `        // 2. 非卷名章节必须有URL` | 注释说明：2. 非卷名章节必须有统一资源链接(URL) |
| 1221 | `        if (!isVolume && (chapterUrl == null \|\| chapterUrl.isEmpty)) {` | 条件判断 如果(if)：!isVolume 且 (chapterUrl 等于 null 或 chapterUrl.isEmpty) |
| 1222 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 1223 | `        }` | 闭合大括号，结束当前代码块 |
| 1224 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1225 | `        // 过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接）` | 注释说明：过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接） |
| 1226 | `        final trimmedName = chapterName.trim().replaceAll(RegExp(r'\s+'), '');` | 声明不可重新赋值的变量 trimmedName：调用 章节 名称.去除首尾空白(...) → 修剪 |
| 1227 | `        if (chapterName.contains('上一页') \|\|` | 条件判断 如果(if)：章节 名称.是否包含('上一页') 或 |
| 1228 | `            chapterName.contains('下一页') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('下一页') \|\| |
| 1229 | `            chapterName.contains('上一章') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('上一章') \|\| |
| 1230 | `            chapterName.contains('下一章') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('下一章') \|\| |
| 1231 | `            trimmedName.isEmpty) {` | trimmedName.是否为空) { |
| 1232 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 1233 | `        }` | 闭合大括号，结束当前代码块 |
| 1234 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1235 | `        // 参考项目：构建章节URL（参考项目第222-243行）` | 注释说明：参考项目：构建章节统一资源链接(URL)（参考项目第222-243行） |
| 1236 | `        // 参考项目保存的是解析出来的原始URL，在getAbsoluteURL()中转换` | 注释说明：参考项目保存的是解析出来的原始统一资源链接(URL)，在getAbsoluteURL()中转换 |
| 1237 | `        // 为了兼容性，我们这里仍然拼接为绝对URL，但不做额外规范化` | 注释说明：为了兼容性，我们这里仍然拼接为绝对统一资源链接(URL)，但不做额外规范化 |
| 1238 | `        String finalUrl = '';` | 字符串(String) finalUrl = '' |
| 1239 | `        if (chapterUrl != null && chapterUrl.isNotEmpty) {` | 条件判断 如果(if)：章节链接 不等于 空值(null) 且 章节链接.是否非空 |
| 1240 | `          // 参考项目：bookChapter.url = analyzeRule.getString(urlRule)` | 注释说明：参考项目：书籍 章节.链接 = 分析 规则.获取 字符串(String)(URL 规则) |
| 1241 | `          // 拼接为绝对URL，但不做额外规范化处理` | 注释说明：拼接为绝对统一资源链接(URL)，但不做额外规范化处理 |
| 1242 | `          finalUrl = _repairChapterUrlWithBookVariables(` | 将 _repairChapterUrlWithBookVariables( 赋值给 finalUrl（调用 _repairChapterUrlWithBookVariables → 修复 章节 统一资源链接(URL) With 书籍 变量表） |
| 1243 | `            NetworkService.joinUrl(effectiveBaseUrl, chapterUrl),` | 链式调用起始于 网络服务(NetworkService)（Network 服务），后续行继续该表达式：网络服务(NetworkService).拼接 URL(effectiveBaseUrl, 章节链接), |
| 1244 | `            book,` | 签名/调用续行参数：书籍 |
| 1245 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1246 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1247 | `          // 参考项目：如果 URL 为空，根据是否是卷名来设置` | 注释说明：参考项目：如果 统一资源链接(URL) 为空，根据是否是卷名来设置 |
| 1248 | `          if (isVolume) {` | 条件判断 如果(if)：isVolume |
| 1249 | `            // 参考项目：如果是卷名且URL为空，使用标题+索引作为URL` | 注释说明：参考项目：如果是卷名且统一资源链接(URL)为空，使用标题+索引作为统一资源链接(URL) |
| 1250 | `            finalUrl = '$chapterName$i';` | finalUrl = '$章节 名称$循环变量 i' |
| 1251 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1252 | `            // 参考项目：非卷名但URL为空，使用baseUrl替代` | 注释说明：参考项目：非卷名但统一资源链接(URL)为空，使用基础链接替代 |
| 1253 | `            finalUrl = effectiveBaseUrl;` | 将 effectiveBaseUrl 赋值给 finalUrl |
| 1254 | `          }` | 闭合大括号，结束当前代码块 |
| 1255 | `        }` | 闭合大括号，结束当前代码块 |
| 1256 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1257 | `        // 参考项目：章节标题直接使用原始标题` | 注释说明：参考项目：章节标题直接使用原始标题 |
| 1258 | `        final chapterTitle =` | 上一表达式的续行：不可重新赋值(final) 章节 标题 = |
| 1259 | `            chapterName.isNotEmpty ? chapterName : '第${i + 1}章';` | 章节 名称.是否非空 ? 章节 名称 : '第${循环变量 i + 1}章' |
| 1260 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1261 | `        final chapter = BookChapter(` | 声明不可重新赋值的变量 章节：调用 章节(BookChapter)(...) → 书籍 章节 |
| 1262 | `          url: finalUrl,` | 命名实参 链接: finalUrl（统一资源链接(URL)） |
| 1263 | `          title: chapterTitle,` | 命名实参 标题: 章节 标题（标题） |
| 1264 | `          bookUrl: book.bookUrl,` | 命名实参 书籍链接: 书籍.书籍链接（书籍 统一资源链接(URL)） |
| 1265 | `          baseUrl: source.bookSourceUrl,` | 命名实参 基础链接: 书源.书源链接（base 统一资源链接(URL)） |
| 1266 | `          index: chapters.length, // 使用过滤后的索引` | 命名实参 索引: 章节列表.长度(length)（索引）；行尾注释：使用过滤后的索引 |
| 1267 | `          isVolume: isVolume, // 设置卷名标志` | 命名实参 isVolume: isVolume（是(is) 体积）；行尾注释：设置卷名标志 |
| 1268 | `          isVip: chapterData['isVip'] == 'true' \|\| chapterData['isVip'] == '1',` | 命名实参 isVip: chapterData['isVip'] == '真(true)' \|\| chapterData['isVip'] == '1'（是(is) Vip） |
| 1269 | `          tag: chapterData['updateTime'],` | 命名实参 tag: chapterData['updateTime'] |
| 1270 | `          duration:` | 时长: |
| 1271 | `              _parseDurationString(chapterData['duration']), // Phase 3：音视频时长` | 调用 _解析 时长 字符串(String)(...)：_解析 时长 字符串(String)(chapterData['时长']),（解析 时长 字符串(字符串(String))）；行尾注释：相位 3：音视频时长 |
| 1272 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1273 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1274 | `        chapters.add(chapter);` | 链式调用起始于 章节列表（章节列表），后续行继续该表达式：章节列表.添加(章节); |
| 1275 | `      }` | 闭合大括号，结束当前代码块 |
| 1276 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1277 | `      final previewCount = chapters.length < 5 ? chapters.length : 5;` | 声明不可重新赋值的变量 previewCount |
| 1278 | `      for (int i = 0; i < previewCount; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < previewCount; 循环变量 i++ |
| 1279 | `        final chapter = chapters[i];` | 声明不可重新赋值的变量 章节 |
| 1280 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1281 | `          '目录预览 ${i + 1}: title=${chapter.title}, url=${chapter.url}',` | 以字符串 '目录预览 ${循环变量 i + 1}: 标题=${章节.标题}, … 起始的表达式：, |
| 1282 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1283 | `      }` | 闭合大括号，结束当前代码块 |
| 1284 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1285 | `      // 参考项目：如果章节列表为空，抛出异常` | 注释说明：参考项目：如果章节列表为空，抛出异常 |
| 1286 | `      if (chapters.isEmpty) {` | 条件判断 如果(if)：章节列表.是否为空 |
| 1287 | `        throw TocEmptyException('章节列表为空');` | 定义方法 目录(TOC) 空 异常：返回 抛出(throw)；位置参数 1 个。语义：目录(目录(TOC)) 空 异常 |
| 1288 | `      }` | 闭合大括号，结束当前代码块 |
| 1289 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1290 | `      // 参考项目：反转逻辑（参考项目第119-120行）` | 注释说明：参考项目：反转逻辑（参考项目第119-120行） |
| 1291 | `      // 如果 !reverse，反转章节列表` | 注释说明：如果 !reverse，反转章节列表 |
| 1292 | `      if (!reverse) {` | 条件判断 如果(if)：!reverse |
| 1293 | `        chapters = chapters.reversed.toList();` | 将 章节列表.reversed.转为列表() 赋值给 章节列表（调用 转为列表 → to 列表） |
| 1294 | `      }` | 闭合大括号，结束当前代码块 |
| 1295 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1296 | `      // 去重：保留第一个发现的章节` | 注释说明：去重：保留第一个发现的章节 |
| 1297 | `      // LinkedHashSet 保留第一次出现的元素` | 注释说明：LinkedHashSet 保留第一次出现的元素 |
| 1298 | `      final originalCount = chapters.length;` | 声明不可重新赋值的变量 originalCount |
| 1299 | `      chapters = LinkedHashSet<BookChapter>.from(chapters).toList();` | 将 LinkedHashSet<章节(BookChapter)>.from(章节列表).转为列表() 赋值给 章节列表（调用 from/转为列表 → to 列表） |
| 1300 | `      if (chapters.length < originalCount) {` | 条件判断 如果(if)：章节列表.长度(length) < originalCount |
| 1301 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1302 | `            .put('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）');` | 链式调用延续：.写入数据库(put)('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）'); |
| 1303 | `        final urlCounts = <String, int>{};` | 声明不可重新赋值的变量 urlCounts |
| 1304 | `        for (final chapter in chapters.length == originalCount` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 章节 属于(in) 章节列表.长度(length) == originalCount |
| 1305 | `            ? chapters` | 上一表达式的续行：? 章节列表 |
| 1306 | `            : chapterList.map((item) {` | 三元表达式为假时取值：章节 列表.映射(map)((条目) { |
| 1307 | `                final title = item['chapterName'] ?? '';` | 声明不可重新赋值的变量 标题 |
| 1308 | `                final url = item['chapterUrl'] ?? '';` | 声明不可重新赋值的变量 链接 |
| 1309 | `                return BookChapter(` | 返回调用 章节(BookChapter)(...) 的结果（语义：书籍 章节） |
| 1310 | `                    url: url, title: title, bookUrl: book.bookUrl);` | 命名实参 链接: 链接, 标题: 标题, 书籍链接: 书籍.书籍链接);（统一资源链接(URL)） |
| 1311 | `              })) {` | 闭合代码块并衔接后续语句：)) { |
| 1312 | `          urlCounts[chapter.url] = (urlCounts[chapter.url] ?? 0) + 1;` | urlCounts[章节.链接] = (urlCounts[章节.链接] ?? 0) + 1 |
| 1313 | `        }` | 闭合大括号，结束当前代码块 |
| 1314 | `        final duplicates =` | 上一表达式的续行：不可重新赋值(final) duplicates = |
| 1315 | `            urlCounts.entries.where((entry) => entry.value > 1).take(5);` | 链式调用起始于 urlCounts.条目集合（条目集合），后续行继续该表达式：urlCounts.条目集合.筛选(where)((条目) => 条目.值 > 1).截取(5); |
| 1316 | `        for (final entry in duplicates) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 条目 属于(in) duplicates |
| 1317 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1318 | `            '重复章节URL: url=${entry.key}, count=${entry.value}',` | 以字符串 '重复章节统一资源链接(URL): 链接=${条目.键}, 数量=${entr… 起始的表达式：, |
| 1319 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1320 | `        }` | 闭合大括号，结束当前代码块 |
| 1321 | `      }` | 闭合大括号，结束当前代码块 |
| 1322 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1323 | `      // 参考项目：如果 !book.getReverseToc()，再次反转列表（参考项目第126-128行）` | 注释说明：参考项目：如果 !书籍.getReverseToc()，再次反转列表（参考项目第126-128行） |
| 1324 | `      if (!book.getReverseToc()) {` | 条件判断 如果(if)：!书籍.getReverseToc() |
| 1325 | `        chapters = chapters.reversed.toList();` | 将 章节列表.reversed.转为列表() 赋值给 章节列表（调用 转为列表 → to 列表） |
| 1326 | `        AppLog.instance.put('反转章节列表（!book.getReverseToc()）');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('反转章节列表（!书籍.getReverseToc()）'); |
| 1327 | `      }` | 闭合大括号，结束当前代码块 |
| 1328 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1329 | `      // 重新设置索引` | 注释说明：重新设置索引 |
| 1330 | `      for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 1331 | `        chapters[i] = chapters[i].copyWith(index: i);` | 调用 copyWith(...)：章节列表[循环变量 i] = 章节列表[循环变量 i].copyWith(索引: 循环变量 i)（复制 With） |
| 1332 | `      }` | 闭合大括号，结束当前代码块 |
| 1333 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1334 | `      // 参考项目：formatJs 格式化章节标题` | 注释说明：参考项目：格式化 JS脚本 格式化章节标题 |
| 1335 | `      final formatJs = effectiveTocRule?.formatJs;` | 声明不可重新赋值的变量 格式化 JS脚本 |
| 1336 | `      if (formatJs != null && formatJs.isNotEmpty) {` | 条件判断 如果(if)：格式化 JS脚本 不等于 空值(null) 且 格式化 JS脚本.是否非空 |
| 1337 | `        AppLog.instance.put('使用 formatJs 格式化章节标题');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('使用 formatJs 格式化章节标题'); |
| 1338 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1339 | `          for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 1340 | `            final chapter = chapters[i];` | 声明不可重新赋值的变量 章节 |
| 1341 | `            final bindings = <String, dynamic>{` | 声明不可重新赋值的变量 bindings |
| 1342 | `              'gInt': 0,` | 映射(Map) 条目 'gInt': 0, |
| 1343 | `              'index': i + 1, // 参考项目：index 从 1 开始` | 映射(Map) 条目 '索引': 循环变量 i + 1,；行尾注释：参考项目：索引 从 1 开始 |
| 1344 | `              'chapter': {` | 映射(Map) 条目 '章节': { |
| 1345 | `                'title': chapter.title,` | 映射(Map) 条目 '标题': 章节.标题, |
| 1346 | `                'url': chapter.url,` | 映射(Map) 条目 '链接': 章节.链接, |
| 1347 | `                'index': chapter.index,` | 映射(Map) 条目 '索引': 章节.索引, |
| 1348 | `              },` | 结束上一个列表/参数项 |
| 1349 | `              'title': chapter.title,` | 映射(Map) 条目 '标题': 章节.标题, |
| 1350 | `            };` | 闭合代码块并衔接后续语句：; |
| 1351 | `            final result = await JSEngine.evalJS(formatJs, bindings: bindings);` | 声明不可重新赋值的变量 结果：等待(await) 调用 JS脚本 引擎.evalJS(...) → eval JavaScript脚本(JS)脚本 |
| 1352 | `            if (result != null && result.toString().isNotEmpty) {` | 条件判断 如果(if)：结果 不等于 空值(null) 且 结果.转为字符串().是否非空 |
| 1353 | `              chapters[i] = chapter.copyWith(title: result.toString());` | 调用 copyWith/转为字符串(...)：章节列表[循环变量 i] = 章节.copyWith(标题: 结果.转为字符串())（复制 With to 字符串(字符串(String))） |
| 1354 | `              AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1355 | `                  '格式化章节 ${i + 1}: ${chapter.title} -> ${result.toString()}');` | 以字符串 '格式化章节 ${循环变量 i + 1}: ${章节.标题} -> ${r… 起始的表达式：); |
| 1356 | `            }` | 闭合大括号，结束当前代码块 |
| 1357 | `          }` | 闭合大括号，结束当前代码块 |
| 1358 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 1359 | `          AppLog.instance.put('格式化标题出错: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('格式化标题出错: $e', error: e); |
| 1360 | `        }` | 闭合大括号，结束当前代码块 |
| 1361 | `      }` | 闭合大括号，结束当前代码块 |
| 1362 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1363 | `      // 参考项目：更新书籍信息（参考项目第154-164行）` | 注释说明：参考项目：更新书籍信息（参考项目第154-164行） |
| 1364 | `      // 获取替换规则处理器` | 注释说明：获取替换规则处理器 |
| 1365 | `      final contentProcessor = ContentProcessor.get(book);` | 声明不可重新赋值的变量 contentProcessor：调用 ContentProcessor.读取(getter)(...) → 获取 |
| 1366 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1367 | `      // 更新 durChapterTitle（参考项目第154行）` | 注释说明：更新 durChapterTitle（参考项目第154行） |
| 1368 | `      if (chapters.isNotEmpty) {` | 条件判断 如果(if)：章节列表.是否非空 |
| 1369 | `        final currentChapterIndex = book.durChapterIndex;` | 声明不可重新赋值的变量 当前 章节 索引 |
| 1370 | `        if (currentChapterIndex >= 0 && currentChapterIndex < chapters.length) {` | 条件判断 如果(if)：当前 章节 索引 > = 0 且 当前 章节 索引 < 章节列表.长度(length) |
| 1371 | `          final currentChapter = chapters[currentChapterIndex];` | 声明不可重新赋值的变量 当前 章节 |
| 1372 | `          final displayTitle = await contentProcessor.getDisplayTitle(` | 声明不可重新赋值的变量 显示 标题：等待(await) 调用 contentProcessor.获取 显示 标题(...) → 获取 显示 标题 |
| 1373 | `            currentChapter,` | 签名/调用续行参数：当前 章节 |
| 1374 | `            useReplace: book.getUseReplaceRule(),` | 命名实参 useReplace: 书籍.getUseReplaceRule()（use 替换） |
| 1375 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1376 | `          book.durChapterTitle = displayTitle;` | 将 显示 标题 赋值给 书籍.durChapterTitle |
| 1377 | `        } else if (chapters.isNotEmpty) {` | 闭合上一代码块并开始 否则(else) 如果(if) (章节列表.是否非空) { |
| 1378 | `          // 如果索引超出范围，使用最后一个章节` | 注释说明：如果索引超出范围，使用最后一个章节 |
| 1379 | `          final lastChapter = chapters.last;` | 声明不可重新赋值的变量 最后 章节 |
| 1380 | `          final displayTitle = await contentProcessor.getDisplayTitle(` | 声明不可重新赋值的变量 显示 标题：等待(await) 调用 contentProcessor.获取 显示 标题(...) → 获取 显示 标题 |
| 1381 | `            lastChapter,` | 签名/调用续行参数：最后 章节 |
| 1382 | `            useReplace: book.getUseReplaceRule(),` | 命名实参 useReplace: 书籍.getUseReplaceRule()（use 替换） |
| 1383 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1384 | `          book.durChapterTitle = displayTitle;` | 将 显示 标题 赋值给 书籍.durChapterTitle |
| 1385 | `        }` | 闭合大括号，结束当前代码块 |
| 1386 | `      }` | 闭合大括号，结束当前代码块 |
| 1387 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1388 | `      // 更新 lastCheckCount 和 latestChapterTime（参考项目第156-158行）` | 注释说明：更新 最后 检查 数量 和 latestChapterTime（参考项目第156-158行） |
| 1389 | `      if (book.totalChapterNum < chapters.length) {` | 条件判断 如果(if)：书籍.totalChapterNum < 章节列表.长度(length) |
| 1390 | `        book.lastCheckCount = chapters.length - book.totalChapterNum;` | 将 章节列表.长度(length) - 书籍.totalChapterNum 赋值给 书籍.最后 检查 数量 |
| 1391 | `        book.latestChapterTime = DateTime.now().millisecondsSinceEpoch;` | 将 DateTime.now().millisecondsSinceEpoch 赋值给 书籍.latestChapterTime |
| 1392 | `      }` | 闭合大括号，结束当前代码块 |
| 1393 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1394 | `      // 更新 lastCheckTime 和 totalChapterNum（参考项目第160-161行）` | 注释说明：更新 lastCheckTime 和 totalChapterNum（参考项目第160-161行） |
| 1395 | `      book.lastCheckTime = DateTime.now().millisecondsSinceEpoch;` | 将 DateTime.now().millisecondsSinceEpoch 赋值给 书籍.lastCheckTime |
| 1396 | `      book.totalChapterNum = chapters.length;` | 将 章节列表.长度(length) 赋值给 书籍.totalChapterNum |
| 1397 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1398 | `      // 更新 latestChapterTitle（参考项目第162-164行）` | 注释说明：更新 latestChapterTitle（参考项目第162-164行） |
| 1399 | `      if (chapters.isNotEmpty) {` | 条件判断 如果(if)：章节列表.是否非空 |
| 1400 | `        final simulatedIndex = book.simulatedTotalChapterNum() - 1;` | 声明不可重新赋值的变量 simulatedIndex：调用 书籍.simulatedTotalChapterNum(...) → simulated Total 章节 编号 |
| 1401 | `        final latestChapterIndex =` | 上一表达式的续行：不可重新赋值(final) latestChapterIndex = |
| 1402 | `            simulatedIndex >= 0 && simulatedIndex < chapters.length` | 上一表达式的续行：simulatedIndex >= 0 && simulatedIndex < 章节列表.长度(length) |
| 1403 | `                ? simulatedIndex` | 上一表达式的续行：? simulatedIndex |
| 1404 | `                : chapters.length - 1;` | 三元表达式为假时取值：章节列表.长度(length) - 1; |
| 1405 | `        final latestChapter = chapters[latestChapterIndex];` | 声明不可重新赋值的变量 latestChapter |
| 1406 | `        final displayTitle = await contentProcessor.getDisplayTitle(` | 声明不可重新赋值的变量 显示 标题：等待(await) 调用 contentProcessor.获取 显示 标题(...) → 获取 显示 标题 |
| 1407 | `          latestChapter,` | 签名/调用续行参数：latestChapter |
| 1408 | `          useReplace: book.getUseReplaceRule(),` | 命名实参 useReplace: 书籍.getUseReplaceRule()（use 替换） |
| 1409 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1410 | `        book.latestChapterTitle = displayTitle;` | 将 显示 标题 赋值给 书籍.latestChapterTitle |
| 1411 | `      }` | 闭合大括号，结束当前代码块 |
| 1412 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1413 | `      // 参考项目：getWordCount（参考项目第272-286行）` | 注释说明：参考项目：获取 单词 数量（参考项目第272-286行） |
| 1414 | `      // 从数据库获取已存在的章节字数` | 注释说明：从数据库获取已存在的章节字数 |
| 1415 | `      await getWordCount(chapters, book);` | 调用 获取 单词 数量(...)（等待异步完成） → 获取 单词 数量 |
| 1416 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1417 | `      AppLog.instance.put('获取章节列表成功: 共 ${chapters.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表成功: 共 ${chapters.length} 个章节'); |
| 1418 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1419 | `      // 保存章节列表到数据库` | 注释说明：保存章节列表到数据库 |
| 1420 | `      await saveChapters(chapters);` | 调用 保存 章节列表(...)（等待异步完成） → 保存 章节列表 |
| 1421 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1422 | `      // 更新书籍信息到数据库` | 注释说明：更新书籍信息到数据库 |
| 1423 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1424 | `        await updateBook(book);` | 调用 更新 书籍(...)（等待异步完成） → 更新 书籍 |
| 1425 | `      } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 1426 | `        AppLog.instance.put('更新书籍信息失败: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('更新书籍信息失败: $e', error: e); |
| 1427 | `      }` | 闭合大括号，结束当前代码块 |
| 1428 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1429 | `      return chapters;` | 返回 章节列表 |
| 1430 | `    } catch (e, stackTrace) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e, stackTrace |
| 1431 | `      AppLog.instance.put('获取章节列表失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败', error: e); |
| 1432 | `      AppLog.instance.put('错误堆栈: $stackTrace');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('错误堆栈: $stackTrace'); |
| 1433 | `      // 如果获取失败，尝试从数据库读取` | 注释说明：如果获取失败，尝试从数据库读取 |
| 1434 | `      return await _getLocalChapters(book.bookUrl);` | 返回异步调用 _获取 本地 章节列表(...) 的结果（语义：获取 本地 章节列表） |
| 1435 | `    }` | 闭合大括号，结束当前代码块 |
| 1436 | `  }` | 闭合大括号，结束当前代码块 |
| 1437 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1438 | `  /// 获取章节列表但不保存到数据库（用于探索页面）` | 文档注释：说明其后代码的用途 |
| 1439 | `  Future<List<BookChapter>> getChapterListWithoutSave(` | 【承接上方文档】获取章节列表但不保存到数据库（用于探索页面） → 定义方法 getChapterListWithoutSave：返回 异步结果(Future)<列表(List)<章节(BookChapter)>>；无参数（异步）。语义：获取 章节 列表 Without 保存 |
| 1440 | `    Book book, {` | 书籍(Book) 类型参数 书籍，其后 { 开启命名参数块（书籍） |
| 1441 | `    bool loadAllPages = true,` | 布尔(bool) 类型参数 加载 全部 分页，默认值 真(true)（加载 全部 分页） |
| 1442 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 1443 | `    if (book.isLocal) {` | 条件判断 如果(if)：书籍.isLocal |
| 1444 | `      // 本地书籍从数据库读取章节` | 注释说明：本地书籍从数据库读取章节 |
| 1445 | `      return await _getLocalChapters(book.bookUrl);` | 返回异步调用 _获取 本地 章节列表(...) 的结果（语义：获取 本地 章节列表） |
| 1446 | `    }` | 闭合大括号，结束当前代码块 |
| 1447 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1448 | `    final source = await _bookSourceService.getBookSourceByUrl(book.origin);` | 声明不可重新赋值的变量 书源：等待(await) 调用 _书籍 书源 服务.getBookSourceByUrl(...) → 获取 书籍 书源 By 统一资源链接(URL) |
| 1449 | `    if (source == null) {` | 条件判断 如果(if)：书源 等于 空值(null) |
| 1450 | `      AppLog.instance.put('获取章节列表失败: 书源不存在 (origin: ${book.origin})');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败: 书源不存在 (来源: ${书籍.来源})'); |
| 1451 | `      return [];` | 返回 []（列表字面量） |
| 1452 | `    }` | 闭合大括号，结束当前代码块 |
| 1453 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1454 | `    if (source.ruleToc == null) {` | 条件判断 如果(if)：书源.目录规则 等于 空值(null) |
| 1455 | `      AppLog.instance.put('获取章节列表失败: 目录规则为空 (书源: ${source.bookSourceName})');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败: 目录规则为空 (书源: ${source.bookSourceName})')… |
| 1456 | `      return [];` | 返回 []（列表字面量） |
| 1457 | `    }` | 闭合大括号，结束当前代码块 |
| 1458 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1459 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1460 | `      final chapterVariables = _buildRuleVariables(book);` | 声明不可重新赋值的变量 章节 变量表：调用 _构建 规则 变量表(...) → 构建 规则 变量表 |
| 1461 | `      // 使用tocUrl或bookUrl` | 注释说明：使用目录(TOC) URL或书籍链接 |
| 1462 | `      final tocUrl = book.tocUrl.isNotEmpty ? book.tocUrl : book.bookUrl;` | 声明不可重新赋值的变量 目录(TOC) URL |
| 1463 | `      AppLog.instance.put('开始获取章节列表: tocUrl=$tocUrl, bookUrl=${book.bookUrl}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('开始获取章节列表: 目录(TOC) URL=$目录(TOC) URL, 书籍链接=${书籍.书籍链接}… |
| 1464 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1465 | `      // 发送请求` | 注释说明：发送请求 |
| 1466 | `      final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 1467 | `        tocUrl,` | 签名/调用续行参数：目录(TOC) URL |
| 1468 | `        headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 1469 | `        retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 1470 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1471 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1472 | `      final html = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 网页内容：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 1473 | `      AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1474 | `          .put('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}');` | 链式调用延续：.写入数据库(put)('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}'); |
| 1475 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1476 | `      if (html.isEmpty) {` | 条件判断 如果(if)：网页内容.是否为空 |
| 1477 | `        AppLog.instance.put('获取章节列表失败: 响应内容为空');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败: 响应内容为空'); |
| 1478 | `        throw TocEmptyException('获取章节列表失败: 响应内容为空');` | 定义方法 目录(TOC) 空 异常：返回 抛出(throw)；位置参数 1 个；参数名: 获取章节列表失败。语义：目录(目录(TOC)) 空 异常 |
| 1479 | `      }` | 闭合大括号，结束当前代码块 |
| 1480 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1481 | `      // 检查HTML中是否包含可能的目录容器` | 注释说明：检查网页标记文本(HTML)中是否包含可能的目录容器 |
| 1482 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1483 | `          '检查HTML结构: 是否包含id="list": ${html.contains('id="list"') \|\| html.contains("id='list'")}');` | 以字符串 '检查网页标记文本(HTML)结构: 是否包含编号(id)="list": ${网页内容.contain… 起始的表达式：编号(id)="list"') \|\| 网页内容.是否包含("编号(id)='list'")}'); |
| 1484 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1485 | `          '检查HTML结构: 是否包含class="list": ${html.contains('class="list"') \|\| html.contains("class='list'")}');` | 以字符串 '检查网页标记文本(HTML)结构: 是否包含类(class)="list": ${网页内容.cont… 起始的表达式：类(class)="list"') \|\| 网页内容.是否包含("类(class)='list'")}'); |
| 1486 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1487 | `          '检查HTML结构: 是否包含<dd>标签: ${html.contains('<dd>') \|\| html.contains('<DD>')}');` | 以字符串 '检查网页标记文本(HTML)结构: 是否包含<dd>标签: ${网页内容.是否包含(' 起始的表达式：<dd>') \|\| 网页内容.是否包含('<DD>')}'); |
| 1488 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1489 | `      // 查找所有可能的目录相关元素` | 注释说明：查找所有可能的目录相关元素 |
| 1490 | `      final listIdPattern = RegExp('id\\s*=\\s*["\']([^"\']*list[^"\']*)["\']',` | 不可重新赋值(final) 类型参数 列表 编号(id) 模式，默认值 正则表达式(RegExp)('编号(id)\\s*=\\s*["\']([^"\']*list[^"\…（列表 编号(编号(id)) 模式） |
| 1491 | `          caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1492 | `      final listIds = listIdPattern` | 上一表达式的续行：不可重新赋值(final) listIds = 列表 编号(id) 模式 |
| 1493 | `          .allMatches(html)` | 链式调用延续：.allMatches(网页内容) |
| 1494 | `          .map((m) => m.group(1))` | 链式调用延续：.映射(map)((m) => m.捕获组(1)) |
| 1495 | `          .whereType<String>()` | 链式调用延续：.筛选(where) 类型<字符串(String)>() |
| 1496 | `          .take(5)` | 链式调用延续：.截取(5) |
| 1497 | `          .toList();` | 链式调用延续：.转为列表(); |
| 1498 | `      if (listIds.isNotEmpty) {` | 条件判断 如果(if)：listIds.是否非空 |
| 1499 | `        AppLog.instance.put('HTML中找到包含"list"的id: ${listIds.join(", ")}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('网页标记文本(HTML)中找到包含"list"的编号(id): ${listIds.拼接(", ")}'); |
| 1500 | `      }` | 闭合大括号，结束当前代码块 |
| 1501 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1502 | `      final listClassPattern = RegExp(` | 声明不可重新赋值的变量 listClassPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 1503 | `          'class\\s*=\\s*["\']([^"\']*list[^"\']*)["\']',` | 以字符串 '类(class)\\s*=\\s*["\']([^"\']*list[^"\']*)… 起始的表达式：, |
| 1504 | `          caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1505 | `      final listClasses = listClassPattern` | 上一表达式的续行：不可重新赋值(final) listClasses = listClassPattern |
| 1506 | `          .allMatches(html)` | 链式调用延续：.allMatches(网页内容) |
| 1507 | `          .map((m) => m.group(1))` | 链式调用延续：.映射(map)((m) => m.捕获组(1)) |
| 1508 | `          .whereType<String>()` | 链式调用延续：.筛选(where) 类型<字符串(String)>() |
| 1509 | `          .take(5)` | 链式调用延续：.截取(5) |
| 1510 | `          .toList();` | 链式调用延续：.转为列表(); |
| 1511 | `      if (listClasses.isNotEmpty) {` | 条件判断 如果(if)：listClasses.是否非空 |
| 1512 | `        AppLog.instance.put('HTML中找到包含"list"的class: ${listClasses.join(", ")}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('网页标记文本(HTML)中找到包含"list"的类(class): ${listClasses.拼接(", ")}'… |
| 1513 | `      }` | 闭合大括号，结束当前代码块 |
| 1514 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1515 | `      // 解析章节列表` | 注释说明：解析章节列表 |
| 1516 | `      // 参考项目：baseUrl使用tocUrl（实际请求的URL），而不是书源的基础URL` | 注释说明：参考项目：基础链接使用目录(TOC) URL（实际请求的统一资源链接(URL)），而不是书源的基础统一资源链接(URL) |
| 1517 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1518 | `          '开始解析章节列表: ruleToc=${source.ruleToc?.toJson()}, chapterList规则=${source.ruleToc?.chapterList}');` | 以字符串 '开始解析章节列表: 目录规则=${书源.目录规则?.toJ… 起始的表达式：); |
| 1519 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1520 | `      // 确定有效的baseUrl：如果tocUrl不是有效的绝对URL，使用source.bookSourceUrl` | 注释说明：确定有效的基础链接：如果目录(TOC) URL不是有效的绝对统一资源链接(URL)，使用书源.书源链接 |
| 1521 | `      String? effectiveBaseUrl = tocUrl;` | 字符串(String)? effectiveBaseUrl = 目录(TOC) URL |
| 1522 | `      if (!tocUrl.isAbsUrl()) {` | 条件判断 如果(if)：!目录(TOC) URL.isAbsUrl() |
| 1523 | `        // 如果source.bookSourceUrl也是有效的绝对URL，使用它；否则尝试从tocUrl构建` | 注释说明：如果书源.书源链接也是有效的绝对统一资源链接(URL)，使用它；否则尝试从目录(TOC) URL构建 |
| 1524 | `        if (source.bookSourceUrl.isAbsUrl()) {` | 条件判断 如果(if)：书源.书源链接.isAbsUrl() |
| 1525 | `          effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 1526 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1527 | `              'tocUrl不是绝对URL，使用source.bookSourceUrl作为baseUrl: $effectiveBaseUrl');` | 以字符串 '目录(TOC) URL不是绝对统一资源链接(URL)，使用书源.书源链接作为b… 起始的表达式：); |
| 1528 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1529 | `          // 如果两者都不是绝对URL，尝试从tocUrl构建完整的URL` | 注释说明：如果两者都不是绝对统一资源链接(URL)，尝试从目录(TOC) URL构建完整的统一资源链接(URL) |
| 1530 | `          // 如果tocUrl是相对路径，使用source.bookSourceUrl作为基础` | 注释说明：如果目录(TOC) URL是相对路径，使用书源.书源链接作为基础 |
| 1531 | `          try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1532 | `            effectiveBaseUrl =` | 上一表达式的续行：effectiveBaseUrl = |
| 1533 | `                NetworkService.joinUrl(source.bookSourceUrl, tocUrl);` | 链式调用起始于 网络服务(NetworkService)（Network 服务），后续行继续该表达式：网络服务(NetworkService).拼接 URL(书源.书源链接, 目录(TOC) URL); |
| 1534 | `            if (!effectiveBaseUrl.isAbsUrl()) {` | 条件判断 如果(if)：!effectiveBaseUrl.isAbsUrl() |
| 1535 | `              // 如果仍然无效，使用source.bookSourceUrl` | 注释说明：如果仍然无效，使用书源.书源链接 |
| 1536 | `              effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 1537 | `            }` | 闭合大括号，结束当前代码块 |
| 1538 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1539 | `                'tocUrl和source.bookSourceUrl都不是绝对URL，尝试拼接后: $effectiveBaseUrl');` | 以字符串 '目录(TOC) URL和书源.书源链接都不是绝对统一资源链接(URL)，尝试拼… 起始的表达式：); |
| 1540 | `          } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 1541 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 1542 | `                '构建baseUrl失败: $e，使用source.bookSourceUrl: ${source.bookSourceUrl}');` | 以字符串 '构建基础链接失败: $异常对象 e，使用书源.书源链接:… 起始的表达式：); |
| 1543 | `            effectiveBaseUrl = source.bookSourceUrl;` | 将 书源.书源链接 赋值给 effectiveBaseUrl |
| 1544 | `          }` | 闭合大括号，结束当前代码块 |
| 1545 | `        }` | 闭合大括号，结束当前代码块 |
| 1546 | `      }` | 闭合大括号，结束当前代码块 |
| 1547 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1548 | `      // 最终验证：确保effectiveBaseUrl是有效的绝对URL` | 注释说明：最终验证：确保effectiveBaseUrl是有效的绝对统一资源链接(URL) |
| 1549 | `      if (!effectiveBaseUrl.isAbsUrl()) {` | 条件判断 如果(if)：!effectiveBaseUrl.isAbsUrl() |
| 1550 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1551 | `            .put('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败');` | 链式调用延续：.写入数据库(put)('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败'); |
| 1552 | `      }` | 闭合大括号，结束当前代码块 |
| 1553 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1554 | `      // 首先尝试使用原始规则获取第一页，如果失败则使用降级规则` | 注释说明：首先尝试使用原始规则获取第一页，如果失败则使用降级规则 |
| 1555 | `      TocRule? effectiveTocRule = source.ruleToc;` | 目录(TOC) 规则? effectiveTocRule = 书源.目录规则 |
| 1556 | `      String? fallbackChapterListRule;` | 字符串(String)? 回退/降级 章节 列表 规则 |
| 1557 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1558 | `      // 检查原始规则是否能匹配到章节` | 注释说明：检查原始规则是否能匹配到章节 |
| 1559 | `      var testChapterList = RuleParser.parseTocRule(` | 声明自动类型推断的变量 testChapterList：调用 规则解析器(RuleParser).解析 目录(TOC) 规则(...) → 解析 目录(目录(TOC)) 规则 |
| 1560 | `        html,` | 签名/调用续行参数：网页内容 |
| 1561 | `        source.ruleToc,` | 签名/调用续行参数：书源.目录规则 |
| 1562 | `        baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 1563 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1564 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1565 | `      if (testChapterList.isEmpty && source.ruleToc?.chapterList != null) {` | 条件判断 如果(if)：testChapterList.是否为空 且 书源.目录规则?.章节 列表 不等于 空值(null) |
| 1566 | `        AppLog.instance.put('原始规则未匹配到章节，尝试智能降级处理');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('原始规则未匹配到章节，尝试智能降级处理'); |
| 1567 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1568 | `        // 查找降级规则` | 注释说明：查找降级规则 |
| 1569 | `        final chapterLinkPattern = RegExp(` | 声明不可重新赋值的变量 chapterLinkPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 1570 | `            '<a[^>]*href=["\']/[^"\']*\\.html["\'][^>]*>.*?</a>',` | 以字符串 '<a[^>]*href=["\']/[^"\']*\\.网页内容["\'][^… 起始的表达式：, |
| 1571 | `            caseSensitive: false,` | 区分大小写开关: 假(false), |
| 1572 | `            dotAll: true);` | 命名实参 点号 全部: 真(true));（点号 全部） |
| 1573 | `        final chapterLinkMatches = chapterLinkPattern.allMatches(html).toList();` | 声明不可重新赋值的变量 chapterLinkMatches：调用 chapterLinkPattern.allMatches(...) → 全部 Matches |
| 1574 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1575 | `        if (chapterLinkMatches.isNotEmpty) {` | 条件判断 如果(if)：chapterLinkMatches.是否非空 |
| 1576 | `          AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1577 | `              .put('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器');` | 链式调用延续：.写入数据库(put)('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器'); |
| 1578 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1579 | `          html_dom.Element? directoryContainer;` | html_dom.Element? directoryContainer |
| 1580 | `          String? containerClass;` | 字符串(String)? containerClass |
| 1581 | `          String? containerId;` | 字符串(String)? containerId |
| 1582 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1583 | `          // 首先尝试查找directoryArea容器` | 注释说明：首先尝试查找directoryArea容器 |
| 1584 | `          final doc = html_parser.parse(html);` | 声明不可重新赋值的变量 文档：调用 HTML 解析器.parse(...) → 解析 |
| 1585 | `          final directoryPattern = RegExp(` | 声明不可重新赋值的变量 目录(directory) 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 1586 | `              'class\\s*=\\s*["\'][^"\']*directory[^"\']*["\']',` | 以字符串 '类(class)\\s*=\\s*["\'][^"\']*目录(directory)[^"\… 起始的表达式：, |
| 1587 | `              caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1588 | `          final directoryMatches = directoryPattern.allMatches(html);` | 声明不可重新赋值的变量 directoryMatches：调用 目录(directory) 模式.allMatches(...) → 全部 Matches |
| 1589 | `          if (directoryMatches.isNotEmpty) {` | 条件判断 如果(if)：directoryMatches.是否非空 |
| 1590 | `            final match = directoryMatches.first;` | 声明不可重新赋值的变量 match |
| 1591 | `            final matchHtml = html.substring(match.start, match.end);` | 声明不可重新赋值的变量 matchHtml |
| 1592 | `            final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 1593 | `                caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1594 | `            final classMatch = classPattern.firstMatch(matchHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 1595 | `            if (classMatch != null) {` | 条件判断 如果(if)：classMatch 不等于 空值(null) |
| 1596 | `              final allClasses =` | 上一表达式的续行：不可重新赋值(final) allClasses = |
| 1597 | `                  classMatch.group(1)?.split(RegExp(r'\s+')) ?? [];` | 链式调用起始于 classMatch，后续行继续该表达式：classMatch.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')) ?? []; |
| 1598 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 1599 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 1600 | `                orElse: () => '',` | 命名实参 orElse: () => ''（or Else） |
| 1601 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1602 | `              if (dirClass.isNotEmpty) {` | 条件判断 如果(if)：dirClass.是否非空 |
| 1603 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 1604 | `                    HtmlParser.selectElement(doc, 'div.$dirClass');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div.$dirClass'); |
| 1605 | `                containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 1606 | `                AppLog.instance.put('找到directory容器: class=$containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到directory容器: class=$containerClass'); |
| 1607 | `              }` | 闭合大括号，结束当前代码块 |
| 1608 | `            }` | 闭合大括号，结束当前代码块 |
| 1609 | `          }` | 闭合大括号，结束当前代码块 |
| 1610 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1611 | `          // 如果找到了directory容器，提取其class或id用于生成降级规则` | 注释说明：如果找到了目录(directory)容器，提取其类(class)或编号(id)用于生成降级规则 |
| 1612 | `          if (directoryContainer != null) {` | 条件判断 如果(if)：directoryContainer 不等于 空值(null) |
| 1613 | `            final dirClassAttr = directoryContainer.attributes['class'];` | 声明不可重新赋值的变量 dirClassAttr |
| 1614 | `            final dirIdAttr = directoryContainer.attributes['id'];` | 声明不可重新赋值的变量 dirIdAttr |
| 1615 | `            if (dirClassAttr != null && dirClassAttr.contains('directory')) {` | 条件判断 如果(if)：dirClassAttr 不等于 空值(null) 且 dirClassAttr.是否包含('目录(directory)') |
| 1616 | `              final allClasses = dirClassAttr.split(RegExp(r'\s+'));` | 声明不可重新赋值的变量 allClasses：调用 dirClassAttr.切分(...) → 切分 |
| 1617 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 1618 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 1619 | `                orElse: () => allClasses.first,` | 命名实参 orElse: () => allClasses.first（or Else） |
| 1620 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1621 | `              containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 1622 | `              AppLog.instance.put('从directory容器提取class: $containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取class: $containerClass'); |
| 1623 | `            }` | 闭合大括号，结束当前代码块 |
| 1624 | `            if (dirIdAttr != null) {` | 条件判断 如果(if)：dirIdAttr 不等于 空值(null) |
| 1625 | `              containerId = dirIdAttr;` | 将 dirIdAttr 赋值给 containerId |
| 1626 | `              AppLog.instance.put('从directory容器提取id: $containerId');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取id: $containerId'); |
| 1627 | `            }` | 闭合大括号，结束当前代码块 |
| 1628 | `          }` | 闭合大括号，结束当前代码块 |
| 1629 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1630 | `          // 生成降级规则` | 注释说明：生成降级规则 |
| 1631 | `          if (containerClass != null) {` | 条件判断 如果(if)：containerClass 不等于 空值(null) |
| 1632 | `            fallbackChapterListRule = 'class.$containerClass@tag.a';` | 回退/降级 章节 列表 规则 = '类(class).$containerClass@tag.a' |
| 1633 | `            AppLog.instance.put('使用降级规则: $fallbackChapterListRule');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('使用降级规则: $fallbackChapterListRule'); |
| 1634 | `          }` | 闭合大括号，结束当前代码块 |
| 1635 | `        }` | 闭合大括号，结束当前代码块 |
| 1636 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1637 | `        // 如果找到了降级规则，创建临时规则对象` | 注释说明：如果找到了降级规则，创建临时规则对象 |
| 1638 | `        if (fallbackChapterListRule != null) {` | 条件判断 如果(if)：回退/降级 章节 列表 规则 不等于 空值(null) |
| 1639 | `          effectiveTocRule = TocRule(` | 将 目录(TOC) 规则( 赋值给 effectiveTocRule（调用 目录(TOC) 规则 → 目录(目录(TOC)) 规则） |
| 1640 | `            chapterList: fallbackChapterListRule,` | 命名实参 章节 列表: 回退/降级 章节 列表 规则（章节 列表） |
| 1641 | `            chapterName: source.ruleToc?.chapterName ?? 'tag.a@text',` | 命名实参 章节 名称: 书源.目录规则?.章节 名称 ?? 'tag.a@文本'（章节 名称） |
| 1642 | `            chapterUrl: source.ruleToc?.chapterUrl ?? 'tag.a@href',` | 命名实参 章节链接: 书源.目录规则?.章节链接 ?? 'tag.a@href'（章节 统一资源链接(URL)） |
| 1643 | `            isVip: source.ruleToc?.isVip,` | 命名实参 isVip: 书源.目录规则?.isVip（是(is) Vip） |
| 1644 | `            isVolume: source.ruleToc?.isVolume, // 保留卷名规则` | 命名实参 isVolume: 书源.目录规则?.isVolume（是(is) 体积）；行尾注释：保留卷名规则 |
| 1645 | `            updateTime: source.ruleToc?.updateTime,` | 命名实参 updateTime: 书源.目录规则?.updateTime（更新 Time） |
| 1646 | `            nextTocUrl: source.ruleToc?.nextTocUrl,` | 命名实参 下一页目录链接: 书源.目录规则?.下一页目录链接（下一章 目录(目录(TOC)) 统一资源链接(URL)） |
| 1647 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1648 | `        }` | 闭合大括号，结束当前代码块 |
| 1649 | `      }` | 闭合大括号，结束当前代码块 |
| 1650 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1651 | `      var allChapterList = <Map<String, String?>>[];` | 声明自动类型推断的变量 全部 章节 列表 |
| 1652 | `      var pageCount = 1;` | 声明自动类型推断的变量 页 数量 |
| 1653 | `      if (effectiveTocRule != null) {` | 条件判断 如果(if)：effectiveTocRule 不等于 空值(null) |
| 1654 | `        final firstPageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 首个 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 1655 | `          html,` | 签名/调用续行参数：网页内容 |
| 1656 | `          effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 1657 | `          variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1658 | `          baseUrl: tocUrl,` | 命名实参 基础链接: 目录(TOC) URL（base 统一资源链接(URL)） |
| 1659 | `          getNextUrl: true,` | 命名实参 获取 下一章 URL: 真(true)（获取 下一章 统一资源链接(URL)） |
| 1660 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1661 | `        final firstPageChapterList =` | 上一表达式的续行：不可重新赋值(final) 首个 页 章节 列表 = |
| 1662 | `            firstPageResult['chapterList'] as List<Map<String, String?>>;` | 首个 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 1663 | `        AppLog.instance.put('第 1 页解析结果: 找到 ${firstPageChapterList.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('第 1 页解析结果: 找到 ${首个 页 章节 列表.长度(length)} 个章节'… |
| 1664 | `        allChapterList.addAll(firstPageChapterList);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(首个 页 章节 列表); |
| 1665 | `      }` | 闭合大括号，结束当前代码块 |
| 1666 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1667 | `      if (loadAllPages) {` | 条件判断 如果(if)：加载 全部 分页 |
| 1668 | `        var currentUrl = tocUrl;` | 声明自动类型推断的变量 当前 URL |
| 1669 | `        var visitedUrls = <String>{currentUrl};` | 声明自动类型推断的变量 visitedUrls |
| 1670 | `        const maxPages = 100; // 防止无限循环` | 声明编译期常量变量 maxPages；行尾注释：防止无限循环 |
| 1671 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1672 | `        while (pageCount < maxPages && effectiveTocRule != null) {` | 当型循环(while) 循环，条件：页 数量 < maxPages && effectiveTocRule != 空值(null) |
| 1673 | `          String pageHtml = html;` | 字符串(String) 页 HTML = 网页内容 |
| 1674 | `          if (pageCount > 1) {` | 条件判断 如果(if)：页 数量 > 1 |
| 1675 | `            final pageResponse = await _networkService.get(` | 声明不可重新赋值的变量 页 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 1676 | `              currentUrl,` | 签名/调用续行参数：当前 URL |
| 1677 | `              headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 1678 | `              retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 1679 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1680 | `            pageHtml = await NetworkService.getResponseText(pageResponse);` | 将 等待异步结果：等待(await) 网络服务(NetworkService).获取 响应 文本(页 响应) 赋值给 页 HTML（调用 获取 响应 文本 → 获取 响应 文本） |
| 1681 | `            if (pageHtml.isEmpty) {` | 条件判断 如果(if)：页 HTML.是否为空 |
| 1682 | `              AppLog.instance.put('第 $pageCount 页内容为空，停止获取');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('第 $pageCount 页内容为空，停止获取'); |
| 1683 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1684 | `            }` | 闭合大括号，结束当前代码块 |
| 1685 | `          }` | 闭合大括号，结束当前代码块 |
| 1686 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1687 | `          List<Map<String, String?>> pageChapterList;` | 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> 页 章节 列表 |
| 1688 | `          if (pageCount == 1) {` | 条件判断 如果(if)：页 数量 等于 1 |
| 1689 | `            pageChapterList = allChapterList;` | 将 全部 章节 列表 赋值给 页 章节 列表 |
| 1690 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1691 | `            final pageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 1692 | `              pageHtml,` | 签名/调用续行参数：页 HTML |
| 1693 | `              effectiveTocRule,` | 签名/调用续行参数：effectiveTocRule |
| 1694 | `              variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1695 | `              baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 1696 | `              getNextUrl: true,` | 命名实参 获取 下一章 URL: 真(true)（获取 下一章 统一资源链接(URL)） |
| 1697 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1698 | `            pageChapterList =` | 上一表达式的续行：页 章节 列表 = |
| 1699 | `                pageResult['chapterList'] as List<Map<String, String?>>;` | 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 1700 | `            AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1701 | `                .put('第 $pageCount 页解析结果: 找到 ${pageChapterList.length} 个章节');` | 链式调用延续：.写入数据库(put)('第 $pageCount 页解析结果: 找到 ${pageChapterList.length} 个章节'); |
| 1702 | `            allChapterList.addAll(pageChapterList);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(页 章节 列表); |
| 1703 | `          }` | 闭合大括号，结束当前代码块 |
| 1704 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1705 | `          String? nextUrl;` | 字符串(String)? 下一章 URL |
| 1706 | `          if (effectiveTocRule.nextTocUrl != null &&` | 条件判断 如果(if)：effectiveTocRule.下一页目录链接 不等于 空值(null) 且 |
| 1707 | `              effectiveTocRule.nextTocUrl!.isNotEmpty) {` | effectiveTocRule.下一页目录链接!.是否非空) { |
| 1708 | `            AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1709 | `                .put('尝试使用nextTocUrl规则获取下一页: ${effectiveTocRule.nextTocUrl}');` | 链式调用延续：.写入数据库(put)('尝试使用nextTocUrl规则获取下一页: ${effectiveTocRule.nextTocUrl}'); |
| 1710 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1711 | `            List<String> nextUrlList;` | 列表(List)<字符串(String)> 下一章 URL 列表 |
| 1712 | `            if (effectiveTocRule.nextTocUrl!.contains('@')) {` | 条件判断 如果(if)：effectiveTocRule.下一页目录链接!.是否包含('@') |
| 1713 | `              nextUrlList = RuleParser.parseListRule(` | 将 规则解析器(RuleParser).解析 列表 规则( 赋值给 下一章 URL 列表（调用 解析 列表 规则 → 解析 列表 规则） |
| 1714 | `                pageHtml,` | 签名/调用续行参数：页 HTML |
| 1715 | `                effectiveTocRule.nextTocUrl!,` | effectiveTocRule.下一页目录链接!, |
| 1716 | `                variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1717 | `                baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 1718 | `                returnHtml: false,` | 命名实参 returnHtml: 假(false)（返回(return) 网页标记文本(HTML)） |
| 1719 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1720 | `            } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1721 | `              final linkHtmlList = RuleParser.parseListRule(` | 声明不可重新赋值的变量 linkHtmlList：调用 规则解析器(RuleParser).解析 列表 规则(...) → 解析 列表 规则 |
| 1722 | `                pageHtml,` | 签名/调用续行参数：页 HTML |
| 1723 | `                effectiveTocRule.nextTocUrl!,` | effectiveTocRule.下一页目录链接!, |
| 1724 | `                variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1725 | `                baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 1726 | `                returnHtml: true,` | 命名实参 returnHtml: 真(true)（返回(return) 网页标记文本(HTML)） |
| 1727 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1728 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1729 | `              nextUrlList = [];` | 下一章 URL 列表 = [] |
| 1730 | `              for (final linkHtml in linkHtmlList) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) linkHtml 属于(in) linkHtmlList |
| 1731 | `                final hrefPattern = RegExp(` | 声明不可重新赋值的变量 hrefPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 1732 | `                  'href\\s*=\\s*["\']([^"\']+)["\']',` | 以字符串 'href\\s*=\\s*["\']([^"\']+)["\']' 起始的表达式：, |
| 1733 | `                  caseSensitive: false,` | 区分大小写开关: 假(false), |
| 1734 | `                );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1735 | `                final match = hrefPattern.firstMatch(linkHtml);` | 声明不可重新赋值的变量 match：调用 hrefPattern.首个匹配(...) → 首个 Match |
| 1736 | `                if (match != null) {` | 条件判断 如果(if)：match 不等于 空值(null) |
| 1737 | `                  final href = match.group(1);` | 声明不可重新赋值的变量 href：调用 match.捕获组(...) → 捕获组 |
| 1738 | `                  if (href != null && href.isNotEmpty) {` | 条件判断 如果(if)：href 不等于 空值(null) 且 href.是否非空 |
| 1739 | `                    nextUrlList.add(href);` | 链式调用起始于 下一章 URL 列表（下一章 统一资源链接(URL) 列表），后续行继续该表达式：下一章 URL 列表.添加(href); |
| 1740 | `                  }` | 闭合大括号，结束当前代码块 |
| 1741 | `                }` | 闭合大括号，结束当前代码块 |
| 1742 | `              }` | 闭合大括号，结束当前代码块 |
| 1743 | `            }` | 闭合大括号，结束当前代码块 |
| 1744 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1745 | `            final filteredUrls = nextUrlList` | 上一表达式的续行：不可重新赋值(final) filteredUrls = 下一章 URL 列表 |
| 1746 | `                .where((url) => url.isNotEmpty && url != currentUrl)` | 链式调用延续：.筛选(where)((链接) => 链接.是否非空 && 链接 != 当前 URL) |
| 1747 | `                .map((url) => NetworkService.joinUrl(currentUrl, url))` | 链式调用延续：.映射(map)((链接) => 网络服务(NetworkService).拼接 URL(当前 URL, 链接)) |
| 1748 | `                .where((url) => url != currentUrl && !visitedUrls.contains(url))` | 链式调用延续：.筛选(where)((链接) => 链接 != 当前 URL && !visitedUrls.是否包含(链接)) |
| 1749 | `                .toList();` | 链式调用延续：.转为列表(); |
| 1750 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1751 | `            AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1752 | `                .put('nextTocUrl规则解析结果: 找到 ${filteredUrls.length} 个URL');` | 链式调用延续：.写入数据库(put)('nextTocUrl规则解析结果: 找到 ${filteredUrls.length} 个URL'); |
| 1753 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1754 | `            if (filteredUrls.isNotEmpty) {` | 条件判断 如果(if)：filteredUrls.是否非空 |
| 1755 | `              if (filteredUrls.length == 1) {` | 条件判断 如果(if)：filteredUrls.长度(length) 等于 1 |
| 1756 | `                nextUrl = filteredUrls[0];` | 将 filteredUrls[0] 赋值给 下一章 URL |
| 1757 | `              } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1758 | `                try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1759 | `                  final futures = filteredUrls.map((url) async {` | 声明不可重新赋值的变量 futures：调用 filteredUrls.映射(map)(...) → 映射 |
| 1760 | `                    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1761 | `                      final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 1762 | `                        url,` | 签名/调用续行参数：链接 |
| 1763 | `                        headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 1764 | `                        retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 1765 | `                      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1766 | `                      final html =` | 上一表达式的续行：不可重新赋值(final) 网页内容 = |
| 1767 | `                          await NetworkService.getResponseText(response);` | 调用 网络服务(NetworkService).获取 响应 文本(...)（等待异步完成） → 获取 响应 文本 |
| 1768 | `                      return {'url': url, 'html': html, 'success': true};` | 返回 {'链接': 链接, '网页内容': 网页内容, '成功': 真(true)}（映射(Map)/集合字面量） |
| 1769 | `                    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 1770 | `                      return {'url': url, 'html': '', 'success': false};` | 返回 {'链接': 链接, '网页内容': '', '成功': 假(false)}（映射(Map)/集合字面量） |
| 1771 | `                    }` | 闭合大括号，结束当前代码块 |
| 1772 | `                  }).toList();` | 闭合代码块并衔接后续语句：).转为列表(); |
| 1773 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1774 | `                  final results = await Future.wait(futures);` | 声明不可重新赋值的变量 结果：等待(await) 调用 异步结果(Future).wait(...) |
| 1775 | `                  final allHtml = results` | 上一表达式的续行：不可重新赋值(final) 全部 HTML = 结果 |
| 1776 | `                      .where((r) =>` | 链式调用延续：.筛选(where)((r) => |
| 1777 | `                          r['success'] == true &&` | 上一表达式的续行：r['成功'] == 真(true) && |
| 1778 | `                          (r['html'] as String).isNotEmpty)` | (r['网页内容'] 作为(as) 字符串(String)).是否非空) |
| 1779 | `                      .map((r) => r['html'] as String)` | 链式调用延续：.映射(map)((r) => r['网页内容'] 作为(as) 字符串(String)) |
| 1780 | `                      .join('\n');` | 链式调用延续：.拼接('\n'); |
| 1781 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1782 | `                  if (allHtml.isNotEmpty) {` | 条件判断 如果(if)：全部 HTML.是否非空 |
| 1783 | `                    pageHtml = allHtml;` | 将 全部 HTML 赋值给 页 HTML |
| 1784 | `                    nextUrl = null;` | 将 空值(null) 赋值给 下一章 URL |
| 1785 | `                  } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 1786 | `                    nextUrl = filteredUrls[0];` | 将 filteredUrls[0] 赋值给 下一章 URL |
| 1787 | `                  }` | 闭合大括号，结束当前代码块 |
| 1788 | `                } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 1789 | `                  nextUrl = filteredUrls[0];` | 将 filteredUrls[0] 赋值给 下一章 URL |
| 1790 | `                }` | 闭合大括号，结束当前代码块 |
| 1791 | `              }` | 闭合大括号，结束当前代码块 |
| 1792 | `            }` | 闭合大括号，结束当前代码块 |
| 1793 | `          }` | 闭合大括号，结束当前代码块 |
| 1794 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1795 | `          if (nextUrl == null \|\| nextUrl.isEmpty) {` | 条件判断 如果(if)：下一章 URL 等于 空值(null) 或 下一章 URL.是否为空 |
| 1796 | `            for (int i = 0; i < pageChapterList.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 页 章节 列表.长度(length); 循环变量 i++ |
| 1797 | `              final chapterData = pageChapterList[i];` | 声明不可重新赋值的变量 chapterData |
| 1798 | `              final chapterNextUrl = chapterData['nextTocUrl'];` | 声明不可重新赋值的变量 章节 下一章 URL |
| 1799 | `              if (chapterNextUrl != null && chapterNextUrl.isNotEmpty) {` | 条件判断 如果(if)：章节 下一章 URL 不等于 空值(null) 且 章节 下一章 URL.是否非空 |
| 1800 | `                nextUrl = NetworkService.joinUrl(currentUrl, chapterNextUrl);` | 将 网络服务(NetworkService).拼接 URL(当前 URL, 章节 下一章 URL) 赋值给 下一章 URL（调用 拼接 URL → 拼接 统一资源链接(URL)） |
| 1801 | `                break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1802 | `              }` | 闭合大括号，结束当前代码块 |
| 1803 | `            }` | 闭合大括号，结束当前代码块 |
| 1804 | `          }` | 闭合大括号，结束当前代码块 |
| 1805 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1806 | `          if (nextUrl == null \|\| nextUrl.isEmpty) {` | 条件判断 如果(if)：下一章 URL 等于 空值(null) 或 下一章 URL.是否为空 |
| 1807 | `            try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 1808 | `              final nextPagePattern = RegExp(` | 声明不可重新赋值的变量 下一章 页 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 1809 | `                '<a[^>]*href=["\']([^"\']+)["\'][^>]*>.*?(?:下一页\|下页\|next\|Next\|NEXT)[^<]*</a>',` | 以字符串 '<a[^>]*href=["\']([^"\']+)["\'][^>]*>.*… 起始的表达式：, |
| 1810 | `                caseSensitive: false,` | 区分大小写开关: 假(false), |
| 1811 | `                dotAll: true,` | 命名实参 点号 全部: 真(true)（点号 全部） |
| 1812 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1813 | `              final match = nextPagePattern.firstMatch(pageHtml);` | 声明不可重新赋值的变量 match：调用 下一章 页 模式.首个匹配(...) → 首个 Match |
| 1814 | `              if (match != null) {` | 条件判断 如果(if)：match 不等于 空值(null) |
| 1815 | `                final href = match.group(1);` | 声明不可重新赋值的变量 href：调用 match.捕获组(...) → 捕获组 |
| 1816 | `                if (href != null && href.isNotEmpty) {` | 条件判断 如果(if)：href 不等于 空值(null) 且 href.是否非空 |
| 1817 | `                  nextUrl = NetworkService.joinUrl(currentUrl, href);` | 将 网络服务(NetworkService).拼接 URL(当前 URL, href) 赋值给 下一章 URL（调用 拼接 URL → 拼接 统一资源链接(URL)） |
| 1818 | `                }` | 闭合大括号，结束当前代码块 |
| 1819 | `              }` | 闭合大括号，结束当前代码块 |
| 1820 | `            } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 1821 | `              AppLog.instance.put('自动查找"下一页"链接失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('自动查找"下一页"链接失败', error: e); |
| 1822 | `            }` | 闭合大括号，结束当前代码块 |
| 1823 | `          }` | 闭合大括号，结束当前代码块 |
| 1824 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1825 | `          if (nextUrl == null \|\|` | 条件判断 如果(if)：下一章 URL 等于 空值(null) 或 |
| 1826 | `              nextUrl.isEmpty \|\|` | 上一表达式的续行：下一章 URL.是否为空 \|\| |
| 1827 | `              visitedUrls.contains(nextUrl)) {` | 链式调用起始于 visitedUrls，后续行继续该表达式：visitedUrls.是否包含(下一章 URL)) { |
| 1828 | `            break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 1829 | `          }` | 闭合大括号，结束当前代码块 |
| 1830 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1831 | `          visitedUrls.add(nextUrl);` | 链式调用起始于 visitedUrls，后续行继续该表达式：visitedUrls.添加(下一章 URL); |
| 1832 | `          currentUrl = nextUrl;` | 将 下一章 URL 赋值给 当前 URL |
| 1833 | `          pageCount++;` | 页 数量++ |
| 1834 | `          AppLog.instance.put('找到下一页URL: $nextUrl，继续获取第 $pageCount 页');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到下一页URL: $nextUrl，继续获取第 $pageCount 页'); |
| 1835 | `        }` | 闭合大括号，结束当前代码块 |
| 1836 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1837 | `        if (pageCount == 1 && effectiveTocRule != null) {` | 条件判断 如果(if)：页 数量 等于 1 且 effectiveTocRule 不等于 空值(null) |
| 1838 | `          final ajaxChapters = await _loadAjaxTocPages(` | 声明不可重新赋值的变量 ajaxChapters：等待(await) 调用 _loadAjaxTocPages(...) → 加载 Ajax 目录(目录(TOC)) 分页 |
| 1839 | `            tocUrl: tocUrl,` | 命名实参 目录(TOC) URL: 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 1840 | `            firstPageHtml: html,` | 命名实参 首个 页 HTML: 网页内容（首个 页 网页标记文本(HTML)） |
| 1841 | `            source: source,` | 命名实参 书源: 书源（书源） |
| 1842 | `            seedChapters: allChapterList,` | 命名实参 seedChapters: 全部 章节 列表（seed 章节列表） |
| 1843 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1844 | `          if (ajaxChapters.isNotEmpty) {` | 条件判断 如果(if)：ajaxChapters.是否非空 |
| 1845 | `            allChapterList.addAll(ajaxChapters);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(ajaxChapters); |
| 1846 | `          }` | 闭合大括号，结束当前代码块 |
| 1847 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1848 | `          final implicitChapters = await _loadImplicitTocPages(` | 声明不可重新赋值的变量 implicitChapters：等待(await) 调用 _loadImplicitTocPages(...) → 加载 Implicit 目录(目录(TOC)) 分页 |
| 1849 | `            tocUrl: tocUrl,` | 命名实参 目录(TOC) URL: 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 1850 | `            source: source,` | 命名实参 书源: 书源（书源） |
| 1851 | `            tocRule: effectiveTocRule,` | 命名实参 目录(TOC) 规则: effectiveTocRule（目录(目录(TOC)) 规则） |
| 1852 | `            seedChapters: allChapterList,` | 命名实参 seedChapters: 全部 章节 列表（seed 章节列表） |
| 1853 | `            variables: chapterVariables,` | 命名实参 variables: 章节 变量表（变量表） |
| 1854 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1855 | `          if (implicitChapters.isNotEmpty) {` | 条件判断 如果(if)：implicitChapters.是否非空 |
| 1856 | `            allChapterList.addAll(implicitChapters);` | 链式调用起始于 全部 章节 列表（全部 章节 列表），后续行继续该表达式：全部 章节 列表.批量添加(implicitChapters); |
| 1857 | `          }` | 闭合大括号，结束当前代码块 |
| 1858 | `        }` | 闭合大括号，结束当前代码块 |
| 1859 | `      }` | 闭合大括号，结束当前代码块 |
| 1860 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1861 | `      AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1862 | `          .put('目录获取完成: 共 $pageCount 页，总计 ${allChapterList.length} 个章节');` | 链式调用延续：.写入数据库(put)('目录获取完成: 共 $pageCount 页，总计 ${allChapterList.length} 个章节'); |
| 1863 | `      var chapterList = allChapterList;` | 声明自动类型推断的变量 章节 列表 |
| 1864 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1865 | `      // 如果仍然没有章节，尝试其他降级规则（保留原有逻辑作为最后手段）` | 注释说明：如果仍然没有章节，尝试其他降级规则（保留原有逻辑作为最后手段） |
| 1866 | `      if (chapterList.isEmpty && source.ruleToc?.chapterList != null) {` | 条件判断 如果(if)：章节 列表.是否为空 且 书源.目录规则?.章节 列表 不等于 空值(null) |
| 1867 | `        AppLog.instance.put('原始规则未匹配到章节，尝试智能降级处理');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('原始规则未匹配到章节，尝试智能降级处理'); |
| 1868 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1869 | `        // 尝试查找包含章节链接的容器` | 注释说明：尝试查找包含章节链接的容器 |
| 1870 | `        // 使用普通字符串而不是原始字符串，以便正确处理字符类中的引号` | 注释说明：使用普通字符串而不是原始字符串，以便正确处理字符类中的引号 |
| 1871 | `        final chapterLinkPattern = RegExp(` | 声明不可重新赋值的变量 chapterLinkPattern：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 1872 | `            '<a[^>]*href=["\']/[^"\']*\\.html["\'][^>]*>.*?</a>',` | 以字符串 '<a[^>]*href=["\']/[^"\']*\\.网页内容["\'][^… 起始的表达式：, |
| 1873 | `            caseSensitive: false,` | 区分大小写开关: 假(false), |
| 1874 | `            dotAll: true);` | 命名实参 点号 全部: 真(true));（点号 全部） |
| 1875 | `        final chapterLinkMatches = chapterLinkPattern.allMatches(html).toList();` | 声明不可重新赋值的变量 chapterLinkMatches：调用 chapterLinkPattern.allMatches(...) → 全部 Matches |
| 1876 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1877 | `        if (chapterLinkMatches.isNotEmpty) {` | 条件判断 如果(if)：chapterLinkMatches.是否非空 |
| 1878 | `          AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 1879 | `              .put('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器');` | 链式调用延续：.写入数据库(put)('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器'); |
| 1880 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1881 | `          // 查找真正的目录开始位置（跳过前几个可能是最新章节的链接）` | 注释说明：查找真正的目录开始位置（跳过前几个可能是最新章节的链接） |
| 1882 | `          // 从第7个链接开始查找，这些应该是真正的目录章节` | 注释说明：从第7个链接开始查找，这些应该是真正的目录章节 |
| 1883 | `          html_dom.Element? directoryContainer;` | html_dom.Element? directoryContainer |
| 1884 | `          String? containerClass;` | 字符串(String)? containerClass |
| 1885 | `          String? containerId;` | 字符串(String)? containerId |
| 1886 | `          String? containerTag;` | 字符串(String)? containerTag |
| 1887 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1888 | `          // 首先尝试查找directoryArea容器` | 注释说明：首先尝试查找directoryArea容器 |
| 1889 | `          final doc = html_parser.parse(html);` | 声明不可重新赋值的变量 文档：调用 HTML 解析器.parse(...) → 解析 |
| 1890 | `          final directoryPattern = RegExp(` | 声明不可重新赋值的变量 目录(directory) 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 1891 | `              'class\\s*=\\s*["\'][^"\']*directory[^"\']*["\']',` | 以字符串 '类(class)\\s*=\\s*["\'][^"\']*目录(directory)[^"\… 起始的表达式：, |
| 1892 | `              caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1893 | `          final directoryMatches = directoryPattern.allMatches(html);` | 声明不可重新赋值的变量 directoryMatches：调用 目录(directory) 模式.allMatches(...) → 全部 Matches |
| 1894 | `          if (directoryMatches.isNotEmpty) {` | 条件判断 如果(if)：directoryMatches.是否非空 |
| 1895 | `            final match = directoryMatches.first;` | 声明不可重新赋值的变量 match |
| 1896 | `            final matchHtml = html.substring(match.start, match.end);` | 声明不可重新赋值的变量 matchHtml |
| 1897 | `            final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 1898 | `                caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1899 | `            final classMatch = classPattern.firstMatch(matchHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 1900 | `            if (classMatch != null) {` | 条件判断 如果(if)：classMatch 不等于 空值(null) |
| 1901 | `              final allClasses =` | 上一表达式的续行：不可重新赋值(final) allClasses = |
| 1902 | `                  classMatch.group(1)?.split(RegExp(r'\s+')) ?? [];` | 链式调用起始于 classMatch，后续行继续该表达式：classMatch.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')) ?? []; |
| 1903 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 1904 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 1905 | `                orElse: () => '',` | 命名实参 orElse: () => ''（or Else） |
| 1906 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1907 | `              if (dirClass.isNotEmpty) {` | 条件判断 如果(if)：dirClass.是否非空 |
| 1908 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 1909 | `                    HtmlParser.selectElement(doc, 'div.$dirClass');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div.$dirClass'); |
| 1910 | `                containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 1911 | `                containerTag = 'div';` | containerTag = 'div' |
| 1912 | `                AppLog.instance.put('找到directory容器: class=$containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到directory容器: class=$containerClass'); |
| 1913 | `              }` | 闭合大括号，结束当前代码块 |
| 1914 | `            }` | 闭合大括号，结束当前代码块 |
| 1915 | `          }` | 闭合大括号，结束当前代码块 |
| 1916 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1917 | `          // 如果没有找到directory容器，从第7个链接开始查找容器` | 注释说明：如果没有找到目录(directory)容器，从第7个链接开始查找容器 |
| 1918 | `          if (directoryContainer == null && chapterLinkMatches.length >= 7) {` | 条件判断 如果(if)：directoryContainer 等于 空值(null) 且 chapterLinkMatches.长度(length) > = 7 |
| 1919 | `            // 从第7个链接开始查找容器` | 注释说明：从第7个链接开始查找容器 |
| 1920 | `            final chapterStartMatch = chapterLinkMatches[6]; // 第7个链接（索引6）` | 声明不可重新赋值的变量 chapterStartMatch；行尾注释：第7个链接（索引6） |
| 1921 | `            final beforeHtml = html.substring(0, chapterStartMatch.start);` | 声明不可重新赋值的变量 beforeHtml |
| 1922 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1923 | `            // 查找最近的容器开始标签（div, ul, ol, dl, section等）` | 注释说明：查找最近的容器开始标签（div, ul, ol, dl, 节等） |
| 1924 | `            final containerStartPattern =` | 上一表达式的续行：不可重新赋值(final) containerStartPattern = |
| 1925 | `                RegExp(r'<(div\|ul\|ol\|dl\|section)[^>]*>', caseSensitive: false);` | 构造函数 正则表达式(RegExp)位置参数 2 个；参数名: 节, 区分大小写开关, 假(false) |
| 1926 | `            final containerStarts =` | 上一表达式的续行：不可重新赋值(final) containerStarts = |
| 1927 | `                containerStartPattern.allMatches(beforeHtml).toList();` | 链式调用起始于 containerStartPattern（container 起始 模式），后续行继续该表达式：containerStartPattern.allMatches(beforeHtml).转为列表(); |
| 1928 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1929 | `            if (containerStarts.isNotEmpty) {` | 条件判断 如果(if)：containerStarts.是否非空 |
| 1930 | `              final lastContainerStart = containerStarts.last;` | 声明不可重新赋值的变量 lastContainerStart |
| 1931 | `              containerTag = lastContainerStart.group(1);` | 将 lastContainerStart.捕获组(1) 赋值给 containerTag（调用 捕获组 → 捕获组） |
| 1932 | `              final containerStartPos = lastContainerStart.start;` | 声明不可重新赋值的变量 containerStartPos |
| 1933 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1934 | `              // 提取容器的class或id属性` | 注释说明：提取容器的类(class)或编号(id)属性 |
| 1935 | `              final containerHtml =` | 上一表达式的续行：不可重新赋值(final) containerHtml = |
| 1936 | `                  html.substring(containerStartPos, lastContainerStart.end);` | 链式调用起始于 网页内容（网页标记文本(HTML)），后续行继续该表达式：网页内容.substring(containerStartPos, lastContainerStart.end); |
| 1937 | `              final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 1938 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1939 | `              final idPattern = RegExp('id\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 编号(id) 模式，默认值 正则表达式(RegExp)('编号(id)\\s*=\\s*["\']([^"\']+)["\']'（编号(编号(id)) 模式） |
| 1940 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 1941 | `              final classMatch = classPattern.firstMatch(containerHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 1942 | `              final idMatch = idPattern.firstMatch(containerHtml);` | 声明不可重新赋值的变量 idMatch：调用 编号(id) 模式.首个匹配(...) → 首个 Match |
| 1943 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1944 | `              containerClass =` | 上一表达式的续行：containerClass = |
| 1945 | `                  classMatch?.group(1)?.split(RegExp(r'\s+')).first;` | 调用 捕获组/切分/正则表达式(RegExp)(...)：classMatch?.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')).first（捕获组 切分 Reg 表达式） |
| 1946 | `              containerId = idMatch?.group(1);` | 将 idMatch?.捕获组(1) 赋值给 containerId（调用 捕获组 → 捕获组） |
| 1947 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1948 | `              // 如果容器class包含directory，尝试查找该容器` | 注释说明：如果容器类(class)包含目录(directory)，尝试查找该容器 |
| 1949 | `              if (containerClass != null &&` | 条件判断 如果(if)：containerClass 不等于 空值(null) 且 |
| 1950 | `                  containerClass.contains('directory')) {` | 链式调用起始于 containerClass，后续行继续该表达式：containerClass.是否包含('目录(directory)')) { |
| 1951 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 1952 | `                    HtmlParser.selectElement(doc, 'div.$containerClass');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div.$containerClass'); |
| 1953 | `                AppLog.instance.put('找到directory容器: class=$containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到directory容器: class=$containerClass'); |
| 1954 | `              } else if (containerId != null) {` | 闭合上一代码块并开始 否则(else) 如果(if) (containerId != 空值(null)) { |
| 1955 | `                directoryContainer =` | 上一表达式的续行：directoryContainer = |
| 1956 | `                    HtmlParser.selectElement(doc, 'div#$containerId');` | 链式调用起始于 HTML 解析器（网页标记文本(HTML) 解析器），后续行继续该表达式：HTML 解析器.selectElement(文档, 'div#$containerId'); |
| 1957 | `                AppLog.instance.put('找到容器: id=$containerId');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('找到容器: id=$containerId'); |
| 1958 | `              }` | 闭合大括号，结束当前代码块 |
| 1959 | `            }` | 闭合大括号，结束当前代码块 |
| 1960 | `          }` | 闭合大括号，结束当前代码块 |
| 1961 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1962 | `          // 如果找到了directory容器，提取其class或id用于生成降级规则` | 注释说明：如果找到了目录(directory)容器，提取其类(class)或编号(id)用于生成降级规则 |
| 1963 | `          if (directoryContainer != null) {` | 条件判断 如果(if)：directoryContainer 不等于 空值(null) |
| 1964 | `            final dirClassAttr = directoryContainer.attributes['class'];` | 声明不可重新赋值的变量 dirClassAttr |
| 1965 | `            final dirIdAttr = directoryContainer.attributes['id'];` | 声明不可重新赋值的变量 dirIdAttr |
| 1966 | `            if (dirClassAttr != null && dirClassAttr.contains('directory')) {` | 条件判断 如果(if)：dirClassAttr 不等于 空值(null) 且 dirClassAttr.是否包含('目录(directory)') |
| 1967 | `              final allClasses = dirClassAttr.split(RegExp(r'\s+'));` | 声明不可重新赋值的变量 allClasses：调用 dirClassAttr.切分(...) → 切分 |
| 1968 | `              final dirClass = allClasses.firstWhere(` | 声明不可重新赋值的变量 dirClass：调用 allClasses.查找首个匹配(firstWhere)(...) → 首个 筛选(筛选(where)) |
| 1969 | `                (c) => c.contains('directory'),` | 调用 是否包含(...)：(c) => c.是否包含('目录(directory)'),（是否包含） |
| 1970 | `                orElse: () => allClasses.first,` | 命名实参 orElse: () => allClasses.first（or Else） |
| 1971 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 1972 | `              containerClass = dirClass;` | 将 dirClass 赋值给 containerClass |
| 1973 | `              containerTag = 'div';` | containerTag = 'div' |
| 1974 | `              AppLog.instance.put('从directory容器提取class: $containerClass');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取class: $containerClass'); |
| 1975 | `            }` | 闭合大括号，结束当前代码块 |
| 1976 | `            if (dirIdAttr != null) {` | 条件判断 如果(if)：dirIdAttr 不等于 空值(null) |
| 1977 | `              containerId = dirIdAttr;` | 将 dirIdAttr 赋值给 containerId |
| 1978 | `              AppLog.instance.put('从directory容器提取id: $containerId');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('从directory容器提取id: $containerId'); |
| 1979 | `            }` | 闭合大括号，结束当前代码块 |
| 1980 | `          }` | 闭合大括号，结束当前代码块 |
| 1981 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1982 | `          // 如果还没有找到容器，使用第一个章节链接的容器` | 注释说明：如果还没有找到容器，使用第一个章节链接的容器 |
| 1983 | `          if (containerClass == null && containerId == null) {` | 条件判断 如果(if)：containerClass 等于 空值(null) 且 containerId 等于 空值(null) |
| 1984 | `            final firstChapterLink = chapterLinkMatches.first;` | 声明不可重新赋值的变量 firstChapterLink |
| 1985 | `            final beforeHtml = html.substring(0, firstChapterLink.start);` | 声明不可重新赋值的变量 beforeHtml |
| 1986 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1987 | `            // 查找最近的容器开始标签（div, ul, ol, dl, section等）` | 注释说明：查找最近的容器开始标签（div, ul, ol, dl, 节等） |
| 1988 | `            final containerStartPattern =` | 上一表达式的续行：不可重新赋值(final) containerStartPattern = |
| 1989 | `                RegExp(r'<(div\|ul\|ol\|dl\|section)[^>]*>', caseSensitive: false);` | 构造函数 正则表达式(RegExp)位置参数 2 个；参数名: 节, 区分大小写开关, 假(false) |
| 1990 | `            final containerStarts =` | 上一表达式的续行：不可重新赋值(final) containerStarts = |
| 1991 | `                containerStartPattern.allMatches(beforeHtml).toList();` | 链式调用起始于 containerStartPattern（container 起始 模式），后续行继续该表达式：containerStartPattern.allMatches(beforeHtml).转为列表(); |
| 1992 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1993 | `            if (containerStarts.isNotEmpty) {` | 条件判断 如果(if)：containerStarts.是否非空 |
| 1994 | `              final lastContainerStart = containerStarts.last;` | 声明不可重新赋值的变量 lastContainerStart |
| 1995 | `              containerTag = lastContainerStart.group(1);` | 将 lastContainerStart.捕获组(1) 赋值给 containerTag（调用 捕获组 → 捕获组） |
| 1996 | `              final containerStartPos = lastContainerStart.start;` | 声明不可重新赋值的变量 containerStartPos |
| 1997 | `&nbsp;` | 空行，分隔逻辑段落 |
| 1998 | `              // 提取容器的class或id属性` | 注释说明：提取容器的类(class)或编号(id)属性 |
| 1999 | `              final containerHtml =` | 上一表达式的续行：不可重新赋值(final) containerHtml = |
| 2000 | `                  html.substring(containerStartPos, lastContainerStart.end);` | 链式调用起始于 网页内容（网页标记文本(HTML)），后续行继续该表达式：网页内容.substring(containerStartPos, lastContainerStart.end); |
| 2001 | `              final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) 模式） |
| 2002 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 2003 | `              final idPattern = RegExp('id\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 编号(id) 模式，默认值 正则表达式(RegExp)('编号(id)\\s*=\\s*["\']([^"\']+)["\']'（编号(编号(id)) 模式） |
| 2004 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 2005 | `              final classMatch = classPattern.firstMatch(containerHtml);` | 声明不可重新赋值的变量 classMatch：调用 classPattern.首个匹配(...) → 首个 Match |
| 2006 | `              final idMatch = idPattern.firstMatch(containerHtml);` | 声明不可重新赋值的变量 idMatch：调用 编号(id) 模式.首个匹配(...) → 首个 Match |
| 2007 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2008 | `              containerClass =` | 上一表达式的续行：containerClass = |
| 2009 | `                  classMatch?.group(1)?.split(RegExp(r'\s+')).first;` | 调用 捕获组/切分/正则表达式(RegExp)(...)：classMatch?.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')).first（捕获组 切分 Reg 表达式） |
| 2010 | `              containerId = idMatch?.group(1);` | 将 idMatch?.捕获组(1) 赋值给 containerId（调用 捕获组 → 捕获组） |
| 2011 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2012 | `              AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2013 | `                  '找到容器: <$containerTag>${containerClass != null ? ' class="$containerClass"' : ''}${containerId != null ? ' id="$containerId"' : ''}');` | 以字符串 '找到容器: <$containerTag>${containerClass !… 起始的表达式：类(class)="$containerClass"' : ''}${containerId != 空值(null) ? ' 编号(id)="… |
| 2014 | `            }` | 闭合大括号，结束当前代码块 |
| 2015 | `          }` | 闭合大括号，结束当前代码块 |
| 2016 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2017 | `          // 使用找到的容器信息生成降级规则` | 注释说明：使用找到的容器信息生成降级规则 |
| 2018 | `          String? finalContainerClass = containerClass;` | 字符串(String)? finalContainerClass = containerClass |
| 2019 | `          String? finalContainerId = containerId;` | 字符串(String)? finalContainerId = containerId |
| 2020 | `          String? finalContainerTag = containerTag;` | 字符串(String)? finalContainerTag = containerTag |
| 2021 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2022 | `          if (directoryContainer == null) {` | 条件判断 如果(if)：directoryContainer 等于 空值(null) |
| 2023 | `            // 如果没有找到directory容器，尝试从第一个章节链接查找容器` | 注释说明：如果没有找到目录(directory)容器，尝试从第一个章节链接查找容器 |
| 2024 | `            final firstChapterLink = chapterLinkMatches.first;` | 声明不可重新赋值的变量 firstChapterLink |
| 2025 | `            final beforeHtml = html.substring(0, firstChapterLink.start);` | 声明不可重新赋值的变量 beforeHtml |
| 2026 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2027 | `            // 查找最近的容器开始标签（div, ul, ol, dl, section等）` | 注释说明：查找最近的容器开始标签（div, ul, ol, dl, 节等） |
| 2028 | `            final containerStartPattern =` | 上一表达式的续行：不可重新赋值(final) containerStartPattern = |
| 2029 | `                RegExp(r'<(div\|ul\|ol\|dl\|section)[^>]*>', caseSensitive: false);` | 构造函数 正则表达式(RegExp)位置参数 2 个；参数名: 节, 区分大小写开关, 假(false) |
| 2030 | `            final containerStarts =` | 上一表达式的续行：不可重新赋值(final) containerStarts = |
| 2031 | `                containerStartPattern.allMatches(beforeHtml).toList();` | 链式调用起始于 containerStartPattern（container 起始 模式），后续行继续该表达式：containerStartPattern.allMatches(beforeHtml).转为列表(); |
| 2032 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2033 | `            if (containerStarts.isNotEmpty) {` | 条件判断 如果(if)：containerStarts.是否非空 |
| 2034 | `              final lastContainerStart = containerStarts.last;` | 声明不可重新赋值的变量 lastContainerStart |
| 2035 | `              finalContainerTag = lastContainerStart.group(1);` | 将 lastContainerStart.捕获组(1) 赋值给 finalContainerTag（调用 捕获组 → 捕获组） |
| 2036 | `              final containerStartPos = lastContainerStart.start;` | 声明不可重新赋值的变量 containerStartPos |
| 2037 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2038 | `              // 提取容器的class或id属性` | 注释说明：提取容器的类(class)或编号(id)属性 |
| 2039 | `              final containerHtml =` | 上一表达式的续行：不可重新赋值(final) containerHtml = |
| 2040 | `                  html.substring(containerStartPos, lastContainerStart.end);` | 链式调用起始于 网页内容（网页标记文本(HTML)），后续行继续该表达式：网页内容.substring(containerStartPos, lastContainerStart.end); |
| 2041 | `              // 使用普通字符串而不是原始字符串，以便正确处理字符类中的引号` | 注释说明：使用普通字符串而不是原始字符串，以便正确处理字符类中的引号 |
| 2042 | `              final classPattern2 = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 classPattern2，默认值 正则表达式(RegExp)('类(class)\\s*=\\s*["\']([^"\']+)["\'…（类(class) Pattern2） |
| 2043 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 2044 | `              final idPattern2 = RegExp('id\\s*=\\s*["\']([^"\']+)["\']',` | 不可重新赋值(final) 类型参数 idPattern2，默认值 正则表达式(RegExp)('编号(id)\\s*=\\s*["\']([^"\']+)["\']'（编号(编号(id)) Pattern2） |
| 2045 | `                  caseSensitive: false);` | 区分大小写开关: 假(false)) |
| 2046 | `              final classMatch2 = classPattern2.firstMatch(containerHtml);` | 声明不可重新赋值的变量 classMatch2：调用 classPattern2.首个匹配(...) → 首个 Match |
| 2047 | `              final idMatch2 = idPattern2.firstMatch(containerHtml);` | 声明不可重新赋值的变量 idMatch2：调用 idPattern2.首个匹配(...) → 首个 Match |
| 2048 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2049 | `              finalContainerClass =` | 上一表达式的续行：finalContainerClass = |
| 2050 | `                  classMatch2?.group(1)?.split(RegExp(r'\s+')).first;` | 调用 捕获组/切分/正则表达式(RegExp)(...)：classMatch2?.捕获组(1)?.切分(正则表达式(RegExp)(r'\s+')).first（捕获组 切分 Reg 表达式） |
| 2051 | `              finalContainerId = idMatch2?.group(1);` | 将 idMatch2?.捕获组(1) 赋值给 finalContainerId（调用 捕获组 → 捕获组） |
| 2052 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2053 | `              AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2054 | `                  '找到容器: <$finalContainerTag>${finalContainerClass != null ? ' class="$finalContainerClass"' : ''}${finalContainerId != null ? ' id="$finalContainerId"' : ''}');` | 以字符串 '找到容器: <$finalContainerTag>${finalContai… 起始的表达式：类(class)="$finalContainerClass"' : ''}${finalContainerId != nul… |
| 2055 | `            }` | 闭合大括号，结束当前代码块 |
| 2056 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 2057 | `            // 如果找到了directory容器，使用它的信息` | 注释说明：如果找到了目录(directory)容器，使用它的信息 |
| 2058 | `            finalContainerTag = 'div';` | finalContainerTag = 'div' |
| 2059 | `            AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2060 | `                '使用directory容器: class=$finalContainerClass, id=$finalContainerId');` | 以字符串 '使用目录(directory)容器: 类(class)=$finalContainerCla… 起始的表达式：); |
| 2061 | `          }` | 闭合大括号，结束当前代码块 |
| 2062 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2063 | `          // 生成降级规则并尝试` | 注释说明：生成降级规则并尝试 |
| 2064 | `          if (finalContainerClass != null \|\|` | 条件判断 如果(if)：finalContainerClass 不等于 空值(null) 或 |
| 2065 | `              finalContainerId != null \|\|` | 上一表达式的续行：finalContainerId != 空值(null) \|\| |
| 2066 | `              finalContainerTag != null) {` | finalContainerTag != 空值(null)) { |
| 2067 | `            final fallbackRules = <String>[];` | 声明不可重新赋值的变量 fallbackRules |
| 2068 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2069 | `            if (finalContainerId != null) {` | 条件判断 如果(if)：finalContainerId 不等于 空值(null) |
| 2070 | `              // 如果容器有id，尝试使用id选择器` | 注释说明：如果容器有编号(id)，尝试使用编号(id)选择器 |
| 2071 | `              fallbackRules.add('id.$finalContainerId@tag.a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('编号(id).$finalContainerId@tag.a'); |
| 2072 | `              fallbackRules.add('id.$finalContainerId@tag.p');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('编号(id).$finalContainerId@tag.p'); |
| 2073 | `              fallbackRules.add('id.$finalContainerId@tag.li');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('编号(id).$finalContainerId@tag.li'); |
| 2074 | `              fallbackRules.add('id.$finalContainerId@tag.dd');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('编号(id).$finalContainerId@tag.dd'); |
| 2075 | `            }` | 闭合大括号，结束当前代码块 |
| 2076 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2077 | `            if (finalContainerClass != null) {` | 条件判断 如果(if)：finalContainerClass 不等于 空值(null) |
| 2078 | `              // 如果容器有class，尝试使用class选择器` | 注释说明：如果容器有类(class)，尝试使用类(class)选择器 |
| 2079 | `              fallbackRules.add('class.$finalContainerClass@tag.a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('类(class).$finalContainerClass@tag.a'); |
| 2080 | `              fallbackRules.add('class.$finalContainerClass@tag.p');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('类(class).$finalContainerClass@tag.p'); |
| 2081 | `              fallbackRules.add('class.$finalContainerClass@tag.li');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('类(class).$finalContainerClass@tag.li'); |
| 2082 | `              fallbackRules.add('class.$finalContainerClass@tag.dd');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('类(class).$finalContainerClass@tag.dd'); |
| 2083 | `            }` | 闭合大括号，结束当前代码块 |
| 2084 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2085 | `            // 尝试直接选择容器内的链接（使用CSS选择器格式）` | 注释说明：尝试直接选择容器内的链接（使用CSS选择器格式） |
| 2086 | `            if (finalContainerTag != null) {` | 条件判断 如果(if)：finalContainerTag 不等于 空值(null) |
| 2087 | `              if (finalContainerClass != null) {` | 条件判断 如果(if)：finalContainerClass 不等于 空值(null) |
| 2088 | `                fallbackRules.add('$finalContainerTag.$finalContainerClass a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('$finalContainerTag.$finalContainerClass a'); |
| 2089 | `              }` | 闭合大括号，结束当前代码块 |
| 2090 | `              if (finalContainerId != null) {` | 条件判断 如果(if)：finalContainerId 不等于 空值(null) |
| 2091 | `                fallbackRules.add('$finalContainerTag#$finalContainerId a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('$finalContainerTag#$finalContainerId a'); |
| 2092 | `              }` | 闭合大括号，结束当前代码块 |
| 2093 | `              fallbackRules.add('$finalContainerTag a');` | 链式调用起始于 fallbackRules（回退/降级 Rules），后续行继续该表达式：fallbackRules.添加('$finalContainerTag a'); |
| 2094 | `            }` | 闭合大括号，结束当前代码块 |
| 2095 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2096 | `            // 尝试每个降级规则` | 注释说明：尝试每个降级规则 |
| 2097 | `            for (final fallbackRule in fallbackRules) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 回退/降级 规则 属于(in) fallbackRules |
| 2098 | `              AppLog.instance.put('尝试降级规则: $fallbackRule');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('尝试降级规则: $fallbackRule'); |
| 2099 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2100 | `              // 创建临时规则对象` | 注释说明：创建临时规则对象 |
| 2101 | `              final fallbackTocRule = TocRule(` | 声明不可重新赋值的变量 回退/降级 目录(TOC) 规则：调用 目录(TOC) 规则(...) → 目录(目录(TOC)) 规则 |
| 2102 | `                chapterList: fallbackRule,` | 命名实参 章节 列表: 回退/降级 规则（章节 列表） |
| 2103 | `                chapterName: source.ruleToc?.chapterName ?? 'tag.a@text',` | 命名实参 章节 名称: 书源.目录规则?.章节 名称 ?? 'tag.a@文本'（章节 名称） |
| 2104 | `                chapterUrl: source.ruleToc?.chapterUrl ?? 'tag.a@href',` | 命名实参 章节链接: 书源.目录规则?.章节链接 ?? 'tag.a@href'（章节 统一资源链接(URL)） |
| 2105 | `                isVip: source.ruleToc?.isVip,` | 命名实参 isVip: 书源.目录规则?.isVip（是(is) Vip） |
| 2106 | `                updateTime: source.ruleToc?.updateTime,` | 命名实参 updateTime: 书源.目录规则?.updateTime（更新 Time） |
| 2107 | `                nextTocUrl: source.ruleToc?.nextTocUrl,` | 命名实参 下一页目录链接: 书源.目录规则?.下一页目录链接（下一章 目录(目录(TOC)) 统一资源链接(URL)） |
| 2108 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2109 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2110 | `              final fallbackChapterList = RuleParser.parseTocRule(` | 声明不可重新赋值的变量 回退/降级 章节 列表：调用 规则解析器(RuleParser).解析 目录(TOC) 规则(...) → 解析 目录(目录(TOC)) 规则 |
| 2111 | `                html,` | 签名/调用续行参数：网页内容 |
| 2112 | `                fallbackTocRule,` | 签名/调用续行参数：回退/降级 目录(TOC) 规则 |
| 2113 | `                baseUrl: effectiveBaseUrl,` | 命名实参 基础链接: effectiveBaseUrl（base 统一资源链接(URL)） |
| 2114 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2115 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2116 | `              AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2117 | `                  '降级规则 $fallbackRule 匹配结果: ${fallbackChapterList.length} 个章节');` | 以字符串 '降级规则 $回退/降级 规则 匹配结果: ${fallbackChap… 起始的表达式：); |
| 2118 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2119 | `              // 如果匹配到的章节数量大于当前结果，使用这个规则` | 注释说明：如果匹配到的章节数量大于当前结果，使用这个规则 |
| 2120 | `              // 这样可以确保选择匹配到最多章节的规则` | 注释说明：这样可以确保选择匹配到最多章节的规则 |
| 2121 | `              if (fallbackChapterList.length > chapterList.length) {` | 条件判断 如果(if)：回退/降级 章节 列表.长度(length) > 章节 列表.长度(length) |
| 2122 | `                AppLog.instance.put('降级规则 $fallbackRule 匹配到更多章节，使用此规则');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('降级规则 $fallbackRule 匹配到更多章节，使用此规则'); |
| 2123 | `                chapterList = fallbackChapterList;` | 将 回退/降级 章节 列表 赋值给 章节 列表 |
| 2124 | `                // 如果匹配到的章节数量足够多（比如超过10个），可以认为这是正确的规则` | 注释说明：如果匹配到的章节数量足够多（比如超过10个），可以认为这是正确的规则 |
| 2125 | `                if (fallbackChapterList.length >= 10) {` | 条件判断 如果(if)：回退/降级 章节 列表.长度(length) > = 10 |
| 2126 | `                  AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2127 | `                      '降级规则 $fallbackRule 匹配到足够多的章节（${fallbackChapterList.length}个），停止尝试其他规则');` | 以字符串 '降级规则 $回退/降级 规则 匹配到足够多的章节（${回退… 起始的表达式：); |
| 2128 | `                  break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2129 | `                }` | 闭合大括号，结束当前代码块 |
| 2130 | `              }` | 闭合大括号，结束当前代码块 |
| 2131 | `            }` | 闭合大括号，结束当前代码块 |
| 2132 | `          }` | 闭合大括号，结束当前代码块 |
| 2133 | `        }` | 闭合大括号，结束当前代码块 |
| 2134 | `      }` | 闭合大括号，结束当前代码块 |
| 2135 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2136 | `      if (chapterList.isEmpty && source.ruleToc?.chapterList != null) {` | 条件判断 如果(if)：章节 列表.是否为空 且 书源.目录规则?.章节 列表 不等于 空值(null) |
| 2137 | `        AppLog.instance.put('警告: 章节列表为空，但规则不为空。可能是规则不匹配HTML结构。');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('警告: 章节列表为空，但规则不为空。可能是规则不匹配HTML结构。'); |
| 2138 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2139 | `            'HTML前2000字符: ${html.substring(0, html.length > 2000 ? 2000 : html.length)}');` | 以字符串 '网页标记文本(HTML)前2000字符: ${网页内容.substring(0, html.l… 起始的表达式：); |
| 2140 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2141 | `        // 尝试查找可能的目录相关元素（用于调试）` | 注释说明：尝试查找可能的目录相关元素（用于调试） |
| 2142 | `        final dlPattern =` | 上一表达式的续行：不可重新赋值(final) dlPattern = |
| 2143 | `            RegExp('<dl[^>]*>.*?</dl>', caseSensitive: false, dotAll: true);` | 构造函数 正则表达式(RegExp)位置参数 3 个；参数名: 区分大小写开关, 假(false), 点号 全部, 真(true) |
| 2144 | `        final dlMatches = dlPattern.allMatches(html);` | 声明不可重新赋值的变量 dlMatches：调用 dlPattern.allMatches(...) → 全部 Matches |
| 2145 | `        AppLog.instance.put('HTML中找到 ${dlMatches.length} 个 <dl> 标签');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('HTML中找到 ${dlMatches.length} 个 <dl> 标签'); |
| 2146 | `        if (dlMatches.isNotEmpty) {` | 条件判断 如果(if)：dlMatches.是否非空 |
| 2147 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2148 | `              '第一个<dl>标签内容（前500字符）: ${dlMatches.first.group(0)?.substring(0, dlMatches.first.group(0)!.length > 500 ? 500 : dlMatches.first.group(0)!.length)}');` | 以字符串 '第一个<dl>标签内容（前500字符）: ${dlMatches.first.… 起始的表达式：); |
| 2149 | `        }` | 闭合大括号，结束当前代码块 |
| 2150 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2151 | `        final ulPattern =` | 上一表达式的续行：不可重新赋值(final) ulPattern = |
| 2152 | `            RegExp('<ul[^>]*>.*?</ul>', caseSensitive: false, dotAll: true);` | 构造函数 正则表达式(RegExp)位置参数 3 个；参数名: 区分大小写开关, 假(false), 点号 全部, 真(true) |
| 2153 | `        final ulMatches = ulPattern.allMatches(html);` | 声明不可重新赋值的变量 ulMatches：调用 ulPattern.allMatches(...) → 全部 Matches |
| 2154 | `        AppLog.instance.put('HTML中找到 ${ulMatches.length} 个 <ul> 标签');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('HTML中找到 ${ulMatches.length} 个 <ul> 标签'); |
| 2155 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2156 | `        final olPattern =` | 上一表达式的续行：不可重新赋值(final) olPattern = |
| 2157 | `            RegExp('<ol[^>]*>.*?</ol>', caseSensitive: false, dotAll: true);` | 构造函数 正则表达式(RegExp)位置参数 3 个；参数名: 区分大小写开关, 假(false), 点号 全部, 真(true) |
| 2158 | `        final olMatches = olPattern.allMatches(html);` | 声明不可重新赋值的变量 olMatches：调用 olPattern.allMatches(...) → 全部 Matches |
| 2159 | `        AppLog.instance.put('HTML中找到 ${olMatches.length} 个 <ol> 标签');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('HTML中找到 ${olMatches.length} 个 <ol> 标签'); |
| 2160 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2161 | `        // 查找所有包含链接的元素（可能是章节链接）` | 注释说明：查找所有包含链接的元素（可能是章节链接） |
| 2162 | `        final linkPattern = RegExp('<a[^>]*href[^>]*>.*?</a>',` | 不可重新赋值(final) 类型参数 linkPattern，默认值 正则表达式(RegExp)('<a[^>]*href[^>]*>.*?</a>'（link 模式） |
| 2163 | `            caseSensitive: false, dotAll: true);` | 区分大小写开关: 假(false), 点号 全部: 真(true)) |
| 2164 | `        final linkMatches = linkPattern.allMatches(html);` | 声明不可重新赋值的变量 linkMatches：调用 linkPattern.allMatches(...) → 全部 Matches |
| 2165 | `        AppLog.instance.put('HTML中找到 ${linkMatches.length} 个链接');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('HTML中找到 ${linkMatches.length} 个链接'); |
| 2166 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2167 | `        // 记录调试信息后，抛出异常` | 注释说明：记录调试信息后，抛出异常 |
| 2168 | `        throw TocEmptyException(` | 定义方法 目录(TOC) 空 异常：返回 抛出(throw)；无参数。语义：目录(目录(TOC)) 空 异常 |
| 2169 | `            '章节列表为空: 规则不匹配HTML结构 (书源: ${source.bookSourceName})');` | 以字符串 '章节列表为空: 规则不匹配网页标记文本(HTML)结构 (书源: ${source.bookS… 起始的表达式：); |
| 2170 | `      }` | 闭合大括号，结束当前代码块 |
| 2171 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2172 | `      // 转换为BookChapter对象` | 注释说明：转换为章节(BookChapter)对象 |
| 2173 | `      var chapters = <BookChapter>[];` | 声明自动类型推断的变量 章节列表 |
| 2174 | `      for (int i = 0; i < chapterList.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节 列表.长度(length); 循环变量 i++ |
| 2175 | `        final chapterData = chapterList[i];` | 声明不可重新赋值的变量 chapterData |
| 2176 | `        final chapterName = chapterData['chapterName'] ?? '';` | 声明不可重新赋值的变量 章节 名称 |
| 2177 | `        final isVolumeStr = chapterData['isVolume'] ?? '0';` | 声明不可重新赋值的变量 isVolumeStr |
| 2178 | `        final isVolume =` | 上一表达式的续行：不可重新赋值(final) isVolume = |
| 2179 | `            isVolumeStr == '1' \|\| isVolumeStr.toLowerCase() == 'true';` | 续行赋值：将 = '1' \|\| isVolumeStr.toLowerCase() == '真(true)'; 赋给 isVolumeStr |
| 2180 | `        final chapterUrl = chapterData['chapterUrl'];` | 声明不可重新赋值的变量 章节链接 |
| 2181 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2182 | `        // 参考项目逻辑：` | 注释说明：参考项目逻辑： |
| 2183 | `        // 1. 卷名（isVolume）不需要URL，即使URL为空也会添加` | 注释说明：1. 卷名（isVolume）不需要统一资源链接(URL)，即使统一资源链接(URL)为空也会添加 |
| 2184 | `        // 2. 非卷名章节必须有URL` | 注释说明：2. 非卷名章节必须有统一资源链接(URL) |
| 2185 | `        if (!isVolume && (chapterUrl == null \|\| chapterUrl.isEmpty)) {` | 条件判断 如果(if)：!isVolume 且 (chapterUrl 等于 null 或 chapterUrl.isEmpty) |
| 2186 | `          AppLog.instance.put('章节 ${i + 1} 缺少URL且不是卷名，跳过');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('章节 ${i + 1} 缺少URL且不是卷名，跳过'); |
| 2187 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 2188 | `        }` | 闭合大括号，结束当前代码块 |
| 2189 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2190 | `        // 过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接）` | 注释说明：过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接） |
| 2191 | `        // 过滤包含"上一页"、"下一页"等分页文本的章节` | 注释说明：过滤包含"上一页"、"下一页"等分页文本的章节 |
| 2192 | `        // 使用更严格的空白检查：去除所有空白字符后检查是否为空` | 注释说明：使用更严格的空白检查：去除所有空白字符后检查是否为空 |
| 2193 | `        final trimmedName = chapterName.trim().replaceAll(RegExp(r'\s+'), '');` | 声明不可重新赋值的变量 trimmedName：调用 章节 名称.去除首尾空白(...) → 修剪 |
| 2194 | `        if (chapterName.contains('上一页') \|\|` | 条件判断 如果(if)：章节 名称.是否包含('上一页') 或 |
| 2195 | `            chapterName.contains('下一页') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('下一页') \|\| |
| 2196 | `            chapterName.contains('上一章') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('上一章') \|\| |
| 2197 | `            chapterName.contains('下一章') \|\|` | 链式调用起始于 章节 名称（章节 名称），后续行继续该表达式：章节 名称.是否包含('下一章') \|\| |
| 2198 | `            trimmedName.isEmpty) {` | trimmedName.是否为空) { |
| 2199 | `          AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 2200 | `              .put('过滤分页链接或空标题章节: 原始="$chapterName", 处理后="$trimmedName"');` | 链式调用延续：.写入数据库(put)('过滤分页链接或空标题章节: 原始="$chapterName", 处理后="$trimmedName"'); |
| 2201 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 2202 | `        }` | 闭合大括号，结束当前代码块 |
| 2203 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2204 | `        // 构建章节URL（卷名可能没有URL）` | 注释说明：构建章节统一资源链接(URL)（卷名可能没有统一资源链接(URL)） |
| 2205 | `        String finalUrl;` | 字符串(String) finalUrl |
| 2206 | `        if (isVolume) {` | 条件判断 如果(if)：isVolume |
| 2207 | `          // 卷名不需要URL，使用空字符串` | 注释说明：卷名不需要统一资源链接(URL)，使用空字符串 |
| 2208 | `          finalUrl = '';` | finalUrl = '' |
| 2209 | `        } else if (chapterUrl != null && chapterUrl.isNotEmpty) {` | 闭合上一代码块并开始 否则(else) 如果(if) (章节链接 != 空值(null) && chapterUr |
| 2210 | `          // 使用effectiveBaseUrl而不是tocUrl，确保baseUrl是有效的绝对URL` | 注释说明：使用effectiveBaseUrl而不是目录(TOC) URL，确保基础链接是有效的绝对统一资源链接(URL) |
| 2211 | `          finalUrl = NetworkService.joinUrl(effectiveBaseUrl, chapterUrl);` | 将 网络服务(NetworkService).拼接 URL(effectiveBaseUrl, 章节链接) 赋值给 finalUrl（调用 拼接 URL → 拼接 统一资源链接(URL)） |
| 2212 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 2213 | `          // 非卷名但没有URL，跳过（已在上面检查）` | 注释说明：非卷名但没有统一资源链接(URL)，跳过（已在上面检查） |
| 2214 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 2215 | `        }` | 闭合大括号，结束当前代码块 |
| 2216 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2217 | `        final chapter = BookChapter(` | 声明不可重新赋值的变量 章节：调用 章节(BookChapter)(...) → 书籍 章节 |
| 2218 | `          url: finalUrl,` | 命名实参 链接: finalUrl（统一资源链接(URL)） |
| 2219 | `          title: chapterName.isNotEmpty ? chapterName : '第${i + 1}章',` | 命名实参 标题: 章节 名称.是否非空 ? 章节 名称 : '第${循环变量 i + 1}章'（标题） |
| 2220 | `          bookUrl: book.bookUrl,` | 命名实参 书籍链接: 书籍.书籍链接（书籍 统一资源链接(URL)） |
| 2221 | `          baseUrl: source.bookSourceUrl,` | 命名实参 基础链接: 书源.书源链接（base 统一资源链接(URL)） |
| 2222 | `          index: chapters.length, // 使用过滤后的索引` | 命名实参 索引: 章节列表.长度(length)（索引）；行尾注释：使用过滤后的索引 |
| 2223 | `          isVolume: isVolume, // 设置卷名标志` | 命名实参 isVolume: isVolume（是(is) 体积）；行尾注释：设置卷名标志 |
| 2224 | `          isVip: chapterData['isVip'] == 'true' \|\| chapterData['isVip'] == '1',` | 命名实参 isVip: chapterData['isVip'] == '真(true)' \|\| chapterData['isVip'] == '1'（是(is) Vip） |
| 2225 | `          tag: chapterData['updateTime'],` | 命名实参 tag: chapterData['updateTime'] |
| 2226 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2227 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2228 | `        chapters.add(chapter);` | 链式调用起始于 章节列表（章节列表），后续行继续该表达式：章节列表.添加(章节); |
| 2229 | `      }` | 闭合大括号，结束当前代码块 |
| 2230 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2231 | `      final previewCount = chapters.length < 5 ? chapters.length : 5;` | 声明不可重新赋值的变量 previewCount |
| 2232 | `      for (int i = 0; i < previewCount; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < previewCount; 循环变量 i++ |
| 2233 | `        final chapter = chapters[i];` | 声明不可重新赋值的变量 章节 |
| 2234 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2235 | `          '目录预览 ${i + 1}: title=${chapter.title}, url=${chapter.url}',` | 以字符串 '目录预览 ${循环变量 i + 1}: 标题=${章节.标题}, … 起始的表达式：, |
| 2236 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2237 | `      }` | 闭合大括号，结束当前代码块 |
| 2238 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2239 | `      // 过滤最新章节：找到第一个包含数字编号的章节（如"1、"、"2、"等），这应该是真正的目录开始` | 注释说明：过滤最新章节：找到第一个包含数字编号的章节（如"1、"、"2、"等），这应该是真正的目录开始 |
| 2240 | `      // 参考项目：只添加标题不为空的章节，不添加分页链接` | 注释说明：参考项目：只添加标题不为空的章节，不添加分页链接 |
| 2241 | `      if (chapters.isNotEmpty) {` | 条件判断 如果(if)：章节列表.是否非空 |
| 2242 | `        int startIndex = 0;` | 整数(int) 起始 索引 = 0 |
| 2243 | `        // 查找第一个包含数字编号的章节（如"1、"、"2、"、"第一章"等）` | 注释说明：查找第一个包含数字编号的章节（如"1、"、"2、"、"第一章"等） |
| 2244 | `        // 或者查找第一个标题看起来像章节标题的（包含"章"、"节"等）` | 注释说明：或者查找第一个标题看起来像章节标题的（包含"章"、"节"等） |
| 2245 | `        for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 2246 | `          final title = chapters[i].title;` | 声明不可重新赋值的变量 标题 |
| 2247 | `          // 检查是否包含数字编号模式（如"1、"、"2、"、"第一章"、"第1章"等）` | 注释说明：检查是否包含数字编号模式（如"1、"、"2、"、"第一章"、"第1章"等） |
| 2248 | `          // 或者包含"章"、"节"等关键词，且不是"最新章节"、"最新章"等` | 注释说明：或者包含"章"、"节"等关键词，且不是"最新章节"、"最新章"等 |
| 2249 | `          final hasNumberPattern =` | 上一表达式的续行：不可重新赋值(final) hasNumberPattern = |
| 2250 | `              RegExp(r'^\d+[、.]\|^第\d+章\|^第[一二三四五六七八九十]+章').hasMatch(title);` | 构造函数 正则表达式(RegExp)位置参数 1 个；参数名: 标题 |
| 2251 | `          final hasChapterKeyword = title.contains('章') \|\| title.contains('节');` | 声明不可重新赋值的变量 hasChapterKeyword：调用 标题.是否包含(...) → 是否包含 |
| 2252 | `          final isNotLatestChapter =` | 上一表达式的续行：不可重新赋值(final) isNotLatestChapter = |
| 2253 | `              !title.contains('最新') && !title.contains('最近');` | 调用 是否包含(...)：!标题.是否包含('最新') && !标题.是否包含('最近')（是否包含） |
| 2254 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2255 | `          if (hasNumberPattern \|\|` | 条件判断 如果(if)：hasNumberPattern 或 |
| 2256 | `              (hasChapterKeyword && isNotLatestChapter && i >= 6)) {` | (hasChapterKeyword && isNotLatestChapter && 循环变量 i >= 6)) { |
| 2257 | `            // 如果找到了数字编号模式，或者找到了包含"章"的标题且不是"最新"相关，且索引>=6（跳过前几个）` | 注释说明：如果找到了数字编号模式，或者找到了包含"章"的标题且不是"最新"相关，且索引>=6（跳过前几个） |
| 2258 | `            startIndex = i;` | 将 循环变量 i 赋值给 起始 索引 |
| 2259 | `            break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2260 | `          }` | 闭合大括号，结束当前代码块 |
| 2261 | `        }` | 闭合大括号，结束当前代码块 |
| 2262 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2263 | `        // 如果找到了真正的目录开始位置，移除前面的最新章节` | 注释说明：如果找到了真正的目录开始位置，移除前面的最新章节 |
| 2264 | `        // 但至少要保留一个章节，避免全部删除` | 注释说明：但至少要保留一个章节，避免全部删除 |
| 2265 | `        if (startIndex > 0 && startIndex < chapters.length) {` | 条件判断 如果(if)：起始 索引 > 0 且 起始 索引 < 章节列表.长度(length) |
| 2266 | `          chapters.removeRange(0, startIndex);` | 链式调用起始于 章节列表（章节列表），后续行继续该表达式：章节列表.removeRange(0, 起始 索引); |
| 2267 | `          // 重新设置索引` | 注释说明：重新设置索引 |
| 2268 | `          for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 2269 | `            chapters[i] = chapters[i].copyWith(index: i);` | 调用 copyWith(...)：章节列表[循环变量 i] = 章节列表[循环变量 i].copyWith(索引: 循环变量 i)（复制 With） |
| 2270 | `          }` | 闭合大括号，结束当前代码块 |
| 2271 | `        }` | 闭合大括号，结束当前代码块 |
| 2272 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2273 | `        // 如果第一条章节的标题为空或只包含空白字符，移除它` | 注释说明：如果第一条章节的标题为空或只包含空白字符，移除它 |
| 2274 | `        // 但需要确保不会把所有章节都删除` | 注释说明：但需要确保不会把所有章节都删除 |
| 2275 | `        while (chapters.isNotEmpty) {` | 当型循环(while) 循环，条件：章节列表.是否非空 |
| 2276 | `          final firstTitle =` | 上一表达式的续行：不可重新赋值(final) 首个 标题 = |
| 2277 | `              chapters[0].title.trim().replaceAll(RegExp(r'\s+'), '');` | 调用 去除首尾空白/全部替换/正则表达式(RegExp)(...)：章节列表[0].标题.去除首尾空白().全部替换(正则表达式(RegExp)(r'\s+'), '')（修剪 替换 全部 Reg 表达式） |
| 2278 | `          if (firstTitle.isEmpty) {` | 条件判断 如果(if)：首个 标题.是否为空 |
| 2279 | `            chapters.removeAt(0);` | 链式调用起始于 章节列表（章节列表），后续行继续该表达式：章节列表.removeAt(0); |
| 2280 | `            // 重新设置索引` | 注释说明：重新设置索引 |
| 2281 | `            for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 2282 | `              chapters[i] = chapters[i].copyWith(index: i);` | 调用 copyWith(...)：章节列表[循环变量 i] = 章节列表[循环变量 i].copyWith(索引: 循环变量 i)（复制 With） |
| 2283 | `            }` | 闭合大括号，结束当前代码块 |
| 2284 | `            // 如果删除后列表为空，停止循环` | 注释说明：如果删除后列表为空，停止循环 |
| 2285 | `            if (chapters.isEmpty) {` | 条件判断 如果(if)：章节列表.是否为空 |
| 2286 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2287 | `            }` | 闭合大括号，结束当前代码块 |
| 2288 | `          } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 2289 | `            break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2290 | `          }` | 闭合大括号，结束当前代码块 |
| 2291 | `        }` | 闭合大括号，结束当前代码块 |
| 2292 | `      }` | 闭合大括号，结束当前代码块 |
| 2293 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2294 | `      // 去重：保留第一个发现的章节` | 注释说明：去重：保留第一个发现的章节 |
| 2295 | `      // LinkedHashSet 保留第一次出现的元素` | 注释说明：LinkedHashSet 保留第一次出现的元素 |
| 2296 | `      final originalCount = chapters.length;` | 声明不可重新赋值的变量 originalCount |
| 2297 | `      final originalChapters = List<BookChapter>.from(chapters);` | 声明不可重新赋值的变量 originalChapters |
| 2298 | `      chapters = LinkedHashSet<BookChapter>.from(chapters).toList();` | 将 LinkedHashSet<章节(BookChapter)>.from(章节列表).转为列表() 赋值给 章节列表（调用 from/转为列表 → to 列表） |
| 2299 | `      if (chapters.length < originalCount) {` | 条件判断 如果(if)：章节列表.长度(length) < originalCount |
| 2300 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 2301 | `            .put('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）');` | 链式调用延续：.写入数据库(put)('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）'); |
| 2302 | `        final urlCounts = <String, int>{};` | 声明不可重新赋值的变量 urlCounts |
| 2303 | `        for (final chapter in originalChapters) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 章节 属于(in) originalChapters |
| 2304 | `          urlCounts[chapter.url] = (urlCounts[chapter.url] ?? 0) + 1;` | urlCounts[章节.链接] = (urlCounts[章节.链接] ?? 0) + 1 |
| 2305 | `        }` | 闭合大括号，结束当前代码块 |
| 2306 | `        final duplicates =` | 上一表达式的续行：不可重新赋值(final) duplicates = |
| 2307 | `            urlCounts.entries.where((entry) => entry.value > 1).take(5);` | 链式调用起始于 urlCounts.条目集合（条目集合），后续行继续该表达式：urlCounts.条目集合.筛选(where)((条目) => 条目.值 > 1).截取(5); |
| 2308 | `        for (final entry in duplicates) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 条目 属于(in) duplicates |
| 2309 | `          AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2310 | `            '重复章节URL: url=${entry.key}, count=${entry.value}',` | 以字符串 '重复章节统一资源链接(URL): 链接=${条目.键}, 数量=${entr… 起始的表达式：, |
| 2311 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2312 | `        }` | 闭合大括号，结束当前代码块 |
| 2313 | `      }` | 闭合大括号，结束当前代码块 |
| 2314 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2315 | `      // 重新设置索引` | 注释说明：重新设置索引 |
| 2316 | `      for (int i = 0; i < chapters.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 章节列表.长度(length); 循环变量 i++ |
| 2317 | `        chapters[i] = chapters[i].copyWith(index: i);` | 调用 copyWith(...)：章节列表[循环变量 i] = 章节列表[循环变量 i].copyWith(索引: 循环变量 i)（复制 With） |
| 2318 | `      }` | 闭合大括号，结束当前代码块 |
| 2319 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2320 | `      AppLog.instance.put('获取章节列表成功: 共 ${chapters.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表成功: 共 ${chapters.length} 个章节'); |
| 2321 | `      // 不保存到数据库，直接返回` | 注释说明：不保存到数据库，直接返回 |
| 2322 | `      return chapters;` | 返回 章节列表 |
| 2323 | `    } catch (e, stackTrace) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e, stackTrace |
| 2324 | `      AppLog.instance.put('获取章节列表失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节列表失败', error: e); |
| 2325 | `      AppLog.instance.put('错误堆栈: $stackTrace');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('错误堆栈: $stackTrace'); |
| 2326 | `      // 重新抛出异常，让调用者能够处理错误` | 注释说明：重新抛出异常，让调用者能够处理错误 |
| 2327 | `      // 如果调用者希望静默处理，可以在调用处捕获异常` | 注释说明：如果调用者希望静默处理，可以在调用处捕获异常 |
| 2328 | `      rethrow;` | rethrow |
| 2329 | `    }` | 闭合大括号，结束当前代码块 |
| 2330 | `  }` | 闭合大括号，结束当前代码块 |
| 2331 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2332 | `  /// 更新书籍目录（用于更新目录功能，支持分页获取）` | 文档注释：说明其后代码的用途 |
| 2333 | `  Future<bool> updateChapterList(Book book) async {` | 【承接上方文档】更新书籍目录（用于更新目录功能，支持分页获取） → 定义方法 更新 章节 列表：返回 异步结果(Future)<布尔(bool)>；位置参数 1 个；含命名参数；参数名: 书籍（异步）。语义：更新 章节 列表 |
| 2334 | `    if (book.isLocal \|\| !book.canUpdate) {` | 条件判断 如果(if)：书籍.isLocal 或 !书籍.canUpdate |
| 2335 | `      return false;` | 返回 假(false)（布尔值 假(false)） |
| 2336 | `    }` | 闭合大括号，结束当前代码块 |
| 2337 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2338 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2339 | `      final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 2340 | `      if (db == null) return false;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 假(false); |
| 2341 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2342 | `      // 先获取书籍信息（如果需要）` | 注释说明：先获取书籍信息（如果需要） |
| 2343 | `      final updatedBook = await getBookInfo(book);` | 声明不可重新赋值的变量 已更新 书籍：等待(await) 调用 getBookInfo(...) → 获取 书籍 Info |
| 2344 | `      if (updatedBook == null) return false;` | 条件判断 如果(if)：已更新 书籍 等于 空值(null)) 返回(return) 假(false); |
| 2345 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2346 | `      // 使用 getChapterList 方法获取所有章节（支持分页）` | 注释说明：使用 获取 章节 列表 方法获取所有章节（支持分页） |
| 2347 | `      final chapters = await getChapterList(updatedBook);` | 声明不可重新赋值的变量 章节列表：等待(await) 调用 获取 章节 列表(...) → 获取 章节 列表 |
| 2348 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2349 | `      if (chapters.isEmpty) {` | 条件判断 如果(if)：章节列表.是否为空 |
| 2350 | `        return false;` | 返回 假(false)（布尔值 假(false)） |
| 2351 | `      }` | 闭合大括号，结束当前代码块 |
| 2352 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2353 | `      // 更新书籍信息` | 注释说明：更新书籍信息 |
| 2354 | `      await saveBook(updatedBook.copyWith(` | 调用 保存 书籍(...)（等待异步完成） → 保存 书籍 |
| 2355 | `        totalChapterNum: chapters.length,` | 命名实参 totalChapterNum: 章节列表.长度(length)（total 章节 编号） |
| 2356 | `        lastCheckTime: DateTime.now().millisecondsSinceEpoch,` | 命名实参 lastCheckTime: DateTime.now().millisecondsSinceEpoch（最后 检查 Time） |
| 2357 | `        latestChapterTitle: chapters.isNotEmpty ? chapters.last.title : null,` | 命名实参 latestChapterTitle: 章节列表.是否非空 ? 章节列表.last.标题 : 空值(null)（latest 章节 标题） |
| 2358 | `      ));` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2359 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2360 | `      return true;` | 返回 真(true)（布尔值 真(true)） |
| 2361 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2362 | `      AppLog.instance.put('更新目录失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('更新目录失败', error: e); |
| 2363 | `      return false;` | 返回 假(false)（布尔值 假(false)） |
| 2364 | `    }` | 闭合大括号，结束当前代码块 |
| 2365 | `  }` | 闭合大括号，结束当前代码块 |
| 2366 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2367 | `  /// 批量更新目录` | 文档注释：说明其后代码的用途 |
| 2368 | `  Future<Map<String, bool>> updateChapterLists(List<Book> books) async {` | 【承接上方文档】批量更新目录 → 定义方法 更新 章节 列表集合：返回 异步结果(Future)<映射(Map)<字符串(String), 布尔(bool)>>；位置参数 1 个；含命名参数；参数名: 书籍列表（异步）。语义：更新 章节 列表集合 |
| 2369 | `    final results = <String, bool>{};` | 声明不可重新赋值的变量 结果 |
| 2370 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2371 | `    // 过滤出可以更新的网络书籍` | 注释说明：过滤出可以更新的网络书籍 |
| 2372 | `    final booksToUpdate =` | 上一表达式的续行：不可重新赋值(final) booksToUpdate = |
| 2373 | `        books.where((book) => !book.isLocal && book.canUpdate).toList();` | 链式调用起始于 书籍列表（书籍列表），后续行继续该表达式：书籍列表.筛选(where)((书籍) => !书籍.isLocal && 书籍.canUpdate).转为列表(); |
| 2374 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2375 | `    for (final book in booksToUpdate) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 书籍 属于(in) booksToUpdate |
| 2376 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2377 | `        final success = await updateChapterList(book);` | 声明不可重新赋值的变量 成功：等待(await) 调用 更新 章节 列表(...) → 更新 章节 列表 |
| 2378 | `        results[book.bookUrl] = success;` | 结果[书籍.书籍链接] = 成功 |
| 2379 | `      } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2380 | `        results[book.bookUrl] = false;` | 结果[书籍.书籍链接] = 假(false) |
| 2381 | `      }` | 闭合大括号，结束当前代码块 |
| 2382 | `    }` | 闭合大括号，结束当前代码块 |
| 2383 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2384 | `    return results;` | 返回 结果 |
| 2385 | `  }` | 闭合大括号，结束当前代码块 |
| 2386 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2387 | `  /// 通过URL添加书籍` | 文档注释：说明其后代码的用途 |
| 2388 | `  Future<int> addBookByUrl(String bookUrls, {int? groupId}) async {` | 【承接上方文档】通过统一资源链接(URL)添加书籍 → 定义方法 addBookByUrl：返回 异步结果(Future)<整数(int)>；位置参数 1 个；含命名参数；参数名: bookUrls, 捕获组 编号(id)（异步）。语义：添加 书籍 By 统一资源链接(URL) |
| 2389 | `    int successCount = 0;` | 整数(int) 成功 数量 = 0 |
| 2390 | `    final urls = bookUrls.split('\n');` | 声明不可重新赋值的变量 urls：调用 bookUrls.切分(...) → 切分 |
| 2391 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2392 | `    for (final url in urls) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 链接 属于(in) urls |
| 2393 | `      final bookUrl = url.trim();` | 声明不可重新赋值的变量 书籍链接：调用 链接.去除首尾空白(...) → 修剪 |
| 2394 | `      if (bookUrl.isEmpty) continue;` | 条件判断 如果(if)：书籍链接.是否为空) 继续(continue); |
| 2395 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2396 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2397 | `        // 检查书籍是否已存在` | 注释说明：检查书籍是否已存在 |
| 2398 | `        final existingBook = await getBookByUrl(bookUrl);` | 声明不可重新赋值的变量 existingBook：等待(await) 调用 getBookByUrl(...) → 获取 书籍 By 统一资源链接(URL) |
| 2399 | `        if (existingBook != null) {` | 条件判断 如果(if)：existingBook 不等于 空值(null) |
| 2400 | `          successCount++;` | 成功 数量++ |
| 2401 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 2402 | `        }` | 闭合大括号，结束当前代码块 |
| 2403 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2404 | `        // 获取baseUrl` | 注释说明：获取基础链接 |
| 2405 | `        final uri = Uri.tryParse(bookUrl);` | 声明不可重新赋值的变量 uri：调用 统一资源标识(URI).tryParse(...) → 尝试(try) 解析 |
| 2406 | `        if (uri == null) continue;` | 条件判断 如果(if)：uri 等于 空值(null)) 继续(continue); |
| 2407 | `        final baseUrl = '${uri.scheme}://${uri.host}';` | 声明不可重新赋值的变量 基础链接：字符串字面量 '${uri.scheme}://${uri.主机}'; |
| 2408 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2409 | `        // 查找匹配的书源` | 注释说明：查找匹配的书源 |
| 2410 | `        BookSource? source =` | 上一表达式的续行：书源(BookSource)? 书源 = |
| 2411 | `            await _bookSourceService.getBookSourceByUrl(baseUrl);` | 调用 _书籍 书源 服务.getBookSourceByUrl(...)（等待异步完成） → 获取 书籍 书源 By 统一资源链接(URL) |
| 2412 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2413 | `        // 如果没找到，尝试通过bookUrlPattern匹配` | 注释说明：如果没找到，尝试通过书籍 URL 模式匹配 |
| 2414 | `        if (source == null) {` | 条件判断 如果(if)：书源 等于 空值(null) |
| 2415 | `          final allSources =` | 上一表达式的续行：不可重新赋值(final) 全部 书源列表 = |
| 2416 | `              await _bookSourceService.getAllBookSources(enabledOnly: true);` | 调用 _书籍 书源 服务.获取 全部 书籍 书源列表(...)（等待异步完成） → 获取 全部 书籍 书源列表 |
| 2417 | `          for (final s in allSources) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) s 属于(in) 全部 书源列表 |
| 2418 | `            if (s.bookUrlPattern != null && s.bookUrlPattern!.isNotEmpty) {` | 条件判断 如果(if)：s.书籍 URL 模式 不等于 空值(null) 且 s.书籍 URL 模式!.是否非空 |
| 2419 | `              try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2420 | `                final pattern = RegExp(s.bookUrlPattern!);` | 声明不可重新赋值的变量 模式：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 2421 | `                if (pattern.hasMatch(bookUrl)) {` | 条件判断 如果(if)：模式.是否匹配(书籍链接) |
| 2422 | `                  source = s;` | 将 s 赋值给 书源 |
| 2423 | `                  break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2424 | `                }` | 闭合大括号，结束当前代码块 |
| 2425 | `              } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2426 | `                // 正则表达式错误，跳过` | 注释说明：正则表达式错误，跳过 |
| 2427 | `                continue;` | 继续(continue)：进入下一次循环迭代 |
| 2428 | `              }` | 闭合大括号，结束当前代码块 |
| 2429 | `            }` | 闭合大括号，结束当前代码块 |
| 2430 | `          }` | 闭合大括号，结束当前代码块 |
| 2431 | `        }` | 闭合大括号，结束当前代码块 |
| 2432 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2433 | `        if (source == null) continue;` | 条件判断 如果(if)：书源 等于 空值(null)) 继续(continue); |
| 2434 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2435 | `        // 创建书籍对象` | 注释说明：创建书籍对象 |
| 2436 | `        final book = Book(` | 声明不可重新赋值的变量 书籍：调用 书籍(Book)(...) → 书籍 |
| 2437 | `          bookUrl: bookUrl,` | 命名实参 书籍链接: 书籍链接（书籍 统一资源链接(URL)） |
| 2438 | `          origin: source.bookSourceUrl,` | 命名实参 来源: 书源.书源链接（来源） |
| 2439 | `          originName: source.bookSourceName,` | 命名实参 来源 名称: 书源.书籍 书源 名称（来源 名称） |
| 2440 | `          canUpdate: true,` | 命名实参 canUpdate: 真(true)（can 更新） |
| 2441 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2442 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2443 | `        // 获取书籍信息` | 注释说明：获取书籍信息 |
| 2444 | `        final bookInfo = await getBookInfo(book);` | 声明不可重新赋值的变量 bookInfo：等待(await) 调用 getBookInfo(...) → 获取 书籍 Info |
| 2445 | `        if (bookInfo == null) continue;` | 条件判断 如果(if)：bookInfo 等于 空值(null)) 继续(continue); |
| 2446 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2447 | `        // 检查是否已存在同名同作者的书籍` | 注释说明：检查是否已存在同名同作者的书籍 |
| 2448 | `        final existingBookByName =` | 上一表达式的续行：不可重新赋值(final) existingBookByName = |
| 2449 | `            await getBookByNameAndAuthor(bookInfo.name, bookInfo.author);` | 调用 getBookByNameAndAuthor(...)（等待异步完成） → 获取 书籍 By 名称 And 作者 |
| 2450 | `        if (existingBookByName != null) {` | 条件判断 如果(if)：existingBookByName 不等于 空值(null) |
| 2451 | `          // 如果已存在，更新章节列表` | 注释说明：如果已存在，更新章节列表 |
| 2452 | `          final chapters = await getChapterList(bookInfo);` | 声明不可重新赋值的变量 章节列表：等待(await) 调用 获取 章节 列表(...) → 获取 章节 列表 |
| 2453 | `          if (chapters.isNotEmpty) {` | 条件判断 如果(if)：章节列表.是否非空 |
| 2454 | `            // 删除旧章节` | 注释说明：删除旧章节 |
| 2455 | `            final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 2456 | `            if (db != null) {` | 条件判断 如果(if)：数据库 不等于 空值(null) |
| 2457 | `              await db.delete(` | 调用 数据库.delete(...)（等待异步完成） → 删除 |
| 2458 | `                'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 2459 | `                where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 2460 | `                whereArgs: [existingBookByName.bookUrl],` | 命名实参 筛选(where) 实参列表: [existingBookByName.书籍链接]（筛选(筛选(where)) 实参列表） |
| 2461 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2462 | `              // 保存新章节` | 注释说明：保存新章节 |
| 2463 | `              await saveChapters(chapters` | 调用 保存 章节列表(...)（等待异步完成） → 保存 章节列表 |
| 2464 | `                  .map((c) => c.copyWith(bookUrl: existingBookByName.bookUrl))` | 链式调用延续：.映射(map)((c) => c.copyWith(书籍链接: existingBookByName.书籍链接)) |
| 2465 | `                  .toList());` | 链式调用延续：.转为列表()); |
| 2466 | `            }` | 闭合大括号，结束当前代码块 |
| 2467 | `          }` | 闭合大括号，结束当前代码块 |
| 2468 | `          successCount++;` | 成功 数量++ |
| 2469 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 2470 | `        }` | 闭合大括号，结束当前代码块 |
| 2471 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2472 | `        // 获取章节列表` | 注释说明：获取章节列表 |
| 2473 | `        final chapters = await getChapterList(bookInfo);` | 声明不可重新赋值的变量 章节列表：等待(await) 调用 获取 章节 列表(...) → 获取 章节 列表 |
| 2474 | `        if (chapters.isEmpty) continue;` | 条件判断 如果(if)：章节列表.是否为空) 继续(continue); |
| 2475 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2476 | `        // 设置分组` | 注释说明：设置分组 |
| 2477 | `        final finalBook =` | 上一表达式的续行：不可重新赋值(final) finalBook = |
| 2478 | `            groupId != null ? bookInfo.copyWith(group: groupId) : bookInfo;` | 调用 copyWith(...)：捕获组 编号(id) != 空值(null) ? bookInfo.copyWith(捕获组: 捕获组 编号(id)) : bookInfo（复制 With） |
| 2479 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2480 | `        // 保存书籍` | 注释说明：保存书籍 |
| 2481 | `        await createBook(finalBook);` | 调用 createBook(...)（等待异步完成） → create 书籍 |
| 2482 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2483 | `        successCount++;` | 成功 数量++ |
| 2484 | `      } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2485 | `        // 添加失败，继续下一个` | 注释说明：添加失败，继续下一个 |
| 2486 | `        continue;` | 继续(continue)：进入下一次循环迭代 |
| 2487 | `      }` | 闭合大括号，结束当前代码块 |
| 2488 | `    }` | 闭合大括号，结束当前代码块 |
| 2489 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2490 | `    return successCount;` | 返回 成功 数量 |
| 2491 | `  }` | 闭合大括号，结束当前代码块 |
| 2492 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2493 | `  /// 根据URL获取书籍` | 文档注释：说明其后代码的用途 |
| 2494 | `  Future<Book?> getBookByUrl(String bookUrl) async {` | 【承接上方文档】根据统一资源链接(URL)获取书籍 → 定义方法 getBookByUrl：返回 异步结果(Future)<书籍(Book)?>；位置参数 1 个；含命名参数；参数名: 书籍链接（异步）。语义：获取 书籍 By 统一资源链接(URL) |
| 2495 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 2496 | `    if (db == null) return null;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 空值(null); |
| 2497 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 2498 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 2499 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 2500 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 2501 | `      limit: 1,` | 命名实参 limit: 1（限制） |
| 2502 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2503 | `    if (result.isEmpty) return null;` | 条件判断 如果(if)：结果.是否为空) 返回(return) 空值(null); |
| 2504 | `    return _bookFromDbMap(result.first);` | 返回调用 _bookFromDbMap(...) 的结果（语义：书籍 From 数据库 映射） |
| 2505 | `  }` | 闭合大括号，结束当前代码块 |
| 2506 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2507 | `  /// 根据书名和作者获取书籍` | 文档注释：说明其后代码的用途 |
| 2508 | `  Future<Book?> getBookByNameAndAuthor(String name, String author) async {` | 【承接上方文档】根据书名和作者获取书籍 → 定义方法 getBookByNameAndAuthor：返回 异步结果(Future)<书籍(Book)?>；位置参数 2 个；含命名参数；参数名: 名称, 作者（异步）。语义：获取 书籍 By 名称 And 作者 |
| 2509 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 2510 | `    if (db == null) return null;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 空值(null); |
| 2511 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 2512 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 2513 | `      where: 'name = ? AND author = ?',` | 命名实参 筛选(where): '名称 = ? AND 作者 = ?'（筛选(筛选(where))） |
| 2514 | `      whereArgs: [name, author],` | 命名实参 筛选(where) 实参列表: [名称, 作者]（筛选(筛选(where)) 实参列表） |
| 2515 | `      limit: 1,` | 命名实参 limit: 1（限制） |
| 2516 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2517 | `    if (result.isEmpty) return null;` | 条件判断 如果(if)：结果.是否为空) 返回(return) 空值(null); |
| 2518 | `    return _bookFromDbMap(result.first);` | 返回调用 _bookFromDbMap(...) 的结果（语义：书籍 From 数据库 映射） |
| 2519 | `  }` | 闭合大括号，结束当前代码块 |
| 2520 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2521 | `  /// 通过书名和作者搜索并添加书籍（用于导入书单）` | 文档注释：说明其后代码的用途 |
| 2522 | `  Future<int> addBookByNameAndAuthor(String name, String author,` | 【承接上方文档】通过书名和作者搜索并添加书籍（用于导入书单） → 定义方法 addBookByNameAndAuthor：返回 异步结果(Future)<整数(int)>；位置参数 2 个；参数名: 名称, 作者（异步）。语义：添加 书籍 By 名称 And 作者 |
| 2523 | `      {int? groupId}) async {` | {整数(int)? 捕获组 编号(id)}) 异步(async) { |
| 2524 | `    if (name.isEmpty) return 0;` | 条件判断 如果(if)：名称.是否为空) 返回(return) 0; |
| 2525 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2526 | `    // 检查是否已存在` | 注释说明：检查是否已存在 |
| 2527 | `    final existingBook = await getBookByNameAndAuthor(name, author);` | 声明不可重新赋值的变量 existingBook：等待(await) 调用 getBookByNameAndAuthor(...) → 获取 书籍 By 名称 And 作者 |
| 2528 | `    if (existingBook != null) {` | 条件判断 如果(if)：existingBook 不等于 空值(null) |
| 2529 | `      return 0; // 已存在，不重复添加` | 返回 0（数值 0）；行尾注释：已存在，不重复添加 |
| 2530 | `    }` | 闭合大括号，结束当前代码块 |
| 2531 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2532 | `    // 搜索书籍` | 注释说明：搜索书籍 |
| 2533 | `    final searchResults = await searchBooks(name);` | 声明不可重新赋值的变量 搜索 结果：等待(await) 调用 搜索 书籍列表(...) → 搜索 书籍列表 |
| 2534 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2535 | `    // 精确匹配书名和作者` | 注释说明：精确匹配书名和作者 |
| 2536 | `    Book? matchedBook;` | 书籍(Book)? matchedBook |
| 2537 | `    for (final book in searchResults) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 书籍 属于(in) 搜索 结果 |
| 2538 | `      if (book.name == name && book.author == author) {` | 条件判断 如果(if)：书籍.名称 等于 名称 且 书籍.作者 等于 作者 |
| 2539 | `        matchedBook = book;` | 将 书籍 赋值给 matchedBook |
| 2540 | `        break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2541 | `      }` | 闭合大括号，结束当前代码块 |
| 2542 | `    }` | 闭合大括号，结束当前代码块 |
| 2543 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2544 | `    if (matchedBook == null) {` | 条件判断 如果(if)：matchedBook 等于 空值(null) |
| 2545 | `      return 0; // 未找到匹配的书籍` | 返回 0（数值 0）；行尾注释：未找到匹配的书籍 |
| 2546 | `    }` | 闭合大括号，结束当前代码块 |
| 2547 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2548 | `    // 获取书籍详情` | 注释说明：获取书籍详情 |
| 2549 | `    final bookInfo = await getBookInfo(matchedBook);` | 声明不可重新赋值的变量 bookInfo：等待(await) 调用 getBookInfo(...) → 获取 书籍 Info |
| 2550 | `    if (bookInfo == null) return 0;` | 条件判断 如果(if)：bookInfo 等于 空值(null)) 返回(return) 0; |
| 2551 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2552 | `    // 获取章节列表` | 注释说明：获取章节列表 |
| 2553 | `    final chapters = await getChapterList(bookInfo);` | 声明不可重新赋值的变量 章节列表：等待(await) 调用 获取 章节 列表(...) → 获取 章节 列表 |
| 2554 | `    if (chapters.isEmpty) return 0;` | 条件判断 如果(if)：章节列表.是否为空) 返回(return) 0; |
| 2555 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2556 | `    // 设置分组` | 注释说明：设置分组 |
| 2557 | `    final finalBook =` | 上一表达式的续行：不可重新赋值(final) finalBook = |
| 2558 | `        groupId != null ? bookInfo.copyWith(group: groupId) : bookInfo;` | 调用 copyWith(...)：捕获组 编号(id) != 空值(null) ? bookInfo.copyWith(捕获组: 捕获组 编号(id)) : bookInfo（复制 With） |
| 2559 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2560 | `    // 保存书籍` | 注释说明：保存书籍 |
| 2561 | `    await createBook(finalBook);` | 调用 createBook(...)（等待异步完成） → create 书籍 |
| 2562 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2563 | `    return 1;` | 返回 1（数值 1） |
| 2564 | `  }` | 闭合大括号，结束当前代码块 |
| 2565 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2566 | `  /// 导入书单（从JSON）` | 文档注释：说明其后代码的用途 |
| 2567 | `  Future<int> importBooklist(String jsonText, {int? groupId}) async {` | 【承接上方文档】导入书单（从JSON数据） → 定义方法 importBooklist：返回 异步结果(Future)<整数(int)>；位置参数 1 个；含命名参数；参数名: JSON 文本, 捕获组 编号(id)（异步）。语义：导入(import) Booklist |
| 2568 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2569 | `      // 解析JSON` | 注释说明：解析JSON数据 |
| 2570 | `      final jsonData = jsonDecode(jsonText);` | 声明不可重新赋值的变量 jsonData：调用 JSON 解码(...) → JSON数据 解码 |
| 2571 | `      if (jsonData is! List) {` | 条件判断 如果(if)：jsonData 是(is)! 列表(List) |
| 2572 | `        throw Exception('书单格式错误：应为数组格式');` | 定义方法 异常：返回 抛出(throw)；位置参数 1 个。语义：异常 |
| 2573 | `      }` | 闭合大括号，结束当前代码块 |
| 2574 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2575 | `      int successCount = 0;` | 整数(int) 成功 数量 = 0 |
| 2576 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2577 | `      // 遍历书单` | 注释说明：遍历书单 |
| 2578 | `      for (final item in jsonData) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 条目 属于(in) jsonData |
| 2579 | `        if (item is! Map) continue;` | 条件判断 如果(if)：条目 是(is)! 映射(Map)) 继续(continue); |
| 2580 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2581 | `        final name = item['name']?.toString() ?? '';` | 声明不可重新赋值的变量 名称 |
| 2582 | `        final author = item['author']?.toString() ?? '';` | 声明不可重新赋值的变量 作者 |
| 2583 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2584 | `        if (name.isEmpty) continue;` | 条件判断 如果(if)：名称.是否为空) 继续(continue); |
| 2585 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2586 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2587 | `          final count =` | 上一表达式的续行：不可重新赋值(final) 数量 = |
| 2588 | `              await addBookByNameAndAuthor(name, author, groupId: groupId);` | 调用 addBookByNameAndAuthor(...)（等待异步完成） → 添加 书籍 By 名称 And 作者 |
| 2589 | `          successCount += count;` | 成功 数量 += 数量 |
| 2590 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2591 | `          // 单个书籍添加失败，继续下一个` | 注释说明：单个书籍添加失败，继续下一个 |
| 2592 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 2593 | `        }` | 闭合大括号，结束当前代码块 |
| 2594 | `      }` | 闭合大括号，结束当前代码块 |
| 2595 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2596 | `      return successCount;` | 返回 成功 数量 |
| 2597 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2598 | `      throw Exception('导入书单失败: $e');` | 定义方法 异常：返回 抛出(throw)；位置参数 1 个；参数名: 导入书单失败。语义：异常 |
| 2599 | `    }` | 闭合大括号，结束当前代码块 |
| 2600 | `  }` | 闭合大括号，结束当前代码块 |
| 2601 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2602 | `  /// 获取章节正文` | 文档注释：说明其后代码的用途 |
| 2603 | `  /// 参考项目：支持分页获取（nextContentUrl），循环获取所有页面的内容` | 文档注释：说明其后代码的用途 |
| 2604 | `  /// [book] 可选参数，传入后会自动检查和保存文件缓存，避免重复网络请求` | 文档注释：说明其后代码的用途 |
| 2605 | `  Future<String?> getChapterContent(` | 【承接上方文档】获取章节正文 参考项目：支持分页获取（下一页正文链接），循环获取所有页面的内容 [书籍] 可选参数，传入后会自动检查和保存文件缓存，避免重复网 → 定义方法 获取 章节 正文内容：返回 异步结果(Future)<字符串(String)?>；无参数（异步）。语义：获取 章节 正文内容 |
| 2606 | `    BookChapter chapter,` | 章节(BookChapter) 类型参数 章节（章节） |
| 2607 | `    BookSource source, {` | 书源(BookSource) 类型参数 书源，其后 { 开启命名参数块（书源） |
| 2608 | `    String? bookName,` | 字符串(String)? 类型参数 书籍 名称（书籍 名称） |
| 2609 | `    String? bookOrigin,` | 字符串(String)? 类型参数 书籍 来源（书籍 来源） |
| 2610 | `    Book? book, // 新增：用于缓存检查和保存` | 书籍(Book)? 类型参数 书籍（书籍） |
| 2611 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 2612 | `    if (source.ruleContent == null) {` | 条件判断 如果(if)：书源.正文规则 等于 空值(null) |
| 2613 | `      AppLog.instance.put('获取章节内容失败: 内容规则为空 (章节: ${chapter.title})');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节内容失败: 内容规则为空 (章节: ${chapter.title})'); |
| 2614 | `      return null;` | 返回 空值(null)（初始为 空值(null)） |
| 2615 | `    }` | 闭合大括号，结束当前代码块 |
| 2616 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2617 | `    // ✅ 新策略: 优先从文件存储读取` | 注释说明：✅ 新策略: 优先从文件存储读取 |
| 2618 | `    if (book != null && !book.isLocal) {` | 条件判断 如果(if)：书籍 不等于 空值(null) 且 !书籍.isLocal |
| 2619 | `      // 1. 如果chapter有localPath,从文件读取` | 注释说明：1. 如果章节有本地存储路径,从文件读取 |
| 2620 | `      if (chapter.localPath != null && chapter.localPath!.isNotEmpty) {` | 条件判断 如果(if)：章节.本地存储路径 不等于 空值(null) 且 章节.本地存储路径!.是否非空 |
| 2621 | `        final fileContent = await readService(AppServices.chapterContentService)` | 声明不可重新赋值的变量 文件(file) 正文内容：等待(await) 调用 读取 服务(...) → 读取 服务 |
| 2622 | `            .getChapterContent(book, chapter);` | 链式调用延续：.获取 章节 正文内容(书籍, 章节); |
| 2623 | `        if (fileContent != null && fileContent.isNotEmpty) {` | 条件判断 如果(if)：文件(file) 正文内容 不等于 空值(null) 且 文件(file) 正文内容.是否非空 |
| 2624 | `          AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 2625 | `              .put('从文件存储读取: ${chapter.title} (${fileContent.length}字)');` | 链式调用延续：.写入数据库(put)('从文件存储读取: ${章节.标题} (${fileContent.length}字)'); |
| 2626 | `          return fileContent;` | 返回 文件(file) 正文内容 |
| 2627 | `        }` | 闭合大括号，结束当前代码块 |
| 2628 | `        // localPath存在但文件不存在,继续从网络获取` | 注释说明：本地存储路径存在但文件不存在,继续从网络获取 |
| 2629 | `        AppLog.instance.put('警告: localPath存在但文件不存在: ${chapter.title}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('警告: localPath存在但文件不存在: ${chapter.title}'); |
| 2630 | `      }` | 闭合大括号，结束当前代码块 |
| 2631 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2632 | `      // 2. 尝试从文件系统读取(向后兼容旧缓存)` | 注释说明：2. 尝试从文件系统读取(向后兼容旧缓存) |
| 2633 | `      final fileContent = await readService(AppServices.chapterContentService)` | 声明不可重新赋值的变量 文件(file) 正文内容：等待(await) 调用 读取 服务(...) → 读取 服务 |
| 2634 | `          .getChapterContent(book, chapter);` | 链式调用延续：.获取 章节 正文内容(书籍, 章节); |
| 2635 | `      if (fileContent != null && fileContent.isNotEmpty) {` | 条件判断 如果(if)：文件(file) 正文内容 不等于 空值(null) 且 文件(file) 正文内容.是否非空 |
| 2636 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2637 | `            '从文件系统读取(无localPath): ${chapter.title} (${fileContent.length}字)');` | 以字符串 '从文件系统读取(无localPath): ${章节.标题} (… 起始的表达式：); |
| 2638 | `        // 更新localPath` | 注释说明：更新本地存储路径 |
| 2639 | `        final localPath = readService(AppServices.chapterContentService)` | 声明不可重新赋值的变量 本地存储路径：调用 读取 服务(...) → 读取 服务 |
| 2640 | `            .getChapterLocalPath(book, chapter);` | 链式调用延续：.获取 章节 本地 路径(书籍, 章节); |
| 2641 | `        chapter.localPath = localPath;` | 将 本地存储路径 赋值给 章节.本地存储路径 |
| 2642 | `        // 异步更新数据库,不阻塞返回` | 注释说明：异步更新数据库,不阻塞返回 |
| 2643 | `        _updateChapterLocalPath(chapter.bookUrl, chapter.url, localPath)` | 调用 _更新 章节 本地 路径(...)：_更新 章节 本地 路径(章节.书籍链接, 章节.链接, 本地存储路径)（更新 章节 本地 路径） |
| 2644 | `            .catchError((e) => AppLog.instance.put('更新localPath失败', error: e));` | 链式调用延续：.catchError((异常对象 e) => 应用日志(AppLog).实例.写入数据库(put)('更新localPath失败', error: e)); |
| 2645 | `        return fileContent;` | 返回 文件(file) 正文内容 |
| 2646 | `      }` | 闭合大括号，结束当前代码块 |
| 2647 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2648 | `      // 3. 回退: 从旧的CacheService读取` | 注释说明：3. 回退: 从旧的缓存 服务读取 |
| 2649 | `      final cachedContent = await readService(AppServices.cacheService)` | 声明不可重新赋值的变量 已缓存 正文内容：等待(await) 调用 读取 服务(...) → 读取 服务 |
| 2650 | `          .getCachedChapterContent(book, chapter);` | 链式调用延续：.获取 已缓存 章节 正文内容(书籍, 章节); |
| 2651 | `      if (cachedContent != null && cachedContent.isNotEmpty) {` | 条件判断 如果(if)：已缓存 正文内容 不等于 空值(null) 且 已缓存 正文内容.是否非空 |
| 2652 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 2653 | `            .put('从旧缓存读取: ${chapter.title} (${cachedContent.length}字)');` | 链式调用延续：.写入数据库(put)('从旧缓存读取: ${章节.标题} (${cachedContent.length}字)'); |
| 2654 | `        return cachedContent;` | 返回 已缓存 正文内容 |
| 2655 | `      }` | 闭合大括号，结束当前代码块 |
| 2656 | `    }` | 闭合大括号，结束当前代码块 |
| 2657 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2658 | `    final chapterKey = chapter.primaryStr();` | 声明不可重新赋值的变量 章节 键：调用 章节.primaryStr(...) → primary 字符串 |
| 2659 | `    return _loadingChapters.putIfAbsent(chapterKey, () async {` | 返回调用 _加载中 章节列表.putIfAbsent(...) 的结果（语义：写入数据库(写入数据库(put)) If Absent） |
| 2660 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2661 | `        return await _getChapterContentInternal(` | 返回异步调用 _获取 章节 正文内容 内部(...) 的结果（语义：获取 章节 正文内容 内部） |
| 2662 | `          chapter,` | 签名/调用续行参数：章节 |
| 2663 | `          source,` | 签名/调用续行参数：书源 |
| 2664 | `          bookName: bookName,` | 命名实参 书籍 名称: 书籍 名称（书籍 名称） |
| 2665 | `          bookOrigin: bookOrigin,` | 命名实参 书籍 来源: 书籍 来源（书籍 来源） |
| 2666 | `          book: book,` | 命名实参 书籍: 书籍（书籍） |
| 2667 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2668 | `      } finally {` | 闭合代码块并衔接后续语句：最终(finally) { |
| 2669 | `        _loadingChapters.remove(chapterKey);` | 链式调用起始于 _加载中 章节列表（加载中 章节列表），后续行继续该表达式：_加载中 章节列表.移除(章节 键); |
| 2670 | `      }` | 闭合大括号，结束当前代码块 |
| 2671 | `    });` | 闭合代码块并衔接后续语句：); |
| 2672 | `  }` | 闭合大括号，结束当前代码块 |
| 2673 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2674 | `  /// 获取章节正文的内部实现` | 文档注释：说明其后代码的用途 |
| 2675 | `  /// 参考项目：支持分页获取（nextContentUrl），循环获取所有页面的内容` | 文档注释：说明其后代码的用途 |
| 2676 | `  Future<String?> _getChapterContentInternal(` | 【承接上方文档】获取章节正文的内部实现 参考项目：支持分页获取（下一页正文链接），循环获取所有页面的内容 → 定义方法 _获取 章节 正文内容 内部：返回 异步结果(Future)<字符串(String)?>；无参数（异步）。语义：获取 章节 正文内容 内部 |
| 2677 | `    BookChapter chapter,` | 章节(BookChapter) 类型参数 章节（章节） |
| 2678 | `    BookSource source, {` | 书源(BookSource) 类型参数 书源，其后 { 开启命名参数块（书源） |
| 2679 | `    String? bookName,` | 字符串(String)? 类型参数 书籍 名称（书籍 名称） |
| 2680 | `    String? bookOrigin,` | 字符串(String)? 类型参数 书籍 来源（书籍 来源） |
| 2681 | `    Book? book, // 新增：用于缓存保存` | 书籍(Book)? 类型参数 书籍（书籍） |
| 2682 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 2683 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2684 | `      final contentVariables =` | 上一表达式的续行：不可重新赋值(final) 正文内容 变量表 = |
| 2685 | `          book != null ? _buildRuleVariables(book) : <String, String>{};` | 调用 _构建 规则 变量表(...)：书籍 != 空值(null) ? _构建 规则 变量表(书籍) : <字符串(String), 字符串(String)>{}（构建 规则 变量表） |
| 2686 | `      // 参考项目：使用章节URL作为baseUrl，支持分页获取` | 注释说明：参考项目：使用章节统一资源链接(URL)作为基础链接，支持分页获取 |
| 2687 | `      // 参考项目：BookContent.analyzeContent` | 注释说明：参考项目：书籍 正文内容.分析 正文内容 |
| 2688 | `      var currentUrl = chapter.url;` | 声明自动类型推断的变量 当前 URL |
| 2689 | `      currentUrl = _repairChapterUrlWithBookVariables(currentUrl, book);` | 将 _repairChapterUrlWithBookVariables(当前 URL, 书籍) 赋值给 当前 URL（调用 _repairChapterUrlWithBookVariables → 修复 章节 统一资源链接(URL) With 书籍 变量表） |
| 2690 | `      var redirectUrl = currentUrl; // 重定向后的URL` | 声明自动类型推断的变量 重定向 URL；行尾注释：重定向后的统一资源链接(URL) |
| 2691 | `      var visitedUrls = <String>{currentUrl};` | 声明自动类型推断的变量 visitedUrls |
| 2692 | `      var contentList = <String>[];` | 声明自动类型推断的变量 正文内容 列表 |
| 2693 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2694 | `      // 参考项目：获取下一章的URL（用于判断是否到达下一章）` | 注释说明：参考项目：获取下一章的统一资源链接(URL)（用于判断是否到达下一章） |
| 2695 | `      final localChapters = await _getLocalChapters(chapter.bookUrl);` | 声明不可重新赋值的变量 本地 章节列表：等待(await) 调用 _获取 本地 章节列表(...) → 获取 本地 章节列表 |
| 2696 | `      BookChapter? nextChapter;` | 章节(BookChapter)? 下一章 章节 |
| 2697 | `      if (chapter.index + 1 < localChapters.length) {` | 条件判断 如果(if)：章节.索引 + 1 < 本地 章节列表.长度(length) |
| 2698 | `        nextChapter = localChapters[chapter.index + 1];` | 将 本地 章节列表[章节.索引 + 1] 赋值给 下一章 章节 |
| 2699 | `      } else if (localChapters.isNotEmpty) {` | 闭合上一代码块并开始 否则(else) 如果(if) (本地 章节列表.是否非空) { |
| 2700 | `        // 参考项目：如果下一章不存在，使用第一章（循环）` | 注释说明：参考项目：如果下一章不存在，使用第一章（循环） |
| 2701 | `        nextChapter = localChapters[0];` | 将 本地 章节列表[0] 赋值给 下一章 章节 |
| 2702 | `      }` | 闭合大括号，结束当前代码块 |
| 2703 | `      final nextChapterUrl = nextChapter?.url;` | 声明不可重新赋值的变量 下一章 章节 URL |
| 2704 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2705 | `      // ── Phase 3：payAction 预执行（付费章节自动解锁）──────────────────────` | 注释说明：── 相位 3：payAction 预执行（付费章节自动解锁）────────────────────── |
| 2706 | `      // 当章节是 VIP 且未购买，且书源配置了 payAction 时，先执行解锁动作，` | 注释说明：当章节是 VIP 且未购买，且书源配置了 payAction 时，先执行解锁动作， |
| 2707 | `      // 成功后重新请求章节页面以获取解锁内容。` | 注释说明：成功后重新请求章节页面以获取解锁内容。 |
| 2708 | `      bool didPayAction = false;` | 布尔(bool) didPayAction = 假(false) |
| 2709 | `      if (chapter.isVip &&` | 条件判断 如果(if)：章节.isVip 且 |
| 2710 | `          !chapter.isPay &&` | 上一表达式的续行：!章节.isPay && |
| 2711 | `          source.ruleContent?.payAction != null &&` | 上一表达式的续行：书源.正文规则?.payAction != 空值(null) && |
| 2712 | `          source.ruleContent!.payAction!.isNotEmpty) {` | 书源.正文规则!.payAction!.是否非空) { |
| 2713 | `        AppLog.instance.put('payAction: 检测到付费章节，尝试执行解锁 (章节: ${chapter.title})');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('payAction: 检测到付费章节，尝试执行解锁 (章节: ${chapter.title})'… |
| 2714 | `        // 先请求一次页面（payAction 可能需要当前页的 HTML 上下文，如 cookie/token）` | 注释说明：先请求一次页面（payAction 可能需要当前页的 网页标记文本(HTML) 上下文，如 Cookie/符号） |
| 2715 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2716 | `          final preResponse = await _networkService.get(` | 声明不可重新赋值的变量 preResponse：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 2717 | `            currentUrl,` | 签名/调用续行参数：当前 URL |
| 2718 | `            headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 2719 | `            retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 2720 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2721 | `          final preHtml = await NetworkService.getResponseText(preResponse);` | 声明不可重新赋值的变量 preHtml：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 2722 | `          didPayAction = await RuleParser.executePayAction(` | 将 等待异步结果：等待(await) 规则解析器(RuleParser).executePayAction( 赋值给 didPayAction（调用 executePayAction → 执行 Pay Action） |
| 2723 | `            preHtml,` | 签名/调用续行参数：preHtml |
| 2724 | `            source.ruleContent!.payAction!,` | 书源.正文规则!.payAction!, |
| 2725 | `            variables: contentVariables,` | 命名实参 variables: 正文内容 变量表（变量表） |
| 2726 | `            source: source,` | 命名实参 书源: 书源（书源） |
| 2727 | `            book: book,` | 命名实参 书籍: 书籍（书籍） |
| 2728 | `            baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 2729 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2730 | `          if (didPayAction) {` | 条件判断 如果(if)：didPayAction |
| 2731 | `            AppLog.instance.put('payAction: 解锁请求已发送，将重新请求章节页面');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('payAction: 解锁请求已发送，将重新请求章节页面'); |
| 2732 | `          }` | 闭合大括号，结束当前代码块 |
| 2733 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2734 | `          AppLog.instance.put('payAction: 预请求失败，跳过解锁', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('payAction: 预请求失败，跳过解锁', error: e); |
| 2735 | `        }` | 闭合大括号，结束当前代码块 |
| 2736 | `      }` | 闭合大括号，结束当前代码块 |
| 2737 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2738 | `      final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 2739 | `        currentUrl,` | 签名/调用续行参数：当前 URL |
| 2740 | `        headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 2741 | `        retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 2742 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2743 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2744 | `      var html = await NetworkService.getResponseText(response);` | 声明自动类型推断的变量 网页内容：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 2745 | `      // 参考项目：获取重定向后的URL（如果有）` | 注释说明：参考项目：获取重定向后的统一资源链接(URL)（如果有） |
| 2746 | `      // 注意：Dio的Response可能没有redirectRecord，使用实际请求的URL` | 注释说明：注意：Dio的响应可能没有重定向 记录，使用实际请求的统一资源链接(URL) |
| 2747 | `      redirectUrl = response.realUri.toString();` | 将 响应.realUri.转为字符串() 赋值给 重定向 URL（调用 转为字符串 → to 字符串(字符串(String))） |
| 2748 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2749 | `      AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 2750 | `          .put('获取章节内容响应: 状态码=${response.statusCode}, 内容长度=${html.length}');` | 链式调用延续：.写入数据库(put)('获取章节内容响应: 状态码=${response.statusCode}, 内容长度=${html.length}'); |
| 2751 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2752 | `      if (html.isEmpty) {` | 条件判断 如果(if)：网页内容.是否为空 |
| 2753 | `        AppLog.instance.put('章节内容响应为空');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('章节内容响应为空'); |
| 2754 | `        throw ContentEmptyException('章节内容为空: ${chapter.title}');` | 定义方法 正文内容 空 异常：返回 抛出(throw)；位置参数 1 个；含命名参数；参数名: 章节内容为空, 标题。语义：正文内容 空 异常 |
| 2755 | `      }` | 闭合大括号，结束当前代码块 |
| 2756 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2757 | `      final pageContent = await RuleParser.parseContentRule(` | 声明不可重新赋值的变量 页 正文内容：等待(await) 调用 规则解析器(RuleParser).解析 正文内容 规则(...) → 解析 正文内容 规则 |
| 2758 | `        html,` | 签名/调用续行参数：网页内容 |
| 2759 | `        source.ruleContent,` | 签名/调用续行参数：书源.正文规则 |
| 2760 | `        variables: contentVariables,` | 命名实参 variables: 正文内容 变量表（变量表） |
| 2761 | `        baseUrl: currentUrl, // 使用当前请求的URL作为baseUrl` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)）；行尾注释：使用当前请求的统一资源链接(URL)作为基础链接 |
| 2762 | `        bookName: bookName,` | 命名实参 书籍 名称: 书籍 名称（书籍 名称） |
| 2763 | `        bookOrigin: bookOrigin,` | 命名实参 书籍 来源: 书籍 来源（书籍 来源） |
| 2764 | `        applyReplaceRegex: false, // 不在每页应用，而是在合并后统一应用` | 命名实参 applyReplaceRegex: 假(false)（apply 替换 正则）；行尾注释：不在每页应用，而是在合并后统一应用 |
| 2765 | `        bookSourceType: source.bookSourceType, // 传入书源类型，启用音视频分发路径` | 命名实参 书籍 书源 类型: 书源.书籍 书源 类型（书籍 书源 类型）；行尾注释：传入书源类型，启用音视频分发路径 |
| 2766 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2767 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2768 | `      if (pageContent == null \|\| pageContent.isEmpty) {` | 条件判断 如果(if)：页 正文内容 等于 空值(null) 或 页 正文内容.是否为空 |
| 2769 | `        AppLog.instance.put('章节内容解析失败: 内容为空 (章节: ${chapter.title})');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('章节内容解析失败: 内容为空 (章节: ${chapter.title})'); |
| 2770 | `        throw ContentEmptyException('章节内容为空: ${chapter.title}');` | 定义方法 正文内容 空 异常：返回 抛出(throw)；位置参数 1 个；含命名参数；参数名: 章节内容为空, 标题。语义：正文内容 空 异常 |
| 2771 | `      }` | 闭合大括号，结束当前代码块 |
| 2772 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2773 | `      // 音频源（bookSourceType == 1）：parseContentRule 返回的是通过` | 注释说明：音频源（书籍 书源 类型 == 1）：解析 正文内容 规则 返回的是通过 |
| 2774 | `      // audioUrl 规则或 sourceRegex 嗅探提取的媒体 URL，将其写入` | 注释说明：音频 URL 规则或 书源 正则 嗅探提取的媒体 统一资源链接(URL)，将其写入 |
| 2775 | `      // chapter.resourceUrl 供播放器直接使用。` | 注释说明：章节.resourceUrl 供播放器直接使用。 |
| 2776 | `      if (source.bookSourceType == 1) {` | 条件判断 如果(if)：书源.书籍 书源 类型 等于 1 |
| 2777 | `        chapter.resourceUrl = pageContent;` | 将 页 正文内容 赋值给 章节.resourceUrl |
| 2778 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2779 | `            '音频源: 已提取资源URL → ${chapter.resourceUrl} (章节: ${chapter.title})');` | 以字符串 '音频源: 已提取资源统一资源链接(URL) → ${章节.resourceUrl} … 起始的表达式：); |
| 2780 | `      }` | 闭合大括号，结束当前代码块 |
| 2781 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2782 | `      // ── Phase 3：解析音视频辅助字段（lyricsUrl/subtitleUrl/qualityOptions）` | 注释说明：── 相位 3：解析音视频辅助字段（lyricsUrl/subtitleUrl/qualityOptions） |
| 2783 | `      if (source.bookSourceType == 1 \|\| source.bookSourceType == 2) {` | 条件判断 如果(if)：书源.书籍 书源 类型 等于 1 或 书源.书籍 书源 类型 等于 2 |
| 2784 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2785 | `          final extras = await RuleParser.parseAudioExtras(` | 声明不可重新赋值的变量 extras：等待(await) 调用 规则解析器(RuleParser).parseAudioExtras(...) → 解析 音频 Extras |
| 2786 | `            html,` | 签名/调用续行参数：网页内容 |
| 2787 | `            source.ruleContent,` | 签名/调用续行参数：书源.正文规则 |
| 2788 | `            variables: contentVariables,` | 命名实参 variables: 正文内容 变量表（变量表） |
| 2789 | `            baseUrl: currentUrl,` | 命名实参 基础链接: 当前 URL（base 统一资源链接(URL)） |
| 2790 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2791 | `          if (extras['lyricsUrl'] != null) {` | 条件判断 如果(if)：extras['lyricsUrl'] 不等于 空值(null) |
| 2792 | `            chapter.lyricsUrl = extras['lyricsUrl'];` | 将 extras['lyricsUrl'] 赋值给 章节.lyricsUrl |
| 2793 | `          }` | 闭合大括号，结束当前代码块 |
| 2794 | `          if (extras['subtitleUrl'] != null) {` | 条件判断 如果(if)：extras['subtitleUrl'] 不等于 空值(null) |
| 2795 | `            chapter.subtitleUrl = extras['subtitleUrl'];` | 将 extras['subtitleUrl'] 赋值给 章节.subtitleUrl |
| 2796 | `          }` | 闭合大括号，结束当前代码块 |
| 2797 | `          if (extras['qualityOptions'] != null) {` | 条件判断 如果(if)：extras['qualityOptions'] 不等于 空值(null) |
| 2798 | `            chapter.qualityOptions = extras['qualityOptions'];` | 将 extras['qualityOptions'] 赋值给 章节.qualityOptions |
| 2799 | `          }` | 闭合大括号，结束当前代码块 |
| 2800 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2801 | `          AppLog.instance.put('parseAudioExtras: 解析辅助字段失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('parseAudioExtras: 解析辅助字段失败', error: e); |
| 2802 | `        }` | 闭合大括号，结束当前代码块 |
| 2803 | `      }` | 闭合大括号，结束当前代码块 |
| 2804 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2805 | `      contentList.add(pageContent);` | 链式调用起始于 正文内容 列表（正文内容 列表），后续行继续该表达式：正文内容 列表.添加(页 正文内容); |
| 2806 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2807 | `      // 参考项目：获取下一页URL列表（可能返回多个URL）` | 注释说明：参考项目：获取下一页统一资源链接(URL)列表（可能返回多个统一资源链接(URL)） |
| 2808 | `      // 参考项目：analyzeRule.getStringList(nextUrlRule, isUrl = true)` | 注释说明：参考项目：分析 规则.获取 字符串(String) 列表(下一章 URL 规则, isUrl = 真(true)) |
| 2809 | `      List<String> nextUrlList = [];` | 列表(List)<字符串(String)> 下一章 URL 列表 = [] |
| 2810 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2811 | `      if (source.ruleContent?.nextContentUrl != null &&` | 条件判断 如果(if)：书源.正文规则?.下一页正文链接 不等于 空值(null) 且 |
| 2812 | `          source.ruleContent!.nextContentUrl!.isNotEmpty) {` | 书源.正文规则!.下一页正文链接!.是否非空) { |
| 2813 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 2814 | `            .put('获取章节内容下一页URL: 规则=${source.ruleContent!.nextContentUrl}');` | 链式调用延续：.写入数据库(put)('获取章节内容下一页URL: 规则=${source.ruleContent!.nextContentUrl}'); |
| 2815 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2816 | `        // 参考项目：使用parseListRule获取URL列表（isUrl=true）` | 注释说明：参考项目：使用解析 列表 规则获取统一资源链接(URL)列表（isUrl=真(true)） |
| 2817 | `        final rawNextUrlList = await RuleParser.parseUrlListRuleAsync(` | 声明不可重新赋值的变量 原始 下一章 URL 列表：等待(await) 调用 规则解析器(RuleParser).parseUrlListRuleAsync(...) → 解析 统一资源链接(URL) 列表 规则 Async |
| 2818 | `          html,` | 签名/调用续行参数：网页内容 |
| 2819 | `          source.ruleContent!.nextContentUrl!,` | 书源.正文规则!.下一页正文链接!, |
| 2820 | `          variables: contentVariables,` | 命名实参 variables: 正文内容 变量表（变量表） |
| 2821 | `          baseUrl: redirectUrl,` | 命名实参 基础链接: 重定向 URL（base 统一资源链接(URL)） |
| 2822 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2823 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2824 | `        // 将相对URL转换为绝对URL，并过滤` | 注释说明：将相对统一资源链接(URL)转换为绝对统一资源链接(URL)，并过滤 |
| 2825 | `        for (final url in rawNextUrlList) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 链接 属于(in) 原始 下一章 URL 列表 |
| 2826 | `          if (url.isNotEmpty) {` | 条件判断 如果(if)：链接.是否非空 |
| 2827 | `            final absoluteUrl = url.startsWith('http')` | 声明不可重新赋值的变量 absoluteUrl |
| 2828 | `                ? url` | 上一表达式的续行：? 链接 |
| 2829 | `                : NetworkService.joinUrl(redirectUrl, url);` | 三元表达式为假时取值：网络服务(NetworkService).拼接 URL(重定向 URL, 链接); |
| 2830 | `            // 参考项目：过滤掉与redirectUrl相同的URL` | 注释说明：参考项目：过滤掉与重定向 URL相同的统一资源链接(URL) |
| 2831 | `            if (absoluteUrl != redirectUrl &&` | 条件判断 如果(if)：absoluteUrl 不等于 重定向 URL 且 |
| 2832 | `                !visitedUrls.contains(absoluteUrl)) {` | 调用 是否包含(...)：!visitedUrls.是否包含(absoluteUrl)) {（是否包含） |
| 2833 | `              nextUrlList.add(absoluteUrl);` | 链式调用起始于 下一章 URL 列表（下一章 统一资源链接(URL) 列表），后续行继续该表达式：下一章 URL 列表.添加(absoluteUrl); |
| 2834 | `            }` | 闭合大括号，结束当前代码块 |
| 2835 | `          }` | 闭合大括号，结束当前代码块 |
| 2836 | `        }` | 闭合大括号，结束当前代码块 |
| 2837 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2838 | `        AppLog.instance.put('获取章节内容下一页URL: 找到 ${nextUrlList.length} 个URL');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节内容下一页URL: 找到 ${nextUrlList.length} 个URL'); |
| 2839 | `        for (int i = 0; i < nextUrlList.length; i++) {` | 循环(for)-属于(in) 遍历：整数(int) 循环变量 i = 0; 循环变量 i < 下一章 URL 列表.长度(length); 循环变量 i++ |
| 2840 | `          AppLog.instance.put('  下一页URL ${i + 1}: ${nextUrlList[i]}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)(' 下一页URL ${i + 1}: ${nextUrlList[i]}'); |
| 2841 | `        }` | 闭合大括号，结束当前代码块 |
| 2842 | `      }` | 闭合大括号，结束当前代码块 |
| 2843 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2844 | `      // 参考项目逻辑：` | 注释说明：参考项目逻辑： |
| 2845 | `      // 如果 nextUrlList.size == 0，没有下一页，直接返回` | 注释说明：如果 下一章 URL 列表.大小 == 0，没有下一页，直接返回 |
| 2846 | `      // 如果 nextUrlList.size == 1，循环获取所有页面` | 注释说明：如果 下一章 URL 列表.大小 == 1，循环获取所有页面 |
| 2847 | `      // 如果 nextUrlList.size > 1，并发获取所有页面` | 注释说明：如果 下一章 URL 列表.大小 > 1，并发获取所有页面 |
| 2848 | `      if (nextUrlList.isEmpty) {` | 条件判断 如果(if)：下一章 URL 列表.是否为空 |
| 2849 | `        // 没有下一页，直接返回` | 注释说明：没有下一页，直接返回 |
| 2850 | `        AppLog.instance.put('没有找到下一页URL');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('没有找到下一页URL'); |
| 2851 | `      } else if (nextUrlList.length == 1) {` | 闭合上一代码块并开始 否则(else) 如果(if) (下一章 URL 列表.长度(length) == 1) { |
| 2852 | `        // 参考项目：循环获取所有页面` | 注释说明：参考项目：循环获取所有页面 |
| 2853 | `        var nextUrl = nextUrlList[0];` | 声明自动类型推断的变量 下一章 URL |
| 2854 | `        var pageCount = 1;` | 声明自动类型推断的变量 页 数量 |
| 2855 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2856 | `        while (nextUrl.isNotEmpty && !visitedUrls.contains(nextUrl)) {` | 当型循环(while) 循环，条件：下一章 URL.是否非空 && !visitedUrls.是否包含(下一章 URL) |
| 2857 | `          // 参考项目：检查是否到达下一章` | 注释说明：参考项目：检查是否到达下一章 |
| 2858 | `          // 参考项目逻辑：NetworkUtils.getAbsoluteURL(redirectUrl, nextUrl) == NetworkUtils.getAbsoluteURL(redirectUrl, mNextChapterUrl)` | 注释说明：参考项目逻辑：NetworkUtils.getAbsoluteURL(重定向 URL, 下一章 URL) == NetworkUtils.getAbsoluteURL(重定向 URL, mNextChapterUrl) |
| 2859 | `          if (nextChapterUrl != null) {` | 条件判断 如果(if)：下一章 章节 URL 不等于 空值(null) |
| 2860 | `            // 将两个 URL 都通过 getAbsoluteURL 规范化后再比较` | 注释说明：将两个 统一资源链接(URL) 都通过 getAbsoluteURL 规范化后再比较 |
| 2861 | `            final normalizedNextUrl =` | 上一表达式的续行：不可重新赋值(final) normalizedNextUrl = |
| 2862 | `                NetworkUtils.getAbsoluteURL(redirectUrl, nextUrl);` | 链式调用起始于 NetworkUtils，后续行继续该表达式：NetworkUtils.getAbsoluteURL(重定向 URL, 下一章 URL); |
| 2863 | `            final normalizedNextChapterUrl =` | 上一表达式的续行：不可重新赋值(final) normalizedNextChapterUrl = |
| 2864 | `                NetworkUtils.getAbsoluteURL(redirectUrl, nextChapterUrl);` | 链式调用起始于 NetworkUtils，后续行继续该表达式：NetworkUtils.getAbsoluteURL(重定向 URL, 下一章 章节 URL); |
| 2865 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2866 | `            if (_urlEquals(normalizedNextUrl, normalizedNextChapterUrl)) {` | 条件判断 如果(if)：_urlEquals(normalizedNextUrl, normalizedNextChapterUrl) |
| 2867 | `              AppLog.instance.put('下一页URL等于下一章URL，停止获取');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('下一页URL等于下一章URL，停止获取'); |
| 2868 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2869 | `            }` | 闭合大括号，结束当前代码块 |
| 2870 | `          }` | 闭合大括号，结束当前代码块 |
| 2871 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2872 | `          pageCount++;` | 页 数量++ |
| 2873 | `          visitedUrls.add(nextUrl);` | 链式调用起始于 visitedUrls，后续行继续该表达式：visitedUrls.添加(下一章 URL); |
| 2874 | `          AppLog.instance.put('获取章节内容第 $pageCount 页: $nextUrl');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节内容第 $pageCount 页: $nextUrl'); |
| 2875 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2876 | `          try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2877 | `            final nextResponse = await _networkService.get(` | 声明不可重新赋值的变量 下一章 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 2878 | `              nextUrl,` | 签名/调用续行参数：下一章 URL |
| 2879 | `              headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 2880 | `              retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 2881 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2882 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2883 | `            final nextHtml = await NetworkService.getResponseText(nextResponse);` | 声明不可重新赋值的变量 下一章 HTML：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 2884 | `            final nextRedirectUrl = nextResponse.realUri.toString();` | 声明不可重新赋值的变量 下一章 重定向 URL：调用 下一章 响应.realUri.转为字符串(...) → to 字符串(字符串(String)) |
| 2885 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2886 | `            if (nextHtml.isEmpty) {` | 条件判断 如果(if)：下一章 HTML.是否为空 |
| 2887 | `              AppLog.instance.put('章节内容响应为空，停止获取');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('章节内容响应为空，停止获取'); |
| 2888 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2889 | `            }` | 闭合大括号，结束当前代码块 |
| 2890 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2891 | `            final nextPageContent = await RuleParser.parseContentRule(` | 声明不可重新赋值的变量 下一章 页 正文内容：等待(await) 调用 规则解析器(RuleParser).解析 正文内容 规则(...) → 解析 正文内容 规则 |
| 2892 | `              nextHtml,` | 签名/调用续行参数：下一章 HTML |
| 2893 | `              source.ruleContent,` | 签名/调用续行参数：书源.正文规则 |
| 2894 | `              baseUrl: nextUrl,` | 命名实参 基础链接: 下一章 URL（base 统一资源链接(URL)） |
| 2895 | `              bookName: bookName,` | 命名实参 书籍 名称: 书籍 名称（书籍 名称） |
| 2896 | `              bookOrigin: bookOrigin,` | 命名实参 书籍 来源: 书籍 来源（书籍 来源） |
| 2897 | `              applyReplaceRegex: false,` | 命名实参 applyReplaceRegex: 假(false)（apply 替换 正则） |
| 2898 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2899 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2900 | `            if (nextPageContent != null && nextPageContent.isNotEmpty) {` | 条件判断 如果(if)：下一章 页 正文内容 不等于 空值(null) 且 下一章 页 正文内容.是否非空 |
| 2901 | `              contentList.add(nextPageContent);` | 链式调用起始于 正文内容 列表（正文内容 列表），后续行继续该表达式：正文内容 列表.添加(下一章 页 正文内容); |
| 2902 | `              AppLog.instance.put('第${contentList.length}页完成');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('第${contentList.length}页完成'); |
| 2903 | `            }` | 闭合大括号，结束当前代码块 |
| 2904 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2905 | `            // 获取下一页URL` | 注释说明：获取下一页统一资源链接(URL) |
| 2906 | `            if (source.ruleContent?.nextContentUrl != null &&` | 条件判断 如果(if)：书源.正文规则?.下一页正文链接 不等于 空值(null) 且 |
| 2907 | `                source.ruleContent!.nextContentUrl!.isNotEmpty) {` | 书源.正文规则!.下一页正文链接!.是否非空) { |
| 2908 | `              final nextNextUrlList = RuleParser.parseListRule(` | 声明不可重新赋值的变量 下一章 下一章 URL 列表：调用 规则解析器(RuleParser).解析 列表 规则(...) → 解析 列表 规则 |
| 2909 | `                nextHtml,` | 签名/调用续行参数：下一章 HTML |
| 2910 | `                source.ruleContent!.nextContentUrl!,` | 书源.正文规则!.下一页正文链接!, |
| 2911 | `                variables: null,` | 命名实参 variables: 空值(null)（变量表） |
| 2912 | `                baseUrl: nextRedirectUrl,` | 命名实参 基础链接: 下一章 重定向 URL（base 统一资源链接(URL)） |
| 2913 | `                returnHtml: false,` | 命名实参 returnHtml: 假(false)（返回(return) 网页标记文本(HTML)） |
| 2914 | `              );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2915 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2916 | `              // 转换为绝对URL并过滤` | 注释说明：转换为绝对统一资源链接(URL)并过滤 |
| 2917 | `              final filteredNextUrls = <String>[];` | 声明不可重新赋值的变量 filteredNextUrls |
| 2918 | `              for (final url in nextNextUrlList) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 链接 属于(in) 下一章 下一章 URL 列表 |
| 2919 | `                if (url.isNotEmpty) {` | 条件判断 如果(if)：链接.是否非空 |
| 2920 | `                  final absoluteUrl = url.startsWith('http')` | 声明不可重新赋值的变量 absoluteUrl |
| 2921 | `                      ? url` | 上一表达式的续行：? 链接 |
| 2922 | `                      : NetworkService.joinUrl(nextRedirectUrl, url);` | 三元表达式为假时取值：网络服务(NetworkService).拼接 URL(下一章 重定向 URL, 链接); |
| 2923 | `                  if (absoluteUrl != nextRedirectUrl &&` | 条件判断 如果(if)：absoluteUrl 不等于 下一章 重定向 URL 且 |
| 2924 | `                      !visitedUrls.contains(absoluteUrl)) {` | 调用 是否包含(...)：!visitedUrls.是否包含(absoluteUrl)) {（是否包含） |
| 2925 | `                    // 检查是否到达下一章（参考项目：使用 getAbsoluteURL 规范化后比较）` | 注释说明：检查是否到达下一章（参考项目：使用 getAbsoluteURL 规范化后比较） |
| 2926 | `                    if (nextChapterUrl != null) {` | 条件判断 如果(if)：下一章 章节 URL 不等于 空值(null) |
| 2927 | `                      final normalizedAbsoluteUrl = NetworkUtils.getAbsoluteURL(` | 声明不可重新赋值的变量 normalizedAbsoluteUrl：调用 NetworkUtils.getAbsoluteURL(...) → 获取 Absolute 统一资源链接(URL) |
| 2928 | `                          nextRedirectUrl, absoluteUrl);` | 下一章 重定向 URL, absoluteUrl) |
| 2929 | `                      final normalizedNextChapterUrl =` | 上一表达式的续行：不可重新赋值(final) normalizedNextChapterUrl = |
| 2930 | `                          NetworkUtils.getAbsoluteURL(` | 链式调用起始于 NetworkUtils，后续行继续该表达式：NetworkUtils.getAbsoluteURL( |
| 2931 | `                              nextRedirectUrl, nextChapterUrl);` | 下一章 重定向 URL, 下一章 章节 URL) |
| 2932 | `                      if (_urlEquals(` | 条件判断 如果(if)：_urlEquals( |
| 2933 | `                          normalizedAbsoluteUrl, normalizedNextChapterUrl)) {` | normalizedAbsoluteUrl, normalizedNextChapterUrl)) { |
| 2934 | `                        AppLog.instance.put('检测到下一页URL等于下一章URL，停止获取');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('检测到下一页URL等于下一章URL，停止获取'); |
| 2935 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2936 | `                        filteredNextUrls.clear();` | 链式调用起始于 filteredNextUrls（已过滤 下一章 Urls），后续行继续该表达式：filteredNextUrls.clear(); |
| 2937 | `                        break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2938 | `                      }` | 闭合大括号，结束当前代码块 |
| 2939 | `                    }` | 闭合大括号，结束当前代码块 |
| 2940 | `                    filteredNextUrls.add(absoluteUrl);` | 链式调用起始于 filteredNextUrls（已过滤 下一章 Urls），后续行继续该表达式：filteredNextUrls.添加(absoluteUrl); |
| 2941 | `                  }` | 闭合大括号，结束当前代码块 |
| 2942 | `                }` | 闭合大括号，结束当前代码块 |
| 2943 | `              }` | 闭合大括号，结束当前代码块 |
| 2944 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2945 | `              if (filteredNextUrls.isEmpty) {` | 条件判断 如果(if)：filteredNextUrls.是否为空 |
| 2946 | `                break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2947 | `              }` | 闭合大括号，结束当前代码块 |
| 2948 | `              nextUrl = filteredNextUrls[0];` | 将 filteredNextUrls[0] 赋值给 下一章 URL |
| 2949 | `            } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 2950 | `              break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2951 | `            }` | 闭合大括号，结束当前代码块 |
| 2952 | `          } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2953 | `            AppLog.instance.put('获取第 $pageCount 页失败: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取第 $pageCount 页失败: $e', error: e); |
| 2954 | `            break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 2955 | `          }` | 闭合大括号，结束当前代码块 |
| 2956 | `        }` | 闭合大括号，结束当前代码块 |
| 2957 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2958 | `        AppLog.instance.put('本章总页数: ${visitedUrls.length}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('本章总页数: ${visitedUrls.length}'); |
| 2959 | `      } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 2960 | `        // 参考项目：并发获取所有页面` | 注释说明：参考项目：并发获取所有页面 |
| 2961 | `        // 注意：并发模式下也需要过滤掉下一章的URL` | 注释说明：注意：并发模式下也需要过滤掉下一章的统一资源链接(URL) |
| 2962 | `        final filteredNextUrlList = <String>[];` | 声明不可重新赋值的变量 已过滤 下一章 URL 列表 |
| 2963 | `        if (nextChapterUrl != null) {` | 条件判断 如果(if)：下一章 章节 URL 不等于 空值(null) |
| 2964 | `          // 参考项目：使用 getAbsoluteURL 规范化后比较` | 注释说明：参考项目：使用 getAbsoluteURL 规范化后比较 |
| 2965 | `          final normalizedNextChapterUrl =` | 上一表达式的续行：不可重新赋值(final) normalizedNextChapterUrl = |
| 2966 | `              NetworkUtils.getAbsoluteURL(redirectUrl, nextChapterUrl);` | 链式调用起始于 NetworkUtils，后续行继续该表达式：NetworkUtils.getAbsoluteURL(重定向 URL, 下一章 章节 URL); |
| 2967 | `          for (final url in nextUrlList) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 链接 属于(in) 下一章 URL 列表 |
| 2968 | `            final normalizedUrl = NetworkUtils.getAbsoluteURL(redirectUrl, url);` | 声明不可重新赋值的变量 normalizedUrl：调用 NetworkUtils.getAbsoluteURL(...) → 获取 Absolute 统一资源链接(URL) |
| 2969 | `            if (!_urlEquals(normalizedUrl, normalizedNextChapterUrl)) {` | 条件判断 如果(if)：!_urlEquals(normalizedUrl, normalizedNextChapterUrl) |
| 2970 | `              filteredNextUrlList.add(url);` | 链式调用起始于 已过滤 下一章 URL 列表（已过滤 下一章 统一资源链接(URL) 列表），后续行继续该表达式：已过滤 下一章 URL 列表.添加(链接); |
| 2971 | `            } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 2972 | `              AppLog.instance.put('并发模式：过滤掉下一章URL: $url');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('并发模式：过滤掉下一章URL: $url'); |
| 2973 | `            }` | 闭合大括号，结束当前代码块 |
| 2974 | `          }` | 闭合大括号，结束当前代码块 |
| 2975 | `        } else {` | 闭合上一分支并开始 否则(else) 分支 |
| 2976 | `          filteredNextUrlList.addAll(nextUrlList);` | 链式调用起始于 已过滤 下一章 URL 列表（已过滤 下一章 统一资源链接(URL) 列表），后续行继续该表达式：已过滤 下一章 URL 列表.批量添加(下一章 URL 列表); |
| 2977 | `        }` | 闭合大括号，结束当前代码块 |
| 2978 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2979 | `        AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 2980 | `            '并发解析正文，总页数: ${filteredNextUrlList.length} (原始: ${nextUrlList.length})');` | 以字符串 '并发解析正文，总页数: ${已过滤 下一章 URL 列表.lengt… 起始的表达式：); |
| 2981 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2982 | `        final futures = filteredNextUrlList.asMap().entries.map((entry) async {` | 声明不可重新赋值的变量 futures：调用 已过滤 下一章 URL 列表.asMap(...) → 作为(as) 映射 |
| 2983 | `          final url = entry.value;` | 声明不可重新赋值的变量 链接 |
| 2984 | `          try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 2985 | `            final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 2986 | `              url,` | 签名/调用续行参数：链接 |
| 2987 | `              headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 2988 | `              retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 2989 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 2990 | `            final pageHtml = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 页 HTML：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 2991 | `            return {'url': url, 'html': pageHtml, 'success': true};` | 返回 {'链接': 链接, '网页内容': 页 HTML, '成功': 真(true)}（映射(Map)/集合字面量） |
| 2992 | `          } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 2993 | `            return {'url': url, 'html': '', 'success': false};` | 返回 {'链接': 链接, '网页内容': '', '成功': 假(false)}（映射(Map)/集合字面量） |
| 2994 | `          }` | 闭合大括号，结束当前代码块 |
| 2995 | `        }).toList();` | 闭合代码块并衔接后续语句：).转为列表(); |
| 2996 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2997 | `        final results = await Future.wait(futures);` | 声明不可重新赋值的变量 结果：等待(await) 调用 异步结果(Future).wait(...) |
| 2998 | `&nbsp;` | 空行，分隔逻辑段落 |
| 2999 | `        for (final result in results) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 结果 属于(in) 结果 |
| 3000 | `          if (result['success'] == true &&` | 条件判断 如果(if)：结果['成功'] 等于 真(true) 且 |
| 3001 | `              (result['html'] as String).isNotEmpty) {` | (结果['网页内容'] 作为(as) 字符串(String)).是否非空) { |
| 3002 | `            final pageHtml = result['html'] as String;` | 声明不可重新赋值的变量 页 HTML |
| 3003 | `            final pageUrl = result['url'] as String;` | 声明不可重新赋值的变量 页 URL |
| 3004 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3005 | `            final pageContent = await RuleParser.parseContentRule(` | 声明不可重新赋值的变量 页 正文内容：等待(await) 调用 规则解析器(RuleParser).解析 正文内容 规则(...) → 解析 正文内容 规则 |
| 3006 | `              pageHtml,` | 签名/调用续行参数：页 HTML |
| 3007 | `              source.ruleContent,` | 签名/调用续行参数：书源.正文规则 |
| 3008 | `              baseUrl: pageUrl,` | 命名实参 基础链接: 页 URL（base 统一资源链接(URL)） |
| 3009 | `              bookName: bookName,` | 命名实参 书籍 名称: 书籍 名称（书籍 名称） |
| 3010 | `              bookOrigin: bookOrigin,` | 命名实参 书籍 来源: 书籍 来源（书籍 来源） |
| 3011 | `              applyReplaceRegex: false,` | 命名实参 applyReplaceRegex: 假(false)（apply 替换 正则） |
| 3012 | `            );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3013 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3014 | `            if (pageContent != null && pageContent.isNotEmpty) {` | 条件判断 如果(if)：页 正文内容 不等于 空值(null) 且 页 正文内容.是否非空 |
| 3015 | `              contentList.add(pageContent);` | 链式调用起始于 正文内容 列表（正文内容 列表），后续行继续该表达式：正文内容 列表.添加(页 正文内容); |
| 3016 | `            }` | 闭合大括号，结束当前代码块 |
| 3017 | `          }` | 闭合大括号，结束当前代码块 |
| 3018 | `        }` | 闭合大括号，结束当前代码块 |
| 3019 | `      }` | 闭合大括号，结束当前代码块 |
| 3020 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3021 | `      // 合并所有页面的内容` | 注释说明：合并所有页面的内容 |
| 3022 | `      if (contentList.isEmpty) {` | 条件判断 如果(if)：正文内容 列表.是否为空 |
| 3023 | `        AppLog.instance.put('章节内容获取失败: 所有页面内容都为空 (章节: ${chapter.title})');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('章节内容获取失败: 所有页面内容都为空 (章节: ${chapter.title})'); |
| 3024 | `        throw ContentEmptyException('章节内容为空: ${chapter.title}');` | 定义方法 正文内容 空 异常：返回 抛出(throw)；位置参数 1 个；含命名参数；参数名: 章节内容为空, 标题。语义：正文内容 空 异常 |
| 3025 | `      }` | 闭合大括号，结束当前代码块 |
| 3026 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3027 | `      // 参考项目：将多页内容拼接在一起` | 注释说明：参考项目：将多页内容拼接在一起 |
| 3028 | `      var content = contentList.join('\n');` | 声明自动类型推断的变量 正文内容：调用 正文内容 列表.拼接(...) → 拼接 |
| 3029 | `      final totalPages = contentList.length;` | 声明不可重新赋值的变量 totalPages |
| 3030 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 3031 | `          '章节内容获取成功: 共 $totalPages 页，合并前总长度=${content.length} (章节: ${chapter.title})');` | 以字符串 '章节内容获取成功: 共 $totalPages 页，合并前总长度=${cont… 起始的表达式：); |
| 3032 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3033 | `      // 参考项目：在所有页面内容合并后，统一应用replaceRegex规则` | 注释说明：参考项目：在所有页面内容合并后，统一应用正则替换规则 |
| 3034 | `      // 参考项目逻辑：先将内容按行分割并trim，应用替换规则，然后在每行前添加全角空格` | 注释说明：参考项目逻辑：先将内容按行分割并去除首尾空白，应用替换规则，然后在每行前添加全角空格 |
| 3035 | `      if (source.ruleContent?.replaceRegex != null &&` | 条件判断 如果(if)：书源.正文规则?.正则替换 不等于 空值(null) 且 |
| 3036 | `          source.ruleContent!.replaceRegex!.isNotEmpty) {` | 书源.正文规则!.正则替换!.是否非空) { |
| 3037 | `        // #region agent log` | 注释说明：#region 代理端 日志 |
| 3038 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 3039 | `          final f = File(` | 声明不可重新赋值的变量 f：调用 文件(file)(...) → 文件(文件(file)) |
| 3040 | `              '/Users/zhangmingxun/Desktop/legado_flutter/.cursor/debug.log');` | 以字符串 '/Users/zhangmingxun/Desktop/legado_flut… 起始的表达式：); |
| 3041 | `          f.writeAsStringSync(` | 链式调用起始于 f，后续行继续该表达式：f.writeAsStringSync( |
| 3042 | `              '${jsonEncode({` | 调用 JSON 编码(...)：'${JSON 编码({（JSON数据 编码） |
| 3043 | `                    "location": "book_service.dart:2449",` | 映射(Map) 条目 "位置": "书籍 服务.dart:2449", |
| 3044 | `                    "message": "book_service应用replaceRegex前",` | 映射(Map) 条目 "信息": "书籍 服务应用正则替换前", |
| 3045 | `                    "data": {` | 映射(Map) 条目 "data": { |
| 3046 | `                      "replaceRegex": source.ruleContent!.replaceRegex,` | 映射(Map) 条目 "正则替换": 书源.正文规则!.正则替换, |
| 3047 | `                      "contentLength": content.length,` | 映射(Map) 条目 "正文内容 长度(length)": 正文内容.长度(length), |
| 3048 | `                      "totalPages": totalPages` | 上一表达式的续行："totalPages": totalPages |
| 3049 | `                    },` | 结束上一个列表/参数项 |
| 3050 | `                    "timestamp": DateTime.now().millisecondsSinceEpoch,` | 映射(Map) 条目 "时间戳": DateTime.now().millisecondsSinceEpoch, |
| 3051 | `                    "sessionId": "debug-session",` | 映射(Map) 条目 "会话 编号(id)": "debug-会话", |
| 3052 | `                    "hypothesisId": "D"` | 上一表达式的续行："hypothesisId": "D" |
| 3053 | `                  })}\n',` | 闭合代码块并衔接后续语句：)}\n', |
| 3054 | `              mode: FileMode.append);` | 命名实参 模式: 文件(file) 模式.追加);（模式） |
| 3055 | `        } catch (_) {` | 闭合 尝试(try) 块并捕获异常（忽略异常对象） |
| 3056 | `          // 忽略调试日志写入失败，不影响正文处理流程。` | 注释说明：忽略调试日志写入失败，不影响正文处理流程。 |
| 3057 | `        }` | 闭合大括号，结束当前代码块 |
| 3058 | `        // #endregion` | 注释说明：#endregion |
| 3059 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3060 | `        AppLog.instance` | 上一表达式的续行：应用日志(AppLog).实例 |
| 3061 | `            .put('应用replaceRegex规则: ${source.ruleContent!.replaceRegex}');` | 链式调用延续：.写入数据库(put)('应用replaceRegex规则: ${source.ruleContent!.replaceRegex}'); |
| 3062 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3063 | `        // 参考项目逻辑：按行分割并trim每行` | 注释说明：参考项目逻辑：按行分割并去除首尾空白每行 |
| 3064 | `        final lines = content.split('\n');` | 声明不可重新赋值的变量 lines：调用 正文内容.切分(...) → 切分 |
| 3065 | `        content = lines.map((line) => line.trim()).join('\n');` | 将 lines.映射(map)((line) => line.去除首尾空白()).拼接('\n') 赋值给 正文内容（调用 映射(map)/去除首尾空白/拼接 → 拼接） |
| 3066 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3067 | `        // 应用replaceRegex规则` | 注释说明：应用正则替换规则 |
| 3068 | `        final beforeReplace = content;` | 声明不可重新赋值的变量 beforeReplace |
| 3069 | `        content = RuleParser.applyReplaceRegex(` | 将 规则解析器(RuleParser).applyReplaceRegex( 赋值给 正文内容（调用 applyReplaceRegex → apply 替换 正则） |
| 3070 | `            content, source.ruleContent!.replaceRegex!);` | 正文内容, 书源.正文规则!.正则替换!) |
| 3071 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3072 | `        // 参考项目逻辑：按行分割并在每行前添加全角空格（段落缩进）` | 注释说明：参考项目逻辑：按行分割并在每行前添加全角空格（段落缩进） |
| 3073 | `        final processedLines = content.split('\n');` | 声明不可重新赋值的变量 processedLines：调用 正文内容.切分(...) → 切分 |
| 3074 | `        content = processedLines.map((line) => '　　$line').join('\n');` | 将 processedLines.映射(map)((line) => ' $line').拼接('\n') 赋值给 正文内容（调用 映射(map)/拼接 → 拼接） |
| 3075 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3076 | `        // #region agent log` | 注释说明：#region 代理端 日志 |
| 3077 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 3078 | `          final f = File(` | 声明不可重新赋值的变量 f：调用 文件(file)(...) → 文件(文件(file)) |
| 3079 | `              '/Users/zhangmingxun/Desktop/legado_flutter/.cursor/debug.log');` | 以字符串 '/Users/zhangmingxun/Desktop/legado_flut… 起始的表达式：); |
| 3080 | `          f.writeAsStringSync(` | 链式调用起始于 f，后续行继续该表达式：f.writeAsStringSync( |
| 3081 | `              '${jsonEncode({` | 调用 JSON 编码(...)：'${JSON 编码({（JSON数据 编码） |
| 3082 | `                    "location": "book_service.dart:2469",` | 映射(Map) 条目 "位置": "书籍 服务.dart:2469", |
| 3083 | `                    "message": "book_service应用replaceRegex后",` | 映射(Map) 条目 "信息": "书籍 服务应用正则替换后", |
| 3084 | `                    "data": {` | 映射(Map) 条目 "data": { |
| 3085 | `                      "contentLengthBefore": beforeReplace.length,` | 映射(Map) 条目 "contentLengthBefore": beforeReplace.长度(length), |
| 3086 | `                      "contentLengthAfter": content.length` | 上一表达式的续行："contentLengthAfter": 正文内容.长度(length) |
| 3087 | `                    },` | 结束上一个列表/参数项 |
| 3088 | `                    "timestamp": DateTime.now().millisecondsSinceEpoch,` | 映射(Map) 条目 "时间戳": DateTime.now().millisecondsSinceEpoch, |
| 3089 | `                    "sessionId": "debug-session",` | 映射(Map) 条目 "会话 编号(id)": "debug-会话", |
| 3090 | `                    "hypothesisId": "D"` | 上一表达式的续行："hypothesisId": "D" |
| 3091 | `                  })}\n',` | 闭合代码块并衔接后续语句：)}\n', |
| 3092 | `              mode: FileMode.append);` | 命名实参 模式: 文件(file) 模式.追加);（模式） |
| 3093 | `        } catch (_) {` | 闭合 尝试(try) 块并捕获异常（忽略异常对象） |
| 3094 | `          // 忽略调试日志写入失败，不影响正文处理流程。` | 注释说明：忽略调试日志写入失败，不影响正文处理流程。 |
| 3095 | `        }` | 闭合大括号，结束当前代码块 |
| 3096 | `        // #endregion` | 注释说明：#endregion |
| 3097 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3098 | `        AppLog.instance.put('应用replaceRegex后，内容长度=${content.length}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('应用replaceRegex后，内容长度=${content.length}'); |
| 3099 | `      }` | 闭合大括号，结束当前代码块 |
| 3100 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3101 | `      // 输出章节内容 前500 字符` | 注释说明：输出章节内容 前500 字符 |
| 3102 | `      // 输出章节内容 后500 字符` | 注释说明：输出章节内容 后500 字符 |
| 3103 | `      // 参考项目：在返回内容前立即保存到缓存（BookHelp.saveText）` | 注释说明：参考项目：在返回内容前立即保存到缓存（BookHelp.保存 文本） |
| 3104 | `      // 这样可以避免 _loadingChapters 移除后、缓存写入前的竞态条件` | 注释说明：这样可以避免 _加载中 章节列表 移除后、缓存写入前的竞态条件 |
| 3105 | `      if (book != null && !book.isLocal) {` | 条件判断 如果(if)：书籍 不等于 空值(null) 且 !书籍.isLocal |
| 3106 | `        // ✅ 新策略: 保存到文件存储` | 注释说明：✅ 新策略: 保存到文件存储 |
| 3107 | `        final localPath = await readService(AppServices.chapterContentService)` | 声明不可重新赋值的变量 本地存储路径：等待(await) 调用 读取 服务(...) → 读取 服务 |
| 3108 | `            .saveChapterContent(book, chapter, content);` | 链式调用延续：.保存 章节 正文内容(书籍, 章节, 正文内容); |
| 3109 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3110 | `        if (localPath != null) {` | 条件判断 如果(if)：本地存储路径 不等于 空值(null) |
| 3111 | `          // 更新内存中的chapter对象` | 注释说明：更新内存中的章节对象 |
| 3112 | `          chapter.localPath = localPath;` | 将 本地存储路径 赋值给 章节.本地存储路径 |
| 3113 | `          // 异步更新数据库,不阻塞返回` | 注释说明：异步更新数据库,不阻塞返回 |
| 3114 | `          _updateChapterLocalPath(chapter.bookUrl, chapter.url, localPath)` | 调用 _更新 章节 本地 路径(...)：_更新 章节 本地 路径(章节.书籍链接, 章节.链接, 本地存储路径)（更新 章节 本地 路径） |
| 3115 | `              .catchError(` | 链式调用延续：.catchError( |
| 3116 | `                  (e) => AppLog.instance.put('更新localPath失败', error: e));` | 输出日志(写入数据库(put))：“更新本地存储路径失败” |
| 3117 | `        }` | 闭合大括号，结束当前代码块 |
| 3118 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3119 | `        // 同时保存到旧缓存(向后兼容)` | 注释说明：同时保存到旧缓存(向后兼容) |
| 3120 | `        await readService(AppServices.cacheService)` | 调用 读取 服务(...)（等待异步完成） → 读取 服务 |
| 3121 | `            .saveChapterContent(book, chapter, content);` | 链式调用延续：.保存 章节 正文内容(书籍, 章节, 正文内容); |
| 3122 | `      } else if (book == null) {` | 闭合上一代码块并开始 否则(else) 如果(if) (书籍 == 空值(null)) { |
| 3123 | `        // 未传入 book 参数，尝试从数据库查询（向后兼容）` | 注释说明：未传入 书籍 参数，尝试从数据库查询（向后兼容） |
| 3124 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 3125 | `          final dbBook = await getBookByUrl(chapter.bookUrl);` | 声明不可重新赋值的变量 数据库 书籍：等待(await) 调用 getBookByUrl(...) → 获取 书籍 By 统一资源链接(URL) |
| 3126 | `          if (dbBook != null && !dbBook.isLocal) {` | 条件判断 如果(if)：数据库 书籍 不等于 空值(null) 且 !数据库 书籍.isLocal |
| 3127 | `            await readService(AppServices.cacheService)` | 调用 读取 服务(...)（等待异步完成） → 读取 服务 |
| 3128 | `                .saveChapterContent(dbBook, chapter, content);` | 链式调用延续：.保存 章节 正文内容(数据库 书籍, 章节, 正文内容); |
| 3129 | `          }` | 闭合大括号，结束当前代码块 |
| 3130 | `        } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 3131 | `          // 缓存失败不影响返回内容` | 注释说明：缓存失败不影响返回内容 |
| 3132 | `        }` | 闭合大括号，结束当前代码块 |
| 3133 | `      }` | 闭合大括号，结束当前代码块 |
| 3134 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3135 | `      return content;` | 返回 正文内容 |
| 3136 | `    } catch (e, stackTrace) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e, stackTrace |
| 3137 | `      AppLog.instance.put('获取章节内容失败', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节内容失败', error: e); |
| 3138 | `      AppLog.instance.put('错误堆栈: $stackTrace');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('错误堆栈: $stackTrace'); |
| 3139 | `      AppLog.instance.put('章节URL: ${chapter.url}, 章节标题: ${chapter.title}');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('章节URL: ${chapter.url}, 章节标题: ${chapter.title}'); |
| 3140 | `      return null;` | 返回 空值(null)（初始为 空值(null)） |
| 3141 | `    }` | 闭合大括号，结束当前代码块 |
| 3142 | `  }` | 闭合大括号，结束当前代码块 |
| 3143 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3144 | `  /// 保存书籍到书架` | 文档注释：说明其后代码的用途 |
| 3145 | `  Future<void> saveBook(Book book) async {` | 【承接上方文档】保存书籍到书架 → 定义方法 保存 书籍：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 书籍（异步）。语义：保存 书籍 |
| 3146 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3147 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 3148 | `    await db.insert(` | 调用 数据库.插入(...)（等待异步完成） → 插入 |
| 3149 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 3150 | `      _bookToDbMap(book),` | 调用 _bookToDbMap(...)：_bookToDbMap(书籍),（书籍 To 数据库 映射） |
| 3151 | `      conflictAlgorithm: ConflictAlgorithm.replace,` | 命名实参 conflictAlgorithm: ConflictAlgorithm.replace（conflict Algorithm） |
| 3152 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3153 | `  }` | 闭合大括号，结束当前代码块 |
| 3154 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3155 | `  /// 创建书籍（保存书籍和章节）` | 文档注释：说明其后代码的用途 |
| 3156 | `  Future<Book> createBook(Book book) async {` | 【承接上方文档】创建书籍（保存书籍和章节） → 定义方法 createBook：返回 异步结果(Future)<书籍(Book)>；位置参数 1 个；含命名参数；参数名: 书籍（异步）。语义：create 书籍 |
| 3157 | `    await saveBook(book);` | 调用 保存 书籍(...)（等待异步完成） → 保存 书籍 |
| 3158 | `    return book;` | 返回 书籍 |
| 3159 | `  }` | 闭合大括号，结束当前代码块 |
| 3160 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3161 | `  /// 创建章节` | 文档注释：说明其后代码的用途 |
| 3162 | `  Future<void> createChapter(BookChapter chapter) async {` | 【承接上方文档】创建章节 → 定义方法 createChapter：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 章节（异步）。语义：create 章节 |
| 3163 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3164 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 3165 | `    await db.insert(` | 调用 数据库.插入(...)（等待异步完成） → 插入 |
| 3166 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 3167 | `      _chapterToDbMap(chapter),` | 调用 _chapterToDbMap(...)：_chapterToDbMap(章节),（章节 To 数据库 映射） |
| 3168 | `      conflictAlgorithm: ConflictAlgorithm.replace,` | 命名实参 conflictAlgorithm: ConflictAlgorithm.replace（conflict Algorithm） |
| 3169 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3170 | `  }` | 闭合大括号，结束当前代码块 |
| 3171 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3172 | `  /// 从书架删除书籍` | 文档注释：说明其后代码的用途 |
| 3173 | `  Future<void> deleteBook(String bookUrl) async {` | 【承接上方文档】从书架删除书籍 → 定义方法 删除 书籍：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 书籍链接（异步）。语义：删除 书籍 |
| 3174 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3175 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 3176 | `    await db.delete(` | 调用 数据库.delete(...)（等待异步完成） → 删除 |
| 3177 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 3178 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 3179 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 3180 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3181 | `    // 章节会通过外键级联删除` | 注释说明：章节会通过外键级联删除 |
| 3182 | `  }` | 闭合大括号，结束当前代码块 |
| 3183 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3184 | `  /// 获取书架所有书籍` | 文档注释：说明其后代码的用途 |
| 3185 | `  Future<List<Book>> getBookshelfBooks() async {` | 【承接上方文档】获取书架所有书籍 → 定义方法 getBookshelfBooks：返回 异步结果(Future)<列表(List)<书籍(Book)>>；位置参数 1 个；含命名参数（异步）。语义：获取 Bookshelf 书籍列表 |
| 3186 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3187 | `    if (db == null) return [];` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) []; |
| 3188 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 3189 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 3190 | `      orderBy: '"order" ASC, durChapterTime DESC',` | 命名实参 orderBy: '"顺序" ASC, durChapterTime DESC'（顺序 By） |
| 3191 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3192 | `    return result.map((json) => _bookFromDbMap(json)).toList();` | 返回调用 结果.映射(map)(...) 的结果（语义：映射） |
| 3193 | `  }` | 闭合大括号，结束当前代码块 |
| 3194 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3195 | `  /// 获取最后阅读的书籍` | 文档注释：说明其后代码的用途 |
| 3196 | `  /// 参考项目：appDb.bookDao.lastReadBook` | 文档注释：说明其后代码的用途 |
| 3197 | `  Future<Book?> getLastReadBook() async {` | 【承接上方文档】获取最后阅读的书籍 参考项目：appDb.bookDao.最后 读取 书籍 → 定义方法 获取 最后 读取 书籍：返回 异步结果(Future)<书籍(Book)?>；位置参数 1 个；含命名参数（异步）。语义：获取 最后 读取 书籍 |
| 3198 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3199 | `    if (db == null) return null;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 空值(null); |
| 3200 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3201 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 3202 | `      // 按最后阅读时间排序，获取最近阅读的书籍` | 注释说明：按最后阅读时间排序，获取最近阅读的书籍 |
| 3203 | `      final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 3204 | `        'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 3205 | `        orderBy: 'durChapterTime DESC',` | 命名实参 orderBy: 'durChapterTime DESC'（顺序 By） |
| 3206 | `        limit: 1,` | 命名实参 limit: 1（限制） |
| 3207 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3208 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3209 | `      if (result.isEmpty) return null;` | 条件判断 如果(if)：结果.是否为空) 返回(return) 空值(null); |
| 3210 | `      return _bookFromDbMap(result.first);` | 返回调用 _bookFromDbMap(...) 的结果（语义：书籍 From 数据库 映射） |
| 3211 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 3212 | `      AppLog.instance.put('获取最后阅读书籍失败: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取最后阅读书籍失败: $e', error: e); |
| 3213 | `      return null;` | 返回 空值(null)（初始为 空值(null)） |
| 3214 | `    }` | 闭合大括号，结束当前代码块 |
| 3215 | `  }` | 闭合大括号，结束当前代码块 |
| 3216 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3217 | `  /// 根据分组获取书籍` | 文档注释：说明其后代码的用途 |
| 3218 | `  Future<List<Book>> getBooksByGroup(int groupId) async {` | 【承接上方文档】根据分组获取书籍 → 定义方法 getBooksByGroup：返回 异步结果(Future)<列表(List)<书籍(Book)>>；位置参数 1 个；含命名参数；参数名: 捕获组 编号(id)（异步）。语义：获取 书籍列表 By 捕获组 |
| 3219 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3220 | `    if (db == null) return [];` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) []; |
| 3221 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3222 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 3223 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 3224 | `      where: '"group" = ?',` | 命名实参 筛选(where): '"捕获组" = ?'（筛选(筛选(where))） |
| 3225 | `      whereArgs: [groupId],` | 命名实参 筛选(where) 实参列表: [捕获组 编号(id)]（筛选(筛选(where)) 实参列表） |
| 3226 | `      orderBy: '"order" ASC, durChapterTime DESC',` | 命名实参 orderBy: '"顺序" ASC, durChapterTime DESC'（顺序 By） |
| 3227 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3228 | `    return result.map((json) => _bookFromDbMap(json)).toList();` | 返回调用 结果.映射(map)(...) 的结果（语义：映射） |
| 3229 | `  }` | 闭合大括号，结束当前代码块 |
| 3230 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3231 | `  /// 更新书籍分组` | 文档注释：说明其后代码的用途 |
| 3232 | `  Future<void> updateBookGroup(String bookUrl, int groupId) async {` | 【承接上方文档】更新书籍分组 → 定义方法 更新 书籍 捕获组：返回 异步结果(Future)<无返回值(void)>；位置参数 2 个；含命名参数；参数名: 书籍链接, 捕获组 编号(id)（异步）。语义：更新 书籍 捕获组 |
| 3233 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3234 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 3235 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 3236 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 3237 | `      {'group': groupId},` | {'捕获组': 捕获组 编号(id)}, |
| 3238 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 3239 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 3240 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3241 | `  }` | 闭合大括号，结束当前代码块 |
| 3242 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3243 | `  /// 更新书籍阅读进度` | 文档注释：说明其后代码的用途 |
| 3244 | `  Future<void> updateReadingProgress(` | 【承接上方文档】更新书籍阅读进度 → 定义方法 updateReadingProgress：返回 异步结果(Future)<无返回值(void)>；无参数（异步）。语义：更新 Reading 进度 |
| 3245 | `    String bookUrl,` | 字符串(String) 类型参数 书籍链接（书籍 统一资源链接(URL)） |
| 3246 | `    int chapterIndex,` | 整数(int) 类型参数 章节 索引（章节 索引） |
| 3247 | `    int chapterPos,` | 整数(int) 类型参数 章节 位置（章节 位置） |
| 3248 | `    String? chapterTitle,` | 字符串(String)? 类型参数 章节 标题（章节 标题） |
| 3249 | `  ) async {` | ) 异步(async) { |
| 3250 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3251 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 3252 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 3253 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 3254 | `      {` | 代码块开始 { |
| 3255 | `        'durChapterIndex': chapterIndex,` | 映射(Map) 条目 'durChapterIndex': 章节 索引, |
| 3256 | `        'durChapterPos': chapterPos,` | 映射(Map) 条目 'durChapterPos': 章节 位置, |
| 3257 | `        'durChapterTitle': chapterTitle,` | 映射(Map) 条目 'durChapterTitle': 章节 标题, |
| 3258 | `        'durChapterTime': DateTime.now().millisecondsSinceEpoch,` | 映射(Map) 条目 'durChapterTime': DateTime.now().millisecondsSinceEpoch, |
| 3259 | `      },` | 结束上一个列表/参数项 |
| 3260 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 3261 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 3262 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3263 | `  }` | 闭合大括号，结束当前代码块 |
| 3264 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3265 | `  /// 构建搜索URL` | 文档注释：说明其后代码的用途 |
| 3266 | `  String _buildSearchUrl(String searchUrl, String keyword) {` | 【承接上方文档】构建搜索统一资源链接(URL) → 定义方法 _构建 搜索 URL：返回 字符串(String)；位置参数 2 个；参数名: 搜索链接。语义：构建 搜索 统一资源链接(URL) |
| 3267 | `    return searchUrl.replaceAll('{{key}}', Uri.encodeComponent(keyword));` | 返回调用 搜索链接.全部替换(...) 的结果（语义：替换 全部） |
| 3268 | `  }` | 闭合大括号，结束当前代码块 |
| 3269 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3270 | `  /// 保存章节列表` | 文档注释：说明其后代码的用途 |
| 3271 | `  Future<void> saveChapters(List<BookChapter> chapters) async {` | 【承接上方文档】保存章节列表 → 定义方法 保存 章节列表：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 章节列表（异步）。语义：保存 章节列表 |
| 3272 | `    if (chapters.isEmpty) return;` | 条件判断 如果(if)：章节列表.是否为空) 返回(return); |
| 3273 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3274 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3275 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 3276 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3277 | `    // 先删除该书籍的所有章节，然后重新插入` | 注释说明：先删除该书籍的所有章节，然后重新插入 |
| 3278 | `    // 这样可以避免由于 index 不同导致的重复记录` | 注释说明：这样可以避免由于 索引 不同导致的重复记录 |
| 3279 | `    final bookUrl = chapters.first.bookUrl;` | 声明不可重新赋值的变量 书籍链接 |
| 3280 | `    await db.delete(` | 调用 数据库.delete(...)（等待异步完成） → 删除 |
| 3281 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 3282 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 3283 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 3284 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3285 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3286 | `    final batch = db.batch();` | 声明不可重新赋值的变量 batch：调用 数据库.batch(...) → 批量 |
| 3287 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3288 | `    for (final chapter in chapters) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 章节 属于(in) 章节列表 |
| 3289 | `      batch.insert(` | 链式调用起始于 batch（批量），后续行继续该表达式：batch.插入( |
| 3290 | `        'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 3291 | `        _chapterToDbMap(chapter),` | 调用 _chapterToDbMap(...)：_chapterToDbMap(章节),（章节 To 数据库 映射） |
| 3292 | `        conflictAlgorithm: ConflictAlgorithm.replace,` | 命名实参 conflictAlgorithm: ConflictAlgorithm.replace（conflict Algorithm） |
| 3293 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3294 | `    }` | 闭合大括号，结束当前代码块 |
| 3295 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3296 | `    await batch.commit(noResult: true);` | 调用 batch.提交(...)（等待异步完成） → 提交 |
| 3297 | `  }` | 闭合大括号，结束当前代码块 |
| 3298 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3299 | `  /// 获取本地章节列表` | 文档注释：说明其后代码的用途 |
| 3300 | `  Future<List<BookChapter>> _getLocalChapters(String bookUrl) async {` | 【承接上方文档】获取本地章节列表 → 定义方法 _获取 本地 章节列表：返回 异步结果(Future)<列表(List)<章节(BookChapter)>>；位置参数 1 个；含命名参数；参数名: 书籍链接（异步）。语义：获取 本地 章节列表 |
| 3301 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3302 | `    if (db == null) return [];` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) []; |
| 3303 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 3304 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 3305 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 3306 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 3307 | `      orderBy: '"index" ASC',` | 命名实参 orderBy: '"索引" ASC'（顺序 By） |
| 3308 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3309 | `    return result.map((json) => _chapterFromDbMap(json)).toList();` | 返回调用 结果.映射(map)(...) 的结果（语义：映射） |
| 3310 | `  }` | 闭合大括号，结束当前代码块 |
| 3311 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3312 | `  /// 从数据库获取指定索引的章节（参考项目：bookChapterDao.getChapter）` | 文档注释：说明其后代码的用途 |
| 3313 | `  /// 确保返回的章节的 index 字段与请求的索引一致` | 文档注释：说明其后代码的用途 |
| 3314 | `  Future<BookChapter?> getChapterByIndex(String bookUrl, int index) async {` | 【承接上方文档】从数据库获取指定索引的章节（参考项目：bookChapterDao.获取 章节） 确保返回的章节的 索引 字段与请求的索引一致 → 定义方法 getChapterByIndex：返回 异步结果(Future)<章节(BookChapter)?>；位置参数 2 个；含命名参数；参数名: 书籍链接, 索引（异步）。语义：获取 章节 By 索引 |
| 3315 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3316 | `    if (db == null) return null;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return) 空值(null); |
| 3317 | `    final result = await db.query(` | 声明不可重新赋值的变量 结果：等待(await) 调用 数据库.查询串(...) → 查询 |
| 3318 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 3319 | `      where: 'bookUrl = ? AND "index" = ?',` | 命名实参 筛选(where): '书籍链接 = ? AND "索引" = ?'（筛选(筛选(where))） |
| 3320 | `      whereArgs: [bookUrl, index],` | 命名实参 筛选(where) 实参列表: [书籍链接, 索引]（筛选(筛选(where)) 实参列表） |
| 3321 | `      limit: 1,` | 命名实参 limit: 1（限制） |
| 3322 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3323 | `    if (result.isEmpty) return null;` | 条件判断 如果(if)：结果.是否为空) 返回(return) 空值(null); |
| 3324 | `    return _chapterFromDbMap(result.first);` | 返回调用 _chapterFromDbMap(...) 的结果（语义：章节 From 数据库 映射） |
| 3325 | `  }` | 闭合大括号，结束当前代码块 |
| 3326 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3327 | `  /// Book转数据库Map` | 文档注释：说明其后代码的用途 |
| 3328 | `  Map<String, dynamic> _bookToDbMap(Book book) {` | 【承接上方文档】书籍(Book)转数据库映射(Map) → 定义方法 _bookToDbMap：返回 映射(Map)<字符串(String), dynamic>；位置参数 1 个。语义：书籍 To 数据库 映射 |
| 3329 | `    return {` | 返回 {（映射(Map)/集合字面量） |
| 3330 | `      'bookUrl': book.bookUrl,` | 映射(Map) 条目 '书籍链接': 书籍.书籍链接, |
| 3331 | `      'tocUrl': book.tocUrl,` | 映射(Map) 条目 '目录(TOC) URL': 书籍.目录(TOC) URL, |
| 3332 | `      'origin': book.origin,` | 映射(Map) 条目 '来源': 书籍.来源, |
| 3333 | `      'originName': book.originName,` | 映射(Map) 条目 '来源 名称': 书籍.来源 名称, |
| 3334 | `      'name': book.name,` | 映射(Map) 条目 '名称': 书籍.名称, |
| 3335 | `      'author': book.author,` | 映射(Map) 条目 '作者': 书籍.作者, |
| 3336 | `      'kind': book.kind,` | 映射(Map) 条目 '类别': 书籍.类别, |
| 3337 | `      'customTag': book.customTag,` | 映射(Map) 条目 'customTag': 书籍.customTag, |
| 3338 | `      'coverUrl': book.coverUrl,` | 映射(Map) 条目 '封面链接': 书籍.封面链接, |
| 3339 | `      'customCoverUrl': book.customCoverUrl,` | 映射(Map) 条目 '自定义 封面 URL': 书籍.自定义 封面 URL, |
| 3340 | `      'intro': book.intro,` | 映射(Map) 条目 '简介': 书籍.简介, |
| 3341 | `      'customIntro': book.customIntro,` | 映射(Map) 条目 '自定义 简介': 书籍.自定义 简介, |
| 3342 | `      'charset': book.charset,` | 映射(Map) 条目 '字符集': 书籍.字符集, |
| 3343 | `      'type': book.type,` | 映射(Map) 条目 '类型': 书籍.类型, |
| 3344 | `      'group': book.group,` | 映射(Map) 条目 '捕获组': 书籍.捕获组, |
| 3345 | `      'latestChapterTitle': book.latestChapterTitle,` | 映射(Map) 条目 'latestChapterTitle': 书籍.latestChapterTitle, |
| 3346 | `      'latestChapterTime': book.latestChapterTime,` | 映射(Map) 条目 'latestChapterTime': 书籍.latestChapterTime, |
| 3347 | `      'lastCheckTime': book.lastCheckTime,` | 映射(Map) 条目 'lastCheckTime': 书籍.lastCheckTime, |
| 3348 | `      'lastCheckCount': book.lastCheckCount,` | 映射(Map) 条目 '最后 检查 数量': 书籍.最后 检查 数量, |
| 3349 | `      'totalChapterNum': book.totalChapterNum,` | 映射(Map) 条目 'totalChapterNum': 书籍.totalChapterNum, |
| 3350 | `      'durChapterTitle': book.durChapterTitle,` | 映射(Map) 条目 'durChapterTitle': 书籍.durChapterTitle, |
| 3351 | `      'durChapterIndex': book.durChapterIndex,` | 映射(Map) 条目 'durChapterIndex': 书籍.durChapterIndex, |
| 3352 | `      'durChapterPos': book.durChapterPos,` | 映射(Map) 条目 'durChapterPos': 书籍.durChapterPos, |
| 3353 | `      'durChapterTime': book.durChapterTime,` | 映射(Map) 条目 'durChapterTime': 书籍.durChapterTime, |
| 3354 | `      'wordCount': book.wordCount,` | 映射(Map) 条目 '字数': 书籍.字数, |
| 3355 | `      'canUpdate': book.canUpdate ? 1 : 0,` | 映射(Map) 条目 'canUpdate': 书籍.canUpdate ? 1 : 0, |
| 3356 | `      'order': book.order,` | 映射(Map) 条目 '顺序': 书籍.顺序, |
| 3357 | `      'originOrder': book.originOrder,` | 映射(Map) 条目 '来源 顺序': 书籍.来源 顺序, |
| 3358 | `      'variable': book.variable,` | 映射(Map) 条目 'variable': 书籍.variable, |
| 3359 | `      'readConfig': book.readConfig != null` | 上一表达式的续行：'读取 配置': 书籍.读取 配置 != 空值(null) |
| 3360 | `          ? jsonEncode(book.readConfig!.toJson())` | 三元表达式为真时取值：JSON 编码(书籍.读取 配置!.toJson()) |
| 3361 | `          : null,` | 三元表达式为假时取值：空值(null), |
| 3362 | `      'syncTime': book.syncTime,` | 映射(Map) 条目 'syncTime': 书籍.syncTime, |
| 3363 | `    };` | 闭合代码块并衔接后续语句：; |
| 3364 | `  }` | 闭合大括号，结束当前代码块 |
| 3365 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3366 | `  /// 数据库Map转Book` | 文档注释：说明其后代码的用途 |
| 3367 | `  Book _bookFromDbMap(Map<String, dynamic> map) {` | 【承接上方文档】数据库映射(Map)转书籍(Book) → 定义方法 _bookFromDbMap：返回 书籍(Book)；位置参数 2 个；参数名: 字符串(String)。语义：书籍 From 数据库 映射 |
| 3368 | `    return Book(` | 返回调用 书籍(Book)(...) 的结果（语义：书籍） |
| 3369 | `      bookUrl: map['bookUrl'] ?? '',` | 命名实参 书籍链接: 映射(map)['书籍链接'] ?? ''（书籍 统一资源链接(URL)） |
| 3370 | `      tocUrl: map['tocUrl'] ?? '',` | 命名实参 目录(TOC) URL: 映射(map)['目录(TOC) URL'] ?? ''（目录(目录(TOC)) 统一资源链接(URL)） |
| 3371 | `      origin: map['origin'] ?? BookType.localTag,` | 命名实参 来源: 映射(map)['来源'] ?? 书籍 类型.localTag（来源） |
| 3372 | `      originName: map['originName'] ?? '',` | 命名实参 来源 名称: 映射(map)['来源 名称'] ?? ''（来源 名称） |
| 3373 | `      name: map['name'] ?? '',` | 命名实参 名称: 映射(map)['名称'] ?? ''（名称） |
| 3374 | `      author: map['author'] ?? '',` | 命名实参 作者: 映射(map)['作者'] ?? ''（作者） |
| 3375 | `      kind: map['kind'],` | 命名实参 类别: 映射(map)['类别']（类别） |
| 3376 | `      customTag: map['customTag'],` | 命名实参 customTag: 映射(map)['customTag']（自定义 Tag） |
| 3377 | `      coverUrl: map['coverUrl'],` | 命名实参 封面链接: 映射(map)['封面链接']（封面 统一资源链接(URL)） |
| 3378 | `      customCoverUrl: map['customCoverUrl'],` | 命名实参 自定义 封面 URL: 映射(map)['自定义 封面 URL']（自定义 封面 统一资源链接(URL)） |
| 3379 | `      intro: map['intro'],` | 命名实参 简介: 映射(map)['简介']（简介） |
| 3380 | `      customIntro: map['customIntro'],` | 命名实参 自定义 简介: 映射(map)['自定义 简介']（自定义 简介） |
| 3381 | `      charset: map['charset'],` | 命名实参 字符集: 映射(map)['字符集']（字符集） |
| 3382 | `      type: map['type'] ?? BookType.text,` | 命名实参 类型: 映射(map)['类型'] ?? 书籍 类型.文本（类型） |
| 3383 | `      group: map['group'] ?? 0,` | 命名实参 捕获组: 映射(map)['捕获组'] ?? 0（捕获组） |
| 3384 | `      latestChapterTitle: map['latestChapterTitle'],` | 命名实参 latestChapterTitle: 映射(map)['latestChapterTitle']（latest 章节 标题） |
| 3385 | `      latestChapterTime: map['latestChapterTime'] ?? 0,` | 命名实参 latestChapterTime: 映射(map)['latestChapterTime'] ?? 0（latest 章节 Time） |
| 3386 | `      lastCheckTime: map['lastCheckTime'] ?? 0,` | 命名实参 lastCheckTime: 映射(map)['lastCheckTime'] ?? 0（最后 检查 Time） |
| 3387 | `      lastCheckCount: map['lastCheckCount'] ?? 0,` | 命名实参 最后 检查 数量: 映射(map)['最后 检查 数量'] ?? 0（最后 检查 数量） |
| 3388 | `      totalChapterNum: map['totalChapterNum'] ?? 0,` | 命名实参 totalChapterNum: 映射(map)['totalChapterNum'] ?? 0（total 章节 编号） |
| 3389 | `      durChapterTitle: map['durChapterTitle'],` | 命名实参 durChapterTitle: 映射(map)['durChapterTitle']（dur 章节 标题） |
| 3390 | `      durChapterIndex: map['durChapterIndex'] ?? 0,` | 命名实参 durChapterIndex: 映射(map)['durChapterIndex'] ?? 0（dur 章节 索引） |
| 3391 | `      durChapterPos: map['durChapterPos'] ?? 0,` | 命名实参 durChapterPos: 映射(map)['durChapterPos'] ?? 0（dur 章节 位置） |
| 3392 | `      durChapterTime: map['durChapterTime'] ?? 0,` | 命名实参 durChapterTime: 映射(map)['durChapterTime'] ?? 0（dur 章节 Time） |
| 3393 | `      wordCount: map['wordCount'],` | 命名实参 字数: 映射(map)['字数']（单词 数量） |
| 3394 | `      canUpdate: map['canUpdate'] == 1,` | 命名实参 canUpdate: 映射(map)['canUpdate'] == 1（can 更新） |
| 3395 | `      order: map['order'] ?? 0,` | 命名实参 顺序: 映射(map)['顺序'] ?? 0（顺序） |
| 3396 | `      originOrder: map['originOrder'] ?? 0,` | 命名实参 来源 顺序: 映射(map)['来源 顺序'] ?? 0（来源 顺序） |
| 3397 | `      variable: map['variable'],` | 命名实参 variable: 映射(map)['variable']（变量） |
| 3398 | `      readConfig: map['readConfig'] != null` | 上一表达式的续行：读取 配置: 映射(map)['读取 配置'] != 空值(null) |
| 3399 | `          ? ReadConfig.fromJson(jsonDecode(map['readConfig']))` | 三元表达式为真时取值：读取 配置.fromJson(JSON 解码(映射(map)['读取 配置'])) |
| 3400 | `          : null,` | 三元表达式为假时取值：空值(null), |
| 3401 | `      syncTime: map['syncTime'] ?? 0,` | 命名实参 syncTime: 映射(map)['syncTime'] ?? 0（同步 Time） |
| 3402 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3403 | `  }` | 闭合大括号，结束当前代码块 |
| 3404 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3405 | `  /// BookChapter转数据库Map` | 文档注释：说明其后代码的用途 |
| 3406 | `  Map<String, dynamic> _chapterToDbMap(BookChapter chapter) {` | 【承接上方文档】章节(BookChapter)转数据库映射(Map) → 定义方法 _chapterToDbMap：返回 映射(Map)<字符串(String), dynamic>；位置参数 1 个。语义：章节 To 数据库 映射 |
| 3407 | `    return {` | 返回 {（映射(Map)/集合字面量） |
| 3408 | `      'url': chapter.url,` | 映射(Map) 条目 '链接': 章节.链接, |
| 3409 | `      'bookUrl': chapter.bookUrl,` | 映射(Map) 条目 '书籍链接': 章节.书籍链接, |
| 3410 | `      'title': chapter.title,` | 映射(Map) 条目 '标题': 章节.标题, |
| 3411 | `      'isVolume': chapter.isVolume ? 1 : 0,` | 映射(Map) 条目 'isVolume': 章节.isVolume ? 1 : 0, |
| 3412 | `      'baseUrl': chapter.baseUrl,` | 映射(Map) 条目 '基础链接': 章节.基础链接, |
| 3413 | `      'index': chapter.index,` | 映射(Map) 条目 '索引': 章节.索引, |
| 3414 | `      'isVip': chapter.isVip ? 1 : 0,` | 映射(Map) 条目 'isVip': 章节.isVip ? 1 : 0, |
| 3415 | `      'isPay': chapter.isPay ? 1 : 0,` | 映射(Map) 条目 'isPay': 章节.isPay ? 1 : 0, |
| 3416 | `      'resourceUrl': chapter.resourceUrl,` | 映射(Map) 条目 'resourceUrl': 章节.resourceUrl, |
| 3417 | `      'tag': chapter.tag,` | 映射(Map) 条目 'tag': 章节.tag, |
| 3418 | `      'wordCount': chapter.wordCount,` | 映射(Map) 条目 '字数': 章节.字数, |
| 3419 | `      'start': chapter.start,` | 映射(Map) 条目 '起始': 章节.起始, |
| 3420 | `      'end': chapter.end,` | 映射(Map) 条目 'end': 章节.end, |
| 3421 | `      'startFragmentId': chapter.startFragmentId,` | 映射(Map) 条目 'startFragmentId': 章节.startFragmentId, |
| 3422 | `      'endFragmentId': chapter.endFragmentId,` | 映射(Map) 条目 'endFragmentId': 章节.endFragmentId, |
| 3423 | `      'variable': chapter.variable,` | 映射(Map) 条目 'variable': 章节.variable, |
| 3424 | `    };` | 闭合代码块并衔接后续语句：; |
| 3425 | `  }` | 闭合大括号，结束当前代码块 |
| 3426 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3427 | `  /// 数据库Map转BookChapter` | 文档注释：说明其后代码的用途 |
| 3428 | `  BookChapter _chapterFromDbMap(Map<String, dynamic> map) {` | 【承接上方文档】数据库映射(Map)转章节(BookChapter) → 定义方法 _chapterFromDbMap：返回 章节(BookChapter)；位置参数 2 个；参数名: 字符串(String)。语义：章节 From 数据库 映射 |
| 3429 | `    return BookChapter(` | 返回调用 章节(BookChapter)(...) 的结果（语义：书籍 章节） |
| 3430 | `      url: map['url'] ?? '',` | 命名实参 链接: 映射(map)['链接'] ?? ''（统一资源链接(URL)） |
| 3431 | `      title: map['title'] ?? '',` | 命名实参 标题: 映射(map)['标题'] ?? ''（标题） |
| 3432 | `      isVolume: map['isVolume'] == 1,` | 命名实参 isVolume: 映射(map)['isVolume'] == 1（是(is) 体积） |
| 3433 | `      baseUrl: map['baseUrl'] ?? '',` | 命名实参 基础链接: 映射(map)['基础链接'] ?? ''（base 统一资源链接(URL)） |
| 3434 | `      bookUrl: map['bookUrl'] ?? '',` | 命名实参 书籍链接: 映射(map)['书籍链接'] ?? ''（书籍 统一资源链接(URL)） |
| 3435 | `      index: map['index'] ?? 0,` | 命名实参 索引: 映射(map)['索引'] ?? 0（索引） |
| 3436 | `      isVip: map['isVip'] == 1,` | 命名实参 isVip: 映射(map)['isVip'] == 1（是(is) Vip） |
| 3437 | `      isPay: map['isPay'] == 1,` | 命名实参 isPay: 映射(map)['isPay'] == 1（是(is) Pay） |
| 3438 | `      resourceUrl: map['resourceUrl'],` | 命名实参 resourceUrl: 映射(map)['resourceUrl']（resource 统一资源链接(URL)） |
| 3439 | `      tag: map['tag'],` | 命名实参 tag: 映射(map)['tag'] |
| 3440 | `      wordCount: map['wordCount'],` | 命名实参 字数: 映射(map)['字数']（单词 数量） |
| 3441 | `      start: map['start'],` | 命名实参 起始: 映射(map)['起始']（起始） |
| 3442 | `      end: map['end'],` | 命名实参 end: 映射(map)['end'] |
| 3443 | `      startFragmentId: map['startFragmentId'],` | 命名实参 startFragmentId: 映射(map)['startFragmentId']（起始 Fragment 编号(编号(id))） |
| 3444 | `      endFragmentId: map['endFragmentId'],` | 命名实参 endFragmentId: 映射(map)['endFragmentId']（end Fragment 编号(编号(id))） |
| 3445 | `      variable: map['variable'],` | 命名实参 variable: 映射(map)['variable']（变量） |
| 3446 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3447 | `  }` | 闭合大括号，结束当前代码块 |
| 3448 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3449 | `  /// 更新书籍排序` | 文档注释：说明其后代码的用途 |
| 3450 | `  Future<void> updateBookOrder(String bookUrl, int order) async {` | 【承接上方文档】更新书籍排序 → 定义方法 更新 书籍 顺序：返回 异步结果(Future)<无返回值(void)>；位置参数 2 个；含命名参数；参数名: 书籍链接, 顺序（异步）。语义：更新 书籍 顺序 |
| 3451 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3452 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 3453 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 3454 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 3455 | `      {'order': order},` | {'顺序': 顺序}, |
| 3456 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 3457 | `      whereArgs: [bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接]（筛选(筛选(where)) 实参列表） |
| 3458 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3459 | `  }` | 闭合大括号，结束当前代码块 |
| 3460 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3461 | `  /// 更新书籍信息` | 文档注释：说明其后代码的用途 |
| 3462 | `  Future<void> updateBook(Book book) async {` | 【承接上方文档】更新书籍信息 → 定义方法 更新 书籍：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 书籍（异步）。语义：更新 书籍 |
| 3463 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3464 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 3465 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 3466 | `      'books',` | 以字符串 '书籍列表' 起始的表达式：, |
| 3467 | `      _bookToDbMap(book),` | 调用 _bookToDbMap(...)：_bookToDbMap(书籍),（书籍 To 数据库 映射） |
| 3468 | `      where: 'bookUrl = ?',` | 命名实参 筛选(where): '书籍链接 = ?'（筛选(筛选(where))） |
| 3469 | `      whereArgs: [book.bookUrl],` | 命名实参 筛选(where) 实参列表: [书籍.书籍链接]（筛选(筛选(where)) 实参列表） |
| 3470 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3471 | `  }` | 闭合大括号，结束当前代码块 |
| 3472 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3473 | `  /// 更新章节字数` | 文档注释：说明其后代码的用途 |
| 3474 | `  /// 参考项目：BookService.updateChapterWordCount` | 文档注释：说明其后代码的用途 |
| 3475 | `  Future<void> updateChapterWordCount(BookChapter chapter) async {` | 【承接上方文档】更新章节字数 参考项目：书籍 服务.更新 章节 单词 数量 → 定义方法 更新 章节 单词 数量：返回 异步结果(Future)<无返回值(void)>；位置参数 1 个；含命名参数；参数名: 章节（异步）。语义：更新 章节 单词 数量 |
| 3476 | `    final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3477 | `    if (db == null) throw Exception('数据库不可用（Web平台不支持SQLite）');` | 条件判断 如果(if)：数据库 等于 空值(null)；成立则抛出异常 异常('数据库不可用（Web平台不支持SQLite）'); |
| 3478 | `    await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 3479 | `      'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 3480 | `      {'wordCount': chapter.wordCount},` | {'字数': 章节.字数}, |
| 3481 | `      where: 'url = ? AND bookUrl = ?',` | 命名实参 筛选(where): '链接 = ? AND 书籍链接 = ?'（筛选(筛选(where))） |
| 3482 | `      whereArgs: [chapter.url, chapter.bookUrl],` | 命名实参 筛选(where) 实参列表: [章节.链接, 章节.书籍链接]（筛选(筛选(where)) 实参列表） |
| 3483 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3484 | `  }` | 闭合大括号，结束当前代码块 |
| 3485 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3486 | `  /// 从数据库获取已存在的章节字数` | 文档注释：说明其后代码的用途 |
| 3487 | `  /// 参考项目：BookChapterList.getWordCount（第272-286行）` | 文档注释：说明其后代码的用途 |
| 3488 | `  Future<void> getWordCount(List<BookChapter> chapters, Book book) async {` | 【承接上方文档】从数据库获取已存在的章节字数 参考项目：书籍 章节 列表.获取 单词 数量（第272-286行） → 定义方法 获取 单词 数量：返回 异步结果(Future)<无返回值(void)>；位置参数 2 个；含命名参数；参数名: 章节列表, 书籍（异步）。语义：获取 单词 数量 |
| 3489 | `    // 参考项目：如果 AppConfig.tocCountWords 为 false，不处理` | 注释说明：参考项目：如果 AppConfig.tocCountWords 为 假(false)，不处理 |
| 3490 | `    // 这里暂时总是处理，如果需要可以从配置中读取` | 注释说明：这里暂时总是处理，如果需要可以从配置中读取 |
| 3491 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 3492 | `      final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3493 | `      if (db == null) return;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return); |
| 3494 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3495 | `      // 从数据库获取已存在的章节列表` | 注释说明：从数据库获取已存在的章节列表 |
| 3496 | `      final existingChapters = await _getLocalChapters(book.bookUrl);` | 声明不可重新赋值的变量 existingChapters：等待(await) 调用 _获取 本地 章节列表(...) → 获取 本地 章节列表 |
| 3497 | `      if (existingChapters.isEmpty) return;` | 条件判断 如果(if)：existingChapters.是否为空) 返回(return); |
| 3498 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3499 | `      // 创建章节文件名的映射（参考项目：associateBy）` | 注释说明：创建章节文件名的映射（参考项目：associateBy） |
| 3500 | `      final wordCountMap = <String, String>{};` | 声明不可重新赋值的变量 单词 数量 映射 |
| 3501 | `      for (final existingChapter in existingChapters) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) existingChapter 属于(in) existingChapters |
| 3502 | `        final fileName = _getChapterFileName(existingChapter);` | 声明不可重新赋值的变量 文件(file) 名称：调用 _获取 章节 文件(file) 名称(...) → 获取 章节 文件(文件(file)) 名称 |
| 3503 | `        if (existingChapter.wordCount != null &&` | 条件判断 如果(if)：existingChapter.字数 不等于 空值(null) 且 |
| 3504 | `            existingChapter.wordCount!.isNotEmpty) {` | existingChapter.字数!.是否非空) { |
| 3505 | `          wordCountMap[fileName] = existingChapter.wordCount!;` | 单词 数量 映射[文件(file) 名称] = existingChapter.字数! |
| 3506 | `        }` | 闭合大括号，结束当前代码块 |
| 3507 | `      }` | 闭合大括号，结束当前代码块 |
| 3508 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3509 | `      // 更新章节字数` | 注释说明：更新章节字数 |
| 3510 | `      for (final chapter in chapters) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 章节 属于(in) 章节列表 |
| 3511 | `        final fileName = _getChapterFileName(chapter);` | 声明不可重新赋值的变量 文件(file) 名称：调用 _获取 章节 文件(file) 名称(...) → 获取 章节 文件(文件(file)) 名称 |
| 3512 | `        final wordCount = wordCountMap[fileName];` | 声明不可重新赋值的变量 字数 |
| 3513 | `        if (wordCount != null) {` | 条件判断 如果(if)：字数 不等于 空值(null) |
| 3514 | `          chapter.wordCount = wordCount;` | 将 字数 赋值给 章节.字数 |
| 3515 | `        }` | 闭合大括号，结束当前代码块 |
| 3516 | `      }` | 闭合大括号，结束当前代码块 |
| 3517 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 3518 | `      AppLog.instance.put('获取章节字数失败: $e', error: e);` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('获取章节字数失败: $e', error: e); |
| 3519 | `    }` | 闭合大括号，结束当前代码块 |
| 3520 | `  }` | 闭合大括号，结束当前代码块 |
| 3521 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3522 | `  /// 获取章节文件名（用于字数匹配）` | 文档注释：说明其后代码的用途 |
| 3523 | `  /// 参考项目：BookChapter.getFileName` | 文档注释：说明其后代码的用途 |
| 3524 | `  String _getChapterFileName(BookChapter chapter) {` | 【承接上方文档】获取章节文件名（用于字数匹配） 参考项目：章节(BookChapter).获取 文件(file) 名称 → 定义方法 _获取 章节 文件(file) 名称：返回 字符串(String)；位置参数 1 个。语义：获取 章节 文件(文件(file)) 名称 |
| 3525 | `    // 参考项目：使用章节URL的MD5作为文件名` | 注释说明：参考项目：使用章节统一资源链接(URL)的MD5摘要作为文件名 |
| 3526 | `    // 这里简化处理，使用章节索引和URL的组合` | 注释说明：这里简化处理，使用章节索引和统一资源链接(URL)的组合 |
| 3527 | `    return '${chapter.index}_${chapter.url}';` | 返回 '${章节.索引}_${章节.链接}'（字符串字面量 '${章节.索引}_${章节.链接}'） |
| 3528 | `  }` | 闭合大括号，结束当前代码块 |
| 3529 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3530 | `  /// 更新章节的localPath字段` | 文档注释：说明其后代码的用途 |
| 3531 | `  ///` | 文档注释：说明其后代码的用途 |
| 3532 | `  /// 将章节内容文件路径更新到数据库` | 文档注释：说明其后代码的用途 |
| 3533 | `  Future<void> _updateChapterLocalPath(` | 【承接上方文档】更新章节的本地存储路径字段  将章节内容文件路径更新到数据库 → 定义方法 _更新 章节 本地 路径：返回 异步结果(Future)<无返回值(void)>；无参数（异步）。语义：更新 章节 本地 路径 |
| 3534 | `    String bookUrl,` | 字符串(String) 类型参数 书籍链接（书籍 统一资源链接(URL)） |
| 3535 | `    String chapterUrl,` | 字符串(String) 类型参数 章节链接（章节 统一资源链接(URL)） |
| 3536 | `    String localPath,` | 字符串(String) 类型参数 本地存储路径（本地 路径） |
| 3537 | `  ) async {` | ) 异步(async) { |
| 3538 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 3539 | `      final db = await _db.database;` | 声明不可重新赋值的变量 数据库：等待(await) 等待异步调用结果 |
| 3540 | `      if (db == null) return;` | 条件判断 如果(if)：数据库 等于 空值(null)) 返回(return); |
| 3541 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3542 | `      await db.update(` | 调用 数据库.update(...)（等待异步完成） → 更新 |
| 3543 | `        'chapters',` | 以字符串 '章节列表' 起始的表达式：, |
| 3544 | `        {'localPath': localPath},` | {'本地存储路径': 本地存储路径}, |
| 3545 | `        where: 'bookUrl = ? AND url = ?',` | 命名实参 筛选(where): '书籍链接 = ? AND 链接 = ?'（筛选(筛选(where))） |
| 3546 | `        whereArgs: [bookUrl, chapterUrl],` | 命名实参 筛选(where) 实参列表: [书籍链接, 章节链接]（筛选(筛选(where)) 实参列表） |
| 3547 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3548 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 3549 | `      AppLog.instance.put(` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)( |
| 3550 | `        '更新章节localPath失败: bookUrl=$bookUrl, url=$chapterUrl',` | 以字符串 '更新章节本地存储路径失败: 书籍链接=$书籍链接, 链接=… 起始的表达式：, |
| 3551 | `        error: e,` | 命名实参 错误: 异常对象 e（错误） |
| 3552 | `      );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 3553 | `    }` | 闭合大括号，结束当前代码块 |
| 3554 | `  }` | 闭合大括号，结束当前代码块 |
| 3555 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3556 | `  // ── Phase 3：辅助工具方法 ────────────────────────────────────────────────` | 注释说明：── 相位 3：辅助工具方法 ──────────────────────────────────────────────── |
| 3557 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3558 | `  /// 将时长字符串解析为秒数（int）` | 文档注释：说明其后代码的用途 |
| 3559 | `  ///` | 文档注释：说明其后代码的用途 |
| 3560 | `  /// 支持三种格式：` | 文档注释：说明其后代码的用途 |
| 3561 | `  ///   - 纯秒数字符串：`"1800"` → 1800` | 文档注释：说明其后代码的用途 |
| 3562 | `  ///   - MM:SS 格式：`"30:00"` → 1800` | 文档注释：说明其后代码的用途 |
| 3563 | `  ///   - HH:MM:SS 格式：`"00:30:00"` → 1800` | 文档注释：说明其后代码的用途 |
| 3564 | `  ///` | 文档注释：说明其后代码的用途 |
| 3565 | `  /// 解析失败或输入为空时返回 null。` | 文档注释：说明其后代码的用途 |
| 3566 | `  static int? _parseDurationString(String? raw) {` | 【承接上方文档】将时长字符串解析为秒数（整数(int)）  支持三种格式： - 纯秒数字符串：`"1800"` → 1800 - MM:SS 格式：`"30:00"` → 1800 - → 定义静态方法 _解析 时长 字符串(String)：返回 整数(int)?；位置参数 1 个。语义：解析 时长 字符串(字符串(String)) |
| 3567 | `    if (raw == null \|\| raw.trim().isEmpty) return null;` | 条件判断 如果(if)：原始 等于 空值(null) 或 原始.去除首尾空白().是否为空) 返回(return) 空值(null); |
| 3568 | `    final trimmed = raw.trim();` | 声明不可重新赋值的变量 trimmed：调用 原始.去除首尾空白(...) → 修剪 |
| 3569 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3570 | `    // 尝试 HH:MM:SS 或 MM:SS 格式` | 注释说明：尝试 HH:MM:SS 或 MM:SS 格式 |
| 3571 | `    final parts = trimmed.split(':');` | 声明不可重新赋值的变量 parts：调用 trimmed.切分(...) → 切分 |
| 3572 | `    if (parts.length == 2) {` | 条件判断 如果(if)：parts.长度(length) 等于 2 |
| 3573 | `      // MM:SS` | 注释说明：MM:SS |
| 3574 | `      final minutes = int.tryParse(parts[0]);` | 声明不可重新赋值的变量 minutes：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 3575 | `      final seconds = int.tryParse(parts[1]);` | 声明不可重新赋值的变量 seconds：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 3576 | `      if (minutes != null && seconds != null) {` | 条件判断 如果(if)：minutes 不等于 空值(null) 且 seconds 不等于 空值(null) |
| 3577 | `        return minutes * 60 + seconds;` | 返回 minutes * 60 + seconds |
| 3578 | `      }` | 闭合大括号，结束当前代码块 |
| 3579 | `    } else if (parts.length == 3) {` | 闭合上一代码块并开始 否则(else) 如果(if) (parts.长度(length) == 3) { |
| 3580 | `      // HH:MM:SS` | 注释说明：HH:MM:SS |
| 3581 | `      final hours = int.tryParse(parts[0]);` | 声明不可重新赋值的变量 hours：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 3582 | `      final minutes = int.tryParse(parts[1]);` | 声明不可重新赋值的变量 minutes：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 3583 | `      final seconds = int.tryParse(parts[2]);` | 声明不可重新赋值的变量 seconds：调用 整数(int).tryParse(...) → 尝试(try) 解析 |
| 3584 | `      if (hours != null && minutes != null && seconds != null) {` | 条件判断 如果(if)：hours 不等于 空值(null) 且 minutes 不等于 空值(null) 且 seconds 不等于 空值(null) |
| 3585 | `        return hours * 3600 + minutes * 60 + seconds;` | 返回 hours * 3600 + minutes * 60 + seconds |
| 3586 | `      }` | 闭合大括号，结束当前代码块 |
| 3587 | `    }` | 闭合大括号，结束当前代码块 |
| 3588 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3589 | `    // 尝试纯数字（秒数）` | 注释说明：尝试纯数字（秒数） |
| 3590 | `    return int.tryParse(trimmed);` | 返回调用 整数(int).tryParse(...) 的结果（语义：尝试(try) 解析） |
| 3591 | `  }` | 闭合大括号，结束当前代码块 |
| 3592 | `}` | 闭合大括号，结束当前代码块 |
