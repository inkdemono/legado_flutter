import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/manage_book_source_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_source_repository.dart';

void main() {
  late ManageBookSourceUseCase useCase;
  late MockBookSourceRepository mockBookSourceRepository;

  setUp(() {
    mockBookSourceRepository = MockBookSourceRepository();
    useCase = ManageBookSourceUseCase(
      bookSourceRepository: mockBookSourceRepository,
    );
  });

  group('ManageBookSourceUseCase', () {
    test('addSource 和 addSourcesBatch 应该保存书源', () async {
      final source1 = createTestBookSourceEntity(
        bookSourceUrl: 'https://source1.com',
      );
      final source2 = createTestBookSourceEntity(
        bookSourceUrl: 'https://source2.com',
      );

      await useCase.addSource(source1);
      final batchCount = await useCase.addSourcesBatch([source2]);

      expect(batchCount, 1);
      expect(mockBookSourceRepository.saveBookSourceCallCount, 2);

      final allSources = await mockBookSourceRepository.getAllBookSources();
      expect(allSources.map((item) => item.bookSourceUrl), [
        'https://source1.com',
        'https://source2.com',
      ]);
    });

    test('deleteSourcesBatch 和 clearAll 应该删除书源', () async {
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(bookSourceUrl: 'https://source1.com'),
        createTestBookSourceEntity(bookSourceUrl: 'https://source2.com'),
        createTestBookSourceEntity(bookSourceUrl: 'https://source3.com'),
      ]);

      final deletedCount = await useCase.deleteSourcesBatch([
        'https://source1.com',
        'https://source3.com',
      ]);

      expect(deletedCount, 2);
      expect(mockBookSourceRepository.deleteBookSourceCallCount, 2);

      await useCase.clearAll();

      final allSources = await mockBookSourceRepository.getAllBookSources();
      expect(allSources, isEmpty);
      expect(mockBookSourceRepository.clearAllBookSourcesCallCount, 1);
    });
  });
}
