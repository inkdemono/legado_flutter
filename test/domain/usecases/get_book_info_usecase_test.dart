import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/get_book_info_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_repository.dart';
import '../../mocks/mock_book_source_repository.dart';

void main() {
  late GetBookInfoUseCase useCase;
  late MockBookRepository mockBookRepository;
  late MockBookSourceRepository mockBookSourceRepository;

  setUp(() {
    mockBookRepository = MockBookRepository();
    mockBookSourceRepository = MockBookSourceRepository();
    useCase = GetBookInfoUseCase(
      bookRepository: mockBookRepository,
      bookSourceRepository: mockBookSourceRepository,
    );
  });

  group('GetBookInfoUseCase', () {
    test('execute(saveToLocal: true) 应该更新本地书籍信息', () async {
      final book = createTestBookEntity();
      final updatedBook = book.copyWith(name: '更新后的书名');
      mockBookRepository.setBookInfo(updatedBook);
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(bookSourceUrl: book.origin),
      ]);

      final result = await useCase.execute(book, saveToLocal: true);

      expect(result.name, '更新后的书名');
      expect(mockBookRepository.getBookInfoCallCount, 1);
      expect(mockBookRepository.updateBookCallCount, 1);
      expect(mockBookRepository.lastUpdatedBookUrl, book.bookUrl);
    });

    test('当书源不存在时应该抛错', () async {
      await expectLater(
        useCase.execute(createTestBookEntity()),
        throwsException,
      );
    });

    test('executeBatch 遇到失败时应该保留原书籍', () async {
      final successBook = createTestBookEntity(
        bookUrl: 'https://test.com/book-1',
        name: '书1',
      );
      final failBook = createTestBookEntity(
        bookUrl: 'https://test.com/book-2',
        name: '书2',
      ).copyWith(origin: 'https://missing-source.com');

      mockBookRepository.setBookInfo(successBook.copyWith(name: '已更新'));
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(bookSourceUrl: successBook.origin),
      ]);

      final result = await useCase.executeBatch([successBook, failBook]);

      expect(result[0].name, '已更新');
      expect(result[1].name, '书2');
    });
  });
}
