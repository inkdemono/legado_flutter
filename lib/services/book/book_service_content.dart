part of 'book_service.dart';

// =============================================================================
// BookService 职责：章节正文获取（规则解析、分页拼接、本地缓存与并发去重）。
// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）
// =============================================================================

  Future<String?> getChapterContent(
    BookChapter chapter,
    BookSource source, {
    String? bookName,
    String? bookOrigin,
    Book? book, // 新增：用于缓存检查和保存
  }) async {
    if (source.ruleContent == null) {
      AppLog.instance.put('获取章节内容失败: 内容规则为空 (章节: ${chapter.title})');
      return null;
    }

    // ✅ 新策略: 优先从文件存储读取
    if (book != null && !book.isLocal) {
      // 1. 如果chapter有localPath,从文件读取
      if (chapter.localPath != null && chapter.localPath!.isNotEmpty) {
        final fileContent = await readService(AppServices.chapterContentService)
            .getChapterContent(book, chapter);
        if (fileContent != null && fileContent.isNotEmpty) {
          AppLog.instance
              .put('从文件存储读取: ${chapter.title} (${fileContent.length}字)');
          return fileContent;
        }
        // localPath存在但文件不存在,继续从网络获取
        AppLog.instance.put('警告: localPath存在但文件不存在: ${chapter.title}');
      }

      // 2. 尝试从文件系统读取(向后兼容旧缓存)
      final fileContent = await readService(AppServices.chapterContentService)
          .getChapterContent(book, chapter);
      if (fileContent != null && fileContent.isNotEmpty) {
        AppLog.instance.put(
            '从文件系统读取(无localPath): ${chapter.title} (${fileContent.length}字)');
        // 更新localPath
        final localPath = readService(AppServices.chapterContentService)
            .getChapterLocalPath(book, chapter);
        chapter.localPath = localPath;
        // 异步更新数据库,不阻塞返回
        _updateChapterLocalPath(chapter.bookUrl, chapter.url, localPath)
            .catchError((e) => AppLog.instance.put('更新localPath失败', error: e));
        return fileContent;
      }

      // 3. 回退: 从旧的CacheService读取
      final cachedContent = await readService(AppServices.cacheService)
          .getCachedChapterContent(book, chapter);
      if (cachedContent != null && cachedContent.isNotEmpty) {
        AppLog.instance
            .put('从旧缓存读取: ${chapter.title} (${cachedContent.length}字)');
        return cachedContent;
      }
    }

    final chapterKey = chapter.primaryStr();
    return _loadingChapters.putIfAbsent(chapterKey, () async {
      try {
        return await _getChapterContentInternal(
          chapter,
          source,
          bookName: bookName,
          bookOrigin: bookOrigin,
          book: book,
        );
      } finally {
        _loadingChapters.remove(chapterKey);
      }
    });
  }

  /// 获取章节正文的内部实现
  /// 参考项目：支持分页获取（nextContentUrl），循环获取所有页面的内容
  Future<String?> _getChapterContentInternal(
    BookChapter chapter,
    BookSource source, {
    String? bookName,
    String? bookOrigin,
    Book? book, // 新增：用于缓存保存
  }) async {
    try {
      final contentVariables =
          book != null ? _buildRuleVariables(book) : <String, String>{};
      // 参考项目：使用章节URL作为baseUrl，支持分页获取
      // 参考项目：BookContent.analyzeContent
      var currentUrl = chapter.url;
      currentUrl = _repairChapterUrlWithBookVariables(currentUrl, book);
      var redirectUrl = currentUrl; // 重定向后的URL
      var visitedUrls = <String>{currentUrl};
      var contentList = <String>[];

      // 参考项目：获取下一章的URL（用于判断是否到达下一章）
      final localChapters = await _getLocalChapters(chapter.bookUrl);
      BookChapter? nextChapter;
      if (chapter.index + 1 < localChapters.length) {
        nextChapter = localChapters[chapter.index + 1];
      } else if (localChapters.isNotEmpty) {
        // 参考项目：如果下一章不存在，使用第一章（循环）
        nextChapter = localChapters[0];
      }
      final nextChapterUrl = nextChapter?.url;

      // ── Phase 3：payAction 预执行（付费章节自动解锁）──────────────────────
      // 当章节是 VIP 且未购买，且书源配置了 payAction 时，先执行解锁动作，
      // 成功后重新请求章节页面以获取解锁内容。
      bool didPayAction = false;
      if (chapter.isVip &&
          !chapter.isPay &&
          source.ruleContent?.payAction != null &&
          source.ruleContent!.payAction!.isNotEmpty) {
        AppLog.instance.put('payAction: 检测到付费章节，尝试执行解锁 (章节: ${chapter.title})');
        // 先请求一次页面（payAction 可能需要当前页的 HTML 上下文，如 cookie/token）
        try {
          final preResponse = await _networkService.get(
            currentUrl,
            headers: NetworkService.parseHeaders(source.header),
            retryCount: 1,
          );
          final preHtml = await NetworkService.getResponseText(preResponse);
          didPayAction = await RuleParser.executePayAction(
            preHtml,
            source.ruleContent!.payAction!,
            variables: contentVariables,
            source: source,
            book: book,
            baseUrl: currentUrl,
          );
          if (didPayAction) {
            AppLog.instance.put('payAction: 解锁请求已发送，将重新请求章节页面');
          }
        } catch (e) {
          AppLog.instance.put('payAction: 预请求失败，跳过解锁', error: e);
        }
      }

      final response = await _networkService.get(
        currentUrl,
        headers: NetworkService.parseHeaders(source.header),
        retryCount: 1,
      );

      var html = await NetworkService.getResponseText(response);
      // 参考项目：获取重定向后的URL（如果有）
      // 注意：Dio的Response可能没有redirectRecord，使用实际请求的URL
      redirectUrl = response.realUri.toString();

      AppLog.instance
          .put('获取章节内容响应: 状态码=${response.statusCode}, 内容长度=${html.length}');

      if (html.isEmpty) {
        AppLog.instance.put('章节内容响应为空');
        throw ContentEmptyException('章节内容为空: ${chapter.title}');
      }

      final pageContent = await RuleParser.parseContentRule(
        html,
        source.ruleContent,
        variables: contentVariables,
        baseUrl: currentUrl, // 使用当前请求的URL作为baseUrl
        bookName: bookName,
        bookOrigin: bookOrigin,
        applyReplaceRegex: false, // 不在每页应用，而是在合并后统一应用
        bookSourceType: source.bookSourceType, // 传入书源类型，启用音视频分发路径
      );

      if (pageContent == null || pageContent.isEmpty) {
        AppLog.instance.put('章节内容解析失败: 内容为空 (章节: ${chapter.title})');
        throw ContentEmptyException('章节内容为空: ${chapter.title}');
      }

      // 音频源（bookSourceType == 1）：parseContentRule 返回的是通过
      // audioUrl 规则或 sourceRegex 嗅探提取的媒体 URL，将其写入
      // chapter.resourceUrl 供播放器直接使用。
      if (source.bookSourceType == 1) {
        chapter.resourceUrl = pageContent;
        AppLog.instance.put(
            '音频源: 已提取资源URL → ${chapter.resourceUrl} (章节: ${chapter.title})');
      }

      // ── Phase 3：解析音视频辅助字段（lyricsUrl/subtitleUrl/qualityOptions）
      if (source.bookSourceType == 1 || source.bookSourceType == 2) {
        try {
          final extras = await RuleParser.parseAudioExtras(
            html,
            source.ruleContent,
            variables: contentVariables,
            baseUrl: currentUrl,
          );
          if (extras['lyricsUrl'] != null) {
            chapter.lyricsUrl = extras['lyricsUrl'];
          }
          if (extras['subtitleUrl'] != null) {
            chapter.subtitleUrl = extras['subtitleUrl'];
          }
          if (extras['qualityOptions'] != null) {
            chapter.qualityOptions = extras['qualityOptions'];
          }
        } catch (e) {
          AppLog.instance.put('parseAudioExtras: 解析辅助字段失败', error: e);
        }
      }

      contentList.add(pageContent);

      // 参考项目：获取下一页URL列表（可能返回多个URL）
      // 参考项目：analyzeRule.getStringList(nextUrlRule, isUrl = true)
      List<String> nextUrlList = [];

      if (source.ruleContent?.nextContentUrl != null &&
          source.ruleContent!.nextContentUrl!.isNotEmpty) {
        AppLog.instance
            .put('获取章节内容下一页URL: 规则=${source.ruleContent!.nextContentUrl}');

        // 参考项目：使用parseListRule获取URL列表（isUrl=true）
        final rawNextUrlList = await RuleParser.parseUrlListRuleAsync(
          html,
          source.ruleContent!.nextContentUrl!,
          variables: contentVariables,
          baseUrl: redirectUrl,
        );

        // 将相对URL转换为绝对URL，并过滤
        for (final url in rawNextUrlList) {
          if (url.isNotEmpty) {
            final absoluteUrl = url.startsWith('http')
                ? url
                : NetworkService.joinUrl(redirectUrl, url);
            // 参考项目：过滤掉与redirectUrl相同的URL
            if (absoluteUrl != redirectUrl &&
                !visitedUrls.contains(absoluteUrl)) {
              nextUrlList.add(absoluteUrl);
            }
          }
        }

        AppLog.instance.put('获取章节内容下一页URL: 找到 ${nextUrlList.length} 个URL');
        for (int i = 0; i < nextUrlList.length; i++) {
          AppLog.instance.put('  下一页URL ${i + 1}: ${nextUrlList[i]}');
        }
      }

      // 参考项目逻辑：
      // 如果 nextUrlList.size == 0，没有下一页，直接返回
      // 如果 nextUrlList.size == 1，循环获取所有页面
      // 如果 nextUrlList.size > 1，并发获取所有页面
      if (nextUrlList.isEmpty) {
        // 没有下一页，直接返回
        AppLog.instance.put('没有找到下一页URL');
      } else if (nextUrlList.length == 1) {
        // 参考项目：循环获取所有页面
        var nextUrl = nextUrlList[0];
        var pageCount = 1;

        while (nextUrl.isNotEmpty && !visitedUrls.contains(nextUrl)) {
          // 参考项目：检查是否到达下一章
          // 参考项目逻辑：NetworkUtils.getAbsoluteURL(redirectUrl, nextUrl) == NetworkUtils.getAbsoluteURL(redirectUrl, mNextChapterUrl)
          if (nextChapterUrl != null) {
            // 将两个 URL 都通过 getAbsoluteURL 规范化后再比较
            final normalizedNextUrl =
                NetworkUtils.getAbsoluteURL(redirectUrl, nextUrl);
            final normalizedNextChapterUrl =
                NetworkUtils.getAbsoluteURL(redirectUrl, nextChapterUrl);

            if (_urlEquals(normalizedNextUrl, normalizedNextChapterUrl)) {
              AppLog.instance.put('下一页URL等于下一章URL，停止获取');
              break;
            }
          }

          pageCount++;
          visitedUrls.add(nextUrl);
          AppLog.instance.put('获取章节内容第 $pageCount 页: $nextUrl');

          try {
            final nextResponse = await _networkService.get(
              nextUrl,
              headers: NetworkService.parseHeaders(source.header),
              retryCount: 1,
            );

            final nextHtml = await NetworkService.getResponseText(nextResponse);
            final nextRedirectUrl = nextResponse.realUri.toString();

            if (nextHtml.isEmpty) {
              AppLog.instance.put('章节内容响应为空，停止获取');
              break;
            }

            final nextPageContent = await RuleParser.parseContentRule(
              nextHtml,
              source.ruleContent,
              baseUrl: nextUrl,
              bookName: bookName,
              bookOrigin: bookOrigin,
              applyReplaceRegex: false,
            );

            if (nextPageContent != null && nextPageContent.isNotEmpty) {
              contentList.add(nextPageContent);
              AppLog.instance.put('第${contentList.length}页完成');
            }

            // 获取下一页URL
            if (source.ruleContent?.nextContentUrl != null &&
                source.ruleContent!.nextContentUrl!.isNotEmpty) {
              final nextNextUrlList = RuleParser.parseListRule(
                nextHtml,
                source.ruleContent!.nextContentUrl!,
                variables: null,
                baseUrl: nextRedirectUrl,
                returnHtml: false,
              );

              // 转换为绝对URL并过滤
              final filteredNextUrls = <String>[];
              for (final url in nextNextUrlList) {
                if (url.isNotEmpty) {
                  final absoluteUrl = url.startsWith('http')
                      ? url
                      : NetworkService.joinUrl(nextRedirectUrl, url);
                  if (absoluteUrl != nextRedirectUrl &&
                      !visitedUrls.contains(absoluteUrl)) {
                    // 检查是否到达下一章（参考项目：使用 getAbsoluteURL 规范化后比较）
                    if (nextChapterUrl != null) {
                      final normalizedAbsoluteUrl = NetworkUtils.getAbsoluteURL(
                          nextRedirectUrl, absoluteUrl);
                      final normalizedNextChapterUrl =
                          NetworkUtils.getAbsoluteURL(
                              nextRedirectUrl, nextChapterUrl);
                      if (_urlEquals(
                          normalizedAbsoluteUrl, normalizedNextChapterUrl)) {
                        AppLog.instance.put('检测到下一页URL等于下一章URL，停止获取');

                        filteredNextUrls.clear();
                        break;
                      }
                    }
                    filteredNextUrls.add(absoluteUrl);
                  }
                }
              }

              if (filteredNextUrls.isEmpty) {
                break;
              }
              nextUrl = filteredNextUrls[0];
            } else {
              break;
            }
          } catch (e) {
            AppLog.instance.put('获取第 $pageCount 页失败: $e', error: e);
            break;
          }
        }

        AppLog.instance.put('本章总页数: ${visitedUrls.length}');
      } else {
        // 参考项目：并发获取所有页面
        // 注意：并发模式下也需要过滤掉下一章的URL
        final filteredNextUrlList = <String>[];
        if (nextChapterUrl != null) {
          // 参考项目：使用 getAbsoluteURL 规范化后比较
          final normalizedNextChapterUrl =
              NetworkUtils.getAbsoluteURL(redirectUrl, nextChapterUrl);
          for (final url in nextUrlList) {
            final normalizedUrl = NetworkUtils.getAbsoluteURL(redirectUrl, url);
            if (!_urlEquals(normalizedUrl, normalizedNextChapterUrl)) {
              filteredNextUrlList.add(url);
            } else {
              AppLog.instance.put('并发模式：过滤掉下一章URL: $url');
            }
          }
        } else {
          filteredNextUrlList.addAll(nextUrlList);
        }

        AppLog.instance.put(
            '并发解析正文，总页数: ${filteredNextUrlList.length} (原始: ${nextUrlList.length})');

        final futures = filteredNextUrlList.asMap().entries.map((entry) async {
          final url = entry.value;
          try {
            final response = await _networkService.get(
              url,
              headers: NetworkService.parseHeaders(source.header),
              retryCount: 1,
            );
            final pageHtml = await NetworkService.getResponseText(response);
            return {'url': url, 'html': pageHtml, 'success': true};
          } catch (e) {
            return {'url': url, 'html': '', 'success': false};
          }
        }).toList();

        final results = await Future.wait(futures);

        for (final result in results) {
          if (result['success'] == true &&
              (result['html'] as String).isNotEmpty) {
            final pageHtml = result['html'] as String;
            final pageUrl = result['url'] as String;

            final pageContent = await RuleParser.parseContentRule(
              pageHtml,
              source.ruleContent,
              baseUrl: pageUrl,
              bookName: bookName,
              bookOrigin: bookOrigin,
              applyReplaceRegex: false,
            );

            if (pageContent != null && pageContent.isNotEmpty) {
              contentList.add(pageContent);
            }
          }
        }
      }

      // 合并所有页面的内容
      if (contentList.isEmpty) {
        AppLog.instance.put('章节内容获取失败: 所有页面内容都为空 (章节: ${chapter.title})');
        throw ContentEmptyException('章节内容为空: ${chapter.title}');
      }

      // 参考项目：将多页内容拼接在一起
      var content = contentList.join('\n');
      final totalPages = contentList.length;
      AppLog.instance.put(
          '章节内容获取成功: 共 $totalPages 页，合并前总长度=${content.length} (章节: ${chapter.title})');

      // 参考项目：在所有页面内容合并后，统一应用replaceRegex规则
      // 参考项目逻辑：先将内容按行分割并trim，应用替换规则，然后在每行前添加全角空格
      if (source.ruleContent?.replaceRegex != null &&
          source.ruleContent!.replaceRegex!.isNotEmpty) {
        // #region agent log
        try {
          final f = File(
              '/Users/zhangmingxun/Desktop/legado_flutter/.cursor/debug.log');
          f.writeAsStringSync(
              '${jsonEncode({
                    "location": "book_service.dart:2449",
                    "message": "book_service应用replaceRegex前",
                    "data": {
                      "replaceRegex": source.ruleContent!.replaceRegex,
                      "contentLength": content.length,
                      "totalPages": totalPages
                    },
                    "timestamp": DateTime.now().millisecondsSinceEpoch,
                    "sessionId": "debug-session",
                    "hypothesisId": "D"
                  })}\n',
              mode: FileMode.append);
        } catch (_) {
          // 忽略调试日志写入失败，不影响正文处理流程。
        }
        // #endregion

        AppLog.instance
            .put('应用replaceRegex规则: ${source.ruleContent!.replaceRegex}');

        // 参考项目逻辑：按行分割并trim每行
        final lines = content.split('\n');
        content = lines.map((line) => line.trim()).join('\n');

        // 应用replaceRegex规则
        final beforeReplace = content;
        content = RuleParser.applyReplaceRegex(
            content, source.ruleContent!.replaceRegex!);

        // 参考项目逻辑：按行分割并在每行前添加全角空格（段落缩进）
        final processedLines = content.split('\n');
        content = processedLines.map((line) => '　　$line').join('\n');

        // #region agent log
        try {
          final f = File(
              '/Users/zhangmingxun/Desktop/legado_flutter/.cursor/debug.log');
          f.writeAsStringSync(
              '${jsonEncode({
                    "location": "book_service.dart:2469",
                    "message": "book_service应用replaceRegex后",
                    "data": {
                      "contentLengthBefore": beforeReplace.length,
                      "contentLengthAfter": content.length
                    },
                    "timestamp": DateTime.now().millisecondsSinceEpoch,
                    "sessionId": "debug-session",
                    "hypothesisId": "D"
                  })}\n',
              mode: FileMode.append);
        } catch (_) {
          // 忽略调试日志写入失败，不影响正文处理流程。
        }
        // #endregion

        AppLog.instance.put('应用replaceRegex后，内容长度=${content.length}');
      }

      // 输出章节内容 前500 字符
      // 输出章节内容 后500 字符
      // 参考项目：在返回内容前立即保存到缓存（BookHelp.saveText）
      // 这样可以避免 _loadingChapters 移除后、缓存写入前的竞态条件
      if (book != null && !book.isLocal) {
        // ✅ 新策略: 保存到文件存储
        final localPath = await readService(AppServices.chapterContentService)
            .saveChapterContent(book, chapter, content);

        if (localPath != null) {
          // 更新内存中的chapter对象
          chapter.localPath = localPath;
          // 异步更新数据库,不阻塞返回
          _updateChapterLocalPath(chapter.bookUrl, chapter.url, localPath)
              .catchError(
                  (e) => AppLog.instance.put('更新localPath失败', error: e));
        }

        // 同时保存到旧缓存(向后兼容)
        await readService(AppServices.cacheService)
            .saveChapterContent(book, chapter, content);
      } else if (book == null) {
        // 未传入 book 参数，尝试从数据库查询（向后兼容）
        try {
          final dbBook = await getBookByUrl(chapter.bookUrl);
          if (dbBook != null && !dbBook.isLocal) {
            await readService(AppServices.cacheService)
                .saveChapterContent(dbBook, chapter, content);
          }
        } catch (e) {
          // 缓存失败不影响返回内容
        }
      }

      return content;
    } catch (e, stackTrace) {
      AppLog.instance.put('获取章节内容失败', error: e);
      AppLog.instance.put('错误堆栈: $stackTrace');
      AppLog.instance.put('章节URL: ${chapter.url}, 章节标题: ${chapter.title}');
      return null;
    }
  }

  /// 保存书籍到书架
