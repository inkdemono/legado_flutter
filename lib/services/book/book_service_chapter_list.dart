part of 'book_service.dart';

// =============================================================================
// BookService 职责：章节列表获取（分页加载、智能降级解析、持久化）。
// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）
// =============================================================================

  Future<List<BookChapter>> getChapterList(
    Book book, {
    bool loadAllPages = true,
  }) async {
    if (book.isLocal) {
      // 本地书籍从数据库读取章节
      return await _getLocalChapters(book.bookUrl);
    }

    final source = await _bookSourceService.getBookSourceByUrl(book.origin);
    if (source == null || source.ruleToc == null) {
      return [];
    }

    try {
      final chapterVariables = _buildRuleVariables(book);
      // 使用tocUrl或bookUrl
      final tocUrl = book.tocUrl.isNotEmpty ? book.tocUrl : book.bookUrl;
      AppLog.instance.put('开始获取章节列表: tocUrl=$tocUrl, bookUrl=${book.bookUrl}');

      // 发送请求
      final response = await _networkService.get(
        tocUrl,
        headers: NetworkService.parseHeaders(source.header),
        retryCount: 1,
      );

      var html = await NetworkService.getResponseText(response);

      AppLog.instance
          .put('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}');

      if (html.isEmpty) {
        AppLog.instance.put('获取章节列表失败: 响应内容为空');
        // 如果获取失败，尝试从数据库读取
        final localChapters = await _getLocalChapters(book.bookUrl);
        if (localChapters.isEmpty) {
          throw TocEmptyException('获取章节列表失败: 响应内容为空，且本地无章节数据');
        }
        return localChapters;
      }

      // 确定有效的baseUrl：如果tocUrl不是有效的绝对URL，使用source.bookSourceUrl
      String? effectiveBaseUrl = tocUrl;
      if (!tocUrl.isAbsUrl()) {
        // 如果source.bookSourceUrl也是有效的绝对URL，使用它；否则尝试从tocUrl构建
        if (source.bookSourceUrl.isAbsUrl()) {
          effectiveBaseUrl = source.bookSourceUrl;
          AppLog.instance.put(
              'tocUrl不是绝对URL，使用source.bookSourceUrl作为baseUrl: $effectiveBaseUrl');
        } else {
          // 如果两者都不是绝对URL，尝试从tocUrl构建完整的URL
          // 如果tocUrl是相对路径，使用source.bookSourceUrl作为基础
          try {
            effectiveBaseUrl =
                NetworkService.joinUrl(source.bookSourceUrl, tocUrl);
            if (!effectiveBaseUrl.isAbsUrl()) {
              // 如果仍然无效，使用source.bookSourceUrl
              effectiveBaseUrl = source.bookSourceUrl;
            }
            AppLog.instance.put(
                'tocUrl和source.bookSourceUrl都不是绝对URL，尝试拼接后: $effectiveBaseUrl');
          } catch (e) {
            AppLog.instance.put(
                '构建baseUrl失败: $e，使用source.bookSourceUrl: ${source.bookSourceUrl}');
            effectiveBaseUrl = source.bookSourceUrl;
          }
        }
      }

      // 最终验证：确保effectiveBaseUrl是有效的绝对URL
      if (!effectiveBaseUrl.isAbsUrl()) {
        AppLog.instance
            .put('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败');
      }

      // 参考项目：执行 preUpdateJs（如果存在）
      // 参考项目的 TocRule 有 preUpdateJs 字段，用于在解析目录前预处理HTML
      if (source.ruleToc?.preUpdateJs != null &&
          source.ruleToc!.preUpdateJs!.isNotEmpty) {
        AppLog.instance.put('执行 preUpdateJs 预处理HTML');
        try {
          final preUpdateResult = await RuleParser.executeJs(
            html,
            source.ruleToc!.preUpdateJs!,
            source: source,
            book: book,
            baseUrl: effectiveBaseUrl,
          );
          if (preUpdateResult != null && preUpdateResult.isNotEmpty) {
            html = preUpdateResult;
            AppLog.instance.put('preUpdateJs 执行成功，HTML长度=${html.length}');
          } else {
            AppLog.instance.put('preUpdateJs 执行返回空，使用原始HTML');
          }
        } catch (e) {
          AppLog.instance.put('preUpdateJs 执行失败: $e，使用原始HTML', error: e);
        }
      }

      // 首先尝试使用原始规则获取第一页，如果失败则使用降级规则
      TocRule? effectiveTocRule = source.ruleToc;
      String? fallbackChapterListRule;

      // 检查原始规则是否能匹配到章节
      var testChapterList = RuleParser.parseTocRule(
        html,
        source.ruleToc,
        baseUrl: effectiveBaseUrl,
      );

      if (testChapterList.isEmpty && source.ruleToc?.chapterList != null) {
        AppLog.instance.put('原始规则未匹配到章节，尝试智能降级处理');

        // 查找降级规则
        final chapterLinkPattern = RegExp(
            '<a[^>]*href=["\']/[^"\']*\\.html["\'][^>]*>.*?</a>',
            caseSensitive: false,
            dotAll: true);
        final chapterLinkMatches = chapterLinkPattern.allMatches(html).toList();

        if (chapterLinkMatches.isNotEmpty) {
          AppLog.instance
              .put('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器');

          html_dom.Element? directoryContainer;
          String? containerClass;
          String? containerId;

          // 首先尝试查找directoryArea容器
          final doc = html_parser.parse(html);
          final directoryPattern = RegExp(
              'class\\s*=\\s*["\'][^"\']*directory[^"\']*["\']',
              caseSensitive: false);
          final directoryMatches = directoryPattern.allMatches(html);
          if (directoryMatches.isNotEmpty) {
            final match = directoryMatches.first;
            final matchHtml = html.substring(match.start, match.end);
            final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',
                caseSensitive: false);
            final classMatch = classPattern.firstMatch(matchHtml);
            if (classMatch != null) {
              final allClasses =
                  classMatch.group(1)?.split(RegExp(r'\s+')) ?? [];
              final dirClass = allClasses.firstWhere(
                (c) => c.contains('directory'),
                orElse: () => '',
              );
              if (dirClass.isNotEmpty) {
                directoryContainer =
                    HtmlParser.selectElement(doc, 'div.$dirClass');
                containerClass = dirClass;
                AppLog.instance.put('找到directory容器: class=$containerClass');
              }
            }
          }

          // 如果找到了directory容器，提取其class或id用于生成降级规则
          if (directoryContainer != null) {
            final dirClassAttr = directoryContainer.attributes['class'];
            final dirIdAttr = directoryContainer.attributes['id'];
            if (dirClassAttr != null && dirClassAttr.contains('directory')) {
              final allClasses = dirClassAttr.split(RegExp(r'\s+'));
              final dirClass = allClasses.firstWhere(
                (c) => c.contains('directory'),
                orElse: () => allClasses.first,
              );
              containerClass = dirClass;
              AppLog.instance.put('从directory容器提取class: $containerClass');
            }
            if (dirIdAttr != null) {
              containerId = dirIdAttr;
              AppLog.instance.put('从directory容器提取id: $containerId');
            }
          }

          // 生成降级规则
          if (containerClass != null) {
            fallbackChapterListRule = 'class.$containerClass@tag.a';
            AppLog.instance.put('使用降级规则: $fallbackChapterListRule');
          }
        }

        // 如果找到了降级规则，创建临时规则对象
        if (fallbackChapterListRule != null) {
          effectiveTocRule = TocRule(
            chapterList: fallbackChapterListRule,
            chapterName: source.ruleToc?.chapterName ?? 'tag.a@text',
            chapterUrl: source.ruleToc?.chapterUrl ?? 'tag.a@href',
            isVip: source.ruleToc?.isVip,
            isVolume: source.ruleToc?.isVolume, // 保留卷名规则
            updateTime: source.ruleToc?.updateTime,
            nextTocUrl: source.ruleToc?.nextTocUrl,
          );
        }
      }

      // 参考项目：BookChapterList.analyzeChapterList
      // 处理 chapterList 规则的前缀（参考项目第51-58行）
      var reverse = false;
      var listRule = effectiveTocRule?.chapterList ?? '';
      if (listRule.startsWith('-')) {
        reverse = true;
        listRule = listRule.substring(1);
        AppLog.instance.put('检测到 - 前缀，将反转章节列表');
      }
      if (listRule.startsWith('+')) {
        listRule = listRule.substring(1);
        AppLog.instance.put('检测到 + 前缀，已移除');
      }

      // 如果规则被修改，更新 effectiveTocRule
      if (listRule != effectiveTocRule?.chapterList) {
        effectiveTocRule = TocRule(
          chapterList: listRule,
          chapterName: effectiveTocRule?.chapterName,
          chapterUrl: effectiveTocRule?.chapterUrl,
          isVip: effectiveTocRule?.isVip,
          isVolume: effectiveTocRule?.isVolume,
          updateTime: effectiveTocRule?.updateTime,
          nextTocUrl: effectiveTocRule?.nextTocUrl,
          formatJs: effectiveTocRule?.formatJs,
          preUpdateJs: effectiveTocRule?.preUpdateJs,
        );
      }

      // 参考项目：第一次调用 analyzeChapterList，返回章节列表和下一页URL列表
      final firstPageResult = await RuleParser.parseTocRuleWithNextUrl(
        html,
        effectiveTocRule,
        variables: chapterVariables,
        baseUrl: effectiveBaseUrl,
        getNextUrl: true,
      );

      var allChapterList = <Map<String, String?>>[];
      allChapterList
          .addAll(firstPageResult['chapterList'] as List<Map<String, String?>>);
      var nextUrlList =
          List<String>.from(firstPageResult['nextUrlList'] as List);

      // 过滤掉与当前URL相同的URL
      nextUrlList =
          nextUrlList.where((url) => url.isNotEmpty && url != tocUrl).toList();

      // 参考项目：根据 nextUrlList.size 决定处理方式
      // size == 0: 不处理分页
      // size == 1: 循环获取下一页
      // size > 1: 并发处理所有URL
      if (loadAllPages && nextUrlList.isEmpty) {
        final ajaxChapters = await _loadAjaxTocPages(
          tocUrl: tocUrl,
          firstPageHtml: html,
          source: source,
          seedChapters: allChapterList,
        );
        if (ajaxChapters.isNotEmpty) {
          allChapterList.addAll(ajaxChapters);
        }

        final implicitChapters = await _loadImplicitTocPages(
          tocUrl: tocUrl,
          source: source,
          tocRule: effectiveTocRule!,
          seedChapters: allChapterList,
          variables: chapterVariables,
        );
        if (implicitChapters.isNotEmpty) {
          allChapterList.addAll(implicitChapters);
        }
      } else if (loadAllPages && nextUrlList.length == 1) {
        // 参考项目：循环获取下一页，直到没有下一页或已访问过
        var currentUrl = nextUrlList[0];
        var visitedUrls = <String>{tocUrl, currentUrl};
        var pageCount = 1;
        const maxPages = 100; // 防止无限循环

        while (pageCount < maxPages) {
          pageCount++;

          try {
            final pageResponse = await _networkService.get(
              currentUrl,
              headers: NetworkService.parseHeaders(source.header),
              retryCount: 1,
            );
            final pageHtml = await NetworkService.getResponseText(pageResponse);

            if (pageHtml.isEmpty) {
              break;
            }

            // 解析当前页的章节列表和下一页URL
            final pageResult = await RuleParser.parseTocRuleWithNextUrl(
              pageHtml,
              effectiveTocRule,
              variables: chapterVariables,
              baseUrl: currentUrl,
              getNextUrl: true,
            );

            final pageChapterList =
                pageResult['chapterList'] as List<Map<String, String?>>;
            final pageNextUrlList =
                List<String>.from(pageResult['nextUrlList'] as List);

            allChapterList.addAll(pageChapterList);

            // 获取下一页URL（过滤掉已访问的URL）
            final filteredNextUrls = pageNextUrlList
                .where((url) =>
                    url.isNotEmpty &&
                    url != currentUrl &&
                    !visitedUrls.contains(url))
                .toList();

            if (filteredNextUrls.isEmpty) {
              break;
            }

            currentUrl = filteredNextUrls[0];
            visitedUrls.add(currentUrl);
          } catch (e) {
            AppLog.instance.put('获取第 $pageCount 页失败: $e', error: e);
            break;
          }
        }
      } else if (loadAllPages) {
        // 参考项目：并发处理所有URL
        try {
          // 并发处理所有URL
          final futures = nextUrlList.map((url) async {
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

          // 分别解析每个URL的章节列表，然后合并
          for (final result in results) {
            if (result['success'] == true &&
                (result['html'] as String).isNotEmpty) {
              final pageHtml = result['html'] as String;
              final pageUrl = result['url'] as String;

              final pageResult = await RuleParser.parseTocRuleWithNextUrl(
                pageHtml,
                effectiveTocRule,
                variables: chapterVariables,
                baseUrl: pageUrl,
                getNextUrl: false, // 并发处理时不需要获取下一页URL
              );

              final pageChapterList =
                  pageResult['chapterList'] as List<Map<String, String?>>;
              allChapterList.addAll(pageChapterList);
            }
          }
        } catch (e) {
          AppLog.instance.put('并发处理异常: $e', error: e);
        }
      }

      var chapterList = allChapterList;

      // 参考项目：转换为BookChapter对象（参考项目第217-256行）
      // 参考项目不过滤"最新章节"，保留所有解析到的章节
      var chapters = <BookChapter>[];
      for (int i = 0; i < chapterList.length; i++) {
        final chapterData = chapterList[i];
        final chapterName = chapterData['chapterName'] ?? '';
        final isVolumeStr = chapterData['isVolume'] ?? '0';
        final isVolume =
            isVolumeStr == '1' || isVolumeStr.toLowerCase() == 'true';
        final chapterUrl = chapterData['chapterUrl'];

        // 参考项目逻辑：
        // 1. 卷名（isVolume）不需要URL，即使URL为空也会添加
        // 2. 非卷名章节必须有URL
        if (!isVolume && (chapterUrl == null || chapterUrl.isEmpty)) {
          continue;
        }

        // 过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接）
        final trimmedName = chapterName.trim().replaceAll(RegExp(r'\s+'), '');
        if (chapterName.contains('上一页') ||
            chapterName.contains('下一页') ||
            chapterName.contains('上一章') ||
            chapterName.contains('下一章') ||
            trimmedName.isEmpty) {
          continue;
        }

        // 参考项目：构建章节URL（参考项目第222-243行）
        // 参考项目保存的是解析出来的原始URL，在getAbsoluteURL()中转换
        // 为了兼容性，我们这里仍然拼接为绝对URL，但不做额外规范化
        String finalUrl = '';
        if (chapterUrl != null && chapterUrl.isNotEmpty) {
          // 参考项目：bookChapter.url = analyzeRule.getString(urlRule)
          // 拼接为绝对URL，但不做额外规范化处理
          finalUrl = _repairChapterUrlWithBookVariables(
            NetworkService.joinUrl(effectiveBaseUrl, chapterUrl),
            book,
          );
        } else {
          // 参考项目：如果 URL 为空，根据是否是卷名来设置
          if (isVolume) {
            // 参考项目：如果是卷名且URL为空，使用标题+索引作为URL
            finalUrl = '$chapterName$i';
          } else {
            // 参考项目：非卷名但URL为空，使用baseUrl替代
            finalUrl = effectiveBaseUrl;
          }
        }

        // 参考项目：章节标题直接使用原始标题
        final chapterTitle =
            chapterName.isNotEmpty ? chapterName : '第${i + 1}章';

        final chapter = BookChapter(
          url: finalUrl,
          title: chapterTitle,
          bookUrl: book.bookUrl,
          baseUrl: source.bookSourceUrl,
          index: chapters.length, // 使用过滤后的索引
          isVolume: isVolume, // 设置卷名标志
          isVip: chapterData['isVip'] == 'true' || chapterData['isVip'] == '1',
          tag: chapterData['updateTime'],
          duration:
              _parseDurationString(chapterData['duration']), // Phase 3：音视频时长
        );

        chapters.add(chapter);
      }

      final previewCount = chapters.length < 5 ? chapters.length : 5;
      for (int i = 0; i < previewCount; i++) {
        final chapter = chapters[i];
        AppLog.instance.put(
          '目录预览 ${i + 1}: title=${chapter.title}, url=${chapter.url}',
        );
      }

      // 参考项目：如果章节列表为空，抛出异常
      if (chapters.isEmpty) {
        throw TocEmptyException('章节列表为空');
      }

      // 参考项目：反转逻辑（参考项目第119-120行）
      // 如果 !reverse，反转章节列表
      if (!reverse) {
        chapters = chapters.reversed.toList();
      }

      // 去重：保留第一个发现的章节
      // LinkedHashSet 保留第一次出现的元素
      final originalCount = chapters.length;
      chapters = LinkedHashSet<BookChapter>.from(chapters).toList();
      if (chapters.length < originalCount) {
        AppLog.instance
            .put('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）');
        final urlCounts = <String, int>{};
        for (final chapter in chapters.length == originalCount
            ? chapters
            : chapterList.map((item) {
                final title = item['chapterName'] ?? '';
                final url = item['chapterUrl'] ?? '';
                return BookChapter(
                    url: url, title: title, bookUrl: book.bookUrl);
              })) {
          urlCounts[chapter.url] = (urlCounts[chapter.url] ?? 0) + 1;
        }
        final duplicates =
            urlCounts.entries.where((entry) => entry.value > 1).take(5);
        for (final entry in duplicates) {
          AppLog.instance.put(
            '重复章节URL: url=${entry.key}, count=${entry.value}',
          );
        }
      }

      // 参考项目：如果 !book.getReverseToc()，再次反转列表（参考项目第126-128行）
      if (!book.getReverseToc()) {
        chapters = chapters.reversed.toList();
        AppLog.instance.put('反转章节列表（!book.getReverseToc()）');
      }

      // 重新设置索引
      for (int i = 0; i < chapters.length; i++) {
        chapters[i] = chapters[i].copyWith(index: i);
      }

      // 参考项目：formatJs 格式化章节标题
      final formatJs = effectiveTocRule?.formatJs;
      if (formatJs != null && formatJs.isNotEmpty) {
        AppLog.instance.put('使用 formatJs 格式化章节标题');
        try {
          for (int i = 0; i < chapters.length; i++) {
            final chapter = chapters[i];
            final bindings = <String, dynamic>{
              'gInt': 0,
              'index': i + 1, // 参考项目：index 从 1 开始
              'chapter': {
                'title': chapter.title,
                'url': chapter.url,
                'index': chapter.index,
              },
              'title': chapter.title,
            };
            final result = await JSEngine.evalJS(formatJs, bindings: bindings);
            if (result != null && result.toString().isNotEmpty) {
              chapters[i] = chapter.copyWith(title: result.toString());
              AppLog.instance.put(
                  '格式化章节 ${i + 1}: ${chapter.title} -> ${result.toString()}');
            }
          }
        } catch (e) {
          AppLog.instance.put('格式化标题出错: $e', error: e);
        }
      }

      // 参考项目：更新书籍信息（参考项目第154-164行）
      // 获取替换规则处理器
      final contentProcessor = ContentProcessor.get(book);

      // 更新 durChapterTitle（参考项目第154行）
      if (chapters.isNotEmpty) {
        final currentChapterIndex = book.durChapterIndex;
        if (currentChapterIndex >= 0 && currentChapterIndex < chapters.length) {
          final currentChapter = chapters[currentChapterIndex];
          final displayTitle = await contentProcessor.getDisplayTitle(
            currentChapter,
            useReplace: book.getUseReplaceRule(),
          );
          book.durChapterTitle = displayTitle;
        } else if (chapters.isNotEmpty) {
          // 如果索引超出范围，使用最后一个章节
          final lastChapter = chapters.last;
          final displayTitle = await contentProcessor.getDisplayTitle(
            lastChapter,
            useReplace: book.getUseReplaceRule(),
          );
          book.durChapterTitle = displayTitle;
        }
      }

      // 更新 lastCheckCount 和 latestChapterTime（参考项目第156-158行）
      if (book.totalChapterNum < chapters.length) {
        book.lastCheckCount = chapters.length - book.totalChapterNum;
        book.latestChapterTime = DateTime.now().millisecondsSinceEpoch;
      }

      // 更新 lastCheckTime 和 totalChapterNum（参考项目第160-161行）
      book.lastCheckTime = DateTime.now().millisecondsSinceEpoch;
      book.totalChapterNum = chapters.length;

      // 更新 latestChapterTitle（参考项目第162-164行）
      if (chapters.isNotEmpty) {
        final simulatedIndex = book.simulatedTotalChapterNum() - 1;
        final latestChapterIndex =
            simulatedIndex >= 0 && simulatedIndex < chapters.length
                ? simulatedIndex
                : chapters.length - 1;
        final latestChapter = chapters[latestChapterIndex];
        final displayTitle = await contentProcessor.getDisplayTitle(
          latestChapter,
          useReplace: book.getUseReplaceRule(),
        );
        book.latestChapterTitle = displayTitle;
      }

      // 参考项目：getWordCount（参考项目第272-286行）
      // 从数据库获取已存在的章节字数
      await getWordCount(chapters, book);

      AppLog.instance.put('获取章节列表成功: 共 ${chapters.length} 个章节');

      // 保存章节列表到数据库
      await saveChapters(chapters);

      // 更新书籍信息到数据库
      try {
        await updateBook(book);
      } catch (e) {
        AppLog.instance.put('更新书籍信息失败: $e', error: e);
      }

      return chapters;
    } catch (e, stackTrace) {
      AppLog.instance.put('获取章节列表失败', error: e);
      AppLog.instance.put('错误堆栈: $stackTrace');
      // 如果获取失败，尝试从数据库读取
      return await _getLocalChapters(book.bookUrl);
    }
  }

  /// 获取章节列表但不保存到数据库（用于探索页面）
  Future<List<BookChapter>> getChapterListWithoutSave(
    Book book, {
    bool loadAllPages = true,
  }) async {
    if (book.isLocal) {
      // 本地书籍从数据库读取章节
      return await _getLocalChapters(book.bookUrl);
    }

    final source = await _bookSourceService.getBookSourceByUrl(book.origin);
    if (source == null) {
      AppLog.instance.put('获取章节列表失败: 书源不存在 (origin: ${book.origin})');
      return [];
    }

    if (source.ruleToc == null) {
      AppLog.instance.put('获取章节列表失败: 目录规则为空 (书源: ${source.bookSourceName})');
      return [];
    }

    try {
      final chapterVariables = _buildRuleVariables(book);
      // 使用tocUrl或bookUrl
      final tocUrl = book.tocUrl.isNotEmpty ? book.tocUrl : book.bookUrl;
      AppLog.instance.put('开始获取章节列表: tocUrl=$tocUrl, bookUrl=${book.bookUrl}');

      // 发送请求
      final response = await _networkService.get(
        tocUrl,
        headers: NetworkService.parseHeaders(source.header),
        retryCount: 1,
      );

      final html = await NetworkService.getResponseText(response);
      AppLog.instance
          .put('获取章节列表响应: 状态码=${response.statusCode}, 内容长度=${html.length}');

      if (html.isEmpty) {
        AppLog.instance.put('获取章节列表失败: 响应内容为空');
        throw TocEmptyException('获取章节列表失败: 响应内容为空');
      }

      // 检查HTML中是否包含可能的目录容器
      AppLog.instance.put(
          '检查HTML结构: 是否包含id="list": ${html.contains('id="list"') || html.contains("id='list'")}');
      AppLog.instance.put(
          '检查HTML结构: 是否包含class="list": ${html.contains('class="list"') || html.contains("class='list'")}');
      AppLog.instance.put(
          '检查HTML结构: 是否包含<dd>标签: ${html.contains('<dd>') || html.contains('<DD>')}');

      // 查找所有可能的目录相关元素
      final listIdPattern = RegExp('id\\s*=\\s*["\']([^"\']*list[^"\']*)["\']',
          caseSensitive: false);
      final listIds = listIdPattern
          .allMatches(html)
          .map((m) => m.group(1))
          .whereType<String>()
          .take(5)
          .toList();
      if (listIds.isNotEmpty) {
        AppLog.instance.put('HTML中找到包含"list"的id: ${listIds.join(", ")}');
      }

      final listClassPattern = RegExp(
          'class\\s*=\\s*["\']([^"\']*list[^"\']*)["\']',
          caseSensitive: false);
      final listClasses = listClassPattern
          .allMatches(html)
          .map((m) => m.group(1))
          .whereType<String>()
          .take(5)
          .toList();
      if (listClasses.isNotEmpty) {
        AppLog.instance.put('HTML中找到包含"list"的class: ${listClasses.join(", ")}');
      }

      // 解析章节列表
      // 参考项目：baseUrl使用tocUrl（实际请求的URL），而不是书源的基础URL
      AppLog.instance.put(
          '开始解析章节列表: ruleToc=${source.ruleToc?.toJson()}, chapterList规则=${source.ruleToc?.chapterList}');

      // 确定有效的baseUrl：如果tocUrl不是有效的绝对URL，使用source.bookSourceUrl
      String? effectiveBaseUrl = tocUrl;
      if (!tocUrl.isAbsUrl()) {
        // 如果source.bookSourceUrl也是有效的绝对URL，使用它；否则尝试从tocUrl构建
        if (source.bookSourceUrl.isAbsUrl()) {
          effectiveBaseUrl = source.bookSourceUrl;
          AppLog.instance.put(
              'tocUrl不是绝对URL，使用source.bookSourceUrl作为baseUrl: $effectiveBaseUrl');
        } else {
          // 如果两者都不是绝对URL，尝试从tocUrl构建完整的URL
          // 如果tocUrl是相对路径，使用source.bookSourceUrl作为基础
          try {
            effectiveBaseUrl =
                NetworkService.joinUrl(source.bookSourceUrl, tocUrl);
            if (!effectiveBaseUrl.isAbsUrl()) {
              // 如果仍然无效，使用source.bookSourceUrl
              effectiveBaseUrl = source.bookSourceUrl;
            }
            AppLog.instance.put(
                'tocUrl和source.bookSourceUrl都不是绝对URL，尝试拼接后: $effectiveBaseUrl');
          } catch (e) {
            AppLog.instance.put(
                '构建baseUrl失败: $e，使用source.bookSourceUrl: ${source.bookSourceUrl}');
            effectiveBaseUrl = source.bookSourceUrl;
          }
        }
      }

      // 最终验证：确保effectiveBaseUrl是有效的绝对URL
      if (!effectiveBaseUrl.isAbsUrl()) {
        AppLog.instance
            .put('警告: effectiveBaseUrl仍然无效: $effectiveBaseUrl，将尝试继续解析但可能失败');
      }

      // 首先尝试使用原始规则获取第一页，如果失败则使用降级规则
      TocRule? effectiveTocRule = source.ruleToc;
      String? fallbackChapterListRule;

      // 检查原始规则是否能匹配到章节
      var testChapterList = RuleParser.parseTocRule(
        html,
        source.ruleToc,
        baseUrl: effectiveBaseUrl,
      );

      if (testChapterList.isEmpty && source.ruleToc?.chapterList != null) {
        AppLog.instance.put('原始规则未匹配到章节，尝试智能降级处理');

        // 查找降级规则
        final chapterLinkPattern = RegExp(
            '<a[^>]*href=["\']/[^"\']*\\.html["\'][^>]*>.*?</a>',
            caseSensitive: false,
            dotAll: true);
        final chapterLinkMatches = chapterLinkPattern.allMatches(html).toList();

        if (chapterLinkMatches.isNotEmpty) {
          AppLog.instance
              .put('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器');

          html_dom.Element? directoryContainer;
          String? containerClass;
          String? containerId;

          // 首先尝试查找directoryArea容器
          final doc = html_parser.parse(html);
          final directoryPattern = RegExp(
              'class\\s*=\\s*["\'][^"\']*directory[^"\']*["\']',
              caseSensitive: false);
          final directoryMatches = directoryPattern.allMatches(html);
          if (directoryMatches.isNotEmpty) {
            final match = directoryMatches.first;
            final matchHtml = html.substring(match.start, match.end);
            final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',
                caseSensitive: false);
            final classMatch = classPattern.firstMatch(matchHtml);
            if (classMatch != null) {
              final allClasses =
                  classMatch.group(1)?.split(RegExp(r'\s+')) ?? [];
              final dirClass = allClasses.firstWhere(
                (c) => c.contains('directory'),
                orElse: () => '',
              );
              if (dirClass.isNotEmpty) {
                directoryContainer =
                    HtmlParser.selectElement(doc, 'div.$dirClass');
                containerClass = dirClass;
                AppLog.instance.put('找到directory容器: class=$containerClass');
              }
            }
          }

          // 如果找到了directory容器，提取其class或id用于生成降级规则
          if (directoryContainer != null) {
            final dirClassAttr = directoryContainer.attributes['class'];
            final dirIdAttr = directoryContainer.attributes['id'];
            if (dirClassAttr != null && dirClassAttr.contains('directory')) {
              final allClasses = dirClassAttr.split(RegExp(r'\s+'));
              final dirClass = allClasses.firstWhere(
                (c) => c.contains('directory'),
                orElse: () => allClasses.first,
              );
              containerClass = dirClass;
              AppLog.instance.put('从directory容器提取class: $containerClass');
            }
            if (dirIdAttr != null) {
              containerId = dirIdAttr;
              AppLog.instance.put('从directory容器提取id: $containerId');
            }
          }

          // 生成降级规则
          if (containerClass != null) {
            fallbackChapterListRule = 'class.$containerClass@tag.a';
            AppLog.instance.put('使用降级规则: $fallbackChapterListRule');
          }
        }

        // 如果找到了降级规则，创建临时规则对象
        if (fallbackChapterListRule != null) {
          effectiveTocRule = TocRule(
            chapterList: fallbackChapterListRule,
            chapterName: source.ruleToc?.chapterName ?? 'tag.a@text',
            chapterUrl: source.ruleToc?.chapterUrl ?? 'tag.a@href',
            isVip: source.ruleToc?.isVip,
            isVolume: source.ruleToc?.isVolume, // 保留卷名规则
            updateTime: source.ruleToc?.updateTime,
            nextTocUrl: source.ruleToc?.nextTocUrl,
          );
        }
      }

      var allChapterList = <Map<String, String?>>[];
      var pageCount = 1;
      if (effectiveTocRule != null) {
        final firstPageResult = await RuleParser.parseTocRuleWithNextUrl(
          html,
          effectiveTocRule,
          variables: chapterVariables,
          baseUrl: tocUrl,
          getNextUrl: true,
        );
        final firstPageChapterList =
            firstPageResult['chapterList'] as List<Map<String, String?>>;
        AppLog.instance.put('第 1 页解析结果: 找到 ${firstPageChapterList.length} 个章节');
        allChapterList.addAll(firstPageChapterList);
      }

      if (loadAllPages) {
        var currentUrl = tocUrl;
        var visitedUrls = <String>{currentUrl};
        const maxPages = 100; // 防止无限循环

        while (pageCount < maxPages && effectiveTocRule != null) {
          String pageHtml = html;
          if (pageCount > 1) {
            final pageResponse = await _networkService.get(
              currentUrl,
              headers: NetworkService.parseHeaders(source.header),
              retryCount: 1,
            );
            pageHtml = await NetworkService.getResponseText(pageResponse);
            if (pageHtml.isEmpty) {
              AppLog.instance.put('第 $pageCount 页内容为空，停止获取');
              break;
            }
          }

          List<Map<String, String?>> pageChapterList;
          if (pageCount == 1) {
            pageChapterList = allChapterList;
          } else {
            final pageResult = await RuleParser.parseTocRuleWithNextUrl(
              pageHtml,
              effectiveTocRule,
              variables: chapterVariables,
              baseUrl: currentUrl,
              getNextUrl: true,
            );
            pageChapterList =
                pageResult['chapterList'] as List<Map<String, String?>>;
            AppLog.instance
                .put('第 $pageCount 页解析结果: 找到 ${pageChapterList.length} 个章节');
            allChapterList.addAll(pageChapterList);
          }

          String? nextUrl;
          if (effectiveTocRule.nextTocUrl != null &&
              effectiveTocRule.nextTocUrl!.isNotEmpty) {
            AppLog.instance
                .put('尝试使用nextTocUrl规则获取下一页: ${effectiveTocRule.nextTocUrl}');

            List<String> nextUrlList;
            if (effectiveTocRule.nextTocUrl!.contains('@')) {
              nextUrlList = RuleParser.parseListRule(
                pageHtml,
                effectiveTocRule.nextTocUrl!,
                variables: chapterVariables,
                baseUrl: currentUrl,
                returnHtml: false,
              );
            } else {
              final linkHtmlList = RuleParser.parseListRule(
                pageHtml,
                effectiveTocRule.nextTocUrl!,
                variables: chapterVariables,
                baseUrl: currentUrl,
                returnHtml: true,
              );

              nextUrlList = [];
              for (final linkHtml in linkHtmlList) {
                final hrefPattern = RegExp(
                  'href\\s*=\\s*["\']([^"\']+)["\']',
                  caseSensitive: false,
                );
                final match = hrefPattern.firstMatch(linkHtml);
                if (match != null) {
                  final href = match.group(1);
                  if (href != null && href.isNotEmpty) {
                    nextUrlList.add(href);
                  }
                }
              }
            }

            final filteredUrls = nextUrlList
                .where((url) => url.isNotEmpty && url != currentUrl)
                .map((url) => NetworkService.joinUrl(currentUrl, url))
                .where((url) => url != currentUrl && !visitedUrls.contains(url))
                .toList();

            AppLog.instance
                .put('nextTocUrl规则解析结果: 找到 ${filteredUrls.length} 个URL');

            if (filteredUrls.isNotEmpty) {
              if (filteredUrls.length == 1) {
                nextUrl = filteredUrls[0];
              } else {
                try {
                  final futures = filteredUrls.map((url) async {
                    try {
                      final response = await _networkService.get(
                        url,
                        headers: NetworkService.parseHeaders(source.header),
                        retryCount: 1,
                      );
                      final html =
                          await NetworkService.getResponseText(response);
                      return {'url': url, 'html': html, 'success': true};
                    } catch (e) {
                      return {'url': url, 'html': '', 'success': false};
                    }
                  }).toList();

                  final results = await Future.wait(futures);
                  final allHtml = results
                      .where((r) =>
                          r['success'] == true &&
                          (r['html'] as String).isNotEmpty)
                      .map((r) => r['html'] as String)
                      .join('\n');

                  if (allHtml.isNotEmpty) {
                    pageHtml = allHtml;
                    nextUrl = null;
                  } else {
                    nextUrl = filteredUrls[0];
                  }
                } catch (e) {
                  nextUrl = filteredUrls[0];
                }
              }
            }
          }

          if (nextUrl == null || nextUrl.isEmpty) {
            for (int i = 0; i < pageChapterList.length; i++) {
              final chapterData = pageChapterList[i];
              final chapterNextUrl = chapterData['nextTocUrl'];
              if (chapterNextUrl != null && chapterNextUrl.isNotEmpty) {
                nextUrl = NetworkService.joinUrl(currentUrl, chapterNextUrl);
                break;
              }
            }
          }

          if (nextUrl == null || nextUrl.isEmpty) {
            try {
              final nextPagePattern = RegExp(
                '<a[^>]*href=["\']([^"\']+)["\'][^>]*>.*?(?:下一页|下页|next|Next|NEXT)[^<]*</a>',
                caseSensitive: false,
                dotAll: true,
              );
              final match = nextPagePattern.firstMatch(pageHtml);
              if (match != null) {
                final href = match.group(1);
                if (href != null && href.isNotEmpty) {
                  nextUrl = NetworkService.joinUrl(currentUrl, href);
                }
              }
            } catch (e) {
              AppLog.instance.put('自动查找"下一页"链接失败', error: e);
            }
          }

          if (nextUrl == null ||
              nextUrl.isEmpty ||
              visitedUrls.contains(nextUrl)) {
            break;
          }

          visitedUrls.add(nextUrl);
          currentUrl = nextUrl;
          pageCount++;
          AppLog.instance.put('找到下一页URL: $nextUrl，继续获取第 $pageCount 页');
        }

        if (pageCount == 1 && effectiveTocRule != null) {
          final ajaxChapters = await _loadAjaxTocPages(
            tocUrl: tocUrl,
            firstPageHtml: html,
            source: source,
            seedChapters: allChapterList,
          );
          if (ajaxChapters.isNotEmpty) {
            allChapterList.addAll(ajaxChapters);
          }

          final implicitChapters = await _loadImplicitTocPages(
            tocUrl: tocUrl,
            source: source,
            tocRule: effectiveTocRule,
            seedChapters: allChapterList,
            variables: chapterVariables,
          );
          if (implicitChapters.isNotEmpty) {
            allChapterList.addAll(implicitChapters);
          }
        }
      }

      AppLog.instance
          .put('目录获取完成: 共 $pageCount 页，总计 ${allChapterList.length} 个章节');
      var chapterList = allChapterList;

      // 如果仍然没有章节，尝试其他降级规则（保留原有逻辑作为最后手段）
      if (chapterList.isEmpty && source.ruleToc?.chapterList != null) {
        AppLog.instance.put('原始规则未匹配到章节，尝试智能降级处理');

        // 尝试查找包含章节链接的容器
        // 使用普通字符串而不是原始字符串，以便正确处理字符类中的引号
        final chapterLinkPattern = RegExp(
            '<a[^>]*href=["\']/[^"\']*\\.html["\'][^>]*>.*?</a>',
            caseSensitive: false,
            dotAll: true);
        final chapterLinkMatches = chapterLinkPattern.allMatches(html).toList();

        if (chapterLinkMatches.isNotEmpty) {
          AppLog.instance
              .put('找到 ${chapterLinkMatches.length} 个可能的章节链接，尝试查找容器');

          // 查找真正的目录开始位置（跳过前几个可能是最新章节的链接）
          // 从第7个链接开始查找，这些应该是真正的目录章节
          html_dom.Element? directoryContainer;
          String? containerClass;
          String? containerId;
          String? containerTag;

          // 首先尝试查找directoryArea容器
          final doc = html_parser.parse(html);
          final directoryPattern = RegExp(
              'class\\s*=\\s*["\'][^"\']*directory[^"\']*["\']',
              caseSensitive: false);
          final directoryMatches = directoryPattern.allMatches(html);
          if (directoryMatches.isNotEmpty) {
            final match = directoryMatches.first;
            final matchHtml = html.substring(match.start, match.end);
            final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',
                caseSensitive: false);
            final classMatch = classPattern.firstMatch(matchHtml);
            if (classMatch != null) {
              final allClasses =
                  classMatch.group(1)?.split(RegExp(r'\s+')) ?? [];
              final dirClass = allClasses.firstWhere(
                (c) => c.contains('directory'),
                orElse: () => '',
              );
              if (dirClass.isNotEmpty) {
                directoryContainer =
                    HtmlParser.selectElement(doc, 'div.$dirClass');
                containerClass = dirClass;
                containerTag = 'div';
                AppLog.instance.put('找到directory容器: class=$containerClass');
              }
            }
          }

          // 如果没有找到directory容器，从第7个链接开始查找容器
          if (directoryContainer == null && chapterLinkMatches.length >= 7) {
            // 从第7个链接开始查找容器
            final chapterStartMatch = chapterLinkMatches[6]; // 第7个链接（索引6）
            final beforeHtml = html.substring(0, chapterStartMatch.start);

            // 查找最近的容器开始标签（div, ul, ol, dl, section等）
            final containerStartPattern =
                RegExp(r'<(div|ul|ol|dl|section)[^>]*>', caseSensitive: false);
            final containerStarts =
                containerStartPattern.allMatches(beforeHtml).toList();

            if (containerStarts.isNotEmpty) {
              final lastContainerStart = containerStarts.last;
              containerTag = lastContainerStart.group(1);
              final containerStartPos = lastContainerStart.start;

              // 提取容器的class或id属性
              final containerHtml =
                  html.substring(containerStartPos, lastContainerStart.end);
              final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',
                  caseSensitive: false);
              final idPattern = RegExp('id\\s*=\\s*["\']([^"\']+)["\']',
                  caseSensitive: false);
              final classMatch = classPattern.firstMatch(containerHtml);
              final idMatch = idPattern.firstMatch(containerHtml);

              containerClass =
                  classMatch?.group(1)?.split(RegExp(r'\s+')).first;
              containerId = idMatch?.group(1);

              // 如果容器class包含directory，尝试查找该容器
              if (containerClass != null &&
                  containerClass.contains('directory')) {
                directoryContainer =
                    HtmlParser.selectElement(doc, 'div.$containerClass');
                AppLog.instance.put('找到directory容器: class=$containerClass');
              } else if (containerId != null) {
                directoryContainer =
                    HtmlParser.selectElement(doc, 'div#$containerId');
                AppLog.instance.put('找到容器: id=$containerId');
              }
            }
          }

          // 如果找到了directory容器，提取其class或id用于生成降级规则
          if (directoryContainer != null) {
            final dirClassAttr = directoryContainer.attributes['class'];
            final dirIdAttr = directoryContainer.attributes['id'];
            if (dirClassAttr != null && dirClassAttr.contains('directory')) {
              final allClasses = dirClassAttr.split(RegExp(r'\s+'));
              final dirClass = allClasses.firstWhere(
                (c) => c.contains('directory'),
                orElse: () => allClasses.first,
              );
              containerClass = dirClass;
              containerTag = 'div';
              AppLog.instance.put('从directory容器提取class: $containerClass');
            }
            if (dirIdAttr != null) {
              containerId = dirIdAttr;
              AppLog.instance.put('从directory容器提取id: $containerId');
            }
          }

          // 如果还没有找到容器，使用第一个章节链接的容器
          if (containerClass == null && containerId == null) {
            final firstChapterLink = chapterLinkMatches.first;
            final beforeHtml = html.substring(0, firstChapterLink.start);

            // 查找最近的容器开始标签（div, ul, ol, dl, section等）
            final containerStartPattern =
                RegExp(r'<(div|ul|ol|dl|section)[^>]*>', caseSensitive: false);
            final containerStarts =
                containerStartPattern.allMatches(beforeHtml).toList();

            if (containerStarts.isNotEmpty) {
              final lastContainerStart = containerStarts.last;
              containerTag = lastContainerStart.group(1);
              final containerStartPos = lastContainerStart.start;

              // 提取容器的class或id属性
              final containerHtml =
                  html.substring(containerStartPos, lastContainerStart.end);
              final classPattern = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',
                  caseSensitive: false);
              final idPattern = RegExp('id\\s*=\\s*["\']([^"\']+)["\']',
                  caseSensitive: false);
              final classMatch = classPattern.firstMatch(containerHtml);
              final idMatch = idPattern.firstMatch(containerHtml);

              containerClass =
                  classMatch?.group(1)?.split(RegExp(r'\s+')).first;
              containerId = idMatch?.group(1);

              AppLog.instance.put(
                  '找到容器: <$containerTag>${containerClass != null ? ' class="$containerClass"' : ''}${containerId != null ? ' id="$containerId"' : ''}');
            }
          }

          // 使用找到的容器信息生成降级规则
          String? finalContainerClass = containerClass;
          String? finalContainerId = containerId;
          String? finalContainerTag = containerTag;

          if (directoryContainer == null) {
            // 如果没有找到directory容器，尝试从第一个章节链接查找容器
            final firstChapterLink = chapterLinkMatches.first;
            final beforeHtml = html.substring(0, firstChapterLink.start);

            // 查找最近的容器开始标签（div, ul, ol, dl, section等）
            final containerStartPattern =
                RegExp(r'<(div|ul|ol|dl|section)[^>]*>', caseSensitive: false);
            final containerStarts =
                containerStartPattern.allMatches(beforeHtml).toList();

            if (containerStarts.isNotEmpty) {
              final lastContainerStart = containerStarts.last;
              finalContainerTag = lastContainerStart.group(1);
              final containerStartPos = lastContainerStart.start;

              // 提取容器的class或id属性
              final containerHtml =
                  html.substring(containerStartPos, lastContainerStart.end);
              // 使用普通字符串而不是原始字符串，以便正确处理字符类中的引号
              final classPattern2 = RegExp('class\\s*=\\s*["\']([^"\']+)["\']',
                  caseSensitive: false);
              final idPattern2 = RegExp('id\\s*=\\s*["\']([^"\']+)["\']',
                  caseSensitive: false);
              final classMatch2 = classPattern2.firstMatch(containerHtml);
              final idMatch2 = idPattern2.firstMatch(containerHtml);

              finalContainerClass =
                  classMatch2?.group(1)?.split(RegExp(r'\s+')).first;
              finalContainerId = idMatch2?.group(1);

              AppLog.instance.put(
                  '找到容器: <$finalContainerTag>${finalContainerClass != null ? ' class="$finalContainerClass"' : ''}${finalContainerId != null ? ' id="$finalContainerId"' : ''}');
            }
          } else {
            // 如果找到了directory容器，使用它的信息
            finalContainerTag = 'div';
            AppLog.instance.put(
                '使用directory容器: class=$finalContainerClass, id=$finalContainerId');
          }

          // 生成降级规则并尝试
          if (finalContainerClass != null ||
              finalContainerId != null ||
              finalContainerTag != null) {
            final fallbackRules = <String>[];

            if (finalContainerId != null) {
              // 如果容器有id，尝试使用id选择器
              fallbackRules.add('id.$finalContainerId@tag.a');
              fallbackRules.add('id.$finalContainerId@tag.p');
              fallbackRules.add('id.$finalContainerId@tag.li');
              fallbackRules.add('id.$finalContainerId@tag.dd');
            }

            if (finalContainerClass != null) {
              // 如果容器有class，尝试使用class选择器
              fallbackRules.add('class.$finalContainerClass@tag.a');
              fallbackRules.add('class.$finalContainerClass@tag.p');
              fallbackRules.add('class.$finalContainerClass@tag.li');
              fallbackRules.add('class.$finalContainerClass@tag.dd');
            }

            // 尝试直接选择容器内的链接（使用CSS选择器格式）
            if (finalContainerTag != null) {
              if (finalContainerClass != null) {
                fallbackRules.add('$finalContainerTag.$finalContainerClass a');
              }
              if (finalContainerId != null) {
                fallbackRules.add('$finalContainerTag#$finalContainerId a');
              }
              fallbackRules.add('$finalContainerTag a');
            }

            // 尝试每个降级规则
            for (final fallbackRule in fallbackRules) {
              AppLog.instance.put('尝试降级规则: $fallbackRule');

              // 创建临时规则对象
              final fallbackTocRule = TocRule(
                chapterList: fallbackRule,
                chapterName: source.ruleToc?.chapterName ?? 'tag.a@text',
                chapterUrl: source.ruleToc?.chapterUrl ?? 'tag.a@href',
                isVip: source.ruleToc?.isVip,
                updateTime: source.ruleToc?.updateTime,
                nextTocUrl: source.ruleToc?.nextTocUrl,
              );

              final fallbackChapterList = RuleParser.parseTocRule(
                html,
                fallbackTocRule,
                baseUrl: effectiveBaseUrl,
              );

              AppLog.instance.put(
                  '降级规则 $fallbackRule 匹配结果: ${fallbackChapterList.length} 个章节');

              // 如果匹配到的章节数量大于当前结果，使用这个规则
              // 这样可以确保选择匹配到最多章节的规则
              if (fallbackChapterList.length > chapterList.length) {
                AppLog.instance.put('降级规则 $fallbackRule 匹配到更多章节，使用此规则');
                chapterList = fallbackChapterList;
                // 如果匹配到的章节数量足够多（比如超过10个），可以认为这是正确的规则
                if (fallbackChapterList.length >= 10) {
                  AppLog.instance.put(
                      '降级规则 $fallbackRule 匹配到足够多的章节（${fallbackChapterList.length}个），停止尝试其他规则');
                  break;
                }
              }
            }
          }
        }
      }

      if (chapterList.isEmpty && source.ruleToc?.chapterList != null) {
        AppLog.instance.put('警告: 章节列表为空，但规则不为空。可能是规则不匹配HTML结构。');
        AppLog.instance.put(
            'HTML前2000字符: ${html.substring(0, html.length > 2000 ? 2000 : html.length)}');

        // 尝试查找可能的目录相关元素（用于调试）
        final dlPattern =
            RegExp('<dl[^>]*>.*?</dl>', caseSensitive: false, dotAll: true);
        final dlMatches = dlPattern.allMatches(html);
        AppLog.instance.put('HTML中找到 ${dlMatches.length} 个 <dl> 标签');
        if (dlMatches.isNotEmpty) {
          AppLog.instance.put(
              '第一个<dl>标签内容（前500字符）: ${dlMatches.first.group(0)?.substring(0, dlMatches.first.group(0)!.length > 500 ? 500 : dlMatches.first.group(0)!.length)}');
        }

        final ulPattern =
            RegExp('<ul[^>]*>.*?</ul>', caseSensitive: false, dotAll: true);
        final ulMatches = ulPattern.allMatches(html);
        AppLog.instance.put('HTML中找到 ${ulMatches.length} 个 <ul> 标签');

        final olPattern =
            RegExp('<ol[^>]*>.*?</ol>', caseSensitive: false, dotAll: true);
        final olMatches = olPattern.allMatches(html);
        AppLog.instance.put('HTML中找到 ${olMatches.length} 个 <ol> 标签');

        // 查找所有包含链接的元素（可能是章节链接）
        final linkPattern = RegExp('<a[^>]*href[^>]*>.*?</a>',
            caseSensitive: false, dotAll: true);
        final linkMatches = linkPattern.allMatches(html);
        AppLog.instance.put('HTML中找到 ${linkMatches.length} 个链接');

        // 记录调试信息后，抛出异常
        throw TocEmptyException(
            '章节列表为空: 规则不匹配HTML结构 (书源: ${source.bookSourceName})');
      }

      // 转换为BookChapter对象
      var chapters = <BookChapter>[];
      for (int i = 0; i < chapterList.length; i++) {
        final chapterData = chapterList[i];
        final chapterName = chapterData['chapterName'] ?? '';
        final isVolumeStr = chapterData['isVolume'] ?? '0';
        final isVolume =
            isVolumeStr == '1' || isVolumeStr.toLowerCase() == 'true';
        final chapterUrl = chapterData['chapterUrl'];

        // 参考项目逻辑：
        // 1. 卷名（isVolume）不需要URL，即使URL为空也会添加
        // 2. 非卷名章节必须有URL
        if (!isVolume && (chapterUrl == null || chapterUrl.isEmpty)) {
          AppLog.instance.put('章节 ${i + 1} 缺少URL且不是卷名，跳过');
          continue;
        }

        // 过滤分页链接（参考项目：不添加标题为空的章节，以及分页链接）
        // 过滤包含"上一页"、"下一页"等分页文本的章节
        // 使用更严格的空白检查：去除所有空白字符后检查是否为空
        final trimmedName = chapterName.trim().replaceAll(RegExp(r'\s+'), '');
        if (chapterName.contains('上一页') ||
            chapterName.contains('下一页') ||
            chapterName.contains('上一章') ||
            chapterName.contains('下一章') ||
            trimmedName.isEmpty) {
          AppLog.instance
              .put('过滤分页链接或空标题章节: 原始="$chapterName", 处理后="$trimmedName"');
          continue;
        }

        // 构建章节URL（卷名可能没有URL）
        String finalUrl;
        if (isVolume) {
          // 卷名不需要URL，使用空字符串
          finalUrl = '';
        } else if (chapterUrl != null && chapterUrl.isNotEmpty) {
          // 使用effectiveBaseUrl而不是tocUrl，确保baseUrl是有效的绝对URL
          finalUrl = NetworkService.joinUrl(effectiveBaseUrl, chapterUrl);
        } else {
          // 非卷名但没有URL，跳过（已在上面检查）
          continue;
        }

        final chapter = BookChapter(
          url: finalUrl,
          title: chapterName.isNotEmpty ? chapterName : '第${i + 1}章',
          bookUrl: book.bookUrl,
          baseUrl: source.bookSourceUrl,
          index: chapters.length, // 使用过滤后的索引
          isVolume: isVolume, // 设置卷名标志
          isVip: chapterData['isVip'] == 'true' || chapterData['isVip'] == '1',
          tag: chapterData['updateTime'],
        );

        chapters.add(chapter);
      }

      final previewCount = chapters.length < 5 ? chapters.length : 5;
      for (int i = 0; i < previewCount; i++) {
        final chapter = chapters[i];
        AppLog.instance.put(
          '目录预览 ${i + 1}: title=${chapter.title}, url=${chapter.url}',
        );
      }

      // 过滤最新章节：找到第一个包含数字编号的章节（如"1、"、"2、"等），这应该是真正的目录开始
      // 参考项目：只添加标题不为空的章节，不添加分页链接
      if (chapters.isNotEmpty) {
        int startIndex = 0;
        // 查找第一个包含数字编号的章节（如"1、"、"2、"、"第一章"等）
        // 或者查找第一个标题看起来像章节标题的（包含"章"、"节"等）
        for (int i = 0; i < chapters.length; i++) {
          final title = chapters[i].title;
          // 检查是否包含数字编号模式（如"1、"、"2、"、"第一章"、"第1章"等）
          // 或者包含"章"、"节"等关键词，且不是"最新章节"、"最新章"等
          final hasNumberPattern =
              RegExp(r'^\d+[、.]|^第\d+章|^第[一二三四五六七八九十]+章').hasMatch(title);
          final hasChapterKeyword = title.contains('章') || title.contains('节');
          final isNotLatestChapter =
              !title.contains('最新') && !title.contains('最近');

          if (hasNumberPattern ||
              (hasChapterKeyword && isNotLatestChapter && i >= 6)) {
            // 如果找到了数字编号模式，或者找到了包含"章"的标题且不是"最新"相关，且索引>=6（跳过前几个）
            startIndex = i;
            break;
          }
        }

        // 如果找到了真正的目录开始位置，移除前面的最新章节
        // 但至少要保留一个章节，避免全部删除
        if (startIndex > 0 && startIndex < chapters.length) {
          chapters.removeRange(0, startIndex);
          // 重新设置索引
          for (int i = 0; i < chapters.length; i++) {
            chapters[i] = chapters[i].copyWith(index: i);
          }
        }

        // 如果第一条章节的标题为空或只包含空白字符，移除它
        // 但需要确保不会把所有章节都删除
        while (chapters.isNotEmpty) {
          final firstTitle =
              chapters[0].title.trim().replaceAll(RegExp(r'\s+'), '');
          if (firstTitle.isEmpty) {
            chapters.removeAt(0);
            // 重新设置索引
            for (int i = 0; i < chapters.length; i++) {
              chapters[i] = chapters[i].copyWith(index: i);
            }
            // 如果删除后列表为空，停止循环
            if (chapters.isEmpty) {
              break;
            }
          } else {
            break;
          }
        }
      }

      // 去重：保留第一个发现的章节
      // LinkedHashSet 保留第一次出现的元素
      final originalCount = chapters.length;
      final originalChapters = List<BookChapter>.from(chapters);
      chapters = LinkedHashSet<BookChapter>.from(chapters).toList();
      if (chapters.length < originalCount) {
        AppLog.instance
            .put('章节去重: $originalCount -> ${chapters.length}（保留第一个发现的）');
        final urlCounts = <String, int>{};
        for (final chapter in originalChapters) {
          urlCounts[chapter.url] = (urlCounts[chapter.url] ?? 0) + 1;
        }
        final duplicates =
            urlCounts.entries.where((entry) => entry.value > 1).take(5);
        for (final entry in duplicates) {
          AppLog.instance.put(
            '重复章节URL: url=${entry.key}, count=${entry.value}',
          );
        }
      }

      // 重新设置索引
      for (int i = 0; i < chapters.length; i++) {
        chapters[i] = chapters[i].copyWith(index: i);
      }

      AppLog.instance.put('获取章节列表成功: 共 ${chapters.length} 个章节');
      // 不保存到数据库，直接返回
      return chapters;
    } catch (e, stackTrace) {
      AppLog.instance.put('获取章节列表失败', error: e);
      AppLog.instance.put('错误堆栈: $stackTrace');
      // 重新抛出异常，让调用者能够处理错误
      // 如果调用者希望静默处理，可以在调用处捕获异常
      rethrow;
    }
  }

  /// 更新书籍目录（用于更新目录功能，支持分页获取）
