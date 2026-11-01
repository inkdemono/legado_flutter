part of 'book_service.dart';

// =============================================================================
// BookService 职责：书源搜索（单源/多源聚合）与书籍详情解析。
// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）
// =============================================================================

  /// 从单个书源搜索书籍
  /// 供SearchModel使用
  Future<List<Book>> searchBooksFromSource(
    BookSource source,
    String keyword,
    bool precisionSearch,
  ) async {
    final results = <Book>[];

    try {
      await ConcurrentRateLimiter(source).withLimit(() async {
        final searchUrl = _buildSearchUrl(source.searchUrl!, keyword);
        final fullUrl = NetworkService.joinUrl(source.bookSourceUrl, searchUrl);

        final response = await _networkService.get(
          fullUrl,
          headers: NetworkService.parseHeaders(source.header),
          retryCount: 1,
        );

        final html = await NetworkService.getResponseText(response);
        final searchResults = await RuleParser.parseSearchRule(
          html,
          source.ruleSearch,
          variables: {'keyword': keyword},
          baseUrl: fullUrl,
        );

        for (final result in searchResults) {
          final bookUrl = result['bookUrl'];
          if (bookUrl == null || bookUrl.isEmpty) continue;

          if (source.ruleSearch?.checkKeyWord != null &&
              source.ruleSearch!.checkKeyWord!.isNotEmpty) {
            final checkKeyWordValue = result['checkKeyWord'];
            if (checkKeyWordValue == null || checkKeyWordValue.isEmpty) {
              continue;
            }
          }

          final finalBookUrl =
              bookUrl.startsWith('http://') || bookUrl.startsWith('https://')
                  ? bookUrl
                  : NetworkService.joinUrl(source.bookSourceUrl, bookUrl);

          final book = Book(
            bookUrl: finalBookUrl,
            origin: source.bookSourceUrl,
            originName: source.bookSourceName,
            name: result['name'] ?? '',
            author: result['author'] ?? '',
            kind: result['kind'],
            coverUrl: result['coverUrl'],
            intro: result['intro'],
            wordCount: result['wordCount'],
            latestChapterTitle: result['lastChapter'],
            canUpdate: true,
          );

          if (precisionSearch) {
            final keywordLower = keyword.toLowerCase();
            final nameLower = book.name.toLowerCase();
            final authorLower = book.author.toLowerCase();

            if (nameLower != keywordLower &&
                authorLower != keywordLower &&
                !(nameLower.contains(keywordLower) &&
                    authorLower.contains(keywordLower))) {
              continue;
            }
          }

          results.add(book);
        }
      });
    } catch (e) {
      AppLog.instance.put('书源搜索失败: ${source.bookSourceName}', error: e);
    }

    return results;
  }

  /// 搜索书籍
  Future<List<Book>> searchBooks(
    String keyword, {
    List<BookSource>? sources,
    bool precisionSearch = false,
    Function(int current, int total)? onProgress,
    Function(Book book)? onResult, // 新增：找到结果时的回调
  }) async {
    if (keyword.isEmpty) return [];

    // 如果没有指定书源，获取所有启用的书源
    sources ??= await _bookSourceService.getAllBookSources(enabledOnly: true);

    // 过滤出有效的书源（启用且有搜索规则）
    final validSources = sources.where((source) {
      return source.enabled &&
          source.searchUrl != null &&
          source.ruleSearch != null;
    }).toList();

    final totalSources = validSources.length;
    final results = <Book>[];
    int currentIndex = 0;

    for (final source in validSources) {
      currentIndex++;

      // 报告进度
      if (onProgress != null) {
        onProgress(currentIndex, totalSources);
      }

      try {
        // 使用并发限流器（参考项目：ConcurrentRateLimiter）
        await ConcurrentRateLimiter(source).withLimit(() async {
          // 构建搜索URL（替换关键字）
          final searchUrl = _buildSearchUrl(source.searchUrl!, keyword);
          // 构建完整URL（处理相对路径）
          final fullUrl =
              NetworkService.joinUrl(source.bookSourceUrl, searchUrl);

          // 使用协议处理器发送请求（支持HTTP/JSON/WebView）
          final responseText = await _request(
            fullUrl,
            source,
          );

          final html = responseText;
          AppLog.instance.put('搜索响应: 内容长度=${html.length}, URL=$fullUrl');

          // 输出响应内容的前500个字符用于调试
          if (html.isNotEmpty) {
            final preview =
                html.length > 500 ? '${html.substring(0, 500)}...' : html;
            AppLog.instance.put(
                '搜索响应内容预览 (前${html.length > 500 ? 500 : html.length}字符):\n$preview');
          }

          // 解析搜索结果
          // 使用实际请求的URL作为baseUrl（参考项目中的做法）
          final searchResults = await RuleParser.parseSearchRule(
            html,
            source.ruleSearch,
            variables: {'keyword': keyword},
            baseUrl: fullUrl, // 使用实际请求的URL，而不是书源的基础URL
          );

          // 转换为Book对象
          for (final result in searchResults) {
            final bookUrl = result['bookUrl'];
            if (bookUrl == null || bookUrl.isEmpty) continue;

            // 检查 checkKeyWord 规则（如果存在）
            // 参考项目：checkKeyWord 用于验证搜索结果是否包含关键词
            // 如果规则存在且解析结果为空，说明搜索结果无效，跳过
            if (source.ruleSearch?.checkKeyWord != null &&
                source.ruleSearch!.checkKeyWord!.isNotEmpty) {
              final checkKeyWordValue = result['checkKeyWord'];
              // 如果 checkKeyWord 规则存在但解析结果为空，说明搜索结果不匹配，跳过
              if (checkKeyWordValue == null || checkKeyWordValue.isEmpty) {
                AppLog.instance.put('搜索结果未通过checkKeyWord验证，跳过');
                continue;
              }
            }

            // 如果bookUrl已经是绝对URL，直接使用；否则相对于书源URL处理
            final finalBookUrl =
                bookUrl.startsWith('http://') || bookUrl.startsWith('https://')
                    ? bookUrl
                    : NetworkService.joinUrl(source.bookSourceUrl, bookUrl);

            final kindValue = result['kind'];
            // 添加调试日志（仅前3个结果）
            if (results.length < 3) {
              AppLog.instance.put(
                  'searchBooks: 创建Book对象 - name=${result['name']}, author=${result['author']}, kind=$kindValue, kind规则=${source.ruleSearch?.kind}');
            }

            final book = Book(
              bookUrl: finalBookUrl,
              origin: source.bookSourceUrl,
              originName: source.bookSourceName,
              name: result['name'] ?? '',
              author: result['author'] ?? '',
              kind: kindValue,
              // coverUrl已经在parseRule中使用实际请求的URL（fullUrl）作为baseUrl处理过了
              // 参考项目中，封面URL使用当前页面URL作为baseUrl，parseRule已经处理
              coverUrl: result['coverUrl'],
              intro: result['intro'],
              wordCount: result['wordCount'],
              latestChapterTitle: result['lastChapter'],
              canUpdate: true,
            );

            // 精确搜索模式：只保留书名或作者完全匹配的结果
            if (precisionSearch) {
              final keywordLower = keyword.toLowerCase();
              final nameLower = book.name.toLowerCase();
              final authorLower = book.author.toLowerCase();

              if (nameLower != keywordLower &&
                  authorLower != keywordLower &&
                  !(nameLower.contains(keywordLower) &&
                      authorLower.contains(keywordLower))) {
                continue; // 跳过不匹配的结果
              }
            }

            results.add(book);

            // 立即回调新结果
            if (onResult != null) {
              onResult(book);
            }
          }
        });
      } catch (e) {
        // 搜索失败，记录日志并继续下一个书源
        AppLog.instance.put('书源搜索失败: ${source.bookSourceName}', error: e);
        continue;
      }
    }

    return results;
  }

  /// 获取书籍详情
  Future<Book?> getBookInfo(Book book) async {
    if (book.isLocal) {
      // 本地书籍不需要获取详情
      return book;
    }

    final source = await _bookSourceService.getBookSourceByUrl(book.origin);
    if (source == null || source.ruleBookInfo == null) {
      AppLog.instance.put('getBookInfo: 书源不存在或详情规则为空');
      return book;
    }

    try {
      AppLog.instance.put('getBookInfo: 开始获取书籍详情，bookUrl=${book.bookUrl}');

      // 使用并发限流器（参考项目：ConcurrentRateLimiter）
      final updatedBook =
          await ConcurrentRateLimiter(source).withLimit(() async {
        String html = '';
        bool usedCachedInfoHtml = false;

        if (book.infoHtml != null && book.infoHtml!.isNotEmpty) {
          html = book.infoHtml!;
          usedCachedInfoHtml = true;
          AppLog.instance.put(
            'getBookInfo: 使用列表页透传HTML，内容长度=${html.length}, URL=${book.bookUrl}',
          );
        } else {
          html = await _fetchBookInfoHtml(book, source);
        }

        var bookInfo = await RuleParser.parseBookInfoRule(
          html,
          source.ruleBookInfo,
          baseUrl: book.bookUrl,
        );

        if (usedCachedInfoHtml && !_hasMeaningfulBookInfo(bookInfo)) {
          AppLog.instance.put('getBookInfo: 透传HTML未命中详情规则，回退网络请求');
          html = await _fetchBookInfoHtml(book, source);
          bookInfo = await RuleParser.parseBookInfoRule(
            html,
            source.ruleBookInfo,
            baseUrl: book.bookUrl,
          );
        }

        // 更新书籍信息
        final newTocUrl = bookInfo['tocUrl'] != null
            ? NetworkService.joinUrl(source.bookSourceUrl, bookInfo['tocUrl']!)
            : book.tocUrl;

        AppLog.instance.put(
            'getBookInfo: 解析结果 - name=${bookInfo['name']}, author=${bookInfo['author']}, kind=${bookInfo['kind']}, tocUrl=${bookInfo['tocUrl']}, 最终tocUrl=$newTocUrl');

        // 处理 canReName（如果可以重命名，存储到 variable 中）
        String? updatedVariable = book.variable;
        final canReNameValue = bookInfo['canReName'];
        if (canReNameValue != null && canReNameValue.isNotEmpty) {
          // 将 canReName 存储到 variable JSON 中
          try {
            final variableMap = <String, dynamic>{};
            if (updatedVariable != null && updatedVariable.isNotEmpty) {
              final decoded =
                  jsonDecode(updatedVariable) as Map<String, dynamic>?;
              if (decoded != null) {
                variableMap.addAll(decoded);
              }
            }
            // canReName 通常是一个布尔值或字符串，存储为字符串
            variableMap['canReName'] = canReNameValue;
            updatedVariable = jsonEncode(variableMap);
          } catch (e) {
            AppLog.instance
                .put('getBookInfo: 更新canReName到variable失败', error: e);
          }
        }

        String? pickNonBlank(String? primary, String? fallback) {
          if (primary != null && primary.trim().isNotEmpty) {
            return primary;
          }
          return fallback;
        }

        // 更新书籍信息
        return book.copyWith(
          name: pickNonBlank(bookInfo['name'], book.name) ?? book.name,
          author: pickNonBlank(bookInfo['author'], book.author) ?? book.author,
          kind: pickNonBlank(bookInfo['kind'], book.kind),
          // coverUrl已经在parseRule中使用书籍详情页URL（book.bookUrl）作为baseUrl处理过了
          // 参考项目：封面URL使用当前页面URL作为baseUrl，parseRule已经处理
          coverUrl: pickNonBlank(bookInfo['coverUrl'], book.coverUrl),
          intro: pickNonBlank(bookInfo['intro'], book.intro),
          wordCount: pickNonBlank(bookInfo['wordCount'], book.wordCount),
          latestChapterTitle:
              pickNonBlank(bookInfo['lastChapter'], book.latestChapterTitle),
          tocUrl: newTocUrl,
          variable: updatedVariable,
          infoHtml: html,
          lastCheckTime: DateTime.now().millisecondsSinceEpoch,
        );
      });

      // 参考项目：如果书籍在书架中，自动保存到数据库
      try {
        final existingBook = await getBookByUrl(book.bookUrl);
        if (existingBook != null) {
          // 书籍在书架中，自动更新数据库
          await updateBook(updatedBook);
          AppLog.instance.put('getBookInfo: 书籍在书架中，已自动更新数据库');
        } else {
          // 尝试通过书名和作者查找（因为bookUrl可能不同）
          final existingByName = await getBookByNameAndAuthor(
              updatedBook.name, updatedBook.author);
          if (existingByName != null) {
            // 找到同名同作者的书籍，更新它
            final finalBook =
                updatedBook.copyWith(bookUrl: existingByName.bookUrl);
            await updateBook(finalBook);
            AppLog.instance.put('getBookInfo: 通过书名和作者找到书籍，已自动更新数据库');
          }
        }
      } catch (e) {
        // 保存失败不影响返回结果
        AppLog.instance.put('getBookInfo: 自动保存书籍详情失败', error: e);
      }

      return updatedBook;
    } catch (e) {
      AppLog.instance.put('getBookInfo: 获取书籍详情失败', error: e);
      return book;
    }
  }

  Future<String> _fetchBookInfoHtml(Book book, BookSource source) async {
    final headers = NetworkService.parseHeaders(source.header);
    headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
    headers['Pragma'] = 'no-cache';
    headers['Expires'] = '0';

    AppLog.instance.put(
      'getBookInfo: 请求URL=${book.bookUrl}, 请求头数量=${headers.length}',
    );

    final html = await _request(
      book.bookUrl,
      source,
      headers: headers,
    );

    AppLog.instance.put(
      'getBookInfo: 内容长度=${html.length}, URL=${book.bookUrl}',
    );

    return html;
  }

  bool _hasMeaningfulBookInfo(Map<String, String?> bookInfo) {
    const keys = [
      'name',
      'author',
      'kind',
      'wordCount',
      'lastChapter',
      'intro',
      'coverUrl',
      'tocUrl'
    ];
    for (final key in keys) {
      final value = bookInfo[key];
      if (value != null && value.trim().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// 获取章节列表（支持分页获取所有章节）
