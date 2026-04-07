import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/toggle_book_source_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_source_repository.dart';

void main() {
  late ToggleBookSourceUseCase useCase;
  late MockBookSourceRepository mockBookSourceRepository;

  setUp(() {
    mockBookSourceRepository = MockBookSourceRepository();
    mockBookSourceRepository.setAllSources([
      createTestBookSourceEntity(
        bookSourceUrl: 'https://source1.com',
        enabled: false,
      ),
      createTestBookSourceEntity(
        bookSourceUrl: 'https://source2.com',
        enabled: true,
      ),
    ]);
    useCase = ToggleBookSourceUseCase(
      bookSourceRepository: mockBookSourceRepository,
    );
  });

  group('ToggleBookSourceUseCase', () {
    test('enable 和 disable 应该切换单个书源状态', () async {
      await useCase.enable('https://source1.com');
      await useCase.disable('https://source2.com');

      final source1 = await mockBookSourceRepository.getBookSourceByUrl(
        'https://source1.com',
      );
      final source2 = await mockBookSourceRepository.getBookSourceByUrl(
        'https://source2.com',
      );

      expect(source1?.enabled, isTrue);
      expect(source2?.enabled, isFalse);
      expect(mockBookSourceRepository.toggleBookSourceCallCount, 2);
    });

    test('executeBatch 应该返回成功切换数量', () async {
      final count = await useCase.executeBatch([
        'https://source1.com',
        'https://source2.com',
      ], true);

      expect(count, 2);
      expect(mockBookSourceRepository.toggleBookSourceCallCount, 2);
    });
  });
}
