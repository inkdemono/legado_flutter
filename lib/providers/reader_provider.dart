import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/book.dart';
import '../data/models/book_chapter.dart';
import '../utils/app_log.dart';
import 'book_provider.dart';

/// 阅读器状态：章节列表与当前章节索引，供 ReaderPage 与预加载/进度同步使用。
class ReaderState {
  const ReaderState({
    this.book,
    this.chapters = const [],
    this.currentChapterIndex = 0,
    this.isLoading = true,
    this.error,
  });

  final Book? book;
  final List<BookChapter> chapters;
  final int currentChapterIndex;
  final bool isLoading;
  final Object? error;

  ReaderState copyWith({
    Book? book,
    List<BookChapter>? chapters,
    int? currentChapterIndex,
    bool? isLoading,
    Object? error,
  }) {
    return ReaderState(
      book: book ?? this.book,
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 阅读器 ViewModel：加载章节列表与当前章节索引，与参考项目 ReadBookViewModel 对应。
/// 每个可见的 ReaderPage 通过 openBook 绑定当前书籍，便于后续扩展预加载与进度同步。
class ReaderViewModel extends Notifier<ReaderState> {
  @override
  ReaderState build() => const ReaderState();

  /// 打开书籍并加载章节列表，应在 ReaderPage 进入时调用。
  Future<void> openBook(Book book, int initialChapterIndex) async {
    state = state.copyWith(book: book, isLoading: true, error: null);
    try {
      final chapters = await ref.read(bookServiceProvider).getChapterList(book);
      final index = initialChapterIndex.clamp(
        0,
        chapters.isEmpty ? 0 : chapters.length - 1,
      );
      state = state.copyWith(
        chapters: chapters,
        currentChapterIndex: index,
        isLoading: false,
      );
    } catch (e) {
      AppLog.instance.put('加载章节列表失败', error: e);
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  void setCurrentChapterIndex(int index) {
    if (index < 0 || index >= state.chapters.length) return;
    state = state.copyWith(currentChapterIndex: index);
  }
}

/// 阅读器状态 Provider，供 ReaderPage 使用。
final readerViewModelProvider =
    NotifierProvider<ReaderViewModel, ReaderState>(ReaderViewModel.new);
