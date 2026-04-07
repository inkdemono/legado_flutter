import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/event/app_events.dart';
import '../data/models/book.dart';
import '../data/models/book_chapter.dart';
import '../data/models/book_group.dart';
import '../data/mappers/entity_mapper.dart';
import '../services/book/book_service.dart';
import '../services/book_group_service.dart';
import 'event_bus_provider.dart';
import 'helpers/async_value_extension.dart';
import 'repository_providers.dart';
import 'service_registry.dart';

/// BookService Provider
final bookServiceProvider = Provider<IBookService>((ref) {
  return ref.watch(AppServices.bookService);
});

/// BookGroupService Provider
final bookGroupServiceProvider = Provider<BookGroupService>((ref) {
  return ref.watch(AppServices.bookGroupService);
});

class BookshelfNotifier extends AsyncNotifier<List<Book>> {
  @override
  Future<List<Book>> build() async {
    ref.listen(bookCollectionEventProvider, (_, next) {
      if (next.hasValue) {
        unawaited(reload());
      }
    });
    return _loadShelfBooks();
  }

  Future<List<Book>> _loadShelfBooks() async {
    final repository = ref.read(bookRepositoryProvider);
    final entities = await repository.getShelfBooks();
    return entities.map((e) => EntityMapper.bookFromEntity(e)).toList();
  }

  Future<void> reload({bool showLoading = false}) async {
    if (showLoading || !state.hasValue) {
      state = const AsyncValue.loading();
    }
    state = await AsyncValue.guard(_loadShelfBooks);
  }

  Future<void> addBook(Book book) async {
    await ref.read(bookServiceProvider).createBook(book);
    final current = state.valueOrNull;
    if (current == null) {
      await reload();
      return;
    }
    state = AsyncValue.data(
        [...current.where((item) => item.bookUrl != book.bookUrl), book]);
  }

  Future<void> addImportedBooks(List<Book> books) async {
    if (books.isEmpty) {
      await reload();
      return;
    }
    final current = state.valueOrNull;
    if (current == null) {
      await reload();
      return;
    }
    final incoming = {for (final book in books) book.bookUrl: book};
    final merged = [
      ...current.where((item) => !incoming.containsKey(item.bookUrl)),
      ...books,
    ];
    state = AsyncValue.data(merged);
  }

  Future<void> removeBook(String bookUrl) async {
    await ref.read(bookRepositoryProvider).deleteBook(bookUrl);
    final current = state.valueOrNull;
    if (current == null) {
      await reload();
      return;
    }
    state = AsyncValue.data(
      current.where((item) => item.bookUrl != bookUrl).toList(),
    );
  }

  Future<void> removeBooks(List<String> bookUrls) async {
    final urlSet = bookUrls.toSet();
    for (final bookUrl in bookUrls) {
      await ref.read(bookRepositoryProvider).deleteBook(bookUrl);
    }
    final current = state.valueOrNull;
    if (current == null) {
      await reload();
      return;
    }
    state = AsyncValue.data(
      current.where((item) => !urlSet.contains(item.bookUrl)).toList(),
    );
  }

  Future<void> updateBook(Book book) async {
    await ref
        .read(bookRepositoryProvider)
        .updateBook(EntityMapper.bookToEntity(book));
    _replaceBookLocally(book);
  }

  Future<void> updateBookGroup(String bookUrl, int groupId) async {
    await ref.read(bookServiceProvider).updateBookGroup(bookUrl, groupId);
    _mutateBook(bookUrl, (book) => book.copyWith(group: groupId));
  }

  Future<void> updateBookGroups(List<String> bookUrls, int groupId) async {
    final urlSet = bookUrls.toSet();
    for (final bookUrl in bookUrls) {
      await ref.read(bookServiceProvider).updateBookGroup(bookUrl, groupId);
    }
    final current = state.valueOrNull;
    if (current == null) {
      await reload();
      return;
    }
    state = AsyncValue.data(
      current
          .map((book) => urlSet.contains(book.bookUrl)
              ? book.copyWith(group: groupId)
              : book)
          .toList(),
    );
  }

  Future<void> updateBookOrder(String bookUrl, int order) async {
    await ref.read(bookServiceProvider).updateBookOrder(bookUrl, order);
    _mutateBook(bookUrl, (book) => book.copyWith(order: order));
  }

  Future<void> updateBookOrders(Map<String, int> ordersByUrl) async {
    for (final entry in ordersByUrl.entries) {
      await ref
          .read(bookServiceProvider)
          .updateBookOrder(entry.key, entry.value);
    }
    final current = state.valueOrNull;
    if (current == null) {
      await reload();
      return;
    }
    state = AsyncValue.data(
      current
          .map((book) => ordersByUrl.containsKey(book.bookUrl)
              ? book.copyWith(order: ordersByUrl[book.bookUrl]!)
              : book)
          .toList(),
    );
  }

  Future<void> updateProgress(
    String bookUrl,
    int chapterIndex,
    int chapterPos,
    String? chapterTitle,
  ) async {
    await ref
        .read(bookRepositoryProvider)
        .updateReadProgress(bookUrl, chapterIndex, chapterPos);
    final now = DateTime.now().millisecondsSinceEpoch;
    _mutateBook(
      bookUrl,
      (book) => book.copyWith(
        durChapterIndex: chapterIndex,
        durChapterPos: chapterPos,
        durChapterTitle: chapterTitle ?? book.durChapterTitle,
        durChapterTime: now,
      ),
    );
  }

  void _replaceBookLocally(Book updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    final index = current.indexWhere((item) => item.bookUrl == updated.bookUrl);
    state = AsyncValue.data(
      index >= 0
          ? [
              ...current.sublist(0, index),
              updated,
              ...current.sublist(index + 1),
            ]
          : [...current, updated],
    );
  }

  void _mutateBook(String bookUrl, Book Function(Book book) transform) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current
          .map((book) => book.bookUrl == bookUrl ? transform(book) : book)
          .toList(),
    );
  }
}

final bookshelfBooksProvider =
    AsyncNotifierProvider<BookshelfNotifier, List<Book>>(BookshelfNotifier.new);

/// 书籍搜索Provider (使用Repository - Stream方式)
final bookSearchProvider =
    StreamProvider.family<List<Book>, String>((ref, keyword) {
  final repository = ref.read(bookRepositoryProvider);
  final sourceRepository = ref.read(bookSourceRepositoryProvider);

  return sourceRepository
      .getEnabledBookSources()
      .asStream()
      .asyncExpand((sourceEntities) {
    return repository
        .searchBooks(keyword, sources: sourceEntities)
        .map((entities) {
      return entities.map((e) => EntityMapper.bookFromEntity(e)).toList();
    });
  });
});

/// 书籍详情Provider (使用Repository)
final bookInfoProvider = FutureProvider.family<Book?, Book>((ref, book) async {
  final repository = ref.read(bookRepositoryProvider);
  final sourceRepository = ref.read(bookSourceRepositoryProvider);

  // 转换为Entity
  final bookEntity = EntityMapper.bookToEntity(book);

  // 获取书源
  final sourceEntities = await sourceRepository.getBookSourceByUrl(book.origin);
  if (sourceEntities == null) return null;

  // 获取书籍详情
  final updatedEntity =
      await repository.getBookInfo(bookEntity, sourceEntities);
  return EntityMapper.bookFromEntity(updatedEntity);
});

/// 章节列表Provider (使用Repository)
final chapterListProvider =
    FutureProvider.family<List<BookChapter>, Book>((ref, book) async {
  final repository = ref.read(bookRepositoryProvider);
  final sourceRepository = ref.read(bookSourceRepositoryProvider);

  // 转换为Entity
  final bookEntity = EntityMapper.bookToEntity(book);

  // 获取书源
  final sourceEntity = await sourceRepository.getBookSourceByUrl(book.origin);
  if (sourceEntity == null) return [];

  // 获取章节列表
  final chapterEntities =
      await repository.getChapterList(bookEntity, sourceEntity);
  return chapterEntities.map((e) => EntityMapper.chapterFromEntity(e)).toList();
});

/// 刷新书架列表别名，兼容旧调用点
final refreshBookshelfProvider = bookshelfBooksProvider;

class BookGroupsNotifier extends AsyncNotifier<List<BookGroup>> {
  @override
  Future<List<BookGroup>> build() async {
    ref.listen(bookGroupEventProvider, (_, next) {
      if (next.hasValue) {
        unawaited(reload());
      }
    });
    return _loadGroups();
  }

  Future<List<BookGroup>> _loadGroups() async {
    final service = ref.read(bookGroupServiceProvider);
    if (!service.isInitialized) {
      await service.init();
    }
    await service.initDefaultGroups();
    return service.getAllGroups(showOnly: true);
  }

  Future<void> reload({bool showLoading = false}) async {
    if (showLoading || !state.hasValue) {
      state = const AsyncValue.loading();
    }
    state = await AsyncValue.guard(_loadGroups);
  }

  Future<void> createGroup(BookGroup group) async {
    await ref.read(bookGroupServiceProvider).createGroup(group);
    final current = state.valueOrNull;
    if (current == null) {
      await reload();
      return;
    }
    state = AsyncValue.data([...current, group]..sort(_compareGroups));
  }

  Future<void> updateGroup(BookGroup group) async {
    await ref.read(bookGroupServiceProvider).updateGroup(group);
    final current = state.valueOrNull;
    if (current == null) {
      await reload();
      return;
    }
    final next = current.where((item) => item.groupId != group.groupId).toList()
      ..add(group)
      ..sort(_compareGroups);
    state = AsyncValue.data(next);
  }

  Future<void> toggleGroupVisibility(BookGroup group, bool show) async {
    await updateGroup(group.copyWith(show: show));
  }

  Future<void> deleteGroup(int groupId) async {
    await ref.read(bookGroupServiceProvider).deleteGroup(groupId);
    final current = state.valueOrNull;
    if (current == null) {
      await reload();
      return;
    }
    state = AsyncValue.data(
      current.where((item) => item.groupId != groupId).toList(),
    );
  }

  int _compareGroups(BookGroup a, BookGroup b) {
    final orderCompare = a.order.compareTo(b.order);
    if (orderCompare != 0) return orderCompare;
    return a.groupId.compareTo(b.groupId);
  }
}

final bookGroupsProvider =
    AsyncNotifierProvider<BookGroupsNotifier, List<BookGroup>>(
  BookGroupsNotifier.new,
);

class BooksByGroupNotifier extends AsyncNotifier<List<Book>> {
  BooksByGroupNotifier(this.groupId);

  final int groupId;

  @override
  FutureOr<List<Book>> build() async {
    final books = await ref.watch(bookshelfBooksProvider.future);
    if (groupId == BookGroup.idAll) {
      return books;
    }
    return books.where((book) => book.group == groupId).toList();
  }
}

final booksByGroupProvider =
    AsyncNotifierProvider.family<BooksByGroupNotifier, List<Book>, int>(
  BooksByGroupNotifier.new,
);

/// 书籍操作Provider
final bookOperationsProvider = Provider((ref) => BookOperations());

/// 书籍操作类 (使用Repository)
class BookOperations {
  /// 添加书籍到书架
  Future<void> addBook(Book book, WidgetRef ref) async {
    await ref.read(bookshelfBooksProvider.notifier).addBook(book);
    ref.read(eventBusProvider).fire(
          BookCollectionChangedEvent(
            reason: 'book_added',
            bookUrl: book.bookUrl,
          ),
        );
  }

  /// 从书架删除书籍
  Future<void> removeBook(String bookUrl, WidgetRef ref) async {
    await ref.read(bookshelfBooksProvider.notifier).removeBook(bookUrl);
    ref.read(eventBusProvider).fire(
          BookCollectionChangedEvent(
            reason: 'book_removed',
            bookUrl: bookUrl,
          ),
        );
  }

  /// 更新阅读进度
  Future<void> updateProgress(
    String bookUrl,
    int chapterIndex,
    int chapterPos,
    String? chapterTitle,
    WidgetRef ref,
  ) async {
    await ref.read(bookshelfBooksProvider.notifier).updateProgress(
          bookUrl,
          chapterIndex,
          chapterPos,
          chapterTitle,
        );
    ref.read(eventBusProvider).fire(
          BookCollectionChangedEvent(
            reason: 'progress_updated',
            bookUrl: bookUrl,
          ),
        );
  }
}
