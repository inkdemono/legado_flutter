import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/add_book_to_shelf_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_repository.dart';

void main() {
  late AddBookToShelfUseCase useCase;
  late MockBookRepository mockBookRepository;

  setUp(() {
    mockBookRepository = MockBookRepository();
    useCase = AddBookToShelfUseCase(
      bookRepository: mockBookRepository,
    );
  });

  group('AddBookToShelfUseCase', () {
    test('execute 应该按指定分组保存书籍', () async {
      final book = createTestBookEntity(bookUrl: 'https://test.com/book-1');

      await useCase.execute(book, groupId: 7);

      expect(mockBookRepository.saveBookCallCount, 1);
      final savedBooks = await mockBookRepository.getShelfBooks();
      expect(savedBooks.single.group, 7);
    });

    test('executeBatch 应该返回成功添加数量', () async {
      final books = [
        createTestBookEntity(bookUrl: 'https://test.com/book-1'),
        createTestBookEntity(bookUrl: 'https://test.com/book-2'),
      ];

      final count = await useCase.executeBatch(books, groupId: 3);

      expect(count, 2);
      expect(mockBookRepository.saveBookCallCount, 2);
    });
  });
}
