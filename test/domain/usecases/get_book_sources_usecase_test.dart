import 'package:flutter_test/flutter_test.dart';
import 'package:legado_flutter/domain/usecases/get_book_sources_usecase.dart';
import '../../helpers/test_helpers.dart';
import '../../mocks/mock_book_source_repository.dart';

void main() {
  late GetBookSourcesUseCase useCase;
  late MockBookSourceRepository mockBookSourceRepository;

  setUp(() {
    mockBookSourceRepository = MockBookSourceRepository();
    useCase = GetBookSourcesUseCase(
      bookSourceRepository: mockBookSourceRepository,
    );
  });

  group('GetBookSourcesUseCase', () {
    test('execute(enabledOnly: true) 应该只返回启用书源', () async {
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(
          bookSourceUrl: 'https://source1.com',
          enabled: true,
        ),
        createTestBookSourceEntity(
          bookSourceUrl: 'https://source2.com',
          enabled: false,
        ),
      ]);

      final result = await useCase.execute(enabledOnly: true);

      expect(result, hasLength(1));
      expect(result.first.bookSourceUrl, 'https://source1.com');
    });

    test('executeDisabled 应该返回禁用书源', () async {
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(
          bookSourceUrl: 'https://source1.com',
          enabled: true,
        ),
        createTestBookSourceEntity(
          bookSourceUrl: 'https://source2.com',
          enabled: false,
        ),
      ]);

      final result = await useCase.executeDisabled();

      expect(result, hasLength(1));
      expect(result.first.bookSourceUrl, 'https://source2.com');
    });

    test('executeByGroup、getAllGroups 和 search 应该委托给仓库', () async {
      mockBookSourceRepository.setAllSources([
        createTestBookSourceEntity(
          bookSourceUrl: 'https://alpha.com',
          bookSourceName: 'Alpha源',
        ),
        createTestBookSourceEntity(
          bookSourceUrl: 'https://beta.com',
          bookSourceName: 'Beta源',
        ).copyWith(bookSourceGroup: '其他'),
      ]);
      mockBookSourceRepository.setGroups(['测试', '其他']);

      final groupResult = await useCase.executeByGroup('测试');
      final groups = await useCase.getAllGroups();
      final searchResult = await useCase.search('Beta');

      expect(groupResult, hasLength(1));
      expect(groupResult.first.bookSourceUrl, 'https://alpha.com');
      expect(groups, ['测试', '其他']);
      expect(searchResult, hasLength(1));
      expect(searchResult.first.bookSourceUrl, 'https://beta.com');
    });
  });
}
