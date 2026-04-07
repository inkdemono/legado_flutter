import 'package:flutter/material.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '../../reader/reader_page.dart';
import '../../reader/manga_reader_page.dart';
import '../../reader/chapter_list_page.dart';
import '../../../../data/models/book.dart';
import '../../../../data/models/book_chapter.dart';
import '../../../../data/models/book_source.dart';
import '../../../../services/network/network_service.dart';
import '../../../../data/models/book_group.dart';
import '../../../../providers/book_provider.dart';
import '../../../../utils/app_log.dart';
import 'book_info_header.dart';
import 'book_info_actions.dart';
import 'book_info_menu.dart';
import 'book_info_intro.dart';
import 'change_source_dialog.dart';
import 'change_cover_dialog.dart';
import 'book_info_edit_page.dart';
import '../../audio/audio_play_page.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

/// 书籍详情页面
class BookInfoPage extends ConsumerStatefulWidget {
  final String bookUrl;
  final String? bookName;
  final String? author;
  final String? sourceUrl;
  final String? coverUrl;
  final String? intro;
  final String? initialInfoHtml;
  final String? initialVariable;

  const BookInfoPage({
    super.key,
    required this.bookUrl,
    this.bookName,
    this.author,
    this.sourceUrl,
    this.coverUrl,
    this.intro,
    this.initialInfoHtml,
    this.initialVariable,
  });

  @override
  ConsumerState<BookInfoPage> createState() => _BookInfoPageState();
}

class _BookInfoPageState extends ConsumerState<BookInfoPage>
    with WidgetsBindingObserver {
  Book? _book;
  bool _isLoading = true;
  bool _isInBookshelf = false;
  String? _error; // 书籍信息加载错误
  String? _chapterError; // 章节列表加载错误（分离处理）
  List<BookChapter>? _chapters; // 保存章节列表用于显示
  bool _isLoadingChapters = false; // 章节加载状态
  bool _hasFullChapterList = false;
  late final ValueNotifier<List<BookChapter>> _chapterListNotifier;
  late final ValueNotifier<bool> _chapterListLoadingNotifier;
  OverlayEntry? _hintOverlayEntry;
  Timer? _hintDismissTimer;

  void _clearCenteredHint() {
    _hintDismissTimer?.cancel();
    _hintDismissTimer = null;
    _hintOverlayEntry?.remove();
    _hintOverlayEntry = null;
  }

  Future<void> _showCenteredHint(String message) async {
    if (!mounted) return;
    _hintDismissTimer?.cancel();
    _hintOverlayEntry?.remove();
    _hintOverlayEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);

    _hintOverlayEntry = OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_hintOverlayEntry!);
    _hintDismissTimer = Timer(const Duration(milliseconds: 900), () {
      _hintOverlayEntry?.remove();
      _hintOverlayEntry = null;
    });
  }

  bool get _hasExternalPreviewData =>
      (widget.coverUrl != null && widget.coverUrl!.trim().isNotEmpty) ||
      (widget.intro != null && widget.intro!.trim().isNotEmpty) ||
      (widget.initialInfoHtml != null && widget.initialInfoHtml!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chapterListNotifier = ValueNotifier<List<BookChapter>>(<BookChapter>[]);
    _chapterListLoadingNotifier = ValueNotifier<bool>(false);
    // 重置状态，确保每次打开页面都是全新的状态
    _book = null;
    _isInBookshelf = false;
    _error = null;
    _isLoading = true;
    _loadBook();
  }

  @override
  void didUpdateWidget(BookInfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果参数发生变化，重新加载书籍数据
    if (oldWidget.bookUrl != widget.bookUrl ||
        oldWidget.bookName != widget.bookName ||
        oldWidget.author != widget.author ||
        oldWidget.sourceUrl != widget.sourceUrl ||
        oldWidget.coverUrl != widget.coverUrl ||
        oldWidget.intro != widget.intro ||
        oldWidget.initialVariable != widget.initialVariable) {
      // 重置状态
      _book = null;
      _isInBookshelf = false;
      _error = null;
      _isLoading = true;
      _hasFullChapterList = false;
      _chapterListNotifier.value = const <BookChapter>[];
      _chapterListLoadingNotifier.value = false;
      // 重新加载
      _loadBook();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clearCenteredHint();
    _chapterListNotifier.dispose();
    _chapterListLoadingNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _clearCenteredHint();
    }
  }

  Future<void> _loadBook() async {
    final placeholderBook = _createPlaceholderBook();

    setState(() {
      _book = placeholderBook;
      _isLoading = placeholderBook == null;
      _error = null;
      _chapterError = null;
      _chapters = null;
      _isLoadingChapters = false;
      _hasFullChapterList = false;
      _isInBookshelf = false;
      _chapterListNotifier.value = const <BookChapter>[];
      _chapterListLoadingNotifier.value = false;
    });

    try {
      Book? book;
      bool isInShelf = false;

      // 参考项目逻辑：如果提供了 bookName 和 author，优先通过这两个字段查找
      // 因为 bookUrl 可能是分类页面 URL，不是唯一的书籍标识符
      if (widget.bookName != null && widget.author != null) {
        book =
            await readService(AppServices.bookService).getBookByNameAndAuthor(
          widget.bookName!,
          widget.author!,
        );
        if (book != null) {
          // 验证 bookUrl 是否匹配（如果 bookUrl 是有效的书籍详情页 URL）
          // 如果 bookUrl 看起来像分类页面 URL（包含 /sort/），则不验证
          bool urlMatches = widget.bookUrl.isEmpty ||
              widget.bookUrl.contains('/sort/') ||
              book.bookUrl == widget.bookUrl;

          if (urlMatches) {
            isInShelf = true;
          } else {
            book = null; // 重置，继续查找
          }
        }
      }

      // 如果通过名称和作者没找到，尝试通过 bookUrl 查找
      // 但需要验证名称和作者是否匹配
      if (book == null) {
        book = await readService(AppServices.bookService)
            .getBookByUrl(widget.bookUrl);
        if (book != null) {
          // 验证书籍名称和作者是否匹配（防止 bookUrl 是分类页面 URL 的情况）
          bool nameMatches =
              widget.bookName == null || book.name == widget.bookName;
          bool authorMatches = widget.author == null ||
              book.author == widget.author ||
              book.author.replaceAll('作者：', '').replaceAll('作者:', '').trim() ==
                  widget.author;

          if (nameMatches && authorMatches) {
            isInShelf = true;
          } else {
            book = null; // 重置，继续查找或创建临时对象
          }
        }
      }

      if (book == null && placeholderBook != null) {
        book = placeholderBook;
      }

      if (book == null) {
        throw Exception('未找到书籍');
      }

      book = _mergeWidgetPreviewIntoBook(book);

      // 再次检查 widget 参数是否变化（防止异步操作期间参数已变化）
      if (widget.bookUrl != book.bookUrl) {
        // 如果参数已变化，重新加载
        if (mounted) {
          _loadBook();
        }
        return;
      }

      if (mounted) {
        setState(() {
          _book = book;
          _isInBookshelf = isInShelf;
          _isLoading = false;
        });

        // 如果书籍在书架，也加载章节列表用于显示
        if (isInShelf) {
          unawaited(_loadChaptersForDisplay());
        } else {
          unawaited(_hydrateTransientBook(book));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Book? _createPlaceholderBook() {
    if (widget.bookName == null || widget.sourceUrl == null) {
      return null;
    }

    return Book(
      bookUrl: widget.bookUrl,
      name: widget.bookName!,
      author: widget.author ?? '',
      origin: widget.sourceUrl!,
      originName: '',
      coverUrl: widget.coverUrl != null && widget.coverUrl!.isNotEmpty
          ? NetworkService.joinUrl(widget.sourceUrl!, widget.coverUrl!)
          : null,
      intro: widget.intro,
      infoHtml: widget.initialInfoHtml,
      variable: widget.initialVariable,
      canUpdate: true,
    );
  }

  Book _mergeWidgetPreviewIntoBook(Book book) {
    final widgetCover = widget.coverUrl?.trim();
    final resolvedWidgetCover = widgetCover != null &&
            widgetCover.isNotEmpty &&
            widget.sourceUrl != null
        ? NetworkService.joinUrl(widget.sourceUrl!, widgetCover)
        : null;
    final widgetIntro = widget.intro?.trim();

    return book.copyWith(
      name: book.name.trim().isNotEmpty
          ? book.name
          : (widget.bookName?.trim().isNotEmpty == true
              ? widget.bookName!.trim()
              : book.name),
      author: book.author.trim().isNotEmpty
          ? book.author
          : (widget.author?.trim().isNotEmpty == true
              ? widget.author!.trim()
              : book.author),
      coverUrl: resolvedWidgetCover != null && resolvedWidgetCover.isNotEmpty
          ? resolvedWidgetCover
          : book.coverUrl,
      intro: (book.intro == null || book.intro!.trim().isEmpty)
          ? (widgetIntro?.isNotEmpty == true ? widgetIntro : book.intro)
          : book.intro,
      infoHtml: (book.infoHtml == null || book.infoHtml!.isEmpty)
          ? widget.initialInfoHtml
          : book.infoHtml,
      variable: (book.variable == null || book.variable!.isEmpty)
          ? widget.initialVariable
          : book.variable,
    );
  }

  Future<void> _hydrateTransientBook(Book baseBook) async {
    try {
      final source = await readService(AppServices.bookSourceService)
          .getBookSourceByUrl(baseBook.origin);
      if (source == null || !mounted) return;

      var workingBook = baseBook;
      if (workingBook.originName.isEmpty) {
        workingBook = workingBook.copyWith(originName: source.bookSourceName);
        if (mounted) {
          setState(() {
            _book = workingBook;
          });
        }
      }

      final bookInfo =
          await readService(AppServices.bookService).getBookInfo(workingBook);
      if (bookInfo != null) {
        workingBook = _mergeWidgetPreviewIntoBook(bookInfo);
        if (mounted) {
          setState(() {
            _book = workingBook;
          });
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoadingChapters = true;
        _chapterError = null;
      });

      final chapters = await readService(AppServices.bookService)
          .getChapterListWithoutSave(workingBook);
      if (!mounted) return;

      if (chapters.isNotEmpty) {
        workingBook = workingBook.copyWith(
          totalChapterNum: chapters.length,
          durChapterTitle: chapters.first.title,
        );
      } else {
        AppLog.instance.put(
          'BookInfoPage: 章节列表为空 - bookUrl=${workingBook.bookUrl}, tocUrl=${workingBook.tocUrl}, origin=${workingBook.origin}',
        );
      }

      setState(() {
        _book = workingBook;
        _chapters = chapters;
        _isLoadingChapters = false;
        _hasFullChapterList = true;
        _chapterError = chapters.isEmpty ? '解析目录失败：未找到章节列表' : null;
      });
      _chapterListNotifier.value = chapters;
      _chapterListLoadingNotifier.value = false;
      if (_isInBookshelf && chapters.isNotEmpty) {
        await readService(AppServices.bookService).saveChapters(chapters);
      }
    } catch (e, stackTrace) {
      AppLog.instance.put('BookInfoPage: 异步补全详情失败', error: e);
      AppLog.instance.put('错误堆栈: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoadingChapters = false;
        if (_book == null) {
          _error = '获取书籍详情失败: ${e.toString()}';
        } else {
          _chapterError = '解析目录失败: ${e.toString()}';
        }
      });
      _chapterListLoadingNotifier.value = false;
    }
  }

  Future<void> _refreshBook() async {
    if (_book == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 更新书籍信息
      final updatedBook =
          await readService(AppServices.bookService).getBookInfo(_book!);
      if (updatedBook != null) {
        setState(() {
          _book = updatedBook;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addToBookshelf() async {
    if (_book == null) return;

    try {
      await ref.read(bookshelfBooksProvider.notifier).addBook(_book!);

      setState(() {
        _isInBookshelf = true;
      });

      _refreshBookshelfProviders();

      unawaited(_persistChaptersAfterAddToShelf());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已添加到书架')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    }
  }

  void _refreshBookshelfProviders() {
    ref.read(bookshelfBooksProvider.notifier).reload();
  }

  Future<void> _persistChaptersAfterAddToShelf() async {
    if (_book == null || _book!.isLocal) return;

    try {
      if (_chapters != null && _chapters!.isNotEmpty) {
        await readService(AppServices.bookService).saveChapters(_chapters!);
      }

      if (_hasFullChapterList || _isLoadingChapters) {
        return;
      }

      await _upgradeChapterListInBackground(
        shouldPreferLiveChapters: _hasExternalPreviewData,
      );
    } catch (_) {
      // 目录后台保存失败不影响加入书架结果
    }
  }

  Future<void> _removeFromBookshelf() async {
    if (_book == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除书籍'),
        content: Text('确定要从书架移除 "${_book!.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('移除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(bookshelfBooksProvider.notifier)
            .removeBook(_book!.bookUrl);

        if (mounted) {
          Navigator.of(context).pop(true); // 返回并通知刷新
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('移除失败: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditPage() async {
    if (_book == null) return;

    final result = await Navigator.of(context).push<Book>(
      MaterialPageRoute(
        builder: (context) => BookInfoEditPage(book: _book!),
      ),
    );

    if (result != null) {
      setState(() {
        _book = result;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
      }
    }
  }

  Future<void> _shareBook() async {
    if (_book == null) return;

    try {
      // 将书籍信息转换为JSON
      final bookJson = jsonEncode(_book!.toJson());
      // 分享格式：bookUrl#json
      final shareText = '${_book!.bookUrl}#$bookJson';

      await Share.share(
        shareText,
        subject: _book!.name,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }

  /// 加载章节列表用于显示（不阻塞UI）
  Future<void> _loadChaptersForDisplay() async {
    if (_book == null) return;

    try {
      final chapters = _hasExternalPreviewData
          ? await readService(AppServices.bookService)
              .getChapterListWithoutSave(_book!)
          : await readService(AppServices.bookService).getChapterList(_book!);
      if (mounted) {
        setState(() {
          _chapters = chapters;
          _hasFullChapterList = true;
        });
        _chapterListNotifier.value = chapters;
      }
      if (_isInBookshelf && chapters.isNotEmpty) {
        await readService(AppServices.bookService).saveChapters(chapters);
      }
    } catch (e) {
      // 加载失败不影响显示
    }
  }

  Future<void> _upgradeChapterListInBackground({
    required bool shouldPreferLiveChapters,
  }) async {
    if (_book == null || _hasFullChapterList) return;

    try {
      _chapterListLoadingNotifier.value = true;
      final chapters = (_isInBookshelf && !shouldPreferLiveChapters)
          ? await readService(AppServices.bookService).getChapterList(_book!)
          : await readService(AppServices.bookService)
              .getChapterListWithoutSave(_book!);
      if (!mounted || chapters.isEmpty) return;

      setState(() {
        _chapters = chapters;
        _hasFullChapterList = true;
        _chapterError = null;
      });
      _chapterListNotifier.value = chapters;
      if (_isInBookshelf) {
        await readService(AppServices.bookService).saveChapters(chapters);
      }
    } catch (_) {
      // 后台补全失败不影响当前目录页使用
    } finally {
      _chapterListLoadingNotifier.value = false;
    }
  }

  Future<void> _openChapterList() async {
    if (_book == null) return;

    try {
      if (_isLoadingChapters && (_chapters == null || _chapters!.isEmpty)) {
        unawaited(_showCenteredHint('目录加载中...'));
        return;
      }

      if (!_isLoadingChapters &&
          (_chapters == null || _chapters!.isEmpty) &&
          _chapterError != null) {
        unawaited(_showCenteredHint('目录获取失败'));
        return;
      }

      List<BookChapter> chapters;
      final shouldPreferLiveChapters = _hasExternalPreviewData;

      if (_chapters != null && _chapters!.isNotEmpty && _chapterError == null) {
        chapters = _chapters!;
      } else {
        if (mounted) {
          setState(() {
            _isLoadingChapters = true;
            _chapterError = null;
          });
        }

        _chapterListLoadingNotifier.value = true;
        chapters = (_isInBookshelf && !shouldPreferLiveChapters)
            ? await readService(AppServices.bookService)
                .getChapterList(_book!, loadAllPages: false)
            : await readService(AppServices.bookService)
                .getChapterListWithoutSave(
                _book!,
                loadAllPages: false,
              );

        if (mounted) {
          setState(() {
            _chapters = chapters;
            _isLoadingChapters = false;
            _hasFullChapterList = false;
            _chapterError = chapters.isEmpty ? '未找到章节' : null;
          });
        }
        _chapterListNotifier.value = chapters;
        _chapterListLoadingNotifier.value = false;
      }

      if (!mounted) return;

      // 确保当前章节索引在有效范围内
      final currentIndex = _book!.durChapterIndex >= 0 &&
              _book!.durChapterIndex < chapters.length
          ? _book!.durChapterIndex
          : (chapters.isNotEmpty ? 0 : -1);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChapterListPage(
            chapters: chapters,
            chaptersListenable: _chapterListNotifier,
            loadingListenable: _chapterListLoadingNotifier,
            currentChapterIndex: currentIndex,
            onChapterSelected: (chapterIndex) {
              Navigator.of(context).pop();
              _startReading(chapterIndex: chapterIndex);
            },
          ),
        ),
      );

      unawaited(
        _upgradeChapterListInBackground(
          shouldPreferLiveChapters: shouldPreferLiveChapters,
        ),
      );
    } catch (e) {
      _chapterListLoadingNotifier.value = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载章节列表失败: $e')),
        );
      }
    }
  }

  void _startReading({int? chapterIndex}) {
    if (_book == null) return;

    // 根据书籍类型跳转到不同的页面
    if (_book!.type == BookType.audio) {
      // 音频书籍：跳转到音频播放页面
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => AudioPlayPage(
            book: _book!,
          ),
        ),
      )
          .then((_) {
        // 播放返回后刷新书籍信息
        _loadBook();
      });
    } else if (_book!.type == BookType.image) {
      // 漫画书籍：跳转到漫画阅读页面
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => MangaReaderPage(
            book: _book!,
            initialChapterIndex: chapterIndex ?? 0,
          ),
        ),
      )
          .then((_) {
        // 阅读返回后刷新书籍信息
        _loadBook();
      });
    } else {
      // 文本书籍：跳转到阅读页面
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => ReaderPage(
            book: _book!,
            initialChapterIndex: chapterIndex ?? 0,
          ),
        ),
      )
          .then((_) {
        // 阅读返回后刷新书籍信息
        _loadBook();
      });
    }
  }

  Future<void> _showChangeSourceDialog() async {
    if (_book == null) return;

    await showDialog(
      context: context,
      builder: (context) => ChangeSourceDialog(
        oldBook: _book!,
        onSourceChanged: (BookSource source, Book newBook,
            List<BookChapter> chapters) async {
          // 更新书籍信息
          try {
            // 如果书籍在书架中，需要更新数据库
            if (_isInBookshelf) {
              // 删除旧书籍
              await readService(AppServices.bookService)
                  .deleteBook(_book!.bookUrl);
              // 保存新书籍
              await readService(AppServices.bookService).createBook(newBook);
              // 保存章节列表
              await readService(AppServices.bookService).saveChapters(chapters);
            }

            setState(() {
              _book = newBook;
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('换源成功')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('换源失败: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _updateChapterList() async {
    if (_book == null || _book!.isLocal) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('本地书籍无法更新目录')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await readService(AppServices.bookService).updateChapterList(_book!);
      if (success) {
        // 重新加载书籍信息
        await _loadBook();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('目录更新成功')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('目录更新失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('目录更新失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 显示封面更换对话框
  void _showChangeCoverDialog() {
    if (_book == null) return;

    showDialog(
      context: context,
      builder: (context) => ChangeCoverDialog(
        book: _book!,
        onCoverChanged: (coverUrl) async {
          // 更新书籍封面
          try {
            final updatedBook = _book!.copyWith(
              customCoverUrl: coverUrl.isEmpty ? null : coverUrl,
            );
            await readService(AppServices.bookService).updateBook(updatedBook);
            setState(() {
              _book = updatedBook;
            });
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('更新封面失败: $e')),
              );
            }
          }
        },
      ),
    );
  }

  /// 显示设置分组对话框
  Future<void> _showChangeGroupDialog() async {
    if (_book == null) return;

    try {
      final groups = await readService(AppServices.bookGroupService)
          .getAllGroups(showOnly: false);
      if (groups.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('暂无可用分组')),
          );
        }
        return;
      }

      final selectedGroup = await showDialog<BookGroup>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('选择分组'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final isSelected = group.groupId == _book!.group;
                return ListTile(
                  title: Text(group.groupName),
                  trailing: isSelected
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(group),
                );
              },
            ),
          ),
        ),
      );

      if (selectedGroup != null) {
        try {
          await readService(AppServices.bookService)
              .updateBookGroup(_book!.bookUrl, selectedGroup.groupId);
          // 更新本地书籍对象的分组信息
          setState(() {
            _book = _book!.copyWith(group: selectedGroup.groupId);
          });
          // 重新加载书籍信息以确保数据同步
          await _loadBook();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已移动到"${selectedGroup.groupName}"')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('设置分组失败: $e')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载分组失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('书籍详情'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white),
        actions: [
          if (_book != null)
            BookInfoMenu(
              book: _book!,
              isInBookshelf: _isInBookshelf,
              onRefresh: _refreshBook,
              onEdit: () => _showEditPage(),
              onShare: () => _shareBook(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '加载失败',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadBook,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                )
              : _book == null
                  ? const Center(child: Text('书籍不存在'))
                  : Stack(
                      children: [
                        // 背景图片（封面模糊图）
                        if (_book!.displayCover != null &&
                            _book!.displayCover!.isNotEmpty)
                          Positioned.fill(
                            child: ImageFiltered(
                              imageFilter:
                                  ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: CachedNetworkImage(
                                key: ValueKey(
                                  'book_info_background_${_book!.displayCover!}',
                                ),
                                imageUrl: _book!.displayCover!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: theme.scaffoldBackgroundColor,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: theme.scaffoldBackgroundColor,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(color: theme.scaffoldBackgroundColor),
                        // 半透明遮罩层
                        Positioned.fill(
                          child: Container(
                            color: const Color(0x50000000),
                          ),
                        ),
                        // 顶部区域背景色（覆盖封面区域，使用与信息区域相同的背景色）
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 90 + 160 + 78, // AppBar高度 + 封面高度 + 弧形高度
                          child: Container(
                            color: (theme.brightness == Brightness.dark
                                    ? (Colors.grey[900] ?? Colors.black)
                                    : Colors.white)
                                .withOpacity(0.3), // 半透明背景色，不完全遮挡背景图片
                          ),
                        ),
                        // 内容层
                        Column(
                          children: [
                            // 可滚动内容
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _refreshBook,
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 书籍信息头部（封面区域透明，信息区域有背景色）
                                      BookInfoHeader(
                                        book: _book!,
                                        onCoverTap: () =>
                                            _showChangeCoverDialog(),
                                        onChangeSource: () =>
                                            _showChangeSourceDialog(),
                                        onViewToc: () => _openChapterList(),
                                        onChangeGroup: () =>
                                            _showChangeGroupDialog(),
                                        chapters: _chapters,
                                        isLoadingChapters: _isLoadingChapters,
                                        chapterError: _chapterError,
                                      ),
                                      // 简介
                                      BookInfoIntro(book: _book!),
                                      // 底部间距（为底部操作栏留空间）
                                      SizedBox(
                                          height: 60 +
                                              MediaQuery.of(context)
                                                  .padding
                                                  .bottom),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // 底部操作栏
                            BookInfoActions(
                              book: _book!,
                              isInBookshelf: _isInBookshelf,
                              onRead: () => _startReading(),
                              onAddToShelf: _addToBookshelf,
                              onRemoveFromShelf: _removeFromBookshelf,
                              onChangeSource: () => _showChangeSourceDialog(),
                              onUpdateToc: () => _updateChapterList(),
                            ),
                          ],
                        ),
                      ],
                    ),
    );
  }
}
