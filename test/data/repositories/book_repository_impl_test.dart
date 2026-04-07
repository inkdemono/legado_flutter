import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/data/datasources/book_local_datasource.dart';
import 'package:legado_flutter/data/datasources/book_remote_datasource.dart';
import 'package:legado_flutter/data/mappers/entity_mapper.dart';
import 'package:legado_flutter/data/models/book.dart';
import 'package:legado_flutter/data/models/book_chapter.dart';
import 'package:legado_flutter/data/models/book_source.dart';
import 'package:legado_flutter/data/models/search_book.dart';
import 'package:legado_flutter/data/repositories/book_repository_impl.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late _FakeBookLocalDataSource localDataSource;
  late _FakeBookRemoteDataSource remoteDataSource;
  late BookRepositoryImpl repository;

  setUp(() {
    localDataSource = _FakeBookLocalDataSource();
    remoteDataSource = _FakeBookRemoteDataSource();
    repository = BookRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  group('BookRepositoryImpl', () {
    test('getBookByUrl、getAllBooks、getBooksByGroup 应该完成模型映射', () async {
      localDataSource.books.addAll([
        EntityMapper.bookFromEntity(
          createTestBookEntity(bookUrl: 'https://test.com/book-1', group: 1),
        ),
        EntityMapper.bookFromEntity(
          createTestBookEntity(bookUrl: 'https://test.com/book-2', group: 2),
        ),
      ]);

      final book = await repository.getBookByUrl('https://test.com/book-1');
      final allBooks = await repository.getAllBooks();
      final groupedBooks = await repository.getBooksByGroup(2);

      expect(book?.bookUrl, 'https://test.com/book-1');
      expect(allBooks, hasLength(2));
      expect(groupedBooks.single.bookUrl, 'https://test.com/book-2');
    });

    test('getChapterList 应该优先返回本地章节', () async {
      final book = createTestBookEntity();
      localDataSource.chaptersByBook[book.bookUrl] = [
        EntityMapper.chapterFromEntity(createTestChapterEntity(index: 0)),
      ];

      final result = await repository.getChapterList(
        book,
        createTestBookSourceEntity(bookSourceUrl: book.origin),
      );

      expect(result, hasLength(1));
      expect(remoteDataSource.getChapterListCallCount, 0);
    });

    test('getBookInfo 应该返回远端更新后的实体', () async {
      final book = createTestBookEntity();
      remoteDataSource.bookInfo =
          EntityMapper.bookFromEntity(book.copyWith(name: '远端书名'));

      final result = await repository.getBookInfo(
        book,
        createTestBookSourceEntity(bookSourceUrl: book.origin),
      );

      expect(result.name, '远端书名');
    });

    test('getChapterContent 缓存未命中时应该读取远端并回填本地缓存', () async {
      final chapter = createTestChapterEntity();
      remoteDataSource.chapterContent = '远端章节内容';

      final result = await repository.getChapterContent(
        chapter,
        createTestBookSourceEntity(bookSourceUrl: 'https://test.com'),
      );

      expect(result, '远端章节内容');
      expect(remoteDataSource.getChapterContentCallCount, 1);
      expect(
        localDataSource
            .savedChapterContents['${chapter.bookUrl}|${chapter.url}'],
        '远端章节内容',
      );
    });

    test('checkBookUpdate 应该保存新章节并更新书籍信息', () async {
      final book = createTestBookEntity().copyWith(totalChapterNum: 1);
      remoteDataSource.chapters = [
        EntityMapper.chapterFromEntity(createTestChapterEntity(index: 0)),
        EntityMapper.chapterFromEntity(
          createTestChapterEntity(
            index: 1,
            title: '第2章',
            url: 'https://test.com/book1/chapter2',
          ),
        ),
      ];

      final count = await repository.checkBookUpdate(
        book,
        createTestBookSourceEntity(bookSourceUrl: book.origin),
      );

      expect(count, 1);
      expect(localDataSource.saveChaptersCallCount, 1);
      expect(localDataSource.updateBookCallCount, 1);
      expect(localDataSource.updatedBooks.single.lastCheckCount, 1);
    });

    test('saveBook、updateBook、deleteBook、updateReadProgress 应该委托本地数据源',
        () async {
      final book = createTestBookEntity(bookUrl: 'https://test.com/book-1');

      await repository.saveBook(book);
      await repository.updateBook(book.copyWith(name: '更新后'));
      await repository.updateReadProgress(book.bookUrl, 3, 120);
      await repository.deleteBook(book.bookUrl);

      expect(localDataSource.books, isEmpty);
      expect(localDataSource.updateBookCallCount, 1);
      expect(localDataSource.readProgressBookUrl, book.bookUrl);
      expect(localDataSource.readProgressChapterIndex, 3);
      expect(localDataSource.readProgressChapterPos, 120);
    });

    test('addToShelf 和 removeFromShelf 应该更新 group 字段', () async {
      final book = createTestBookEntity(
        bookUrl: 'https://test.com/book-1',
        group: 0,
      );
      localDataSource.books.add(EntityMapper.bookFromEntity(book));

      await repository.addToShelf(book);
      await repository.removeFromShelf(book.bookUrl);

      expect(localDataSource.updatedBooks, hasLength(2));
      expect(localDataSource.updatedBooks.first.group, 1);
      expect(localDataSource.updatedBooks.last.group, 0);
    });

    test('checkShelfBooksUpdate 当前应返回空映射', () async {
      localDataSource.books.add(
        EntityMapper.bookFromEntity(
          createTestBookEntity(bookUrl: 'https://test.com/book-1'),
        ),
      );

      final result = await repository.checkShelfBooksUpdate();

      expect(result, isEmpty);
    });

    test('searchBooks 应该将远端 SearchBook 转成实体结果流', () async {
      remoteDataSource.searchResults = [
        SearchBook(
          bookUrl: 'https://test.com/book-1',
          tocUrl: 'https://test.com/book-1/toc',
          name: '搜索结果',
          author: '作者',
        ),
      ];

      final result = await repository.searchBooks(
        '关键词',
        sources: [
          createTestBookSourceEntity(bookSourceUrl: 'https://source.com')
        ],
      ).last;

      expect(result, hasLength(1));
      expect(result.single.name, '搜索结果');
    });
  });
}

class _FakeBookLocalDataSource implements BookLocalDataSource {
  final List<Book> books = [];
  final List<Book> updatedBooks = [];
  final Map<String, List<BookChapter>> chaptersByBook = {};
  final Map<String, String> savedChapterContents = {};
  int saveChaptersCallCount = 0;
  int updateBookCallCount = 0;
  String? readProgressBookUrl;
  int? readProgressChapterIndex;
  int? readProgressChapterPos;

  @override
  Future<void> deleteBook(String bookUrl) async {
    books.removeWhere((book) => book.bookUrl == bookUrl);
  }

  @override
  Future<List<Book>> getAllBooks() async => List<Book>.from(books);

  @override
  Future<Book?> getBookByUrl(String bookUrl) async {
    for (final book in books) {
      if (book.bookUrl == bookUrl) {
        return book;
      }
    }
    return null;
  }

  @override
  Future<List<Book>> getBooksByGroup(int groupId) async {
    return books.where((book) => book.group == groupId).toList();
  }

  @override
  Future<String?> getChapterContent(String bookUrl, String chapterUrl) async {
    return savedChapterContents['$bookUrl|$chapterUrl'];
  }

  @override
  Future<List<BookChapter>> getChapterList(String bookUrl) async {
    return chaptersByBook[bookUrl] ?? const [];
  }

  @override
  Future<List<Book>> getShelfBooks() async => List<Book>.from(books);

  @override
  Future<void> saveBook(Book book) async {
    books.add(book);
  }

  @override
  Future<void> saveChapterContent(
    String bookUrl,
    String chapterUrl,
    String content,
  ) async {
    savedChapterContents['$bookUrl|$chapterUrl'] = content;
  }

  @override
  Future<void> saveChapters(List<BookChapter> chapters) async {
    saveChaptersCallCount++;
    if (chapters.isNotEmpty) {
      chaptersByBook[chapters.first.bookUrl] = List<BookChapter>.from(chapters);
    }
  }

  @override
  Future<void> updateBook(Book book) async {
    updateBookCallCount++;
    updatedBooks.add(book);
    final index = books.indexWhere((item) => item.bookUrl == book.bookUrl);
    if (index >= 0) {
      books[index] = book;
    }
  }

  @override
  Future<void> updateReadProgress(
    String bookUrl,
    int chapterIndex,
    int chapterPos,
  ) async {
    readProgressBookUrl = bookUrl;
    readProgressChapterIndex = chapterIndex;
    readProgressChapterPos = chapterPos;
  }
}

class _FakeBookRemoteDataSource implements BookRemoteDataSource {
  List<SearchBook> searchResults = [];
  Book? bookInfo;
  List<BookChapter> chapters = [];
  String chapterContent = '';
  int getChapterListCallCount = 0;
  int getChapterContentCallCount = 0;

  @override
  Future<Book> getBookInfo(Book book, BookSource source) async {
    return bookInfo ?? book;
  }

  @override
  Future<String> getChapterContent(
      BookChapter chapter, BookSource source) async {
    getChapterContentCallCount++;
    return chapterContent;
  }

  @override
  Future<List<BookChapter>> getChapterList(Book book, BookSource source) async {
    getChapterListCallCount++;
    return List<BookChapter>.from(chapters);
  }

  @override
  Stream<SearchBook> searchBooks(String keyword, BookSource source) async* {
    for (final result in searchResults) {
      yield result;
    }
  }
}
