import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/remove_book_from_shelf_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_repository.dart';

void main() {
  late RemoveBookFromShelfUseCase useCase;
  late MockBookRepository mockBookRepository;

  setUp(() {
    mockBookRepository = MockBookRepository();
    mockBookRepository.setShelfBooks([
      createTestBookEntity(bookUrl: 'https://test.com/book-1'),
      createTestBookEntity(bookUrl: 'https://test.com/book-2'),
      createTestBookEntity(bookUrl: 'https://test.com/book-3'),
    ]);
    useCase = RemoveBookFromShelfUseCase(
      bookRepository: mockBookRepository,
    );
  });

  group('RemoveBookFromShelfUseCase', () {
    test('execute 应该删除指定书籍', () async {
      await useCase.execute('https://test.com/book-2');

      final books = await mockBookRepository.getShelfBooks();
      expect(books.map((book) => book.bookUrl), [
        'https://test.com/book-1',
        'https://test.com/book-3',
      ]);
      expect(mockBookRepository.deleteBookCallCount, 1);
    });

    test('executeBatch 应该返回成功删除数量', () async {
      final count = await useCase.executeBatch([
        'https://test.com/book-1',
        'https://test.com/book-3',
      ]);

      expect(count, 2);
      expect(mockBookRepository.deleteBookCallCount, 2);
    });
  });
}
