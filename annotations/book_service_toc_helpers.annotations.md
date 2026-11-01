# book_service_toc_helpers.dart 逐行注释

> 源文件：`lib/services/book/book_service_toc_helpers.dart`（共 304 行）
>
> 本文件由 `scripts/gen_line_annotations.py` 自动生成，对源文件每一行给出独立说明。
> 说明优先采用源码自带的中文注释；无注释的行依据 Dart 语法特征自动生成解释。

| 行号 | 源代码 | 说明 |
| ---: | --- | --- |
| 1 | `part of 'book_service.dart';` | 声明本文件是 书籍 服务.dart 库的一部分(分部文件(part))，与其共享同一命名空间 |
| 2 | `&nbsp;` | 空行，分隔逻辑段落 |
| 3 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 4 | `// BookService 职责：目录(TOC)抓取辅助逻辑 —— URL 规范化比较、隐式分页候选构造、Ajax 目录回退解析。` | 注释说明：书籍 服务 职责：目录(目录(TOC))抓取辅助逻辑 —— 统一资源链接(URL) 规范化比较、隐式分页候选构造、Ajax 目录回退解析。 |
| 5 | `// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）` | 注释说明：（分部文件(part) 文件，与主文件 书籍 服务.dart 共享同一 Dart 库，可访问私有符号） |
| 6 | `// =============================================================================` | 分隔线注释，标记章节区块 |
| 7 | `&nbsp;` | 空行，分隔逻辑段落 |
| 8 | `  /// 比较两个 URL 是否相等（规范化后比较）` | 文档注释：说明其后代码的用途 |
| 9 | `  /// 参考项目：NetworkUtils.getAbsoluteURL 的比较逻辑` | 文档注释：说明其后代码的用途 |
| 10 | `  /// 处理 URL 末尾的旜杠、大小写等差异` | 文档注释：说明其后代码的用途 |
| 11 | `  bool _urlEquals(String url1, String url2) {` | 【承接上方文档】比较两个 统一资源链接(URL) 是否相等（规范化后比较） 参考项目：NetworkUtils.getAbsoluteURL 的比较逻辑 处理 统一资源链接(URL) 末尾的旜杠、大小写等差异 → 定义方法 _urlEquals：返回 布尔(bool)；位置参数 2 个；参数名: url1。语义：统一资源链接(URL) Equals |
| 12 | `    if (url1 == url2) return true;` | 条件判断 如果(if)：url1 等于 url2) 返回(return) 真(true); |
| 13 | `    if (url1.isEmpty \|\| url2.isEmpty) return false;` | 条件判断 如果(if)：url1.是否为空 或 url2.是否为空) 返回(return) 假(false); |
| 14 | `&nbsp;` | 空行，分隔逻辑段落 |
| 15 | `    // 规范化 URL：移除末尾的 /` | 注释说明：规范化 统一资源链接(URL)：移除末尾的 / |
| 16 | `    String normalize(String url) {` | 定义方法 normalize：返回 字符串(String)；位置参数 1 个。语义：规范化 |
| 17 | `      var normalized = url.trim();` | 声明自动类型推断的变量 normalized：调用 链接.去除首尾空白(...) → 修剪 |
| 18 | `      while (normalized.endsWith('/')) {` | 当型循环(while) 循环，条件：normalized.endsWith('/') |
| 19 | `        normalized = normalized.substring(0, normalized.length - 1);` | 将 normalized.substring(0, normalized.长度(length) - 1) 赋值给 normalized |
| 20 | `      }` | 闭合大括号，结束当前代码块 |
| 21 | `      return normalized;` | 返回 normalized |
| 22 | `    }` | 闭合大括号，结束当前代码块 |
| 23 | `&nbsp;` | 空行，分隔逻辑段落 |
| 24 | `    final normalized1 = normalize(url1);` | 声明不可重新赋值的变量 normalized1：调用 normalize(...) → 规范化 |
| 25 | `    final normalized2 = normalize(url2);` | 声明不可重新赋值的变量 normalized2：调用 normalize(...) → 规范化 |
| 26 | `&nbsp;` | 空行，分隔逻辑段落 |
| 27 | `    // 直接比较` | 注释说明：直接比较 |
| 28 | `    if (normalized1 == normalized2) return true;` | 条件判断 如果(if)：normalized1 等于 normalized2) 返回(return) 真(true); |
| 29 | `&nbsp;` | 空行，分隔逻辑段落 |
| 30 | `    // 尝试解析 URI 后比较` | 注释说明：尝试解析 URI 后比较 |
| 31 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 32 | `      final uri1 = Uri.parse(normalized1);` | 声明不可重新赋值的变量 uri1：调用 统一资源标识(URI).parse(...) → 解析 |
| 33 | `      final uri2 = Uri.parse(normalized2);` | 声明不可重新赋值的变量 uri2：调用 统一资源标识(URI).parse(...) → 解析 |
| 34 | `&nbsp;` | 空行，分隔逻辑段落 |
| 35 | `      // 比较 scheme、host、port 和 path` | 注释说明：比较 scheme、主机、端口 和 路径 |
| 36 | `      return uri1.scheme == uri2.scheme &&` | 上一表达式的续行：返回(return) uri1.scheme == uri2.scheme && |
| 37 | `          uri1.host == uri2.host &&` | 续行赋值：将 = uri2.主机 && 赋给 uri1.主机 |
| 38 | `          uri1.port == uri2.port &&` | 续行赋值：将 = uri2.端口 && 赋给 uri1.端口 |
| 39 | `          uri1.path == uri2.path;` | 续行赋值：将 = uri2.路径; 赋给 uri1.路径 |
| 40 | `    } catch (e) {` | 闭合 尝试(try) 块并捕获异常，异常变量：异常对象 e |
| 41 | `      return false;` | 返回 假(false)（布尔值 假(false)） |
| 42 | `    }` | 闭合大括号，结束当前代码块 |
| 43 | `  }` | 闭合大括号，结束当前代码块 |
| 44 | `&nbsp;` | 空行，分隔逻辑段落 |
| 45 | `  String _chapterIdentity(Map<String, String?> chapterData) {` | 定义方法 _chapterIdentity：返回 字符串(String)；位置参数 2 个；参数名: 字符串(String)。语义：章节 Identity |
| 46 | `    final chapterUrl = chapterData['chapterUrl']?.trim() ?? '';` | 声明不可重新赋值的变量 章节链接 |
| 47 | `    if (chapterUrl.isNotEmpty) return chapterUrl;` | 条件判断 如果(if)：章节链接.是否非空) 返回(return) 章节链接; |
| 48 | `    return chapterData['chapterName']?.trim() ?? '';` | 返回 chapterData['章节 名称']?.去除首尾空白() ?? '' |
| 49 | `  }` | 闭合大括号，结束当前代码块 |
| 50 | `&nbsp;` | 空行，分隔逻辑段落 |
| 51 | `  List<String> _buildImplicitTocPageCandidates(String tocUrl, int pageNumber) {` | 定义方法 _buildImplicitTocPageCandidates：返回 列表(List)<字符串(String)>；位置参数 2 个；参数名: 目录(TOC) URL。语义：构建 Implicit 目录(目录(TOC)) 页 Candidates |
| 52 | `    if (pageNumber < 2 \|\| tocUrl.isEmpty) return const [];` | 条件判断 如果(if)：pageNumber < 2 或 目录(TOC) URL.是否为空) 返回(return) 编译期常量(const) []; |
| 53 | `&nbsp;` | 空行，分隔逻辑段落 |
| 54 | `    final normalizedUrl = tocUrl.trim();` | 声明不可重新赋值的变量 normalizedUrl：调用 目录(TOC) URL.去除首尾空白(...) → 修剪 |
| 55 | `    final candidates = <String>[];` | 声明不可重新赋值的变量 candidates |
| 56 | `&nbsp;` | 空行，分隔逻辑段落 |
| 57 | `    void addCandidate(String value) {` | 定义方法 addCandidate：返回 无返回值(void)；位置参数 1 个。语义：添加 Candidate |
| 58 | `      if (value.isNotEmpty && !candidates.contains(value)) {` | 条件判断 如果(if)：值.是否非空 且 !candidates.是否包含(值) |
| 59 | `        candidates.add(value);` | 链式调用起始于 candidates，后续行继续该表达式：candidates.添加(值); |
| 60 | `      }` | 闭合大括号，结束当前代码块 |
| 61 | `    }` | 闭合大括号，结束当前代码块 |
| 62 | `&nbsp;` | 空行，分隔逻辑段落 |
| 63 | `    if (normalizedUrl.endsWith('/')) {` | 条件判断 如果(if)：normalizedUrl.endsWith('/') |
| 64 | `      addCandidate(` | 调用 addCandidate(...)：addCandidate(（添加 Candidate） |
| 65 | `          NetworkService.joinUrl(normalizedUrl, 'index_$pageNumber.html'));` | 链式调用起始于 网络服务(NetworkService)（Network 服务），后续行继续该表达式：网络服务(NetworkService).拼接 URL(normalizedUrl, 'index_$pageNumber.网页内容')); |
| 66 | `      addCandidate(NetworkService.joinUrl(normalizedUrl, '$pageNumber.html'));` | 调用 addCandidate/拼接 URL(...)：addCandidate(网络服务(NetworkService).拼接 URL(normalizedUrl, '$pageNumber.网页内容'))（添加 Candidate 拼接 统一资源链接(URL)） |
| 67 | `      return candidates;` | 返回 candidates |
| 68 | `    }` | 闭合大括号，结束当前代码块 |
| 69 | `&nbsp;` | 空行，分隔逻辑段落 |
| 70 | `    try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 71 | `      final uri = Uri.parse(normalizedUrl);` | 声明不可重新赋值的变量 uri：调用 统一资源标识(URI).parse(...) → 解析 |
| 72 | `      if (uri.path.endsWith('.html')) {` | 条件判断 如果(if)：uri.路径.endsWith('.网页内容') |
| 73 | `        final slashIndex = uri.path.lastIndexOf('/');` | 声明不可重新赋值的变量 斜杠 索引：调用 uri.路径.lastIndexOf(...) → 最后 索引 Of |
| 74 | `        final directoryPath =` | 上一表达式的续行：不可重新赋值(final) 目录(directory) 路径 = |
| 75 | `            slashIndex >= 0 ? uri.path.substring(0, slashIndex + 1) : '/';` | 调用 substring(...)：斜杠 索引 >= 0 ? uri.路径.substring(0, 斜杠 索引 + 1) : '/' |
| 76 | `        final pageUri =` | 上一表达式的续行：不可重新赋值(final) 页 统一资源标识(URI) = |
| 77 | `            uri.replace(path: '${directoryPath}index_$pageNumber.html');` | 链式调用起始于 uri，后续行继续该表达式：uri.replace(路径: '${目录(directory) 路径}index_$pageNumber.网页内容'); |
| 78 | `        addCandidate(pageUri.toString());` | 调用 addCandidate/转为字符串(...)：addCandidate(页 统一资源标识(URI).转为字符串())（添加 Candidate to 字符串(字符串(String))） |
| 79 | `      }` | 闭合大括号，结束当前代码块 |
| 80 | `    } catch (_) {` | 闭合 尝试(try) 块并捕获异常（忽略异常对象） |
| 81 | `      // ignore invalid tocUrl and fall back to the original URL shape below.` | 注释说明：ignore 无效 目录(TOC) URL and fall back to the original 统一资源链接(URL) 形状 below. |
| 82 | `    }` | 闭合大括号，结束当前代码块 |
| 83 | `&nbsp;` | 空行，分隔逻辑段落 |
| 84 | `    addCandidate('$normalizedUrl/index_$pageNumber.html');` | 调用 addCandidate(...)：addCandidate('$normalizedUrl/index_$pageNumber.网页内容')（添加 Candidate） |
| 85 | `    return candidates;` | 返回 candidates |
| 86 | `  }` | 闭合大括号，结束当前代码块 |
| 87 | `&nbsp;` | 空行，分隔逻辑段落 |
| 88 | `  Future<List<Map<String, String?>>> _loadImplicitTocPages({` | 定义方法 _loadImplicitTocPages：返回 异步结果(Future)<列表(List)<映射(Map)<字符串(String), 字符串(String)?>>>；含命名参数（异步）。语义：加载 Implicit 目录(目录(TOC)) 分页 |
| 89 | `    required String tocUrl,` | 必填字符串(String) 类型参数 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 90 | `    required BookSource source,` | 必填书源(BookSource) 类型参数 书源（书源） |
| 91 | `    required TocRule tocRule,` | 必填目录(TOC) 规则 类型参数 目录(TOC) 规则（目录(目录(TOC)) 规则） |
| 92 | `    required Iterable<Map<String, String?>> seedChapters,` | 必填Iterable<映射(Map)<字符串(String), 字符串(String)?>> 类型参数 seedChapters（seed 章节列表） |
| 93 | `    Map<String, String>? variables,` | 映射(Map)<字符串(String), 字符串(String)>? 类型参数 variables（变量表） |
| 94 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 95 | `    if (tocUrl.isEmpty \|\| tocRule.nextTocUrl?.isNotEmpty == true) {` | 条件判断 如果(if)：目录(TOC) URL.是否为空 或 目录(TOC) 规则.下一页目录链接?.是否非空 等于 真(true) |
| 96 | `      return const [];` | 返回 编译期常量(const) [] |
| 97 | `    }` | 闭合大括号，结束当前代码块 |
| 98 | `&nbsp;` | 空行，分隔逻辑段落 |
| 99 | `    final existingIdentities =` | 上一表达式的续行：不可重新赋值(final) existingIdentities = |
| 100 | `        seedChapters.map(_chapterIdentity).where((id) => id.isNotEmpty).toSet();` | 链式调用起始于 seedChapters（seed 章节列表），后续行继续该表达式：seedChapters.映射(map)(_chapterIdentity).筛选(where)((编号(id)) => 编号(id).是否非空).转为集合(… |
| 101 | `    final collected = <Map<String, String?>>[];` | 声明不可重新赋值的变量 collected |
| 102 | `    const maxImplicitPages = 50;` | 声明编译期常量变量 maxImplicitPages |
| 103 | `&nbsp;` | 空行，分隔逻辑段落 |
| 104 | `    for (int pageNumber = 2; pageNumber <= maxImplicitPages; pageNumber++) {` | 循环(for)-属于(in) 遍历：整数(int) pageNumber = 2; pageNumber <= maxImplicitPages; pageNumber++ |
| 105 | `      final candidates = _buildImplicitTocPageCandidates(tocUrl, pageNumber);` | 声明不可重新赋值的变量 candidates：调用 _buildImplicitTocPageCandidates(...) → 构建 Implicit 目录(目录(TOC)) 页 Candidates |
| 106 | `      if (candidates.isEmpty) break;` | 条件判断 如果(if)：candidates.是否为空) 跳出(break); |
| 107 | `&nbsp;` | 空行，分隔逻辑段落 |
| 108 | `      List<Map<String, String?>>? matchedPage;` | 列表(List)<映射(Map)<字符串(String), 字符串(String)?>>? matchedPage |
| 109 | `&nbsp;` | 空行，分隔逻辑段落 |
| 110 | `      for (final candidateUrl in candidates) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) candidateUrl 属于(in) candidates |
| 111 | `        try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 112 | `          final response = await _networkService.get(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.读取(getter)(...) → 获取 |
| 113 | `            candidateUrl,` | 签名/调用续行参数：candidateUrl |
| 114 | `            headers: NetworkService.parseHeaders(source.header),` | 命名实参 请求头: 网络服务(NetworkService).解析 请求头(书源.请求头)（请求头） |
| 115 | `            retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 116 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 117 | `          if (response.statusCode != 200) {` | 条件判断 如果(if)：响应.状态 代码 不等于 200 |
| 118 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 119 | `          }` | 闭合大括号，结束当前代码块 |
| 120 | `&nbsp;` | 空行，分隔逻辑段落 |
| 121 | `          final pageHtml = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 页 HTML：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 122 | `          if (pageHtml.isEmpty) {` | 条件判断 如果(if)：页 HTML.是否为空 |
| 123 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 124 | `          }` | 闭合大括号，结束当前代码块 |
| 125 | `&nbsp;` | 空行，分隔逻辑段落 |
| 126 | `          final pageResult = await RuleParser.parseTocRuleWithNextUrl(` | 声明不可重新赋值的变量 页 结果：等待(await) 调用 规则解析器(RuleParser).parseTocRuleWithNextUrl(...) → 解析 目录(目录(TOC)) 规则 With 下一章 统一资源链接(URL) |
| 127 | `            pageHtml,` | 签名/调用续行参数：页 HTML |
| 128 | `            tocRule,` | 签名/调用续行参数：目录(TOC) 规则 |
| 129 | `            variables: variables,` | 命名实参 variables: variables（变量表） |
| 130 | `            baseUrl: candidateUrl,` | 命名实参 基础链接: candidateUrl（base 统一资源链接(URL)） |
| 131 | `            getNextUrl: false,` | 命名实参 获取 下一章 URL: 假(false)（获取 下一章 统一资源链接(URL)） |
| 132 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 133 | `          final pageChapters =` | 上一表达式的续行：不可重新赋值(final) 页 章节列表 = |
| 134 | `              pageResult['chapterList'] as List<Map<String, String?>>;` | 页 结果['章节 列表'] 作为(as) 列表(List)<映射(Map)<字符串(String), 字符串(String)?>> |
| 135 | `          if (pageChapters.isEmpty) {` | 条件判断 如果(if)：页 章节列表.是否为空 |
| 136 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 137 | `          }` | 闭合大括号，结束当前代码块 |
| 138 | `&nbsp;` | 空行，分隔逻辑段落 |
| 139 | `          final newChapters = pageChapters.where((chapter) {` | 声明不可重新赋值的变量 newChapters：调用 页 章节列表.筛选(where)(...) → 筛选(筛选(where)) |
| 140 | `            final identity = _chapterIdentity(chapter);` | 声明不可重新赋值的变量 identity：调用 _chapterIdentity(...) → 章节 Identity |
| 141 | `            return identity.isNotEmpty &&` | 上一表达式的续行：返回(return) identity.是否非空 && |
| 142 | `                !existingIdentities.contains(identity);` | 调用 是否包含(...)：!existingIdentities.是否包含(identity)（是否包含） |
| 143 | `          }).toList();` | 闭合代码块并衔接后续语句：).转为列表(); |
| 144 | `&nbsp;` | 空行，分隔逻辑段落 |
| 145 | `          if (newChapters.isEmpty) {` | 条件判断 如果(if)：newChapters.是否为空 |
| 146 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 147 | `          }` | 闭合大括号，结束当前代码块 |
| 148 | `&nbsp;` | 空行，分隔逻辑段落 |
| 149 | `          matchedPage = newChapters;` | 将 newChapters 赋值给 matchedPage |
| 150 | `          existingIdentities.addAll(` | 链式调用起始于 existingIdentities，后续行继续该表达式：existingIdentities.批量添加( |
| 151 | `            newChapters.map(_chapterIdentity).where((id) => id.isNotEmpty),` | 链式调用起始于 newChapters（新建(new) 章节列表），后续行继续该表达式：newChapters.映射(map)(_chapterIdentity).筛选(where)((编号(id)) => 编号(id).是否非空), |
| 152 | `          );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 153 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 154 | `        } catch (_) {` | 闭合 尝试(try) 块并捕获异常（忽略异常对象） |
| 155 | `          continue;` | 继续(continue)：进入下一次循环迭代 |
| 156 | `        }` | 闭合大括号，结束当前代码块 |
| 157 | `      }` | 闭合大括号，结束当前代码块 |
| 158 | `&nbsp;` | 空行，分隔逻辑段落 |
| 159 | `      if (matchedPage == null \|\| matchedPage.isEmpty) {` | 条件判断 如果(if)：matchedPage 等于 空值(null) 或 matchedPage.是否为空 |
| 160 | `        break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 161 | `      }` | 闭合大括号，结束当前代码块 |
| 162 | `&nbsp;` | 空行，分隔逻辑段落 |
| 163 | `      collected.addAll(matchedPage);` | 链式调用起始于 collected，后续行继续该表达式：collected.批量添加(matchedPage); |
| 164 | `    }` | 闭合大括号，结束当前代码块 |
| 165 | `&nbsp;` | 空行，分隔逻辑段落 |
| 166 | `    if (collected.isNotEmpty) {` | 条件判断 如果(if)：collected.是否非空 |
| 167 | `      AppLog.instance.put('目录隐式分页补全成功: 新增 ${collected.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('目录隐式分页补全成功: 新增 ${collected.length} 个章节'); |
| 168 | `    }` | 闭合大括号，结束当前代码块 |
| 169 | `&nbsp;` | 空行，分隔逻辑段落 |
| 170 | `    return collected;` | 返回 collected |
| 171 | `  }` | 闭合大括号，结束当前代码块 |
| 172 | `&nbsp;` | 空行，分隔逻辑段落 |
| 173 | `  String? _extractAjaxTocBookId(String html) {` | 定义方法 _extractAjaxTocBookId：返回 字符串(String)?；位置参数 1 个。语义：提取 Ajax 目录(目录(TOC)) 书籍 编号(编号(id)) |
| 174 | `    final match = RegExp(` | 声明不可重新赋值的变量 match：调用 正则表达式(RegExp)(...) → Reg 表达式 |
| 175 | `      'id\\s*=\\s*["\\\']bookiddata["\\\'][^>]*data-sid\\s*=\\s*["\\\'](\\d+)["\\\']',` | 以字符串 '编号(id)\\s*=\\s*["\\\']bookiddata["\\\'][^>]… 起始的表达式：, |
| 176 | `      caseSensitive: false,` | 区分大小写开关: 假(false), |
| 177 | `    ).firstMatch(html);` | 调用 首个匹配(...)：).首个匹配(网页内容)（首个 Match） |
| 178 | `    return match?.group(1);` | 返回 match?.捕获组(1) |
| 179 | `  }` | 闭合大括号，结束当前代码块 |
| 180 | `&nbsp;` | 空行，分隔逻辑段落 |
| 181 | `  bool _supportsAjaxTocFallback(String tocUrl, String html) {` | 定义方法 _supportsAjaxTocFallback：返回 布尔(bool)；位置参数 2 个；参数名: 目录(TOC) URL。语义：supports Ajax 目录(目录(TOC)) 回退/降级 |
| 182 | `    return tocUrl.contains('guishuji.com') &&` | 返回调用 目录(TOC) URL.是否包含(...) 的结果（语义：是否包含） |
| 183 | `        _extractAjaxTocBookId(html)?.isNotEmpty == true;` | 调用 _extractAjaxTocBookId(...)：_extractAjaxTocBookId(网页内容)?.是否非空 == 真(true)（提取 Ajax 目录(目录(TOC)) 书籍 编号(编号(id))） |
| 184 | `  }` | 闭合大括号，结束当前代码块 |
| 185 | `&nbsp;` | 空行，分隔逻辑段落 |
| 186 | `  Map<String, String> _buildRuleVariables(Book book) {` | 定义方法 _构建 规则 变量表：返回 映射(Map)<字符串(String), 字符串(String)>；位置参数 1 个。语义：构建 规则 变量表 |
| 187 | `    final variables = <String, String>{};` | 声明不可重新赋值的变量 variables |
| 188 | `    book.variableMap.forEach((key, value) {` | 链式调用起始于 书籍.变量 映射（变量 映射），后续行继续该表达式：书籍.变量 映射.forEach((键, 值) { |
| 189 | `      variables[key] = value?.toString() ?? '';` | 调用 转为字符串(...)：variables[键] = 值?.转为字符串() ?? ''（to 字符串(字符串(String))） |
| 190 | `    });` | 闭合代码块并衔接后续语句：); |
| 191 | `    return variables;` | 返回 variables |
| 192 | `  }` | 闭合大括号，结束当前代码块 |
| 193 | `&nbsp;` | 空行，分隔逻辑段落 |
| 194 | `  String _repairChapterUrlWithBookVariables(String url, Book? book) {` | 定义方法 _repairChapterUrlWithBookVariables：返回 字符串(String)；位置参数 2 个；参数名: 链接。语义：修复 章节 统一资源链接(URL) With 书籍 变量表 |
| 195 | `    if (url.isEmpty \|\| book == null) return url;` | 条件判断 如果(if)：链接.是否为空 或 书籍 等于 空值(null)) 返回(return) 链接; |
| 196 | `&nbsp;` | 空行，分隔逻辑段落 |
| 197 | `    final bid = '${book.variableMap['bid'] ?? ''}'.trim();` | 声明不可重新赋值的变量 bid：字符串字面量 '${书籍.变量 映射['bid'] ?? ''}'.去除首尾空白(… |
| 198 | `    if (bid.isEmpty) return url;` | 条件判断 如果(if)：bid.是否为空) 返回(return) 链接; |
| 199 | `&nbsp;` | 空行，分隔逻辑段落 |
| 200 | `    return url.replaceAllMapped(` | 返回调用 链接.replaceAllMapped(...) 的结果（语义：替换 全部 Mapped） |
| 201 | `      RegExp(r'([?&]comic_id=)(?:null)?(?=&\|$)'),` | 构造函数 正则表达式(RegExp)位置参数 1 个；参数名: comic_id, 空值(null) |
| 202 | `      (match) => '${match.group(1)}$bid',` | 调用 捕获组(...)：(match) => '${match.捕获组(1)}$bid',（捕获组） |
| 203 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 204 | `  }` | 闭合大括号，结束当前代码块 |
| 205 | `&nbsp;` | 空行，分隔逻辑段落 |
| 206 | `  Future<List<Map<String, String?>>> _loadAjaxTocPages({` | 定义方法 _loadAjaxTocPages：返回 异步结果(Future)<列表(List)<映射(Map)<字符串(String), 字符串(String)?>>>；含命名参数（异步）。语义：加载 Ajax 目录(目录(TOC)) 分页 |
| 207 | `    required String tocUrl,` | 必填字符串(String) 类型参数 目录(TOC) URL（目录(目录(TOC)) 统一资源链接(URL)） |
| 208 | `    required String firstPageHtml,` | 必填字符串(String) 类型参数 首个 页 HTML（首个 页 网页标记文本(HTML)） |
| 209 | `    required BookSource source,` | 必填书源(BookSource) 类型参数 书源（书源） |
| 210 | `    required Iterable<Map<String, String?>> seedChapters,` | 必填Iterable<映射(Map)<字符串(String), 字符串(String)?>> 类型参数 seedChapters（seed 章节列表） |
| 211 | `  }) async {` | 签名结束，进入异步方法体 }) 异步(async) { |
| 212 | `    if (!_supportsAjaxTocFallback(tocUrl, firstPageHtml)) {` | 条件判断 如果(if)：!_supportsAjaxTocFallback(目录(TOC) URL, 首个 页 HTML) |
| 213 | `      return const [];` | 返回 编译期常量(const) [] |
| 214 | `    }` | 闭合大括号，结束当前代码块 |
| 215 | `&nbsp;` | 空行，分隔逻辑段落 |
| 216 | `    final bookId = _extractAjaxTocBookId(firstPageHtml);` | 声明不可重新赋值的变量 书籍 编号(id)：调用 _extractAjaxTocBookId(...) → 提取 Ajax 目录(目录(TOC)) 书籍 编号(编号(id)) |
| 217 | `    if (bookId == null \|\| bookId.isEmpty) {` | 条件判断 如果(if)：书籍 编号(id) 等于 空值(null) 或 书籍 编号(id).是否为空 |
| 218 | `      return const [];` | 返回 编译期常量(const) [] |
| 219 | `    }` | 闭合大括号，结束当前代码块 |
| 220 | `&nbsp;` | 空行，分隔逻辑段落 |
| 221 | `    final ajaxUrl = NetworkService.joinUrl(` | 声明不可重新赋值的变量 ajaxUrl：调用 网络服务(NetworkService).拼接 URL(...) → 拼接 统一资源链接(URL) |
| 222 | `      tocUrl,` | 签名/调用续行参数：目录(TOC) URL |
| 223 | `      '/e/extend/bookpage/pages.php?id=$bookId',` | 以字符串 '/异常对象 e/extend/bookpage/pages.php?编号(id)=$书籍 编号(id)… 起始的表达式：, |
| 224 | `    );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 225 | `    final existingIdentities =` | 上一表达式的续行：不可重新赋值(final) existingIdentities = |
| 226 | `        seedChapters.map(_chapterIdentity).where((id) => id.isNotEmpty).toSet();` | 链式调用起始于 seedChapters（seed 章节列表），后续行继续该表达式：seedChapters.映射(map)(_chapterIdentity).筛选(where)((编号(id)) => 编号(id).是否非空).转为集合(… |
| 227 | `    final collected = <Map<String, String?>>[];` | 声明不可重新赋值的变量 collected |
| 228 | `&nbsp;` | 空行，分隔逻辑段落 |
| 229 | `    int? totalPages;` | 整数(int)? totalPages |
| 230 | `    int pageNum = 1;` | 整数(int) 页 编号 = 1 |
| 231 | `&nbsp;` | 空行，分隔逻辑段落 |
| 232 | `    while (pageNum < 100) {` | 当型循环(while) 循环，条件：页 编号 < 100 |
| 233 | `      try {` | 尝试(try) 块开始：包裹可能抛出异常的逻辑 |
| 234 | `        final response = await _networkService.post(` | 声明不可重新赋值的变量 响应：等待(await) 调用 _networkService.post(...) |
| 235 | `          ajaxUrl,` | 签名/调用续行参数：ajaxUrl |
| 236 | `          data: {'pageNum': pageNum},` | 命名实参 data: {'页 编号': 页 编号} |
| 237 | `          headers: {` | 命名实参 请求头: {（请求头） |
| 238 | `            ...NetworkService.parseHeaders(source.header),` | 链式调用起始于 ...网络服务(NetworkService)（Network 服务），后续行继续该表达式：...网络服务(NetworkService).解析 请求头(书源.请求头), |
| 239 | `            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',` | 映射(Map) 条目 '正文内容-类型': 'application/x-www-形态-urlencoded; 字符集=UTF-8', |
| 240 | `            'X-Requested-With': 'XMLHttpRequest',` | 映射(Map) 条目 'X-Requested-With': 'XML数据 超文本传输协议(HTTP) 请求', |
| 241 | `            'Referer': tocUrl,` | 映射(Map) 条目 'Referer': 目录(TOC) URL, |
| 242 | `          },` | 结束上一个列表/参数项 |
| 243 | `          retryCount: 1,` | 命名实参 重试次数: 1（重试 数量） |
| 244 | `        );` | 闭合语句结尾，结束当前调用/字面量/块 |
| 245 | `        final responseText = await NetworkService.getResponseText(response);` | 声明不可重新赋值的变量 响应 文本：等待(await) 调用 网络服务(NetworkService).获取 响应 文本(...) → 获取 响应 文本 |
| 246 | `        if (responseText.isEmpty) {` | 条件判断 如果(if)：响应 文本.是否为空 |
| 247 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 248 | `        }` | 闭合大括号，结束当前代码块 |
| 249 | `&nbsp;` | 空行，分隔逻辑段落 |
| 250 | `        final data = jsonDecode(responseText);` | 声明不可重新赋值的变量 data：调用 JSON 解码(...) → JSON数据 解码 |
| 251 | `        if (data is! Map<String, dynamic>) {` | 条件判断 如果(if)：data 是(is)! 映射(Map) < 字符串(String), dynamic > |
| 252 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 253 | `        }` | 闭合大括号，结束当前代码块 |
| 254 | `&nbsp;` | 空行，分隔逻辑段落 |
| 255 | `        totalPages ??= int.tryParse('${data['totalPage'] ?? ''}');` | 调用 tryParse(...)：totalPages ??= 整数(int).tryParse('${data['totalPage'] ?? ''}')（尝试(try) 解析） |
| 256 | `        final list = data['list'];` | 声明不可重新赋值的变量 list |
| 257 | `        if (list is! List \|\| list.isEmpty) {` | 条件判断 如果(if)：list 是(is)! 列表(List) 或 list.是否为空 |
| 258 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 259 | `        }` | 闭合大括号，结束当前代码块 |
| 260 | `&nbsp;` | 空行，分隔逻辑段落 |
| 261 | `        final pageChapters = <Map<String, String?>>[];` | 声明不可重新赋值的变量 页 章节列表 |
| 262 | `        for (final item in list) {` | 循环(for)-属于(in) 遍历：不可重新赋值(final) 条目 属于(in) list |
| 263 | `          if (item is! Map) continue;` | 条件判断 如果(if)：条目 是(is)! 映射(Map)) 继续(continue); |
| 264 | `          final title = '${item['title'] ?? ''}'.trim();` | 声明不可重新赋值的变量 标题：字符串字面量 '${条目['标题'] ?? ''}'.去除首尾空白(); |
| 265 | `          final rawUrl = '${item['pic'] ?? ''}'.trim();` | 声明不可重新赋值的变量 原始 URL：字符串字面量 '${条目['pic'] ?? ''}'.去除首尾空白(); |
| 266 | `          if (title.isEmpty \|\| rawUrl.isEmpty) continue;` | 条件判断 如果(if)：标题.是否为空 或 原始 URL.是否为空) 继续(continue); |
| 267 | `&nbsp;` | 空行，分隔逻辑段落 |
| 268 | `          final chapter = <String, String?>{` | 声明不可重新赋值的变量 章节 |
| 269 | `            'chapterName': title,` | 映射(Map) 条目 '章节 名称': 标题, |
| 270 | `            'chapterUrl': NetworkService.joinUrl(tocUrl, rawUrl),` | 映射(Map) 条目 '章节链接': 网络服务(NetworkService).拼接 URL(目录(TOC) URL, 原始 URL), |
| 271 | `            'isVip': '0',` | 映射(Map) 条目 'isVip': '0', |
| 272 | `            'isVolume': '0',` | 映射(Map) 条目 'isVolume': '0', |
| 273 | `            'updateTime': '',` | 映射(Map) 条目 'updateTime': '', |
| 274 | `            'nextTocUrl': '',` | 映射(Map) 条目 '下一页目录链接': '', |
| 275 | `          };` | 闭合代码块并衔接后续语句：; |
| 276 | `          final identity = _chapterIdentity(chapter);` | 声明不可重新赋值的变量 identity：调用 _chapterIdentity(...) → 章节 Identity |
| 277 | `          if (identity.isEmpty \|\| existingIdentities.contains(identity)) {` | 条件判断 如果(if)：identity.是否为空 或 existingIdentities.是否包含(identity) |
| 278 | `            continue;` | 继续(continue)：进入下一次循环迭代 |
| 279 | `          }` | 闭合大括号，结束当前代码块 |
| 280 | `          existingIdentities.add(identity);` | 链式调用起始于 existingIdentities，后续行继续该表达式：existingIdentities.添加(identity); |
| 281 | `          pageChapters.add(chapter);` | 链式调用起始于 页 章节列表（页 章节列表），后续行继续该表达式：页 章节列表.添加(章节); |
| 282 | `        }` | 闭合大括号，结束当前代码块 |
| 283 | `&nbsp;` | 空行，分隔逻辑段落 |
| 284 | `        if (pageChapters.isEmpty) {` | 条件判断 如果(if)：页 章节列表.是否为空 |
| 285 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 286 | `        }` | 闭合大括号，结束当前代码块 |
| 287 | `&nbsp;` | 空行，分隔逻辑段落 |
| 288 | `        collected.addAll(pageChapters);` | 链式调用起始于 collected，后续行继续该表达式：collected.批量添加(页 章节列表); |
| 289 | `        pageNum++;` | 页 编号++ |
| 290 | `&nbsp;` | 空行，分隔逻辑段落 |
| 291 | `        if (totalPages != null && pageNum >= totalPages) {` | 条件判断 如果(if)：totalPages 不等于 空值(null) 且 页 编号 > = totalPages |
| 292 | `          break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 293 | `        }` | 闭合大括号，结束当前代码块 |
| 294 | `      } catch (_) {` | 闭合 尝试(try) 块并捕获异常（忽略异常对象） |
| 295 | `        break;` | 跳出(break)：跳出当前循环/分支判断(switch) |
| 296 | `      }` | 闭合大括号，结束当前代码块 |
| 297 | `    }` | 闭合大括号，结束当前代码块 |
| 298 | `&nbsp;` | 空行，分隔逻辑段落 |
| 299 | `    if (collected.isNotEmpty) {` | 条件判断 如果(if)：collected.是否非空 |
| 300 | `      AppLog.instance.put('目录AJAX分页补全成功: 新增 ${collected.length} 个章节');` | 链式调用起始于 应用日志(AppLog).实例（实例），后续行继续该表达式：应用日志(AppLog).实例.写入数据库(put)('目录AJAX分页补全成功: 新增 ${collected.length} 个章节'); |
| 301 | `    }` | 闭合大括号，结束当前代码块 |
| 302 | `&nbsp;` | 空行，分隔逻辑段落 |
| 303 | `    return collected;` | 返回 collected |
| 304 | `  }` | 闭合大括号，结束当前代码块 |
