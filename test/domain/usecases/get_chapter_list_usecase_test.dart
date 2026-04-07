import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/get_chapter_list_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_repository.dart';
import '../../mocks/mock_book_source_repository.dart';

void main() {
  late GetChapterListUseCase useCase;
  late MockBookRepository mockBookRepository;
  late MockBookSourceRepository mockBookSourceRepository;

  setUp(() {
    mockBookRepository = MockBookRepository();
    mockBookSourceRepository = MockBookSourceRepository();
    useCase = GetChapterListUseCase(
      bookRepository: mockBookRepository,
      bookSourceRepository: mockBookSourceRepository,
    );
  });

  group('GetChapterListUseCase', () {
    test('execute 应该返回章节列表', () async {
      final book = createTestBookEntity();
      final chapters = [
        createTestChapterEntity(index: 0, title: '第1章'),
        createTestChapterEntity(
          index: 1,
          title: '第2章',
          url: 'https://test.com/book1/chapter2',
        ),
        createTestChapterEntity(
          index: 2,
          title: '第3章',
          url: 'https://test.com/book1/chapter3',
        ),
      ];
      mockBookRepository.setChapterList(chapters);
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(bookSourceUrl: book.origin),
      ]);

      final result = await useCase.execute(book);

      expect(result, chapters);
      expect(mockBookRepository.getChapterListCallCount, 1);
    });

    test('executeRange 应该返回指定区间章节', () async {
      final book = createTestBookEntity();
      final chapters = [
        createTestChapterEntity(index: 0, title: '第1章'),
        createTestChapterEntity(
          index: 1,
          title: '第2章',
          url: 'https://test.com/book1/chapter2',
        ),
        createTestChapterEntity(
          index: 2,
          title: '第3章',
          url: 'https://test.com/book1/chapter3',
        ),
      ];
      mockBookRepository.setChapterList(chapters);
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(bookSourceUrl: book.origin),
      ]);

      final result = await useCase.executeRange(book, 1, 2);

      expect(result.map((chapter) => chapter.title), ['第2章', '第3章']);
    });

    test('executeAround 应该返回当前章节前后窗口', () async {
      final book = createTestBookEntity();
      final chapters = List.generate(
        5,
        (index) => createTestChapterEntity(
          index: index,
          title: '第${index + 1}章',
          url: 'https://test.com/book1/chapter${index + 1}',
        ),
      );
      mockBookRepository.setChapterList(chapters);
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(bookSourceUrl: book.origin),
      ]);

      final result = await useCase.executeAround(
        book,
        2,
        beforeCount: 1,
        afterCount: 1,
      );

      expect(result.map((chapter) => chapter.index), [1, 2, 3]);
    });
  });
}
