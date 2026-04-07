import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/check_book_update_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_repository.dart';
import '../../mocks/mock_book_source_repository.dart';

void main() {
  late CheckBookUpdateUseCase useCase;
  late MockBookRepository mockBookRepository;
  late MockBookSourceRepository mockBookSourceRepository;

  setUp(() {
    mockBookRepository = MockBookRepository();
    mockBookRepository.setUpdateCount(4);
    mockBookSourceRepository = MockBookSourceRepository();
    useCase = CheckBookUpdateUseCase(
      bookRepository: mockBookRepository,
      bookSourceRepository: mockBookSourceRepository,
    );
  });

  group('CheckBookUpdateUseCase', () {
    test('execute 应该返回单本书更新数量', () async {
      final book = createTestBookEntity();
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(bookSourceUrl: book.origin),
      ]);

      final count = await useCase.execute(book);

      expect(count, 4);
      expect(mockBookRepository.checkBookUpdateCallCount, 1);
    });

    test('当书源不存在时应该返回 0', () async {
      final count = await useCase.execute(createTestBookEntity());

      expect(count, 0);
      expect(mockBookRepository.checkBookUpdateCallCount, 0);
    });

    test('executeBatch 应该为每本书返回结果', () async {
      final books = [
        createTestBookEntity(
          bookUrl: 'https://test.com/book-1',
          name: '书1',
        ),
        createTestBookEntity(
          bookUrl: 'https://test.com/book-2',
          name: '书2',
        ).copyWith(origin: 'https://missing-source.com'),
      ];
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(bookSourceUrl: books.first.origin),
      ]);

      final result = await useCase.executeBatch(books);

      expect(result['https://test.com/book-1'], 4);
      expect(result['https://test.com/book-2'], 0);
    });
  });
}
