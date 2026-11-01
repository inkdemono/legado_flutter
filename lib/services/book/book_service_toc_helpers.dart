part of 'book_service.dart';

// =============================================================================
// BookService 职责：目录(TOC)抓取辅助逻辑 —— URL 规范化比较、隐式分页候选构造、Ajax 目录回退解析。
// （part 文件，与主文件 book_service.dart 共享同一 Dart 库，可访问私有符号）
// =============================================================================

  /// 比较两个 URL 是否相等（规范化后比较）
  /// 参考项目：NetworkUtils.getAbsoluteURL 的比较逻辑
  /// 处理 URL 末尾的旜杠、大小写等差异
  bool _urlEquals(String url1, String url2) {
    if (url1 == url2) return true;
    if (url1.isEmpty || url2.isEmpty) return false;

    // 规范化 URL：移除末尾的 /
    String normalize(String url) {
      var normalized = url.trim();
      while (normalized.endsWith('/')) {
        normalized = normalized.substring(0, normalized.length - 1);
      }
      return normalized;
    }

    final normalized1 = normalize(url1);
    final normalized2 = normalize(url2);

    // 直接比较
    if (normalized1 == normalized2) return true;

    // 尝试解析 URI 后比较
    try {
      final uri1 = Uri.parse(normalized1);
      final uri2 = Uri.parse(normalized2);

      // 比较 scheme、host、port 和 path
      return uri1.scheme == uri2.scheme &&
          uri1.host == uri2.host &&
          uri1.port == uri2.port &&
          uri1.path == uri2.path;
    } catch (e) {
      return false;
    }
  }

  String _chapterIdentity(Map<String, String?> chapterData) {
    final chapterUrl = chapterData['chapterUrl']?.trim() ?? '';
    if (chapterUrl.isNotEmpty) return chapterUrl;
    return chapterData['chapterName']?.trim() ?? '';
  }

  List<String> _buildImplicitTocPageCandidates(String tocUrl, int pageNumber) {
    if (pageNumber < 2 || tocUrl.isEmpty) return const [];

    final normalizedUrl = tocUrl.trim();
    final candidates = <String>[];

    void addCandidate(String value) {
      if (value.isNotEmpty && !candidates.contains(value)) {
        candidates.add(value);
      }
    }

    if (normalizedUrl.endsWith('/')) {
      addCandidate(
          NetworkService.joinUrl(normalizedUrl, 'index_$pageNumber.html'));
      addCandidate(NetworkService.joinUrl(normalizedUrl, '$pageNumber.html'));
      return candidates;
    }

    try {
      final uri = Uri.parse(normalizedUrl);
      if (uri.path.endsWith('.html')) {
        final slashIndex = uri.path.lastIndexOf('/');
        final directoryPath =
            slashIndex >= 0 ? uri.path.substring(0, slashIndex + 1) : '/';
        final pageUri =
            uri.replace(path: '${directoryPath}index_$pageNumber.html');
        addCandidate(pageUri.toString());
      }
    } catch (_) {
      // ignore invalid tocUrl and fall back to the original URL shape below.
    }

    addCandidate('$normalizedUrl/index_$pageNumber.html');
    return candidates;
  }

  Future<List<Map<String, String?>>> _loadImplicitTocPages({
    required String tocUrl,
    required BookSource source,
    required TocRule tocRule,
    required Iterable<Map<String, String?>> seedChapters,
    Map<String, String>? variables,
  }) async {
    if (tocUrl.isEmpty || tocRule.nextTocUrl?.isNotEmpty == true) {
      return const [];
    }

    final existingIdentities =
        seedChapters.map(_chapterIdentity).where((id) => id.isNotEmpty).toSet();
    final collected = <Map<String, String?>>[];
    const maxImplicitPages = 50;

    for (int pageNumber = 2; pageNumber <= maxImplicitPages; pageNumber++) {
      final candidates = _buildImplicitTocPageCandidates(tocUrl, pageNumber);
      if (candidates.isEmpty) break;

      List<Map<String, String?>>? matchedPage;

      for (final candidateUrl in candidates) {
        try {
          final response = await _networkService.get(
            candidateUrl,
            headers: NetworkService.parseHeaders(source.header),
            retryCount: 1,
          );
          if (response.statusCode != 200) {
            continue;
          }

          final pageHtml = await NetworkService.getResponseText(response);
          if (pageHtml.isEmpty) {
            continue;
          }

          final pageResult = await RuleParser.parseTocRuleWithNextUrl(
            pageHtml,
            tocRule,
            variables: variables,
            baseUrl: candidateUrl,
            getNextUrl: false,
          );
          final pageChapters =
              pageResult['chapterList'] as List<Map<String, String?>>;
          if (pageChapters.isEmpty) {
            continue;
          }

          final newChapters = pageChapters.where((chapter) {
            final identity = _chapterIdentity(chapter);
            return identity.isNotEmpty &&
                !existingIdentities.contains(identity);
          }).toList();

          if (newChapters.isEmpty) {
            continue;
          }

          matchedPage = newChapters;
          existingIdentities.addAll(
            newChapters.map(_chapterIdentity).where((id) => id.isNotEmpty),
          );
          break;
        } catch (_) {
          continue;
        }
      }

      if (matchedPage == null || matchedPage.isEmpty) {
        break;
      }

      collected.addAll(matchedPage);
    }

    if (collected.isNotEmpty) {
      AppLog.instance.put('目录隐式分页补全成功: 新增 ${collected.length} 个章节');
    }

    return collected;
  }

  String? _extractAjaxTocBookId(String html) {
    final match = RegExp(
      'id\\s*=\\s*["\\\']bookiddata["\\\'][^>]*data-sid\\s*=\\s*["\\\'](\\d+)["\\\']',
      caseSensitive: false,
    ).firstMatch(html);
    return match?.group(1);
  }

  bool _supportsAjaxTocFallback(String tocUrl, String html) {
    return tocUrl.contains('guishuji.com') &&
        _extractAjaxTocBookId(html)?.isNotEmpty == true;
  }

  Map<String, String> _buildRuleVariables(Book book) {
    final variables = <String, String>{};
    book.variableMap.forEach((key, value) {
      variables[key] = value?.toString() ?? '';
    });
    return variables;
  }

  String _repairChapterUrlWithBookVariables(String url, Book? book) {
    if (url.isEmpty || book == null) return url;

    final bid = '${book.variableMap['bid'] ?? ''}'.trim();
    if (bid.isEmpty) return url;

    return url.replaceAllMapped(
      RegExp(r'([?&]comic_id=)(?:null)?(?=&|$)'),
      (match) => '${match.group(1)}$bid',
    );
  }

  Future<List<Map<String, String?>>> _loadAjaxTocPages({
    required String tocUrl,
    required String firstPageHtml,
    required BookSource source,
    required Iterable<Map<String, String?>> seedChapters,
  }) async {
    if (!_supportsAjaxTocFallback(tocUrl, firstPageHtml)) {
      return const [];
    }

    final bookId = _extractAjaxTocBookId(firstPageHtml);
    if (bookId == null || bookId.isEmpty) {
      return const [];
    }

    final ajaxUrl = NetworkService.joinUrl(
      tocUrl,
      '/e/extend/bookpage/pages.php?id=$bookId',
    );
    final existingIdentities =
        seedChapters.map(_chapterIdentity).where((id) => id.isNotEmpty).toSet();
    final collected = <Map<String, String?>>[];

    int? totalPages;
    int pageNum = 1;

    while (pageNum < 100) {
      try {
        final response = await _networkService.post(
          ajaxUrl,
          data: {'pageNum': pageNum},
          headers: {
            ...NetworkService.parseHeaders(source.header),
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest',
            'Referer': tocUrl,
          },
          retryCount: 1,
        );
        final responseText = await NetworkService.getResponseText(response);
        if (responseText.isEmpty) {
          break;
        }

        final data = jsonDecode(responseText);
        if (data is! Map<String, dynamic>) {
          break;
        }

        totalPages ??= int.tryParse('${data['totalPage'] ?? ''}');
        final list = data['list'];
        if (list is! List || list.isEmpty) {
          break;
        }

        final pageChapters = <Map<String, String?>>[];
        for (final item in list) {
          if (item is! Map) continue;
          final title = '${item['title'] ?? ''}'.trim();
          final rawUrl = '${item['pic'] ?? ''}'.trim();
          if (title.isEmpty || rawUrl.isEmpty) continue;

          final chapter = <String, String?>{
            'chapterName': title,
            'chapterUrl': NetworkService.joinUrl(tocUrl, rawUrl),
            'isVip': '0',
            'isVolume': '0',
            'updateTime': '',
            'nextTocUrl': '',
          };
          final identity = _chapterIdentity(chapter);
          if (identity.isEmpty || existingIdentities.contains(identity)) {
            continue;
          }
          existingIdentities.add(identity);
          pageChapters.add(chapter);
        }

        if (pageChapters.isEmpty) {
          break;
        }

        collected.addAll(pageChapters);
        pageNum++;

        if (totalPages != null && pageNum >= totalPages) {
          break;
        }
      } catch (_) {
        break;
      }
    }

    if (collected.isNotEmpty) {
      AppLog.instance.put('目录AJAX分页补全成功: 新增 ${collected.length} 个章节');
    }

    return collected;
  }
