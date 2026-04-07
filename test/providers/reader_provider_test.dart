import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legado_flutter/data/models/book.dart';
import 'package:legado_flutter/data/models/book_chapter.dart';
import 'package:legado_flutter/providers/reader_provider.dart';
import 'package:legado_flutter/providers/service_registry.dart';
import 'package:legado_flutter/services/book/book_service.dart';

class _FakeBookService implements IBookService {
  _FakeBookService({required this.chapters});

  final List<BookChapter> chapters;

  @override
  Future<List<BookChapter>> getChapterList(
    Book book, {
    bool loadAllPages = true,
  }) async {
    return chapters;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ReaderState', () {
    test('copyWith 应正确更新字段', () {
      const state = ReaderState(
        chapters: [],
        currentChapterIndex: 0,
        isLoading: true,
      );
      final next = state.copyWith(
        currentChapterIndex: 2,
        isLoading: false,
      );
      expect(next.currentChapterIndex, 2);
      expect(next.isLoading, false);
      expect(next.chapters, state.chapters);
    });

    test('初始状态应符合默认值', () {
      const state = ReaderState();
      expect(state.chapters, isEmpty);
      expect(state.currentChapterIndex, 0);
      expect(state.isLoading, isTrue);
      expect(state.error, isNull);
    });
  });

  group('ReaderViewModel', () {
    test('build 应返回初始状态', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(readerViewModelProvider);
      expect(state.book, isNull);
      expect(state.chapters, isEmpty);
      expect(state.currentChapterIndex, 0);
      expect(state.isLoading, isTrue);
    });

    test('setCurrentChapterIndex 在无章节时不修改状态', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(readerViewModelProvider.notifier);
      notifier.setCurrentChapterIndex(0);
      expect(container.read(readerViewModelProvider).currentChapterIndex, 0);
    });

    test('openBook 支持通过 Provider override 替换 BookService', () async {
      final chapters = [
        BookChapter(
            bookUrl: 'book-1', title: '第1章', index: 0, url: 'chapter-1'),
        BookChapter(
            bookUrl: 'book-1', title: '第2章', index: 1, url: 'chapter-2'),
      ];
      final fakeService = _FakeBookService(chapters: chapters);
      final container = ProviderContainer(
        overrides: [
          AppServices.bookService.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(readerViewModelProvider.notifier);
      final book = Book(bookUrl: 'book-1', name: '测试书籍', origin: 'source-1');

      await notifier.openBook(book, 1);

      final state = container.read(readerViewModelProvider);
      expect(state.book?.bookUrl, 'book-1');
      expect(state.chapters, chapters);
      expect(state.currentChapterIndex, 1);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });
  });
}
