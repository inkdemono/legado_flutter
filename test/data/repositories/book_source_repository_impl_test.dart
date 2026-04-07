import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/data/datasources/book_source_local_datasource.dart';
import 'package:legado_flutter/data/models/book_source.dart';
import 'package:legado_flutter/data/repositories/book_source_repository_impl.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late _FakeBookSourceLocalDataSource localDataSource;
  late BookSourceRepositoryImpl repository;

  setUp(() {
    localDataSource = _FakeBookSourceLocalDataSource();
    repository = BookSourceRepositoryImpl(localDataSource: localDataSource);
  });

  group('BookSourceRepositoryImpl', () {
    test('getAllBookSources、getDisabledBookSources、getBookSourceByUrl 应该返回映射结果',
        () async {
      localDataSource.sources = [
        BookSource(
          bookSourceUrl: 'https://source1.com',
          bookSourceName: '源1',
          enabled: true,
        ),
        BookSource(
          bookSourceUrl: 'https://source2.com',
          bookSourceName: '源2',
          enabled: false,
        ),
      ];

      final all = await repository.getAllBookSources();
      final disabled = await repository.getDisabledBookSources();
      final single = await repository.getBookSourceByUrl('https://source1.com');

      expect(all, hasLength(2));
      expect(disabled.single.bookSourceUrl, 'https://source2.com');
      expect(single?.bookSourceName, '源1');
    });

    test('getEnabledBookSources 应该完成模型到实体的映射', () async {
      localDataSource.sources = [
        BookSource(bookSourceUrl: 'https://source1.com', enabled: true),
        BookSource(bookSourceUrl: 'https://source2.com', enabled: false),
      ];

      final result = await repository.getEnabledBookSources();

      expect(result, hasLength(1));
      expect(result.single.bookSourceUrl, 'https://source1.com');
    });

    test('importFromJson 应该解析 JSON 并保存到本地数据源', () async {
      final count = await repository.importFromJson(
        '[{"bookSourceUrl":"https://source1.com","bookSourceName":"源1"}]',
      );

      expect(count, 1);
      expect(localDataSource.savedSources, hasLength(1));
      expect(localDataSource.savedSources.single.bookSourceUrl,
          'https://source1.com');
    });

    test('save、update、delete、toggle 等写操作应该委托本地数据源', () async {
      final source = createTestBookSourceEntity(
        bookSourceUrl: 'https://source1.com',
        bookSourceName: '源1',
      );
      localDataSource.sources = [
        BookSource(
          bookSourceUrl: source.bookSourceUrl,
          bookSourceName: source.bookSourceName,
          enabled: true,
        ),
      ];

      await repository.saveBookSource(source);
      await repository.updateBookSource(source.copyWith(bookSourceName: '新源1'));
      await repository.toggleBookSource(source.bookSourceUrl, false);
      await repository.toggleBookSources([source.bookSourceUrl], true);
      await repository.updateBookSourceOrder(source.bookSourceUrl, 9);
      await repository.updateRespondTime(source.bookSourceUrl, 120);
      await repository.deleteBookSource(source.bookSourceUrl);

      expect(localDataSource.saveBookSourceCallCount, 1);
      expect(localDataSource.updateBookSourceCallCount, 1);
      expect(localDataSource.toggleBookSourceCallCount, 2);
      expect(localDataSource.updateBookSourceOrderCallCount, 1);
      expect(localDataSource.updateRespondTimeCallCount, 1);
      expect(localDataSource.deleteBookSourceCallCount, 1);
    });

    test('按分组搜索与清空操作应该委托本地数据源', () async {
      localDataSource.sources = [
        BookSource(
          bookSourceUrl: 'https://source1.com',
          bookSourceName: 'Alpha',
          bookSourceGroup: '默认',
          enabled: true,
        ),
        BookSource(
          bookSourceUrl: 'https://source2.com',
          bookSourceName: 'Beta',
          bookSourceGroup: '其他',
          enabled: true,
        ),
      ];

      final groupSources = await repository.getBookSourcesByGroup('其他');
      final groups = await repository.getAllGroups();
      final searchResult = await repository.searchBookSources('Alpha');
      await repository.clearAllBookSources();

      expect(groupSources.single.bookSourceUrl, 'https://source2.com');
      expect(groups, containsAll(['默认', '其他']));
      expect(searchResult.single.bookSourceName, 'Alpha');
      expect(localDataSource.clearAllBookSourcesCallCount, 1);
    });

    test('exportToJson 应该导出传入实体列表', () async {
      final json = await repository.exportToJson([
        createTestBookSourceEntity(
          bookSourceUrl: 'https://source1.com',
          bookSourceName: '源1',
        ),
      ]);

      expect(json, contains('https://source1.com'));
      expect(json, contains('源1'));
    });
  });
}

class _FakeBookSourceLocalDataSource implements BookSourceLocalDataSource {
  List<BookSource> sources = [];
  List<BookSource> savedSources = [];
  int saveBookSourceCallCount = 0;
  int deleteBookSourceCallCount = 0;
  int updateBookSourceCallCount = 0;
  int toggleBookSourceCallCount = 0;
  int updateBookSourceOrderCallCount = 0;
  int updateRespondTimeCallCount = 0;
  int clearAllBookSourcesCallCount = 0;

  @override
  Future<void> clearAllBookSources() async {
    clearAllBookSourcesCallCount++;
    sources.clear();
  }

  @override
  Future<void> deleteBookSource(String bookSourceUrl) async {
    deleteBookSourceCallCount++;
    sources.removeWhere((source) => source.bookSourceUrl == bookSourceUrl);
  }

  @override
  Future<void> deleteBookSources(List<String> bookSourceUrls) async {
    sources
        .removeWhere((source) => bookSourceUrls.contains(source.bookSourceUrl));
  }

  @override
  Future<List<BookSource>> getAllBookSources({bool enabledOnly = false}) async {
    if (!enabledOnly) {
      return List<BookSource>.from(sources);
    }
    return sources.where((source) => source.enabled).toList();
  }

  @override
  Future<List<String>> getAllGroups() async {
    return sources
        .map((source) => source.bookSourceGroup)
        .whereType<String>()
        .toSet()
        .toList();
  }

  @override
  Future<BookSource?> getBookSourceByUrl(String url) async {
    for (final source in sources) {
      if (source.bookSourceUrl == url) {
        return source;
      }
    }
    return null;
  }

  @override
  Future<List<BookSource>> getBookSourcesByGroup(String group) async {
    return sources.where((source) => source.bookSourceGroup == group).toList();
  }

  @override
  Future<List<BookSource>> getDisabledBookSources() async {
    return sources.where((source) => !source.enabled).toList();
  }

  @override
  Future<List<BookSource>> getEnabledBookSources() async {
    return sources.where((source) => source.enabled).toList();
  }

  @override
  Future<void> saveBookSource(BookSource bookSource) async {
    saveBookSourceCallCount++;
    sources.add(bookSource);
  }

  @override
  Future<void> saveBookSources(List<BookSource> bookSources) async {
    savedSources = List<BookSource>.from(bookSources);
    sources.addAll(bookSources);
  }

  @override
  Future<List<BookSource>> searchBookSources(String keyword) async {
    return sources
        .where(
          (source) =>
              source.bookSourceUrl.contains(keyword) ||
              source.bookSourceName.contains(keyword),
        )
        .toList();
  }

  @override
  Future<void> toggleBookSource(String bookSourceUrl, bool enabled) async {
    toggleBookSourceCallCount++;
    final index =
        sources.indexWhere((source) => source.bookSourceUrl == bookSourceUrl);
    if (index >= 0) {
      sources[index] = sources[index].copyWith(enabled: enabled);
    }
  }

  @override
  Future<void> toggleBookSources(
      List<String> bookSourceUrls, bool enabled) async {
    for (final url in bookSourceUrls) {
      await toggleBookSource(url, enabled);
    }
  }

  @override
  Future<void> updateBookSource(BookSource bookSource) async {
    updateBookSourceCallCount++;
    final index = sources.indexWhere(
        (source) => source.bookSourceUrl == bookSource.bookSourceUrl);
    if (index >= 0) {
      sources[index] = bookSource;
    }
  }

  @override
  Future<void> updateBookSourceOrder(String bookSourceUrl, int order) async {
    updateBookSourceOrderCallCount++;
  }

  @override
  Future<void> updateRespondTime(String bookSourceUrl, int respondTime) async {
    updateRespondTimeCallCount++;
  }
}
