import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/get_chapter_content_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_repository.dart';
import '../../mocks/mock_book_source_repository.dart';

void main() {
  late GetChapterContentUseCase useCase;
  late MockBookRepository mockBookRepository;
  late MockBookSourceRepository mockBookSourceRepository;

  setUp(() {
    mockBookRepository = MockBookRepository();
    mockBookRepository.setChapterContent('章节内容');
    mockBookSourceRepository = MockBookSourceRepository();
    useCase = GetChapterContentUseCase(
      bookRepository: mockBookRepository,
      bookSourceRepository: mockBookSourceRepository,
    );
  });

  group('GetChapterContentUseCase', () {
    test('execute 应该返回章节正文', () async {
      final source =
          createTestBookSourceEntity(bookSourceUrl: 'https://test.com');
      mockBookSourceRepository.setAllSources([source]);

      final result = await useCase.execute(
        createTestChapterEntity(),
        'https://test.com',
      );

      expect(result, '章节内容');
      expect(mockBookRepository.getChapterContentCallCount, 1);
    });

    test('preloadChapters 应该统计成功预加载数量', () async {
      final source =
          createTestBookSourceEntity(bookSourceUrl: 'https://test.com');
      mockBookSourceRepository.setAllSources([source]);
      final chapters = [
        createTestChapterEntity(index: 0),
        createTestChapterEntity(
          index: 1,
          url: 'https://test.com/book1/chapter2',
        ),
      ];

      final count = await useCase.preloadChapters(chapters, 'https://test.com');

      expect(count, 2);
      expect(mockBookRepository.getChapterContentCallCount, 2);
    });

    test('preloadNext 应该只预加载当前章节后的若干章节', () async {
      final source =
          createTestBookSourceEntity(bookSourceUrl: 'https://test.com');
      mockBookSourceRepository.setAllSources([source]);
      final chapters = List.generate(
        4,
        (index) => createTestChapterEntity(
          index: index,
          url: 'https://test.com/book1/chapter${index + 1}',
        ),
      );

      final count = await useCase.preloadNext(
        chapters[0],
        chapters,
        'https://test.com',
        preloadCount: 2,
      );

      expect(count, 2);
      expect(mockBookRepository.getChapterContentCallCount, 2);
    });
  });
}
